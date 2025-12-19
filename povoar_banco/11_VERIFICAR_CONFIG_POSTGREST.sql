-- ============================================
-- 11_VERIFICAR_CONFIG_POSTGREST.sql
-- Verificar configuração do PostgREST
-- ============================================

-- Verificar qual schema o PostgREST está configurado para expor
SHOW db_schema;

-- Verificar permissões do role authenticator (usado pelo PostgREST)
SELECT 
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('anon', 'authenticated', 'authenticator')
  AND table_schema = 'public'
  AND table_name LIKE 'vw_%'
ORDER BY grantee, table_name;

| grantee       | table_schema | table_name               | privilege_type |
| ------------- | ------------ | ------------------------ | -------------- |
| anon          | public       | vw_buscar_lentes         | SELECT         |
| anon          | public       | vw_comparar_fornecedores | SELECT         |
| anon          | public       | vw_filtros_disponiveis   | SELECT         |
| anon          | public       | vw_fornecedores          | SELECT         |
| anon          | public       | vw_grupos_genericos      | SELECT         |
| anon          | public       | vw_grupos_premium        | SELECT         |
| anon          | public       | vw_marcas                | SELECT         |
| anon          | public       | vw_stats_catalogo        | SELECT         |
| authenticated | public       | vw_buscar_lentes         | SELECT         |
| authenticated | public       | vw_comparar_fornecedores | SELECT         |
| authenticated | public       | vw_filtros_disponiveis   | SELECT         |
| authenticated | public       | vw_fornecedores          | SELECT         |
| authenticated | public       | vw_grupos_genericos      | SELECT         |
| authenticated | public       | vw_grupos_premium        | SELECT         |
| authenticated | public       | vw_marcas                | SELECT         |
| authenticated | public       | vw_stats_catalogo        | SELECT         |



-- Verificar se o role anon existe e tem as permissões corretas
SELECT 
    r.rolname,
    r.rolsuper,
    r.rolinherit,
    r.rolcreaterole,
    r.rolcreatedb,
    r.rolcanlogin
FROM pg_roles r
WHERE r.rolname IN ('anon', 'authenticated', 'authenticator');

| rolname       | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin |
| ------------- | -------- | ---------- | ------------- | ----------- | ----------- |
| authenticated | false    | true       | false         | false       | false       |
| anon          | false    | true       | false         | false       | false       |
| authenticator | false    | false      | false         | false       | true        |
