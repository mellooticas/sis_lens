-- ============================================================================
-- INVESTIGAÇÃO: Dados para Nova Sidebar
-- Data: 2026-01-11
-- Objetivo: Verificar que dados já temos no banco para implementar 7 itens
-- ============================================================================

-- =============================================================================
-- 1. FORNECEDORES - "já temos os dados no banco e não trouxemos ainda"
-- =============================================================================

-- Query 1.1: Verificar estrutura da tabela fornecedores
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'core' 
  AND table_name = 'fornecedores'
ORDER BY ordinal_position;


| column_name         | data_type                | is_nullable |
| ------------------- | ------------------------ | ----------- |
| id                  | uuid                     | NO          |
| nome                | text                     | NO          |
| razao_social        | text                     | YES         |
| cnpj                | character varying        | YES         |
| cep_origem          | character varying        | YES         |
| cidade_origem       | text                     | YES         |
| estado_origem       | character varying        | YES         |
| prazo_visao_simples | integer                  | YES         |
| prazo_multifocal    | integer                  | YES         |
| prazo_surfacada     | integer                  | YES         |
| prazo_free_form     | integer                  | YES         |
| frete_config        | jsonb                    | YES         |
| desconto_volume     | jsonb                    | YES         |
| ativo               | boolean                  | NO          |
| created_at          | timestamp with time zone | NO          |
| updated_at          | timestamp with time zone | NO          |
| deleted_at          | timestamp with time zone | YES         |

-- Query 1.2: Contar fornecedores cadastrados
SELECT COUNT(*) as total_fornecedores
FROM core.fornecedores;

| total_fornecedores |
| ------------------ |
| 11                 |


-- Query 1.3A: Primeiro, descobrir onde está a tabela marcas
SELECT 
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_name = 'marcas';


| table_schema | table_name |
| ------------ | ---------- |
| lens_catalog | marcas     |

-- Query 1.3B: Listar fornecedores com suas lentes (sem marcas por enquanto)
SELECT 
    f.id,
    f.nome as fornecedor,
    f.ativo,
    COUNT(DISTINCT l.id) as total_lentes,
    COUNT(DISTINCT l.marca_id) as marcas_diferentes_usadas
FROM core.fornecedores f
LEFT JOIN lens_catalog.lentes l ON l.fornecedor_id = f.id AND l.ativo = true
GROUP BY f.id, f.nome, f.ativo
ORDER BY f.nome;

| id                                   | fornecedor             | ativo | total_lentes | marcas_diferentes_usadas |
| ------------------------------------ | ---------------------- | ----- | ------------ | ------------------------ |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Brascor                | true  | 58           | 2                        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | Braslentes             | true  | 0            | 0                        |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express                | true  | 84           | 4                        |
| e4a24408-3d58-4fc7-a096-cf7140f4f248 | Galeria Florencio lj11 | true  | 0            | 0                        |
| d90bebaf-e552-4cf0-a226-808c91bda73a | Kaizi Oculos Solares   | true  | 0            | 0                        |
| c50ea6eb-a420-4cf7-8aa2-68aaeb41ac95 | Navarro Oculos         | true  | 0            | 0                        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Polylux                | true  | 158          | 4                        |
| 1d0b088f-dcb1-4179-9a18-5d67ce86c4b6 | Sao Paulo Acessorios   | true  | 0            | 0                        |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | So Blocos              | true  | 1097         | 2                        |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | Style                  | true  | 0            | 0                        |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Sygma                  | true  | 14           | 1                        |


-- Query 1.4: Verificar campos disponíveis em fornecedores
SELECT *
FROM core.fornecedores
LIMIT 3;

| id                                   | nome                 | razao_social                    | cnpj | cep_origem | cidade_origem | estado_origem | prazo_visao_simples | prazo_multifocal | prazo_surfacada | prazo_free_form | frete_config                                                                                                                                                                                                                                                                                                                                                                | desconto_volume                                           | ativo | created_at                    | updated_at                    | deleted_at |
| ------------------------------------ | -------------------- | ------------------------------- | ---- | ---------- | ------------- | ------------- | ------------------- | ---------------- | --------------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- | ----- | ----------------------------- | ----------------------------- | ---------- |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Brascor              | Brascor Distribuidora de Lentes | null | null       | null          | null          | 7                   | 10               | 12              | 15              | {"tipo":"PAC","contato":{"email":"vendas@brascorlab.com.br","telefone":"(11) 93047-3110","observacoes":"aceita pedidos por email","representante":"Shirley","condicoes_pagamento":"30 dias","representante_contato":"+55 11 91421-1122"},"taxa_fixa":25,"valor_minimo":0,"frete_gratis_acima":500}                                                                          | {"5_unidades":0.03,"10_unidades":0.05,"20_unidades":0.08} | true  | 2025-12-19 22:06:29.405712+00 | 2025-12-19 22:06:29.405712+00 | null       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Sygma                | Sygma Lentes Laboratório Óptico | null | null       | null          | null          | 7                   | 10               | 12              | 15              | {"tipo":"PAC","contato":{"site":"https://www.sygmalentes.com.br","email":"contato@sygmalentes.com.br","telefone":"(11) 3667-8803","representante":"Paulo","whatsapp_comercial":"(11) 97657-4040","condicoes_pagamento":"30 dias","whatsapp_financeiro":"(11) 9657-9404","whatsapp_atendimento":"(11) 93768-9139"},"taxa_fixa":25,"valor_minimo":0,"frete_gratis_acima":500} | {"5_unidades":0.03,"10_unidades":0.05,"20_unidades":0.08} | true  | 2025-12-19 22:06:29.405712+00 | 2025-12-19 22:06:29.405712+00 | null       |
| 1d0b088f-dcb1-4179-9a18-5d67ce86c4b6 | Sao Paulo Acessorios | São Paulo Acessórios LTDA       | null | null       | null          | null          | 7                   | 10               | 12              | 15              | {"tipo":"PAC","contato":{"email":"contato@spacessorios.com.br","telefone":"(11) 99999-9999","observacoes":"Fornecedor de produtos INFINITY","representante":"Carlos","condicoes_pagamento":"30 dias","representante_contato":"(11) 99999-9999"},"taxa_fixa":25,"valor_minimo":0,"frete_gratis_acima":500}                                                                   | {"5_unidades":0.03,"10_unidades":0.05,"20_unidades":0.08} | true  | 2025-12-19 22:06:29.405712+00 | 2025-12-19 22:06:29.405712+00 | null       |

-- =============================================================================
-- 2. RANKING - "perfeito pode implementar para eu ver se faz sentido"
-- =============================================================================

-- Query 2.1: Top 10 grupos por preço médio (mais caros)
SELECT 
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    preco_medio,
    total_lentes,
    total_marcas,
    is_premium
FROM public.v_grupos_canonicos
ORDER BY preco_medio DESC
LIMIT 10;

| nome_grupo                                                                            | tipo_lente    | material | indice_refracao | preco_medio | total_lentes | total_marcas | is_premium |
| ------------------------------------------------------------------------------------- | ------------- | -------- | --------------- | ----------- | ------------ | ------------ | ---------- |
| Lente CR39 1.74 Multifocal +UV [-14.00/10.00 | -6.00/0.00 | 0.50/4.50]                | multifocal    | CR39     | 1.74            | 7676.74     | 6            | 1            | false      |
| Lente CR39 1.74 Visao Simples +UV [-14.00/10.00 | -8.00/0.00]                         | visao_simples | CR39     | 1.74            | 7650.67     | 9            | 1            | false      |
| Lente CR39 1.74 Multifocal +UV +BlueLight [-15.00/12.00 | -8.00/0.00 | 0.50/4.50]     | multifocal    | CR39     | 1.74            | 7559.42     | 3            | 1            | false      |
| Lente CR39 1.74 Multifocal +AR +UV [-14.00/10.00 | -6.00/0.00 | 0.50/4.50]            | multifocal    | CR39     | 1.74            | 7481.20     | 4            | 1            | false      |
| Lente CR39 1.74 Visao Simples +AR +UV [-14.00/10.00 | -8.00/0.00]                     | visao_simples | CR39     | 1.74            | 7455.13     | 6            | 1            | false      |
| Lente CR39 1.74 Multifocal +AR +UV +BlueLight [-15.00/12.00 | -8.00/0.00 | 0.50/4.50] | multifocal    | CR39     | 1.74            | 7363.88     | 2            | 1            | false      |
| Lente CR39 1.74 Multifocal +UV [-13.00/11.00 | -6.00/0.00]                            | multifocal    | CR39     | 1.74            | 7344.32     | 6            | 1            | false      |
| Lente CR39 1.74 Multifocal +UV [-15.00/12.00 | -8.00/0.00 | 0.50/4.50]                | multifocal    | CR39     | 1.74            | 7324.76     | 3            | 1            | false      |
| Lente CR39 1.74 Multifocal +UV [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]                | multifocal    | CR39     | 1.74            | 7314.99     | 12           | 1            | false      |
| Lente CR39 1.74 Multifocal +UV [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]                | multifocal    | CR39     | 1.74            | 7275.88     | 12           | 1            | false      |

-- Query 2.2: Top 10 grupos com mais lentes disponíveis
SELECT 
    nome_grupo,
    tipo_lente,
    material,
    total_lentes,
    total_marcas,
    preco_medio,
    is_premium
FROM public.v_grupos_canonicos
ORDER BY total_lentes DESC
LIMIT 10;

| nome_grupo                                                                                    | tipo_lente    | material      | total_lentes | total_marcas | preco_medio | is_premium |
| --------------------------------------------------------------------------------------------- | ------------- | ------------- | ------------ | ------------ | ----------- | ---------- |
| Lente CR39 1.50 Multifocal +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                          | multifocal    | CR39          | 36           | 1            | 2620.31     | false      |
| Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]     | multifocal    | POLICARBONATO | 30           | 1            | 3218.35     | false      |
| Lente CR39 1.67 Multifocal +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                         | multifocal    | CR39          | 24           | 1            | 5437.77     | false      |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                      | multifocal    | CR39          | 24           | 1            | 2424.77     | false      |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-10.00/8.00 | -6.00/0.00 | 0.50/4.50] | multifocal    | POLICARBONATO | 20           | 1            | 3022.81     | false      |
| Lente CR39 1.67 Multifocal +AR +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                     | multifocal    | CR39          | 16           | 1            | 5242.23     | false      |
| Lente CR39 1.56 Multifocal +UV +BlueLight [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]               | multifocal    | CR39          | 15           | 1            | 2795.98     | false      |
| Lente POLICARBONATO 1.59 Multifocal +UV [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]                | multifocal    | POLICARBONATO | 15           | 1            | 2874.19     | false      |
| Lente POLICARBONATO 1.59 Visao Simples +UV +BlueLight [-10.00/8.00 | -6.00/0.00]              | visao_simples | POLICARBONATO | 12           | 1            | 3237.90     | false      |
| Lente CR39 1.67 Multifocal +UV [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]                         | multifocal    | CR39          | 12           | 1            | 5134.68     | false      |

-- Query 2.3: Top 10 grupos premium mais caros
SELECT 
    nome_grupo,
    tipo_lente,
    material,
    preco_medio,
    total_lentes,
    total_marcas
FROM public.v_grupos_premium
ORDER BY preco_medio DESC
LIMIT 10;

| nome_grupo                                                                                | tipo_lente    | material | preco_medio | total_lentes | total_marcas |
| ----------------------------------------------------------------------------------------- | ------------- | -------- | ----------- | ------------ | ------------ |
| Lente CR39 1.74 Multifocal +UV +fotocromático [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]     | multifocal    | CR39     | 9123.76     | 3            | 1            |
| Lente CR39 1.74 Multifocal +UV +fotocromático [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]     | multifocal    | CR39     | 9084.66     | 6            | 1            |
| Lente CR39 1.74 Multifocal +UV +fotocromático [-13.00/11.00 | -6.00/0.00]                 | multifocal    | CR39     | 9045.55     | 3            | 1            |
| Lente CR39 1.74 Visao Simples +UV +fotocromático [-14.00/10.00 | -8.00/0.00]              | visao_simples | CR39     | 8986.89     | 6            | 1            |
| Lente CR39 1.74 Multifocal +AR +UV +fotocromático [-13.00/10.00 | -6.00/0.00 | 0.50/4.50] | multifocal    | CR39     | 8928.23     | 2            | 1            |
| Lente CR39 1.74 Multifocal +AR +UV +fotocromático [-15.00/10.00 | -8.00/0.00 | 0.50/4.50] | multifocal    | CR39     | 8889.11     | 4            | 1            |
| Lente CR39 1.74 Multifocal +AR +UV +fotocromático [-13.00/11.00 | -6.00/0.00]             | multifocal    | CR39     | 8850.01     | 2            | 1            |
| Lente CR39 1.74 Visao Simples +AR +UV +fotocromático [-14.00/10.00 | -8.00/0.00]          | visao_simples | CR39     | 8791.34     | 4            | 1            |
| Lente CR39 1.67 Multifocal +UV +fotocromático [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]      | multifocal    | CR39     | 7520.31     | 3            | 1            |
| Lente CR39 1.67 Multifocal +UV +fotocromático [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]      | multifocal    | CR39     | 7461.64     | 6            | 1            |



-- Query 2.4: Distribuição de grupos por tipo de lente
SELECT 
    tipo_lente,
    COUNT(*) as total_grupos,
    AVG(preco_medio) as preco_medio,
    SUM(total_lentes) as total_lentes
FROM public.v_grupos_canonicos
GROUP BY tipo_lente
ORDER BY total_grupos DESC;

| tipo_lente    | total_grupos | preco_medio           | total_lentes |
| ------------- | ------------ | --------------------- | ------------ |
| visao_simples | 218          | 1501.2324311926605505 | 394          |
| multifocal    | 182          | 2946.9439010989010989 | 754          |
| bifocal       | 1            | 555.0500000000000000  | 2            |


-- =============================================================================
-- 3. HISTÓRICO/VENDAS - "controle das vendas de lentes e valores da venda"
-- =============================================================================

-- Query 3.1: Verificar se existe tabela de vendas/pedidos
SELECT 
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_name LIKE '%venda%' 
   OR table_name LIKE '%pedido%'
   OR table_name LIKE '%ordem%'
   OR table_name LIKE '%compra%';


| table_schema | table_name              |
| ------------ | ----------------------- |
| compras      | pedidos                 |
| compras      | pedido_itens            |
| compras      | v_pedidos_completos     |
| public       | v_lentes_cotacao_compra |
| public       | v_pedidos_pendentes     |


isso o outro app que vai USAR
e devemos fazer da sequinte maneira, criar um documento de como usar, e a jornada da compra é a seguinte, comprou no pdv, vai para uma tabela de historico de compra, ou seja, entrada no  estoque jit, e e quando o outro app que é o de compra de lentes ai sim, faz a compra correta, porque devemos pensar asssim, o pdvsó tem acesso as lentes canonicas standard e premium, e com isso só depois da compra no laboratoio teremos o id real da lente ou o  sku real

-- Query 3.2: Verificar tabelas no schema compras
SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'compras'
ORDER BY table_name;

| table_name            | table_type |
| --------------------- | ---------- |
| estoque_movimentacoes | BASE TABLE |
| estoque_saldo         | BASE TABLE |
| historico_precos      | BASE TABLE |
| pedido_itens          | BASE TABLE |
| pedidos               | BASE TABLE |
| v_estoque_alertas     | VIEW       |
| v_itens_pendentes     | VIEW       |
| v_pedidos_completos   | VIEW       |


-- Query 3.3: Se houver tabela de pedidos, ver estrutura
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'compras'
  AND table_name LIKE '%pedido%'
ORDER BY ordinal_position;


| column_name             | data_type                | is_nullable |
| ----------------------- | ------------------------ | ----------- |
| id                      | uuid                     | YES         |
| id                      | uuid                     | NO          |
| id                      | uuid                     | NO          |
| pedido_id               | uuid                     | NO          |
| numero_pedido           | character varying        | NO          |
| numero_pedido           | character varying        | YES         |
| lente_id                | uuid                     | NO          |
| fornecedor_id           | uuid                     | YES         |
| fornecedor_id           | uuid                     | NO          |
| status                  | USER-DEFINED             | NO          |
| quantidade              | integer                  | NO          |
| status                  | USER-DEFINED             | YES         |
| data_pedido             | timestamp with time zone | NO          |
| data_pedido             | timestamp with time zone | YES         |
| quantidade_recebida     | integer                  | YES         |
| preco_unitario          | numeric                  | NO          |
| data_confirmacao        | timestamp with time zone | YES         |
| data_confirmacao        | timestamp with time zone | YES         |
| data_previsao_entrega   | timestamp with time zone | YES         |
| desconto_unitario       | numeric                  | YES         |
| data_previsao_entrega   | timestamp with time zone | YES         |
| data_recebimento        | timestamp with time zone | YES         |
| data_recebimento        | timestamp with time zone | YES         |
| subtotal                | numeric                  | YES         |
| valor_total             | numeric                  | NO          |
| valor_total             | numeric                  | YES         |
| observacoes             | text                     | YES         |
| valor_frete             | numeric                  | YES         |
| valor_frete             | numeric                  | YES         |
| created_at              | timestamp with time zone | NO          |
| valor_desconto          | numeric                  | YES         |
| valor_desconto          | numeric                  | YES         |
| updated_at              | timestamp with time zone | NO          |
| observacoes             | text                     | YES         |
| observacoes             | text                     | YES         |
| observacoes_internas    | text                     | YES         |
| observacoes_internas    | text                     | YES         |
| codigo_rastreio         | character varying        | YES         |
| codigo_rastreio         | character varying        | YES         |
| created_by              | uuid                     | YES         |
| created_by              | uuid                     | YES         |
| created_at              | timestamp with time zone | NO          |
| created_at              | timestamp with time zone | YES         |
| updated_at              | timestamp with time zone | YES         |
| updated_at              | timestamp with time zone | NO          |
| deleted_at              | timestamp with time zone | YES         |
| deleted_at              | timestamp with time zone | YES         |
| fornecedor_nome         | text                     | YES         |
| fornecedor_razao_social | text                     | YES         |
| prazo_visao_simples     | integer                  | YES         |
| total_itens             | bigint                   | YES         |
| total_quantidade        | bigint                   | YES         |


-- Query 3.4: Verificar schema disponíveis
SELECT 
    schema_name
FROM information_schema.schemata
WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
ORDER BY schema_name;

| schema_name      |
| ---------------- |
| auth             |
| compras          |
| contact_lens     |
| core             |
| extensions       |
| graphql          |
| graphql_public   |
| lens_catalog     |
| pg_temp_0        |
| pg_temp_1        |
| pg_temp_10       |
| pg_temp_11       |
| pg_temp_12       |
| pg_temp_13       |
| pg_temp_14       |
| pg_temp_15       |
| pg_temp_16       |
| pg_temp_17       |
| pg_temp_18       |
| pg_temp_19       |
| pg_temp_2        |
| pg_temp_20       |
| pg_temp_21       |
| pg_temp_22       |
| pg_temp_23       |
| pg_temp_24       |
| pg_temp_25       |
| pg_temp_26       |
| pg_temp_27       |
| pg_temp_28       |
| pg_temp_29       |
| pg_temp_3        |
| pg_temp_30       |
| pg_temp_31       |
| pg_temp_32       |
| pg_temp_33       |
| pg_temp_34       |
| pg_temp_35       |
| pg_temp_36       |
| pg_temp_37       |
| pg_temp_38       |
| pg_temp_39       |
| pg_temp_4        |
| pg_temp_40       |
| pg_temp_41       |
| pg_temp_42       |
| pg_temp_43       |
| pg_temp_44       |
| pg_temp_45       |
| pg_temp_46       |
| pg_temp_47       |
| pg_temp_48       |
| pg_temp_49       |
| pg_temp_5        |
| pg_temp_50       |
| pg_temp_51       |
| pg_temp_52       |
| pg_temp_53       |
| pg_temp_54       |
| pg_temp_55       |
| pg_temp_56       |
| pg_temp_57       |
| pg_temp_58       |
| pg_temp_59       |
| pg_temp_6        |
| pg_temp_7        |
| pg_temp_8        |
| pg_temp_9        |
| pg_toast_temp_0  |
| pg_toast_temp_1  |
| pg_toast_temp_10 |
| pg_toast_temp_11 |
| pg_toast_temp_12 |
| pg_toast_temp_13 |
| pg_toast_temp_14 |
| pg_toast_temp_15 |
| pg_toast_temp_16 |
| pg_toast_temp_17 |
| pg_toast_temp_18 |
| pg_toast_temp_19 |
| pg_toast_temp_2  |
| pg_toast_temp_20 |
| pg_toast_temp_21 |
| pg_toast_temp_22 |
| pg_toast_temp_23 |
| pg_toast_temp_24 |
| pg_toast_temp_25 |
| pg_toast_temp_26 |
| pg_toast_temp_27 |
| pg_toast_temp_28 |
| pg_toast_temp_29 |
| pg_toast_temp_3  |
| pg_toast_temp_30 |
| pg_toast_temp_31 |
| pg_toast_temp_32 |
| pg_toast_temp_33 |
| pg_toast_temp_34 |
| pg_toast_temp_35 |
| pg_toast_temp_36 |
| pg_toast_temp_37 |
| pg_toast_temp_38 |
| pg_toast_temp_39 |
| pg_toast_temp_4  |
| pg_toast_temp_40 |
| pg_toast_temp_41 |
| pg_toast_temp_42 |
| pg_toast_temp_43 |
| pg_toast_temp_44 |
| pg_toast_temp_45 |
| pg_toast_temp_46 |
| pg_toast_temp_47 |
| pg_toast_temp_48 |
| pg_toast_temp_49 |
| pg_toast_temp_5  |
| pg_toast_temp_50 |
| pg_toast_temp_51 |
| pg_toast_temp_52 |
| pg_toast_temp_53 |
| pg_toast_temp_54 |
| pg_toast_temp_55 |
| pg_toast_temp_56 |
| pg_toast_temp_57 |
| pg_toast_temp_58 |
| pg_toast_temp_59 |
| pg_toast_temp_6  |
| pg_toast_temp_7  |
| pg_toast_temp_8  |
| pg_toast_temp_9  |
| pgbouncer        |
| public           |
| public_api       |
| realtime         |
| storage          |
| vault            |


-- =============================================================================
-- 4. ANALYTICS/BI - "juntar com o historico para termos tudo em um unico lugar"
-- =============================================================================

-- Query 4.1: Dados para Analytics - Distribuição de preços
SELECT 
    CASE 
        WHEN preco_medio < 300 THEN 'Até R$ 300'
        WHEN preco_medio < 500 THEN 'R$ 300 - 500'
        WHEN preco_medio < 1000 THEN 'R$ 500 - 1000'
        WHEN preco_medio < 2000 THEN 'R$ 1000 - 2000'
        ELSE 'Acima de R$ 2000'
    END as faixa_preco,
    COUNT(*) as quantidade_grupos,
    is_premium
FROM public.v_grupos_canonicos
GROUP BY faixa_preco, is_premium
ORDER BY 
    is_premium DESC,
    MIN(preco_medio);

    | faixa_preco      | quantidade_grupos | is_premium |
| ---------------- | ----------------- | ---------- |
| Até R$ 300       | 20                | false      |
| R$ 300 - 500     | 69                | false      |
| R$ 500 - 1000    | 82                | false      |
| R$ 1000 - 2000   | 64                | false      |
| Acima de R$ 2000 | 166               | false      |


-- Query 4.2: Distribuição por material
SELECT 
    material,
    COUNT(*) as total_grupos,
    AVG(preco_medio) as preco_medio,
    SUM(total_lentes) as total_lentes,
    SUM(CASE WHEN is_premium THEN 1 ELSE 0 END) as grupos_premium,
    SUM(CASE WHEN NOT is_premium THEN 1 ELSE 0 END) as grupos_standard
FROM public.v_grupos_canonicos
GROUP BY material
ORDER BY total_grupos DESC;


| material      | total_grupos | preco_medio           | total_lentes | grupos_premium | grupos_standard |
| ------------- | ------------ | --------------------- | ------------ | -------------- | --------------- |
| CR39          | 301          | 2329.1759800664451827 | 851          | 0              | 301             |
| POLICARBONATO | 100          | 1630.8554000000000000 | 299          | 0              | 100             |


-- Query 4.3: Tratamentos mais comuns
SELECT 'Antirreflexo' as tratamento, COUNT(*) as grupos_com_tratamento
FROM public.v_grupos_canonicos
WHERE tratamento_antirreflexo = true
UNION ALL
SELECT 'Blue Light', COUNT(*)
FROM public.v_grupos_canonicos
WHERE tratamento_blue_light = true
UNION ALL
SELECT 'UV', COUNT(*)
FROM public.v_grupos_canonicos
WHERE tratamento_uv = true
UNION ALL
SELECT 'Fotossensível', COUNT(*)
FROM public.v_grupos_canonicos
WHERE tratamento_fotossensiveis != 'nenhum'
ORDER BY grupos_com_tratamento DESC;

| tratamento    | grupos_com_tratamento |
| ------------- | --------------------- |
| UV            | 401                   |
| Antirreflexo  | 214                   |
| Blue Light    | 179                   |
| Fotossensível | 69                    |



-- =============================================================================
-- 5. CATÁLOGO - "só tems que ter 1" (remover duplicata)
-- =============================================================================

-- Query 5.1: Confirmar totais do catálogo
SELECT 
    'Todos' as tipo,
    COUNT(*) as total_grupos,
    AVG(preco_medio) as preco_medio,
    SUM(total_lentes) as total_lentes
FROM public.v_grupos_canonicos
UNION ALL
SELECT 
    'Standard' as tipo,
    COUNT(*) as total_grupos,
    AVG(preco_medio) as preco_medio,
    SUM(total_lentes) as total_lentes
FROM public.v_grupos_canonicos
WHERE is_premium = false
UNION ALL
SELECT 
    'Premium' as tipo,
    COUNT(*) as total_grupos,
    AVG(preco_medio) as preco_medio,
    SUM(total_lentes) as total_lentes
FROM public.v_grupos_premium;

| tipo     | total_grupos | preco_medio           | total_lentes |
| -------- | ------------ | --------------------- | ------------ |
| Todos    | 401          | 2155.0311970074812968 | 1150         |
| Standard | 401          | 2155.0311970074812968 | 1150         |
| Premium  | 60           | 4589.9520000000000000 | 261          |



-- =============================================================================
-- 6. COMPARAÇÃO - "não temos porque continuar com isso, depois te explico"
-- =============================================================================

-- Query 6.1: Verificar se existe tabela de comparações salvas
SELECT 
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_name LIKE '%compar%';


Success. No rows returned




-- Query 6.2: Verificar se existe histórico de decisões
SELECT 
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_name LIKE '%decisao%' 
   OR table_name LIKE '%decision%';

Success. No rows returned






-- =============================================================================
-- 7. COMERCIAL - "não faz mais sentido com o pdv já rodanto"
-- =============================================================================

-- Query 7.1: Verificar tabelas relacionadas a comercial
SELECT 
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_name LIKE '%voucher%' 
   OR table_name LIKE '%cliente%'
   OR table_name LIKE '%comercial%';


| table_schema | table_name                   |
| ------------ | ---------------------------- |
| public       | v_grupos_por_receita_cliente |


-- Query 7.2: Listar todas as tabelas disponíveis para decisão
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
ORDER BY table_schema, table_name;

| table_schema | table_name                       | table_type |
| ------------ | -------------------------------- | ---------- |
| auth         | audit_log_entries                | BASE TABLE |
| auth         | flow_state                       | BASE TABLE |
| auth         | identities                       | BASE TABLE |
| auth         | instances                        | BASE TABLE |
| auth         | mfa_amr_claims                   | BASE TABLE |
| auth         | mfa_challenges                   | BASE TABLE |
| auth         | mfa_factors                      | BASE TABLE |
| auth         | oauth_authorizations             | BASE TABLE |
| auth         | oauth_client_states              | BASE TABLE |
| auth         | oauth_clients                    | BASE TABLE |
| auth         | oauth_consents                   | BASE TABLE |
| auth         | one_time_tokens                  | BASE TABLE |
| auth         | refresh_tokens                   | BASE TABLE |
| auth         | saml_providers                   | BASE TABLE |
| auth         | saml_relay_states                | BASE TABLE |
| auth         | schema_migrations                | BASE TABLE |
| auth         | sessions                         | BASE TABLE |
| auth         | sso_domains                      | BASE TABLE |
| auth         | sso_providers                    | BASE TABLE |
| auth         | users                            | BASE TABLE |
| compras      | estoque_movimentacoes            | BASE TABLE |
| compras      | estoque_saldo                    | BASE TABLE |
| compras      | historico_precos                 | BASE TABLE |
| compras      | pedido_itens                     | BASE TABLE |
| compras      | pedidos                          | BASE TABLE |
| compras      | v_estoque_alertas                | VIEW       |
| compras      | v_itens_pendentes                | VIEW       |
| compras      | v_pedidos_completos              | VIEW       |
| core         | fornecedores                     | BASE TABLE |
| extensions   | pg_stat_statements               | VIEW       |
| extensions   | pg_stat_statements_info          | VIEW       |
| lens_catalog | grupos_canonicos                 | BASE TABLE |
| lens_catalog | grupos_canonicos_backup_old      | BASE TABLE |
| lens_catalog | grupos_canonicos_log             | BASE TABLE |
| lens_catalog | lentes                           | BASE TABLE |
| lens_catalog | lentes_canonicas                 | BASE TABLE |
| lens_catalog | lentes_grupos_backup_old         | BASE TABLE |
| lens_catalog | marcas                           | BASE TABLE |
| lens_catalog | premium_canonicas                | BASE TABLE |
| lens_catalog | stg_lentes_import                | BASE TABLE |
| lens_catalog | v_grupos_canonicos_detalhados    | VIEW       |
| lens_catalog | v_grupos_canonicos_detalhados_v5 | VIEW       |
| public       | v_estatisticas_catalogo          | VIEW       |
| public       | v_estoque_disponivel             | VIEW       |
| public       | v_filtros_disponiveis            | VIEW       |
| public       | v_filtros_grupos_canonicos       | VIEW       |
| public       | v_fornecedores_catalogo          | VIEW       |
| public       | v_fornecedores_por_lente         | VIEW       |
| public       | v_grupos_canonicos               | VIEW       |
| public       | v_grupos_canonicos_completos     | VIEW       |
| public       | v_grupos_com_lentes              | VIEW       |
| public       | v_grupos_melhor_margem           | VIEW       |
| public       | v_grupos_por_faixa_preco         | VIEW       |
| public       | v_grupos_por_receita_cliente     | VIEW       |
| public       | v_grupos_premium                 | VIEW       |
| public       | v_lentes_busca                   | VIEW       |
| public       | v_lentes_catalogo                | VIEW       |
| public       | v_lentes_cotacao_compra          | VIEW       |
| public       | v_pedidos_pendentes              | VIEW       |
| public       | v_sugestoes_upgrade              | VIEW       |
| public       | vw_bi_lentes_lucratividade       | VIEW       |
| public       | vw_canonicas_genericas           | VIEW       |
| public       | vw_canonicas_premium             | VIEW       |
| public       | vw_detalhes_premium              | VIEW       |
| public       | vw_lentes_catalogo               | VIEW       |
| public       | vw_stats_catalogo                | VIEW       |
| realtime     | messages                         | BASE TABLE |
| realtime     | schema_migrations                | BASE TABLE |
| realtime     | subscription                     | BASE TABLE |
| storage      | buckets                          | BASE TABLE |
| storage      | buckets_analytics                | BASE TABLE |
| storage      | buckets_vectors                  | BASE TABLE |
| storage      | migrations                       | BASE TABLE |
| storage      | objects                          | BASE TABLE |
| storage      | prefixes                         | BASE TABLE |
| storage      | s3_multipart_uploads             | BASE TABLE |
| storage      | s3_multipart_uploads_parts       | BASE TABLE |
| storage      | vector_indexes                   | BASE TABLE |
| vault        | decrypted_secrets                | VIEW       |
| vault        | secrets                          | BASE TABLE |


-- =============================================================================
-- RESUMO EXECUTIVO
-- =============================================================================

-- Query FINAL: Overview completo do banco
SELECT 
    'Fornecedores' as recurso,
    (SELECT COUNT(*) FROM core.fornecedores) as total,
    'core.fornecedores' as tabela
UNION ALL
SELECT 
    'Marcas' as recurso,
    (SELECT COUNT(*) FROM lens_catalog.marcas) as total,
    'lens_catalog.marcas' as tabela
UNION ALL
SELECT 
    'Lentes Individuais' as recurso,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true) as total,
    'lens_catalog.lentes' as tabela
UNION ALL
SELECT 
    'Grupos Canônicos (Todos)' as recurso,
    (SELECT COUNT(*) FROM lens_catalog.grupos_canonicos) as total,
    'lens_catalog.grupos_canonicos' as tabela
UNION ALL
SELECT 
    'Grupos Standard' as recurso,
    (SELECT COUNT(*) FROM public.v_grupos_canonicos WHERE is_premium = false) as total,
    'v_grupos_canonicos (standard)' as tabela
UNION ALL
SELECT 
    'Grupos Premium' as recurso,
    (SELECT COUNT(*) FROM public.v_grupos_premium) as total,
    'v_grupos_premium' as tabela;

| recurso                  | total | tabela                        |
| ------------------------ | ----- | ----------------------------- |
| Fornecedores             | 11    | core.fornecedores             |
| Marcas                   | 17    | lens_catalog.marcas           |
| Lentes Individuais       | 1411  | lens_catalog.lentes           |
| Grupos Canônicos (Todos) | 461   | lens_catalog.grupos_canonicos |
| Grupos Standard          | 401   | v_grupos_canonicos (standard) |
| Grupos Premium           | 60    | v_grupos_premium              |


