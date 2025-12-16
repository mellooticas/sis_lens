-- Script para verificar se há dados no banco de dados

-- 1. Verificar laboratórios
SELECT 'LABORATÓRIOS' as tabela, COUNT(*) as total FROM suppliers.laboratorios;
SELECT * FROM suppliers.laboratorios LIMIT 3;

-- 2. Verificar lentes
SELECT 'LENTES' as tabela, COUNT(*) as total FROM lens_catalog.lentes;
SELECT id, familia, design, material FROM lens_catalog.lentes LIMIT 3;

-- 3. Verificar decisões
SELECT 'DECISÕES' as tabela, COUNT(*) as total FROM orders.decisoes_lentes;

-- 4. Verificar alternativas
SELECT 'ALTERNATIVAS' as tabela, COUNT(*) as total FROM orders.alternativas_cotacao;

-- 5. Verificar scores
SELECT 'SCORES' as tabela, COUNT(*) as total FROM scoring.scores_laboratorios;
SELECT * FROM scoring.scores_laboratorios LIMIT 3;

-- 6. Testar view pública de laboratórios
SELECT 'VIEW LABS' as teste, COUNT(*) as total FROM public.vw_laboratorios_completo;
SELECT * FROM public.vw_laboratorios_completo LIMIT 3;

-- 7. Testar função obter_dashboard_kpis
SELECT 'DASHBOARD KPIS' as teste;
SELECT public.obter_dashboard_kpis();

-- 8. Testar função listar_laboratorios
SELECT 'LISTAR LABS' as teste;
SELECT * FROM public.listar_laboratorios();
