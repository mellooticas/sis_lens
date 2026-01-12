-- ============================================================================
-- CONSULTAS PARA TESTAR NO SUPABASE DASHBOARD
-- Execute estas queries no SQL Editor do Supabase para verificar estrutura
-- ============================================================================

-- 1. VERIFICAR TODAS AS TABELAS E VIEWS NO SCHEMA PUBLIC
-- Execute primeiro para ver o que existe
SELECT 
    table_name,
    table_type,
    CASE 
        WHEN table_type = 'BASE TABLE' THEN '🗂️  Tabela'
        WHEN table_type = 'VIEW' THEN '👁️  View'
        ELSE table_type 
    END as tipo
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_type, table_name;

| table_name               | table_type | tipo        |
| ------------------------ | ---------- | ----------- |
| consultas_lens_log       | BASE TABLE | 🗂️  Tabela |
| controle_vouchers_mensal | BASE TABLE | 🗂️  Tabela |
| ranking_vouchers         | BASE TABLE | 🗂️  Tabela |
| sistema_config_bestlens  | BASE TABLE | 🗂️  Tabela |
| usuarios                 | BASE TABLE | 🗂️  Tabela |
| vouchers_desconto        | BASE TABLE | 🗂️  Tabela |
| v_configuracoes_sistema  | VIEW       | 👁️  View   |
| v_dashboard_vouchers     | VIEW       | 👁️  View   |
| v_historico_consultas    | VIEW       | 👁️  View   |
| v_ranking_economia       | VIEW       | 👁️  View   |
| v_user_profile           | VIEW       | 👁️  View   |
| v_vouchers_disponiveis   | VIEW       | 👁️  View   |

-- ============================================================================

-- 2. LISTAR COLUNAS DAS VIEWS PRINCIPAIS QUE O BACKEND ESPERA
-- Execute para ver a estrutura de cada view

-- View: vw_lentes_catalogo
SELECT 
    'vw_lentes_catalogo' as view_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'vw_lentes_catalogo'
ORDER BY ordinal_position;

nada

-- ============================================================================

-- View: vw_fornecedores  
SELECT 
    'vw_fornecedores' as view_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'vw_fornecedores'
ORDER BY ordinal_position;


nada
-- ============================================================================

-- 3. VERIFICAR PERMISSÕES ATUAIS (RLS)
-- Execute para ver Row Level Security
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_habilitado,
    hasrls as tem_politicas
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

ERROR:  42703: column "hasrls" does not exist
LINE 5:     hasrls as tem_politicas
            ^
HINT:  Perhaps you meant to reference the column "pg_tables.hasrules".
Note: A limit of 100 was applied to your query. If this was the cause of a syntax error, try selecting "No limit" instead and re-run the query.

-- ============================================================================

-- 4. LISTAR FUNÇÕES/RPCs DISPONÍVEIS
-- Execute para ver as funções que o backend usa
SELECT 
    routine_name as nome_funcao,
    routine_type as tipo,
    specific_name
FROM information_schema.routines 
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
ORDER BY routine_name;


| nome_funcao                     | tipo     | specific_name                         |
| ------------------------------- | -------- | ------------------------------------- |
| api_dashboard_controle_vouchers | FUNCTION | api_dashboard_controle_vouchers_19847 |
| api_dashboard_executivo         | FUNCTION | api_dashboard_executivo_19903         |
| api_frontend_gerar_voucher      | FUNCTION | api_frontend_gerar_voucher_19904      |
| api_gerar_voucher_controlado    | FUNCTION | api_gerar_voucher_controlado_19845    |
| api_listar_vouchers             | FUNCTION | api_listar_vouchers_19902             |
| api_login_usuario               | FUNCTION | api_login_usuario_19900               |
| api_logout_usuario              | FUNCTION | api_logout_usuario_19957              |
| api_perfil_usuario              | FUNCTION | api_perfil_usuario_19901              |
| api_trocar_senha                | FUNCTION | api_trocar_senha_19958                |
| api_validar_login               | FUNCTION | api_validar_login_19956               |
| gerar_codigo_voucher            | FUNCTION | gerar_codigo_voucher_19730            |
| update_updated_at_column        | FUNCTION | update_updated_at_column_19732        |
| usuario_tem_permissao           | FUNCTION | usuario_tem_permissao_19731           |
| verificar_limites_voucher       | FUNCTION | verificar_limites_voucher_19844       |


-- ============================================================================

-- 5. TESTE DE ACESSO BÁSICO AS VIEWS
-- Execute cada uma separadamente para testar acesso

-- Teste vw_lentes_catalogo
SELECT COUNT(*) as total_lentes FROM vw_lentes_catalogo LIMIT 1;

ERROR:  42P01: relation "vw_lentes_catalogo" does not exist
LINE 1: SELECT COUNT(*) as total_lentes FROM vw_lentes_catalogo LIMIT 1;
                                             ^

-- Teste vw_fornecedores
SELECT COUNT(*) as total_fornecedores FROM vw_fornecedores LIMIT 1;


ERROR:  42P01: relation "vw_fornecedores" does not exist
LINE 1: SELECT COUNT(*) as total_fornecedores FROM vw_fornecedores LIMIT 1;
                                                   ^
-- Teste decisoes_compra
SELECT COUNT(*) as total_decisoes FROM decisoes_compra LIMIT 1;


ERROR:  42P01: relation "decisoes_compra" does not exist
LINE 1: SELECT COUNT(*) as total_decisoes FROM decisoes_compra LIMIT 1;
                                               ^
-- Teste produtos_laboratorio
SELECT COUNT(*) as total_produtos FROM produtos_laboratorio LIMIT 1;

ERROR:  42P01: relation "produtos_laboratorio" does not exist
LINE 1: SELECT COUNT(*) as total_produtos FROM produtos_laboratorio LIMIT 1;
                                               ^

-- ============================================================================

-- 6. VERIFICAR GRANTS/PERMISSÕES PARA ANON
-- Execute para ver permissões da role anônima
SELECT 
    table_schema,
    table_name,
    privilege_type,
    grantee
FROM information_schema.role_table_grants 
WHERE grantee = 'anon' 
  AND table_schema = 'public'
ORDER BY table_name, privilege_type;


| table_schema | table_name               | privilege_type | grantee |
| ------------ | ------------------------ | -------------- | ------- |
| public       | consultas_lens_log       | DELETE         | anon    |
| public       | consultas_lens_log       | INSERT         | anon    |
| public       | consultas_lens_log       | REFERENCES     | anon    |
| public       | consultas_lens_log       | SELECT         | anon    |
| public       | consultas_lens_log       | TRIGGER        | anon    |
| public       | consultas_lens_log       | TRUNCATE       | anon    |
| public       | consultas_lens_log       | UPDATE         | anon    |
| public       | controle_vouchers_mensal | DELETE         | anon    |
| public       | controle_vouchers_mensal | INSERT         | anon    |
| public       | controle_vouchers_mensal | REFERENCES     | anon    |
| public       | controle_vouchers_mensal | SELECT         | anon    |
| public       | controle_vouchers_mensal | TRIGGER        | anon    |
| public       | controle_vouchers_mensal | TRUNCATE       | anon    |
| public       | controle_vouchers_mensal | UPDATE         | anon    |
| public       | ranking_vouchers         | DELETE         | anon    |
| public       | ranking_vouchers         | INSERT         | anon    |
| public       | ranking_vouchers         | REFERENCES     | anon    |
| public       | ranking_vouchers         | SELECT         | anon    |
| public       | ranking_vouchers         | TRIGGER        | anon    |
| public       | ranking_vouchers         | TRUNCATE       | anon    |
| public       | ranking_vouchers         | UPDATE         | anon    |
| public       | sistema_config_bestlens  | DELETE         | anon    |
| public       | sistema_config_bestlens  | INSERT         | anon    |
| public       | sistema_config_bestlens  | REFERENCES     | anon    |
| public       | sistema_config_bestlens  | SELECT         | anon    |
| public       | sistema_config_bestlens  | TRIGGER        | anon    |
| public       | sistema_config_bestlens  | TRUNCATE       | anon    |
| public       | sistema_config_bestlens  | UPDATE         | anon    |
| public       | usuarios                 | DELETE         | anon    |
| public       | usuarios                 | INSERT         | anon    |
| public       | usuarios                 | REFERENCES     | anon    |
| public       | usuarios                 | SELECT         | anon    |
| public       | usuarios                 | TRIGGER        | anon    |
| public       | usuarios                 | TRUNCATE       | anon    |
| public       | usuarios                 | UPDATE         | anon    |
| public       | v_configuracoes_sistema  | DELETE         | anon    |
| public       | v_configuracoes_sistema  | INSERT         | anon    |
| public       | v_configuracoes_sistema  | REFERENCES     | anon    |
| public       | v_configuracoes_sistema  | SELECT         | anon    |
| public       | v_configuracoes_sistema  | TRIGGER        | anon    |
| public       | v_configuracoes_sistema  | TRUNCATE       | anon    |
| public       | v_configuracoes_sistema  | UPDATE         | anon    |
| public       | v_dashboard_vouchers     | DELETE         | anon    |
| public       | v_dashboard_vouchers     | INSERT         | anon    |
| public       | v_dashboard_vouchers     | REFERENCES     | anon    |
| public       | v_dashboard_vouchers     | SELECT         | anon    |
| public       | v_dashboard_vouchers     | TRIGGER        | anon    |
| public       | v_dashboard_vouchers     | TRUNCATE       | anon    |
| public       | v_dashboard_vouchers     | UPDATE         | anon    |
| public       | v_historico_consultas    | DELETE         | anon    |
| public       | v_historico_consultas    | INSERT         | anon    |
| public       | v_historico_consultas    | REFERENCES     | anon    |
| public       | v_historico_consultas    | SELECT         | anon    |
| public       | v_historico_consultas    | TRIGGER        | anon    |
| public       | v_historico_consultas    | TRUNCATE       | anon    |
| public       | v_historico_consultas    | UPDATE         | anon    |
| public       | v_ranking_economia       | DELETE         | anon    |
| public       | v_ranking_economia       | INSERT         | anon    |
| public       | v_ranking_economia       | REFERENCES     | anon    |
| public       | v_ranking_economia       | SELECT         | anon    |
| public       | v_ranking_economia       | TRIGGER        | anon    |
| public       | v_ranking_economia       | TRUNCATE       | anon    |
| public       | v_ranking_economia       | UPDATE         | anon    |
| public       | v_user_profile           | DELETE         | anon    |
| public       | v_user_profile           | INSERT         | anon    |
| public       | v_user_profile           | REFERENCES     | anon    |
| public       | v_user_profile           | SELECT         | anon    |
| public       | v_user_profile           | TRIGGER        | anon    |
| public       | v_user_profile           | TRUNCATE       | anon    |
| public       | v_user_profile           | UPDATE         | anon    |
| public       | v_vouchers_disponiveis   | DELETE         | anon    |
| public       | v_vouchers_disponiveis   | INSERT         | anon    |
| public       | v_vouchers_disponiveis   | REFERENCES     | anon    |
| public       | v_vouchers_disponiveis   | SELECT         | anon    |
| public       | v_vouchers_disponiveis   | TRIGGER        | anon    |
| public       | v_vouchers_disponiveis   | TRUNCATE       | anon    |
| public       | v_vouchers_disponiveis   | UPDATE         | anon    |
| public       | vouchers_desconto        | DELETE         | anon    |
| public       | vouchers_desconto        | INSERT         | anon    |
| public       | vouchers_desconto        | REFERENCES     | anon    |
| public       | vouchers_desconto        | SELECT         | anon    |
| public       | vouchers_desconto        | TRIGGER        | anon    |
| public       | vouchers_desconto        | TRUNCATE       | anon    |
| public       | vouchers_desconto        | UPDATE         | anon    |

-- ============================================================================

-- 7. CRIAÇÃO DOS GRANTS SE NECESSÁRIO
-- Execute APENAS se não houver permissões para anon

-- Grants para tabelas principais
GRANT SELECT ON public.decisoes_compra TO anon;
GRANT SELECT ON public.produtos_laboratorio TO anon;
GRANT SELECT ON public.lentes TO anon;
GRANT SELECT ON public.laboratorios TO anon;
GRANT SELECT ON public.marcas TO anon;

ERROR:  42P01: relation "public.decisoes_compra" does not exist




-- Grants para views
GRANT SELECT ON public.vw_lentes_catalogo TO anon;
GRANT SELECT ON public.vw_fornecedores TO anon;

-- Grants para funções/RPCs
GRANT EXECUTE ON FUNCTION public.rpc_buscar_lente TO anon;
GRANT EXECUTE ON FUNCTION public.rpc_rank_opcoes TO anon;
GRANT EXECUTE ON FUNCTION public.rpc_confirmar_decisao TO anon;

-- ============================================================================

-- 8. DESABILITAR RLS TEMPORARIAMENTE (SE NECESSÁRIO)
-- Execute APENAS se RLS estiver bloqueando acesso

-- Para tabelas principais
ALTER TABLE public.decisoes_compra DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos_laboratorio DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.lentes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.laboratorios DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.marcas DISABLE ROW LEVEL SECURITY;

-- ============================================================================

-- 9. TESTE FINAL - QUERIES QUE O BACKEND FAZ
-- Execute para simular o que o DatabaseClient faz

-- Simular LensCatalogService.listarLentes()
SELECT * FROM vw_lentes_catalogo LIMIT 5;

-- Simular SuppliersService.listarLaboratorios()
SELECT * FROM vw_fornecedores LIMIT 5;

-- Simular OrdersService.listarDecisoes()
SELECT * FROM decisoes_compra LIMIT 5;

-- Simular busca de lentes (se RPC existir)
SELECT rpc_buscar_lente('varilux', 3);

-- ============================================================================
-- INSTRUÇÕES:
-- 1. Execute as queries na ordem numerada
-- 2. Se houver erro de permissão, execute os GRANTs (seção 7)
-- 3. Se RLS estiver bloqueando, execute seção 8
-- 4. Teste final com seção 9
-- ============================================================================