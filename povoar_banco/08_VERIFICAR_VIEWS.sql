-- ============================================
-- VERIFICAR O QUE EXISTE NO BANCO
-- ============================================

-- 1. Verificar VIEWS no schema public
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
  AND table_type = 'VIEW'
ORDER BY table_name;

| table_schema | table_name               | table_type |
| ------------ | ------------------------ | ---------- |
| public       | vw_buscar_lentes         | VIEW       |
| public       | vw_comparar_fornecedores | VIEW       |
| public       | vw_filtros_disponiveis   | VIEW       |
| public       | vw_fornecedores          | VIEW       |
| public       | vw_grupos_genericos      | VIEW       |
| public       | vw_grupos_premium        | VIEW       |
| public       | vw_marcas                | VIEW       |
| public       | vw_stats_catalogo        | VIEW       |



-- 2. Verificar TODAS as tabelas/views no schema public
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_type, table_name;

| table_schema | table_name               | table_type |
| ------------ | ------------------------ | ---------- |
| public       | vw_buscar_lentes         | VIEW       |
| public       | vw_comparar_fornecedores | VIEW       |
| public       | vw_filtros_disponiveis   | VIEW       |
| public       | vw_fornecedores          | VIEW       |
| public       | vw_grupos_genericos      | VIEW       |
| public       | vw_grupos_premium        | VIEW       |
| public       | vw_marcas                | VIEW       |
| public       | vw_stats_catalogo        | VIEW       |



-- 3. Se as views estiverem em outro schema, procurar
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_name LIKE 'vw_%'
ORDER BY table_schema, table_name;


| table_schema | table_name               | table_type |
| ------------ | ------------------------ | ---------- |
| lens_catalog | vw_analise_markup        | VIEW       |
| lens_catalog | vw_historico_precos      | VIEW       |
| public       | vw_buscar_lentes         | VIEW       |
| public       | vw_comparar_fornecedores | VIEW       |
| public       | vw_filtros_disponiveis   | VIEW       |
| public       | vw_fornecedores          | VIEW       |
| public       | vw_grupos_genericos      | VIEW       |
| public       | vw_grupos_premium        | VIEW       |
| public       | vw_marcas                | VIEW       |
| public       | vw_stats_catalogo        | VIEW       |