-- ============================================================================
-- VERIFICAÇÃO: Campos Usados na Canonização
-- ============================================================================
-- Data: 22/01/2026
-- Objetivo: Verificar se os triggers estão usando TODOS os campos atualizados
--          (tratamentos, GAPs, etc) ou se há campos sendo ignorados
-- ============================================================================

-- ============================================================================
-- 1. VERIFICAR QUAIS CAMPOS A FUNÇÃO "encontrar_ou_criar_grupo_canonico" USA
-- ============================================================================

-- Analisando a função, ela usa para BUSCAR grupo existente:
-- ✅ tipo_lente
-- ✅ material  
-- ✅ indice_refracao
-- ✅ categoria_predominante
-- ✅ grau_esferico_min/max
-- ✅ grau_cilindrico_min/max
-- ✅ adicao_min/max
-- ✅ tratamento_antirreflexo (ar)
-- ✅ tratamento_antirrisco
-- ✅ tratamento_uv
-- ✅ tratamento_blue_light
-- ✅ tratamento_fotossensiveis

-- PROBLEMA POTENCIAL: A função "fn_associar_lente_grupo_automatico" NÃO verifica tratamentos!
-- Ela só verifica: tipo, material, índice, e RANGES de graus
-- Isso significa que lentes com tratamentos DIFERENTES podem estar no MESMO grupo!


-- ============================================================================
-- 2. VERIFICAR GRUPOS COM LENTES DE TRATAMENTOS DIFERENTES
-- ============================================================================

WITH grupos_tratamentos AS (
  SELECT
    gc.id as grupo_id,
    gc.nome_grupo,
    gc.tipo_lente,
    gc.material,
    gc.indice_refracao,
    gc.tratamento_antirreflexo as grupo_ar,
    gc.tratamento_uv as grupo_uv,
    gc.tratamento_blue_light as grupo_blue,
    gc.tratamento_fotossensiveis as grupo_foto,
    -- Tratamentos das lentes
    COUNT(DISTINCT l.ar) as variacoes_ar,
    COUNT(DISTINCT l.uv400) as variacoes_uv,
    COUNT(DISTINCT l.blue) as variacoes_blue,
    COUNT(DISTINCT l.fotossensivel) as variacoes_foto,
    COUNT(*) as total_lentes
  FROM lens_catalog.grupos_canonicos gc
  JOIN lens_catalog.lentes l ON l.grupo_canonico_id = gc.id
  WHERE gc.ativo = true AND l.ativo = true
  GROUP BY gc.id, gc.nome_grupo, gc.tipo_lente, gc.material, gc.indice_refracao,
           gc.tratamento_antirreflexo, gc.tratamento_uv, gc.tratamento_blue_light, 
           gc.tratamento_fotossensiveis
)
SELECT
  grupo_id,
  nome_grupo,
  tipo_lente,
  material,
  indice_refracao,
  total_lentes,
  CASE WHEN variacoes_ar > 1 THEN '⚠️ Lentes com e sem AR' ELSE '✅ OK' END as status_ar,
  CASE WHEN variacoes_uv > 1 THEN '⚠️ Lentes com e sem UV' ELSE '✅ OK' END as status_uv,
  CASE WHEN variacoes_blue > 1 THEN '⚠️ Lentes com e sem Blue' ELSE '✅ OK' END as status_blue,
  CASE WHEN variacoes_foto > 1 THEN '⚠️ Lentes com e sem Foto' ELSE '✅ OK' END as status_foto
FROM grupos_tratamentos
WHERE variacoes_ar > 1 
   OR variacoes_uv > 1 
   OR variacoes_blue > 1 
   OR variacoes_foto > 1
ORDER BY total_lentes DESC;

-- Se retornar linhas, significa que há grupos misturando lentes com tratamentos diferentes!

| grupo_id                             | nome_grupo                                                                                   | tipo_lente    | material      | indice_refracao | total_lentes | status_ar | status_uv | status_blue | status_foto              |
| ------------------------------------ | -------------------------------------------------------------------------------------------- | ------------- | ------------- | --------------- | ------------ | --------- | --------- | ----------- | ------------------------ |
| 0d592228-5b78-462d-96f6-846af9de46e0 | Lente CR39 1.50 Multifocal +UV +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]          | multifocal    | CR39          | 1.50            | 7            | ✅ OK      | ✅ OK      | ✅ OK        | ⚠️ Lentes com e sem Foto |
| ac55c792-f205-4607-9b5e-ff98058849eb | Lente CR39 1.67 Multifocal +UV +fotocromático [-12.00/9.00 | 0.00/-6.00 | 1.00/3.00]         | multifocal    | CR39          | 1.67            | 4            | ✅ OK      | ✅ OK      | ✅ OK        | ⚠️ Lentes com e sem Foto |
| e6568c60-e995-4f97-806d-036586784d89 | Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-8.00/8.00 | 0.00/-4.00 | 1.00/3.00] | multifocal    | POLICARBONATO | 1.59            | 4            | ✅ OK      | ✅ OK      | ✅ OK        | ⚠️ Lentes com e sem Foto |
| a9f93bb3-7f0d-448e-9278-b204c3c5e614 | Lente CR39 1.50 Visao Simples +UV +fotocromático [-6.00/6.00 | -4.00/0.00]                   | visao_simples | CR39          | 1.50            | 2            | ✅ OK      | ✅ OK      | ✅ OK        | ⚠️ Lentes com e sem Foto |
| bac7a06e-5415-4cfb-a1bc-175d7d771ce6 | Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]      | multifocal    | CR39          | 1.50            | 2            | ✅ OK      | ✅ OK      | ✅ OK        | ⚠️ Lentes com e sem Foto |
| d866c17c-bb77-4a23-8add-ed612b86afcb | Lente CR39 1.50 Visao Simples +AR +UV +fotocromático [-6.00/6.00 | -4.00/0.00]               | visao_simples | CR39          | 1.50            | 2            | ✅ OK      | ✅ OK      | ✅ OK        | ⚠️ Lentes com e sem Foto |


-- ============================================================================
-- 3. VERIFICAR GRUPOS DUPLICADOS COM RANGES IDÊNTICOS MAS TRATAMENTOS DIFERENTES
-- ============================================================================

SELECT
  tipo_lente,
  material,
  indice_refracao,
  grau_esferico_min,
  grau_esferico_max,
  grau_cilindrico_min,
  grau_cilindrico_max,
  COUNT(*) as grupos_com_mesmo_range,
  ARRAY_AGG(nome_grupo ORDER BY nome_grupo) as grupos,
  SUM(total_lentes) as total_lentes_todos_grupos
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
GROUP BY tipo_lente, material, indice_refracao,
         grau_esferico_min, grau_esferico_max,
         grau_cilindrico_min, grau_cilindrico_max
HAVING COUNT(*) > 1
ORDER BY grupos_com_mesmo_range DESC, total_lentes_todos_grupos DESC
LIMIT 20;

-- Esperado: Vários grupos com mesmos ranges mas tratamentos diferentes
-- Isso é CORRETO se os tratamentos forem diferentes

| tipo_lente    | material      | indice_refracao | grau_esferico_min | grau_esferico_max | grau_cilindrico_min | grau_cilindrico_max | grupos_com_mesmo_range | grupos                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | total_lentes_todos_grupos |
| ------------- | ------------- | --------------- | ----------------- | ----------------- | ------------------- | ------------------- | ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| multifocal    | CR39          | 1.50            | -8.00             | 6.50              | -6.00               | 0.00                | 10                     | ["Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00]","Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00]","Lente CR39 1.50 Multifocal +AR +UV +polarizado [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.50 Multifocal +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.50 Multifocal +UV [-8.00/6.50 | -6.00/0.00]","Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/6.50 | -6.00/0.00]","Lente CR39 1.50 Multifocal +UV +polarizado [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]"] | 145                       |
| multifocal    | POLICARBONATO | 1.59            | -10.00            | 8.00              | -6.00               | 0.00                | 8                      | ["Lente POLICARBONATO 1.59 Multifocal +AR +UV [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-10.00/8.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Multifocal +AR +UV +fotocromático [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Multifocal +UV [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-10.00/8.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]"]                                                     | 105                       |
| multifocal    | CR39          | 1.67            | -13.00            | 9.00              | -6.00               | 0.00                | 8                      | ["Lente CR39 1.67 Multifocal +AR +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Multifocal +AR +UV +BlueLight [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Multifocal +AR +UV +BlueLight [-13.00/9.00 | -6.00/0.00]","Lente CR39 1.67 Multifocal +AR +UV +fotocromático [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Multifocal +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Multifocal +UV +BlueLight [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Multifocal +UV +BlueLight [-13.00/9.00 | -6.00/0.00]","Lente CR39 1.67 Multifocal +UV +fotocromático [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]"]                                                                                                                             | 70                        |
| visao_simples | CR39          | 1.67            | -13.00            | 9.00              | -6.00               | 0.00                | 8                      | ["Lente CR39 1.67 Visao Simples +AR +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Visao Simples +AR +UV [-13.00/9.00 | -6.00/0.00]","Lente CR39 1.67 Visao Simples +AR +UV +BlueLight [-13.00/9.00 | -6.00/0.00]","Lente CR39 1.67 Visao Simples +AR +UV +fotocromático [-13.00/9.00 | -6.00/0.00]","Lente CR39 1.67 Visao Simples +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Visao Simples +UV [-13.00/9.00 | -6.00/0.00]","Lente CR39 1.67 Visao Simples +UV +BlueLight [-13.00/9.00 | -6.00/0.00]","Lente CR39 1.67 Visao Simples +UV +fotocromático [-13.00/9.00 | -6.00/0.00]"]                                                                                                                                                                           | 40                        |
| visao_simples | CR39          | 1.74            | -14.00            | 10.00             | -8.00               | 0.00                | 8                      | ["Lente CR39 1.74 Visao Simples +AR +UV [-14.00/10.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Visao Simples +AR +UV [-14.00/10.00 | -8.00/0.00]","Lente CR39 1.74 Visao Simples +AR +UV +BlueLight [-14.00/10.00 | -8.00/0.00]","Lente CR39 1.74 Visao Simples +AR +UV +fotocromático [-14.00/10.00 | -8.00/0.00]","Lente CR39 1.74 Visao Simples +UV [-14.00/10.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Visao Simples +UV [-14.00/10.00 | -8.00/0.00]","Lente CR39 1.74 Visao Simples +UV +BlueLight [-14.00/10.00 | -8.00/0.00]","Lente CR39 1.74 Visao Simples +UV +fotocromático [-14.00/10.00 | -8.00/0.00]"]                                                                                                                                                                   | 40                        |
| visao_simples | POLICARBONATO | 1.59            | -10.00            | 8.00              | -6.00               | 0.00                | 8                      | ["Lente POLICARBONATO 1.59 Visao Simples +AR +UV [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Visao Simples +AR +UV [-10.00/8.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Visao Simples +AR +UV +BlueLight [-10.00/8.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Visao Simples +AR +UV +fotocromático [-10.00/8.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Visao Simples +UV [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Visao Simples +UV [-10.00/8.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Visao Simples +UV +BlueLight [-10.00/8.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Visao Simples +UV +fotocromático [-10.00/8.00 | -6.00/0.00]"]                                                                                                   | 40                        |
| visao_simples | CR39          | 1.56            | -6.00             | 6.00              | -2.25               | -4.00               | 7                      | ["Lente CR39 1.56 Visao Simples +AR +UV [-6.00/6.00 | -2.25/-4.00]","Lente CR39 1.56 Visao Simples +AR +UV +BlueLight [-6.00/6.00 | -2.25/-4.00]","Lente CR39 1.56 Visao Simples +AR +UV +BlueLight +fotocromático [-6.00/6.00 | -2.25/-4.00]","Lente CR39 1.56 Visao Simples +AR +UV +fotocromático [-6.00/6.00 | -2.25/-4.00]","Lente CR39 1.56 Visao Simples +UV +BlueLight [-6.00/6.00 | -2.25/-4.00]","Lente CR39 1.56 Visao Simples +UV +BlueLight +fotocromático [-6.00/6.00 | -2.25/-4.00]","Lente CR39 1.56 Visao Simples +UV +fotocromático [-6.00/6.00 | -2.25/-4.00]"]                                                                                                                                                                                                              | 16                        |
| multifocal    | POLICARBONATO | 1.59            | -6.00             | 6.00              | -4.00               | 0.00                | 7                      | ["Lente POLICARBONATO 1.59 Multifocal +AR +UV [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]","Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]","Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]","Lente POLICARBONATO 1.59 Multifocal +UV [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]","Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]","Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]","Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]"]                                                                                                          | 9                         |
| multifocal    | CR39          | 1.74            | -15.00            | 10.00             | -8.00               | 0.00                | 6                      | ["Lente CR39 1.74 Multifocal +AR +UV [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Multifocal +AR +UV +BlueLight [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Multifocal +AR +UV +fotocromático [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Multifocal +UV [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Multifocal +UV +BlueLight [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Multifocal +UV +fotocromático [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]"]                                                                                                                                                                                                                                                                         | 40                        |
| multifocal    | CR39          | 1.67            | -13.00            | 9.00              | -8.00               | 0.00                | 6                      | ["Lente CR39 1.67 Multifocal +AR +UV [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Multifocal +AR +UV +BlueLight [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Multifocal +AR +UV +fotocromático [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Multifocal +UV [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Multifocal +UV +BlueLight [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]","Lente CR39 1.67 Multifocal +UV +fotocromático [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]"]                                                                                                                                                                                                                                                                               | 40                        |
| visao_simples | CR39          | 1.50            | -8.00             | 6.50              | -6.00               | 0.00                | 6                      | ["Lente CR39 1.50 Visao Simples +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.50 Visao Simples +AR +UV [-8.00/6.50 | -6.00/0.00]","Lente CR39 1.50 Visao Simples +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00]","Lente CR39 1.50 Visao Simples +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.50 Visao Simples +UV [-8.00/6.50 | -6.00/0.00]","Lente CR39 1.50 Visao Simples +UV +fotocromático [-8.00/6.50 | -6.00/0.00]"]                                                                                                                                                                                                                                                                                                                                         | 40                        |
| multifocal    | CR39          | 1.74            | -13.00            | 10.00             | -6.00               | 0.00                | 6                      | ["Lente CR39 1.74 Multifocal +AR +UV [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Multifocal +AR +UV +BlueLight [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Multifocal +AR +UV +fotocromático [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Multifocal +UV [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Multifocal +UV +BlueLight [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]","Lente CR39 1.74 Multifocal +UV +fotocromático [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]"]                                                                                                                                                                                                                                                                         | 35                        |
| visao_simples | POLICARBONATO | 1.59            | -8.00             | 7.00              | -4.00               | 0.00                | 6                      | ["Lente POLICARBONATO 1.59 Visao Simples +AR +UV [-8.00/7.00 | -4.00/0.00 | 0.50/1.25]","Lente POLICARBONATO 1.59 Visao Simples +AR +UV [-8.00/7.00 | -4.00/0.00 | 0.75/3.50]","Lente POLICARBONATO 1.59 Visao Simples +AR +UV +BlueLight [-8.00/7.00 | -4.00/0.00 | 0.50/1.25]","Lente POLICARBONATO 1.59 Visao Simples +UV [-8.00/7.00 | -4.00/0.00 | 0.50/1.25]","Lente POLICARBONATO 1.59 Visao Simples +UV [-8.00/7.00 | -4.00/0.00 | 0.75/3.50]","Lente POLICARBONATO 1.59 Visao Simples +UV +BlueLight [-8.00/7.00 | -4.00/0.00 | 0.50/1.25]"]                                                                                                                                                                                                                                           | 20                        |
| multifocal    | POLICARBONATO | 1.59            | -8.00             | 6.50              | -6.00               | 0.00                | 6                      | ["Lente POLICARBONATO 1.59 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Multifocal +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Multifocal +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]","Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]"]                                                                                                                                                                                                                               | 20                        |
| multifocal    | POLICARBONATO | 1.59            | -10.00            | 7.00              | -6.00               | 0.00                | 6                      | ["Lente POLICARBONATO 1.59 Multifocal +AR +UV [-10.00/7.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-10.00/7.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Multifocal +AR +UV +fotocromático [-10.00/7.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Multifocal +UV [-10.00/7.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-10.00/7.00 | -6.00/0.00]","Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-10.00/7.00 | -6.00/0.00]"]                                                                                                                                                                                                                                                                                                 | 20                        |
| multifocal    | CR39          | 1.74            | -13.00            | 11.00             | -6.00               | 0.00                | 6                      | ["Lente CR39 1.74 Multifocal +AR +UV [-13.00/11.00 | -6.00/0.00]","Lente CR39 1.74 Multifocal +AR +UV +BlueLight [-13.00/11.00 | -6.00/0.00]","Lente CR39 1.74 Multifocal +AR +UV +fotocromático [-13.00/11.00 | -6.00/0.00]","Lente CR39 1.74 Multifocal +UV [-13.00/11.00 | -6.00/0.00]","Lente CR39 1.74 Multifocal +UV +BlueLight [-13.00/11.00 | -6.00/0.00]","Lente CR39 1.74 Multifocal +UV +fotocromático [-13.00/11.00 | -6.00/0.00]"]                                                                                                                                                                                                                                                                                                                                                 | 20                        |
| multifocal    | POLICARBONATO | 1.59            | -8.00             | 6.00              | -5.00               | 0.00                | 6                      | ["Lente POLICARBONATO 1.59 Multifocal +AR +UV [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]","Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]","Lente POLICARBONATO 1.59 Multifocal +AR +UV +fotocromático [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]","Lente POLICARBONATO 1.59 Multifocal +UV [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]","Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]","Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]"]                                                                                                                                                                                                                               | 20                        |
| visao_simples | CR39          | 1.67            | -9.50             | 7.50              | -4.00               | 0.00                | 6                      | ["Lente CR39 1.67 Visao Simples +AR +UV [-9.50/7.50 | -4.00/0.00 | 0.50/1.25]","Lente CR39 1.67 Visao Simples +AR +UV [-9.50/7.50 | -4.00/0.00 | 0.75/3.50]","Lente CR39 1.67 Visao Simples +AR +UV +BlueLight [-9.50/7.50 | -4.00/0.00 | 0.50/1.25]","Lente CR39 1.67 Visao Simples +UV [-9.50/7.50 | -4.00/0.00 | 0.50/1.25]","Lente CR39 1.67 Visao Simples +UV [-9.50/7.50 | -4.00/0.00 | 0.75/3.50]","Lente CR39 1.67 Visao Simples +UV +BlueLight [-9.50/7.50 | -4.00/0.00 | 0.50/1.25]"]                                                                                                                                                                                                                                                                                                 | 20                        |
| multifocal    | CR39          | 1.67            | -12.00            | 10.00             | -6.00               | 0.00                | 6                      | ["Lente CR39 1.67 Multifocal +AR +UV [-12.00/10.00 | -6.00/0.00]","Lente CR39 1.67 Multifocal +AR +UV +BlueLight [-12.00/10.00 | -6.00/0.00]","Lente CR39 1.67 Multifocal +AR +UV +fotocromático [-12.00/10.00 | -6.00/0.00]","Lente CR39 1.67 Multifocal +UV [-12.00/10.00 | -6.00/0.00]","Lente CR39 1.67 Multifocal +UV +BlueLight [-12.00/10.00 | -6.00/0.00]","Lente CR39 1.67 Multifocal +UV +fotocromático [-12.00/10.00 | -6.00/0.00]"]                                                                                                                                                                                                                                                                                                                                                 | 20                        |
| visao_simples | CR39          | 1.74            | -9.50             | 7.50              | -4.00               | 0.00                | 6                      | ["Lente CR39 1.74 Visao Simples +AR +UV [-9.50/7.50 | -4.00/0.00 | 0.50/1.25]","Lente CR39 1.74 Visao Simples +AR +UV [-9.50/7.50 | -4.00/0.00 | 0.75/3.50]","Lente CR39 1.74 Visao Simples +AR +UV +BlueLight [-9.50/7.50 | -4.00/0.00 | 0.50/1.25]","Lente CR39 1.74 Visao Simples +UV [-9.50/7.50 | -4.00/0.00 | 0.50/1.25]","Lente CR39 1.74 Visao Simples +UV [-9.50/7.50 | -4.00/0.00 | 0.75/3.50]","Lente CR39 1.74 Visao Simples +UV +BlueLight [-9.50/7.50 | -4.00/0.00 | 0.50/1.25]"]                                                                                                                                                                                                                                                                                                 | 15                        |


-- ============================================================================
-- 4. ANALISAR UM GRUPO ESPECÍFICO (Multifocal CR39 1.50)
-- ============================================================================

SELECT
  gc.nome_grupo,
  l.nome_lente,
  l.ar,
  l.uv400,
  l.blue,
  l.fotossensivel,
  l.preco_venda_sugerido,
  l.esferico_min,
  l.esferico_max
FROM lens_catalog.grupos_canonicos gc
JOIN lens_catalog.lentes l ON l.grupo_canonico_id = gc.id
WHERE gc.tipo_lente = 'multifocal'
  AND gc.material = 'CR39'
  AND gc.indice_refracao = '1.50'
  AND gc.ativo = true
  AND l.ativo = true
ORDER BY gc.nome_grupo, l.ar, l.blue, l.fotossensivel
LIMIT 30;



| nome_grupo                                                               | nome_lente                                         | ar   | uv400 | blue  | fotossensivel | preco_venda_sugerido | esferico_min | esferico_max |
| ------------------------------------------------------------------------ | -------------------------------------------------- | ---- | ----- | ----- | ------------- | -------------------- | ------------ | ------------ |
| Lente CR39 1.50 Multifocal +AR +UV [-6.00/6.00 | -4.00/0.00 | 1.00/3.50] | POLYLUX FREE FORM CR39 AR                          | true | true  | false | nenhum        | 785.79               | -6.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-6.00/6.00 | -6.00/0.00 | 0.50/4.50] | MULTI 1.49 FREEVIEW GENESIS AR FAST                | true | true  | false | nenhum        | 3147.96              | -6.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-6.00/6.00 | -6.00/0.00 | 0.50/4.50] | MULTI 1.49 FREEVIEW GENESIS PREMIUM AR FAST        | true | true  | false | nenhum        | 3851.91              | -6.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-6.00/6.00 | -6.00/0.00 | 0.50/4.50] | MULTI 1.49 FREEVIEW GENESIS AR FAST AZUL           | true | true  | false | nenhum        | 3288.75              | -6.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-6.00/6.00 | -6.00/0.00 | 0.50/4.50] | MULTI 1.49 FREEVIEW GENESIS PREMIUM AR FAST AZUL   | true | true  | false | nenhum        | 3992.70              | -6.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-7.00/5.00 | -4.00/0.00 | 1.00/3.50] | MULTI 1.49 FOTO FREE FORM (AR FAST AZUL)           | true | true  | false | nenhum        | 1474.10              | -7.00        | 5.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-7.00/5.00 | -4.00/0.00 | 1.00/3.50] | MULTI 1.49 FREE FORM (AR FAST)                     | true | true  | false | nenhum        | 965.69               | -7.00        | 5.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-7.00/5.00 | -4.00/0.00 | 1.00/3.50] | MULTI 1.49 FOTO FREE FORM (AR FAST)                | true | true  | false | nenhum        | 1333.31              | -7.00        | 5.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-7.00/5.00 | -4.00/0.00 | 1.00/3.50] | MULTI 1.49 FREE FORM (AR FAST AZUL)                | true | true  | false | nenhum        | 1106.48              | -7.00        | 5.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -4.00/0.00 | 1.00/3.50] | MULTI 1.49 TOP LIGHT FF (AR FAST)                  | true | true  | false | nenhum        | 996.98               | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -4.00/0.00 | 1.00/3.50] | MULTI 1.49 TOP LIGHT FF FOTO (AR FAST)             | true | true  | false | nenhum        | 1567.96              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -4.00/0.00 | 1.00/3.50] | MULTI 1.49 TOP LIGHT FF (AR FAST AZUL)             | true | true  | false | nenhum        | 1137.77              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -4.00/0.00 | 1.00/3.50] | MULTI 1.49 TOP LIGHT FF FOTO (AR FAST SH)          | true | true  | false | nenhum        | 1896.48              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -4.00/0.00 | 1.00/3.50] | MULTI 1.49 TOP LIGHT FF (AR FAST SH)               | true | true  | false | nenhum        | 1325.49              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -4.00/0.00 | 1.00/3.50] | MULTI 1.49 TOP LIGHT FF FOTO (AR FAST AZUL)        | true | true  | false | nenhum        | 1708.75              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -5.00/0.00 | 0.75/3.50] | MULTI 1.49 TOP VIEW FF (AR FAST AZUL)              | true | true  | false | nenhum        | 1372.42              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -5.00/0.00 | 0.75/3.50] | MULTI 1.49 TOP VIEW FF AR FAST AZUL                | true | true  | false | nenhum        | 1372.42              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -5.00/0.00 | 0.75/3.50] | MULTI 1.49 TOP VIEW FF AR FAST                     | true | true  | false | nenhum        | 1231.63              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -5.00/0.00 | 0.75/3.50] | MULTI 1.49 TOP VIEW FF FOTO AR FAST                | true | true  | false | nenhum        | 2092.02              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -5.00/0.00 | 0.75/3.50] | MULTI 1.49 TOP VIEW FF (AR FAST)                   | true | true  | false | nenhum        | 1231.63              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -5.00/0.00 | 0.75/3.50] | MULTI 1.49 TOP VIEW FF FOTO AR FAST AZUL           | true | true  | false | nenhum        | 2232.81              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | 0.00/0.00 | 0.75/3.50]  | MULTI 1.49 TOP VIEW FF AR FAST AZUL                | true | true  | false | nenhum        | 1372.42              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | 0.00/0.00 | 0.75/3.50]  | MULTI 1.49 TOP VIEW FF AR FAST                     | true | true  | false | nenhum        | 1231.63              | -8.00        | 6.00         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50] | MULTI 1.49 FREEVIEW EASY AR FAST                   | true | true  | false | nenhum        | 1857.37              | -8.00        | 6.50         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50] | MULTI 1.49 FREEVIEW PRO AR FAST AZUL               | true | true  | false | nenhum        | 2154.59              | -8.00        | 6.50         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50] | MULTI 1.49 FREEVIEW SILVER FOTO AR FAST            | true | true  | false | nenhum        | 2561.32              | -8.00        | 6.50         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50] | MULTI 1.49 FREEVIEW HD SLIM AR FAST                | true | true  | false | nenhum        | 2287.56              | -8.00        | 6.50         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50] | MULTI 1.49 FREEVIEW HD SLIM FOTO AR FAST           | true | true  | false | nenhum        | 2835.09              | -8.00        | 6.50         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50] | MULTI 1.49 FREEVIEW PRO FOTOSSENS�VEL AR FAST AZUL | true | true  | false | nenhum        | 2702.12              | -8.00        | 6.50         |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50] | MULTI 1.49 FREEVIEW HD FOTO AR FAST                | true | true  | false | nenhum        | 2639.54              | -8.00        | 6.50         |

-- ============================================================================
-- 5. CONTAGEM DE GRUPOS POR COMBINAÇÃO DE TRATAMENTOS
-- ============================================================================

SELECT
  tipo_lente,
  material,
  indice_refracao,
  tratamento_antirreflexo as tem_ar,
  tratamento_uv as tem_uv,
  tratamento_blue_light as tem_blue,
  tratamento_fotossensiveis as tem_foto,
  COUNT(*) as total_grupos,
  SUM(total_lentes) as total_lentes
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
GROUP BY tipo_lente, material, indice_refracao,
         tratamento_antirreflexo, tratamento_uv, 
         tratamento_blue_light, tratamento_fotossensiveis
ORDER BY total_lentes DESC
LIMIT 30;



| tipo_lente    | material      | indice_refracao | tem_ar | tem_uv | tem_blue | tem_foto      | total_grupos | total_lentes |
| ------------- | ------------- | --------------- | ------ | ------ | -------- | ------------- | ------------ | ------------ |
| multifocal    | CR39          | 1.50            | false  | true   | false    | nenhum        | 13           | 78           |
| multifocal    | CR39          | 1.67            | false  | true   | false    | nenhum        | 9            | 61           |
| multifocal    | POLICARBONATO | 1.59            | false  | true   | true     | nenhum        | 9            | 59           |
| multifocal    | CR39          | 1.50            | false  | true   | false    | fotocromático | 9            | 57           |
| multifocal    | CR39          | 1.74            | false  | true   | false    | nenhum        | 9            | 53           |
| multifocal    | CR39          | 1.50            | true   | true   | false    | nenhum        | 8            | 51           |
| multifocal    | POLICARBONATO | 1.59            | true   | true   | true     | nenhum        | 12           | 50           |
| multifocal    | CR39          | 1.67            | true   | true   | false    | nenhum        | 9            | 48           |
| multifocal    | POLICARBONATO | 1.59            | false  | true   | false    | nenhum        | 11           | 39           |
| multifocal    | CR39          | 1.50            | true   | true   | false    | fotocromático | 5            | 35           |
| multifocal    | CR39          | 1.67            | false  | true   | true     | nenhum        | 10           | 35           |
| multifocal    | CR39          | 1.74            | true   | true   | false    | nenhum        | 7            | 34           |
| multifocal    | CR39          | 1.56            | false  | true   | true     | nenhum        | 9            | 33           |
| multifocal    | CR39          | 1.74            | false  | true   | true     | nenhum        | 8            | 30           |
| visao_simples | CR39          | 1.50            | false  | true   | false    | nenhum        | 12           | 30           |
| multifocal    | CR39          | 1.56            | true   | true   | true     | nenhum        | 11           | 29           |
| multifocal    | POLICARBONATO | 1.59            | false  | true   | false    | fotocromático | 6            | 29           |
| visao_simples | CR39          | 1.67            | false  | true   | false    | nenhum        | 11           | 28           |
| multifocal    | POLICARBONATO | 1.59            | true   | true   | false    | nenhum        | 9            | 27           |
| visao_simples | POLICARBONATO | 1.59            | false  | true   | true     | nenhum        | 10           | 26           |
| multifocal    | CR39          | 1.67            | true   | true   | true     | nenhum        | 9            | 26           |
| visao_simples | CR39          | 1.74            | false  | true   | false    | nenhum        | 10           | 25           |
| visao_simples | CR39          | 1.56            | true   | true   | true     | nenhum        | 13           | 24           |
| visao_simples | POLICARBONATO | 1.59            | true   | true   | true     | nenhum        | 9            | 21           |
| multifocal    | CR39          | 1.74            | true   | true   | true     | nenhum        | 8            | 20           |
| visao_simples | POLICARBONATO | 1.59            | false  | true   | false    | nenhum        | 11           | 19           |
| visao_simples | CR39          | 1.56            | false  | true   | true     | nenhum        | 10           | 19           |
| multifocal    | CR39          | 1.67            | false  | true   | false    | fotocromático | 5            | 19           |
| multifocal    | POLICARBONATO | 1.59            | false  | true   | false    | polarizado    | 3            | 18           |
| multifocal    | CR39          | 1.50            | false  | true   | false    | polarizado    | 3            | 18           |


-- ============================================================================
-- 6. VERIFICAR SE HÁ LENTES COM TRATAMENTOS DIFERENTES DO GRUPO
-- ============================================================================

SELECT
  gc.id,
  gc.nome_grupo,
  COUNT(*) as lentes_incompativeis,
  ARRAY_AGG(DISTINCT 
    CASE 
      WHEN l.ar != gc.tratamento_antirreflexo THEN 'AR incompatível'
      WHEN l.uv400 != gc.tratamento_uv THEN 'UV incompatível'
      WHEN l.blue != gc.tratamento_blue_light THEN 'Blue incompatível'
      WHEN COALESCE(l.fotossensivel, 'nenhum') != COALESCE(gc.tratamento_fotossensiveis, 'nenhum') 
        THEN 'Fotossensível incompatível'
    END
  ) as problemas
FROM lens_catalog.grupos_canonicos gc
JOIN lens_catalog.lentes l ON l.grupo_canonico_id = gc.id
WHERE gc.ativo = true
  AND l.ativo = true
  AND (
    l.ar != gc.tratamento_antirreflexo
    OR l.uv400 != gc.tratamento_uv
    OR l.blue != gc.tratamento_blue_light
    OR COALESCE(l.fotossensivel, 'nenhum') != COALESCE(gc.tratamento_fotossensiveis, 'nenhum')
  )
GROUP BY gc.id, gc.nome_grupo
ORDER BY lentes_incompativeis DESC;

-- ⚠️ CRÍTICO: Se retornar linhas, significa que lentes estão em grupos ERRADOS!


| id                                   | nome_grupo                                                                                        | lentes_incompativeis | problemas                      |
| ------------------------------------ | ------------------------------------------------------------------------------------------------- | -------------------- | ------------------------------ |
| f4352d04-8970-4939-8a8b-ec4e0f172a08 | Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]               | 36                   | ["Fotossensível incompatível"] |
| 1355a3cb-7e0d-4512-85fb-93322feb8aa6 | Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]           | 24                   | ["Fotossensível incompatível"] |
| e47ca0ed-48a9-4ad7-b2ca-e756a67a2fd9 | Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]     | 15                   | ["Fotossensível incompatível"] |
| 993119bf-4d3f-463b-a9a1-4f06bfcf3f40 | Lente CR39 1.50 Visao Simples +UV +fotocromático [-8.00/6.50 | -6.00/0.00]                        | 12                   | ["Fotossensível incompatível"] |
| a3b374a0-3fcd-498e-b5bd-28ee12a3ed37 | Lente POLICARBONATO 1.59 Multifocal +AR +UV +fotocromático [-10.00/8.00 | -6.00/0.00 | 0.50/4.50] | 10                   | ["Fotossensível incompatível"] |
| 2b2bae8b-6c65-4dc9-919b-b309be7387e7 | Lente CR39 1.50 Visao Simples +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00]                    | 8                    | ["Fotossensível incompatível"] |
| dc396033-574f-4407-8fe9-9eadae557bde | Lente CR39 1.67 Multifocal +UV +fotocromático [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]              | 6                    | ["Fotossensível incompatível"] |
| c029d8d7-953c-4453-ae8e-f3d1e26ab9b7 | Lente CR39 1.67 Visao Simples +UV +fotocromático [-13.00/9.00 | -6.00/0.00]                       | 6                    | ["Fotossensível incompatível"] |
| f916497e-6b49-48eb-8cee-cc4f327a20cc | Lente CR39 1.74 Visao Simples +UV +fotocromático [-14.00/10.00 | -8.00/0.00]                      | 6                    | ["Fotossensível incompatível"] |
| 6831773b-67da-4b41-9dfe-d30749088744 | Lente CR39 1.74 Multifocal +UV +fotocromático [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]             | 6                    | ["Fotossensível incompatível"] |
| 452e62f3-5b39-455d-b301-f2094f0ee7d4 | Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]               | 6                    | ["Fotossensível incompatível"] |
| 24cb65f7-a9aa-475c-8544-7ff0df4ae933 | Lente POLICARBONATO 1.59 Visao Simples +UV +fotocromático [-10.00/8.00 | -6.00/0.00]              | 6                    | ["Fotossensível incompatível"] |
| 0d592228-5b78-462d-96f6-846af9de46e0 | Lente CR39 1.50 Multifocal +UV +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]               | 6                    | ["Fotossensível incompatível"] |
| 0226073a-24d6-4575-846b-b47b628502b8 | Lente CR39 1.67 Multifocal +AR +UV +fotocromático [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]          | 4                    | ["Fotossensível incompatível"] |
| 2b045950-4a19-4cde-914c-86eb3284f79a | Lente CR39 1.67 Visao Simples +AR +UV +fotocromático [-13.00/9.00 | -6.00/0.00]                   | 4                    | ["Fotossensível incompatível"] |
| 113bc859-170e-4204-af23-aaa0ad7734bf | Lente POLICARBONATO 1.59 Visao Simples +AR +UV +fotocromático [-10.00/8.00 | -6.00/0.00]          | 4                    | ["Fotossensível incompatível"] |
| 5883b2a4-1add-405b-9f16-1b955b7c84db | Lente CR39 1.74 Multifocal +AR +UV +fotocromático [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]         | 4                    | ["Fotossensível incompatível"] |
| 16283b20-8faf-4a7d-93e5-71998867b726 | Lente CR39 1.74 Visao Simples +AR +UV +fotocromático [-14.00/10.00 | -8.00/0.00]                  | 4                    | ["Fotossensível incompatível"] |
| 86501fdc-d4e9-4085-a09b-6a24264aa952 | Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]           | 4                    | ["Fotossensível incompatível"] |
| 46822afe-0d1d-4e12-ab6c-fbfdf8ab8f47 | Lente CR39 1.67 Multifocal +UV +fotocromático [-12.00/9.00 | -6.00/0.00 | 0.50/4.50]              | 3                    | ["Fotossensível incompatível"] |
| 24ccbcca-bfdc-46ac-ad3f-85f946ac54b6 | Lente CR39 1.67 Multifocal +UV +fotocromático [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]              | 3                    | ["Fotossensível incompatível"] |
| 92aaf342-7aa3-4e9f-8d06-ccbac381df8f | Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]      | 3                    | ["Fotossensível incompatível"] |
| af4fdc4a-e8ce-40a2-9a1c-215131cc0691 | Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-10.00/7.00 | -6.00/0.00]                 | 3                    | ["Fotossensível incompatível"] |
| 61c9a6e1-90ee-422b-a1f1-283c43cea2c7 | Lente CR39 1.74 Multifocal +UV +fotocromático [-13.00/11.00 | -6.00/0.00]                         | 3                    | ["Fotossensível incompatível"] |
| f2756736-bb1d-4ddb-9a80-2276802a6b08 | Lente CR39 1.74 Multifocal +UV +fotocromático [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]             | 3                    | ["Fotossensível incompatível"] |
| c99ea0a3-9ef3-4228-83e8-d6c02192e941 | Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-8.00/6.00 | -4.00/0.00 | 1.00/3.50]           | 3                    | ["Fotossensível incompatível"] |
| f9d7eaee-bdaf-41e5-822c-af4db1d8406b | Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]      | 3                    | ["Fotossensível incompatível"] |
| 45b35696-dabc-47d6-b8eb-6fd7d172a7a9 | Lente CR39 1.67 Multifocal +UV +fotocromático [-12.00/10.00 | -6.00/0.00]                         | 3                    | ["Fotossensível incompatível"] |
| 45fd4771-bceb-4347-a098-f0e9b131d3d9 | Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/6.50 | -6.00/0.00]                           | 3                    | ["Fotossensível incompatível"] |
| 6fc9584b-b6dd-4b17-a286-f427c4736fab | Lente CR39 1.74 Multifocal +AR +UV +fotocromático [-13.00/11.00 | -6.00/0.00]                     | 2                    | ["Fotossensível incompatível"] |
| 04510613-db9f-4553-ac0c-30303a02207f | Lente POLICARBONATO 1.59 Multifocal +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]  | 2                    | ["Fotossensível incompatível"] |
| 0deb3e4b-3736-4e3d-bb42-b2a5e682dabc | Lente POLICARBONATO 1.59 Multifocal +AR +UV +fotocromático [-10.00/7.00 | -6.00/0.00]             | 2                    | ["Fotossensível incompatível"] |
| 0fd0a796-458a-473b-aca1-3394097e9ccb | Lente CR39 1.74 Multifocal +AR +UV +fotocromático [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]         | 2                    | ["Fotossensível incompatível"] |
| 299382fc-d9ba-426b-84c5-b7a73c84b3c0 | Lente CR39 1.56 Multifocal +AR +UV +fotocromático [-7.00/5.00 | -4.00/0.00 | 1.00/3.50]           | 2                    | ["Fotossensível incompatível"] |
| 44e34980-c4c4-4925-a306-4433f96ea239 | Lente CR39 1.67 Multifocal +AR +UV +fotocromático [-12.00/9.00 | -6.00/0.00 | 0.50/4.50]          | 2                    | ["Fotossensível incompatível"] |
| 5f833bbb-a258-4a3c-9c5e-b0f13b932f9a | Lente CR39 1.59 Multifocal +UV +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]               | 2                    | ["Fotossensível incompatível"] |
| 68263355-1d44-43b9-9775-f053b42e2b3a | Lente CR39 1.67 Multifocal +AR +UV +fotocromático [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]          | 2                    | ["Fotossensível incompatível"] |
| ac55c792-f205-4607-9b5e-ff98058849eb | Lente CR39 1.67 Multifocal +UV +fotocromático [-12.00/9.00 | 0.00/-6.00 | 1.00/3.00]              | 2                    | ["Fotossensível incompatível"] |
| b7318d55-cddf-4aef-ae06-7fb7f0614cf7 | Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00]                       | 2                    | ["Fotossensível incompatível"] |
| c12a68f1-a6ee-4455-b60d-c12299cc4e55 | Lente CR39 1.67 Multifocal +AR +UV +fotocromático [-12.00/10.00 | -6.00/0.00]                     | 2                    | ["Fotossensível incompatível"] |
| e0dc170a-d6f0-474a-8e2e-e6509ca2008b | Lente POLICARBONATO 1.59 Multifocal +AR +UV +fotocromático [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]  | 2                    | ["Fotossensível incompatível"] |
| e6568c60-e995-4f97-806d-036586784d89 | Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-8.00/8.00 | 0.00/-4.00 | 1.00/3.00]      | 2                    | ["Fotossensível incompatível"] |
| c9018c4e-edb7-4aa0-82a9-a1422a1e575e | Lente CR39 1.50 Multifocal +UV +fotocromático [-4.00/4.00 | -4.00/0.00 | 1.00/3.50]               | 1                    | ["Fotossensível incompatível"] |
| 9b9f7d70-b5dc-4dc8-8efd-763e77db83ff | Lente CR39 1.50 Multifocal +UV +fotocromático [-5.00/6.00 | 0.00/-4.00 | 1.00/3.00]               | 1                    | ["Fotossensível incompatível"] |
| d7f2decc-cadd-4c86-b1e3-7a9f44cba37d | Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/8.00 | 0.00/-4.00 | 1.00/3.00]               | 1                    | ["Fotossensível incompatível"] |
| d866c17c-bb77-4a23-8add-ed612b86afcb | Lente CR39 1.50 Visao Simples +AR +UV +fotocromático [-6.00/6.00 | -4.00/0.00]                    | 1                    | ["Fotossensível incompatível"] |
| 885df9ba-8446-4a00-a29d-3c95b11a69d0 | Lente CR39 1.56 Visao Simples +UV +fotocromático [-4.00/4.00 | -2.00/0.00]                        | 1                    | ["Fotossensível incompatível"] |
| 2ddb3ce0-f537-44dd-87e5-eb02cc3b7743 | Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/6.00 | -4.00/0.00 | 1.00/3.50]               | 1                    | ["Fotossensível incompatível"] |
| e30dbb13-8b6f-47ee-839e-42d98caabeb0 | Lente CR39 1.56 Multifocal +UV +fotocromático [-7.00/5.00 | -4.00/0.00 | 1.00/3.50]               | 1                    | ["Fotossensível incompatível"] |
| 6604b87e-a01f-47d0-bb99-04cfb6a16736 | Lente CR39 1.50 Visao Simples +AR +UV +fotocromático [-2.00/2.00 | 0.00/-2.00]                    | 1                    | ["Fotossensível incompatível"] |
| fd48dd98-789c-4951-87a8-c90c1d5990c2 | Lente CR39 1.50 Multifocal +UV +fotocromático [-5.00/5.00 | -4.00/0.00 | 1.00/3.50]               | 1                    | ["Fotossensível incompatível"] |
| 625e5366-9e89-47ec-a1cf-b935190395be | Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]      | 1                    | ["Fotossensível incompatível"] |
| 520981ba-b797-4934-920e-7d7630c835c7 | Lente CR39 1.50 Visao Simples +UV +fotocromático [2.25/4.00 | -2.25/-4.00]                        | 1                    | ["Fotossensível incompatível"] |
| bac7a06e-5415-4cfb-a1bc-175d7d771ce6 | Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]           | 1                    | ["Fotossensível incompatível"] |
| a9f93bb3-7f0d-448e-9278-b204c3c5e614 | Lente CR39 1.50 Visao Simples +UV +fotocromático [-6.00/6.00 | -4.00/0.00]                        | 1                    | ["Fotossensível incompatível"] |
| 42a074d3-3ec6-4995-a55a-561a8e384fd0 | Lente CR39 1.50 Visao Simples +UV +fotocromático [-10.00/12.00 | 0.00/-6.00]                      | 1                    | ["Fotossensível incompatível"] |



-- ============================================================================
-- DIAGNÓSTICO FINAL
-- ============================================================================

-- PERGUNTA CHAVE: Os triggers consideram TODOS os campos?

-- RESPOSTA:
-- ❌ "fn_associar_lente_grupo_automatico" → NÃO verifica tratamentos
--    Ele só verifica: tipo, material, índice, ranges de graus
--    Lentes com TRATAMENTOS DIFERENTES podem ir para o MESMO grupo!
--
-- ✅ "encontrar_ou_criar_grupo_canonico" → SIM verifica tratamentos
--    Ele busca/cria grupos considerando TODOS os tratamentos
--
-- PROBLEMA: Há 2 triggers diferentes com lógicas diferentes!
-- - trg_lentes_associar_grupo → usa fn_associar_lente_grupo_automatico (SEM tratamentos)
-- - trg_lente_insert_update → usa trigger_atualizar_grupo_canonico (COM tratamentos)
--
-- SOLUÇÃO: Precisamos garantir que apenas UM trigger está ativo, 
--          e que ele use a função COMPLETA (com tratamentos)


-- ============================================================================
-- RECOMENDAÇÃO
-- ============================================================================

-- Se a query 6 retornar MUITAS linhas (lentes incompatíveis com seus grupos):
-- → PRECISA re-canonizar usando apenas a função correta
--
-- Se retornar 0 linhas:
-- → Sistema está OK, os triggers corretos estão funcionando
-- ============================================================================
