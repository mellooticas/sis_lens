-- Migration: 008_orders.sql
-- Schema orders: Sistema de pedidos/decisões de lentes

-- ============================================
-- TABELA: decisoes_lentes
-- ============================================
CREATE TABLE orders.decisoes_lentes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    codigo_decisao TEXT NOT NULL,
    
    -- Dados do Cliente/Ótica
    otica_id UUID,
    nome_otica TEXT,
    vendedor_nome TEXT,
    cliente_nome TEXT,
    cliente_idade INTEGER,
    
    -- Receita Médica
    receita JSONB NOT NULL,
    tipo_receita TEXT NOT NULL,
    
    -- Especificações da Lente
    especificacoes JSONB NOT NULL,
    necessidades_especiais TEXT[],
    uso_principal TEXT,
    prioridades JSONB,
    
    -- Resultado da Decisão
    lente_recomendada_id UUID REFERENCES lens_catalog.lentes(id),
    laboratorio_escolhido_id UUID REFERENCES suppliers.laboratorios(id),
    justificativa_tecnica TEXT,
    
    -- Comercial
    preco_final NUMERIC(10,2),
    desconto_aplicado NUMERIC(5,2) DEFAULT 0,
    desconto_detalhes JSONB,
    condicoes_pagamento TEXT,
    
    -- Logística
    prazo_entrega_prometido INTEGER,
    custo_frete NUMERIC(8,2) DEFAULT 0,
    endereco_entrega JSONB,
    
    -- Status e Controle
    status TEXT NOT NULL DEFAULT 'COTACAO',
    prioridade TEXT NOT NULL DEFAULT 'NORMAL',
    observacoes TEXT,
    tags TEXT[] DEFAULT '{}',
    
    -- Metadados
    criado_por UUID,
    aprovado_por UUID,
    data_aprovacao TIMESTAMPTZ,
    versao INTEGER NOT NULL DEFAULT 1,
    decisao_original_id UUID,
    
    -- Timestamps
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, codigo_decisao),
    CHECK (cliente_idade IS NULL OR (cliente_idade >= 0 AND cliente_idade <= 120)),
    CHECK (desconto_aplicado >= 0 AND desconto_aplicado <= 100),
    CHECK (preco_final IS NULL OR preco_final > 0),
    CHECK (prazo_entrega_prometido IS NULL OR prazo_entrega_prometido > 0),
    CHECK (custo_frete >= 0),
    CHECK (versao > 0),
    CHECK (tipo_receita IN ('VISAO_SIMPLES', 'MULTIFOCAL', 'PROGRESSIVA', 'ESPECIAL')),
    CHECK (status IN ('COTACAO', 'APROVADA', 'PRODUCAO', 'PRONTA', 'ENTREGUE', 'CANCELADA')),
    CHECK (prioridade IN ('BAIXA', 'NORMAL', 'ALTA', 'URGENTE')),
    CHECK (uso_principal IN ('DISTANCIA', 'PERTO', 'COMPUTADOR', 'ESPORTE', 'SOCIAL', 'PROFISSIONAL', 'GERAL'))
);

-- Índices
CREATE INDEX idx_decisoes_tenant ON orders.decisoes_lentes(tenant_id);
CREATE INDEX idx_decisoes_codigo ON orders.decisoes_lentes(codigo_decisao);
CREATE INDEX idx_decisoes_status ON orders.decisoes_lentes(status);
CREATE INDEX idx_decisoes_prioridade ON orders.decisoes_lentes(prioridade);
CREATE INDEX idx_decisoes_otica ON orders.decisoes_lentes(otica_id);
CREATE INDEX idx_decisoes_lente ON orders.decisoes_lentes(lente_recomendada_id);
CREATE INDEX idx_decisoes_laboratorio ON orders.decisoes_lentes(laboratorio_escolhido_id);
CREATE INDEX idx_decisoes_criado_em ON orders.decisoes_lentes(criado_em);
CREATE INDEX idx_decisoes_tipo_receita ON orders.decisoes_lentes(tipo_receita);
CREATE INDEX idx_decisoes_uso ON orders.decisoes_lentes(uso_principal);
CREATE INDEX idx_decisoes_tags ON orders.decisoes_lentes USING gin(tags);

-- ============================================
-- TABELA: alternativas_cotacao
-- ============================================
CREATE TABLE orders.alternativas_cotacao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    decisao_id UUID NOT NULL REFERENCES orders.decisoes_lentes(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    
    -- Identificação da Alternativa
    posicao INTEGER NOT NULL,
    tipo_alternativa TEXT NOT NULL DEFAULT 'RECOMENDACAO',
    
    -- Produto
    lente_id UUID NOT NULL REFERENCES lens_catalog.lentes(id),
    laboratorio_id UUID NOT NULL REFERENCES suppliers.laboratorios(id),
    
    -- Adequação Técnica
    percentual_adequacao NUMERIC(5,2),
    compatibilidade_receita JSONB,
    limitacoes TEXT[],
    
    -- Dados Comerciais
    preco_base NUMERIC(10,2) NOT NULL,
    desconto_percentual NUMERIC(5,2) DEFAULT 0,
    preco_final NUMERIC(10,2) NOT NULL,
    custo_frete NUMERIC(8,2) DEFAULT 0,
    preco_total NUMERIC(10,2) GENERATED ALWAYS AS (preco_final + custo_frete) STORED,
    
    -- Logística
    prazo_minimo INTEGER,
    prazo_maximo INTEGER,
    prazo_medio INTEGER GENERATED ALWAYS AS ((prazo_minimo + prazo_maximo) / 2) STORED,
    disponibilidade TEXT,
    
    -- Qualificação
    score_geral NUMERIC(5,2),
    score_qualidade NUMERIC(5,2),
    score_preco NUMERIC(5,2),
    score_prazo NUMERIC(5,2),
    
    -- Justificativas
    pontos_fortes TEXT[],
    pontos_fracos TEXT[],
    observacoes TEXT,
    
    -- Controle
    ativa BOOLEAN NOT NULL DEFAULT true,
    recomendada BOOLEAN NOT NULL DEFAULT false,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(decisao_id, posicao),
    CHECK (posicao > 0),
    CHECK (percentual_adequacao IS NULL OR (percentual_adequacao >= 0 AND percentual_adequacao <= 100)),
    CHECK (desconto_percentual >= 0 AND desconto_percentual <= 100),
    CHECK (preco_base > 0 AND preco_final > 0),
    CHECK (custo_frete >= 0),
    CHECK (prazo_minimo IS NULL OR prazo_minimo > 0),
    CHECK (prazo_maximo IS NULL OR prazo_maximo >= prazo_minimo),
    CHECK (score_geral IS NULL OR (score_geral >= 0 AND score_geral <= 10)),
    CHECK (tipo_alternativa IN ('RECOMENDACAO', 'ALTERNATIVA', 'ECONOMICA', 'PREMIUM', 'SEGUNDA_OPCAO')),
    CHECK (disponibilidade IN ('DISPONIVEL', 'SOB_ENCOMENDA', 'LIMITADA', 'INDISPONIVEL'))
);

-- Índices
CREATE INDEX idx_alternativas_decisao ON orders.alternativas_cotacao(decisao_id);
CREATE INDEX idx_alternativas_tenant ON orders.alternativas_cotacao(tenant_id);
CREATE INDEX idx_alternativas_posicao ON orders.alternativas_cotacao(posicao);
CREATE INDEX idx_alternativas_lente ON orders.alternativas_cotacao(lente_id);
CREATE INDEX idx_alternativas_laboratorio ON orders.alternativas_cotacao(laboratorio_id);
CREATE INDEX idx_alternativas_preco ON orders.alternativas_cotacao(preco_total);
CREATE INDEX idx_alternativas_prazo ON orders.alternativas_cotacao(prazo_medio);
CREATE INDEX idx_alternativas_score ON orders.alternativas_cotacao(score_geral);
CREATE INDEX idx_alternativas_recomendada ON orders.alternativas_cotacao(recomendada);
CREATE INDEX idx_alternativas_ativa ON orders.alternativas_cotacao(ativa);

-- ============================================
-- TABELA: historico_status
-- ============================================
CREATE TABLE orders.historico_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    decisao_id UUID NOT NULL REFERENCES orders.decisoes_lentes(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    
    status_anterior TEXT,
    status_novo TEXT NOT NULL,
    motivo TEXT,
    detalhes JSONB,
    usuario_id UUID,
    usuario_nome TEXT,
    data_mudanca TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CHECK (status_anterior IS NULL OR status_anterior IN ('COTACAO', 'APROVADA', 'PRODUCAO', 'PRONTA', 'ENTREGUE', 'CANCELADA')),
    CHECK (status_novo IN ('COTACAO', 'APROVADA', 'PRODUCAO', 'PRONTA', 'ENTREGUE', 'CANCELADA'))
);

-- Índices
CREATE INDEX idx_historico_decisao ON orders.historico_status(decisao_id);
CREATE INDEX idx_historico_status_novo ON orders.historico_status(status_novo);
CREATE INDEX idx_historico_data ON orders.historico_status(data_mudanca);

-- ============================================
-- TABELA: criterios_decisao
-- ============================================
CREATE TABLE orders.criterios_decisao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    descricao TEXT,
    categoria TEXT NOT NULL,
    peso_padrao NUMERIC(3,2) NOT NULL DEFAULT 1.0,
    tipo_criterio TEXT NOT NULL,
    configuracao JSONB DEFAULT '{}',
    ativo BOOLEAN NOT NULL DEFAULT true,
    ordem INTEGER DEFAULT 1,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, nome),
    CHECK (peso_padrao >= 0 AND peso_padrao <= 5.0),
    CHECK (categoria IN ('TECNICO', 'COMERCIAL', 'LOGISTICO', 'QUALIDADE')),
    CHECK (tipo_criterio IN ('ADEQUACAO_RECEITA', 'PRECO', 'PRAZO', 'QUALIDADE', 'DISPONIBILIDADE', 'SCORE_LABORATORIO')),
    CHECK (ordem > 0)
);

-- Índices
CREATE INDEX idx_criterios_tenant ON orders.criterios_decisao(tenant_id);
CREATE INDEX idx_criterios_categoria ON orders.criterios_decisao(categoria);
CREATE INDEX idx_criterios_ativo ON orders.criterios_decisao(ativo);
CREATE INDEX idx_criterios_ordem ON orders.criterios_decisao(ordem);

-- ============================================
-- TRIGGERS
-- ============================================
CREATE TRIGGER tr_decisoes_updated_at
    BEFORE UPDATE ON orders.decisoes_lentes
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

-- Trigger para gerar código único de decisão
CREATE OR REPLACE FUNCTION orders.gerar_codigo_decisao()
RETURNS TRIGGER AS $$
DECLARE
    v_prefixo TEXT;
    v_sequencial INTEGER;
    v_codigo TEXT;
BEGIN
    IF NEW.codigo_decisao IS NULL OR NEW.codigo_decisao = '' THEN
        -- Gera prefixo baseado na data
        v_prefixo := TO_CHAR(NOW(), 'YYYYMM');
        
        -- Busca próximo sequencial do mês
        SELECT COALESCE(
            MAX(
                CASE 
                    WHEN codigo_decisao ~ ('^' || v_prefixo || '[0-9]+$') 
                    THEN SUBSTRING(codigo_decisao FROM LENGTH(v_prefixo) + 1)::INTEGER
                    ELSE 0 
                END
            ), 0
        ) + 1
        INTO v_sequencial
        FROM orders.decisoes_lentes
        WHERE tenant_id = NEW.tenant_id;
        
        -- Monta código final
        NEW.codigo_decisao := v_prefixo || LPAD(v_sequencial::TEXT, 4, '0');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_gerar_codigo_decisao
    BEFORE INSERT ON orders.decisoes_lentes
    FOR EACH ROW EXECUTE FUNCTION orders.gerar_codigo_decisao();

-- Trigger para registrar mudanças de status
CREATE OR REPLACE FUNCTION orders.registrar_mudanca_status()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND (OLD.status IS DISTINCT FROM NEW.status) THEN
        INSERT INTO orders.historico_status (
            decisao_id, tenant_id, status_anterior, status_novo, 
            motivo, usuario_nome
        ) VALUES (
            NEW.id, NEW.tenant_id, OLD.status, NEW.status,
            'Mudança automática de status', 'Sistema'
        );
        
        -- Atualiza data de aprovação se necessário
        IF NEW.status = 'APROVADA' AND OLD.status != 'APROVADA' THEN
            NEW.data_aprovacao := NOW();
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_mudanca_status
    BEFORE UPDATE ON orders.decisoes_lentes
    FOR EACH ROW EXECUTE FUNCTION orders.registrar_mudanca_status();

-- Trigger para marcar apenas uma alternativa como recomendada
CREATE OR REPLACE FUNCTION orders.validar_alternativa_recomendada()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.recomendada = true THEN
        -- Desmarca outras recomendadas da mesma decisão
        UPDATE orders.alternativas_cotacao 
        SET recomendada = false 
        WHERE decisao_id = NEW.decisao_id 
          AND id != COALESCE(NEW.id, uuid_nil())
          AND recomendada = true;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_validar_alternativa_recomendada
    BEFORE INSERT OR UPDATE ON orders.alternativas_cotacao
    FOR EACH ROW EXECUTE FUNCTION orders.validar_alternativa_recomendada();

-- ============================================
-- FUNÇÕES PRINCIPAIS
-- ============================================

-- Função para calcular adequação de uma lente à receita
CREATE OR REPLACE FUNCTION orders.calcular_adequacao_receita(
    p_lente_id UUID,
    p_receita JSONB
)
RETURNS NUMERIC AS $$
DECLARE
    v_lente RECORD;
    v_adequacao NUMERIC := 0;
    v_esferico NUMERIC;
    v_cilindrico NUMERIC;
    v_adicao NUMERIC;
BEGIN
    -- Busca dados da lente
    SELECT * INTO v_lente
    FROM lens_catalog.lentes
    WHERE id = p_lente_id;
    
    IF NOT FOUND THEN
        RETURN 0;
    END IF;
    
    -- Extrai valores da receita
    v_esferico := COALESCE((p_receita->>'esferico_od')::NUMERIC, 0);
    v_cilindrico := COALESCE(ABS((p_receita->>'cilindrico_od')::NUMERIC), 0);
    v_adicao := COALESCE((p_receita->>'adicao')::NUMERIC, 0);
    
    -- Verifica compatibilidade com graus
    IF v_esferico BETWEEN 
        COALESCE((v_lente.specs_tecnicas->>'esferico_min')::NUMERIC, -20) AND 
        COALESCE((v_lente.specs_tecnicas->>'esferico_max')::NUMERIC, 20) THEN
        v_adequacao := v_adequacao + 40;
    END IF;
    
    IF v_cilindrico BETWEEN 
        COALESCE((v_lente.specs_tecnicas->>'cilindrico_min')::NUMERIC, 0) AND 
        COALESCE((v_lente.specs_tecnicas->>'cilindrico_max')::NUMERIC, 6) THEN
        v_adequacao := v_adequacao + 30;
    END IF;
    
    -- Se é progressiva, verifica adição
    IF v_lente.tipo_lente = 'PROGRESSIVA' AND v_adicao > 0 THEN
        IF v_adicao BETWEEN 
            COALESCE((v_lente.specs_tecnicas->>'adicao_min')::NUMERIC, 0.75) AND 
            COALESCE((v_lente.specs_tecnicas->>'adicao_max')::NUMERIC, 3.5) THEN
            v_adequacao := v_adequacao + 20;
        END IF;
    ELSIF v_lente.tipo_lente != 'PROGRESSIVA' AND v_adicao = 0 THEN
        v_adequacao := v_adequacao + 20;
    END IF;
    
    -- Pontuação adicional por características especiais
    IF (p_receita->>'uso_computador')::BOOLEAN = true AND 'BLUE' = ANY(v_lente.tratamentos) THEN
        v_adequacao := v_adequacao + 5;
    END IF;
    
    -- Proteção UV geralmente está incluída em lentes PHOTOCHROMIC
    -- IF (p_receita->>'uso_externo')::BOOLEAN = true AND 'PHOTOCHROMIC' = ANY(v_lente.tratamentos) THEN
    --     v_adequacao := v_adequacao + 5;
    -- END IF;
    
    RETURN LEAST(100, v_adequacao);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para processar decisão de lente
CREATE OR REPLACE FUNCTION orders.processar_decisao_lente(
    p_tenant_id UUID,
    p_receita JSONB,
    p_especificacoes JSONB,
    p_prioridades JSONB DEFAULT '{"preco": 1.0, "qualidade": 1.0, "prazo": 1.0}',
    p_regiao_entrega TEXT DEFAULT 'SUDESTE',
    p_limite_resultados INTEGER DEFAULT 5
)
RETURNS TABLE (
    result_lente_id UUID,
    result_laboratorio_id UUID,
    result_nome_lente TEXT,
    result_nome_laboratorio TEXT,
    result_adequacao_receita NUMERIC,
    result_preco_final NUMERIC,
    result_prazo_medio INTEGER,
    result_score_geral NUMERIC,
    result_score_ponderado NUMERIC,
    result_posicao_ranking INTEGER
) AS $$
DECLARE
    v_peso_preco NUMERIC := COALESCE((p_prioridades->>'preco')::NUMERIC, 1.0);
    v_peso_qualidade NUMERIC := COALESCE((p_prioridades->>'qualidade')::NUMERIC, 1.0);
    v_peso_prazo NUMERIC := COALESCE((p_prioridades->>'prazo')::NUMERIC, 1.0);
BEGIN
    RETURN QUERY
    WITH candidatos AS (
        SELECT 
            l.id as lente_id,
            lab.id as laboratorio_id,
            CONCAT(l.familia, ' ', l.design) as nome_lente,
            lab.nome_fantasia as nome_laboratorio,
            orders.calcular_adequacao_receita(l.id, p_receita) as adequacao,
            
            -- Busca preço
            COALESCE(
                (SELECT pb.preco_tabela 
                 FROM commercial.precos_base pb 
                 JOIN suppliers.produtos_laboratorio pl2 ON pl2.id = pb.produto_lab_id
                 WHERE pl2.lente_id = l.id 
                   AND pl2.laboratorio_id = lab.id 
                   AND pb.ativo = true
                   AND (pb.vigencia_fim IS NULL OR pb.vigencia_fim >= CURRENT_DATE)
                 ORDER BY pb.vigencia_inicio DESC 
                 LIMIT 1), 
                500.00
            ) as preco,
            
            -- Busca prazo
            COALESCE(
                (SELECT lp.prazo_medio 
                 FROM logistics.buscar_prazo_frete(lab.id, p_regiao_entrega) lp), 
                7
            ) as prazo,
            
            -- Busca score do laboratório
            COALESCE(
                (SELECT sl.score_geral 
                 FROM scoring.scores_laboratorios sl 
                 WHERE sl.laboratorio_id = lab.id 
                   AND sl.valido_ate >= CURRENT_DATE 
                 ORDER BY sl.data_calculo DESC 
                 LIMIT 1), 
                5.0
            ) as score_lab
            
        FROM lens_catalog.lentes l
        JOIN suppliers.produtos_laboratorio pl ON pl.lente_id = l.id
        JOIN suppliers.laboratorios lab ON lab.id = pl.laboratorio_id
        WHERE l.ativo = true 
          AND lab.ativo = true
          AND pl.disponivel = true
          AND l.tenant_id = p_tenant_id
          AND lab.tenant_id = p_tenant_id
    ),
    pontuados AS (
        SELECT 
            *,
            -- Normaliza scores (0-10)
            adequacao / 10.0 as score_adequacao,
            GREATEST(0, 10 - (preco - 100) / 100.0) as score_preco_norm,
            GREATEST(0, 10 - prazo / 2.0) as score_prazo_norm,
            score_lab as score_qualidade_norm
        FROM candidatos
        WHERE adequacao >= 60  -- Só considera lentes com adequação mínima
    ),
    finais AS (
        SELECT 
            lente_id,
            laboratorio_id,
            nome_lente,
            nome_laboratorio,
            adequacao,
            preco as preco_final,
            prazo as prazo_medio,
            score_lab as score_geral,
            
            -- Score ponderado final
            ROUND(
                (score_adequacao * 2.0 +  -- Adequação sempre tem peso alto
                 score_qualidade_norm * v_peso_qualidade +
                 score_preco_norm * v_peso_preco +
                 score_prazo_norm * v_peso_prazo) /
                (2.0 + v_peso_qualidade + v_peso_preco + v_peso_prazo),
                2
            ) as score_ponderado
        FROM pontuados
    )
    SELECT 
        f.lente_id as result_lente_id,
        f.laboratorio_id as result_laboratorio_id,
        f.nome_lente as result_nome_lente,
        f.nome_laboratorio as result_nome_laboratorio,
        f.adequacao as result_adequacao_receita,
        f.preco_final as result_preco_final,
        f.prazo_medio as result_prazo_medio,
        f.score_geral as result_score_geral,
        f.score_ponderado as result_score_ponderado,
        ROW_NUMBER() OVER (ORDER BY f.score_ponderado DESC, f.adequacao DESC)::INTEGER as result_posicao_ranking
    FROM finais f
    ORDER BY f.score_ponderado DESC, f.adequacao DESC
    LIMIT p_limite_resultados;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- VIEWS AUXILIARES
-- ============================================

-- View para decisões com dados resumidos
CREATE OR REPLACE VIEW orders.vw_decisoes_resumo AS
SELECT 
    d.id,
    d.codigo_decisao,
    d.cliente_nome,
    d.nome_otica,
    d.tipo_receita,
    d.uso_principal,
    d.status,
    d.prioridade,
    d.preco_final,
    d.prazo_entrega_prometido,
    CONCAT(l.familia, ' ', l.design) as lente_nome,
    lab.nome_fantasia as laboratorio_nome,
    d.criado_em,
    d.atualizado_em,
    CASE d.status
        WHEN 'COTACAO' THEN '📋 Em Cotação'
        WHEN 'APROVADA' THEN '✅ Aprovada'
        WHEN 'PRODUCAO' THEN '⚙️ Em Produção'
        WHEN 'PRONTA' THEN '📦 Pronta'
        WHEN 'ENTREGUE' THEN '🚚 Entregue'
        WHEN 'CANCELADA' THEN '❌ Cancelada'
    END as status_display,
    CASE d.prioridade
        WHEN 'URGENTE' THEN '🔴'
        WHEN 'ALTA' THEN '🟠'
        WHEN 'NORMAL' THEN '🟢'
        WHEN 'BAIXA' THEN '⚪'
    END as prioridade_display
FROM orders.decisoes_lentes d
LEFT JOIN lens_catalog.lentes l ON l.id = d.lente_recomendada_id
LEFT JOIN suppliers.laboratorios lab ON lab.id = d.laboratorio_escolhido_id;

-- View para alternativas com dados completos
CREATE OR REPLACE VIEW orders.vw_alternativas_completas AS
SELECT 
    a.*,
    CONCAT(l.familia, ' ', l.design) as lente_nome,
    m.nome as lente_marca,
    l.tipo_lente,
    l.material,
    lab.nome_fantasia as laboratorio_nome,
    d.codigo_decisao,
    d.cliente_nome,
    CASE a.tipo_alternativa
        WHEN 'RECOMENDACAO' THEN '⭐ Recomendada'
        WHEN 'ALTERNATIVA' THEN '🔄 Alternativa'
        WHEN 'ECONOMICA' THEN '💰 Econômica'
        WHEN 'PREMIUM' THEN '💎 Premium'
        WHEN 'SEGUNDA_OPCAO' THEN '🥈 2ª Opção'
    END as tipo_display
FROM orders.alternativas_cotacao a
JOIN orders.decisoes_lentes d ON d.id = a.decisao_id
JOIN lens_catalog.lentes l ON l.id = a.lente_id
JOIN lens_catalog.marcas m ON m.id = l.marca_id
JOIN suppliers.laboratorios lab ON lab.id = a.laboratorio_id
WHERE a.ativa = true;

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE orders.decisoes_lentes IS 'Decisões/cotações de lentes para clientes';
COMMENT ON COLUMN orders.decisoes_lentes.receita IS 'Receita médica em JSON: {esferico_od, cilindrico_od, eixo_od, esferico_oe, cilindrico_oe, eixo_oe, adicao, dp}';
COMMENT ON COLUMN orders.decisoes_lentes.especificacoes IS 'Especificações técnicas: {material, tratamentos, formato_armacao}';
COMMENT ON COLUMN orders.decisoes_lentes.prioridades IS 'Pesos para decisão: {preco: 1.0, qualidade: 1.0, prazo: 1.0}';

COMMENT ON TABLE orders.alternativas_cotacao IS 'Alternativas de lentes cotadas para cada decisão';
COMMENT ON COLUMN orders.alternativas_cotacao.compatibilidade_receita IS 'Detalhes de compatibilidade: {adequacao_esferico, adequacao_cilindrico, limitacoes}';

COMMENT ON TABLE orders.criterios_decisao IS 'Critérios configuráveis para algoritmo de decisão';
COMMENT ON FUNCTION orders.calcular_adequacao_receita IS 'Calcula percentual de adequação de uma lente à receita (0-100)';
COMMENT ON FUNCTION orders.processar_decisao_lente IS 'Motor principal de decisão - retorna melhores opções rankeadas';

-- ============================================
-- DADOS INICIAIS
-- ============================================

DO $$
DECLARE
    v_tenant_id UUID;
    v_decisao_id UUID;
    v_lente_id UUID;
    v_lab_id UUID;
BEGIN
    -- Pega referências
    SELECT id INTO v_tenant_id FROM meta_system.tenants WHERE slug = 'demo';
    
    -- Critérios de decisão
    INSERT INTO orders.criterios_decisao (tenant_id, nome, descricao, categoria, peso_padrao, tipo_criterio) VALUES 
    (v_tenant_id, 'Adequação à Receita', 'Compatibilidade técnica com a receita médica', 'TECNICO', 3.0, 'ADEQUACAO_RECEITA'),
    (v_tenant_id, 'Competitividade de Preço', 'Avaliação do preço vs. mercado', 'COMERCIAL', 1.5, 'PRECO'),
    (v_tenant_id, 'Prazo de Entrega', 'Rapidez na entrega', 'LOGISTICO', 1.2, 'PRAZO'),
    (v_tenant_id, 'Qualidade do Laboratório', 'Score de qualificação do laboratório', 'QUALIDADE', 2.0, 'SCORE_LABORATORIO'),
    (v_tenant_id, 'Disponibilidade', 'Disponibilidade em estoque', 'LOGISTICO', 1.0, 'DISPONIBILIDADE');
    
    -- Decisão de exemplo
    INSERT INTO orders.decisoes_lentes (
        tenant_id, nome_otica, vendedor_nome, cliente_nome, cliente_idade,
        receita, tipo_receita, especificacoes, uso_principal,
        prioridades, status, observacoes
    ) VALUES (
        v_tenant_id, 'Ótica Vision Center', 'João Silva', 'Maria Santos', 45,
        '{
            "esferico_od": -2.5,
            "cilindrico_od": -1.0,
            "eixo_od": 180,
            "esferico_oe": -2.25,
            "cilindrico_oe": -0.75,
            "eixo_oe": 175,
            "adicao": 1.5,
            "dp": 62,
            "uso_computador": true,
            "uso_externo": true
        }'::jsonb,
        'PROGRESSIVA',
        '{
            "material_preferido": "POLICARBONATO",
            "tratamentos": ["AR", "BLUE"],
            "formato_armacao": "OVALADO"
        }'::jsonb,
        'PROFISSIONAL',
        '{"preco": 1.0, "qualidade": 1.5, "prazo": 0.8}'::jsonb,
        'COTACAO',
        'Cliente trabalha muito no computador, precisa de lente progressiva com filtro azul'
    ) RETURNING id INTO v_decisao_id;
    
    -- Gera alternativas usando o motor de decisão
    INSERT INTO orders.alternativas_cotacao (
        decisao_id, tenant_id, posicao, tipo_alternativa, lente_id, laboratorio_id,
        percentual_adequacao, preco_base, preco_final, prazo_minimo, prazo_maximo,
        score_geral, recomendada, pontos_fortes, observacoes
    )
    SELECT 
        v_decisao_id,
        v_tenant_id,
        resultado.result_posicao_ranking,
        CASE 
            WHEN resultado.result_posicao_ranking = 1 THEN 'RECOMENDACAO'
            WHEN resultado.result_posicao_ranking <= 3 THEN 'ALTERNATIVA'
            ELSE 'SEGUNDA_OPCAO'
        END,
        resultado.result_lente_id,
        resultado.result_laboratorio_id,
        resultado.result_adequacao_receita,
        resultado.result_preco_final * 0.9, -- Preço base (sem desconto)
        resultado.result_preco_final,
        GREATEST(1, resultado.result_prazo_medio - 1),
        resultado.result_prazo_medio + 1,
        resultado.result_score_geral,
        resultado.result_posicao_ranking = 1, -- Primeira é recomendada
        CASE 
            WHEN resultado.result_posicao_ranking = 1 THEN ARRAY['Melhor adequação técnica', 'Laboratório qualificado', 'Bom custo-benefício']
            WHEN resultado.result_score_geral >= 8 THEN ARRAY['Alta qualidade', 'Laboratório confiável']
            WHEN resultado.result_preco_final < 400 THEN ARRAY['Preço atrativo', 'Boa opção econômica']
            ELSE ARRAY['Opção viável', 'Atende especificações']
        END,
        'Alternativa gerada automaticamente pelo sistema'
    FROM orders.processar_decisao_lente(
        v_tenant_id,
        '{
            "esferico_od": -2.5,
            "cilindrico_od": -1.0,
            "eixo_od": 180,
            "esferico_oe": -2.25,
            "cilindrico_oe": -0.75,
            "eixo_oe": 175,
            "adicao": 1.5,
            "dp": 62,
            "uso_computador": true,
            "uso_externo": true
        }'::jsonb,
        '{
            "material_preferido": "POLICARBONATO",
            "tratamentos": ["AR", "BLUE"],
            "formato_armacao": "OVALADO"
        }'::jsonb,
        '{"preco": 1.0, "qualidade": 1.5, "prazo": 0.8}'::jsonb
    ) resultado;
    
    -- Atualiza a decisão com a recomendação principal
    SELECT lente_id, laboratorio_id INTO v_lente_id, v_lab_id
    FROM orders.alternativas_cotacao 
    WHERE decisao_id = v_decisao_id AND recomendada = true;
    
    UPDATE orders.decisoes_lentes 
    SET 
        lente_recomendada_id = v_lente_id,
        laboratorio_escolhido_id = v_lab_id,
        justificativa_tecnica = 'Recomendação automática baseada em adequação técnica e scores de qualidade',
        preco_final = (SELECT preco_final FROM orders.alternativas_cotacao WHERE decisao_id = v_decisao_id AND recomendada = true),
        prazo_entrega_prometido = (SELECT prazo_maximo FROM orders.alternativas_cotacao WHERE decisao_id = v_decisao_id AND recomendada = true)
    WHERE id = v_decisao_id;
    
END $$;