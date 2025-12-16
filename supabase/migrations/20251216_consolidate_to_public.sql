-- ============================================
-- MIGRAÇÃO: Consolidar API e Dados para PUBLIC
-- Data: 2025-12-16
-- Descrição: Cria wrappers e views enriquecidas no schema public para permitir
--            que o frontend acesse toda funcionalidade necessária sem depender
--            de schemas internos (api, scoring, suppliers, etc)
-- ============================================
-- BASEADO NA INVESTIGAÇÃO: docs/database/investigation/05_veredito_gaps_public.md
-- 
-- GAPS IDENTIFICADOS:
-- 1. Impossível salvar decisões (Write Gap) - Falta wrapper para api.criar_decisao_lente
-- 2. Laboratórios sem "alma" (Data Gap) - View não mostra badges, scores, prazos
-- 3. Dashboard cego - Sem dados de decisão pois não conseguimos gravar
--
-- IMPORTANTE: Esta migração deve ser executada em DESENVOLVIMENTO primeiro!
-- Backup recomendado antes de executar em produção.

BEGIN;

-- ============================================
-- 1. CRIAR WRAPPERS DE FUNÇÕES API NO PUBLIC
-- ============================================

-- 1.1 Wrapper para buscar lentes (já existe rpc_buscar_lente, mas vamos garantir)
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
    -- Chama a função real do schema api
    RETURN QUERY
    SELECT * FROM api.buscar_lentes(p_query, p_filtros, p_limit);
END;
$$;

COMMENT ON FUNCTION public.buscar_lentes IS 
'Wrapper público para api.buscar_lentes - Permite frontend buscar lentes sem acessar schema api';

-- 1.2 Wrapper para criar decisão de lente (CRÍTICO - Gap #1)
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
    -- Chama a função real do schema api
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
'Wrapper público para api.criar_decisao_lente - RESOLVE GAP #1: Permite salvar decisões';

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
        -- Retornar estrutura vazia se houver erro
        RETURN jsonb_build_object(
            'total_decisoes', 0,
            'economia_total', 0,
            'decisoes_mes', 0,
            'labs_ativos', 0
        );
END;
$$;

COMMENT ON FUNCTION public.obter_dashboard_kpis IS 
'Wrapper público para api.obter_dashboard_kpis';

-- ============================================
-- 2. CRIAR VIEWS ENRIQUECIDAS NO PUBLIC
-- ============================================

-- 2.1 View de Fornecedores Enriquecida (RESOLVE GAP #2)
CREATE OR REPLACE VIEW public.vw_laboratorios_completo AS
SELECT 
    l.id,
    l.nome,
    l.cnpj,
    l.email,
    l.telefone,
    l.status,
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
WHERE l.status = 'ATIVO';

COMMENT ON VIEW public.vw_laboratorios_completo IS 
'View enriquecida com scores e badges dos laboratórios - RESOLVE GAP #2';

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
'View de histórico de decisões com alternativas - Facilita dashboard e relatórios';

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
'View enriquecida do ranking com badges e scores dos laboratórios';

-- ============================================
-- 3. CRIAR FUNÇÕES AUXILIARES NO PUBLIC
-- ============================================

-- 3.1 Função para listar laboratórios disponíveis (com filtros)
CREATE OR REPLACE FUNCTION public.listar_laboratorios(
    p_tenant_id UUID DEFAULT NULL,
    p_status TEXT DEFAULT 'ATIVO',
    p_min_score NUMERIC DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    nome TEXT,
    badge TEXT,
    score_geral NUMERIC,
    percentual_pontualidade NUMERIC,
    prazo_medio_dias INTEGER,
    total_pedidos INTEGER,
    status TEXT
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
        l.status
    FROM suppliers.laboratorios l
    LEFT JOIN scoring.scores_laboratorios sl ON l.id = sl.laboratorio_id
    WHERE l.status = p_status
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
        'cnpj', l.cnpj,
        'email', l.email,
        'telefone', l.telefone,
        'status', l.status,
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

-- Permitir que usuários autenticados executem as funções
GRANT EXECUTE ON FUNCTION public.buscar_lentes TO authenticated;
GRANT EXECUTE ON FUNCTION public.criar_decisao_lente TO authenticated;
GRANT EXECUTE ON FUNCTION public.obter_dashboard_kpis TO authenticated;
GRANT EXECUTE ON FUNCTION public.listar_laboratorios TO authenticated;
GRANT EXECUTE ON FUNCTION public.obter_laboratorio TO authenticated;

-- Permitir leitura das views
GRANT SELECT ON public.vw_laboratorios_completo TO authenticated;
GRANT SELECT ON public.vw_historico_decisoes TO authenticated;
GRANT SELECT ON public.vw_ranking_atual TO authenticated;

-- ============================================
-- 5. CRIAR ÍNDICES PARA PERFORMANCE
-- ============================================

-- Índice para busca de laboratórios por score
CREATE INDEX IF NOT EXISTS idx_scores_laboratorios_score_geral 
ON scoring.scores_laboratorios(score_geral DESC);

-- Índice para decisões por tenant e data
CREATE INDEX IF NOT EXISTS idx_decisoes_tenant_criado 
ON orders.decisoes_lentes(tenant_id, criado_em DESC);

-- Índice para alternativas por decisão
CREATE INDEX IF NOT EXISTS idx_alternativas_decisao 
ON orders.alternativas_cotacao(decisao_id, ranking_posicao);

COMMIT;

-- ============================================
-- 1. MOVER TABELAS PARA PUBLIC
-- ============================================

-- 1.1 META_SYSTEM -> PUBLIC
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'meta_system'
    LOOP
        EXECUTE format('ALTER TABLE meta_system.%I SET SCHEMA public', r.tablename);
        RAISE NOTICE 'Moved table meta_system.% to public', r.tablename;
    END LOOP;
END $$;

-- 1.2 LENS_CATALOG -> PUBLIC
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'lens_catalog'
    LOOP
        EXECUTE format('ALTER TABLE lens_catalog.%I SET SCHEMA public', r.tablename);
        RAISE NOTICE 'Moved table lens_catalog.% to public', r.tablename;
    END LOOP;
END $$;

-- 1.3 SUPPLIERS -> PUBLIC
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'suppliers'
    LOOP
        EXECUTE format('ALTER TABLE suppliers.%I SET SCHEMA public', r.tablename);
        RAISE NOTICE 'Moved table suppliers.% to public', r.tablename;
    END LOOP;
END $$;

-- 1.4 COMMERCIAL -> PUBLIC
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'commercial'
    LOOP
        EXECUTE format('ALTER TABLE commercial.%I SET SCHEMA public', r.tablename);
        RAISE NOTICE 'Moved table commercial.% to public', r.tablename;
    END LOOP;
END $$;

-- 1.5 LOGISTICS -> PUBLIC
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'logistics'
    LOOP
        EXECUTE format('ALTER TABLE logistics.%I SET SCHEMA public', r.tablename);
        RAISE NOTICE 'Moved table logistics.% to public', r.tablename;
    END LOOP;
END $$;

-- 1.6 SCORING -> PUBLIC
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'scoring'
    LOOP
        EXECUTE format('ALTER TABLE scoring.%I SET SCHEMA public', r.tablename);
        RAISE NOTICE 'Moved table scoring.% to public', r.tablename;
    END LOOP;
END $$;

-- 1.7 ORDERS -> PUBLIC
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'orders'
    LOOP
        EXECUTE format('ALTER TABLE orders.%I SET SCHEMA public', r.tablename);
        RAISE NOTICE 'Moved table orders.% to public', r.tablename;
    END LOOP;
END $$;

-- 1.8 ANALYTICS -> PUBLIC
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'analytics'
    LOOP
        EXECUTE format('ALTER TABLE analytics.%I SET SCHEMA public', r.tablename);
        RAISE NOTICE 'Moved table analytics.% to public', r.tablename;
    END LOOP;
END $$;

-- ============================================
-- 2. MOVER VIEWS PARA PUBLIC
-- ============================================

DO $$
DECLARE
    r RECORD;
    schemas TEXT[] := ARRAY['meta_system', 'lens_catalog', 'suppliers', 'commercial', 'logistics', 'scoring', 'orders', 'analytics'];
    schema_name TEXT;
BEGIN
    FOREACH schema_name IN ARRAY schemas
    LOOP
        FOR r IN 
            SELECT viewname 
            FROM pg_views 
            WHERE schemaname = schema_name
        LOOP
            EXECUTE format('ALTER VIEW %I.%I SET SCHEMA public', schema_name, r.viewname);
            RAISE NOTICE 'Moved view %.% to public', schema_name, r.viewname;
        END LOOP;
    END LOOP;
END $$;

-- ============================================
-- 3. MOVER SEQUENCES PARA PUBLIC
-- ============================================

DO $$
DECLARE
    r RECORD;
    schemas TEXT[] := ARRAY['meta_system', 'lens_catalog', 'suppliers', 'commercial', 'logistics', 'scoring', 'orders', 'analytics'];
    schema_name TEXT;
BEGIN
    FOREACH schema_name IN ARRAY schemas
    LOOP
        FOR r IN 
            SELECT sequencename 
            FROM pg_sequences 
            WHERE schemaname = schema_name
        LOOP
            EXECUTE format('ALTER SEQUENCE %I.%I SET SCHEMA public', schema_name, r.sequencename);
            RAISE NOTICE 'Moved sequence %.% to public', schema_name, r.sequencename;
        END LOOP;
    END LOOP;
END $$;

-- ============================================
-- 4. MOVER FUNÇÕES PARA PUBLIC
-- ============================================

DO $$
DECLARE
    r RECORD;
    schemas TEXT[] := ARRAY['meta_system', 'lens_catalog', 'suppliers', 'commercial', 'logistics', 'scoring', 'orders', 'analytics'];
    schema_name TEXT;
BEGIN
    FOREACH schema_name IN ARRAY schemas
    LOOP
        FOR r IN 
            SELECT 
                p.proname as function_name,
                pg_get_function_identity_arguments(p.oid) as arguments
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = schema_name
        LOOP
            EXECUTE format('ALTER FUNCTION %I.%I(%s) SET SCHEMA public', 
                schema_name, r.function_name, r.arguments);
            RAISE NOTICE 'Moved function %.%(%s) to public', schema_name, r.function_name, r.arguments;
        END LOOP;
    END LOOP;
END $$;

-- ============================================
-- 5. MOVER TIPOS CUSTOMIZADOS PARA PUBLIC
-- ============================================

DO $$
DECLARE
    r RECORD;
    schemas TEXT[] := ARRAY['meta_system', 'lens_catalog', 'suppliers', 'commercial', 'logistics', 'scoring', 'orders', 'analytics'];
    schema_name TEXT;
BEGIN
    FOREACH schema_name IN ARRAY schemas
    LOOP
        FOR r IN 
            SELECT typname
            FROM pg_type t
            JOIN pg_namespace n ON t.typnamespace = n.oid
            WHERE n.nspname = schema_name
            AND t.typtype IN ('e', 'c') -- enum or composite
        LOOP
            EXECUTE format('ALTER TYPE %I.%I SET SCHEMA public', schema_name, r.typname);
            RAISE NOTICE 'Moved type %.% to public', schema_name, r.typname;
        END LOOP;
    END LOOP;
END $$;

-- ============================================
-- 6. RECRIAR POLÍTICAS RLS (se necessário)
-- ============================================

-- As políticas RLS devem continuar funcionando, mas vamos garantir
-- que as permissões estejam corretas no schema public

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;

-- Grant access to all tables
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Grant access to all sequences
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Grant execute on all functions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon;

-- ============================================
-- 7. ATUALIZAR SEARCH_PATH PADRÃO
-- ============================================

-- Garantir que public seja o primeiro no search_path
ALTER DATABASE postgres SET search_path TO public;

-- ============================================
-- 8. CRIAR VIEWS DE COMPATIBILIDADE (OPCIONAL)
-- ============================================

-- Se houver código legado que ainda referencia os schemas antigos,
-- podemos criar views de redirecionamento:

-- Exemplo (descomente se necessário):
-- CREATE OR REPLACE VIEW meta_system.original_table_name AS 
-- SELECT * FROM public.original_table_name;

-- ============================================
-- 9. LIMPAR SCHEMAS VAZIOS (CUIDADO!)
-- ============================================

-- AVISO: Só execute isso depois de confirmar que tudo foi movido!
-- Descomente as linhas abaixo após validação:

-- DROP SCHEMA IF EXISTS meta_system CASCADE;
-- DROP SCHEMA IF EXISTS lens_catalog CASCADE;
-- DROP SCHEMA IF EXISTS suppliers CASCADE;
-- DROP SCHEMA IF EXISTS commercial CASCADE;
-- DROP SCHEMA IF EXISTS logistics CASCADE;
-- DROP SCHEMA IF EXISTS scoring CASCADE;
-- DROP SCHEMA IF EXISTS orders CASCADE;
-- DROP SCHEMA IF EXISTS analytics CASCADE;

-- ============================================
-- 10. VERIFICAÇÃO FINAL
-- ============================================

DO $$
DECLARE
    count_meta INTEGER;
    count_lens INTEGER;
    count_suppliers INTEGER;
    count_commercial INTEGER;
    count_logistics INTEGER;
    count_scoring INTEGER;
    count_orders INTEGER;
    count_analytics INTEGER;
BEGIN
    SELECT COUNT(*) INTO count_meta FROM pg_tables WHERE schemaname = 'meta_system';
    SELECT COUNT(*) INTO count_lens FROM pg_tables WHERE schemaname = 'lens_catalog';
    SELECT COUNT(*) INTO count_suppliers FROM pg_tables WHERE schemaname = 'suppliers';
    SELECT COUNT(*) INTO count_commercial FROM pg_tables WHERE schemaname = 'commercial';
    SELECT COUNT(*) INTO count_logistics FROM pg_tables WHERE schemaname = 'logistics';
    SELECT COUNT(*) INTO count_scoring FROM pg_tables WHERE schemaname = 'scoring';
    SELECT COUNT(*) INTO count_orders FROM pg_tables WHERE schemaname = 'orders';
    SELECT COUNT(*) INTO count_analytics FROM pg_tables WHERE schemaname = 'analytics';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'VERIFICAÇÃO FINAL DE MIGRAÇÃO';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Tabelas restantes em meta_system: %', count_meta;
    RAISE NOTICE 'Tabelas restantes em lens_catalog: %', count_lens;
    RAISE NOTICE 'Tabelas restantes em suppliers: %', count_suppliers;
    RAISE NOTICE 'Tabelas restantes em commercial: %', count_commercial;
    RAISE NOTICE 'Tabelas restantes em logistics: %', count_logistics;
    RAISE NOTICE 'Tabelas restantes em scoring: %', count_scoring;
    RAISE NOTICE 'Tabelas restantes em orders: %', count_orders;
    RAISE NOTICE 'Tabelas restantes em analytics: %', count_analytics;
    RAISE NOTICE '========================================';
    
    IF count_meta + count_lens + count_suppliers + count_commercial + 
       count_logistics + count_scoring + count_orders + count_analytics = 0 THEN
        RAISE NOTICE '✓ SUCESSO: Todas as tabelas foram movidas para public!';
    ELSE
        RAISE NOTICE '⚠ AVISO: Ainda existem tabelas nos schemas antigos.';
    END IF;
END $$;

COMMIT;

-- ============================================
-- INSTRUÇÕES PÓS-MIGRAÇÃO
-- ============================================

/*
1. Execute esta migração em ambiente de desenvolvimento primeiro
2. Teste todas as funcionalidades do sistema
3. Verifique se há referências hardcoded aos schemas antigos no código
4. Atualize o código do frontend/backend para remover qualificadores de schema
5. Após confirmação, execute em produção
6. Após validação total, descomente a seção 9 para limpar schemas vazios
*/
