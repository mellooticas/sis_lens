-- ============================================
-- DIAGNÓSTICO COMPLETO DA ESTRUTURA DO BANCO
-- Execute este arquivo para descobrir as colunas reais
-- ============================================

-- 1. TABELA: lens_catalog.lentes
SELECT 
  '=== TABELA: lens_catalog.lentes ===' as info,
  column_name, 
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'lens_catalog' 
  AND table_name = 'lentes'
ORDER BY ordinal_position;

| info                                | column_name            | data_type                | is_nullable | column_default                            |
| ----------------------------------- | ---------------------- | ------------------------ | ----------- | ----------------------------------------- |
| === TABELA: lens_catalog.lentes === | id                     | uuid                     | NO          | gen_random_uuid()                         |
| === TABELA: lens_catalog.lentes === | sku_fornecedor         | character varying        | NO          | null                                      |
| === TABELA: lens_catalog.lentes === | codigo_original        | character varying        | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | nome_comercial         | text                     | NO          | null                                      |
| === TABELA: lens_catalog.lentes === | marca_id               | uuid                     | NO          | null                                      |
| === TABELA: lens_catalog.lentes === | fornecedor_id          | uuid                     | NO          | null                                      |
| === TABELA: lens_catalog.lentes === | lente_canonica_id      | uuid                     | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | premium_canonica_id    | uuid                     | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | tipo_lente             | USER-DEFINED             | NO          | null                                      |
| === TABELA: lens_catalog.lentes === | categoria              | USER-DEFINED             | NO          | 'economica'::lens_catalog.categoria_lente |
| === TABELA: lens_catalog.lentes === | material               | USER-DEFINED             | NO          | null                                      |
| === TABELA: lens_catalog.lentes === | indice_refracao        | USER-DEFINED             | NO          | null                                      |
| === TABELA: lens_catalog.lentes === | diametro               | integer                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | espessura_central      | numeric                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | peso_aproximado        | numeric                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | esferico_min           | numeric                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | esferico_max           | numeric                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | cilindrico_min         | numeric                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | cilindrico_max         | numeric                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | adicao_min             | numeric                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | adicao_max             | numeric                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | dnp_min                | integer                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | dnp_max                | integer                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | ar                     | boolean                  | NO          | false                                     |
| === TABELA: lens_catalog.lentes === | antirrisco             | boolean                  | NO          | false                                     |
| === TABELA: lens_catalog.lentes === | hidrofobico            | boolean                  | NO          | false                                     |
| === TABELA: lens_catalog.lentes === | antiembaçante          | boolean                  | NO          | false                                     |
| === TABELA: lens_catalog.lentes === | blue                   | boolean                  | NO          | false                                     |
| === TABELA: lens_catalog.lentes === | uv400                  | boolean                  | NO          | false                                     |
| === TABELA: lens_catalog.lentes === | fotossensivel          | USER-DEFINED             | NO          | 'nenhum'::lens_catalog.tratamento_foto    |
| === TABELA: lens_catalog.lentes === | polarizado             | boolean                  | NO          | false                                     |
| === TABELA: lens_catalog.lentes === | digital                | boolean                  | NO          | false                                     |
| === TABELA: lens_catalog.lentes === | free_form              | boolean                  | NO          | false                                     |
| === TABELA: lens_catalog.lentes === | indoor                 | boolean                  | NO          | false                                     |
| === TABELA: lens_catalog.lentes === | drive                  | boolean                  | NO          | false                                     |
| === TABELA: lens_catalog.lentes === | linha_produto          | character varying        | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | custo_base             | numeric                  | NO          | null                                      |
| === TABELA: lens_catalog.lentes === | preco_fabricante       | numeric                  | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | preco_tabela           | numeric                  | NO          | null                                      |
| === TABELA: lens_catalog.lentes === | prazo_entrega          | integer                  | YES         | 7                                         |
| === TABELA: lens_catalog.lentes === | obs_prazo              | text                     | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | peso_frete             | numeric                  | YES         | 50.0                                      |
| === TABELA: lens_catalog.lentes === | exige_receita_especial | boolean                  | YES         | false                                     |
| === TABELA: lens_catalog.lentes === | descricao_curta        | text                     | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | descricao_completa     | text                     | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | beneficios             | ARRAY                    | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | indicacoes             | ARRAY                    | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | contraindicacoes       | text                     | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | observacoes            | text                     | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | status                 | USER-DEFINED             | NO          | 'ativo'::lens_catalog.status_lente        |
| === TABELA: lens_catalog.lentes === | disponivel             | boolean                  | NO          | true                                      |
| === TABELA: lens_catalog.lentes === | destaque               | boolean                  | YES         | false                                     |
| === TABELA: lens_catalog.lentes === | novidade               | boolean                  | YES         | false                                     |
| === TABELA: lens_catalog.lentes === | data_lancamento        | date                     | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | data_descontinuacao    | date                     | YES         | null                                      |
| === TABELA: lens_catalog.lentes === | created_at             | timestamp with time zone | NO          | now()                                     |
| === TABELA: lens_catalog.lentes === | updated_at             | timestamp with time zone | NO          | now()                                     |



-- 2. TABELA: lens_catalog.marcas
SELECT 
  '=== TABELA: lens_catalog.marcas ===' as info,
  column_name, 
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'lens_catalog' 
  AND table_name = 'marcas'
ORDER BY ordinal_position;

| info                                | column_name | data_type                | is_nullable | column_default    |
| ----------------------------------- | ----------- | ------------------------ | ----------- | ----------------- |
| === TABELA: lens_catalog.marcas === | id          | uuid                     | NO          | gen_random_uuid() |
| === TABELA: lens_catalog.marcas === | nome        | character varying        | NO          | null              |
| === TABELA: lens_catalog.marcas === | slug        | character varying        | NO          | null              |
| === TABELA: lens_catalog.marcas === | is_premium  | boolean                  | NO          | false             |
| === TABELA: lens_catalog.marcas === | descricao   | text                     | YES         | null              |
| === TABELA: lens_catalog.marcas === | website     | text                     | YES         | null              |
| === TABELA: lens_catalog.marcas === | logo_url    | text                     | YES         | null              |
| === TABELA: lens_catalog.marcas === | ativo       | boolean                  | NO          | true              |
| === TABELA: lens_catalog.marcas === | created_at  | timestamp with time zone | NO          | now()             |
| === TABELA: lens_catalog.marcas === | updated_at  | timestamp with time zone | NO          | now()             |



-- 3. TABELA: lens_catalog.lentes_canonicas
SELECT 
  '=== TABELA: lens_catalog.lentes_canonicas ===' as info,
  column_name, 
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'lens_catalog' 
  AND table_name = 'lentes_canonicas'
ORDER BY ordinal_position;

| info                                          | column_name     | data_type                | is_nullable | column_default    |
| --------------------------------------------- | --------------- | ------------------------ | ----------- | ----------------- |
| === TABELA: lens_catalog.lentes_canonicas === | id              | uuid                     | NO          | gen_random_uuid() |
| === TABELA: lens_catalog.lentes_canonicas === | nome_canonico   | text                     | NO          | null              |
| === TABELA: lens_catalog.lentes_canonicas === | descricao       | text                     | YES         | null              |
| === TABELA: lens_catalog.lentes_canonicas === | tipo_lente      | USER-DEFINED             | NO          | null              |
| === TABELA: lens_catalog.lentes_canonicas === | material        | USER-DEFINED             | NO          | null              |
| === TABELA: lens_catalog.lentes_canonicas === | indice_refracao | USER-DEFINED             | NO          | null              |
| === TABELA: lens_catalog.lentes_canonicas === | categoria       | USER-DEFINED             | NO          | null              |
| === TABELA: lens_catalog.lentes_canonicas === | ar              | boolean                  | NO          | false             |
| === TABELA: lens_catalog.lentes_canonicas === | blue            | boolean                  | NO          | false             |
| === TABELA: lens_catalog.lentes_canonicas === | fotossensivel   | boolean                  | NO          | false             |
| === TABELA: lens_catalog.lentes_canonicas === | polarizado      | boolean                  | NO          | false             |
| === TABELA: lens_catalog.lentes_canonicas === | esferico_min    | numeric                  | YES         | null              |
| === TABELA: lens_catalog.lentes_canonicas === | esferico_max    | numeric                  | YES         | null              |
| === TABELA: lens_catalog.lentes_canonicas === | cilindrico_min  | numeric                  | YES         | null              |
| === TABELA: lens_catalog.lentes_canonicas === | cilindrico_max  | numeric                  | YES         | null              |
| === TABELA: lens_catalog.lentes_canonicas === | adicao_min      | numeric                  | YES         | null              |
| === TABELA: lens_catalog.lentes_canonicas === | adicao_max      | numeric                  | YES         | null              |
| === TABELA: lens_catalog.lentes_canonicas === | total_lentes    | integer                  | YES         | 0                 |
| === TABELA: lens_catalog.lentes_canonicas === | preco_minimo    | numeric                  | YES         | null              |
| === TABELA: lens_catalog.lentes_canonicas === | preco_maximo    | numeric                  | YES         | null              |
| === TABELA: lens_catalog.lentes_canonicas === | preco_medio     | numeric                  | YES         | null              |
| === TABELA: lens_catalog.lentes_canonicas === | ativo           | boolean                  | NO          | true              |
| === TABELA: lens_catalog.lentes_canonicas === | created_at      | timestamp with time zone | NO          | now()             |
| === TABELA: lens_catalog.lentes_canonicas === | updated_at      | timestamp with time zone | NO          | now()             |



-- 4. TABELA: lens_catalog.premium_canonicas
SELECT 
  '=== TABELA: lens_catalog.premium_canonicas ===' as info,
  column_name, 
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'lens_catalog' 
  AND table_name = 'premium_canonicas'
ORDER BY ordinal_position;

| info                                           | column_name     | data_type                | is_nullable | column_default    |
| ---------------------------------------------- | --------------- | ------------------------ | ----------- | ----------------- |
| === TABELA: lens_catalog.premium_canonicas === | id              | uuid                     | NO          | gen_random_uuid() |
| === TABELA: lens_catalog.premium_canonicas === | marca_id        | uuid                     | NO          | null              |
| === TABELA: lens_catalog.premium_canonicas === | linha_produto   | character varying        | YES         | null              |
| === TABELA: lens_catalog.premium_canonicas === | nome_canonico   | text                     | NO          | null              |
| === TABELA: lens_catalog.premium_canonicas === | descricao       | text                     | YES         | null              |
| === TABELA: lens_catalog.premium_canonicas === | tipo_lente      | USER-DEFINED             | NO          | null              |
| === TABELA: lens_catalog.premium_canonicas === | material        | USER-DEFINED             | NO          | null              |
| === TABELA: lens_catalog.premium_canonicas === | indice_refracao | USER-DEFINED             | NO          | null              |
| === TABELA: lens_catalog.premium_canonicas === | categoria       | USER-DEFINED             | NO          | null              |
| === TABELA: lens_catalog.premium_canonicas === | ar              | boolean                  | NO          | false             |
| === TABELA: lens_catalog.premium_canonicas === | blue            | boolean                  | NO          | false             |
| === TABELA: lens_catalog.premium_canonicas === | fotossensivel   | boolean                  | NO          | false             |
| === TABELA: lens_catalog.premium_canonicas === | polarizado      | boolean                  | NO          | false             |
| === TABELA: lens_catalog.premium_canonicas === | esferico_min    | numeric                  | YES         | null              |
| === TABELA: lens_catalog.premium_canonicas === | esferico_max    | numeric                  | YES         | null              |
| === TABELA: lens_catalog.premium_canonicas === | cilindrico_min  | numeric                  | YES         | null              |
| === TABELA: lens_catalog.premium_canonicas === | cilindrico_max  | numeric                  | YES         | null              |
| === TABELA: lens_catalog.premium_canonicas === | adicao_min      | numeric                  | YES         | null              |
| === TABELA: lens_catalog.premium_canonicas === | adicao_max      | numeric                  | YES         | null              |
| === TABELA: lens_catalog.premium_canonicas === | total_lentes    | integer                  | YES         | 0                 |
| === TABELA: lens_catalog.premium_canonicas === | preco_minimo    | numeric                  | YES         | null              |
| === TABELA: lens_catalog.premium_canonicas === | preco_maximo    | numeric                  | YES         | null              |
| === TABELA: lens_catalog.premium_canonicas === | preco_medio     | numeric                  | YES         | null              |
| === TABELA: lens_catalog.premium_canonicas === | ativo           | boolean                  | NO          | true              |
| === TABELA: lens_catalog.premium_canonicas === | created_at      | timestamp with time zone | NO          | now()             |
| === TABELA: lens_catalog.premium_canonicas === | updated_at      | timestamp with time zone | NO          | now()             |


-- 5. TODAS AS TABELAS DO SCHEMA lens_catalog
SELECT 
  '=== TODAS AS TABELAS EM lens_catalog ===' as info,
  table_name,
  table_type
FROM information_schema.tables
WHERE table_schema = 'lens_catalog'
ORDER BY table_name;

| info                                     | table_name               | table_type |
| ---------------------------------------- | ------------------------ | ---------- |
| === TODAS AS TABELAS EM lens_catalog === | historico_precos_lente   | BASE TABLE |
| === TODAS AS TABELAS EM lens_catalog === | lentes                   | BASE TABLE |
| === TODAS AS TABELAS EM lens_catalog === | lentes_canonicas         | BASE TABLE |
| === TODAS AS TABELAS EM lens_catalog === | marcas                   | BASE TABLE |
| === TODAS AS TABELAS EM lens_catalog === | premium_canonicas        | BASE TABLE |
| === TODAS AS TABELAS EM lens_catalog === | v_combo_ar_blue          | VIEW       |
| === TODAS AS TABELAS EM lens_catalog === | v_lentes_completas       | VIEW       |
| === TODAS AS TABELAS EM lens_catalog === | v_lentes_destaque        | VIEW       |
| === TODAS AS TABELAS EM lens_catalog === | v_lentes_por_faixa_preco | VIEW       |
| === TODAS AS TABELAS EM lens_catalog === | v_promo_black_friday     | VIEW       |
| === TODAS AS TABELAS EM lens_catalog === | v_promo_essilor          | VIEW       |
| === TODAS AS TABELAS EM lens_catalog === | v_sugestoes_prescricao   | VIEW       |
| === TODAS AS TABELAS EM lens_catalog === | vw_analise_markup        | VIEW       |
| === TODAS AS TABELAS EM lens_catalog === | vw_historico_precos      | VIEW       |


-- 6. SAMPLE DATA - Ver alguns registros reais
SELECT 
  '=== SAMPLE: 5 primeiras lentes ===' as info,
  *
FROM lens_catalog.lentes
LIMIT 5;

| info                               | id                                   | sku_fornecedor | codigo_original | nome_comercial                                 | marca_id                             | fornecedor_id                        | lente_canonica_id | premium_canonica_id                  | tipo_lente    | categoria     | material      | indice_refracao | diametro | espessura_central | peso_aproximado | esferico_min | esferico_max | cilindrico_min | cilindrico_max | adicao_min | adicao_max | dnp_min | dnp_max | ar    | antirrisco | hidrofobico | antiembaçante | blue  | uv400 | fotossensivel | polarizado | digital | free_form | indoor | drive | linha_produto | custo_base | preco_fabricante | preco_tabela | prazo_entrega | obs_prazo | peso_frete | exige_receita_especial | descricao_curta | descricao_completa | beneficios | indicacoes | contraindicacoes | observacoes | status | disponivel | destaque | novidade | data_lancamento | data_descontinuacao | created_at                    | updated_at                    |
| ---------------------------------- | ------------------------------------ | -------------- | --------------- | ---------------------------------------------- | ------------------------------------ | ------------------------------------ | ----------------- | ------------------------------------ | ------------- | ------------- | ------------- | --------------- | -------- | ----------------- | --------------- | ------------ | ------------ | -------------- | -------------- | ---------- | ---------- | ------- | ------- | ----- | ---------- | ----------- | ------------- | ----- | ----- | ------------- | ---------- | ------- | --------- | ------ | ----- | ------------- | ---------- | ---------------- | ------------ | ------------- | --------- | ---------- | ---------------------- | --------------- | ------------------ | ---------- | ---------- | ---------------- | ----------- | ------ | ---------- | -------- | -------- | --------------- | ------------------- | ----------------------------- | ----------------------------- |
| === SAMPLE: 5 primeiras lentes === | 0058ca99-8743-45be-bedf-cff8dcc9a44f | LEN-0058CA99   | 10469           | FREEVIEW HDI 1.67 BLUE FILTER AR FAST TITANIUM | a1b9169c-1af2-4a36-8451-de372dc67003 | e1e1eace-11b4-4f26-9f15-620808a4a410 | null              | dab57a34-5135-4a2e-8bed-8f4d1861024d | visao_simples | super_premium | CR39          | 1.67            | 70       | null              | null            | -13.00       | 9.00         | -6.00          | 0.00           | 0.00       | 0.00       | 18      | 0       | false | false      | false       | false         | true  | true  | nenhum        | false      | false   | true      | false  | false | null          | 1300.00    | null             | 5395.00      | 7             | null      | 50.00      | false                  | null            | null               | null       | null       | null             | null        | ativo  | true       | false    | false    | null            | null                | 2025-06-04 03:05:08.018658+00 | 2025-12-18 18:06:45.692201+00 |
| === SAMPLE: 5 primeiras lentes === | 00594427-93b0-4842-854c-9171a76ca911 | LEN-00594427   | 8566            | SYGMA PRIME 1.67 PHOTO BLUECUT                 | 5a43c260-12bf-4651-99c5-a050a23721ad | 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | null              | e82dcdde-d27a-43ca-8933-a225ad9dbcd6 | visao_simples | premium       | CR39          | 1.67            | 75       | null              | null            | -12.00       | 9.00         | -6.00          | 0.00           | 1.00       | 3.00       | 16      | 18      | false | false      | false       | false         | true  | true  | fotocromático | false      | false   | true      | false  | false | null          | 450.00     | null             | 1867.50      | 7             | null      | 50.00      | false                  | null            | null               | null       | null       | null             | null        | ativo  | true       | false    | false    | null            | null                | 2025-06-04 03:05:08.018658+00 | 2025-12-18 18:06:45.692201+00 |
| === SAMPLE: 5 primeiras lentes === | 00757a23-456a-4108-afef-ac7e35a6b9d9 | LEN-00757A23   | 10488           | MULTI 1.49 FREEVIEW SILVER AR FAST SH          | a1b9169c-1af2-4a36-8451-de372dc67003 | e1e1eace-11b4-4f26-9f15-620808a4a410 | null              | 9bb5d75a-271a-4863-ba38-27f0f5573fb6 | visao_simples | premium       | CR39          | 1.50            | 70       | null              | null            | -8.00        | 6.50         | -6.00          | 0.00           | 0.50       | 4.50       | 14      | 20      | false | false      | true        | false         | false | true  | nenhum        | false      | false   | true      | false  | false | null          | 534.00     | null             | 2136.00      | 7             | null      | 50.00      | false                  | null            | null               | null       | null       | null             | null        | ativo  | true       | false    | false    | null            | null                | 2025-06-04 03:05:08.018658+00 | 2025-12-18 18:06:45.692201+00 |
| === SAMPLE: 5 primeiras lentes === | 007a5411-0392-4ffd-a727-962665fec745 | LEN-007A5411   | 10164           | VS HDI 1.74 SLIM BLUE FILTER AR FAST AZUL      | a1b9169c-1af2-4a36-8451-de372dc67003 | e1e1eace-11b4-4f26-9f15-620808a4a410 | null              | f34872fd-bae9-4a5f-9187-77649f0acdd0 | visao_simples | super_premium | CR39          | 1.74            | 75       | null              | null            | -14.00       | 10.00        | -8.00          | 0.00           | 0.00       | 0.00       | 18      | 0       | true  | false      | false       | false         | true  | true  | nenhum        | false      | false   | false     | false  | false | null          | 1406.00    | null             | 6116.10      | 7             | null      | 50.00      | false                  | null            | null               | null       | null       | null             | null        | ativo  | true       | false    | false    | null            | null                | 2025-06-04 03:05:08.018658+00 | 2025-12-18 18:06:45.692201+00 |
| === SAMPLE: 5 primeiras lentes === | 00b71f1f-3e75-4451-8d99-24a25979042c | LEN-00B71F1F   | 2222            | LT 1.59 POLICARBONATO FOTO AR (RESIDUAL VERDE) | 5a43c260-12bf-4651-99c5-a050a23721ad | 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | null              | f5117a21-0f34-4c08-9b9b-85cba8245294 | visao_simples | economica     | POLICARBONATO | 1.59            | 65       | null              | null            | -4.00        | 4.00         | -2.00          | 0.00           | 0.00       | 0.00       | 0       | 0       | false | false      | false       | false         | false | true  | fotocromático | false      | false   | false     | false  | false | null          | 30.00      | null             | 120.00       | 7             | null      | 50.00      | false                  | null            | null               | null       | null       | null             | null        | ativo  | true       | false    | false    | null            | null                | 2025-06-04 03:05:08.018658+00 | 2025-12-18 18:06:45.692201+00 |



SELECT 
  '=== SAMPLE: 5 primeiras marcas ===' as info,
  *
FROM lens_catalog.marcas
LIMIT 5;

| info                               | id                                   | nome     | slug     | is_premium | descricao                                  | website | logo_url | ativo | created_at                    | updated_at                    |
| ---------------------------------- | ------------------------------------ | -------- | -------- | ---------- | ------------------------------------------ | ------- | -------- | ----- | ----------------------------- | ----------------------------- |
| === SAMPLE: 5 primeiras marcas === | 4c67f7d1-ec57-4a1a-9e00-e1778753b738 | ESSILOR  | essilor  | true       | Líder mundial em lentes oftálmicas         | null    | null     | true  | 2025-12-18 17:44:53.626877+00 | 2025-12-18 17:44:53.626877+00 |
| === SAMPLE: 5 primeiras marcas === | 5a43c260-12bf-4651-99c5-a050a23721ad | EXPRESS  | express  | true       | Lentes de alta qualidade Express           | null    | null     | true  | 2025-12-18 17:44:53.626877+00 | 2025-12-18 17:44:53.626877+00 |
| === SAMPLE: 5 primeiras marcas === | 5b64739e-d1f4-4c13-a159-867d8683f934 | SIS Lens | sis-lens | false      | Marca própria brasileira                   | null    | null     | true  | 2025-12-18 17:44:53.626877+00 | 2025-12-18 17:44:53.626877+00 |
| === SAMPLE: 5 primeiras marcas === | a1b9169c-1af2-4a36-8451-de372dc67003 | SOBLOCOS | soblocos | true       | Laboratório nacional - lentes de qualidade | null    | null     | true  | 2025-12-18 17:44:53.626877+00 | 2025-12-18 17:44:53.626877+00 |
| === SAMPLE: 5 primeiras marcas === | a7656b0c-88fb-4aa8-a3ed-a7de84598492 | POLYLUX  | polylux  | true       | Lentes nacionais intermediárias            | null    | null     | true  | 2025-12-18 17:44:53.626877+00 | 2025-12-18 17:44:53.626877+00 |


