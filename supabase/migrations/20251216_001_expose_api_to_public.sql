-- ============================================
-- MIGRAÇÃO: Expor API e Dados Completos no PUBLIC
-- Data: 2025-12-16
-- Descrição: Cria wrappers e views enriquecidas no schema public para permitir
--            que o frontend acesse toda funcionalidade necessária
-- ============================================
-- BASEADO NA INVESTIGAÇÃO: docs/database/investigation/05_veredito_gaps_public.md
-- 
-- GAPS IDENTIFICADOS E RESOLVIDOS:
-- 1. ✅ Write Gap - Wrapper para api.criar_decisao_lente
-- 2. ✅ Data Gap - Views enriquecidas com badges, scores, prazos
-- 3. ✅ Dashboard Gap - Funções de KPIs expostas

BEGIN;

-- ============================================
-- VERIFICAÇÕES PRÉVIAS
-- ============================================

-- Verificar se schemas necessários existem
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'suppliers') THEN
        RAISE EXCEPTION 'Schema suppliers não existe. Execute primeiro as migrations de estrutura básica.';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'scoring') THEN
        RAISE EXCEPTION 'Schema scoring não existe. Execute primeiro as migrations de estrutura básica.';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'api') THEN
        RAISE EXCEPTION 'Schema api não existe. Execute primeiro as migrations de estrutura básica.';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'orders') THEN
        RAISE EXCEPTION 'Schema orders não existe. Execute primeiro as migrations de estrutura básica.';
    END IF;
    
    RAISE NOTICE 'Todos os schemas necessários existem. Prosseguindo com migração.';
END $$;

-- ============================================
-- 1. CRIAR WRAPPERS DE FUNÇÕES API NO PUBLIC
-- ============================================

-- 1.1 Wrapper para buscar lentes
CREATE OR REPLACE FUNCTION public.buscar_lentes(
    p_query TEXT DEFAULT '',
    p_filtros JSONB DEFAULT '{}'::jsonb,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    sku_canonico TEXT,
    nome_comercial TEXT,
    marca TEXT,
    categoria TEXT,
    material TEXT,
    indice_refracao NUMERIC,
    tratamentos JSONB,
    specs_tecnicas JSONB,
    preco_referencia NUMERIC,
    disponivel BOOLEAN
) 
SECURITY DEFINER
SET search_path = public, api
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM api.buscar_lentes(p_query, p_filtros, p_limit);
END;
$$;

COMMENT ON FUNCTION public.buscar_lentes IS 
'Wrapper público para api.buscar_lentes - Busca lentes com filtros avançados';

-- 1.2 Wrapper para criar decisão de lente (CRÍTICO - Resolve GAP #1)
CREATE OR REPLACE FUNCTION public.criar_decisao_lente(
    p_tenant_id UUID,
    p_cliente_id UUID,
    p_receita JSONB,
    p_criterio TEXT DEFAULT 'EQUILIBRADO',
    p_filtros JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB
SECURITY DEFINER
SET search_path = public, api, orders, scoring
LANGUAGE plpgsql
AS $$
DECLARE
    v_resultado JSONB;
BEGIN
    SELECT api.criar_decisao_lente(
        p_tenant_id,
        p_cliente_id, 
        p_receita,
        p_criterio,
        p_filtros
    ) INTO v_resultado;
    
    RETURN v_resultado;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'sucesso', false,
            'erro', SQLERRM,
            'detalhes', SQLSTATE
        );
END;
$$;

COMMENT ON FUNCTION public.criar_decisao_lente IS 
'🔥 CRÍTICO: Wrapper para criar decisões - RESOLVE GAP #1 (Write Operations)';

-- 1.3 Wrapper para obter dashboard KPIs
CREATE OR REPLACE FUNCTION public.obter_dashboard_kpis(
    p_tenant_id UUID DEFAULT NULL
)
RETURNS JSONB
SECURITY DEFINER
SET search_path = public, api, analytics
LANGUAGE plpgsql
AS $$
DECLARE
    v_resultado JSONB;
BEGIN
    SELECT api.obter_dashboard_kpis(p_tenant_id) INTO v_resultado;
    RETURN v_resultado;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'total_decisoes', 0,
            'economia_total', 0,
            'decisoes_mes', 0,
            'labs_ativos', 0
        );
END;
$$;

COMMENT ON FUNCTION public.obter_dashboard_kpis IS 
'Retorna KPIs do dashboard em formato JSON';

-- ============================================
-- 2. CRIAR VIEWS ENRIQUECIDAS NO PUBLIC
-- ============================================

-- 2.1 View de Fornecedores Enriquecida (Resolve GAP #2)
CREATE OR REPLACE VIEW public.vw_laboratorios_completo AS
SELECT 
    l.id,
    l.nome,
    l.nome_fantasia,
    l.cnpj,
    l.contato_comercial,
    l.lead_time_padrao_dias,
    l.ativo,
    l.tenant_id,
    -- SCORING (antes oculto)
    COALESCE(sl.score_geral, 0) as score_geral,
    COALESCE(sl.score_preco, 0) as score_preco,
    COALESCE(sl.score_prazo, 0) as score_prazo,
    COALESCE(sl.score_qualidade, 0) as score_qualidade,
    -- BADGE (baseado no score)
    CASE 
        WHEN sl.score_geral >= 9.0 THEN 'GOLD'
        WHEN sl.score_geral >= 7.5 THEN 'SILVER'
        WHEN sl.score_geral >= 6.0 THEN 'BRONZE'
        ELSE 'STANDARD'
    END as badge,
    -- MÉTRICAS
    sl.total_pedidos,
    sl.pedidos_no_prazo,
    sl.percentual_pontualidade,
    sl.prazo_medio_dias,
    sl.ultima_atualizacao as score_atualizado_em
FROM suppliers.laboratorios l
LEFT JOIN scoring.scores_laboratorios sl ON l.id = sl.laboratorio_id
WHERE l.ativo = true;

COMMENT ON VIEW public.vw_laboratorios_completo IS 
'🏅 View enriquecida com scores e badges - RESOLVE GAP #2 (Laboratórios com Alma)';

-- 2.2 View de Histórico de Decisões
CREATE OR REPLACE VIEW public.vw_historico_decisoes AS
SELECT 
    d.id,
    d.tenant_id,
    d.cliente_id,
    c.nome as cliente_nome,
    d.receita_dados,
    d.criterio_escolhido,
    d.status,
    d.criado_em,
    -- Alternativa escolhida
    (
        SELECT jsonb_build_object(
            'laboratorio_id', ac.laboratorio_id,
            'laboratorio_nome', l.nome,
            'lente_id', ac.lente_id,
            'lente_nome', le.nome_comercial,
            'preco_final', ac.preco_final,
            'prazo_dias', ac.prazo_entrega_dias,
            'ranking_posicao', ac.ranking_posicao
        )
        FROM orders.alternativas_cotacao ac
        LEFT JOIN suppliers.laboratorios l ON l.id = ac.laboratorio_id
        LEFT JOIN lens_catalog.lentes le ON le.id = ac.lente_id
        WHERE ac.decisao_id = d.id 
            AND ac.escolhida = true
        LIMIT 1
    ) as alternativa_escolhida,
    -- Total de alternativas geradas
    (
        SELECT COUNT(*)
        FROM orders.alternativas_cotacao ac
        WHERE ac.decisao_id = d.id
    ) as total_alternativas
FROM orders.decisoes_lentes d
LEFT JOIN public.clientes c ON c.id = d.cliente_id
ORDER BY d.criado_em DESC;

COMMENT ON VIEW public.vw_historico_decisoes IS 
'Histórico de decisões com alternativas - Facilita dashboard e relatórios';

-- 2.3 View de Ranking de Opções (melhorada)
CREATE OR REPLACE VIEW public.vw_ranking_atual AS
SELECT 
    ac.id,
    ac.decisao_id,
    ac.lente_id,
    l.nome_comercial as lente_nome,
    l.marca as lente_marca,
    ac.laboratorio_id,
    lab.nome as laboratorio_nome,
    -- BADGE do laboratório
    CASE 
        WHEN sl.score_geral >= 9.0 THEN 'GOLD'
        WHEN sl.score_geral >= 7.5 THEN 'SILVER'
        WHEN sl.score_geral >= 6.0 THEN 'BRONZE'
        ELSE 'STANDARD'
    END as laboratorio_badge,
    ac.preco_final,
    ac.prazo_entrega_dias,
    ac.score_final,
    ac.ranking_posicao,
    ac.escolhida,
    ac.recomendada,
    ac.observacoes
FROM orders.alternativas_cotacao ac
LEFT JOIN lens_catalog.lentes l ON l.id = ac.lente_id
LEFT JOIN suppliers.laboratorios lab ON lab.id = ac.laboratorio_id
LEFT JOIN scoring.scores_laboratorios sl ON sl.laboratorio_id = ac.laboratorio_id
ORDER BY ac.decisao_id, ac.ranking_posicao;

COMMENT ON VIEW public.vw_ranking_atual IS 
'Ranking enriquecido com badges e scores dos laboratórios';

-- ============================================
-- 3. CRIAR FUNÇÕES AUXILIARES NO PUBLIC
-- ============================================

-- 3.1 Função para listar laboratórios disponíveis (com filtros)
CREATE OR REPLACE FUNCTION public.listar_laboratorios(
    p_tenant_id UUID DEFAULT NULL,
    p_apenas_ativos BOOLEAN DEFAULT true,
    p_min_score NUMERIC DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    nome TEXT,
    nome_fantasia TEXT,
    badge TEXT,
    score_geral NUMERIC,
    percentual_pontualidade NUMERIC,
    prazo_medio_dias INTEGER,
    total_pedidos INTEGER,
    ativo BOOLEAN
)
SECURITY DEFINER
SET search_path = public, suppliers, scoring
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.nome,
        l.nome_fantasia,
        CASE 
            WHEN COALESCE(sl.score_geral, 0) >= 9.0 THEN 'GOLD'::TEXT
            WHEN COALESCE(sl.score_geral, 0) >= 7.5 THEN 'SILVER'::TEXT
            WHEN COALESCE(sl.score_geral, 0) >= 6.0 THEN 'BRONZE'::TEXT
            ELSE 'STANDARD'::TEXT
        END,
        COALESCE(sl.score_geral, 0),
        COALESCE(sl.percentual_pontualidade, 0),
        COALESCE(sl.prazo_medio_dias::INTEGER, 0),
        COALESCE(sl.total_pedidos::INTEGER, 0),
        l.ativo
    FROM suppliers.laboratorios l
    LEFT JOIN scoring.scores_laboratorios sl ON l.id = sl.laboratorio_id
    WHERE (NOT p_apenas_ativos OR l.ativo = true)
        AND (p_tenant_id IS NULL OR l.tenant_id = p_tenant_id)
        AND COALESCE(sl.score_geral, 0) >= p_min_score
    ORDER BY sl.score_geral DESC NULLS LAST;
END;
$$;

COMMENT ON FUNCTION public.listar_laboratorios IS 
'Lista laboratórios com scores e badges - Acesso simplificado para frontend';

-- 3.2 Função para obter detalhes de um laboratório
CREATE OR REPLACE FUNCTION public.obter_laboratorio(
    p_laboratorio_id UUID
)
RETURNS JSONB
SECURITY DEFINER
SET search_path = public, suppliers, scoring
LANGUAGE plpgsql
AS $$
DECLARE
    v_resultado JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', l.id,
        'nome', l.nome,
        'nome_fantasia', l.nome_fantasia,
        'cnpj', l.cnpj,
        'contato_comercial', l.contato_comercial,
        'lead_time_padrao_dias', l.lead_time_padrao_dias,
        'atende_regioes', l.atende_regioes,
        'ativo', l.ativo,
        'badge', CASE 
            WHEN COALESCE(sl.score_geral, 0) >= 9.0 THEN 'GOLD'
            WHEN COALESCE(sl.score_geral, 0) >= 7.5 THEN 'SILVER'
            WHEN COALESCE(sl.score_geral, 0) >= 6.0 THEN 'BRONZE'
            ELSE 'STANDARD'
        END,
        'scores', jsonb_build_object(
            'geral', COALESCE(sl.score_geral, 0),
            'preco', COALESCE(sl.score_preco, 0),
            'prazo', COALESCE(sl.score_prazo, 0),
            'qualidade', COALESCE(sl.score_qualidade, 0)
        ),
        'metricas', jsonb_build_object(
            'total_pedidos', COALESCE(sl.total_pedidos, 0),
            'pedidos_no_prazo', COALESCE(sl.pedidos_no_prazo, 0),
            'percentual_pontualidade', COALESCE(sl.percentual_pontualidade, 0),
            'prazo_medio_dias', COALESCE(sl.prazo_medio_dias, 0)
        )
    ) INTO v_resultado
    FROM suppliers.laboratorios l
    LEFT JOIN scoring.scores_laboratorios sl ON l.id = sl.laboratorio_id
    WHERE l.id = p_laboratorio_id;
    
    RETURN v_resultado;
END;
$$;

COMMENT ON FUNCTION public.obter_laboratorio IS 
'Retorna dados completos de um laboratório em formato JSON';

-- ============================================
-- 4. ATUALIZAR PERMISSÕES
-- ============================================

GRANT EXECUTE ON FUNCTION public.buscar_lentes TO authenticated;
GRANT EXECUTE ON FUNCTION public.criar_decisao_lente TO authenticated;
GRANT EXECUTE ON FUNCTION public.obter_dashboard_kpis TO authenticated;
GRANT EXECUTE ON FUNCTION public.listar_laboratorios TO authenticated;
GRANT EXECUTE ON FUNCTION public.obter_laboratorio TO authenticated;

GRANT SELECT ON public.vw_laboratorios_completo TO authenticated;
GRANT SELECT ON public.vw_historico_decisoes TO authenticated;
GRANT SELECT ON public.vw_ranking_atual TO authenticated;

-- ============================================
-- 5. CRIAR ÍNDICES PARA PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_scores_laboratorios_score_geral 
ON scoring.scores_laboratorios(score_geral DESC);

CREATE INDEX IF NOT EXISTS idx_decisoes_tenant_criado 
ON orders.decisoes_lentes(tenant_id, criado_em DESC);

CREATE INDEX IF NOT EXISTS idx_alternativas_decisao 
ON orders.alternativas_cotacao(decisao_id, ranking_posicao);

COMMIT;

-- ============================================
-- VERIFICAÇÃO FINAL
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ MIGRAÇÃO CONCLUÍDA COM SUCESSO!';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE '📦 Funções criadas no schema public:';
    RAISE NOTICE '  ✓ buscar_lentes()';
    RAISE NOTICE '  ✓ criar_decisao_lente() - RESOLVE GAP #1';
    RAISE NOTICE '  ✓ obter_dashboard_kpis()';
    RAISE NOTICE '  ✓ listar_laboratorios()';
    RAISE NOTICE '  ✓ obter_laboratorio()';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Views enriquecidas criadas:';
    RAISE NOTICE '  ✓ vw_laboratorios_completo - RESOLVE GAP #2';
    RAISE NOTICE '  ✓ vw_historico_decisoes';
    RAISE NOTICE '  ✓ vw_ranking_atual';
    RAISE NOTICE '========================================';
END $$;
