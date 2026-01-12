-- =====================================================
-- INVESTIGAÇÃO: BANCO DE LENTES - BEST_LENS v2.0
-- =====================================================
-- Objetivo: Mapear estrutura de GRUPOS CANÔNICOS
-- Foco: lens_catalog, core, public (views)
-- Conceito: Grupos Canônicos (não produtos individuais)
-- =====================================================

-- =====================================================
-- 1. ESTRUTURA DO BANCO
-- =====================================================

-- 1.1 Listar todos os schemas
SELECT schema_name 
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


-- 1.2 Listar tabelas no schema 'lens_catalog'
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'lens_catalog'
ORDER BY table_name;


| table_name                       | table_type |
| -------------------------------- | ---------- |
| grupos_canonicos                 | BASE TABLE |
| grupos_canonicos_backup_old      | BASE TABLE |
| grupos_canonicos_log             | BASE TABLE |
| lentes                           | BASE TABLE |
| lentes_canonicas                 | BASE TABLE |
| lentes_grupos_backup_old         | BASE TABLE |
| marcas                           | BASE TABLE |
| premium_canonicas                | BASE TABLE |
| v_grupos_canonicos_detalhados    | VIEW       |
| v_grupos_canonicos_detalhados_v5 | VIEW       |


-- 1.3 Listar tabelas no schema 'core'
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'core'
ORDER BY table_name;

| table_name   | table_type |
| ------------ | ---------- |
| fornecedores | BASE TABLE |


-- 1.4 Listar VIEWS no schema 'public' (foco principal)
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'VIEW'
ORDER BY table_name;


| table_name                   | table_type |
| ---------------------------- | ---------- |
| v_estatisticas_catalogo      | VIEW       |
| v_estoque_disponivel         | VIEW       |
| v_filtros_disponiveis        | VIEW       |
| v_filtros_grupos_canonicos   | VIEW       |
| v_fornecedores_catalogo      | VIEW       |
| v_fornecedores_por_lente     | VIEW       |
| v_grupos_canonicos           | VIEW       |
| v_grupos_canonicos_completos | VIEW       |
| v_grupos_com_lentes          | VIEW       |
| v_grupos_melhor_margem       | VIEW       |
| v_grupos_por_faixa_preco     | VIEW       |
| v_grupos_por_receita_cliente | VIEW       |
| v_grupos_premium             | VIEW       |
| v_lentes_busca               | VIEW       |
| v_lentes_catalogo            | VIEW       |
| v_lentes_cotacao_compra      | VIEW       |
| v_pedidos_pendentes          | VIEW       |
| v_sugestoes_upgrade          | VIEW       |

-- =====================================================
-- 2. VIEWS PRINCIPAIS - GRUPOS CANÔNICOS
-- =====================================================

-- 2.1 Estrutura da view v_grupos_canonicos_completos (STANDARD)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_grupos_canonicos_completos'
ORDER BY ordinal_position;

| column_name              | data_type    | is_nullable |
| ------------------------ | ------------ | ----------- |
| id                       | uuid         | YES         |
| nome_grupo               | text         | YES         |
| tipo_lente               | USER-DEFINED | YES         |
| material                 | USER-DEFINED | YES         |
| indice_refracao          | USER-DEFINED | YES         |
| preco_medio              | numeric      | YES         |
| fornecedores_disponiveis | jsonb        | YES         |
| total_lentes             | bigint       | YES         |
| is_premium               | boolean      | YES         |


-- 2.2 Estrutura da view v_grupos_premium (PREMIUM)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_grupos_premium'
ORDER BY ordinal_position;


| column_name               | data_type    | is_nullable |
| ------------------------- | ------------ | ----------- |
| id                        | uuid         | YES         |
| slug                      | text         | YES         |
| nome_grupo                | text         | YES         |
| tipo_lente                | USER-DEFINED | YES         |
| material                  | USER-DEFINED | YES         |
| indice_refracao           | USER-DEFINED | YES         |
| categoria_predominante    | USER-DEFINED | YES         |
| grau_esferico_min         | numeric      | YES         |
| grau_esferico_max         | numeric      | YES         |
| grau_cilindrico_min       | numeric      | YES         |
| grau_cilindrico_max       | numeric      | YES         |
| adicao_min                | numeric      | YES         |
| adicao_max                | numeric      | YES         |
| descricao_ranges          | text         | YES         |
| tratamento_antirreflexo   | boolean      | YES         |
| tratamento_antirrisco     | boolean      | YES         |
| tratamento_uv             | boolean      | YES         |
| tratamento_blue_light     | boolean      | YES         |
| tratamento_fotossensiveis | text         | YES         |
| preco_minimo              | numeric      | YES         |
| preco_maximo              | numeric      | YES         |
| preco_medio               | numeric      | YES         |
| total_lentes              | integer      | YES         |
| total_marcas              | integer      | YES         |
| peso                      | integer      | YES         |
| is_premium                | boolean      | YES         |
| marcas_disponiveis        | jsonb        | YES         |
| marcas_nomes              | text         | YES         |

-- 2.3 Estrutura da view v_lentes_catalogo (catálogo completo)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_lentes_catalogo'
ORDER BY ordinal_position;


| column_name               | data_type                | is_nullable |
| ------------------------- | ------------------------ | ----------- |
| id                        | uuid                     | YES         |
| slug                      | text                     | YES         |
| nome_lente                | text                     | YES         |
| nome_canonizado           | text                     | YES         |
| fornecedor_id             | uuid                     | YES         |
| fornecedor_nome           | text                     | YES         |
| prazo_visao_simples       | integer                  | YES         |
| prazo_multifocal          | integer                  | YES         |
| prazo_surfacada           | integer                  | YES         |
| prazo_free_form           | integer                  | YES         |
| marca_id                  | uuid                     | YES         |
| marca_nome                | character varying        | YES         |
| marca_slug                | character varying        | YES         |
| marca_premium             | boolean                  | YES         |
| grupo_id                  | uuid                     | YES         |
| nome_grupo                | text                     | YES         |
| grupo_slug                | text                     | YES         |
| tipo_lente                | USER-DEFINED             | YES         |
| material                  | USER-DEFINED             | YES         |
| indice_refracao           | USER-DEFINED             | YES         |
| categoria                 | USER-DEFINED             | YES         |
| tratamento_antirreflexo   | boolean                  | YES         |
| tratamento_antirrisco     | boolean                  | YES         |
| tratamento_uv             | boolean                  | YES         |
| tratamento_blue_light     | boolean                  | YES         |
| tratamento_fotossensiveis | USER-DEFINED             | YES         |
| diametro_mm               | integer                  | YES         |
| curva_base                | numeric                  | YES         |
| espessura_centro_mm       | numeric                  | YES         |
| grau_esferico_min         | numeric                  | YES         |
| grau_esferico_max         | numeric                  | YES         |
| grau_cilindrico_min       | numeric                  | YES         |
| grau_cilindrico_max       | numeric                  | YES         |
| adicao_min                | numeric                  | YES         |
| adicao_max                | numeric                  | YES         |
| preco_custo               | numeric                  | YES         |
| preco_venda_sugerido      | numeric                  | YES         |
| margem_lucro              | numeric                  | YES         |
| estoque_disponivel        | integer                  | YES         |
| estoque_reservado         | integer                  | YES         |
| status                    | USER-DEFINED             | YES         |
| ativo                     | boolean                  | YES         |
| peso                      | integer                  | YES         |
| metadata                  | jsonb                    | YES         |
| created_at                | timestamp with time zone | YES         |
| updated_at                | timestamp with time zone | YES         |

-- =====================================================
-- 2.4 INVESTIGAÇÃO COMPLETA - TODAS AS VIEWS DE GRUPOS
-- =====================================================

-- 2.4.1 Estrutura da view v_grupos_canonicos (STANDARD ONLY)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_grupos_canonicos'
ORDER BY ordinal_position;

| column_name               | data_type    | is_nullable |
| ------------------------- | ------------ | ----------- |
| id                        | uuid         | YES         |
| slug                      | text         | YES         |
| nome_grupo                | text         | YES         |
| tipo_lente                | USER-DEFINED | YES         |
| material                  | USER-DEFINED | YES         |
| indice_refracao           | USER-DEFINED | YES         |
| categoria_predominante    | USER-DEFINED | YES         |
| grau_esferico_min         | numeric      | YES         |
| grau_esferico_max         | numeric      | YES         |
| grau_cilindrico_min       | numeric      | YES         |
| grau_cilindrico_max       | numeric      | YES         |
| adicao_min                | numeric      | YES         |
| adicao_max                | numeric      | YES         |
| descricao_ranges          | text         | YES         |
| tratamento_antirreflexo   | boolean      | YES         |
| tratamento_antirrisco     | boolean      | YES         |
| tratamento_uv             | boolean      | YES         |
| tratamento_blue_light     | boolean      | YES         |
| tratamento_fotossensiveis | text         | YES         |
| preco_minimo              | numeric      | YES         |
| preco_maximo              | numeric      | YES         |
| preco_medio               | numeric      | YES         |
| total_lentes              | integer      | YES         |
| total_marcas              | integer      | YES         |
| peso                      | integer      | YES         |
| is_premium                | boolean      | YES         |


-- 2.4.2 Comparação de totais entre as 3 views
SELECT 
    'v_grupos_canonicos' as view_name,
    COUNT(*) as total_grupos,
    SUM(CASE WHEN is_premium = true THEN 1 ELSE 0 END) as premium_count,
    SUM(CASE WHEN is_premium = false THEN 1 ELSE 0 END) as standard_count
FROM public.v_grupos_canonicos

UNION ALL

SELECT 
    'v_grupos_premium' as view_name,
    COUNT(*) as total_grupos,
    SUM(CASE WHEN is_premium = true THEN 1 ELSE 0 END) as premium_count,
    SUM(CASE WHEN is_premium = false THEN 1 ELSE 0 END) as standard_count
FROM public.v_grupos_premium

UNION ALL

SELECT 
    'v_grupos_canonicos_completos' as view_name,
    COUNT(*) as total_grupos,
    SUM(CASE WHEN is_premium = true THEN 1 ELSE 0 END) as premium_count,
    SUM(CASE WHEN is_premium = false THEN 1 ELSE 0 END) as standard_count
FROM public.v_grupos_canonicos_completos;


| view_name                    | total_grupos | premium_count | standard_count |
| ---------------------------- | ------------ | ------------- | -------------- |
| v_grupos_canonicos           | 401          | 0             | 401            |
| v_grupos_premium             | 60           | 60            | 0              |
| v_grupos_canonicos_completos | 461          | 0             | 461            |


olha o gap complexo que temos aqui, no completo temos as lentes premium mas não aparece separadas 

-- 2.4.3 Exemplo de 5 registros de v_grupos_canonicos (STANDARD)
SELECT 
    id,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    preco_medio,
    total_lentes,
    is_premium
FROM public.v_grupos_canonicos
LIMIT 5;

| id                                   | nome_grupo                                                            | tipo_lente    | material      | indice_refracao | preco_medio | total_lentes | is_premium |
| ------------------------------------ | --------------------------------------------------------------------- | ------------- | ------------- | --------------- | ----------- | ------------ | ---------- |
| 573729aa-91b7-4f74-b2dc-00e5bcd9ea34 | Lente POLICARBONATO 1.59 Visao Simples +UV [-10.00/6.00 | 0.00/-2.00] | visao_simples | POLICARBONATO | 1.59            | 250.00      | 1            | false      |
| 30d581c1-4b46-41a8-b4a5-6653c862ec7a | Lente CR39 1.50 Visao Simples +UV [-6.00/6.00 | 0.00/-2.00]           | visao_simples | CR39          | 1.50            | 250.00      | 1            | false      |
| 62d675b2-e9b2-47d3-b98f-9ff53b26eca7 | Lente CR39 1.56 Visao Simples +AR +UV [-8.00/6.00 | 0.00/-2.00]       | visao_simples | CR39          | 1.56            | 253.91      | 1            | false      |
| 928ddd31-a900-4340-8d3f-094e68538524 | Lente CR39 1.50 Visao Simples +UV [-6.00/6.00 | -2.00/2.00]           | visao_simples | CR39          | 1.50            | 255.87      | 1            | false      |
| 14a2d496-3947-4b9e-9ff2-aff781d7cee3 | Lente CR39 1.56 Visao Simples +AR +UV [-8.00/6.00 | -2.00/0.00]       | visao_simples | CR39          | 1.56            | 261.73      | 1            | false      |


-- 2.4.4 Exemplo de 5 registros de v_grupos_premium (PREMIUM)
SELECT 
    id,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    categoria_predominante,
    preco_medio,
    preco_minimo,
    preco_maximo,
    total_lentes,
    total_marcas,
    is_premium,
    tratamento_antirreflexo,
    tratamento_blue_light
FROM public.v_grupos_premium
LIMIT 5;


| id                                   | nome_grupo                                                                          | tipo_lente    | material | indice_refracao | categoria_predominante | preco_medio | preco_minimo | preco_maximo | total_lentes | total_marcas | is_premium | tratamento_antirreflexo | tratamento_blue_light |
| ------------------------------------ | ----------------------------------------------------------------------------------- | ------------- | -------- | --------------- | ---------------------- | ----------- | ------------ | ------------ | ------------ | ------------ | ---------- | ----------------------- | --------------------- |
| b041ad01-b262-47f1-8d72-0487f42d6d39 | Lente CR39 1.50 Multifocal +UV [-6.00/6.00 | 0.00/-4.00 | 1.00/3.50]                | multifocal    | CR39     | 1.50            | null                   | 508.12      | 410.35       | 605.89       | 2            | 2            | true       | false                   | false                 |
| d5df1018-c6e1-4afc-864e-e472183a66cb | Lente CR39 1.56 Multifocal +UV [-6.00/6.00 | 0.00/-4.00 | 1.00/3.50]                | multifocal    | CR39     | 1.56            | null                   | 684.11      | 684.11       | 684.11       | 1            | 1            | true       | false                   | false                 |
| ed2f6838-6ee7-47f8-a1a1-f65f55b91525 | Lente CR39 1.56 Multifocal +UV +fotocromático [-5.00/6.00 | 0.00/-4.00 | 1.00/3.00] | multifocal    | CR39     | 1.56            | null                   | 695.84      | 527.67       | 996.98       | 5            | 3            | true       | false                   | false                 |
| 520981ba-b797-4934-920e-7d7630c835c7 | Lente CR39 1.50 Visao Simples +UV +fotocromático [2.25/4.00 | -2.25/-4.00]          | visao_simples | CR39     | 1.50            | null                   | 977.42      | 977.42       | 977.42       | 1            | 1            | true       | false                   | false                 |
| 6604b87e-a01f-47d0-bb99-04cfb6a16736 | Lente CR39 1.50 Visao Simples +AR +UV +fotocromático [-2.00/2.00 | 0.00/-2.00]      | visao_simples | CR39     | 1.50            | null                   | 977.42      | 977.42       | 977.42       | 1            | 1            | true       | true                    | false                 |



-- 2.4.5 Exemplo de 5 registros de v_grupos_canonicos_completos (TODOS)
SELECT 
    id,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    preco_medio,
    total_lentes,
    is_premium
FROM public.v_grupos_canonicos_completos
LIMIT 5;

| id                                   | nome_grupo                                                                          | tipo_lente    | material | indice_refracao | preco_medio | total_lentes | is_premium |
| ------------------------------------ | ----------------------------------------------------------------------------------- | ------------- | -------- | --------------- | ----------- | ------------ | ---------- |
| 5119b489-b1e6-486c-908a-0568709d578f | Lente CR39 1.56 Multifocal +AR +UV +BlueLight [-8.00/6.00 | -5.00/0.00 | 0.75/3.50] | multifocal    | CR39     | 1.56            | 1481.93     | 2            | false      |
| d866c17c-bb77-4a23-8add-ed612b86afcb | Lente CR39 1.50 Visao Simples +AR +UV +fotocromático [-6.00/6.00 | -4.00/0.00]      | visao_simples | CR39     | 1.50            | 1305.94     | 2            | false      |
| aa06bcac-1de3-450a-88b6-88ffe7cea158 | Lente CR39 1.50 Visao Simples +AR +UV [-6.00/6.00 | -4.00/0.00]                     | visao_simples | CR39     | 1.50            | 727.13      | 1            | false      |
| b16d7869-ad98-44fe-a4ae-d77e7158b9b2 | Lente CR39 1.50 Visao Simples +AR +UV +BlueLight [-6.00/6.00 | -4.00/0.00]          | visao_simples | CR39     | 1.50            | 918.76      | 1            | false      |
| 3a79ba0f-2bdd-4f1a-a0b9-e5d5cd463ad7 | Lente CR39 1.50 Visao Simples +AR +UV [-6.00/6.00 | -2.25/-4.00]                    | visao_simples | CR39     | 1.50            | 275.42      | 1            | false      |


-- 2.4.6 Comparar campos disponíveis em cada view
SELECT 
    'v_grupos_canonicos' as view_name,
    COUNT(*) as total_campos
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'v_grupos_canonicos'

UNION ALL

SELECT 
    'v_grupos_premium' as view_name,
    COUNT(*) as total_campos
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'v_grupos_premium'

UNION ALL

SELECT 
    'v_grupos_canonicos_completos' as view_name,
    COUNT(*) as total_campos
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'v_grupos_canonicos_completos';

| view_name                    | total_campos |
| ---------------------------- | ------------ |
| v_grupos_canonicos           | 26           |
| v_grupos_premium             | 28           |
| v_grupos_canonicos_completos | 9            |


-- 2.4.7 Verificar se v_grupos_canonicos tem campos de tratamento
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_grupos_canonicos'
  AND (column_name LIKE '%tratamento%' OR column_name LIKE '%categoria%')
ORDER BY column_name;

| column_name               |
| ------------------------- |
| categoria_predominante    |
| tratamento_antirreflexo   |
| tratamento_antirrisco     |
| tratamento_blue_light     |
| tratamento_fotossensiveis |
| tratamento_uv             |


-- 2.4.8 Verificar range de preços em cada view
SELECT 
    'v_grupos_canonicos' as view_name,
    MIN(preco_medio) as preco_min,
    MAX(preco_medio) as preco_max,
    ROUND(AVG(preco_medio), 2) as preco_medio_geral
FROM public.v_grupos_canonicos

UNION ALL

SELECT 
    'v_grupos_premium' as view_name,
    MIN(preco_medio) as preco_min,
    MAX(preco_medio) as preco_max,
    ROUND(AVG(preco_medio), 2) as preco_medio_geral
FROM public.v_grupos_premium

UNION ALL

SELECT 
    'v_grupos_canonicos_completos' as view_name,
    MIN(preco_medio) as preco_min,
    MAX(preco_medio) as preco_max,
    ROUND(AVG(preco_medio), 2) as preco_medio_geral
FROM public.v_grupos_canonicos_completos;

| view_name                    | preco_min | preco_max | preco_medio_geral |
| ---------------------------- | --------- | --------- | ----------------- |
| v_grupos_canonicos           | 250.00    | 7676.74   | 2155.03           |
| v_grupos_premium             | 508.12    | 9123.76   | 4589.95           |
| v_grupos_canonicos_completos | 250.00    | 9123.76   | 2471.94           |


-- 2.4.9 Distribuição por tipo em cada view
-- v_grupos_canonicos
SELECT 
    'v_grupos_canonicos' as view_name,
    tipo_lente,
    COUNT(*) as total
FROM public.v_grupos_canonicos
GROUP BY tipo_lente
ORDER BY total DESC;

| view_name          | tipo_lente    | total |
| ------------------ | ------------- | ----- |
| v_grupos_canonicos | visao_simples | 218   |
| v_grupos_canonicos | multifocal    | 182   |
| v_grupos_canonicos | bifocal       | 1     |


-- v_grupos_premium  
SELECT 
    'v_grupos_premium' as view_name,
    tipo_lente,
    COUNT(*) as total
FROM public.v_grupos_premium
GROUP BY tipo_lente
ORDER BY total DESC;


| view_name        | tipo_lente    | total |
| ---------------- | ------------- | ----- |
| v_grupos_premium | multifocal    | 46    |
| v_grupos_premium | visao_simples | 14    |

-- v_grupos_canonicos_completos
SELECT 
    'v_grupos_canonicos_completos' as view_name,
    tipo_lente,
    COUNT(*) as total
FROM public.v_grupos_canonicos_completos
GROUP BY tipo_lente
ORDER BY total DESC;

| view_name                    | tipo_lente    | total |
| ---------------------------- | ------------- | ----- |
| v_grupos_canonicos_completos | visao_simples | 232   |
| v_grupos_canonicos_completos | multifocal    | 228   |
| v_grupos_canonicos_completos | bifocal       | 1     |


-- 2.4.10 Verificar se há sobreposição de IDs entre as views
SELECT 
    COUNT(DISTINCT gc.id) as ids_em_canonicos,
    COUNT(DISTINCT gp.id) as ids_em_premium,
    COUNT(DISTINCT CASE WHEN gc.id = gp.id THEN gc.id END) as ids_em_ambos
FROM public.v_grupos_canonicos gc
FULL OUTER JOIN public.v_grupos_premium gp ON gc.id = gp.id;

| ids_em_canonicos | ids_em_premium | ids_em_ambos |
| ---------------- | -------------- | ------------ |
| 401              | 60             | 0            |


-- =====================================================
-- 3. ESTATÍSTICAS - GRUPOS CANÔNICOS
-- =====================================================
-- DECISÃO: Usar apenas v_grupos_canonicos (STANDARD) e v_grupos_premium (PREMIUM)
-- =====================================================

-- 3.1 Total de grupos STANDARD
SELECT COUNT(*) as total_grupos_standard
FROM public.v_grupos_canonicos;

| total_grupos_standard |
| --------------------- |
| 401                   |


-- 3.2 Total de grupos PREMIUM
SELECT COUNT(*) as total_grupos_premium
FROM public.v_grupos_premium;


| total_grupos_premium |
| -------------------- |
| 60                   |

-- 3.3 Total GERAL (soma das duas views)
SELECT 
    (SELECT COUNT(*) FROM public.v_grupos_canonicos) +
    (SELECT COUNT(*) FROM public.v_grupos_premium) as total_grupos_geral;

    | total_grupos_geral |
| ------------------ |
| 461                |


-- 3.4 Distribuição por tipo de lente (STANDARD)
SELECT 
    tipo_lente,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio,
    MIN(preco_minimo) as preco_min,
    MAX(preco_maximo) as preco_max
FROM public.v_grupos_canonicos
GROUP BY tipo_lente
ORDER BY total_grupos DESC;

| tipo_lente    | total_grupos | preco_medio | preco_min | preco_max |
| ------------- | ------------ | ----------- | --------- | --------- |
| visao_simples | 218          | 1501.23     | 250.00    | 9014.26   |
| multifocal    | 182          | 2946.94     | 332.13    | 9600.89   |
| bifocal       | 1            | 555.05      | 523.76    | 586.33    |

-- 3.5 Distribuição por tipo de lente (PREMIUM)
SELECT 
    tipo_lente,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio,
    MIN(preco_minimo) as preco_min,
    MAX(preco_maximo) as preco_max
FROM public.v_grupos_premium
GROUP BY tipo_lente
ORDER BY total_grupos DESC;

| tipo_lente    | total_grupos | preco_medio | preco_min | preco_max |
| ------------- | ------------ | ----------- | --------- | --------- |
| multifocal    | 46           | 4720.80     | 410.35    | 9640.00   |
| visao_simples | 14           | 4160.03     | 840.54    | 9444.46   |



-- =====================================================
-- 4. ANÁLISE DE MATERIAIS
-- =====================================================

-- 4.1 Distribuição por material (STANDARD)
SELECT 
    material,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio
FROM public.v_grupos_canonicos
GROUP BY material
ORDER BY total_grupos DESC;

| material      | total_grupos | preco_medio |
| ------------- | ------------ | ----------- |
| CR39          | 301          | 2329.18     |
| POLICARBONATO | 100          | 1630.86     |


-- 4.2 Distribuição por material (PREMIUM)
SELECT 
    material,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio
FROM public.v_grupos_premium
GROUP BY material
ORDER BY total_grupos DESC;

| material      | total_grupos | preco_medio |
| ------------- | ------------ | ----------- |
| CR39          | 48           | 4591.26     |
| POLICARBONATO | 12           | 4584.71     |


-- =====================================================
-- 5. ANÁLISE DE ÍNDICE DE REFRAÇÃO
-- =====================================================

-- 5.1 Distribuição por índice (STANDARD)
SELECT 
    indice_refracao,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio
FROM public.v_grupos_canonicos
GROUP BY indice_refracao
ORDER BY indice_refracao;

| indice_refracao | total_grupos | preco_medio |
| --------------- | ------------ | ----------- |
| 1.50            | 54           | 1528.06     |
| 1.56            | 93           | 807.80      |
| 1.59            | 100          | 1630.86     |
| 1.61            | 20           | 583.60      |
| 1.67            | 73           | 3119.27     |
| 1.74            | 61           | 4984.63     |


-- 5.2 Distribuição por índice (PREMIUM)
SELECT 
    indice_refracao,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio
FROM public.v_grupos_premium
GROUP BY indice_refracao
ORDER BY indice_refracao;

| indice_refracao | total_grupos | preco_medio |
| --------------- | ------------ | ----------- |
| 1.50            | 22           | 2554.99     |
| 1.56            | 5            | 1310.63     |
| 1.59            | 14           | 4611.32     |
| 1.67            | 11           | 6943.28     |
| 1.74            | 8            | 8962.44     |


-- =====================================================
-- 6. ANÁLISE DE CATEGORIAS
-- =====================================================

-- 6.1 Distribuição por categoria (STANDARD)
SELECT 
    categoria_predominante,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio
FROM public.v_grupos_canonicos
GROUP BY categoria_predominante
ORDER BY total_grupos DESC;

| categoria_predominante | total_grupos | preco_medio |
| ---------------------- | ------------ | ----------- |
| null                   | 401          | 2155.03     |


-- 6.2 Distribuição por categoria (PREMIUM)
SELECT 
    categoria_predominante,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio
FROM public.v_grupos_premium
GROUP BY categoria_predominante
ORDER BY total_grupos DESC;

| categoria_predominante | total_grupos | preco_medio |
| ---------------------- | ------------ | ----------- |
| null                   | 60           | 4589.95     |


-- =====================================================
-- 7. ANÁLISE DE TRATAMENTOS
-- =====================================================

-- 7.1 Verificar campos de tratamento disponíveis
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_grupos_canonicos'
  AND column_name LIKE '%tratamento%'
ORDER BY column_name;

| column_name               |
| ------------------------- |
| tratamento_antirreflexo   |
| tratamento_antirrisco     |
| tratamento_blue_light     |
| tratamento_fotossensiveis |
| tratamento_uv             |


-- 7.2 Distribuição de tratamentos (STANDARD)
SELECT 
    tratamento_antirreflexo,
    COUNT(*) as total_grupos
FROM public.v_grupos_canonicos
GROUP BY tratamento_antirreflexo
ORDER BY tratamento_antirreflexo;

| tratamento_antirreflexo | total_grupos |
| ----------------------- | ------------ |
| false                   | 187          |
| true                    | 214          |


SELECT 
    tratamento_blue_light,
    COUNT(*) as total_grupos
FROM public.v_grupos_canonicos
GROUP BY tratamento_blue_light
ORDER BY tratamento_blue_light;

| tratamento_blue_light | total_grupos |
| --------------------- | ------------ |
| false                 | 222          |
| true                  | 179          |


SELECT 
    tratamento_fotossensiveis,
    COUNT(*) as total_grupos
FROM public.v_grupos_canonicos
WHERE tratamento_fotossensiveis IS NOT NULL
GROUP BY tratamento_fotossensiveis
ORDER BY total_grupos DESC;

| tratamento_fotossensiveis | total_grupos |
| ------------------------- | ------------ |
| nenhum                    | 332          |
| fotocromático             | 57           |
| polarizado                | 12           |


-- =====================================================
-- 8. ANÁLISE DE PREÇOS
-- =====================================================

-- 8.1 Range geral de preços (STANDARD)
SELECT 
    MIN(preco_minimo) as preco_absoluto_min,
    MAX(preco_maximo) as preco_absoluto_max,
    ROUND(AVG(preco_medio), 2) as preco_medio_geral,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY preco_medio) as preco_mediano
FROM public.v_grupos_canonicos;

| preco_absoluto_min | preco_absoluto_max | preco_medio_geral | preco_mediano |
| ------------------ | ------------------ | ----------------- | ------------- |
| 250.00             | 9600.89            | 2155.03           | 1438.91       |


-- 8.2 Range geral de preços (PREMIUM)
SELECT 
    MIN(preco_minimo) as preco_absoluto_min,
    MAX(preco_maximo) as preco_absoluto_max,
    ROUND(AVG(preco_medio), 2) as preco_medio_geral,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY preco_medio) as preco_mediano
FROM public.v_grupos_premium;

| preco_absoluto_min | preco_absoluto_max | preco_medio_geral | preco_mediano |
| ------------------ | ------------------ | ----------------- | ------------- |
| 410.35             | 9640.00            | 4589.95           | 4619.75       |


-- 8.3 Distribuição de preços em faixas (STANDARD)
SELECT 
    CASE 
        WHEN preco_medio < 50 THEN '< R$ 50'
        WHEN preco_medio < 100 THEN 'R$ 50 - R$ 100'
        WHEN preco_medio < 200 THEN 'R$ 100 - R$ 200'
        WHEN preco_medio < 500 THEN 'R$ 200 - R$ 500'
        ELSE '> R$ 500'
    END as faixa_preco,
    COUNT(*) as total_grupos
FROM public.v_grupos_canonicos
GROUP BY faixa_preco
ORDER BY MIN(preco_medio);

| faixa_preco     | total_grupos |
| --------------- | ------------ |
| R$ 200 - R$ 500 | 89           |
| > R$ 500        | 312          |


-- =====================================================
-- 9. MARCAS - ANÁLISE
-- =====================================================

-- 9.1 Estrutura da tabela de marcas
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'lens_catalog'
  AND table_name = 'marcas'
ORDER BY ordinal_position;

| column_name | data_type                |
| ----------- | ------------------------ |
| id          | uuid                     |
| nome        | character varying        |
| slug        | character varying        |
| is_premium  | boolean                  |
| descricao   | text                     |
| website     | text                     |
| logo_url    | text                     |
| ativo       | boolean                  |
| created_at  | timestamp with time zone |
| updated_at  | timestamp with time zone |


-- 9.2 Total de marcas
SELECT COUNT(*) as total_marcas
FROM lens_catalog.marcas;

| total_marcas |
| ------------ |
| 17           |


-- 9.3 Marcas premium vs standard
SELECT 
    is_premium,
    COUNT(*) as total_marcas
FROM lens_catalog.marcas
WHERE ativo = true
GROUP BY is_premium;

| is_premium | total_marcas |
| ---------- | ------------ |
| false      | 8            |
| true       | 9            |


-- 9.4 Listar todas as marcas ativas
SELECT 
    id,
    nome,
    slug,
    is_premium,
    ativo
FROM lens_catalog.marcas
WHERE ativo = true
ORDER BY is_premium DESC, nome;

| id                                   | nome        | slug        | is_premium | ativo |
| ------------------------------------ | ----------- | ----------- | ---------- | ----- |
| befba165-0aa0-496f-bfdf-774bfe94a856 | CRIZAL      | crizal      | true       | true  |
| bbe5a62d-1d7d-4d93-87af-0dbde68c0645 | ESSILOR     | essilor     | true       | true  |
| 852e5fb8-8eae-4805-a5cb-a5a1e8638f5c | HOYA        | hoya        | true       | true  |
| a6091278-c827-40ea-a2fb-dcc26f1c8d20 | KODAK       | kodak       | true       | true  |
| 6c37f0a1-487c-4bb1-a065-c9498172cbfe | LENSCOPE    | lenscope    | true       | true  |
| d92921ad-1b9d-4f5f-93e1-3e75e4375f09 | RODENSTOCK  | rodenstock  | true       | true  |
| 3f8ac428-2224-415e-8a20-c9e6879754d3 | TRANSITIONS | transitions | true       | true  |
| 3f70213e-0b45-4f42-907a-28f7e7ac51c0 | VARILUX     | varilux     | true       | true  |
| a8ee9f1e-53d9-41ed-bc68-9c4a9881e828 | ZEISS       | zeiss       | true       | true  |
| 98deae91-ee66-4c32-8a5d-8a6f83681993 | BRASCOR     | brascor     | false      | true  |
| d53785a4-37a2-48d1-b807-d172a31417ff | BRASLENTES  | braslentes  | false      | true  |
| 7bf35e08-7a88-4547-a06a-a6ce62fcc827 | EXPRESS     | express     | false      | true  |
| 7f1aa237-edaf-4376-8b91-6c93c3c079a4 | GENÉRICA    | generica    | false      | true  |
| e7ef4c94-a80a-492f-9195-24e6ab2f5056 | POLYLUX     | polylux     | false      | true  |
| 4af04ba6-e600-4874-b8dc-45a2e1773725 | SO BLOCOS   | so-blocos   | false      | true  |
| 731a86d5-2d61-42ca-9533-1af470184bad | STYLE       | style       | false      | true  |
| 57fc0111-0a99-4642-8b66-f1d87a79afce | SYGMA       | sygma       | false      | true  |


-- 9.5 Marcas disponíveis em grupos premium (JSONB)
-- Exemplo de como acessar o array de marcas
SELECT 
    id,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    preco_medio,
    total_lentes,
    total_marcas,
    marcas_disponiveis -- Array JSONB com marcas
FROM public.v_grupos_premium_marcas
LIMIT 5;

Error: Failed to run sql query: ERROR: 42P01: relation "public.v_grupos_premium_marcas" does not exist LINE 11: FROM public.v_grupos_premium_marcas ^


-- =====================================================
-- 10. FORNECEDORES
-- =====================================================

-- 10.1 Estrutura da view de fornecedores
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_fornecedores_catalogo'
ORDER BY ordinal_position;

| column_name         | data_type                |
| ------------------- | ------------------------ |
| id                  | uuid                     |
| nome                | text                     |
| razao_social        | text                     |
| prazo_visao_simples | integer                  |
| prazo_multifocal    | integer                  |
| prazo_surfacada     | integer                  |
| prazo_free_form     | integer                  |
| total_lentes        | bigint                   |
| total_marcas        | bigint                   |
| preco_minimo        | numeric                  |
| preco_maximo        | numeric                  |
| preco_medio         | numeric                  |
| email_contato       | text                     |
| telefone_contato    | text                     |
| config_frete        | jsonb                    |
| badge_prazo         | text                     |
| ativo               | boolean                  |
| created_at          | timestamp with time zone |



-- 10.2 Total de fornecedores ativos
SELECT COUNT(*) as total_fornecedores
FROM public.v_fornecedores_catalogo
WHERE ativo = true;

| total_fornecedores |
| ------------------ |
| 11                 |


-- 10.3 Listar fornecedores com estatísticas
SELECT 
    id,
    nome,
    prazo_visao_simples,
    prazo_multifocal,
    total_lentes,
    total_marcas,
    preco_medio
FROM public.v_fornecedores_catalogo
WHERE ativo = true
ORDER BY total_lentes DESC;

| id                                   | nome                   | prazo_visao_simples | prazo_multifocal | total_lentes | total_marcas | preco_medio           |
| ------------------------------------ | ---------------------- | ------------------- | ---------------- | ------------ | ------------ | --------------------- |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | So Blocos              | 7                   | 10               | 1097         | 2            | 4305.5264083865086600 |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Polylux                | 7                   | 10               | 158          | 4            | 1177.1189873417721519 |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express                | 3                   | 5                | 84           | 4            | 852.2746428571428571  |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Brascor                | 7                   | 10               | 58           | 2            | 599.3677586206896552  |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Sygma                  | 7                   | 10               | 14           | 1            | 330.0335714285714286  |
| e4a24408-3d58-4fc7-a096-cf7140f4f248 | Galeria Florencio lj11 | 7                   | 10               | 0            | 0            | null                  |
| 1d0b088f-dcb1-4179-9a18-5d67ce86c4b6 | Sao Paulo Acessorios   | 7                   | 10               | 0            | 0            | null                  |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | Style                  | 7                   | 10               | 0            | 0            | null                  |
| d90bebaf-e552-4cf0-a226-808c91bda73a | Kaizi Oculos Solares   | 7                   | 10               | 0            | 0            | null                  |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | Braslentes             | 10                  | 12               | 0            | 0            | null                  |
| c50ea6eb-a420-4cf7-8aa2-68aaeb41ac95 | Navarro Oculos         | 7                   | 10               | 0            | 0            | null                  |


-- =====================================================
-- 11. LENTES INDIVIDUAIS (v_lentes_catalogo)
-- =====================================================
este no frontend não vamos usar, vamso sempre focar nas canonicas, esta somente no sistema de escolha de clientes e na compra de lentes

-- 11.1 Total de lentes no catálogo
SELECT COUNT(*) as total_lentes
FROM public.v_lentes_catalogo
WHERE ativo = true;

| total_lentes |
| ------------ |
| 1411         |


-- 11.2 Distribuição por tipo
SELECT 
    tipo_lente,
    COUNT(*) as total_lentes
FROM public.v_lentes_catalogo
WHERE ativo = true
GROUP BY tipo_lente
ORDER BY total_lentes DESC;

| tipo_lente    | total_lentes |
| ------------- | ------------ |
| multifocal    | 957          |
| visao_simples | 452          |
| bifocal       | 2            |


-- 11.3 Exemplo de lentes com todos os campos
SELECT 
    id,
    nome_lente,
    tipo_lente,
    material,
    indice_refracao,
    categoria,
    preco_venda_sugerido,
    marca_nome,
    fornecedor_nome,
    tratamento_antirreflexo,
    tratamento_blue_light,
    tratamento_fotossensiveis
FROM public.v_lentes_catalogo
WHERE ativo = true
LIMIT 10;

tirei o is premium

| id                                   | nome_lente                            | tipo_lente    | material      | indice_refracao | categoria | preco_venda_sugerido | marca_nome | fornecedor_nome | tratamento_antirreflexo | tratamento_blue_light | tratamento_fotossensiveis |
| ------------------------------------ | ------------------------------------- | ------------- | ------------- | --------------- | --------- | -------------------- | ---------- | --------------- | ----------------------- | --------------------- | ------------------------- |
| 58edb8fb-4283-4d84-b7e8-663a3c8a5cc1 | LT 1.59 POLICARBONATO INCOLOR         | visao_simples | POLICARBONATO | 1.59            | economica | 250.00               | EXPRESS    | Express         | false                   | false                 | nenhum                    |
| 13e50463-bba2-4163-b242-2d2a1bd067fe | LT CR 1.49 INCOLOR (TINTAVEL)         | visao_simples | CR39          | 1.50            | economica | 250.00               | EXPRESS    | Express         | false                   | false                 | nenhum                    |
| 59828728-37d1-4c3b-9780-a2fce84a0b34 | LT CR AR 1.56                         | visao_simples | CR39          | 1.56            | economica | 253.91               | EXPRESS    | Express         | true                    | false                 | nenhum                    |
| 3d656633-f8cc-4e48-af26-d2a9f1408f8c | LT CR 1.49 Incolor (TINTÁVEL)         | visao_simples | CR39          | 1.50            | economica | 255.87               | SYGMA      | Sygma           | false                   | false                 | nenhum                    |
| 82cee871-8c04-4841-b3b9-7ca6d1d1286a | CR 1.56 AR                            | visao_simples | CR39          | 1.56            | economica | 261.73               | POLYLUX    | Polylux         | true                    | false                 | nenhum                    |
| 561e46cc-1077-45e8-b8d5-3b4248647d47 | LENTE AC. COM AR 1.56                 | visao_simples | CR39          | 1.56            | economica | 264.86               | BRASCOR    | Brascor         | true                    | false                 | nenhum                    |
| 7b1522de-1735-4a39-b13c-7c07fff0855b | CR 1.56 INCOLOR TINTAVEL 1            | visao_simples | CR39          | 1.56            | economica | 265.64               | POLYLUX    | Polylux         | false                   | false                 | nenhum                    |
| b1e29c04-b108-4b5b-ab95-4186fd639849 | LT CR AR 1.56 BLUE (RESIDUAL AZUL)    | visao_simples | CR39          | 1.56            | economica | 265.64               | EXPRESS    | Express         | false                   | true                  | nenhum                    |
| 919b83ab-8d88-4032-ab09-f1f4811be1df | LT CR AR 1.56                         | visao_simples | CR39          | 1.56            | economica | 265.64               | SYGMA      | Sygma           | true                    | false                 | nenhum                    |
| e41d8dfd-396e-47c0-b74e-a3d45c7386c7 | LT CR AR 1.56 BLUE (RESIDUAL VERDE)   | visao_simples | CR39          | 1.56            | economica | 265.64               | EXPRESS    | Express         | false                   | true                  | nenhum                    |


-- =====================================================
-- 12. RANGES DE GRAU (GRUPOS CANÔNICOS)
-- =====================================================

-- 12.1 Verificar campos de range disponíveis
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_grupos_canonicos_completos'
  AND (column_name LIKE '%grau%' OR column_name LIKE '%adicao%')
ORDER BY column_name;



Success. No rows returned

temos estas view com os dados de grau:

create view public.v_grupos_por_receita_cliente as
select
  gc.id as grupo_id,
  gc.slug as grupo_slug,
  gc.nome_grupo,
  gc.tipo_lente,
  gc.material,
  gc.indice_refracao,
  min(l.grau_esferico_min) as grau_esferico_min,
  max(l.grau_esferico_max) as grau_esferico_max,
  min(l.grau_cilindrico_min) as grau_cilindrico_min,
  max(l.grau_cilindrico_max) as grau_cilindrico_max,
  min(l.adicao_min) as adicao_min,
  max(l.adicao_max) as adicao_max,
  gc.tratamento_antirreflexo,
  gc.tratamento_antirrisco,
  gc.tratamento_uv,
  gc.tratamento_blue_light,
  gc.tratamento_fotossensiveis,
  gc.preco_minimo,
  gc.preco_medio,
  gc.preco_maximo,
  avg(l.preco_custo) as custo_medio,
  case
    when avg(l.preco_custo) > 0::numeric then (gc.preco_medio / avg(l.preco_custo))::numeric(5, 2)
    else null::numeric
  end as margem_media,
  case
    when gc.preco_medio < 150::numeric then 'economica'::text
    when gc.preco_medio >= 150::numeric
    and gc.preco_medio <= 400::numeric then 'intermediaria'::text
    else 'premium'::text
  end as categoria_sugerida,
  gc.total_lentes,
  count(distinct l.fornecedor_id) as total_fornecedores,
  count(distinct l.marca_id) as total_marcas,
  gc.is_premium,
  avg(
    case gc.tipo_lente
      when 'visao_simples'::lens_catalog.tipo_lente then COALESCE(f.prazo_visao_simples, 7)
      when 'multifocal'::lens_catalog.tipo_lente then COALESCE(f.prazo_multifocal, 10)
      when 'bifocal'::lens_catalog.tipo_lente then COALESCE(f.prazo_multifocal, 10)
      when 'leitura'::lens_catalog.tipo_lente then COALESCE(f.prazo_visao_simples, 7)
      when 'ocupacional'::lens_catalog.tipo_lente then COALESCE(f.prazo_multifocal, 10)
      else 10
    end
  )::integer as prazo_medio_dias
from
  lens_catalog.grupos_canonicos gc
  join lens_catalog.lentes l on l.grupo_canonico_id = gc.id
  and l.ativo = true
  left join core.fornecedores f on f.id = l.fornecedor_id
group by
  gc.id,
  gc.slug,
  gc.nome_grupo,
  gc.tipo_lente,
  gc.material,
  gc.indice_refracao,
  gc.tratamento_antirreflexo,
  gc.tratamento_antirrisco,
  gc.tratamento_uv,
  gc.tratamento_blue_light,
  gc.tratamento_fotossensiveis,
  gc.preco_minimo,
  gc.preco_medio,
  gc.preco_maximo,
  gc.total_lentes,
  gc.is_premium
order by
  gc.preco_medio;


SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_grupos_por_receita_cliente'
  AND (column_name LIKE '%grau%' OR column_name LIKE '%adicao%')
ORDER BY column_name;




| column_name         |
| ------------------- |
| adicao_max          |
| adicao_min          |
| grau_cilindrico_max |
| grau_cilindrico_min |
| grau_esferico_max   |
| grau_esferico_min   |



-- 12.2 Estatísticas de ranges (STANDARD)
SELECT 
    COUNT(*) as total_grupos,
    MIN(grau_esferico_min) as esf_min_absoluto,
    MAX(grau_esferico_max) as esf_max_absoluto,
    MIN(grau_cilindrico_min) as cil_min_absoluto,
    MAX(grau_cilindrico_max) as cil_max_absoluto
FROM public.v_grupos_por_receita_cliente;

mudei aqui tbm

| total_grupos | esf_min_absoluto | esf_max_absoluto | cil_min_absoluto | cil_max_absoluto |
| ------------ | ---------------- | ---------------- | ---------------- | ---------------- |
| 461          | -24.00           | 12.00            | -8.00            | 4.00             |


-- =====================================================
-- 13. COMBINAÇÕES MAIS COMUNS
-- =====================================================

-- 13.1 Top 10 combinações Tipo + Material (STANDARD)
SELECT 
    tipo_lente,
    material,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio
FROM public.v_grupos_canonicos_completos
GROUP BY tipo_lente, material
ORDER BY total_grupos DESC
LIMIT 10;


| tipo_lente    | material      | total_grupos | preco_medio |
| ------------- | ------------- | ------------ | ----------- |
| visao_simples | CR39          | 180          | 1772.63     |
| multifocal    | CR39          | 168          | 3582.35     |
| multifocal    | POLICARBONATO | 60           | 2527.77     |
| visao_simples | POLICARBONATO | 52           | 1277.62     |
| bifocal       | CR39          | 1            | 555.05      |


-- 13.2 Top 10 combinações Tipo + Material (PREMIUM)
SELECT 
    tipo_lente,
    material,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio
FROM public.v_grupos_premium_marcas
GROUP BY tipo_lente, material
ORDER BY total_grupos DESC
LIMIT 10;

Error: Failed to run sql query: ERROR: 42P01: relation "public.v_grupos_premium_marcas" does not exist LINE 7: FROM public.v_grupos_premium_marcas ^


-- 13.3 Top 10 combinações Material + Índice (STANDARD)
SELECT 
    material,
    indice_refracao,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio
FROM public.v_grupos_canonicos_completos
GROUP BY material, indice_refracao
ORDER BY total_grupos DESC
LIMIT 10;

| material      | indice_refracao | total_grupos | preco_medio |
| ------------- | --------------- | ------------ | ----------- |
| POLICARBONATO | 1.59            | 112          | 1947.34     |
| CR39          | 1.56            | 98           | 833.46      |
| CR39          | 1.67            | 84           | 3620.04     |
| CR39          | 1.50            | 76           | 1825.33     |
| CR39          | 1.74            | 69           | 5445.82     |
| CR39          | 1.61            | 20           | 583.60      |
| CR39          | 1.59            | 2            | 4770.97     |


-- =====================================================
-- 14. CAMPOS PARA FILTROS - VALORES ÚNICOS
-- =====================================================

-- 14.1 Tipos de lente disponíveis
SELECT DISTINCT tipo_lente
FROM public.v_grupos_canonicos_completos
ORDER BY tipo_lente;

| tipo_lente    |
| ------------- |
| visao_simples |
| multifocal    |
| bifocal       |


-- 14.2 Materiais disponíveis
SELECT DISTINCT material
FROM public.v_grupos_canonicos
ORDER BY material;

| material      |
| ------------- |
| CR39          |
| POLICARBONATO |


-- 14.3 Índices de refração disponíveis
SELECT DISTINCT indice_refracao
FROM public.v_grupos_canonicos
ORDER BY indice_refracao;

| indice_refracao |
| --------------- |
| 1.50            |
| 1.56            |
| 1.59            |
| 1.61            |
| 1.67            |
| 1.74            |


-- 14.4 Tratamentos fotossensíveis disponíveis
SELECT DISTINCT tratamento_fotossensiveis
FROM public.v_grupos_canonicos
WHERE tratamento_fotossensiveis IS NOT NULL
ORDER BY tratamento_fotossensiveis;

| tratamento_fotossensiveis |
| ------------------------- |
| fotocromático             |
| nenhum                    |
| polarizado                |


-- =====================================================
-- 15. QUERIES ÚTEIS PARA FRONTEND
-- =====================================================

-- 15.1 Top 10 grupos STANDARD mais populares (por total de lentes)
SELECT 
    g.id,
    g.nome_grupo,
    g.tipo_lente,
    g.material,
    g.indice_refracao,
    g.preco_medio,
    g.preco_minimo,
    g.preco_maximo,
    g.total_lentes,
    g.total_marcas,
    g.tratamento_antirreflexo,
    g.tratamento_blue_light,
    g.tratamento_fotossensiveis,
    g.is_premium
FROM public.v_grupos_canonicos g
ORDER BY g.total_lentes DESC
LIMIT 10;

| id                                   | nome_grupo                                                                                    | tipo_lente    | material      | indice_refracao | preco_medio | preco_minimo | preco_maximo | total_lentes | total_marcas | tratamento_antirreflexo | tratamento_blue_light | tratamento_fotossensiveis | is_premium |
| ------------------------------------ | --------------------------------------------------------------------------------------------- | ------------- | ------------- | --------------- | ----------- | ------------ | ------------ | ------------ | ------------ | ----------------------- | --------------------- | ------------------------- | ---------- |
| d299f609-1a4b-4f30-8cb2-4b89f8b2432f | Lente CR39 1.50 Multifocal +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                          | multifocal    | CR39          | 1.50            | 2620.31     | 1622.72      | 3539.04      | 36           | 1            | false                   | false                 | nenhum                    | false      |
| f4c8c969-cc42-48c8-9bef-c44016499bfe | Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]     | multifocal    | POLICARBONATO | 1.59            | 3218.35     | 2209.35      | 4086.56      | 30           | 1            | false                   | true                  | nenhum                    | false      |
| 48200988-d861-4d4d-96e3-8cfec2266a0c | Lente CR39 1.67 Multifocal +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                         | multifocal    | CR39          | 1.67            | 5437.77     | 4360.32      | 7137.04      | 24           | 1            | false                   | false                 | nenhum                    | false      |
| 8f6e593f-b790-4099-9f87-a659cbecabb8 | Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                      | multifocal    | CR39          | 1.50            | 2424.77     | 1857.37      | 2975.88      | 24           | 1            | true                    | false                 | nenhum                    | false      |
| 81cee1fd-ae9c-4e89-b732-279f641ece54 | Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-10.00/8.00 | -6.00/0.00 | 0.50/4.50] | multifocal    | POLICARBONATO | 1.59            | 3022.81     | 2444.00      | 3523.40      | 20           | 1            | true                    | true                  | nenhum                    | false      |
| df1ce9bf-3df7-46d4-b31f-91e9df808ec8 | Lente CR39 1.67 Multifocal +AR +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                     | multifocal    | CR39          | 1.67            | 5242.23     | 4594.98      | 6573.88      | 16           | 1            | true                    | false                 | nenhum                    | false      |
| e7d5ac87-422e-49b4-9138-0f510f1fe901 | Lente CR39 1.56 Multifocal +UV +BlueLight [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]               | multifocal    | CR39          | 1.56            | 2795.98     | 1896.48      | 3460.82      | 15           | 1            | false                   | true                  | nenhum                    | false      |
| cd26d0bf-e40d-45c4-b700-d4f51ab28616 | Lente POLICARBONATO 1.59 Multifocal +UV [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]                | multifocal    | POLICARBONATO | 1.59            | 2874.19     | 2209.35      | 3460.82      | 15           | 1            | false                   | false                 | nenhum                    | false      |
| 585b3e13-ab8c-437c-9be5-716692a538bb | Lente POLICARBONATO 1.59 Visao Simples +UV +BlueLight [-10.00/8.00 | -6.00/0.00]              | visao_simples | POLICARBONATO | 1.59            | 3237.90     | 2287.56      | 4125.67      | 12           | 1            | false                   | true                  | nenhum                    | false      |
| 21aec937-a884-4041-b613-55318bee760d | Lente CR39 1.67 Multifocal +UV [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]                         | multifocal    | CR39          | 1.67            | 5134.68     | 4203.89      | 6002.89      | 12           | 1            | false                   | false                 | nenhum                    | false      |


-- 15.2 Top 10 grupos PREMIUM mais populares (por total de lentes)
SELECT 
    g.id,
    g.nome_grupo,
    g.tipo_lente,
    g.material,
    g.indice_refracao,
    g.preco_medio,
    g.preco_minimo,
    g.preco_maximo,
    g.total_lentes,
    g.total_marcas,
    g.marcas_disponiveis, -- Array JSONB com marcas
    g.marcas_nomes,
    g.is_premium
FROM public.v_grupos_premium g
ORDER BY g.total_lentes DESC
LIMIT 10;

| id                                   | nome_grupo                                                                                        | tipo_lente    | material      | indice_refracao | preco_medio | preco_minimo | preco_maximo | total_lentes | total_marcas | marcas_disponiveis                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | marcas_nomes                            | is_premium |
| ------------------------------------ | ------------------------------------------------------------------------------------------------- | ------------- | ------------- | --------------- | ----------- | ------------ | ------------ | ------------ | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- | ---------- |
| f4352d04-8970-4939-8a8b-ec4e0f172a08 | Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]               | multifocal    | CR39          | 1.50            | 4750.11     | 4086.56      | 5377.15      | 36           | 1            | [{"marca_id":"3f8ac428-2224-415e-8a20-c9e6879754d3","is_premium":true,"marca_nome":"TRANSITIONS","marca_slug":"transitions"}]                                                                                                                                                                                                                                                                                                                                                                 | TRANSITIONS                             | true       |
| 1355a3cb-7e0d-4512-85fb-93322feb8aa6 | Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]           | multifocal    | CR39          | 1.50            | 4554.57     | 4321.22      | 4813.99      | 24           | 1            | [{"marca_id":"3f8ac428-2224-415e-8a20-c9e6879754d3","is_premium":true,"marca_nome":"TRANSITIONS","marca_slug":"transitions"}]                                                                                                                                                                                                                                                                                                                                                                 | TRANSITIONS                             | true       |
| e47ca0ed-48a9-4ad7-b2ca-e756a67a2fd9 | Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]     | multifocal    | POLICARBONATO | 1.59            | 5377.15     | 4673.19      | 5983.34      | 15           | 1            | [{"marca_id":"3f8ac428-2224-415e-8a20-c9e6879754d3","is_premium":true,"marca_nome":"TRANSITIONS","marca_slug":"transitions"}]                                                                                                                                                                                                                                                                                                                                                                 | TRANSITIONS                             | true       |
| 993119bf-4d3f-463b-a9a1-4f06bfcf3f40 | Lente CR39 1.50 Visao Simples +UV +fotocromático [-8.00/6.50 | -6.00/0.00]                        | visao_simples | CR39          | 1.50            | 4684.93     | 4164.78      | 5142.50      | 12           | 1            | [{"marca_id":"3f8ac428-2224-415e-8a20-c9e6879754d3","is_premium":true,"marca_nome":"TRANSITIONS","marca_slug":"transitions"}]                                                                                                                                                                                                                                                                                                                                                                 | TRANSITIONS                             | true       |
| a3b374a0-3fcd-498e-b5bd-28ee12a3ed37 | Lente POLICARBONATO 1.59 Multifocal +AR +UV +fotocromático [-10.00/8.00 | -6.00/0.00 | 0.50/4.50] | multifocal    | POLICARBONATO | 1.59            | 5181.61     | 4907.85      | 5420.17      | 10           | 1            | [{"marca_id":"3f8ac428-2224-415e-8a20-c9e6879754d3","is_premium":true,"marca_nome":"TRANSITIONS","marca_slug":"transitions"}]                                                                                                                                                                                                                                                                                                                                                                 | TRANSITIONS                             | true       |
| 2b2bae8b-6c65-4dc9-919b-b309be7387e7 | Lente CR39 1.50 Visao Simples +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00]                    | visao_simples | CR39          | 1.50            | 4489.38     | 4399.43      | 4579.33      | 8            | 1            | [{"marca_id":"3f8ac428-2224-415e-8a20-c9e6879754d3","is_premium":true,"marca_nome":"TRANSITIONS","marca_slug":"transitions"}]                                                                                                                                                                                                                                                                                                                                                                 | TRANSITIONS                             | true       |
| 0d592228-5b78-462d-96f6-846af9de46e0 | Lente CR39 1.50 Multifocal +UV +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]               | multifocal    | CR39          | 1.50            | 2638.42     | 914.85       | 5807.35      | 7            | 4            | [{"marca_id":"3f70213e-0b45-4f42-907a-28f7e7ac51c0","is_premium":true,"marca_nome":"VARILUX","marca_slug":"varilux"},{"marca_id":"3f8ac428-2224-415e-8a20-c9e6879754d3","is_premium":true,"marca_nome":"TRANSITIONS","marca_slug":"transitions"},{"marca_id":"7f1aa237-edaf-4376-8b91-6c93c3c079a4","is_premium":false,"marca_nome":"GENÉRICA","marca_slug":"generica"},{"marca_id":"e7ef4c94-a80a-492f-9195-24e6ab2f5056","is_premium":false,"marca_nome":"POLYLUX","marca_slug":"polylux"}] | GENÉRICA, POLYLUX, TRANSITIONS, VARILUX | true       |
| 452e62f3-5b39-455d-b301-f2094f0ee7d4 | Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]               | multifocal    | CR39          | 1.50            | 3374.78     | 2874.19      | 3812.80      | 6            | 1            | [{"marca_id":"3f8ac428-2224-415e-8a20-c9e6879754d3","is_premium":true,"marca_nome":"TRANSITIONS","marca_slug":"transitions"}]                                                                                                                                                                                                                                                                                                                                                                 | TRANSITIONS                             | true       |
| 24cb65f7-a9aa-475c-8544-7ff0df4ae933 | Lente POLICARBONATO 1.59 Visao Simples +UV +fotocromático [-10.00/8.00 | -6.00/0.00]              | visao_simples | POLICARBONATO | 1.59            | 5291.11     | 4770.97      | 5748.68      | 6            | 1            | [{"marca_id":"3f8ac428-2224-415e-8a20-c9e6879754d3","is_premium":true,"marca_nome":"TRANSITIONS","marca_slug":"transitions"}]                                                                                                                                                                                                                                                                                                                                                                 | TRANSITIONS                             | true       |
| c029d8d7-953c-4453-ae8e-f3d1e26ab9b7 | Lente CR39 1.67 Visao Simples +UV +fotocromático [-13.00/9.00 | -6.00/0.00]                       | visao_simples | CR39          | 1.67            | 7344.32     | 6824.17      | 7801.89      | 6            | 1            | [{"marca_id":"3f8ac428-2224-415e-8a20-c9e6879754d3","is_premium":true,"marca_nome":"TRANSITIONS","marca_slug":"transitions"}]                                                                                                                                                                                                                                                                                                                                                                 | TRANSITIONS                             | true       |


-- 15.3 Grupos mais baratos (STANDARD)
SELECT 
    g.id,
    g.nome_grupo,
    g.tipo_lente,
    g.material,
    g.indice_refracao,
    g.preco_medio,
    g.total_lentes
FROM public.v_grupos_canonicos g
ORDER BY g.preco_medio ASC
LIMIT 10;

| id                                   | nome_grupo                                                             | tipo_lente    | material      | indice_refracao | preco_medio | total_lentes |
| ------------------------------------ | ---------------------------------------------------------------------- | ------------- | ------------- | --------------- | ----------- | ------------ |
| 30d581c1-4b46-41a8-b4a5-6653c862ec7a | Lente CR39 1.50 Visao Simples +UV [-6.00/6.00 | 0.00/-2.00]            | visao_simples | CR39          | 1.50            | 250.00      | 1            |
| 573729aa-91b7-4f74-b2dc-00e5bcd9ea34 | Lente POLICARBONATO 1.59 Visao Simples +UV [-10.00/6.00 | 0.00/-2.00]  | visao_simples | POLICARBONATO | 1.59            | 250.00      | 1            |
| 62d675b2-e9b2-47d3-b98f-9ff53b26eca7 | Lente CR39 1.56 Visao Simples +AR +UV [-8.00/6.00 | 0.00/-2.00]        | visao_simples | CR39          | 1.56            | 253.91      | 1            |
| 928ddd31-a900-4340-8d3f-094e68538524 | Lente CR39 1.50 Visao Simples +UV [-6.00/6.00 | -2.00/2.00]            | visao_simples | CR39          | 1.50            | 255.87      | 1            |
| 14a2d496-3947-4b9e-9ff2-aff781d7cee3 | Lente CR39 1.56 Visao Simples +AR +UV [-8.00/6.00 | -2.00/0.00]        | visao_simples | CR39          | 1.56            | 261.73      | 1            |
| 7ae84a5b-46b9-488b-a0fb-5c35bdcdc9f7 | Lente CR39 1.56 Visao Simples +UV +BlueLight [-6.00/6.00 | 0.00/-2.00] | visao_simples | CR39          | 1.56            | 265.64      | 2            |
| 4c50219d-9140-4a59-b30b-c0adadd43051 | Lente CR39 1.56 Visao Simples +UV [-6.00/6.00 | -2.00/0.00]            | visao_simples | CR39          | 1.56            | 265.64      | 1            |
| 636a8f30-bebb-4553-ac8b-505b4d897ecb | Lente CR39 1.50 Visao Simples +AR +UV [-4.00/4.00 | 0.00/-2.00]        | visao_simples | CR39          | 1.50            | 267.60      | 1            |
| 3ee458a1-b0da-4b18-b55f-5160eb57f8ee | Lente POLICARBONATO 1.59 Visao Simples +UV [-6.00/6.00 | -2.25/-4.00]  | visao_simples | POLICARBONATO | 1.59            | 273.47      | 1            |
| a47e13a0-4e6a-4153-bf54-78e534e58e6b | Lente CR39 1.56 Visao Simples +AR +UV [-6.00/6.00 | -2.25/-4.00]       | visao_simples | CR39          | 1.56            | 273.47      | 2            |


-- 15.4 Grupos mais baratos (PREMIUM)
SELECT 
    g.id,
    g.nome_grupo,
    g.tipo_lente,
    g.material,
    g.indice_refracao,
    g.preco_medio,
    g.total_lentes,
    g.marcas_nomes
FROM public.v_grupos_premium g
ORDER BY g.preco_medio ASC
LIMIT 10;

| id                                   | nome_grupo                                                                              | tipo_lente    | material | indice_refracao | preco_medio | total_lentes | marcas_nomes            |
| ------------------------------------ | --------------------------------------------------------------------------------------- | ------------- | -------- | --------------- | ----------- | ------------ | ----------------------- |
| b041ad01-b262-47f1-8d72-0487f42d6d39 | Lente CR39 1.50 Multifocal +UV [-6.00/6.00 | 0.00/-4.00 | 1.00/3.50]                    | multifocal    | CR39     | 1.50            | 508.12      | 2            | SYGMA, VARILUX          |
| d5df1018-c6e1-4afc-864e-e472183a66cb | Lente CR39 1.56 Multifocal +UV [-6.00/6.00 | 0.00/-4.00 | 1.00/3.50]                    | multifocal    | CR39     | 1.56            | 684.11      | 1            | VARILUX                 |
| ed2f6838-6ee7-47f8-a1a1-f65f55b91525 | Lente CR39 1.56 Multifocal +UV +fotocromático [-5.00/6.00 | 0.00/-4.00 | 1.00/3.00]     | multifocal    | CR39     | 1.56            | 695.84      | 5            | EXPRESS, SYGMA, VARILUX |
| 520981ba-b797-4934-920e-7d7630c835c7 | Lente CR39 1.50 Visao Simples +UV +fotocromático [2.25/4.00 | -2.25/-4.00]              | visao_simples | CR39     | 1.50            | 977.42      | 1            | TRANSITIONS             |
| 6604b87e-a01f-47d0-bb99-04cfb6a16736 | Lente CR39 1.50 Visao Simples +AR +UV +fotocromático [-2.00/2.00 | 0.00/-2.00]          | visao_simples | CR39     | 1.50            | 977.42      | 1            | TRANSITIONS             |
| 885df9ba-8446-4a00-a29d-3c95b11a69d0 | Lente CR39 1.56 Visao Simples +UV +fotocromático [-4.00/4.00 | -2.00/0.00]              | visao_simples | CR39     | 1.56            | 996.98      | 1            | TRANSITIONS             |
| 42a074d3-3ec6-4995-a55a-561a8e384fd0 | Lente CR39 1.50 Visao Simples +UV +fotocromático [-10.00/12.00 | 0.00/-6.00]            | visao_simples | CR39     | 1.50            | 1075.19     | 1            | TRANSITIONS             |
| a9f93bb3-7f0d-448e-9278-b204c3c5e614 | Lente CR39 1.50 Visao Simples +UV +fotocromático [-6.00/6.00 | -4.00/0.00]              | visao_simples | CR39     | 1.50            | 1075.20     | 2            | POLYLUX, TRANSITIONS    |
| d866c17c-bb77-4a23-8add-ed612b86afcb | Lente CR39 1.50 Visao Simples +AR +UV +fotocromático [-6.00/6.00 | -4.00/0.00]          | visao_simples | CR39     | 1.50            | 1305.94     | 2            | POLYLUX, TRANSITIONS    |
| bac7a06e-5415-4cfb-a1bc-175d7d771ce6 | Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50] | multifocal    | CR39     | 1.50            | 1345.05     | 2            | POLYLUX, TRANSITIONS    |


-- 15.5 Grupos com tratamento completo (AR + Blue + UV)
SELECT 
    g.id,
    g.nome_grupo,
    g.tipo_lente,
    g.material,
    g.indice_refracao,
    g.preco_medio,
    g.tratamento_antirreflexo,
    g.tratamento_blue_light,
    g.tratamento_uv,
    g.is_premium
FROM public.v_grupos_canonicos g
WHERE g.tratamento_antirreflexo = true
  AND g.tratamento_blue_light = true
  AND g.tratamento_uv = true
ORDER BY g.preco_medio ASC
LIMIT 10;

| id                                   | nome_grupo                                                                                 | tipo_lente    | material      | indice_refracao | preco_medio | tratamento_antirreflexo | tratamento_blue_light | tratamento_uv | is_premium |
| ------------------------------------ | ------------------------------------------------------------------------------------------ | ------------- | ------------- | --------------- | ----------- | ----------------------- | --------------------- | ------------- | ---------- |
| 27fcd3ef-e6f4-495d-a91e-27e7f92f513f | Lente CR39 1.56 Visao Simples +AR +UV +BlueLight [-6.00/4.00 | -2.00/0.00]                 | visao_simples | CR39          | 1.56            | 289.11      | true                    | true                  | true          | false      |
| 50b7df71-a005-4efa-bbeb-a709bb3551a5 | Lente CR39 1.56 Visao Simples +AR +UV +BlueLight [-6.00/6.00 | -2.25/-4.00]                | visao_simples | CR39          | 1.56            | 293.02      | true                    | true                  | true          | false      |
| e734b14f-c3ab-4cb7-a2ff-a06ab7639eb3 | Lente CR39 1.56 Visao Simples +AR +UV +BlueLight [-6.00/6.00 | -2.00/0.00]                 | visao_simples | CR39          | 1.56            | 312.57      | true                    | true                  | true          | false      |
| 794c2bb9-809c-43a2-b924-ab36a10282ad | Lente CR39 1.56 Visao Simples +AR +UV +BlueLight [-6.00/4.00 | -4.00/-2.25]                | visao_simples | CR39          | 1.56            | 351.68      | true                    | true                  | true          | false      |
| fa1a1540-51b2-46a5-9b19-2d349919b845 | Lente CR39 1.56 Visao Simples +AR +UV +BlueLight [-6.00/6.00 | -4.00/-2.25]                | visao_simples | CR39          | 1.56            | 351.68      | true                    | true                  | true          | false      |
| 1cc6332c-693d-4c38-979b-183261cdc80d | Lente POLICARBONATO 1.59 Visao Simples +AR +UV +BlueLight [-8.00/6.00 | 0.00/-2.00]        | visao_simples | POLICARBONATO | 1.59            | 359.50      | true                    | true                  | true          | false      |
| e04ba6e0-333a-4443-83c6-03337a7f9d4c | Lente POLICARBONATO 1.59 Visao Simples +AR +UV +BlueLight [-8.00/6.00 | -2.00/0.00]        | visao_simples | POLICARBONATO | 1.59            | 367.33      | true                    | true                  | true          | false      |
| 3e3269ff-44ab-4281-b6d5-4b8cb57e003c | Lente CR39 1.56 Multifocal +AR +UV +BlueLight [0.00/3.00 | 0.00/0.00 | 1.00/3.00]          | multifocal    | CR39          | 1.56            | 410.35      | true                    | true                  | true          | false      |
| 75d92061-1fa0-450f-8750-9e1f62638cfd | Lente CR39 1.56 Visao Simples +AR +UV +BlueLight +fotocromático [-6.00/6.00 | -2.25/-4.00] | visao_simples | CR39          | 1.56            | 426.48      | true                    | true                  | true          | false      |
| c6a392fc-10b0-4def-b46e-42a3d77a18e3 | Lente POLICARBONATO 1.59 Visao Simples +AR +UV +BlueLight [-6.00/2.00 | -2.25/-4.00]       | visao_simples | POLICARBONATO | 1.59            | 429.90      | true                    | true                  | true          | false      |


-- 15.6 Distribuição de grupos por combinação de tratamentos
SELECT 
    tratamento_antirreflexo as tem_ar,
    tratamento_blue_light as tem_blue,
    tratamento_uv as tem_uv,
    tratamento_fotossensiveis,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio
FROM public.v_grupos_canonicos
GROUP BY tratamento_antirreflexo, tratamento_blue_light, tratamento_uv, tratamento_fotossensiveis
ORDER BY total_grupos DESC;

| tem_ar | tem_blue | tem_uv | tratamento_fotossensiveis | total_grupos | preco_medio |
| ------ | -------- | ------ | ------------------------- | ------------ | ----------- |
| false  | false    | true   | nenhum                    | 97           | 2262.84     |
| true   | false    | true   | nenhum                    | 85           | 2348.27     |
| true   | true     | true   | nenhum                    | 85           | 2155.34     |
| false  | true     | true   | nenhum                    | 65           | 2609.28     |
| true   | false    | true   | fotocromático             | 20           | 820.40      |
| true   | true     | true   | fotocromático             | 18           | 1053.78     |
| false  | true     | true   | fotocromático             | 11           | 1190.03     |
| false  | false    | true   | fotocromático             | 8            | 1013.60     |
| true   | false    | true   | polarizado                | 6            | 2876.16     |
| false  | false    | true   | polarizado                | 6            | 3071.69     |



-- 15.7 Análise de ranges de grau por tipo de lente
SELECT 
    tipo_lente,
    COUNT(*) as total_grupos,
    MIN(grau_esferico_min) as esf_min,
    MAX(grau_esferico_max) as esf_max,
    MIN(grau_cilindrico_min) as cil_min,
    MAX(grau_cilindrico_max) as cil_max,
    MIN(adicao_min) as adic_min,
    MAX(adicao_max) as adic_max
FROM public.v_grupos_por_receita_cliente
GROUP BY tipo_lente
ORDER BY total_grupos DESC;

| tipo_lente    | total_grupos | esf_min | esf_max | cil_min | cil_max | adic_min | adic_max |
| ------------- | ------------ | ------- | ------- | ------- | ------- | -------- | -------- |
| visao_simples | 232          | -24.00  | 12.00   | -8.00   | 4.00    | 0.00     | 4.50     |
| multifocal    | 228          | -15.00  | 12.00   | -8.00   | 0.00    | 0.00     | 4.50     |
| bifocal       | 1            | -4.00   | 4.00    | -3.00   | 0.00    | 1.00     | 3.00     |


-- 15.8 Grupos com melhor custo-benefício (menor preço, mais lentes disponíveis)
SELECT 
    g.id,
    g.nome_grupo,
    g.tipo_lente,
    g.material,
    g.indice_refracao,
    g.preco_medio,
    g.total_lentes,
    ROUND(g.preco_medio / NULLIF(g.total_lentes, 0), 2) as custo_por_lente
FROM public.v_grupos_canonicos g
WHERE g.total_lentes > 0
ORDER BY custo_por_lente ASC
LIMIT 10;

| id                                   | nome_grupo                                                                                 | tipo_lente    | material      | indice_refracao | preco_medio | total_lentes | custo_por_lente |
| ------------------------------------ | ------------------------------------------------------------------------------------------ | ------------- | ------------- | --------------- | ----------- | ------------ | --------------- |
| d299f609-1a4b-4f30-8cb2-4b89f8b2432f | Lente CR39 1.50 Multifocal +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                       | multifocal    | CR39          | 1.50            | 2620.31     | 36           | 72.79           |
| 50b7df71-a005-4efa-bbeb-a709bb3551a5 | Lente CR39 1.56 Visao Simples +AR +UV +BlueLight [-6.00/6.00 | -2.25/-4.00]                | visao_simples | CR39          | 1.56            | 293.02      | 4            | 73.26           |
| 1a4867c0-40a9-486f-b82a-f009e218ed4d | Lente CR39 1.56 Visao Simples +AR +UV [-8.00/4.00 | 0.00/-2.00]                            | visao_simples | CR39          | 1.56            | 299.27      | 3            | 99.76           |
| 8f6e593f-b790-4099-9f87-a659cbecabb8 | Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                   | multifocal    | CR39          | 1.50            | 2424.77     | 24           | 101.03          |
| 75d92061-1fa0-450f-8750-9e1f62638cfd | Lente CR39 1.56 Visao Simples +AR +UV +BlueLight +fotocromático [-6.00/6.00 | -2.25/-4.00] | visao_simples | CR39          | 1.56            | 426.48      | 4            | 106.62          |
| f4c8c969-cc42-48c8-9bef-c44016499bfe | Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]  | multifocal    | POLICARBONATO | 1.59            | 3218.35     | 30           | 107.28          |
| cdb0fe1e-694d-4c97-9a8f-71f85fc1e5c6 | Lente CR39 1.56 Visao Simples +AR +UV [-6.00/4.00 | -2.25/-4.00]                           | visao_simples | CR39          | 1.56            | 343.86      | 3            | 114.62          |
| 7ae84a5b-46b9-488b-a0fb-5c35bdcdc9f7 | Lente CR39 1.56 Visao Simples +UV +BlueLight [-6.00/6.00 | 0.00/-2.00]                     | visao_simples | CR39          | 1.56            | 265.64      | 2            | 132.82          |
| a47e13a0-4e6a-4153-bf54-78e534e58e6b | Lente CR39 1.56 Visao Simples +AR +UV [-6.00/6.00 | -2.25/-4.00]                           | visao_simples | CR39          | 1.56            | 273.47      | 2            | 136.74          |
| f87cac93-9763-4271-8aa9-f91cd7ef96b4 | Lente CR39 1.56 Visao Simples +UV +BlueLight [-6.00/6.00 | -2.25/-4.00]                    | visao_simples | CR39          | 1.56            | 281.29      | 2            | 140.65          |


-- =====================================================
-- 16. RESUMO EXECUTIVO FINAL
-- =====================================================

-- 16.1 Resumo geral do catálogo (CORRETO)
SELECT 
    'STANDARD' as tipo_grupo,
    COUNT(*) as total_grupos,
    SUM(total_lentes) as total_lentes,
    ROUND(AVG(preco_medio), 2) as preco_medio,
    MIN(preco_minimo) as preco_min,
    MAX(preco_maximo) as preco_max,
    ROUND(AVG(total_marcas), 2) as marcas_media
FROM public.v_grupos_canonicos

UNION ALL

SELECT 
    'PREMIUM' as tipo_grupo,
    COUNT(*) as total_grupos,
    SUM(total_lentes) as total_lentes,
    ROUND(AVG(preco_medio), 2) as preco_medio,
    MIN(preco_minimo) as preco_min,
    MAX(preco_maximo) as preco_max,
    ROUND(AVG(total_marcas), 2) as marcas_media
FROM public.v_grupos_premium;

| tipo_grupo | total_grupos | total_lentes | preco_medio | preco_min | preco_max | marcas_media |
| ---------- | ------------ | ------------ | ----------- | --------- | --------- | ------------ |
| STANDARD   | 401          | 1150         | 2155.03     | 250.00    | 9600.89   | 1.01         |
| PREMIUM    | 60           | 261          | 4589.95     | 410.35    | 9640.00   | 1.20         |


-- 16.2 Distribuição completa por tipo e segmento
SELECT 
    tipo_lente,
    is_premium,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio,
    SUM(total_lentes) as total_lentes_disponiveis
FROM (
    SELECT tipo_lente, is_premium, preco_medio, total_lentes
    FROM public.v_grupos_canonicos
    UNION ALL
    SELECT tipo_lente, is_premium, preco_medio, total_lentes
    FROM public.v_grupos_premium
) grupos
GROUP BY tipo_lente, is_premium
ORDER BY tipo_lente, is_premium DESC;

| tipo_lente    | is_premium | total_grupos | preco_medio | total_lentes_disponiveis |
| ------------- | ---------- | ------------ | ----------- | ------------------------ |
| visao_simples | true       | 14           | 4160.03     | 58                       |
| visao_simples | false      | 218          | 1501.23     | 394                      |
| multifocal    | true       | 46           | 4720.80     | 203                      |
| multifocal    | false      | 182          | 2946.94     | 754                      |
| bifocal       | false      | 1            | 555.05      | 2                        |


-- 16.3 Top 5 materiais + índices mais comuns
SELECT 
    material,
    indice_refracao,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio,
    SUM(total_lentes) as total_lentes
FROM (
    SELECT material, indice_refracao, preco_medio, total_lentes
    FROM public.v_grupos_canonicos
    UNION ALL
    SELECT material, indice_refracao, preco_medio, total_lentes
    FROM public.v_grupos_premium
) grupos
GROUP BY material, indice_refracao
ORDER BY total_grupos DESC
LIMIT 5;


| material      | indice_refracao | total_grupos | preco_medio | total_lentes |
| ------------- | --------------- | ------------ | ----------- | ------------ |
| POLICARBONATO | 1.59            | 112          | 1947.34     | 354          |
| CR39          | 1.56            | 98           | 833.46      | 182          |
| CR39          | 1.67            | 84           | 3620.04     | 286          |
| CR39          | 1.50            | 76           | 1825.33     | 335          |
| CR39          | 1.74            | 69           | 5445.82     | 230          |


-- 16.4 Análise de tratamentos (todos os grupos)
SELECT 
    'Antirreflexo' as tratamento,
    SUM(CASE WHEN tratamento_antirreflexo = true THEN 1 ELSE 0 END) as com_tratamento,
    SUM(CASE WHEN tratamento_antirreflexo = false THEN 1 ELSE 0 END) as sem_tratamento,
    ROUND(100.0 * SUM(CASE WHEN tratamento_antirreflexo = true THEN 1 ELSE 0 END) / COUNT(*), 2) as percentual
FROM (
    SELECT tratamento_antirreflexo FROM public.v_grupos_canonicos
    UNION ALL
    SELECT tratamento_antirreflexo FROM public.v_grupos_premium
) t

UNION ALL

SELECT 
    'Blue Light' as tratamento,
    SUM(CASE WHEN tratamento_blue_light = true THEN 1 ELSE 0 END),
    SUM(CASE WHEN tratamento_blue_light = false THEN 1 ELSE 0 END),
    ROUND(100.0 * SUM(CASE WHEN tratamento_blue_light = true THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM (
    SELECT tratamento_blue_light FROM public.v_grupos_canonicos
    UNION ALL
    SELECT tratamento_blue_light FROM public.v_grupos_premium
) t

UNION ALL

SELECT 
    'UV' as tratamento,
    SUM(CASE WHEN tratamento_uv = true THEN 1 ELSE 0 END),
    SUM(CASE WHEN tratamento_uv = false THEN 1 ELSE 0 END),
    ROUND(100.0 * SUM(CASE WHEN tratamento_uv = true THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM (
    SELECT tratamento_uv FROM public.v_grupos_canonicos
    UNION ALL
    SELECT tratamento_uv FROM public.v_grupos_premium
) t;

| tratamento   | com_tratamento | sem_tratamento | percentual |
| ------------ | -------------- | -------------- | ---------- |
| Antirreflexo | 237            | 224            | 51.41      |
| Blue Light   | 179            | 282            | 38.83      |
| UV           | 461            | 0              | 100.00     |


-- 16.5 Faixas de preço (distribuição completa)
SELECT 
    CASE 
        WHEN preco_medio < 500 THEN '< R$ 500'
        WHEN preco_medio < 1000 THEN 'R$ 500 - R$ 1.000'
        WHEN preco_medio < 2000 THEN 'R$ 1.000 - R$ 2.000'
        WHEN preco_medio < 5000 THEN 'R$ 2.000 - R$ 5.000'
        ELSE '> R$ 5.000'
    END as faixa_preco,
    COUNT(*) as total_grupos,
    ROUND(AVG(preco_medio), 2) as preco_medio_faixa
FROM (
    SELECT preco_medio FROM public.v_grupos_canonicos
    UNION ALL
    SELECT preco_medio FROM public.v_grupos_premium
) grupos
GROUP BY faixa_preco
ORDER BY MIN(preco_medio);

| faixa_preco         | total_grupos | preco_medio_faixa |
| ------------------- | ------------ | ----------------- |
| < R$ 500            | 89           | 366.16            |
| R$ 500 - R$ 1.000   | 88           | 694.31            |
| R$ 1.000 - R$ 2.000 | 73           | 1457.88           |
| R$ 2.000 - R$ 5.000 | 137          | 3327.42           |
| > R$ 5.000          | 74           | 6535.07           |


-- =====================================================
-- CONCLUSÃO DA INVESTIGAÇÃO
-- =====================================================
-- 
-- VIEWS CONFIRMADAS PARA USO:
-- ✅ v_grupos_canonicos (401 grupos STANDARD)
-- ✅ v_grupos_premium (60 grupos PREMIUM)
-- ✅ v_grupos_por_receita_cliente (ranges de grau)
-- ✅ v_fornecedores_catalogo (fornecedores)
-- ✅ v_lentes_catalogo (lentes individuais - apenas para detalhes)
--
-- FILTROS DISPONÍVEIS:
-- 1. Tipo de Lente (3 opções)
-- 2. Material (2 opções: CR39, POLICARBONATO)
-- 3. Índice de Refração (6 opções: 1.50, 1.56, 1.59, 1.61, 1.67, 1.74)
-- 4. Tratamento Antirreflexo (boolean)
-- 5. Tratamento Blue Light (boolean)
-- 6. Tratamento UV (boolean)
-- 7. Tratamento Fotossensível (3 opções: nenhum, fotocromático, polarizado)
-- 8. Faixa de Preço (R$ 250 - R$ 9.640)
-- 9. Segmento (Premium/Standard toggle)
-- 10. Marcas (apenas premium - JSONB array)
--
-- OBSERVAÇÕES IMPORTANTES:
-- - categoria_predominante está NULL em todos os registros
-- - Categorização deve ser feita por faixa de preço
-- - 17 marcas disponíveis (9 premium, 8 standard)
-- - 11 fornecedores ativos
-- - 1.411 lentes individuais
-- - 461 grupos canônicos (401 standard + 60 premium)
--
-- =====================================================
