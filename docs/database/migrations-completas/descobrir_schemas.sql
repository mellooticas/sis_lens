-- ============================================================================
-- DESCOBERTA COMPLETA: TODOS OS SCHEMAS E ESTRUTURAS
-- ============================================================================

-- 1. LISTAR TODOS OS SCHEMAS DISPONÍVEIS
SELECT schema_name, schema_owner 
FROM information_schema.schemata 
WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
ORDER BY schema_name;


| schema_name      | schema_owner      |
| ---------------- | ----------------- |
| analytics        | postgres          |
| api              | postgres          |
| auth             | supabase_admin    |
| commercial       | postgres          |
| extensions       | postgres          |
| graphql          | supabase_admin    |
| graphql_public   | supabase_admin    |
| lens_catalog     | postgres          |
| logistics        | postgres          |
| meta_system      | postgres          |
| orders           | postgres          |
| pg_temp_1        | supabase_admin    |
| pg_temp_11       | supabase_admin    |
| pg_temp_13       | supabase_admin    |
| pg_temp_14       | supabase_admin    |
| pg_temp_15       | supabase_admin    |
| pg_temp_16       | supabase_admin    |
| pg_temp_18       | supabase_admin    |
| pg_temp_19       | supabase_admin    |
| pg_temp_2        | supabase_admin    |
| pg_temp_22       | supabase_admin    |
| pg_temp_25       | supabase_admin    |
| pg_temp_26       | supabase_admin    |
| pg_temp_28       | supabase_admin    |
| pg_temp_29       | supabase_admin    |
| pg_temp_30       | supabase_admin    |
| pg_temp_32       | supabase_admin    |
| pg_temp_34       | supabase_admin    |
| pg_temp_36       | supabase_admin    |
| pg_temp_37       | supabase_admin    |
| pg_temp_39       | supabase_admin    |
| pg_temp_42       | supabase_admin    |
| pg_temp_44       | supabase_admin    |
| pg_temp_47       | supabase_admin    |
| pg_temp_48       | supabase_admin    |
| pg_temp_49       | supabase_admin    |
| pg_temp_50       | supabase_admin    |
| pg_temp_51       | supabase_admin    |
| pg_temp_52       | supabase_admin    |
| pg_temp_54       | supabase_admin    |
| pg_temp_57       | supabase_admin    |
| pg_temp_59       | supabase_admin    |
| pg_temp_6        | supabase_admin    |
| pg_temp_7        | supabase_admin    |
| pg_temp_8        | supabase_admin    |
| pg_temp_9        | supabase_admin    |
| pg_toast_temp_1  | supabase_admin    |
| pg_toast_temp_11 | supabase_admin    |
| pg_toast_temp_13 | supabase_admin    |
| pg_toast_temp_14 | supabase_admin    |
| pg_toast_temp_15 | supabase_admin    |
| pg_toast_temp_16 | supabase_admin    |
| pg_toast_temp_18 | supabase_admin    |
| pg_toast_temp_19 | supabase_admin    |
| pg_toast_temp_2  | supabase_admin    |
| pg_toast_temp_22 | supabase_admin    |
| pg_toast_temp_25 | supabase_admin    |
| pg_toast_temp_26 | supabase_admin    |
| pg_toast_temp_28 | supabase_admin    |
| pg_toast_temp_29 | supabase_admin    |
| pg_toast_temp_30 | supabase_admin    |
| pg_toast_temp_32 | supabase_admin    |
| pg_toast_temp_34 | supabase_admin    |
| pg_toast_temp_36 | supabase_admin    |
| pg_toast_temp_37 | supabase_admin    |
| pg_toast_temp_39 | supabase_admin    |
| pg_toast_temp_42 | supabase_admin    |
| pg_toast_temp_44 | supabase_admin    |
| pg_toast_temp_47 | supabase_admin    |
| pg_toast_temp_48 | supabase_admin    |
| pg_toast_temp_49 | supabase_admin    |
| pg_toast_temp_50 | supabase_admin    |
| pg_toast_temp_51 | supabase_admin    |
| pg_toast_temp_52 | supabase_admin    |
| pg_toast_temp_54 | supabase_admin    |
| pg_toast_temp_57 | supabase_admin    |
| pg_toast_temp_59 | supabase_admin    |
| pg_toast_temp_6  | supabase_admin    |
| pg_toast_temp_7  | supabase_admin    |
| pg_toast_temp_8  | supabase_admin    |
| pg_toast_temp_9  | supabase_admin    |
| pgbouncer        | pgbouncer         |
| public           | pg_database_owner |
| public_api       | postgres          |
| realtime         | supabase_admin    |
| scoring          | postgres          |
| storage          | supabase_admin    |
| suppliers        | postgres          |
| vault            | supabase_admin    |



-- ============================================================================

-- 2. LISTAR TABELAS EM TODOS OS SCHEMAS (NÃO SÓ PUBLIC)
SELECT 
    table_schema as schema,
    table_name,
    table_type,
    CASE 
        WHEN table_type = 'BASE TABLE' THEN '🗂️  Tabela'
        WHEN table_type = 'VIEW' THEN '👁️  View'
        ELSE table_type 
    END as tipo
FROM information_schema.tables 
WHERE table_schema NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
ORDER BY table_schema, table_type, table_name;


| schema       | table_name                 | table_type | tipo        |
| ------------ | -------------------------- | ---------- | ----------- |
| analytics    | alertas_analytics          | BASE TABLE | 🗂️  Tabela |
| analytics    | execucoes_relatorios       | BASE TABLE | 🗂️  Tabela |
| analytics    | metricas_kpi               | BASE TABLE | 🗂️  Tabela |
| analytics    | relatorios_configuracao    | BASE TABLE | 🗂️  Tabela |
| analytics    | valores_kpi                | BASE TABLE | 🗂️  Tabela |
| auth         | audit_log_entries          | BASE TABLE | 🗂️  Tabela |
| auth         | flow_state                 | BASE TABLE | 🗂️  Tabela |
| auth         | identities                 | BASE TABLE | 🗂️  Tabela |
| auth         | instances                  | BASE TABLE | 🗂️  Tabela |
| auth         | mfa_amr_claims             | BASE TABLE | 🗂️  Tabela |
| auth         | mfa_challenges             | BASE TABLE | 🗂️  Tabela |
| auth         | mfa_factors                | BASE TABLE | 🗂️  Tabela |
| auth         | oauth_clients              | BASE TABLE | 🗂️  Tabela |
| auth         | one_time_tokens            | BASE TABLE | 🗂️  Tabela |
| auth         | refresh_tokens             | BASE TABLE | 🗂️  Tabela |
| auth         | saml_providers             | BASE TABLE | 🗂️  Tabela |
| auth         | saml_relay_states          | BASE TABLE | 🗂️  Tabela |
| auth         | schema_migrations          | BASE TABLE | 🗂️  Tabela |
| auth         | sessions                   | BASE TABLE | 🗂️  Tabela |
| auth         | sso_domains                | BASE TABLE | 🗂️  Tabela |
| auth         | sso_providers              | BASE TABLE | 🗂️  Tabela |
| auth         | users                      | BASE TABLE | 🗂️  Tabela |
| commercial   | descontos                  | BASE TABLE | 🗂️  Tabela |
| commercial   | historico_precos           | BASE TABLE | 🗂️  Tabela |
| commercial   | precos_base                | BASE TABLE | 🗂️  Tabela |
| extensions   | pg_stat_statements         | VIEW       | 👁️  View   |
| extensions   | pg_stat_statements_info    | VIEW       | 👁️  View   |
| lens_catalog | lentes                     | BASE TABLE | 🗂️  Tabela |
| lens_catalog | marcas                     | BASE TABLE | 🗂️  Tabela |
| logistics    | historico_entregas         | BASE TABLE | 🗂️  Tabela |
| logistics    | tabela_prazos              | BASE TABLE | 🗂️  Tabela |
| logistics    | zonas_entrega              | BASE TABLE | 🗂️  Tabela |
| meta_system  | feature_flags              | BASE TABLE | 🗂️  Tabela |
| meta_system  | parametros_tenant          | BASE TABLE | 🗂️  Tabela |
| meta_system  | tenants                    | BASE TABLE | 🗂️  Tabela |
| orders       | alternativas_cotacao       | BASE TABLE | 🗂️  Tabela |
| orders       | criterios_decisao          | BASE TABLE | 🗂️  Tabela |
| orders       | decisoes_lentes            | BASE TABLE | 🗂️  Tabela |
| orders       | historico_status           | BASE TABLE | 🗂️  Tabela |
| public       | consultas_lens_log         | BASE TABLE | 🗂️  Tabela |
| public       | controle_vouchers_mensal   | BASE TABLE | 🗂️  Tabela |
| public       | ranking_vouchers           | BASE TABLE | 🗂️  Tabela |
| public       | sistema_config_bestlens    | BASE TABLE | 🗂️  Tabela |
| public       | usuarios                   | BASE TABLE | 🗂️  Tabela |
| public       | vouchers_desconto          | BASE TABLE | 🗂️  Tabela |
| public       | v_configuracoes_sistema    | VIEW       | 👁️  View   |
| public       | v_dashboard_vouchers       | VIEW       | 👁️  View   |
| public       | v_historico_consultas      | VIEW       | 👁️  View   |
| public       | v_ranking_economia         | VIEW       | 👁️  View   |
| public       | v_user_profile             | VIEW       | 👁️  View   |
| public       | v_vouchers_disponiveis     | VIEW       | 👁️  View   |
| realtime     | messages                   | BASE TABLE | 🗂️  Tabela |
| realtime     | schema_migrations          | BASE TABLE | 🗂️  Tabela |
| realtime     | subscription               | BASE TABLE | 🗂️  Tabela |
| scoring      | avaliacoes_laboratorios    | BASE TABLE | 🗂️  Tabela |
| scoring      | criterios_scoring          | BASE TABLE | 🗂️  Tabela |
| scoring      | historico_scores           | BASE TABLE | 🗂️  Tabela |
| scoring      | scores_laboratorios        | BASE TABLE | 🗂️  Tabela |
| storage      | buckets                    | BASE TABLE | 🗂️  Tabela |
| storage      | buckets_analytics          | BASE TABLE | 🗂️  Tabela |
| storage      | migrations                 | BASE TABLE | 🗂️  Tabela |
| storage      | objects                    | BASE TABLE | 🗂️  Tabela |
| storage      | prefixes                   | BASE TABLE | 🗂️  Tabela |
| storage      | s3_multipart_uploads       | BASE TABLE | 🗂️  Tabela |
| storage      | s3_multipart_uploads_parts | BASE TABLE | 🗂️  Tabela |
| suppliers    | historico_produtos         | BASE TABLE | 🗂️  Tabela |
| suppliers    | laboratorios               | BASE TABLE | 🗂️  Tabela |
| suppliers    | produtos_laboratorio       | BASE TABLE | 🗂️  Tabela |
| vault        | secrets                    | BASE TABLE | 🗂️  Tabela |
| vault        | decrypted_secrets          | VIEW       | 👁️  View   |



-- ============================================================================

-- 3. PROCURAR TABELAS/VIEWS RELACIONADAS A LENTES
SELECT 
    table_schema as schema,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
  AND (
    table_name ILIKE '%lente%' OR
    table_name ILIKE '%laboratorio%' OR  
    table_name ILIKE '%fornecedor%' OR
    table_name ILIKE '%decisao%' OR
    table_name ILIKE '%produto%' OR
    table_name ILIKE '%marca%' OR
    table_name ILIKE '%catalogo%'
  )
ORDER BY table_schema, table_name;


| schema       | table_name              | table_type |
| ------------ | ----------------------- | ---------- |
| lens_catalog | lentes                  | BASE TABLE |
| lens_catalog | marcas                  | BASE TABLE |
| orders       | criterios_decisao       | BASE TABLE |
| orders       | decisoes_lentes         | BASE TABLE |
| scoring      | avaliacoes_laboratorios | BASE TABLE |
| scoring      | scores_laboratorios     | BASE TABLE |
| suppliers    | historico_produtos      | BASE TABLE |
| suppliers    | laboratorios            | BASE TABLE |
| suppliers    | produtos_laboratorio    | BASE TABLE |


-- ============================================================================

-- 4. LISTAR FUNCTIONS/RPCs EM TODOS OS SCHEMAS
SELECT 
    routine_schema as schema,
    routine_name as nome_funcao,
    routine_type as tipo
FROM information_schema.routines 
WHERE routine_schema NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
  AND routine_type = 'FUNCTION'
ORDER BY routine_schema, routine_name;

| schema         | nome_funcao                     | tipo     |
| -------------- | ------------------------------- | -------- |
| api            | buscar_lentes                   | FUNCTION |
| api            | criar_decisao_lente             | FUNCTION |
| api            | listar_laboratorios             | FUNCTION |
| api            | obter_dashboard_kpis            | FUNCTION |
| api            | obter_decisao                   | FUNCTION |
| api            | obter_laboratorio               | FUNCTION |
| api            | obter_lente                     | FUNCTION |
| auth           | email                           | FUNCTION |
| auth           | jwt                             | FUNCTION |
| auth           | role                            | FUNCTION |
| auth           | uid                             | FUNCTION |
| commercial     | log_preco_alteracao             | FUNCTION |
| extensions     | armor                           | FUNCTION |
| extensions     | armor                           | FUNCTION |
| extensions     | crypt                           | FUNCTION |
| extensions     | dearmor                         | FUNCTION |
| extensions     | decrypt                         | FUNCTION |
| extensions     | decrypt_iv                      | FUNCTION |
| extensions     | digest                          | FUNCTION |
| extensions     | digest                          | FUNCTION |
| extensions     | encrypt                         | FUNCTION |
| extensions     | encrypt_iv                      | FUNCTION |
| extensions     | gen_random_bytes                | FUNCTION |
| extensions     | gen_random_uuid                 | FUNCTION |
| extensions     | gen_salt                        | FUNCTION |
| extensions     | gen_salt                        | FUNCTION |
| extensions     | grant_pg_cron_access            | FUNCTION |
| extensions     | grant_pg_graphql_access         | FUNCTION |
| extensions     | grant_pg_net_access             | FUNCTION |
| extensions     | hmac                            | FUNCTION |
| extensions     | hmac                            | FUNCTION |
| extensions     | pg_stat_statements              | FUNCTION |
| extensions     | pg_stat_statements_info         | FUNCTION |
| extensions     | pg_stat_statements_reset        | FUNCTION |
| extensions     | pgp_armor_headers               | FUNCTION |
| extensions     | pgp_key_id                      | FUNCTION |
| extensions     | pgp_pub_decrypt                 | FUNCTION |
| extensions     | pgp_pub_decrypt                 | FUNCTION |
| extensions     | pgp_pub_decrypt                 | FUNCTION |
| extensions     | pgp_pub_decrypt_bytea           | FUNCTION |
| extensions     | pgp_pub_decrypt_bytea           | FUNCTION |
| extensions     | pgp_pub_decrypt_bytea           | FUNCTION |
| extensions     | pgp_pub_encrypt                 | FUNCTION |
| extensions     | pgp_pub_encrypt                 | FUNCTION |
| extensions     | pgp_pub_encrypt_bytea           | FUNCTION |
| extensions     | pgp_pub_encrypt_bytea           | FUNCTION |
| extensions     | pgp_sym_decrypt                 | FUNCTION |
| extensions     | pgp_sym_decrypt                 | FUNCTION |
| extensions     | pgp_sym_decrypt_bytea           | FUNCTION |
| extensions     | pgp_sym_decrypt_bytea           | FUNCTION |
| extensions     | pgp_sym_encrypt                 | FUNCTION |
| extensions     | pgp_sym_encrypt                 | FUNCTION |
| extensions     | pgp_sym_encrypt_bytea           | FUNCTION |
| extensions     | pgp_sym_encrypt_bytea           | FUNCTION |
| extensions     | pgrst_ddl_watch                 | FUNCTION |
| extensions     | pgrst_drop_watch                | FUNCTION |
| extensions     | set_graphql_placeholder         | FUNCTION |
| extensions     | uuid_generate_v1                | FUNCTION |
| extensions     | uuid_generate_v1mc              | FUNCTION |
| extensions     | uuid_generate_v3                | FUNCTION |
| extensions     | uuid_generate_v4                | FUNCTION |
| extensions     | uuid_generate_v5                | FUNCTION |
| extensions     | uuid_nil                        | FUNCTION |
| extensions     | uuid_ns_dns                     | FUNCTION |
| extensions     | uuid_ns_oid                     | FUNCTION |
| extensions     | uuid_ns_url                     | FUNCTION |
| extensions     | uuid_ns_x500                    | FUNCTION |
| graphql        | _internal_resolve               | FUNCTION |
| graphql        | comment_directive               | FUNCTION |
| graphql        | exception                       | FUNCTION |
| graphql        | get_schema_version              | FUNCTION |
| graphql        | increment_schema_version        | FUNCTION |
| graphql        | resolve                         | FUNCTION |
| graphql_public | graphql                         | FUNCTION |
| meta_system    | current_tenant_id               | FUNCTION |
| meta_system    | update_updated_at_column        | FUNCTION |
| pgbouncer      | get_auth                        | FUNCTION |
| public         | api_dashboard_controle_vouchers | FUNCTION |
| public         | api_dashboard_executivo         | FUNCTION |
| public         | api_frontend_gerar_voucher      | FUNCTION |
| public         | api_gerar_voucher_controlado    | FUNCTION |
| public         | api_listar_vouchers             | FUNCTION |
| public         | api_login_usuario               | FUNCTION |
| public         | api_logout_usuario              | FUNCTION |
| public         | api_perfil_usuario              | FUNCTION |
| public         | api_trocar_senha                | FUNCTION |
| public         | api_validar_login               | FUNCTION |
| public         | gerar_codigo_voucher            | FUNCTION |
| public         | update_updated_at_column        | FUNCTION |
| public         | usuario_tem_permissao           | FUNCTION |
| public         | verificar_limites_voucher       | FUNCTION |
| realtime       | apply_rls                       | FUNCTION |
| realtime       | broadcast_changes               | FUNCTION |
| realtime       | build_prepared_statement_sql    | FUNCTION |
| realtime       | cast                            | FUNCTION |
| realtime       | check_equality_op               | FUNCTION |
| realtime       | is_visible_through_filters      | FUNCTION |
| realtime       | list_changes                    | FUNCTION |
| realtime       | quote_wal2json                  | FUNCTION |
| realtime       | send                            | FUNCTION |

-- ============================================================================

-- 5. PROCURAR FUNCTIONS RELACIONADAS A LENTES
SELECT 
    routine_schema as schema,
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_schema NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
  AND routine_type = 'FUNCTION'
  AND (
    routine_name ILIKE '%lente%' OR
    routine_name ILIKE '%buscar%' OR
    routine_name ILIKE '%rank%' OR
    routine_name ILIKE '%decisao%' OR
    routine_name ILIKE '%catalogo%'
  )
ORDER BY routine_schema, routine_name;

| schema | routine_name        | routine_type |
| ------ | ------------------- | ------------ |
| api    | buscar_lentes       | FUNCTION     |
| api    | criar_decisao_lente | FUNCTION     |
| api    | obter_decisao       | FUNCTION     |
| api    | obter_lente         | FUNCTION     |

-- ============================================================================

-- 6. VERIFICAR ESTRUTURA DO SCHEMA LENS (SE EXISTIR)
-- Execute apenas se o schema 'lens' aparecer nos resultados acima
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'lens'
ORDER BY table_type, table_name;

nada

-- ============================================================================

-- 7. VERIFICAR ESTRUTURA DO SCHEMA BESTLENS (SE EXISTIR)  
-- Execute apenas se o schema 'bestlens' aparecer nos resultados acima
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'bestlens'
ORDER BY table_type, table_name;

nada

-- ============================================================================

-- 8. VERIFICAR ESTRUTURA DO SCHEMA LENTES (SE EXISTIR)
-- Execute apenas se o schema 'lentes' aparecer nos resultados acima
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'lentes'
ORDER BY table_type, table_name;
nada

-- ============================================================================

-- 9. VERIFICAR GRANTS/PERMISSÕES PARA ANON EM OUTROS SCHEMAS
SELECT 
    table_schema,
    table_name,
    privilege_type,
    grantee
FROM information_schema.role_table_grants 
WHERE grantee = 'anon' 
  AND table_schema NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
ORDER BY table_schema, table_name, privilege_type;


| table_schema | table_name                 | privilege_type | grantee |
| ------------ | -------------------------- | -------------- | ------- |
| public       | consultas_lens_log         | DELETE         | anon    |
| public       | consultas_lens_log         | INSERT         | anon    |
| public       | consultas_lens_log         | REFERENCES     | anon    |
| public       | consultas_lens_log         | SELECT         | anon    |
| public       | consultas_lens_log         | TRIGGER        | anon    |
| public       | consultas_lens_log         | TRUNCATE       | anon    |
| public       | consultas_lens_log         | UPDATE         | anon    |
| public       | controle_vouchers_mensal   | DELETE         | anon    |
| public       | controle_vouchers_mensal   | INSERT         | anon    |
| public       | controle_vouchers_mensal   | REFERENCES     | anon    |
| public       | controle_vouchers_mensal   | SELECT         | anon    |
| public       | controle_vouchers_mensal   | TRIGGER        | anon    |
| public       | controle_vouchers_mensal   | TRUNCATE       | anon    |
| public       | controle_vouchers_mensal   | UPDATE         | anon    |
| public       | ranking_vouchers           | DELETE         | anon    |
| public       | ranking_vouchers           | INSERT         | anon    |
| public       | ranking_vouchers           | REFERENCES     | anon    |
| public       | ranking_vouchers           | SELECT         | anon    |
| public       | ranking_vouchers           | TRIGGER        | anon    |
| public       | ranking_vouchers           | TRUNCATE       | anon    |
| public       | ranking_vouchers           | UPDATE         | anon    |
| public       | sistema_config_bestlens    | DELETE         | anon    |
| public       | sistema_config_bestlens    | INSERT         | anon    |
| public       | sistema_config_bestlens    | REFERENCES     | anon    |
| public       | sistema_config_bestlens    | SELECT         | anon    |
| public       | sistema_config_bestlens    | TRIGGER        | anon    |
| public       | sistema_config_bestlens    | TRUNCATE       | anon    |
| public       | sistema_config_bestlens    | UPDATE         | anon    |
| public       | usuarios                   | DELETE         | anon    |
| public       | usuarios                   | INSERT         | anon    |
| public       | usuarios                   | REFERENCES     | anon    |
| public       | usuarios                   | SELECT         | anon    |
| public       | usuarios                   | TRIGGER        | anon    |
| public       | usuarios                   | TRUNCATE       | anon    |
| public       | usuarios                   | UPDATE         | anon    |
| public       | v_configuracoes_sistema    | DELETE         | anon    |
| public       | v_configuracoes_sistema    | INSERT         | anon    |
| public       | v_configuracoes_sistema    | REFERENCES     | anon    |
| public       | v_configuracoes_sistema    | SELECT         | anon    |
| public       | v_configuracoes_sistema    | TRIGGER        | anon    |
| public       | v_configuracoes_sistema    | TRUNCATE       | anon    |
| public       | v_configuracoes_sistema    | UPDATE         | anon    |
| public       | v_dashboard_vouchers       | DELETE         | anon    |
| public       | v_dashboard_vouchers       | INSERT         | anon    |
| public       | v_dashboard_vouchers       | REFERENCES     | anon    |
| public       | v_dashboard_vouchers       | SELECT         | anon    |
| public       | v_dashboard_vouchers       | TRIGGER        | anon    |
| public       | v_dashboard_vouchers       | TRUNCATE       | anon    |
| public       | v_dashboard_vouchers       | UPDATE         | anon    |
| public       | v_historico_consultas      | DELETE         | anon    |
| public       | v_historico_consultas      | INSERT         | anon    |
| public       | v_historico_consultas      | REFERENCES     | anon    |
| public       | v_historico_consultas      | SELECT         | anon    |
| public       | v_historico_consultas      | TRIGGER        | anon    |
| public       | v_historico_consultas      | TRUNCATE       | anon    |
| public       | v_historico_consultas      | UPDATE         | anon    |
| public       | v_ranking_economia         | DELETE         | anon    |
| public       | v_ranking_economia         | INSERT         | anon    |
| public       | v_ranking_economia         | REFERENCES     | anon    |
| public       | v_ranking_economia         | SELECT         | anon    |
| public       | v_ranking_economia         | TRIGGER        | anon    |
| public       | v_ranking_economia         | TRUNCATE       | anon    |
| public       | v_ranking_economia         | UPDATE         | anon    |
| public       | v_user_profile             | DELETE         | anon    |
| public       | v_user_profile             | INSERT         | anon    |
| public       | v_user_profile             | REFERENCES     | anon    |
| public       | v_user_profile             | SELECT         | anon    |
| public       | v_user_profile             | TRIGGER        | anon    |
| public       | v_user_profile             | TRUNCATE       | anon    |
| public       | v_user_profile             | UPDATE         | anon    |
| public       | v_vouchers_disponiveis     | DELETE         | anon    |
| public       | v_vouchers_disponiveis     | INSERT         | anon    |
| public       | v_vouchers_disponiveis     | REFERENCES     | anon    |
| public       | v_vouchers_disponiveis     | SELECT         | anon    |
| public       | v_vouchers_disponiveis     | TRIGGER        | anon    |
| public       | v_vouchers_disponiveis     | TRUNCATE       | anon    |
| public       | v_vouchers_disponiveis     | UPDATE         | anon    |
| public       | vouchers_desconto          | DELETE         | anon    |
| public       | vouchers_desconto          | INSERT         | anon    |
| public       | vouchers_desconto          | REFERENCES     | anon    |
| public       | vouchers_desconto          | SELECT         | anon    |
| public       | vouchers_desconto          | TRIGGER        | anon    |
| public       | vouchers_desconto          | TRUNCATE       | anon    |
| public       | vouchers_desconto          | UPDATE         | anon    |
| realtime     | messages                   | INSERT         | anon    |
| realtime     | messages                   | SELECT         | anon    |
| realtime     | messages                   | UPDATE         | anon    |
| realtime     | schema_migrations          | SELECT         | anon    |
| realtime     | subscription               | SELECT         | anon    |
| storage      | buckets                    | DELETE         | anon    |
| storage      | buckets                    | INSERT         | anon    |
| storage      | buckets                    | REFERENCES     | anon    |
| storage      | buckets                    | SELECT         | anon    |
| storage      | buckets                    | TRIGGER        | anon    |
| storage      | buckets                    | TRUNCATE       | anon    |
| storage      | buckets                    | UPDATE         | anon    |
| storage      | buckets_analytics          | DELETE         | anon    |
| storage      | buckets_analytics          | INSERT         | anon    |
| storage      | buckets_analytics          | REFERENCES     | anon    |
| storage      | buckets_analytics          | SELECT         | anon    |
| storage      | buckets_analytics          | TRIGGER        | anon    |
| storage      | buckets_analytics          | TRUNCATE       | anon    |
| storage      | buckets_analytics          | UPDATE         | anon    |
| storage      | objects                    | DELETE         | anon    |
| storage      | objects                    | INSERT         | anon    |
| storage      | objects                    | REFERENCES     | anon    |
| storage      | objects                    | SELECT         | anon    |
| storage      | objects                    | TRIGGER        | anon    |
| storage      | objects                    | TRUNCATE       | anon    |
| storage      | objects                    | UPDATE         | anon    |
| storage      | prefixes                   | DELETE         | anon    |
| storage      | prefixes                   | INSERT         | anon    |
| storage      | prefixes                   | REFERENCES     | anon    |
| storage      | prefixes                   | SELECT         | anon    |
| storage      | prefixes                   | TRIGGER        | anon    |
| storage      | prefixes                   | TRUNCATE       | anon    |
| storage      | prefixes                   | UPDATE         | anon    |
| storage      | s3_multipart_uploads       | SELECT         | anon    |
| storage      | s3_multipart_uploads_parts | SELECT         | anon    |

-- ============================================================================

-- 10. VERIFICAR SE PRECISAMOS CRIAR VIEWS EM PUBLIC
-- Esta query vai nos dizer o que está em outros schemas que precisamos expor

-- Se encontrarmos tabelas de lentes em outros schemas, execute:
-- GRANT USAGE ON SCHEMA nome_do_schema TO anon;
-- GRANT SELECT ON ALL TABLES IN SCHEMA nome_do_schema TO anon;

-- Depois criar views em public como:
-- CREATE OR REPLACE VIEW public.vw_lentes_catalogo AS 
-- SELECT * FROM outro_schema.lentes_com_marcas;

-- ============================================================================