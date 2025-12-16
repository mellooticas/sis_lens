-- DIAGNÓSTICO COMPLETO DO BANCO
-- Execute no Supabase SQL Editor

-- 1. Verificar schemas existentes
SELECT '=== SCHEMAS DISPONÍVEIS ===' as titulo;
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
ORDER BY schema_name;

-- 2. Verificar tabelas em cada schema
SELECT '=== TABELAS POR SCHEMA ===' as titulo;
SELECT table_schema, table_name, 
       (SELECT COUNT(*) FROM information_schema.columns WHERE columns.table_schema = tables.table_schema AND columns.table_name = tables.table_name) as num_colunas
FROM information_schema.tables 
WHERE table_schema NOT IN ('information_schema', 'pg_catalog', 'pg_toast', 'auth', 'storage', 'extensions')
ORDER BY table_schema, table_name;

-- 3. Contar registros nas tabelas principais
SELECT '=== TOTAL DE REGISTROS ===' as titulo;

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Lentes
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'lens_catalog' AND table_name = 'lentes') THEN
        EXECUTE 'SELECT COUNT(*) FROM lens_catalog.lentes' INTO v_count;
        RAISE NOTICE 'lens_catalog.lentes: %', v_count;
    ELSE
        RAISE NOTICE 'lens_catalog.lentes: NÃO EXISTE';
    END IF;
    
    -- Laboratórios
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'suppliers' AND table_name = 'laboratorios') THEN
        EXECUTE 'SELECT COUNT(*) FROM suppliers.laboratorios' INTO v_count;
        RAISE NOTICE 'suppliers.laboratorios: %', v_count;
    ELSE
        RAISE NOTICE 'suppliers.laboratorios: NÃO EXISTE';
    END IF;
    
    -- Scores
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'scoring' AND table_name = 'scores_laboratorios') THEN
        EXECUTE 'SELECT COUNT(*) FROM scoring.scores_laboratorios' INTO v_count;
        RAISE NOTICE 'scoring.scores_laboratorios: %', v_count;
    ELSE
        RAISE NOTICE 'scoring.scores_laboratorios: NÃO EXISTE';
    END IF;
    
    -- Decisões
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'orders' AND table_name = 'decisoes_lentes') THEN
        EXECUTE 'SELECT COUNT(*) FROM orders.decisoes_lentes' INTO v_count;
        RAISE NOTICE 'orders.decisoes_lentes: %', v_count;
    ELSE
        RAISE NOTICE 'orders.decisoes_lentes: NÃO EXISTE';
    END IF;
END $$;

-- 4. Verificar funções públicas existentes
SELECT '=== FUNÇÕES NO SCHEMA PUBLIC ===' as titulo;
SELECT routine_name, routine_type
FROM information_schema.routines 
WHERE routine_schema = 'public'
AND routine_name IN ('buscar_lentes', 'obter_dashboard_kpis', 'criar_decisao_lente', 'listar_laboratorios', 'obter_laboratorio')
ORDER BY routine_name;

-- 5. Verificar views públicas
SELECT '=== VIEWS NO SCHEMA PUBLIC ===' as titulo;
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public'
AND table_name LIKE 'vw_%'
ORDER BY table_name;

-- 6. Testar se consegue acessar lentes
SELECT '=== TESTE ACESSO LENTES ===' as titulo;
SELECT COUNT(*) as total_lentes FROM lens_catalog.lentes WHERE disponivel = true;
SELECT familia, design, material, COUNT(*) as qtd
FROM lens_catalog.lentes 
WHERE disponivel = true
GROUP BY familia, design, material
ORDER BY qtd DESC
LIMIT 10;

-- 7. Testar se consegue acessar laboratórios
SELECT '=== TESTE ACESSO LABS ===' as titulo;
SELECT COUNT(*) as total_labs FROM suppliers.laboratorios WHERE ativo = true;
SELECT id, nome_fantasia, lead_time_padrao_dias, ativo 
FROM suppliers.laboratorios 
LIMIT 5;

-- 8. Verificar se migration 20251216_001 foi aplicada
SELECT '=== VERIFICAR MIGRATIONS APLICADAS ===' as titulo;
SELECT name, executed_at 
FROM supabase_migrations.schema_migrations 
WHERE name LIKE '%20251216%'
ORDER BY executed_at DESC;
