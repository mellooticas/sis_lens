-- ============================================
-- TESTES DAS VIEWS CRIADAS
-- Validar que as views estão retornando dados
-- ============================================

-- 1. TESTE: vw_lentes_catalogo - Ver primeiras 5 lentes
SELECT 
  '=== TESTE 1: vw_lentes_catalogo (5 primeiras) ===' as teste,
  id,
  sku_fornecedor,
  nome_comercial,
  marca_nome,
  tipo_lente,
  categoria,
  material,
  indice_refracao,
  preco_tabela,
  disponivel
FROM public.vw_lentes_catalogo
LIMIT 5;

| teste                                             | id                                   | sku_fornecedor | nome_comercial                                 | marca_nome | tipo_lente    | categoria     | material      | indice_refracao | preco_tabela | disponivel |
| ------------------------------------------------- | ------------------------------------ | -------------- | ---------------------------------------------- | ---------- | ------------- | ------------- | ------------- | --------------- | ------------ | ---------- |
| === TESTE 1: vw_lentes_catalogo (5 primeiras) === | 00594427-93b0-4842-854c-9171a76ca911 | LEN-00594427   | SYGMA PRIME 1.67 PHOTO BLUECUT                 | EXPRESS    | visao_simples | premium       | CR39          | 1.67            | 1867.50      | true       |
| === TESTE 1: vw_lentes_catalogo (5 primeiras) === | 00757a23-456a-4108-afef-ac7e35a6b9d9 | LEN-00757A23   | MULTI 1.49 FREEVIEW SILVER AR FAST SH          | SOBLOCOS   | visao_simples | premium       | CR39          | 1.50            | 2136.00      | true       |
| === TESTE 1: vw_lentes_catalogo (5 primeiras) === | 007a5411-0392-4ffd-a727-962665fec745 | LEN-007A5411   | VS HDI 1.74 SLIM BLUE FILTER AR FAST AZUL      | SOBLOCOS   | visao_simples | super_premium | CR39          | 1.74            | 6116.10      | true       |
| === TESTE 1: vw_lentes_catalogo (5 primeiras) === | 00b71f1f-3e75-4451-8d99-24a25979042c | LEN-00B71F1F   | LT 1.59 POLICARBONATO FOTO AR (RESIDUAL VERDE) | EXPRESS    | visao_simples | economica     | POLICARBONATO | 1.59            | 120.00       | true       |
| === TESTE 1: vw_lentes_catalogo (5 primeiras) === | 0058ca99-8743-45be-bedf-cff8dcc9a44f | LEN-0058CA99   | FREEVIEW HDI 1.67 BLUE FILTER AR FAST TITANIUM | SOBLOCOS   | visao_simples | super_premium | CR39          | 1.67            | 5395.00      | true       |



-- 2. TESTE: vw_canonicas_genericas - Grupos canônicos genéricos
SELECT 
  '=== TESTE 2: vw_canonicas_genericas ===' as teste,
  id,
  nome_canonico,
  tipo_lente,
  material,
  indice_refracao,
  lentes_ativas,
  total_marcas,
  marcas_disponiveis
FROM public.vw_canonicas_genericas
LIMIT 5;

| teste                                   | id                                   | nome_canonico                         | tipo_lente | material      | indice_refracao | lentes_ativas | total_marcas | marcas_disponiveis |
| --------------------------------------- | ------------------------------------ | ------------------------------------- | ---------- | ------------- | --------------- | ------------- | ------------ | ------------------ |
| === TESTE 2: vw_canonicas_genericas === | 15a66f62-abe0-49dc-b106-94119571269d | bifocal CR39 1.50                     | bifocal    | CR39          | 1.50            | 0             | 0            | null               |
| === TESTE 2: vw_canonicas_genericas === | 3631105a-b026-4a97-bdfd-504382088fc4 | ESSILOR multifocal CR39 1.50          | multifocal | CR39          | 1.50            | 0             | 0            | null               |
| === TESTE 2: vw_canonicas_genericas === | 0bcb8acf-7174-4a78-89c4-8dad971bf6c9 | ESSILOR multifocal CR39 1.50          | multifocal | CR39          | 1.50            | 0             | 0            | null               |
| === TESTE 2: vw_canonicas_genericas === | 0fa80e21-49cb-497b-84fe-23dee822d23a | ESSILOR multifocal POLICARBONATO 1.59 | multifocal | POLICARBONATO | 1.59            | 0             | 0            | null               |
| === TESTE 2: vw_canonicas_genericas === | 6522c02f-0ac8-4968-b2c6-e20ec73c6340 | ESSILOR multifocal TRIVEX 1.59        | multifocal | TRIVEX        | 1.59            | 0             | 0            | null               |



-- 3. TESTE: vw_canonicas_premium - Grupos canônicos premium
SELECT 
  '=== TESTE 3: vw_canonicas_premium ===' as teste,
  id,
  marca_nome,
  linha_produto,
  nome_canonico,
  tipo_lente,
  material,
  lentes_ativas,
  preco_minimo,
  preco_maximo,
  preco_medio
FROM public.vw_canonicas_premium
LIMIT 5;

| teste                                 | id                                   | marca_nome | linha_produto | nome_canonico                | tipo_lente | material | lentes_ativas | preco_minimo | preco_maximo | preco_medio |
| ------------------------------------- | ------------------------------------ | ---------- | ------------- | ---------------------------- | ---------- | -------- | ------------- | ------------ | ------------ | ----------- |
| === TESTE 3: vw_canonicas_premium === | 8bbceb1d-a0ce-4b17-9e1d-8a7bc06d4392 | BRASCOR    | null          | BRASCOR multifocal CR39 1.56 | multifocal | CR39     | 1             | 188.00       | 188.00       | 188.00      |
| === TESTE 3: vw_canonicas_premium === | b981fd56-9bf9-4b23-9896-ca52accbd512 | BRASCOR    | null          | BRASCOR multifocal CR39 1.56 | multifocal | CR39     | 1             | 349.20       | 349.20       | 349.20      |
| === TESTE 3: vw_canonicas_premium === | 3f8b3a22-d21a-4b3b-a72c-c398e93e79e3 | BRASCOR    | null          | BRASCOR multifocal CR39 1.56 | multifocal | CR39     | 1             | 305.50       | 305.50       | 305.50      |
| === TESTE 3: vw_canonicas_premium === | 3f023e25-513e-459b-81da-05c36d451e22 | BRASCOR    | null          | BRASCOR multifocal CR39 1.56 | multifocal | CR39     | 1             | 252.20       | 252.20       | 252.20      |
| === TESTE 3: vw_canonicas_premium === | fcedc0dc-d745-4604-841f-ccc7c26990e0 | BRASCOR    | null          | BRASCOR multifocal CR39 1.67 | multifocal | CR39     | 1             | 1316.00      | 1316.00      | 1316.00     |



-- 4. TESTE: vw_comparativo_canonicas_genericas
SELECT 
  '=== TESTE 4: vw_comparativo_canonicas_genericas ===' as teste,
  canonica_id,
  nome_canonico,
  marca_nome,
  nome_comercial,
  categoria,
  preco_tabela,
  disponivel
FROM public.vw_comparativo_canonicas_genericas
LIMIT 5;

Success. No rows returned

isso não deveria existir, a comparação será entre laboratorios e não entre canonicas e premium canonicas, ou seja, laboratoriso x, y e z tem a lentes W com r e t, cada laboratorio chama esta lentes por um nome, mas nós no banco já normalizamos, agora para o front, vamos levar a canonica, e em detalhes de coparativos, aparecerá todas as lentes que usamos para esta normalização canonica



-- 5. TESTE: vw_comparativo_canonicas_premium
SELECT 
  '=== TESTE 5: vw_comparativo_canonicas_premium ===' as teste,
  canonica_id,
  nome_canonico,
  marca_nome,
  nome_comercial,
  categoria,
  preco_tabela,
  digital,
  free_form
FROM public.vw_comparativo_canonicas_premium
LIMIT 5;


| teste                                             | canonica_id                          | nome_canonico                | marca_nome | nome_comercial                                                   | categoria     | preco_tabela | digital | free_form |
| ------------------------------------------------- | ------------------------------------ | ---------------------------- | ---------- | ---------------------------------------------------------------- | ------------- | ------------ | ------- | --------- |
| === TESTE 5: vw_comparativo_canonicas_premium === | 8bbceb1d-a0ce-4b17-9e1d-8a7bc06d4392 | BRASCOR multifocal CR39 1.56 | BRASCOR    | MULTIFOCAL ACABADO 1.56 COM AR                                   | economica     | 188.00       | false   | false     |
| === TESTE 5: vw_comparativo_canonicas_premium === | 3f023e25-513e-459b-81da-05c36d451e22 | BRASCOR multifocal CR39 1.56 | BRASCOR    | MULTIFOCAL ACABADO 1.56 BLUE COM AR RESIDUAL AZUL FREE FORM      | economica     | 252.20       | false   | false     |
| === TESTE 5: vw_comparativo_canonicas_premium === | 3f8b3a22-d21a-4b3b-a72c-c398e93e79e3 | BRASCOR multifocal CR39 1.56 | BRASCOR    | MULTIFOCAL ACABADO 1.56 FOTO COM AR                              | economica     | 305.50       | false   | false     |
| === TESTE 5: vw_comparativo_canonicas_premium === | b981fd56-9bf9-4b23-9896-ca52accbd512 | BRASCOR multifocal CR39 1.56 | BRASCOR    | MULTIFOCAL ACABADO 1.56 BLUE FOTO COM AR RESIDUAL AZUL FREE FORM | economica     | 349.20       | false   | false     |
| === TESTE 5: vw_comparativo_canonicas_premium === | fcedc0dc-d745-4604-841f-ccc7c26990e0 | BRASCOR multifocal CR39 1.67 | BRASCOR    | MULTIFOCAL ACABADO 1.67 COM AR VERDE (75MM DI�METRO)             | intermediaria | 1316.00      | false   | false     |


-- 6. TESTE: vw_stats_catalogo - Estatísticas gerais
SELECT 
  '=== TESTE 6: vw_stats_catalogo (ESTATÍSTICAS GERAIS) ===' as teste,
  total_lentes,
  total_marcas,
  total_tipos,
  total_economicas,
  total_intermediarias,
  total_premium,
  total_super_premium,
  total_visao_simples,
  total_multifocal,
  total_bifocal,
  total_disponiveis,
  preco_minimo,
  preco_maximo,
  preco_medio
FROM public.vw_stats_catalogo;

| teste                                                    | total_lentes | total_marcas | total_tipos | total_economicas | total_intermediarias | total_premium | total_super_premium | total_visao_simples | total_multifocal | total_bifocal | total_disponiveis | preco_minimo | preco_maximo | preco_medio |
| -------------------------------------------------------- | ------------ | ------------ | ----------- | ---------------- | -------------------- | ------------- | ------------------- | ------------------- | ---------------- | ------------- | ----------------- | ------------ | ------------ | ----------- |
| === TESTE 6: vw_stats_catalogo (ESTATÍSTICAS GERAIS) === | 1411         | 6            | 3           | 194              | 143                  | 403           | 671                 | 1185                | 224              | 2             | 1411              | 36.00        | 9640.00      | 3563.56     |


-- 7. CONTAGEM: Verificar totais por view
SELECT 
  '=== CONTAGENS POR VIEW ===' as info,
  (SELECT COUNT(*) FROM public.vw_lentes_catalogo) as total_catalogo,
  (SELECT COUNT(*) FROM public.vw_canonicas_genericas) as total_canonicas_genericas,
  (SELECT COUNT(*) FROM public.vw_canonicas_premium) as total_canonicas_premium,
  (SELECT COUNT(*) FROM public.vw_comparativo_canonicas_genericas) as total_comp_genericas,
  (SELECT COUNT(*) FROM public.vw_comparativo_canonicas_premium) as total_comp_premium;


| info                       | total_catalogo | total_canonicas_genericas | total_canonicas_premium | total_comp_genericas | total_comp_premium |
| -------------------------- | -------------- | ------------------------- | ----------------------- | -------------------- | ------------------ |
| === CONTAGENS POR VIEW === | 1411           | 187                       | 250                     | 0                    | 1411               |
