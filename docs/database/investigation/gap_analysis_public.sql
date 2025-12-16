-- ===============================================================
-- 🕵️ GAP ANALYSIS: PUBLIC SCHEMA VS SYSTEM REQUIREMENTS
-- ===============================================================

-- 1. VERIFICAR SE TEMOS DASHBOARD KPIS EM PUBLIC
-- Esperado: Uma view que traga totais gerais (Economia, Pedidos, etc)
SELECT 'v_dashboard_vouchers' as view_nome, * FROM public.v_dashboard_vouchers LIMIT 1;

| view_nome            | total_vouchers_gerados | valor_total_economia_gerada |
| -------------------- | ---------------------- | --------------------------- |
| v_dashboard_vouchers | 0                      | null                        |


-- 2. VERIFICAR SE TEMOS O RANKING GERAL DE LABS EM PUBLIC
-- Esperado: Lista de laboratórios com seus Scores (0-10) e Níveis (Gold, Silver)
SELECT 'vw_fornecedores_disponiveis' as view_nome, * FROM public.vw_fornecedores_disponiveis LIMIT 1;

| view_nome                   | laboratorio_id                       | nome                                     | tenant_id                            |
| --------------------------- | ------------------------------------ | ---------------------------------------- | ------------------------------------ |
| vw_fornecedores_disponiveis | 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Lab-15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | 229220bb-d480-4608-a07c-ae9ab5266caf |


-- 3. VERIFICAR DETALHES DE DECISÃO EM PUBLIC
-- Esperado: Ver as alternativas geradas para uma decisão
SELECT 'vw_ranking_opcoes' as view_nome, * FROM public.vw_ranking_opcoes LIMIT 1;

Success. No rows returned





-- 4. VERIFICAR SE EXISTE UMA VIEW DE "DECISÕES RECENTES"
-- Esperado: Histórico de decisões do cliente
SELECT 'decisoes_compra' as view_nome, * FROM public.decisoes_compra LIMIT 1;

Success. No rows returned





-- 5. CHECAR SE A "API" ESTÁ EXPOSTA OU SE PRECISAMOS DE WRAPPERS
-- Se o user diz que SÓ acessa public, funções RPC em 'api' podem ser um problema?
-- Vamos listar funções que estão no schema 'public'.
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_type = 'FUNCTION';
  

| routine_name                              |
| ----------------------------------------- |
| usuario_tem_permissao                     |
| update_updated_at_column                  |
| api_perfil_usuario                        |
| get_busca_stats                           |
| set_limit                                 |
| show_limit                                |
| show_trgm                                 |
| similarity                                |
| similarity_op                             |
| word_similarity                           |
| word_similarity_op                        |
| api_login_usuario                         |
| word_similarity_commutator_op             |
| similarity_dist                           |
| word_similarity_dist_op                   |
| word_similarity_dist_commutator_op        |
| gtrgm_in                                  |
| gtrgm_out                                 |
| gtrgm_consistent                          |
| gtrgm_distance                            |
| gtrgm_compress                            |
| gtrgm_decompress                          |
| gtrgm_penalty                             |
| gtrgm_picksplit                           |
| gtrgm_union                               |
| gtrgm_same                                |
| gin_extract_value_trgm                    |
| gin_extract_query_trgm                    |
| gin_trgm_consistent                       |
| gin_trgm_triconsistent                    |
| strict_word_similarity                    |
| strict_word_similarity_op                 |
| strict_word_similarity_commutator_op      |
| strict_word_similarity_dist_op            |
| api_validar_login                         |
| api_logout_usuario                        |
| api_trocar_senha                          |
| strict_word_similarity_dist_commutator_op |
| gtrgm_options                             |
| rpc_buscar_lente                          |
| rpc_rank_opcoes                           |

