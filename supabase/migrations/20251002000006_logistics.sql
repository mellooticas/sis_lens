-- Migration: 006_logistics.sql
-- Schema logistics: Prazos de entrega e custos de frete

-- ============================================
-- TABELA: tabela_prazos
-- ============================================
CREATE TABLE logistics.tabela_prazos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    laboratorio_id UUID NOT NULL REFERENCES suppliers.laboratorios(id) ON DELETE CASCADE,
    regiao_origem TEXT,
    regiao_destino TEXT NOT NULL,
    prazo_minimo INTEGER NOT NULL,
    prazo_maximo INTEGER NOT NULL,
    prazo_medio INTEGER GENERATED ALWAYS AS ((prazo_minimo + prazo_maximo) / 2) STORED,
    custo_frete NUMERIC(8,2) NOT NULL DEFAULT 0,
    frete_gratis_acima NUMERIC(10,2),
    tipo_servico TEXT NOT NULL DEFAULT 'PADRAO',
    observacoes TEXT,
    vigencia_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
    vigencia_fim DATE,
    ativo BOOLEAN NOT NULL DEFAULT true,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CHECK (prazo_minimo >= 1 AND prazo_minimo <= 60),
    CHECK (prazo_maximo >= prazo_minimo AND prazo_maximo <= 60),
    CHECK (custo_frete >= 0),
    CHECK (frete_gratis_acima IS NULL OR frete_gratis_acima > 0),
    CHECK (vigencia_fim IS NULL OR vigencia_fim > vigencia_inicio),
    CHECK (regiao_destino IN ('NORTE', 'NORDESTE', 'CENTRO_OESTE', 'SUDESTE', 'SUL', 'NACIONAL')),
    CHECK (tipo_servico IN ('PADRAO', 'EXPRESSO', 'ECONOMICO', 'URGENCIA'))
);

-- Índices
CREATE INDEX idx_prazos_tenant ON logistics.tabela_prazos(tenant_id);
CREATE INDEX idx_prazos_laboratorio ON logistics.tabela_prazos(laboratorio_id);
CREATE INDEX idx_prazos_regiao_destino ON logistics.tabela_prazos(regiao_destino);
CREATE INDEX idx_prazos_tipo_servico ON logistics.tabela_prazos(tipo_servico);
CREATE INDEX idx_prazos_vigencia ON logistics.tabela_prazos(vigencia_inicio, vigencia_fim);
CREATE INDEX idx_prazos_ativo ON logistics.tabela_prazos(ativo);
CREATE INDEX idx_prazos_prazo_medio ON logistics.tabela_prazos(prazo_medio);

-- ============================================
-- TABELA: zonas_entrega
-- ============================================
CREATE TABLE logistics.zonas_entrega (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    nome_zona TEXT NOT NULL,
    regiao TEXT NOT NULL,
    estados TEXT[] NOT NULL,
    cidades_especiais TEXT[] DEFAULT '{}',
    ceps_especiais TEXT[] DEFAULT '{}',
    observacoes TEXT,
    ativo BOOLEAN NOT NULL DEFAULT true,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, nome_zona),
    CHECK (regiao IN ('NORTE', 'NORDESTE', 'CENTRO_OESTE', 'SUDESTE', 'SUL')),
    CHECK (array_length(estados, 1) > 0)
);

-- Índices
CREATE INDEX idx_zonas_tenant ON logistics.zonas_entrega(tenant_id);
CREATE INDEX idx_zonas_regiao ON logistics.zonas_entrega(regiao);
CREATE INDEX idx_zonas_estados ON logistics.zonas_entrega USING gin(estados);
CREATE INDEX idx_zonas_ceps ON logistics.zonas_entrega USING gin(ceps_especiais);

-- ============================================
-- TABELA: historico_entregas
-- ============================================
CREATE TABLE logistics.historico_entregas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    laboratorio_id UUID NOT NULL REFERENCES suppliers.laboratorios(id),
    regiao_destino TEXT NOT NULL,
    prazo_prometido INTEGER NOT NULL,
    prazo_real INTEGER,
    data_pedido DATE NOT NULL,
    data_entrega_prometida DATE NOT NULL,
    data_entrega_real DATE,
    status_entrega TEXT NOT NULL DEFAULT 'PENDENTE',
    custo_frete_cobrado NUMERIC(8,2),
    observacoes TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CHECK (prazo_prometido > 0),
    CHECK (prazo_real IS NULL OR prazo_real > 0),
    CHECK (data_entrega_prometida > data_pedido),
    CHECK (data_entrega_real IS NULL OR data_entrega_real >= data_pedido),
    CHECK (status_entrega IN ('PENDENTE', 'EM_TRANSITO', 'ENTREGUE', 'ATRASADO', 'CANCELADO')),
    CHECK (custo_frete_cobrado IS NULL OR custo_frete_cobrado >= 0)
);

-- Índices
CREATE INDEX idx_historico_tenant ON logistics.historico_entregas(tenant_id);
CREATE INDEX idx_historico_laboratorio ON logistics.historico_entregas(laboratorio_id);
CREATE INDEX idx_historico_regiao ON logistics.historico_entregas(regiao_destino);
CREATE INDEX idx_historico_data_pedido ON logistics.historico_entregas(data_pedido);
CREATE INDEX idx_historico_status ON logistics.historico_entregas(status_entrega);

-- ============================================
-- TRIGGERS
-- ============================================
CREATE TRIGGER tr_prazos_updated_at
    BEFORE UPDATE ON logistics.tabela_prazos
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

-- Trigger para calcular prazo real quando entrega é confirmada
CREATE OR REPLACE FUNCTION logistics.calcular_prazo_real()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.data_entrega_real IS NOT NULL AND OLD.data_entrega_real IS NULL THEN
        NEW.prazo_real := NEW.data_entrega_real - NEW.data_pedido;
        
        -- Atualiza status baseado no prazo
        IF NEW.prazo_real <= NEW.prazo_prometido THEN
            NEW.status_entrega := 'ENTREGUE';
        ELSE
            NEW.status_entrega := 'ATRASADO';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_historico_prazo_real
    BEFORE UPDATE ON logistics.historico_entregas
    FOR EACH ROW EXECUTE FUNCTION logistics.calcular_prazo_real();

-- ============================================
-- FUNÇÕES AUXILIARES
-- ============================================

-- Função para buscar prazo e frete por laboratório e região
CREATE OR REPLACE FUNCTION logistics.buscar_prazo_frete(
    p_laboratorio_id UUID,
    p_regiao_destino TEXT,
    p_valor_pedido NUMERIC DEFAULT 0,
    p_tipo_servico TEXT DEFAULT 'PADRAO',
    p_data_referencia DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    prazo_minimo INTEGER,
    prazo_maximo INTEGER,
    prazo_medio INTEGER,
    custo_frete NUMERIC,
    frete_gratis BOOLEAN,
    tipo_servico TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tp.prazo_minimo,
        tp.prazo_maximo,
        tp.prazo_medio,
        CASE 
            WHEN tp.frete_gratis_acima IS NOT NULL AND p_valor_pedido >= tp.frete_gratis_acima 
            THEN 0::NUMERIC(8,2)
            ELSE tp.custo_frete 
        END as custo_frete,
        (tp.frete_gratis_acima IS NOT NULL AND p_valor_pedido >= tp.frete_gratis_acima) as frete_gratis,
        tp.tipo_servico
    FROM logistics.tabela_prazos tp
    WHERE tp.laboratorio_id = p_laboratorio_id
      AND (tp.regiao_destino = p_regiao_destino OR tp.regiao_destino = 'NACIONAL')
      AND tp.tipo_servico = p_tipo_servico
      AND tp.ativo = true
      AND tp.vigencia_inicio <= p_data_referencia
      AND (tp.vigencia_fim IS NULL OR tp.vigencia_fim >= p_data_referencia)
    ORDER BY 
        CASE WHEN tp.regiao_destino = p_regiao_destino THEN 1 ELSE 2 END,
        tp.vigencia_inicio DESC
    LIMIT 1;
    
    -- Se não encontrou, tenta com serviço padrão
    IF NOT FOUND AND p_tipo_servico != 'PADRAO' THEN
        RETURN QUERY
        SELECT * FROM logistics.buscar_prazo_frete(
            p_laboratorio_id, p_regiao_destino, p_valor_pedido, 'PADRAO', p_data_referencia
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para calcular métricas de entrega por laboratório
CREATE OR REPLACE FUNCTION logistics.calcular_metricas_entrega(
    p_laboratorio_id UUID,
    p_periodo_inicio DATE DEFAULT CURRENT_DATE - INTERVAL '90 days',
    p_periodo_fim DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    total_entregas INTEGER,
    entregas_no_prazo INTEGER,
    entregas_atrasadas INTEGER,
    percentual_no_prazo NUMERIC,
    atraso_medio_dias NUMERIC,
    prazo_medio_prometido NUMERIC,
    prazo_medio_real NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::INTEGER as total_entregas,
        COUNT(*) FILTER (WHERE he.prazo_real <= he.prazo_prometido)::INTEGER as entregas_no_prazo,
        COUNT(*) FILTER (WHERE he.prazo_real > he.prazo_prometido)::INTEGER as entregas_atrasadas,
        ROUND(
            COUNT(*) FILTER (WHERE he.prazo_real <= he.prazo_prometido)::NUMERIC / 
            NULLIF(COUNT(*), 0) * 100, 
            2
        ) as percentual_no_prazo,
        ROUND(
            AVG(CASE WHEN he.prazo_real > he.prazo_prometido 
                THEN he.prazo_real - he.prazo_prometido 
                ELSE 0 END), 
            2
        ) as atraso_medio_dias,
        ROUND(AVG(he.prazo_prometido), 2) as prazo_medio_prometido,
        ROUND(AVG(he.prazo_real), 2) as prazo_medio_real
    FROM logistics.historico_entregas he
    WHERE he.laboratorio_id = p_laboratorio_id
      AND he.data_pedido BETWEEN p_periodo_inicio AND p_periodo_fim
      AND he.data_entrega_real IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- VIEWS AUXILIARES
-- ============================================

-- View para prazos vigentes com dados do laboratório
CREATE OR REPLACE VIEW logistics.vw_prazos_vigentes AS
SELECT 
    tp.*,
    lab.nome AS laboratorio_nome,
    lab.nome_fantasia AS laboratorio_fantasia,
    lab.atende_regioes
FROM logistics.tabela_prazos tp
JOIN suppliers.laboratorios lab ON lab.id = tp.laboratorio_id
WHERE tp.ativo = true
  AND tp.vigencia_inicio <= CURRENT_DATE
  AND (tp.vigencia_fim IS NULL OR tp.vigencia_fim >= CURRENT_DATE)
  AND lab.ativo = true;

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE logistics.tabela_prazos IS 'Prazos de entrega e custos de frete por laboratório e região';
COMMENT ON COLUMN logistics.tabela_prazos.prazo_medio IS 'Calculado automaticamente: (minimo + maximo) / 2';
COMMENT ON COLUMN logistics.tabela_prazos.regiao_origem IS 'Região de origem (opcional, null = sede do lab)';
COMMENT ON COLUMN logistics.tabela_prazos.frete_gratis_acima IS 'Valor mínimo para frete grátis';

COMMENT ON TABLE logistics.zonas_entrega IS 'Definição de zonas geográficas para cálculo de frete';
COMMENT ON TABLE logistics.historico_entregas IS 'Histórico real de entregas para cálculo de métricas de qualidade';

COMMENT ON FUNCTION logistics.buscar_prazo_frete IS 'Busca prazo e frete considerando valor do pedido e tipo de serviço';
COMMENT ON FUNCTION logistics.calcular_metricas_entrega IS 'Calcula métricas de performance de entrega de um laboratório';

-- ============================================
-- DADOS INICIAIS (EXEMPLOS)
-- ============================================

DO $$
DECLARE
    v_tenant_id UUID;
    v_lab_premium_id UUID;
    v_lab_visao_id UUID;
    v_lab_express_id UUID;
BEGIN
    -- Pega referências
    SELECT id INTO v_tenant_id FROM meta_system.tenants WHERE slug = 'demo';
    SELECT id INTO v_lab_premium_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Premium Ótica';
    SELECT id INTO v_lab_visao_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Visão Clara';
    SELECT id INTO v_lab_express_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Express';
    
    -- Zonas de entrega
    INSERT INTO logistics.zonas_entrega (tenant_id, nome_zona, regiao, estados) VALUES 
    (v_tenant_id, 'Sudeste Metropolitano', 'SUDESTE', ARRAY['SP', 'RJ', 'ES']),
    (v_tenant_id, 'Sudeste Interior', 'SUDESTE', ARRAY['MG']),
    (v_tenant_id, 'Sul Completo', 'SUL', ARRAY['RS', 'SC', 'PR']),
    (v_tenant_id, 'Nordeste Principal', 'NORDESTE', ARRAY['BA', 'PE', 'CE']),
    (v_tenant_id, 'Norte/Centro-Oeste', 'NORTE', ARRAY['AM', 'PA', 'GO', 'DF', 'MT', 'MS']);
    
    -- Prazos Lab Premium (mais rápido, mais caro)
    INSERT INTO logistics.tabela_prazos (
        tenant_id, laboratorio_id, regiao_destino, prazo_minimo, prazo_maximo, 
        custo_frete, frete_gratis_acima, tipo_servico
    ) VALUES 
    (v_tenant_id, v_lab_premium_id, 'SUDESTE', 2, 4, 25.00, 500.00, 'PADRAO'),
    (v_tenant_id, v_lab_premium_id, 'SUL', 3, 6, 35.00, 500.00, 'PADRAO'),
    (v_tenant_id, v_lab_premium_id, 'NORDESTE', 5, 8, 45.00, 700.00, 'PADRAO'),
    (v_tenant_id, v_lab_premium_id, 'CENTRO_OESTE', 4, 7, 40.00, 600.00, 'PADRAO'),
    (v_tenant_id, v_lab_premium_id, 'NORTE', 6, 10, 60.00, 800.00, 'PADRAO'),
    
    -- Serviço expresso Premium
    (v_tenant_id, v_lab_premium_id, 'SUDESTE', 1, 2, 50.00, 1000.00, 'EXPRESSO'),
    (v_tenant_id, v_lab_premium_id, 'SUL', 2, 3, 70.00, 1000.00, 'EXPRESSO'),
    
    -- Prazos Lab Visão Clara (médio)
    (v_tenant_id, v_lab_visao_id, 'SUDESTE', 3, 6, 20.00, 400.00, 'PADRAO'),
    (v_tenant_id, v_lab_visao_id, 'NORDESTE', 2, 4, 15.00, 300.00, 'PADRAO'),
    (v_tenant_id, v_lab_visao_id, 'SUL', 5, 8, 30.00, 500.00, 'PADRAO'),
    (v_tenant_id, v_lab_visao_id, 'NACIONAL', 4, 10, 25.00, 450.00, 'PADRAO'),
    
    -- Prazos Lab Express (mais lento, mais barato)
    (v_tenant_id, v_lab_express_id, 'NACIONAL', 7, 14, 12.00, 200.00, 'PADRAO'),
    (v_tenant_id, v_lab_express_id, 'NORDESTE', 3, 7, 8.00, 150.00, 'PADRAO'),
    (v_tenant_id, v_lab_express_id, 'NACIONAL', 5, 10, 18.00, 300.00, 'EXPRESSO');
    
    -- Histórico de entregas (dados fictícios para cálculo de métricas)
    INSERT INTO logistics.historico_entregas (
        tenant_id, laboratorio_id, regiao_destino, prazo_prometido, prazo_real,
        data_pedido, data_entrega_prometida, data_entrega_real, status_entrega
    ) VALUES 
    -- Premium: bom histórico
    (v_tenant_id, v_lab_premium_id, 'SUDESTE', 4, 3, '2024-09-01', '2024-09-05', '2024-09-04', 'ENTREGUE'),
    (v_tenant_id, v_lab_premium_id, 'SUDESTE', 4, 4, '2024-09-05', '2024-09-09', '2024-09-09', 'ENTREGUE'),
    (v_tenant_id, v_lab_premium_id, 'SUL', 6, 5, '2024-09-10', '2024-09-16', '2024-09-15', 'ENTREGUE'),
    (v_tenant_id, v_lab_premium_id, 'SUDESTE', 4, 6, '2024-09-15', '2024-09-19', '2024-09-21', 'ATRASADO'),
    
    -- Visão Clara: histórico médio
    (v_tenant_id, v_lab_visao_id, 'SUDESTE', 6, 6, '2024-09-01', '2024-09-07', '2024-09-07', 'ENTREGUE'),
    (v_tenant_id, v_lab_visao_id, 'NORDESTE', 4, 3, '2024-09-03', '2024-09-07', '2024-09-06', 'ENTREGUE'),
    (v_tenant_id, v_lab_visao_id, 'SUL', 8, 10, '2024-09-08', '2024-09-16', '2024-09-18', 'ATRASADO'),
    
    -- Express: histórico variável
    (v_tenant_id, v_lab_express_id, 'NORDESTE', 7, 6, '2024-09-01', '2024-09-08', '2024-09-07', 'ENTREGUE'),
    (v_tenant_id, v_lab_express_id, 'NACIONAL', 14, 16, '2024-09-05', '2024-09-19', '2024-09-21', 'ATRASADO'),
    (v_tenant_id, v_lab_express_id, 'NORDESTE', 7, 9, '2024-09-10', '2024-09-17', '2024-09-19', 'ATRASADO');
    
END $$;