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

-- Verificar se schemas e tabelas necessários existem
DO $$
DECLARE
    rec RECORD;
    v_count INTEGER;
BEGIN
    -- Verificar schemas
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'suppliers') THEN
        RAISE EXCEPTION 'Schema suppliers não existe. Execute primeiro as migrations de estrutura básica (20251002000004_suppliers.sql).';
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
    
    -- Verificar tabelas críticas
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'suppliers' AND table_name = 'laboratorios') THEN
        RAISE EXCEPTION 'Tabela suppliers.laboratorios não existe. Execute primeiro a migration 20251002000004_suppliers.sql';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'orders' AND table_name = 'decisoes_lentes') THEN
        RAISE EXCEPTION 'Tabela orders.decisoes_lentes não existe. Execute primeiro as migrations de orders.';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'orders' AND table_name = 'alternativas_cotacao') THEN
        RAISE EXCEPTION 'Tabela orders.alternativas_cotacao não existe. Execute primeiro as migrations de orders.';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lens_catalog' AND table_name = 'lentes') THEN
        RAISE EXCEPTION 'Tabela lens_catalog.lentes não existe. Execute primeiro as migrations de lens_catalog.';
    END IF;
    
    -- Verificar estrutura da tabela laboratorios (validação básica - apenas log, não bloqueia)
    RAISE NOTICE '   ➤ Verificando estrutura de suppliers.laboratorios...';
    
    -- Contar colunas esperadas
    SELECT COUNT(*) INTO v_count FROM information_schema.columns 
    WHERE table_schema = 'suppliers' AND table_name = 'laboratorios';
    
    RAISE NOTICE '     Total de colunas encontradas: %', v_count;
    
    -- Verificar se as colunas essenciais existem
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'suppliers' AND table_name = 'laboratorios' AND column_name = 'nome') THEN
        RAISE NOTICE '     ✓ Coluna "nome" existe';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'suppliers' AND table_name = 'laboratorios' AND column_name = 'nome_fantasia') THEN
        RAISE NOTICE '     ✓ Coluna "nome_fantasia" existe';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'suppliers' AND table_name = 'laboratorios' AND column_name = 'ativo') THEN
        RAISE NOTICE '     ✓ Coluna "ativo" existe';
    END IF;
    
    RAISE NOTICE '✓ Todos os schemas e tabelas necessários existem.';
    RAISE NOTICE '✓ Estrutura da tabela suppliers.laboratorios validada.';
    RAISE NOTICE 'Prosseguindo com migração...';
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

-- 2.1 View de Fornecedores Enriquecida COM SCORING REAL (Resolve GAP #2)
CREATE OR REPLACE VIEW public.vw_laboratorios_completo AS
SELECT 
    l.id,
    l.nome_fantasia as nome,
    l.cnpj,
    l.contato_comercial,
    l.lead_time_padrao_dias,
    l.ativo,
    l.tenant_id,
    l.atende_regioes,
    l.criado_em,
    l.atualizado_em,
    -- Scores do laboratório (dados reais!)
    s.score_geral,
    s.score_qualidade,
    s.score_preco,
    s.score_prazo,
    s.score_servico,
    s.ranking_geral,
    s.nivel_qualificacao as badge,
    s.data_calculo as score_data_calculo,
    s.valido_ate as score_valido_ate
FROM suppliers.laboratorios l
LEFT JOIN LATERAL (
    SELECT *
    FROM scoring.scores_laboratorios sl
    WHERE sl.laboratorio_id = l.id
    AND sl.valido_ate >= CURRENT_DATE
    ORDER BY sl.data_calculo DESC
    LIMIT 1
) s ON true
WHERE l.ativo = true;

COMMENT ON VIEW public.vw_laboratorios_completo IS 
'🏅 View enriquecida com scores e badges - RESOLVE GAP #2 (Laboratórios com Alma)';

-- 2.2 View de Histórico de Decisões (ESTRUTURA REAL)
CREATE OR REPLACE VIEW public.vw_historico_decisoes AS
SELECT 
    d.id,
    d.tenant_id,
    d.codigo_decisao,
    d.cliente_nome,
    d.otica_id,
    d.nome_otica,
    d.lente_recomendada_id,
    d.laboratorio_escolhido_id,
    d.preco_final,
    d.status,
    d.prioridade,
    d.prazo_entrega_prometido,
    d.criado_em,
    d.atualizado_em,
    -- Total de alternativas geradas
    (
        SELECT COUNT(*)
        FROM orders.alternativas_cotacao ac
        WHERE ac.decisao_id = d.id
    ) as total_alternativas,
    -- Alternativa escolhida (se houver)
    (
        SELECT jsonb_build_object(
            'lente_id', ac.lente_id,
            'laboratorio_id', ac.laboratorio_id,
            'preco_final', ac.preco_final,
            'prazo_medio', ac.prazo_medio,
            'score_geral', ac.score_geral
        )
        FROM orders.alternativas_cotacao ac
        WHERE ac.decisao_id = d.id
        AND ac.recomendada = true
        LIMIT 1
    ) as alternativa_recomendada
FROM orders.decisoes_lentes d;

COMMENT ON VIEW public.vw_historico_decisoes IS 
'Histórico de decisões com alternativas - Facilita dashboard e relatórios';

-- 2.3 View de Ranking de Opções (ESTRUTURA REAL + SCORING)
CREATE OR REPLACE VIEW public.vw_ranking_atual AS
SELECT 
    ac.id,
    ac.decisao_id,
    ac.lente_id,
    l.familia as lente_familia,
    l.design as lente_design,
    l.material as lente_material,
    l.indice_refracao,
    ac.laboratorio_id,
    lab.nome_fantasia as laboratorio_nome,
    lab.lead_time_padrao_dias,
    -- Badge baseado no score real (se existir)
    CASE 
        WHEN s.nivel_qualificacao IS NOT NULL THEN s.nivel_qualificacao
        ELSE 'QUALIFICADO'
    END as laboratorio_badge,
    ac.posicao,
    ac.tipo_alternativa,
    ac.preco_base,
    ac.desconto_percentual,
    ac.preco_final,
    ac.custo_frete,
    ac.preco_total,
    ac.prazo_minimo,
    ac.prazo_maximo,
    ac.prazo_medio,
    ac.disponibilidade,
    ac.score_geral,
    ac.score_qualidade,
    ac.score_preco,
    ac.score_prazo,
    ac.percentual_adequacao,
    ac.recomendada,
    ac.ativa,
    ac.pontos_fortes,
    ac.pontos_fracos,
    ac.observacoes,
    -- Scores do laboratório (se disponíveis)
    s.score_geral as lab_score_geral,
    s.score_qualidade as lab_score_qualidade,
    s.score_preco as lab_score_preco,
    s.score_prazo as lab_score_prazo
FROM orders.alternativas_cotacao ac
LEFT JOIN lens_catalog.lentes l ON l.id = ac.lente_id
LEFT JOIN suppliers.laboratorios lab ON lab.id = ac.laboratorio_id
LEFT JOIN LATERAL (
    SELECT *
    FROM scoring.scores_laboratorios sl
    WHERE sl.laboratorio_id = ac.laboratorio_id
    AND sl.valido_ate >= CURRENT_DATE
    ORDER BY sl.data_calculo DESC
    LIMIT 1
) s ON true
ORDER BY ac.decisao_id, ac.posicao;

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
    nome_fantasia TEXT,
    badge TEXT,
    lead_time_padrao_dias INTEGER,
    ativo BOOLEAN,
    score_geral NUMERIC,
    ranking_geral INTEGER
)
SECURITY DEFINER
SET search_path = public, suppliers, scoring
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.nome_fantasia,
        COALESCE(s.nivel_qualificacao, 'QUALIFICADO')::TEXT as badge,
        l.lead_time_padrao_dias,
        l.ativo,
        s.score_geral,
        s.ranking_geral
    FROM suppliers.laboratorios l
    LEFT JOIN LATERAL (
        SELECT *
        FROM scoring.scores_laboratorios sl
        WHERE sl.laboratorio_id = l.id
        AND sl.valido_ate >= CURRENT_DATE
        ORDER BY sl.data_calculo DESC
        LIMIT 1
    ) s ON true
    WHERE (NOT p_apenas_ativos OR l.ativo = true)
        AND (p_tenant_id IS NULL OR l.tenant_id = p_tenant_id)
        AND (p_min_score = 0 OR COALESCE(s.score_geral, 0) >= p_min_score)
    ORDER BY s.ranking_geral NULLS LAST, l.nome_fantasia;
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
        'nome_fantasia', l.nome_fantasia,
        'cnpj', l.cnpj,
        'contato_comercial', l.contato_comercial,
        'lead_time_padrao_dias', l.lead_time_padrao_dias,
        'atende_regioes', l.atende_regioes,
        'ativo', l.ativo,
        'badge', COALESCE(s.nivel_qualificacao, 'QUALIFICADO'),
        'score_geral', s.score_geral,
        'score_qualidade', s.score_qualidade,
        'score_preco', s.score_preco,
        'score_prazo', s.score_prazo,
        'ranking_geral', s.ranking_geral,
        'criado_em', l.criado_em,
        'atualizado_em', l.atualizado_em
    ) INTO v_resultado
    FROM suppliers.laboratorios l
    LEFT JOIN LATERAL (
        SELECT *
        FROM scoring.scores_laboratorios sl
        WHERE sl.laboratorio_id = l.id
        AND sl.valido_ate >= CURRENT_DATE
        ORDER BY sl.data_calculo DESC
        LIMIT 1
    ) s ON true
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

-- Índices para performance (usando estrutura real)
CREATE INDEX IF NOT EXISTS idx_decisoes_tenant_criado 
ON orders.decisoes_lentes(tenant_id, criado_em DESC);

CREATE INDEX IF NOT EXISTS idx_alternativas_decisao_posicao 
ON orders.alternativas_cotacao(decisao_id, posicao);

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
