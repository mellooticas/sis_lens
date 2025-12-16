-- TESTE RÁPIDO: Verificar se o problema é nas funções wrapper

-- 1. Testar acesso direto às tabelas
SELECT '=== TESTE DIRETO TABELAS ===' as titulo;

SELECT 'lens_catalog.lentes' as tabela, COUNT(*) as total FROM lens_catalog.lentes;

| tabela              | total |
| ------------------- | ----- |
| lens_catalog.lentes | 1411  |

SELECT 'suppliers.laboratorios' as tabela, COUNT(*) as total FROM suppliers.laboratorios;

| tabela                 | total |
| ---------------------- | ----- |
| suppliers.laboratorios | 11    |

SELECT 'scoring.scores_laboratorios' as tabela, COUNT(*) as total FROM scoring.scores_laboratorios;

| tabela                      | total |
| --------------------------- | ----- |
| scoring.scores_laboratorios | 0     |



-- 2. Verificar se schema 'api' existe
SELECT '=== VERIFICAR SCHEMA API ===' as titulo;
SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'api';

| schema_name |
| ----------- |
| api         |


-- 3. Listar funções no schema api
SELECT '=== FUNÇÕES NO SCHEMA API ===' as titulo;
SELECT routine_name, routine_schema 
FROM information_schema.routines 
WHERE routine_schema = 'api';

| routine_name         | routine_schema |
| -------------------- | -------------- |
| buscar_lentes        | api            |
| criar_decisao_lente  | api            |
| listar_laboratorios  | api            |
| obter_lente          | api            |
| obter_laboratorio    | api            |
| obter_decisao        | api            |
| obter_dashboard_kpis | api            |


-- 4. Testar view vw_laboratorios_completo
SELECT '=== TESTE VIEW LABORATORIOS ===' as titulo;
SELECT COUNT(*) as total FROM public.vw_laboratorios_completo;
SELECT * FROM public.vw_laboratorios_completo LIMIT 3;

| id                                   | nome                 | cnpj | contato_comercial                                                                                                                                                                                                                                                                                                                 | lead_time_padrao_dias | ativo | tenant_id                            | atende_regioes | criado_em                     | atualizado_em                 | score_geral | score_qualidade | score_preco | score_prazo | badge       |
| ------------------------------------ | -------------------- | ---- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- | ----- | ------------------------------------ | -------------- | ----------------------------- | ----------------------------- | ----------- | --------------- | ----------- | ----------- | ----------- |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Brascor              | null | {"site":null,"email":"vendas@brascorlab.com.br","telefone":"(11) 93047-3110","whatsapp":{"comercial":null,"financeiro":null,"atendimento":null},"observacoes":"aceita pedidos por email","representante":{"nome":"Shirley","contato":"+55 11 91421-1122"},"condicoes_pagamento":"30 dias"}                                        | 7                     | true  | 229220bb-d480-4608-a07c-ae9ab5266caf | ["SUDESTE"]    | 2025-04-30 19:58:38.358647+00 | 2025-12-16 16:16:09.312374+00 | null        | null            | null        | null        | QUALIFICADO |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Sygma                | null | {"site":"https://www.sygmalentes.com.br","email":"contato@sygmalentes.com.br","telefone":"(11) 3667-8803","whatsapp":{"comercial":"(11) 97657-4040","financeiro":"(11) 9657-9404","atendimento":"(11) 93768-9139"},"observacoes":null,"representante":{"nome":"Não informado","contato":"Paulo"},"condicoes_pagamento":"30 dias"} | 7                     | true  | 229220bb-d480-4608-a07c-ae9ab5266caf | ["SUDESTE"]    | 2025-05-28 16:57:43.38942+00  | 2025-12-16 16:16:09.312374+00 | null        | null            | null        | null        | QUALIFICADO |
| 1d0b088f-dcb1-4179-9a18-5d67ce86c4b6 | Sao Paulo Acessorios | null | {"site":null,"email":"contato@spacessorios.com.br","telefone":"(11) 99999-9999","whatsapp":{"comercial":null,"financeiro":null,"atendimento":null},"observacoes":"Fornecedor de produtos INFINITY","representante":{"nome":"Carlos","contato":"(11) 99999-9999"},"condicoes_pagamento":"30 dias"}                                 | 7                     | true  | 229220bb-d480-4608-a07c-ae9ab5266caf | ["SUDESTE"]    | 2025-05-07 16:53:15.990552+00 | 2025-12-16 16:16:09.312374+00 | null        | null            | null        | null        | QUALIFICADO |


-- 5. Verificar colunas da tabela laboratorios
SELECT '=== COLUNAS LABORATORIOS ===' as titulo;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'suppliers' AND table_name = 'laboratorios'
ORDER BY ordinal_position;

| column_name           | data_type                |
| --------------------- | ------------------------ |
| id                    | uuid                     |
| tenant_id             | uuid                     |
| nome_fantasia         | text                     |
| razao_social          | text                     |
| cnpj                  | text                     |
| contato_comercial     | jsonb                    |
| lead_time_padrao_dias | integer                  |
| atende_regioes        | ARRAY                    |
| ativo                 | boolean                  |
| criado_em             | timestamp with time zone |
| atualizado_em         | timestamp with time zone |

-- 6. Verificar se coluna 'criado_em' existe em decisoes_lentes
SELECT '=== COLUNAS DECISOES ===' as titulo;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'orders' AND table_name = 'decisoes_lentes'
ORDER BY ordinal_position;

| column_name               | data_type                |
| ------------------------- | ------------------------ |
| id                        | uuid                     |
| tenant_id                 | uuid                     |
| lente_recomendada_id      | uuid                     |
| laboratorio_escolhido_id  | uuid                     |
| criterio_usado            | USER-DEFINED             |
| preco_final               | numeric                  |
| prazo_estimado_dias       | integer                  |
| custo_frete               | numeric                  |
| score_atribuido           | numeric                  |
| motivo_decisao            | text                     |
| alternativas_consideradas | jsonb                    |
| status                    | USER-DEFINED             |
| decidido_por              | uuid                     |
| decidido_em               | timestamp with time zone |
| confirmado_em             | timestamp with time zone |
| entregue_em               | timestamp with time zone |
| observacoes               | text                     |


-- 7. Teste manual da função dashboard sem depender de api
SELECT '=== TESTE MANUAL KPIs ===' as titulo;
SELECT 
    (SELECT COUNT(*) FROM orders.decisoes_lentes) as total_decisoes,
    (SELECT COUNT(*) FROM suppliers.laboratorios WHERE ativo = true) as labs_ativos,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE disponivel = true) as lentes_disponiveis;
Error: Failed to run sql query: ERROR: 42703: column "disponivel" does not exist LINE 5: (SELECT COUNT(*) FROM lens_catalog.lentes WHERE disponivel = true) as lentes_disponiveis; ^



