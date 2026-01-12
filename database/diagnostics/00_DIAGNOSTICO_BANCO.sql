-- ============================================
-- DIAGNÓSTICO: Verificar estrutura do banco
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Verificar se os schemas existem
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name IN ('lens_catalog', 'pessoas', 'public')
ORDER BY schema_name;

-- 2. Verificar tabelas em lens_catalog
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'lens_catalog'
ORDER BY table_name;

-- 3. Verificar tabelas em pessoas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'pessoas'
ORDER BY table_name;

-- 4. Verificar views existentes em public
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public' 
  AND table_name LIKE 'vw_%'
ORDER BY table_name;

-- 5. Contar registros nas tabelas principais
SELECT 
    'lentes' as tabela,
    COUNT(*) as total
FROM lens_catalog.lentes
WHERE status = 'ativo'

UNION ALL

SELECT 
    'marcas' as tabela,
    COUNT(*) as total
FROM lens_catalog.marcas

UNION ALL

SELECT 
    'fornecedores' as tabela,
    COUNT(*) as total
FROM pessoas.fornecedores;
