-- ============================================
-- INVESTIGAÇÃO RÁPIDA: VIEWS DE CATÁLOGO
-- Execute no SQL Editor do Supabase
-- ============================================

-- 1. Verificar quais views existem
SELECT 
  table_name,
  'EXISTS' as status
FROM information_schema.tables
WHERE table_schema = 'public' 
  AND table_name IN ('v_lentes_catalogo', 'vw_lentes_catalogo');

  | table_name         | status |
| ------------------ | ------ |
| v_lentes_catalogo  | EXISTS |
| vw_lentes_catalogo | EXISTS |



-- 2. Contar registros em cada view (se existir)
SELECT 'v_lentes_catalogo' as view_name, COUNT(*) as total 
FROM public.v_lentes_catalogo
UNION ALL
SELECT 'vw_lentes_catalogo' as view_name, COUNT(*) as total 
FROM public.vw_lentes_catalogo;

| view_name          | total |
| ------------------ | ----- |
| v_lentes_catalogo  | 1411  |
| vw_lentes_catalogo | 1411  |


-- 3. Comparar campos das duas views
WITH campos_v AS (
  SELECT column_name, data_type, 'v_lentes_catalogo' as origem
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'v_lentes_catalogo'
),
campos_vw AS (
  SELECT column_name, data_type, 'vw_lentes_catalogo' as origem
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'vw_lentes_catalogo'
)
SELECT 
  COALESCE(v.column_name, vw.column_name) as campo,
  v.data_type as tipo_em_v,
  vw.data_type as tipo_em_vw,
  CASE 
    WHEN v.column_name IS NULL THEN '❌ Só em vw'
    WHEN vw.column_name IS NULL THEN '❌ Só em v'
    WHEN v.data_type != vw.data_type THEN '⚠️ Tipos diferentes'
    ELSE '✓ Igual'
  END as status
FROM campos_v v
FULL OUTER JOIN campos_vw vw ON v.column_name = vw.column_name
ORDER BY 
  CASE 
    WHEN v.column_name IS NULL THEN 3
    WHEN vw.column_name IS NULL THEN 2
    WHEN v.data_type != vw.data_type THEN 1
    ELSE 0
  END,
  campo;

  | campo                     | tipo_em_v                | tipo_em_vw               | status     |
| ------------------------- | ------------------------ | ------------------------ | ---------- |
| adicao_max                | numeric                  | numeric                  | ✓ Igual    |
| adicao_min                | numeric                  | numeric                  | ✓ Igual    |
| categoria                 | USER-DEFINED             | USER-DEFINED             | ✓ Igual    |
| created_at                | timestamp with time zone | timestamp with time zone | ✓ Igual    |
| fornecedor_id             | uuid                     | uuid                     | ✓ Igual    |
| id                        | uuid                     | uuid                     | ✓ Igual    |
| indice_refracao           | USER-DEFINED             | USER-DEFINED             | ✓ Igual    |
| marca_id                  | uuid                     | uuid                     | ✓ Igual    |
| marca_nome                | character varying        | character varying        | ✓ Igual    |
| marca_premium             | boolean                  | boolean                  | ✓ Igual    |
| marca_slug                | character varying        | character varying        | ✓ Igual    |
| material                  | USER-DEFINED             | USER-DEFINED             | ✓ Igual    |
| status                    | USER-DEFINED             | USER-DEFINED             | ✓ Igual    |
| tipo_lente                | USER-DEFINED             | USER-DEFINED             | ✓ Igual    |
| updated_at                | timestamp with time zone | timestamp with time zone | ✓ Igual    |
| ativo                     | boolean                  | null                     | ❌ Só em v  |
| curva_base                | numeric                  | null                     | ❌ Só em v  |
| diametro_mm               | integer                  | null                     | ❌ Só em v  |
| espessura_centro_mm       | numeric                  | null                     | ❌ Só em v  |
| estoque_disponivel        | integer                  | null                     | ❌ Só em v  |
| estoque_reservado         | integer                  | null                     | ❌ Só em v  |
| fornecedor_nome           | text                     | null                     | ❌ Só em v  |
| grau_cilindrico_max       | numeric                  | null                     | ❌ Só em v  |
| grau_cilindrico_min       | numeric                  | null                     | ❌ Só em v  |
| grau_esferico_max         | numeric                  | null                     | ❌ Só em v  |
| grau_esferico_min         | numeric                  | null                     | ❌ Só em v  |
| grupo_id                  | uuid                     | null                     | ❌ Só em v  |
| grupo_slug                | text                     | null                     | ❌ Só em v  |
| margem_lucro              | numeric                  | null                     | ❌ Só em v  |
| metadata                  | jsonb                    | null                     | ❌ Só em v  |
| nome_canonizado           | text                     | null                     | ❌ Só em v  |
| nome_grupo                | text                     | null                     | ❌ Só em v  |
| nome_lente                | text                     | null                     | ❌ Só em v  |
| peso                      | integer                  | null                     | ❌ Só em v  |
| prazo_free_form           | integer                  | null                     | ❌ Só em v  |
| prazo_multifocal          | integer                  | null                     | ❌ Só em v  |
| prazo_surfacada           | integer                  | null                     | ❌ Só em v  |
| prazo_visao_simples       | integer                  | null                     | ❌ Só em v  |
| preco_custo               | numeric                  | null                     | ❌ Só em v  |
| preco_venda_sugerido      | numeric                  | null                     | ❌ Só em v  |
| slug                      | text                     | null                     | ❌ Só em v  |
| tratamento_antirreflexo   | boolean                  | null                     | ❌ Só em v  |
| tratamento_antirrisco     | boolean                  | null                     | ❌ Só em v  |
| tratamento_blue_light     | boolean                  | null                     | ❌ Só em v  |
| tratamento_fotossensiveis | USER-DEFINED             | null                     | ❌ Só em v  |
| tratamento_uv             | boolean                  | null                     | ❌ Só em v  |
| antiembaçante             | null                     | boolean                  | ❌ Só em vw |
| antirrisco                | null                     | boolean                  | ❌ Só em vw |
| ar                        | null                     | boolean                  | ❌ Só em vw |
| beneficios                | null                     | ARRAY                    | ❌ Só em vw |
| blue                      | null                     | boolean                  | ❌ Só em vw |
| cilindrico_max            | null                     | numeric                  | ❌ Só em vw |
| cilindrico_min            | null                     | numeric                  | ❌ Só em vw |
| codigo_original           | null                     | character varying        | ❌ Só em vw |
| contraindicacoes          | null                     | text                     | ❌ Só em vw |
| custo_base                | null                     | numeric                  | ❌ Só em vw |
| data_descontinuacao       | null                     | date                     | ❌ Só em vw |
| data_lancamento           | null                     | date                     | ❌ Só em vw |
| descricao_completa        | null                     | text                     | ❌ Só em vw |
| descricao_curta           | null                     | text                     | ❌ Só em vw |
| destaque                  | null                     | boolean                  | ❌ Só em vw |
| diametro                  | null                     | integer                  | ❌ Só em vw |
| digital                   | null                     | boolean                  | ❌ Só em vw |
| disponivel                | null                     | boolean                  | ❌ Só em vw |
| dnp_max                   | null                     | integer                  | ❌ Só em vw |
| dnp_min                   | null                     | integer                  | ❌ Só em vw |
| drive                     | null                     | boolean                  | ❌ Só em vw |
| esferico_max              | null                     | numeric                  | ❌ Só em vw |
| esferico_min              | null                     | numeric                  | ❌ Só em vw |
| espessura_central         | null                     | numeric                  | ❌ Só em vw |
| exige_receita_especial    | null                     | boolean                  | ❌ Só em vw |
| fotossensivel             | null                     | text                     | ❌ Só em vw |
| free_form                 | null                     | boolean                  | ❌ Só em vw |
| hidrofobico               | null                     | boolean                  | ❌ Só em vw |
| indicacoes                | null                     | ARRAY                    | ❌ Só em vw |
| indoor                    | null                     | boolean                  | ❌ Só em vw |
| lente_canonica_id         | null                     | uuid                     | ❌ Só em vw |
| linha_produto             | null                     | character varying        | ❌ Só em vw |
| nome_comercial            | null                     | text                     | ❌ Só em vw |
| novidade                  | null                     | boolean                  | ❌ Só em vw |
| obs_prazo                 | null                     | text                     | ❌ Só em vw |
| observacoes               | null                     | text                     | ❌ Só em vw |
| peso_aproximado           | null                     | numeric                  | ❌ Só em vw |
| peso_frete                | null                     | numeric                  | ❌ Só em vw |
| polarizado                | null                     | boolean                  | ❌ Só em vw |
| prazo_entrega             | null                     | integer                  | ❌ Só em vw |
| preco_fabricante          | null                     | numeric                  | ❌ Só em vw |
| preco_tabela              | null                     | numeric                  | ❌ Só em vw |
| premium_canonica_id       | null                     | uuid                     | ❌ Só em vw |
| sku_fornecedor            | null                     | character varying        | ❌ Só em vw |
| uv400                     | null                     | boolean                  | ❌ Só em vw |


-- 4. Campos específicos importantes
SELECT 
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name IN ('v_lentes_catalogo', 'vw_lentes_catalogo')
  AND column_name IN (
    'ar', 'tratamento_antirreflexo',
    'blue', 'tratamento_blue_light',
    'preco_tabela', 'preco_venda_sugerido',
    'custo_base', 'preco_custo',
    'nome_lente', 'nome_comercial',
    'estoque_disponivel', 'disponivel'
  )
ORDER BY column_name, table_name;

| table_name         | column_name             | data_type |
| ------------------ | ----------------------- | --------- |
| vw_lentes_catalogo | ar                      | boolean   |
| vw_lentes_catalogo | blue                    | boolean   |
| vw_lentes_catalogo | custo_base              | numeric   |
| vw_lentes_catalogo | disponivel              | boolean   |
| v_lentes_catalogo  | estoque_disponivel      | integer   |
| vw_lentes_catalogo | nome_comercial          | text      |
| v_lentes_catalogo  | nome_lente              | text      |
| v_lentes_catalogo  | preco_custo             | numeric   |
| vw_lentes_catalogo | preco_tabela            | numeric   |
| v_lentes_catalogo  | preco_venda_sugerido    | numeric   |
| v_lentes_catalogo  | tratamento_antirreflexo | boolean   |
| v_lentes_catalogo  | tratamento_blue_light   | boolean   |


-- 5. Amostra de 2 registros de cada view
SELECT '=== v_lentes_catalogo (amostra) ===' as info;
SELECT * FROM public.v_lentes_catalogo LIMIT 2;

| id                                   | slug                                       | nome_lente                      | nome_canonizado | fornecedor_id                        | fornecedor_nome | prazo_visao_simples | prazo_multifocal | prazo_surfacada | prazo_free_form | marca_id                             | marca_nome | marca_slug | marca_premium | grupo_id                             | nome_grupo                                                            | grupo_slug                                                              | tipo_lente    | material      | indice_refracao | categoria | tratamento_antirreflexo | tratamento_antirrisco | tratamento_uv | tratamento_blue_light | tratamento_fotossensiveis | diametro_mm | curva_base | espessura_centro_mm | grau_esferico_min | grau_esferico_max | grau_cilindrico_min | grau_cilindrico_max | adicao_min | adicao_max | preco_custo | preco_venda_sugerido | margem_lucro | estoque_disponivel | estoque_reservado | status | ativo | peso | metadata                                                                                                                                                                                                | created_at                    | updated_at                    |
| ------------------------------------ | ------------------------------------------ | ------------------------------- | --------------- | ------------------------------------ | --------------- | ------------------- | ---------------- | --------------- | --------------- | ------------------------------------ | ---------- | ---------- | ------------- | ------------------------------------ | --------------------------------------------------------------------- | ----------------------------------------------------------------------- | ------------- | ------------- | --------------- | --------- | ----------------------- | --------------------- | ------------- | --------------------- | ------------------------- | ----------- | ---------- | ------------------- | ----------------- | ----------------- | ------------------- | ------------------- | ---------- | ---------- | ----------- | -------------------- | ------------ | ------------------ | ----------------- | ------ | ----- | ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- | ----------------------------- |
| 13e50463-bba2-4163-b242-2d2a1bd067fe | -1-49-13e50463-bba2-4163-b242-2d2a1bd067fe | LT CR 1.49 INCOLOR (TINTAVEL)   | null            | 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express         | 3                   | 5                | 7               | 10              | 7bf35e08-7a88-4547-a06a-a6ce62fcc827 | EXPRESS    | express    | false         | 30d581c1-4b46-41a8-b4a5-6653c862ec7a | Lente CR39 1.50 Visao Simples +UV [-6.00/6.00 | 0.00/-2.00]           | lente-39-150-visao-simples-uv-esf-n6-00-6-00-cil-0-00-n2-00-add-000-000 | visao_simples | CR39          | 1.50            | economica | false                   | false                 | true          | false                 | nenhum                    | 65          | null       | null                | -6.00             | 6.00              | 0.00                | -2.00               | 0.00       | 0.00       | 9.00        | 250.00               | null         | 0                  | 0                 | ativo  | true  | 50   | {"faixa":"1","tintavel":"true","diametro2":70,"sku_geral":"MLT661JJB","altura_max":"0","altura_min":"0","markup_estimado":27.78,"classificacao_fiscal":"90015010","tratamentos_originais":"TINTAVEL  "} | 2025-12-19 22:33:29.370498+00 | 2025-12-20 03:16:11.631254+00 |
| 58edb8fb-4283-4d84-b7e8-663a3c8a5cc1 | -1-59-58edb8fb-4283-4d84-b7e8-663a3c8a5cc1 | LT 1.59 POLICARBONATO INCOLOR   | null            | 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express         | 3                   | 5                | 7               | 10              | 7bf35e08-7a88-4547-a06a-a6ce62fcc827 | EXPRESS    | express    | false         | 573729aa-91b7-4f74-b2dc-00e5bcd9ea34 | Lente POLICARBONATO 1.59 Visao Simples +UV [-10.00/6.00 | 0.00/-2.00] | lente-159-visao-simples-uv-esf-n10-00-6-00-cil-0-00-n2-00-add-000-000   | visao_simples | POLICARBONATO | 1.59            | economica | false                   | false                 | true          | false                 | nenhum                    | 65          | null       | null                | -10.00            | 6.00              | 0.00                | -2.00               | 0.00       | 0.00       | 9.00        | 250.00               | null         | 0                  | 0                 | ativo  | true  | 50   | {"faixa":"1","tintavel":"false","diametro2":70,"sku_geral":"MLTQXQ4II","altura_max":"0","altura_min":"0","markup_estimado":27.78,"classificacao_fiscal":"90015010","tratamentos_originais":"�  "}       | 2025-12-19 22:33:33.249602+00 | 2025-12-20 03:16:11.631254+00 |


SELECT '=== vw_lentes_catalogo (amostra) ===' as info;
SELECT * FROM public.vw_lentes_catalogo LIMIT 2;


| id                                   | marca_id                             | fornecedor_id                        | lente_canonica_id | premium_canonica_id | sku_fornecedor | codigo_original | nome_comercial | marca_nome | marca_slug | marca_premium | tipo_lente    | categoria | material | indice_refracao | linha_produto | diametro | espessura_central | peso_aproximado | esferico_min | esferico_max | cilindrico_min | cilindrico_max | adicao_min | adicao_max | dnp_min | dnp_max | ar    | antirrisco | hidrofobico | antiembaçante | blue  | uv400 | fotossensivel | polarizado | digital | free_form | indoor | drive | custo_base | preco_fabricante | preco_tabela | prazo_entrega | obs_prazo | peso_frete | exige_receita_especial | descricao_curta | descricao_completa | beneficios | indicacoes | contraindicacoes | observacoes | status | disponivel | destaque | novidade | data_lancamento | data_descontinuacao | created_at                    | updated_at                    |
| ------------------------------------ | ------------------------------------ | ------------------------------------ | ----------------- | ------------------- | -------------- | --------------- | -------------- | ---------- | ---------- | ------------- | ------------- | --------- | -------- | --------------- | ------------- | -------- | ----------------- | --------------- | ------------ | ------------ | -------------- | -------------- | ---------- | ---------- | ------- | ------- | ----- | ---------- | ----------- | ------------- | ----- | ----- | ------------- | ---------- | ------- | --------- | ------ | ----- | ---------- | ---------------- | ------------ | ------------- | --------- | ---------- | ---------------------- | --------------- | ------------------ | ---------- | ---------- | ---------------- | ----------- | ------ | ---------- | -------- | -------- | --------------- | ------------------- | ----------------------------- | ----------------------------- |
| fa5e2bf2-3928-4187-ba2b-0d2e122d3026 | 4af04ba6-e600-4874-b8dc-45a2e1773725 | e1e1eace-11b4-4f26-9f15-620808a4a410 | null              | null                | null           | null            | null           | SO BLOCOS  | so-blocos  | false         | visao_simples | economica | CR39     | 1.50            | null          | null     | null              | null            | null         | null         | null           | null           | 0.00       | 0.00       | null    | null    | false | false      | false       | false         | false | false | nenhum        | false      | false   | false     | false  | false | 0.00       | null             | 0.00         | 7             | null      | 50.0       | false                  | null            | null               | null       | null       | null             | null        | ativo  | true       | false    | false    | null            | null                | 2025-12-19 22:33:42.690213+00 | 2025-12-20 03:16:11.631254+00 |
| f8f167ad-34c0-4aa7-9b15-17bc41529157 | 4af04ba6-e600-4874-b8dc-45a2e1773725 | e1e1eace-11b4-4f26-9f15-620808a4a410 | null              | null                | null           | null            | null           | SO BLOCOS  | so-blocos  | false         | visao_simples | economica | CR39     | 1.50            | null          | null     | null              | null            | null         | null         | null           | null           | 0.00       | 0.00       | null    | null    | false | false      | false       | false         | false | false | nenhum        | false      | false   | false     | false  | false | 0.00       | null             | 0.00         | 7             | null      | 50.0       | false                  | null            | null               | null       | null       | null             | null        | ativo  | true       | false    | false    | null            | null                | 2025-12-19 22:33:42.690213+00 | 2025-12-20 03:16:11.631254+00 |
