-- Migration: 007_scoring.sql
-- Schema scoring: Sistema de scoring/pontuação para qualificação de laboratórios e produtos

-- ============================================
-- TABELA: criterios_scoring
-- ============================================
CREATE TABLE scoring.criterios_scoring (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    descricao TEXT,
    categoria TEXT NOT NULL,
    peso NUMERIC(3,2) NOT NULL DEFAULT 1.0,
    peso_personalizado JSONB DEFAULT '{}',
    tipo_calculo TEXT NOT NULL DEFAULT 'MEDIA_PONDERADA',
    formula_customizada TEXT,
    min_valor NUMERIC(5,2) DEFAULT 0,
    max_valor NUMERIC(5,2) DEFAULT 10,
    unidade TEXT DEFAULT 'pontos',
    ativo BOOLEAN NOT NULL DEFAULT true,
    ordem_exibicao INTEGER DEFAULT 1,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, nome),
    CHECK (peso >= 0 AND peso <= 5.0),
    CHECK (min_valor < max_valor),
    CHECK (categoria IN ('QUALIDADE', 'PRECO', 'PRAZO', 'SERVICO', 'FINANCEIRO', 'TECNICO')),
    CHECK (tipo_calculo IN ('MEDIA_PONDERADA', 'SOMA', 'MAXIMO', 'MINIMO', 'CUSTOMIZADO')),
    CHECK (ordem_exibicao > 0)
);

-- Índices
CREATE INDEX idx_criterios_tenant ON scoring.criterios_scoring(tenant_id);
CREATE INDEX idx_criterios_categoria ON scoring.criterios_scoring(categoria);
CREATE INDEX idx_criterios_ativo ON scoring.criterios_scoring(ativo);
CREATE INDEX idx_criterios_ordem ON scoring.criterios_scoring(ordem_exibicao);

-- ============================================
-- TABELA: avaliacoes_laboratorios
-- ============================================
CREATE TABLE scoring.avaliacoes_laboratorios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    laboratorio_id UUID NOT NULL REFERENCES suppliers.laboratorios(id) ON DELETE CASCADE,
    criterio_id UUID NOT NULL REFERENCES scoring.criterios_scoring(id) ON DELETE CASCADE,
    valor NUMERIC(7,2) NOT NULL,
    valor_normalizado NUMERIC(3,2),
    justificativa TEXT,
    fonte_dados TEXT,
    metodo_calculo TEXT,
    data_referencia DATE NOT NULL DEFAULT CURRENT_DATE,
    periodo_validade INTEGER DEFAULT 90,
    automatico BOOLEAN NOT NULL DEFAULT false,
    revisado_por UUID,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, laboratorio_id, criterio_id, data_referencia),
    CHECK (periodo_validade > 0 AND periodo_validade <= 365),
    CHECK (valor_normalizado IS NULL OR (valor_normalizado >= 0 AND valor_normalizado <= 10)),
    CHECK (fonte_dados IN ('MANUAL', 'HISTORICO_ENTREGAS', 'HISTORICO_PRECOS', 'AVALIACAO_CLIENTE', 'SISTEMA_EXTERNO', 'CALCULO_AUTOMATICO'))
);

-- Índices
CREATE INDEX idx_avaliacoes_tenant ON scoring.avaliacoes_laboratorios(tenant_id);
CREATE INDEX idx_avaliacoes_laboratorio ON scoring.avaliacoes_laboratorios(laboratorio_id);
CREATE INDEX idx_avaliacoes_criterio ON scoring.avaliacoes_laboratorios(criterio_id);
CREATE INDEX idx_avaliacoes_data ON scoring.avaliacoes_laboratorios(data_referencia);
CREATE INDEX idx_avaliacoes_validade ON scoring.avaliacoes_laboratorios(data_referencia, periodo_validade);
CREATE INDEX idx_avaliacoes_automatico ON scoring.avaliacoes_laboratorios(automatico);

-- ============================================
-- TABELA: scores_laboratorios
-- ============================================
CREATE TABLE scoring.scores_laboratorios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    laboratorio_id UUID NOT NULL REFERENCES suppliers.laboratorios(id) ON DELETE CASCADE,
    score_geral NUMERIC(5,2) NOT NULL,
    score_qualidade NUMERIC(5,2),
    score_preco NUMERIC(5,2),
    score_prazo NUMERIC(5,2),
    score_servico NUMERIC(5,2),
    score_financeiro NUMERIC(5,2),
    score_tecnico NUMERIC(5,2),
    ranking_geral INTEGER,
    ranking_categoria JSONB DEFAULT '{}',
    nivel_qualificacao TEXT NOT NULL,
    observacoes TEXT,
    data_calculo DATE NOT NULL DEFAULT CURRENT_DATE,
    valido_ate DATE NOT NULL,
    recalcular_em DATE,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, laboratorio_id, data_calculo),
    CHECK (score_geral >= 0 AND score_geral <= 10),
    CHECK (score_qualidade IS NULL OR (score_qualidade >= 0 AND score_qualidade <= 10)),
    CHECK (score_preco IS NULL OR (score_preco >= 0 AND score_preco <= 10)),
    CHECK (score_prazo IS NULL OR (score_prazo >= 0 AND score_prazo <= 10)),
    CHECK (score_servico IS NULL OR (score_servico >= 0 AND score_servico <= 10)),
    CHECK (score_financeiro IS NULL OR (score_financeiro >= 0 AND score_financeiro <= 10)),
    CHECK (score_tecnico IS NULL OR (score_tecnico >= 0 AND score_tecnico <= 10)),
    CHECK (ranking_geral IS NULL OR ranking_geral > 0),
    CHECK (nivel_qualificacao IN ('GOLD', 'SILVER', 'BRONZE', 'QUALIFICADO', 'NAO_QUALIFICADO')),
    CHECK (valido_ate > data_calculo)
);

-- Índices
CREATE INDEX idx_scores_tenant ON scoring.scores_laboratorios(tenant_id);
CREATE INDEX idx_scores_laboratorio ON scoring.scores_laboratorios(laboratorio_id);
CREATE INDEX idx_scores_geral ON scoring.scores_laboratorios(score_geral DESC);
CREATE INDEX idx_scores_ranking ON scoring.scores_laboratorios(ranking_geral);
CREATE INDEX idx_scores_nivel ON scoring.scores_laboratorios(nivel_qualificacao);
CREATE INDEX idx_scores_data ON scoring.scores_laboratorios(data_calculo);
CREATE INDEX idx_scores_validade ON scoring.scores_laboratorios(valido_ate);

-- ============================================
-- TABELA: historico_scores
-- ============================================
CREATE TABLE scoring.historico_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    laboratorio_id UUID NOT NULL REFERENCES suppliers.laboratorios(id) ON DELETE CASCADE,
    score_anterior NUMERIC(5,2),
    score_novo NUMERIC(5,2) NOT NULL,
    variacao NUMERIC(6,2) GENERATED ALWAYS AS (score_novo - COALESCE(score_anterior, score_novo)) STORED,
    ranking_anterior INTEGER,
    ranking_novo INTEGER,
    motivo_alteracao TEXT,
    criterios_alterados JSONB DEFAULT '[]',
    data_alteracao TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CHECK (score_anterior IS NULL OR (score_anterior >= 0 AND score_anterior <= 10)),
    CHECK (score_novo >= 0 AND score_novo <= 10),
    CHECK (ranking_anterior IS NULL OR ranking_anterior > 0),
    CHECK (ranking_novo IS NULL OR ranking_novo > 0)
);

-- Índices
CREATE INDEX idx_historico_tenant ON scoring.historico_scores(tenant_id);
CREATE INDEX idx_historico_laboratorio ON scoring.historico_scores(laboratorio_id);
CREATE INDEX idx_historico_data ON scoring.historico_scores(data_alteracao);
CREATE INDEX idx_historico_variacao ON scoring.historico_scores(variacao);

-- ============================================
-- TRIGGERS
-- ============================================
CREATE TRIGGER tr_criterios_updated_at
    BEFORE UPDATE ON scoring.criterios_scoring
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

CREATE TRIGGER tr_avaliacoes_updated_at
    BEFORE UPDATE ON scoring.avaliacoes_laboratorios
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

-- Trigger para normalizar valores de avaliação
CREATE OR REPLACE FUNCTION scoring.normalizar_valor_avaliacao()
RETURNS TRIGGER AS $$
DECLARE
    v_criterio RECORD;
BEGIN
    -- Busca o critério para normalização
    SELECT min_valor, max_valor INTO v_criterio
    FROM scoring.criterios_scoring
    WHERE id = NEW.criterio_id;
    
    -- Normaliza o valor para escala 0-10
    IF v_criterio.min_valor != v_criterio.max_valor THEN
        NEW.valor_normalizado := ROUND(
            10.0 * (NEW.valor - v_criterio.min_valor) / (v_criterio.max_valor - v_criterio.min_valor),
            2
        );
    ELSE
        NEW.valor_normalizado := NEW.valor;
    END IF;
    
    -- Garante que está no range 0-10
    NEW.valor_normalizado := GREATEST(0, LEAST(10, NEW.valor_normalizado));
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_normalizar_avaliacao
    BEFORE INSERT OR UPDATE ON scoring.avaliacoes_laboratorios
    FOR EACH ROW EXECUTE FUNCTION scoring.normalizar_valor_avaliacao();

-- Trigger para manter histórico de mudanças de score
CREATE OR REPLACE FUNCTION scoring.registrar_mudanca_score()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.score_geral != NEW.score_geral THEN
        INSERT INTO scoring.historico_scores (
            tenant_id, laboratorio_id, score_anterior, score_novo,
            ranking_anterior, ranking_novo, motivo_alteracao
        ) VALUES (
            NEW.tenant_id, NEW.laboratorio_id, OLD.score_geral, NEW.score_geral,
            OLD.ranking_geral, NEW.ranking_geral, 'Recálculo automático'
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_historico_score
    AFTER UPDATE ON scoring.scores_laboratorios
    FOR EACH ROW EXECUTE FUNCTION scoring.registrar_mudanca_score();

-- ============================================
-- FUNÇÕES PRINCIPAIS
-- ============================================

-- Função para calcular score de um laboratório
CREATE OR REPLACE FUNCTION scoring.calcular_score_laboratorio(
    p_laboratorio_id UUID,
    p_data_referencia DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    score_geral NUMERIC,
    score_qualidade NUMERIC,
    score_preco NUMERIC,
    score_prazo NUMERIC,
    score_servico NUMERIC,
    score_financeiro NUMERIC,
    score_tecnico NUMERIC,
    nivel_qualificacao TEXT
) AS $$
DECLARE
    v_scores RECORD;
    v_tenant_id UUID;
BEGIN
    -- Busca tenant do laboratório
    SELECT tenant_id INTO v_tenant_id 
    FROM suppliers.laboratorios 
    WHERE id = p_laboratorio_id;
    
    -- Calcula scores por categoria
    WITH scores_categoria AS (
        SELECT 
            c.categoria,
            ROUND(
                SUM(a.valor_normalizado * c.peso) / NULLIF(SUM(c.peso), 0), 
                2
            ) as score_categoria
        FROM scoring.criterios_scoring c
        JOIN scoring.avaliacoes_laboratorios a ON a.criterio_id = c.id
        WHERE a.laboratorio_id = p_laboratorio_id
          AND a.tenant_id = v_tenant_id
          AND c.ativo = true
          AND a.data_referencia <= p_data_referencia
          AND (p_data_referencia - a.data_referencia) <= a.periodo_validade
        GROUP BY c.categoria
    ),
    score_geral_calc AS (
        SELECT 
            ROUND(AVG(score_categoria), 2) as score_final
        FROM scores_categoria
    )
    SELECT 
        sg.score_final,
        COALESCE(sc_qual.score_categoria, 0) as qualidade,
        COALESCE(sc_preco.score_categoria, 0) as preco,
        COALESCE(sc_prazo.score_categoria, 0) as prazo,
        COALESCE(sc_servico.score_categoria, 0) as servico,
        COALESCE(sc_financeiro.score_categoria, 0) as financeiro,
        COALESCE(sc_tecnico.score_categoria, 0) as tecnico,
        CASE 
            WHEN sg.score_final >= 9.0 THEN 'GOLD'
            WHEN sg.score_final >= 7.5 THEN 'SILVER'
            WHEN sg.score_final >= 6.0 THEN 'BRONZE'
            WHEN sg.score_final >= 4.0 THEN 'QUALIFICADO'
            ELSE 'NAO_QUALIFICADO'
        END as nivel
    INTO v_scores
    FROM score_geral_calc sg
    LEFT JOIN scores_categoria sc_qual ON sc_qual.categoria = 'QUALIDADE'
    LEFT JOIN scores_categoria sc_preco ON sc_preco.categoria = 'PRECO'
    LEFT JOIN scores_categoria sc_prazo ON sc_prazo.categoria = 'PRAZO'
    LEFT JOIN scores_categoria sc_servico ON sc_servico.categoria = 'SERVICO'
    LEFT JOIN scores_categoria sc_financeiro ON sc_financeiro.categoria = 'FINANCEIRO'
    LEFT JOIN scores_categoria sc_tecnico ON sc_tecnico.categoria = 'TECNICO';
    
    RETURN QUERY SELECT 
        COALESCE(v_scores.score_final, 0),
        v_scores.qualidade,
        v_scores.preco,
        v_scores.prazo,
        v_scores.servico,
        v_scores.financeiro,
        v_scores.tecnico,
        COALESCE(v_scores.nivel, 'NAO_QUALIFICADO');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para atualizar scores de todos os laboratórios
CREATE OR REPLACE FUNCTION scoring.atualizar_scores_todos_laboratorios(
    p_tenant_id UUID,
    p_data_referencia DATE DEFAULT CURRENT_DATE
)
RETURNS INTEGER AS $$
DECLARE
    v_lab RECORD;
    v_score RECORD;
    v_ranking INTEGER := 1;
    v_contador INTEGER := 0;
BEGIN
    -- Para cada laboratório ativo
    FOR v_lab IN 
        SELECT id 
        FROM suppliers.laboratorios 
        WHERE tenant_id = p_tenant_id 
          AND ativo = true
    LOOP
        -- Calcula o score
        SELECT * INTO v_score
        FROM scoring.calcular_score_laboratorio(v_lab.id, p_data_referencia);
        
        -- Insere ou atualiza o score
        INSERT INTO scoring.scores_laboratorios (
            tenant_id, laboratorio_id, score_geral, score_qualidade, score_preco,
            score_prazo, score_servico, score_financeiro, score_tecnico,
            nivel_qualificacao, data_calculo, valido_ate, recalcular_em
        ) VALUES (
            p_tenant_id, v_lab.id, v_score.score_geral, v_score.score_qualidade,
            v_score.score_preco, v_score.score_prazo, v_score.score_servico,
            v_score.score_financeiro, v_score.score_tecnico, v_score.nivel_qualificacao,
            p_data_referencia, p_data_referencia + INTERVAL '30 days',
            p_data_referencia + INTERVAL '7 days'
        )
        ON CONFLICT (tenant_id, laboratorio_id, data_calculo)
        DO UPDATE SET
            score_geral = EXCLUDED.score_geral,
            score_qualidade = EXCLUDED.score_qualidade,
            score_preco = EXCLUDED.score_preco,
            score_prazo = EXCLUDED.score_prazo,
            score_servico = EXCLUDED.score_servico,
            score_financeiro = EXCLUDED.score_financeiro,
            score_tecnico = EXCLUDED.score_tecnico,
            nivel_qualificacao = EXCLUDED.nivel_qualificacao,
            valido_ate = EXCLUDED.valido_ate,
            recalcular_em = EXCLUDED.recalcular_em;
        
        v_contador := v_contador + 1;
    END LOOP;
    
    -- Atualiza rankings
    UPDATE scoring.scores_laboratorios 
    SET ranking_geral = sub.ranking
    FROM (
        SELECT 
            id,
            ROW_NUMBER() OVER (ORDER BY score_geral DESC, criado_em ASC) as ranking
        FROM scoring.scores_laboratorios
        WHERE tenant_id = p_tenant_id
          AND data_calculo = p_data_referencia
    ) sub
    WHERE scoring.scores_laboratorios.id = sub.id;
    
    RETURN v_contador;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para avaliar automaticamente baseado em métricas
CREATE OR REPLACE FUNCTION scoring.avaliar_metricas_automaticas(
    p_laboratorio_id UUID,
    p_data_referencia DATE DEFAULT CURRENT_DATE
)
RETURNS INTEGER AS $$
DECLARE
    v_tenant_id UUID;
    v_metricas_entrega RECORD;
    v_contador INTEGER := 0;
BEGIN
    -- Busca tenant
    SELECT tenant_id INTO v_tenant_id 
    FROM suppliers.laboratorios 
    WHERE id = p_laboratorio_id;
    
    -- Busca métricas de entrega
    SELECT * INTO v_metricas_entrega
    FROM logistics.calcular_metricas_entrega(p_laboratorio_id);
    
    IF v_metricas_entrega.total_entregas > 0 THEN
        -- Avalia critério de pontualidade
        INSERT INTO scoring.avaliacoes_laboratorios (
            tenant_id, laboratorio_id, criterio_id, valor, justificativa,
            fonte_dados, data_referencia, automatico
        )
        SELECT 
            v_tenant_id, p_laboratorio_id, c.id, v_metricas_entrega.percentual_no_prazo,
            FORMAT('Baseado em %s entregas dos últimos 90 dias', v_metricas_entrega.total_entregas),
            'HISTORICO_ENTREGAS', p_data_referencia, true
        FROM scoring.criterios_scoring c
        WHERE c.tenant_id = v_tenant_id
          AND c.nome = 'Pontualidade na Entrega'
          AND c.ativo = true
        ON CONFLICT (tenant_id, laboratorio_id, criterio_id, data_referencia)
        DO UPDATE SET
            valor = EXCLUDED.valor,
            justificativa = EXCLUDED.justificativa,
            atualizado_em = NOW();
        
        v_contador := v_contador + 1;
        
        -- Avalia critério de prazo médio
        INSERT INTO scoring.avaliacoes_laboratorios (
            tenant_id, laboratorio_id, criterio_id, valor, justificativa,
            fonte_dados, data_referencia, automatico
        )
        SELECT 
            v_tenant_id, p_laboratorio_id, c.id, 
            GREATEST(0, 10 - (v_metricas_entrega.prazo_medio_real - 1)), -- Score inverso ao prazo
            FORMAT('Prazo médio real: %.1f dias', v_metricas_entrega.prazo_medio_real),
            'HISTORICO_ENTREGAS', p_data_referencia, true
        FROM scoring.criterios_scoring c
        WHERE c.tenant_id = v_tenant_id
          AND c.nome = 'Velocidade de Entrega'
          AND c.ativo = true
        ON CONFLICT (tenant_id, laboratorio_id, criterio_id, data_referencia)
        DO UPDATE SET
            valor = EXCLUDED.valor,
            justificativa = EXCLUDED.justificativa,
            atualizado_em = NOW();
        
        v_contador := v_contador + 1;
    END IF;
    
    RETURN v_contador;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- VIEWS AUXILIARES
-- ============================================

-- View para ranking atual de laboratórios
CREATE OR REPLACE VIEW scoring.vw_ranking_laboratorios AS
SELECT 
    s.*,
    l.nome as laboratorio_nome,
    l.nome_fantasia as laboratorio_fantasia,
    CASE 
        WHEN s.ranking_geral <= 3 THEN '🥇 Top 3'
        WHEN s.ranking_geral <= 10 THEN '⭐ Top 10'
        WHEN s.nivel_qualificacao = 'GOLD' THEN '🔶 Gold'
        WHEN s.nivel_qualificacao = 'SILVER' THEN '🔷 Silver'
        WHEN s.nivel_qualificacao = 'BRONZE' THEN '🔸 Bronze'
        ELSE '⚪ Básico'
    END as badge_nivel
FROM scoring.scores_laboratorios s
JOIN suppliers.laboratorios l ON l.id = s.laboratorio_id
WHERE s.data_calculo = (
    SELECT MAX(data_calculo) 
    FROM scoring.scores_laboratorios s2 
    WHERE s2.laboratorio_id = s.laboratorio_id
      AND s2.tenant_id = s.tenant_id
)
AND s.valido_ate >= CURRENT_DATE
AND l.ativo = true
ORDER BY s.ranking_geral;

-- View para histórico de evolução de scores
CREATE OR REPLACE VIEW scoring.vw_evolucao_scores AS
SELECT 
    h.*,
    l.nome as laboratorio_nome,
    l.nome_fantasia as laboratorio_fantasia,
    CASE 
        WHEN h.variacao > 0.5 THEN '📈 Melhora significativa'
        WHEN h.variacao > 0 THEN '📊 Melhora'
        WHEN h.variacao = 0 THEN '➖ Estável'
        WHEN h.variacao > -0.5 THEN '📉 Piora'
        ELSE '⚠️ Piora significativa'
    END as status_evolucao
FROM scoring.historico_scores h
JOIN suppliers.laboratorios l ON l.id = h.laboratorio_id
ORDER BY h.data_alteracao DESC;

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE scoring.criterios_scoring IS 'Critérios de avaliação para scoring de laboratórios';
COMMENT ON COLUMN scoring.criterios_scoring.peso_personalizado IS 'JSON com pesos específicos por região/cliente: {"SP": 1.5, "RJ": 1.2}';
COMMENT ON COLUMN scoring.criterios_scoring.formula_customizada IS 'Fórmula SQL personalizada para cálculo complexo';

COMMENT ON TABLE scoring.avaliacoes_laboratorios IS 'Avaliações específicas de laboratórios por critério';
COMMENT ON COLUMN scoring.avaliacoes_laboratorios.valor_normalizado IS 'Valor na escala 0-10 calculado automaticamente';
COMMENT ON COLUMN scoring.avaliacoes_laboratorios.periodo_validade IS 'Dias de validade desta avaliação';

COMMENT ON TABLE scoring.scores_laboratorios IS 'Scores consolidados e rankings de laboratórios';
COMMENT ON COLUMN scoring.scores_laboratorios.ranking_categoria IS 'JSON com rankings por categoria: {"QUALIDADE": 1, "PRECO": 5}';

COMMENT ON TABLE scoring.historico_scores IS 'Histórico de mudanças nos scores para auditoria';

-- ============================================
-- DADOS INICIAIS
-- ============================================

DO $$
DECLARE
    v_tenant_id UUID;
    v_criterio_id UUID;
    v_lab_premium_id UUID;
    v_lab_visao_id UUID;
    v_lab_express_id UUID;
BEGIN
    -- Pega referências
    SELECT id INTO v_tenant_id FROM meta_system.tenants WHERE slug = 'demo';
    SELECT id INTO v_lab_premium_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Premium Ótica';
    SELECT id INTO v_lab_visao_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Visão Clara';
    SELECT id INTO v_lab_express_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Express';
    
    -- Critérios de scoring
    INSERT INTO scoring.criterios_scoring (tenant_id, nome, descricao, categoria, peso, min_valor, max_valor, ordem_exibicao) VALUES 
    (v_tenant_id, 'Qualidade dos Produtos', 'Avaliação da qualidade técnica das lentes', 'QUALIDADE', 2.0, 0, 10, 1),
    (v_tenant_id, 'Pontualidade na Entrega', 'Percentual de entregas no prazo prometido', 'PRAZO', 1.8, 0, 100, 2),
    (v_tenant_id, 'Velocidade de Entrega', 'Rapidez média de entrega', 'PRAZO', 1.5, 0, 10, 3),
    (v_tenant_id, 'Competitividade de Preços', 'Posicionamento de preços vs mercado', 'PRECO', 1.7, 0, 10, 4),
    (v_tenant_id, 'Atendimento ao Cliente', 'Qualidade do suporte e atendimento', 'SERVICO', 1.3, 0, 10, 5),
    (v_tenant_id, 'Variedade de Produtos', 'Amplitude do catálogo de produtos', 'TECNICO', 1.2, 0, 10, 6),
    (v_tenant_id, 'Estabilidade Financeira', 'Solidez financeira do laboratório', 'FINANCEIRO', 1.4, 0, 10, 7),
    (v_tenant_id, 'Inovação Tecnológica', 'Investimento em novas tecnologias', 'TECNICO', 1.1, 0, 10, 8);
    
    -- Avaliações manuais (simuladas)
    
    -- Lab Premium (scores altos)
    INSERT INTO scoring.avaliacoes_laboratorios (tenant_id, laboratorio_id, criterio_id, valor, justificativa, fonte_dados) 
    SELECT v_tenant_id, v_lab_premium_id, id, 
        CASE nome
            WHEN 'Qualidade dos Produtos' THEN 9.2
            WHEN 'Competitividade de Preços' THEN 6.5  -- Mais caro
            WHEN 'Atendimento ao Cliente' THEN 9.0
            WHEN 'Variedade de Produtos' THEN 8.8
            WHEN 'Estabilidade Financeira' THEN 9.5
            WHEN 'Inovação Tecnológica' THEN 8.5
        END as valor,
        'Avaliação baseada em histórico de 12 meses',
        'MANUAL'
    FROM scoring.criterios_scoring 
    WHERE tenant_id = v_tenant_id 
      AND nome NOT IN ('Pontualidade na Entrega', 'Velocidade de Entrega');
    
    -- Lab Visão Clara (scores médios)
    INSERT INTO scoring.avaliacoes_laboratorios (tenant_id, laboratorio_id, criterio_id, valor, justificativa, fonte_dados) 
    SELECT v_tenant_id, v_lab_visao_id, id, 
        CASE nome
            WHEN 'Qualidade dos Produtos' THEN 7.8
            WHEN 'Competitividade de Preços' THEN 8.2  -- Bom custo-benefício
            WHEN 'Atendimento ao Cliente' THEN 7.5
            WHEN 'Variedade de Produtos' THEN 7.0
            WHEN 'Estabilidade Financeira' THEN 8.0
            WHEN 'Inovação Tecnológica' THEN 6.5
        END as valor,
        'Avaliação baseada em histórico de 12 meses',
        'MANUAL'
    FROM scoring.criterios_scoring 
    WHERE tenant_id = v_tenant_id 
      AND nome NOT IN ('Pontualidade na Entrega', 'Velocidade de Entrega');
    
    -- Lab Express (scores variados)
    INSERT INTO scoring.avaliacoes_laboratorios (tenant_id, laboratorio_id, criterio_id, valor, justificativa, fonte_dados) 
    SELECT v_tenant_id, v_lab_express_id, id, 
        CASE nome
            WHEN 'Qualidade dos Produtos' THEN 6.5
            WHEN 'Competitividade de Preços' THEN 9.0  -- Mais barato
            WHEN 'Atendimento ao Cliente' THEN 6.0
            WHEN 'Variedade de Produtos' THEN 5.5
            WHEN 'Estabilidade Financeira' THEN 7.0
            WHEN 'Inovação Tecnológica' THEN 4.0
        END as valor,
        'Avaliação baseada em histórico de 12 meses',
        'MANUAL'
    FROM scoring.criterios_scoring 
    WHERE tenant_id = v_tenant_id 
      AND nome NOT IN ('Pontualidade na Entrega', 'Velocidade de Entrega');
    
    -- Gera avaliações automáticas de métricas de entrega
    PERFORM scoring.avaliar_metricas_automaticas(v_lab_premium_id);
    PERFORM scoring.avaliar_metricas_automaticas(v_lab_visao_id);
    PERFORM scoring.avaliar_metricas_automaticas(v_lab_express_id);
    
    -- Calcula scores iniciais
    PERFORM scoring.atualizar_scores_todos_laboratorios(v_tenant_id);
    
END $$;