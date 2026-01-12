-- ============================================
-- ANÁLISE SIMPLIFICADA DAS VIEWS
-- Execute no Supabase SQL Editor
-- ============================================

-- 1. CONTAGEM DE REGISTROS
SELECT 'v_lentes_catalogo' as view_name, COUNT(*) as total_registros
FROM public.v_lentes_catalogo
UNION ALL
SELECT 'vw_lentes_catalogo' as view_name, COUNT(*) as total_registros
FROM public.vw_lentes_catalogo;


| view_name          | total_registros |
| ------------------ | --------------- |
| v_lentes_catalogo  | 1411            |
| vw_lentes_catalogo | 1411            |


-- 2. AMOSTRA: v_lentes_catalogo (primeiros 2 registros)
SELECT 
  '=== v_lentes_catalogo ===' as info,
  id,
  nome_lente,
  marca_nome,
  fornecedor_nome,
  tipo_lente,
  material,
  indice_refracao,
  tratamento_antirreflexo as ar,
  tratamento_blue_light as blue,
  preco_custo,
  preco_venda_sugerido,
  margem_lucro,
  estoque_disponivel,
  grupo_id,
  nome_grupo
FROM public.v_lentes_catalogo
LIMIT 2;


| info                      | id                                   | nome_lente                      | marca_nome | fornecedor_nome | tipo_lente    | material      | indice_refracao | ar    | blue  | preco_custo | preco_venda_sugerido | margem_lucro | estoque_disponivel | grupo_id                             | nome_grupo                                                            |
| ------------------------- | ------------------------------------ | ------------------------------- | ---------- | --------------- | ------------- | ------------- | --------------- | ----- | ----- | ----------- | -------------------- | ------------ | ------------------ | ------------------------------------ | --------------------------------------------------------------------- |
| === v_lentes_catalogo === | 13e50463-bba2-4163-b242-2d2a1bd067fe | LT CR 1.49 INCOLOR (TINTAVEL)   | EXPRESS    | Express         | visao_simples | CR39          | 1.50            | false | false | 9.00        | 250.00               | null         | 0                  | 30d581c1-4b46-41a8-b4a5-6653c862ec7a | Lente CR39 1.50 Visao Simples +UV [-6.00/6.00 | 0.00/-2.00]           |
| === v_lentes_catalogo === | 58edb8fb-4283-4d84-b7e8-663a3c8a5cc1 | LT 1.59 POLICARBONATO INCOLOR   | EXPRESS    | Express         | visao_simples | POLICARBONATO | 1.59            | false | false | 9.00        | 250.00               | null         | 0                  | 573729aa-91b7-4f74-b2dc-00e5bcd9ea34 | Lente POLICARBONATO 1.59 Visao Simples +UV [-10.00/6.00 | 0.00/-2.00] |

-- 3. AMOSTRA: vw_lentes_catalogo (primeiros 2 registros)
SELECT 
  '=== vw_lentes_catalogo ===' as info,
  id,
  nome_comercial,
  marca_nome,
  tipo_lente,
  material,
  indice_refracao,
  ar,
  blue,
  fotossensivel,
  custo_base,
  preco_tabela,
  preco_fabricante,
  disponivel,
  lente_canonica_id,
  premium_canonica_id
FROM public.vw_lentes_catalogo
LIMIT 2;

| info                       | id                                   | nome_comercial | marca_nome | tipo_lente    | material | indice_refracao | ar    | blue  | fotossensivel | custo_base | preco_tabela | preco_fabricante | disponivel | lente_canonica_id | premium_canonica_id |
| -------------------------- | ------------------------------------ | -------------- | ---------- | ------------- | -------- | --------------- | ----- | ----- | ------------- | ---------- | ------------ | ---------------- | ---------- | ----------------- | ------------------- |
| === vw_lentes_catalogo === | fa5e2bf2-3928-4187-ba2b-0d2e122d3026 | null           | SO BLOCOS  | visao_simples | CR39     | 1.50            | false | false | nenhum        | 0.00       | 0.00         | null             | true       | null              | null                |
| === vw_lentes_catalogo === | f8f167ad-34c0-4aa7-9b15-17bc41529157 | null           | SO BLOCOS  | visao_simples | CR39     | 1.50            | false | false | nenhum        | 0.00       | 0.00         | null             | true       | null              | null                |

-- 4. COMPARAR CAMPOS DE PREÇO (com dados reais)
SELECT 
  'v_lentes_catalogo' as source,
  AVG(preco_custo) as preco_custo_medio,
  AVG(preco_venda_sugerido) as preco_venda_medio,
  MIN(preco_venda_sugerido) as preco_min,
  MAX(preco_venda_sugerido) as preco_max
FROM public.v_lentes_catalogo
WHERE preco_venda_sugerido IS NOT NULL
UNION ALL
SELECT 
  'vw_lentes_catalogo' as source,
  AVG(custo_base) as preco_custo_medio,
  AVG(preco_tabela) as preco_venda_medio,
  MIN(preco_tabela) as preco_min,
  MAX(preco_tabela) as preco_max
FROM public.vw_lentes_catalogo
WHERE preco_tabela IS NOT NULL;

| source             | preco_custo_medio      | preco_venda_medio      | preco_min | preco_max |
| ------------------ | ---------------------- | ---------------------- | --------- | --------- |
| v_lentes_catalogo  | 854.8083628632175762   | 3557.8470163004961021  | 250.00    | 9640.00   |
| vw_lentes_catalogo | 0.00000000000000000000 | 0.00000000000000000000 | 0.00      | 0.00      |


-- 5. TRATAMENTOS: quantas lentes tem cada tratamento
SELECT 
  'v_lentes_catalogo' as source,
  COUNT(CASE WHEN tratamento_antirreflexo = true THEN 1 END) as com_ar,
  COUNT(CASE WHEN tratamento_blue_light = true THEN 1 END) as com_blue,
  COUNT(CASE WHEN tratamento_fotossensiveis != 'nenhum' THEN 1 END) as com_foto
FROM public.v_lentes_catalogo
UNION ALL
SELECT 
  'vw_lentes_catalogo' as source,
  COUNT(CASE WHEN ar = true THEN 1 END) as com_ar,
  COUNT(CASE WHEN blue = true THEN 1 END) as com_blue,
  COUNT(CASE WHEN fotossensivel != 'nenhum' THEN 1 END) as com_foto
FROM public.vw_lentes_catalogo;

| source             | com_ar | com_blue | com_foto |
| ------------------ | ------ | -------- | -------- |
| v_lentes_catalogo  | 620    | 466      | 382      |
| vw_lentes_catalogo | 0      | 0        | 0        |


-- 6. CAMPOS EXCLUSIVOS IMPORTANTES
-- Verificar se v_lentes_catalogo tem dados em campos exclusivos
SELECT 
  'Campos exclusivos v_lentes_catalogo' as analise,
  COUNT(CASE WHEN grupo_id IS NOT NULL THEN 1 END) as tem_grupo_canonico,
  COUNT(CASE WHEN estoque_disponivel > 0 THEN 1 END) as tem_estoque,
  COUNT(CASE WHEN margem_lucro IS NOT NULL THEN 1 END) as tem_margem,
  COUNT(CASE WHEN prazo_visao_simples IS NOT NULL THEN 1 END) as tem_prazos
FROM public.v_lentes_catalogo;

| analise                             | tem_grupo_canonico | tem_estoque | tem_margem | tem_prazos |
| ----------------------------------- | ------------------ | ----------- | ---------- | ---------- |
| Campos exclusivos v_lentes_catalogo | 1411               | 0           | 0          | 1411       |


-- Verificar se vw_lentes_catalogo tem dados em campos exclusivos
SELECT 
  'Campos exclusivos vw_lentes_catalogo' as analise,
  COUNT(CASE WHEN lente_canonica_id IS NOT NULL THEN 1 END) as tem_canonica_generica,
  COUNT(CASE WHEN premium_canonica_id IS NOT NULL THEN 1 END) as tem_canonica_premium,
  COUNT(CASE WHEN digital = true THEN 1 END) as tem_digital,
  COUNT(CASE WHEN free_form = true THEN 1 END) as tem_free_form,
  COUNT(CASE WHEN descricao_completa IS NOT NULL THEN 1 END) as tem_descricao,
  COUNT(CASE WHEN beneficios IS NOT NULL THEN 1 END) as tem_beneficios
FROM public.vw_lentes_catalogo;

| analise                              | tem_canonica_generica | tem_canonica_premium | tem_digital | tem_free_form | tem_descricao | tem_beneficios |
| ------------------------------------ | --------------------- | -------------------- | ----------- | ------------- | ------------- | -------------- |
| Campos exclusivos vw_lentes_catalogo | 0                     | 0                    | 0           | 0             | 0             | 0              |
