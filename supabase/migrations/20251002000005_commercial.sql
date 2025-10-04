-- Migration: 005_commercial.sql
-- Schema commercial: Precificação e descontos

-- ============================================
-- TABELA: precos_base
-- ============================================
CREATE TABLE commercial.precos_base (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    produto_lab_id UUID NOT NULL REFERENCES suppliers.produtos_laboratorio(id) ON DELETE CASCADE,
    moeda TEXT NOT NULL DEFAULT 'BRL',
    preco_custo NUMERIC(10,2),
    preco_tabela NUMERIC(10,2) NOT NULL,
    margem_percentual NUMERIC(5,2) GENERATED ALWAYS AS (
        CASE 
            WHEN preco_custo IS NOT NULL AND preco_custo > 0 
            THEN ((preco_tabela - preco_custo) / preco_custo * 100)
            ELSE NULL 
        END
    ) STORED,
    vigencia_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
    vigencia_fim DATE,
    tabela_referencia TEXT NOT NULL,
    observacoes TEXT,
    ativo BOOLEAN NOT NULL DEFAULT true,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CHECK (preco_tabela > 0),
    CHECK (preco_custo IS NULL OR preco_custo >= 0),
    CHECK (vigencia_fim IS NULL OR vigencia_fim > vigencia_inicio),
    CHECK (moeda IN ('BRL', 'USD', 'EUR'))
);

-- Constraint para evitar sobreposição de vigências por produto
CREATE UNIQUE INDEX idx_precos_base_vigencia_exclusiva 
ON commercial.precos_base (tenant_id, produto_lab_id, vigencia_inicio) 
WHERE ativo = true AND vigencia_fim IS NULL;

-- Índices
CREATE INDEX idx_precos_tenant ON commercial.precos_base(tenant_id);
CREATE INDEX idx_precos_produto ON commercial.precos_base(produto_lab_id);
CREATE INDEX idx_precos_vigencia ON commercial.precos_base(vigencia_inicio, vigencia_fim);
CREATE INDEX idx_precos_tabela ON commercial.precos_base(preco_tabela);
CREATE INDEX idx_precos_ativo ON commercial.precos_base(ativo);

-- ============================================
-- TABELA: descontos
-- ============================================
CREATE TABLE commercial.descontos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    descricao TEXT,
    escopo public.escopo_desconto NOT NULL,
    alvo_id UUID NOT NULL, -- FK polimórfico (lab_id, marca_id ou produto_lab_id)
    tipo_desconto public.tipo_desconto NOT NULL,
    valor NUMERIC(10,2) NOT NULL,
    prioridade INTEGER NOT NULL DEFAULT 1,
    vigencia_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
    vigencia_fim DATE,
    quantidade_minima INTEGER DEFAULT 1,
    valor_minimo_pedido NUMERIC(10,2),
    condicoes_especiais JSONB DEFAULT '{}',
    uso_maximo INTEGER, -- limite de uso (null = ilimitado)
    uso_atual INTEGER NOT NULL DEFAULT 0,
    ativo BOOLEAN NOT NULL DEFAULT true,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CHECK (valor > 0),
    CHECK (prioridade BETWEEN 1 AND 100),
    CHECK (vigencia_fim IS NULL OR vigencia_fim > vigencia_inicio),
    CHECK (quantidade_minima >= 1),
    CHECK (valor_minimo_pedido IS NULL OR valor_minimo_pedido > 0),
    CHECK (uso_maximo IS NULL OR uso_maximo > 0),
    CHECK (uso_atual >= 0),
    CHECK (uso_maximo IS NULL OR uso_atual <= uso_maximo)
);

-- Índices
CREATE INDEX idx_descontos_tenant ON commercial.descontos(tenant_id);
CREATE INDEX idx_descontos_escopo ON commercial.descontos(escopo);
CREATE INDEX idx_descontos_alvo ON commercial.descontos(alvo_id);
CREATE INDEX idx_descontos_tipo ON commercial.descontos(tipo_desconto);
CREATE INDEX idx_descontos_prioridade ON commercial.descontos(prioridade DESC);
CREATE INDEX idx_descontos_vigencia ON commercial.descontos(vigencia_inicio, vigencia_fim);
CREATE INDEX idx_descontos_ativo ON commercial.descontos(ativo);

-- ============================================
-- TABELA: historico_precos
-- ============================================
CREATE TABLE commercial.historico_precos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL,
    produto_lab_id UUID NOT NULL,
    preco_anterior NUMERIC(10,2),
    preco_novo NUMERIC(10,2) NOT NULL,
    motivo_alteracao TEXT,
    alterado_por UUID, -- user_id (futuro)
    alterado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_historico_tenant ON commercial.historico_precos(tenant_id);
CREATE INDEX idx_historico_produto ON commercial.historico_precos(produto_lab_id);
CREATE INDEX idx_historico_data ON commercial.historico_precos(alterado_em);

-- ============================================
-- TRIGGERS
-- ============================================
CREATE TRIGGER tr_precos_base_updated_at
    BEFORE UPDATE ON commercial.precos_base
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

CREATE TRIGGER tr_descontos_updated_at
    BEFORE UPDATE ON commercial.descontos
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

-- Trigger para log de alterações de preço
CREATE OR REPLACE FUNCTION commercial.log_preco_alteracao()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.preco_tabela != NEW.preco_tabela THEN
        INSERT INTO commercial.historico_precos (
            tenant_id, produto_lab_id, preco_anterior, preco_novo, motivo_alteracao
        ) VALUES (
            NEW.tenant_id, NEW.produto_lab_id, OLD.preco_tabela, NEW.preco_tabela, 
            'Atualização tabela de preços'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_precos_log_alteracao
    AFTER UPDATE ON commercial.precos_base
    FOR EACH ROW EXECUTE FUNCTION commercial.log_preco_alteracao();

-- ============================================
-- FUNÇÕES DE CÁLCULO
-- ============================================

-- Função para calcular preço final com descontos
CREATE OR REPLACE FUNCTION commercial.calcular_preco_final(
    p_produto_lab_id UUID,
    p_tenant_id UUID,
    p_data_referencia DATE DEFAULT CURRENT_DATE,
    p_quantidade INTEGER DEFAULT 1,
    p_valor_pedido NUMERIC DEFAULT NULL
)
RETURNS TABLE (
    preco_tabela NUMERIC,
    descontos_aplicados JSONB,
    preco_final NUMERIC,
    economia NUMERIC
) AS $$
DECLARE
    v_preco_base NUMERIC;
    v_preco_atual NUMERIC;
    v_desconto RECORD;
    v_valor_desconto NUMERIC;
    v_descontos JSONB := '[]'::JSONB;
    v_economia_total NUMERIC := 0;
BEGIN
    -- Busca preço base vigente
    SELECT pb.preco_tabela INTO v_preco_base
    FROM commercial.precos_base pb
    WHERE pb.produto_lab_id = p_produto_lab_id
      AND pb.tenant_id = p_tenant_id
      AND pb.ativo = true
      AND pb.vigencia_inicio <= p_data_referencia
      AND (pb.vigencia_fim IS NULL OR pb.vigencia_fim >= p_data_referencia)
    ORDER BY pb.vigencia_inicio DESC
    LIMIT 1;
    
    IF v_preco_base IS NULL THEN
        RAISE EXCEPTION 'Preço não encontrado para produto %', p_produto_lab_id;
    END IF;
    
    v_preco_atual := v_preco_base;
    
    -- Busca descontos aplicáveis ordenados por prioridade
    FOR v_desconto IN
        SELECT d.*, 
               CASE d.escopo
                   WHEN 'PRODUTO' THEN pl.id
                   WHEN 'MARCA' THEN l.marca_id  
                   WHEN 'LABORATORIO' THEN pl.laboratorio_id
               END as id_comparacao
        FROM commercial.descontos d,
             suppliers.produtos_laboratorio pl,
             lens_catalog.lentes l
        WHERE pl.id = p_produto_lab_id
          AND l.id = pl.lente_id
          AND d.tenant_id = p_tenant_id
          AND d.ativo = true
          AND d.vigencia_inicio <= p_data_referencia
          AND (d.vigencia_fim IS NULL OR d.vigencia_fim >= p_data_referencia)
          AND (d.uso_maximo IS NULL OR d.uso_atual < d.uso_maximo)
          AND (d.quantidade_minima <= p_quantidade)
          AND (d.valor_minimo_pedido IS NULL OR p_valor_pedido >= d.valor_minimo_pedido)
          AND (
              (d.escopo = 'PRODUTO' AND d.alvo_id = pl.id) OR
              (d.escopo = 'MARCA' AND d.alvo_id = l.marca_id) OR
              (d.escopo = 'LABORATORIO' AND d.alvo_id = pl.laboratorio_id)
          )
        ORDER BY d.prioridade DESC, d.criado_em ASC
    LOOP
        -- Calcula desconto
        v_valor_desconto := CASE v_desconto.tipo_desconto
            WHEN 'PERCENTUAL' THEN v_preco_atual * (v_desconto.valor / 100)
            WHEN 'VALOR_FIXO' THEN v_desconto.valor
            WHEN 'PRECO_TETO' THEN GREATEST(0, v_preco_atual - v_desconto.valor)
        END;
        
        -- Aplica desconto
        IF v_desconto.tipo_desconto = 'PRECO_TETO' THEN
            v_preco_atual := LEAST(v_preco_atual, v_desconto.valor);
        ELSE
            v_preco_atual := v_preco_atual - v_valor_desconto;
        END IF;
        
        v_economia_total := v_economia_total + v_valor_desconto;
        
        -- Adiciona ao log de descontos
        v_descontos := v_descontos || jsonb_build_object(
            'nome', v_desconto.nome,
            'tipo', v_desconto.tipo_desconto,
            'valor_desconto', v_valor_desconto,
            'preco_apos', v_preco_atual
        );
    END LOOP;
    
    -- Garante que preço não seja negativo
    v_preco_atual := GREATEST(0, v_preco_atual);
    
    RETURN QUERY SELECT 
        v_preco_base,
        v_descontos,
        v_preco_atual,
        v_economia_total;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- VIEWS AUXILIARES
-- ============================================

-- View para preços vigentes
CREATE OR REPLACE VIEW commercial.vw_precos_vigentes AS
SELECT 
    pb.*,
    pl.sku_laboratorio,
    pl.sku_fantasia,
    pl.nome_comercial,
    lab.nome AS laboratorio_nome,
    le.familia,
    le.design,
    ma.nome AS marca_nome
FROM commercial.precos_base pb
JOIN suppliers.produtos_laboratorio pl ON pl.id = pb.produto_lab_id
JOIN suppliers.laboratorios lab ON lab.id = pl.laboratorio_id  
JOIN lens_catalog.lentes le ON le.id = pl.lente_id
JOIN lens_catalog.marcas ma ON ma.id = le.marca_id
WHERE pb.ativo = true
  AND pb.vigencia_inicio <= CURRENT_DATE
  AND (pb.vigencia_fim IS NULL OR pb.vigencia_fim >= CURRENT_DATE);

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE commercial.precos_base IS 'Preços base dos produtos com vigência temporal';
COMMENT ON COLUMN commercial.precos_base.margem_percentual IS 'Margem calculada automaticamente: ((tabela - custo) / custo) * 100';
COMMENT ON COLUMN commercial.precos_base.tabela_referencia IS 'Referência da tabela (ex: TABELA_2024_Q1, PROMOCAO_VERAO)';

COMMENT ON TABLE commercial.descontos IS 'Regras de desconto por escopo (lab, marca ou produto)';
COMMENT ON COLUMN commercial.descontos.alvo_id IS 'FK polimórfico: laboratorio_id, marca_id ou produto_lab_id conforme escopo';
COMMENT ON COLUMN commercial.descontos.prioridade IS 'Ordem de aplicação (maior primeiro). Evita conflitos.';
COMMENT ON COLUMN commercial.descontos.condicoes_especiais IS 'Condições extras em JSON: cliente_especifico, periodo_especial, etc.';

COMMENT ON FUNCTION commercial.calcular_preco_final IS 'Calcula preço final aplicando todos os descontos válidos por prioridade';

-- ============================================
-- DADOS INICIAIS (EXEMPLOS)
-- ============================================

DO $$
DECLARE
    v_tenant_id UUID;
    v_produto_varilux_premium UUID;
    v_produto_varilux_visao UUID;
    v_produto_hoya_express UUID;
    v_lab_premium_id UUID;
    v_marca_essilor_id UUID;
BEGIN
    -- Pega referências
    SELECT id INTO v_tenant_id FROM meta_system.tenants WHERE slug = 'demo';
    
    SELECT pl.id INTO v_produto_varilux_premium 
    FROM suppliers.produtos_laboratorio pl 
    JOIN suppliers.laboratorios lab ON lab.id = pl.laboratorio_id
    WHERE lab.nome_fantasia = 'Premium Ótica' AND pl.sku_fantasia = 'PREMIUM-VLX-X-167-BLUE';
    
    SELECT pl.id INTO v_produto_varilux_visao
    FROM suppliers.produtos_laboratorio pl 
    JOIN suppliers.laboratorios lab ON lab.id = pl.laboratorio_id  
    WHERE lab.nome_fantasia = 'Visão Clara' AND pl.sku_fantasia = 'VISAO-VLX-X-167-HC-AR-BLUE';
    
    SELECT pl.id INTO v_produto_hoya_express
    FROM suppliers.produtos_laboratorio pl 
    JOIN suppliers.laboratorios lab ON lab.id = pl.laboratorio_id
    WHERE lab.nome_fantasia = 'Express' AND pl.sku_fantasia = 'EXPRESS-HOYA-ID-167';
    
    SELECT id INTO v_lab_premium_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Premium Ótica';
    SELECT id INTO v_marca_essilor_id FROM lens_catalog.marcas WHERE nome = 'Essilor';
    
    -- Insere preços base
    INSERT INTO commercial.precos_base (
        tenant_id, produto_lab_id, preco_custo, preco_tabela, tabela_referencia
    ) VALUES 
    (v_tenant_id, v_produto_varilux_premium, 280.00, 420.00, 'TABELA_PREMIUM_2024_Q4'),
    (v_tenant_id, v_produto_varilux_visao, 260.00, 380.00, 'TABELA_VISAO_2024_Q4'),
    (v_tenant_id, v_produto_hoya_express, 240.00, 350.00, 'TABELA_EXPRESS_2024_Q4');
    
    -- Insere descontos
    INSERT INTO commercial.descontos (
        tenant_id, nome, descricao, escopo, alvo_id, tipo_desconto, valor, prioridade,
        vigencia_inicio, vigencia_fim
    ) VALUES 
    -- Desconto no laboratório Premium
    (v_tenant_id, 'Desconto Premium VIP', 'Desconto especial laboratório premium', 
     'LABORATORIO', v_lab_premium_id, 'PERCENTUAL', 10.00, 50,
     CURRENT_DATE, CURRENT_DATE + INTERVAL '3 months'),
     
    -- Desconto na marca Essilor
    (v_tenant_id, 'Promocão Essilor', 'Promoção especial marca Essilor',
     'MARCA', v_marca_essilor_id, 'VALOR_FIXO', 25.00, 30,
     CURRENT_DATE, CURRENT_DATE + INTERVAL '1 month'),
     
    -- Preço teto em produto específico
    (v_tenant_id, 'Preço Máximo Varilux Premium', 'Preço teto para competir',
     'PRODUTO', v_produto_varilux_premium, 'PRECO_TETO', 350.00, 80,
     CURRENT_DATE, CURRENT_DATE + INTERVAL '2 months');
     
END $$;