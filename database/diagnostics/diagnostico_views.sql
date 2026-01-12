-- Diagnóstico das Views e Funções Públicas

-- 1. Verificar total de registros nas tabelas base
SELECT '1. TABELAS BASE' as secao;
SELECT 'suppliers.laboratorios' as tabela, COUNT(*) as total FROM suppliers.laboratorios;
SELECT 'lens_catalog.lentes' as tabela, COUNT(*) as total FROM lens_catalog.lentes;
SELECT 'scoring.scores_laboratorios' as tabela, COUNT(*) as total FROM scoring.scores_laboratorios;
SELECT 'orders.decisoes_lentes' as tabela, COUNT(*) as total FROM orders.decisoes_lentes;
SELECT 'orders.alternativas_cotacao' as tabela, COUNT(*) as total FROM orders.alternativas_cotacao;

-- 2. Testar views públicas
SELECT '2. VIEWS PÚBLICAS' as secao;

-- View de laboratórios
SELECT 'vw_laboratorios_completo' as view_name, COUNT(*) as total FROM public.vw_laboratorios_completo;
SELECT * FROM public.vw_laboratorios_completo LIMIT 3;

-- View de decisões
SELECT 'vw_historico_decisoes' as view_name, COUNT(*) as total FROM public.vw_historico_decisoes;
SELECT * FROM public.vw_historico_decisoes LIMIT 3;

-- View de ranking
SELECT 'vw_ranking_atual' as view_name, COUNT(*) as total FROM public.vw_ranking_atual;
SELECT * FROM public.vw_ranking_atual LIMIT 3;

-- 3. Testar funções públicas
SELECT '3. FUNÇÕES PÚBLICAS' as secao;

-- Dashboard KPIs
SELECT 'obter_dashboard_kpis()' as funcao;
SELECT public.obter_dashboard_kpis();

-- Listar laboratórios
SELECT 'listar_laboratorios()' as funcao;
SELECT * FROM public.listar_laboratorios();

-- Buscar lentes (teste simples)
SELECT 'buscar_lentes()' as funcao, COUNT(*) as total 
FROM public.buscar_lentes('', '{}', 10);

-- 4. Verificar se api.obter_dashboard_kpis existe
SELECT '4. FUNÇÃO API' as secao;
SELECT routine_name, routine_schema 
FROM information_schema.routines 
WHERE routine_name = 'obter_dashboard_kpis';

-- 5. Verificar se api.buscar_lentes existe
SELECT routine_name, routine_schema 
FROM information_schema.routines 
WHERE routine_name = 'buscar_lentes';

-- 6. Testar diretamente a tabela de lentes
SELECT '5. TESTE DIRETO LENTES' as secao;
SELECT COUNT(*) as total_lentes FROM lens_catalog.lentes;
SELECT id, familia, design, material, marca_id FROM lens_catalog.lentes LIMIT 5;

-- 7. Verificar se as funções API realmente existem
SELECT '6. VERIFICAR SCHEMA API' as secao;
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'api' 
ORDER BY routine_name;
