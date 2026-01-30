-- ============================================================================
-- VALIDAÇÃO: Canonização Automática (So Blocos)
-- ============================================================================
-- Objetivo: Verificar se os triggers vincularam as novas lentes aos grupos
-- ============================================================================

-- 1. Resumo de Vinculação
SELECT 
    'Lentes So Blocos Ativas' as metrica,
    COUNT(*) as total,
    COUNT(CASE WHEN grupo_canonico_id IS NOT NULL THEN 1 END) as canonizadas,
    COUNT(CASE WHEN grupo_canonico_id IS NULL THEN 1 END) as orfas
FROM lens_catalog.lentes 
WHERE fornecedor_id = 'e1e1eace-11b4-4f26-9f15-620808a4a410'
  AND ativo = true;

| metrica                 | total | canonizadas | orfas |
| ----------------------- | ----- | ----------- | ----- |
| Lentes So Blocos Ativas | 60    | 60          | 0     |



-- 2. Verificar novos grupos criados hoje
SELECT 
    id,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    total_lentes,
    preco_minimo,
    preco_maximo
FROM lens_catalog.grupos_canonicos
WHERE created_at >= CURRENT_DATE
ORDER BY created_at DESC;


| id                                   | nome_grupo                                                                          | tipo_lente    | material      | indice_refracao | total_lentes | preco_minimo | preco_maximo |
| ------------------------------------ | ----------------------------------------------------------------------------------- | ------------- | ------------- | --------------- | ------------ | ------------ | ------------ |
| 4379ebe3-8ea9-40e1-a602-b29882da77df | Lente CR39 1.50 Visao simples [-4.00/6.00 | 0.00/-2.00]                             | visao_simples | CR39          | 1.50            | 0            | null         | null         |
| 1f381dce-3e46-4cc5-836d-281fea67c334 | Lente CR39 1.50 Visao simples [-4.00/4.00 | -2.25/-4.00]                            | visao_simples | CR39          | 1.50            | 0            | null         | null         |
| 20e512a1-b1d7-464d-b8ef-ff9056dec0fc | Lente CR39 1.56 Visao simples +AR +BlueLight [-4.00/4.00 | 0.00/-2.00]              | visao_simples | CR39          | 1.56            | 0            | null         | null         |
| 576b329c-18bf-43c9-b9b0-47f8d863b5b2 | Lente CR39 1.56 Visao simples +AR +BlueLight [-4.00/4.00 | -2.25/-4.00]             | visao_simples | CR39          | 1.56            | 0            | null         | null         |
| db73c324-79b5-449e-8118-496fa7f470f5 | Lente CR39 1.50 Visao simples +AR [-4.00/4.00 | 0.00/-2.00]                         | visao_simples | CR39          | 1.50            | 0            | null         | null         |
| 15c52b63-a80f-45a7-8884-2e9a0e5e94ea | Lente CR39 1.61 Visao simples +AR +UV [-10.00/4.00 | 0.00/-2.00]                    | visao_simples | CR39          | 1.61            | 0            | null         | null         |
| 622d688a-0b84-40dd-8363-fcacc5cbc19e | Lente CR39 1.61 Visao simples +AR +UV [0.00/-5.00 | -4.00/-5.25]                    | visao_simples | CR39          | 1.61            | 0            | null         | null         |
| ae5b430c-aae0-4bac-bec2-40485cfcb5e3 | Lente CR39 1.61 Visao simples +AR +UV [-12.50/-15.00 | 0.00/0.00]                   | visao_simples | CR39          | 1.61            | 0            | null         | null         |
| bce3d0ab-9ecf-4317-b094-a46747b1e332 | Lente CR39 1.56 Visao simples +AR +Fotocromático [-6.00/4.00 | 0.00/-2.00]          | visao_simples | CR39          | 1.56            | 0            | null         | null         |
| e46d2382-83b5-445d-aae5-dfeed292b93a | Lente CR39 1.56 Visao simples +AR +Fotocromático [-4.00/4.00 | -2.25/-4.00]         | visao_simples | CR39          | 1.56            | 0            | null         | null         |
| 09c9a5c2-ddfb-4efb-a4d1-c32698a1a929 | Lente CR39 1.50 Visao simples +AR +Fotocromático [-2.00/2.00 | 0.00/-2.00]          | visao_simples | CR39          | 1.50            | 0            | null         | null         |
| 608b3f31-cefd-4b5c-9300-aa3cc19f2146 | Lente CR39 1.50 Visao simples +AR +Fotocromático [2.25/4.00 | 0.00/0.00]            | visao_simples | CR39          | 1.50            | 1            | 780.00       | 780.00       |
| bbdf7c1d-1f22-424e-bd9d-720cb6225bbc | Lente CR39 1.56 Visao simples +AR [-4.00/4.00 | -4.25/-6.00]                        | visao_simples | CR39          | 1.56            | 0            | null         | null         |
| 2abdf697-15d2-4352-8cf6-160d53ebb775 | Lente CR39 1.56 Visao simples +AR +BlueLight [-4.00/4.00 | -4.25/-6.00]             | visao_simples | CR39          | 1.56            | 0            | null         | null         |
| 49a7a4be-7f59-4122-b3bc-e4a55191c869 | Lente CR39 1.56 Visao simples +AR [-8.00/4.00 | 0.00/-2.00]                         | visao_simples | CR39          | 1.56            | 2            | 265.60       | 292.00       |
| ef23e8b9-3c86-4f9d-a54a-52ab21306f50 | Lente CR39 1.56 Visao simples +AR [-6.00/4.00 | 0.00/-2.00]                         | visao_simples | CR39          | 1.56            | 0            | null         | null         |
| e5bbb1ca-4f75-42bb-b75b-91d8bf9510d6 | Lente CR39 1.56 Visao simples +AR [-6.00/4.00 | -2.25/-4.00]                        | visao_simples | CR39          | 1.56            | 3            | 294.00       | 312.00       |
| f9194af7-6d09-47a8-8d42-44f01a5a40aa | Lente POLICARBONATO 1.59 Visao simples +AR +UV +BlueLight [-6.00/4.00 | 0.00/-2.00] | visao_simples | POLICARBONATO | 1.59            | 0            | null         | null         |
| 8088479d-4f7d-49d5-b034-2df52957bab5 | Lente POLICARBONATO 1.59 Visao simples +AR +UV [-6.00/6.00 | 0.00/-2.00]            | visao_simples | POLICARBONATO | 1.59            | 0            | null         | null         |
| ab9cd2db-6993-42c9-b4d3-ee517c59cf1f | Lente CR39 1.61 Visao simples +AR +UV +BlueLight [6.00/-10.00 | 0.00/-2.00]         | visao_simples | CR39          | 1.61            | 0            | null         | null         |
| 0316b5c7-ff68-43ce-bb20-66f84c89935b | Lente CR39 1.61 Visao simples +AR +UV +BlueLight [0.00/-8.00 | -2.25/-4.00]         | visao_simples | CR39          | 1.61            | 0            | null         | null         |
| 0846c43c-e441-4647-9da0-edda911b3be6 | Lente CR39 1.67 Visao simples +AR +UV [6.00/-12.00 | 0.00/-2.00]                    | visao_simples | CR39          | 1.67            | 1            | 392.00       | 392.00       |
| a9f554f3-deb0-4078-948e-e36f5b83f3ec | Lente CR39 1.67 Visao simples +AR +UV [-12.50/-15.00 | 0.00/0.00]                   | visao_simples | CR39          | 1.67            | 1            | 392.00       | 392.00       |
| d3c376d0-3426-4d6e-80d1-7ef026930a28 | Lente CR39 1.67 Visao simples +AR +UV [0.00/-8.00 | -2.25/-4.00]                    | visao_simples | CR39          | 1.67            | 1            | 392.00       | 392.00       |
| bc59f784-0816-4fca-b687-c9d34b7ecb8a | Lente CR39 1.74 Visao simples +AR +UV +BlueLight [-3.00/-18.00 | 0.00/-2.00]        | visao_simples | CR39          | 1.74            | 0            | null         | null         |
| 351f4c87-e89f-4ec6-a207-f67a1f3c7fab | Lente CR39 1.74 Visao simples +AR +UV +BlueLight [-18.50/-24.00 | 0.00/0.00]        | visao_simples | CR39          | 1.74            | 0            | null         | null         |
| e585dd8a-9fb8-40c0-96cc-be385307fdd5 | Lente CR39 1.74 Visao simples +AR +UV [-2.00/-12.00 | 0.00/-2.00]                   | visao_simples | CR39          | 1.74            | 1            | 1472.00      | 1472.00      |
| da9a532e-c67f-4a76-aebb-726a7c65825b | Lente CR39 1.74 Visao simples +AR +UV [-12.50/-15.00 | 0.00/0.00]                   | visao_simples | CR39          | 1.74            | 1            | 1472.00      | 1472.00      |
| 2e309f27-ac9c-4481-a8dc-d4e647b8a1ee | Lente CR39 1.74 Visao simples +AR +UV [-2.00/-8.00 | -2.25/-4.00]                   | visao_simples | CR39          | 1.74            | 1            | 1472.00      | 1472.00      |
| ebace7a9-3598-44a4-a23c-8e0101e4eb52 | Lente CR39 1.56 Visao simples +AR +Fotocromático [-4.00/3.00 | 0.00/-2.00]          | visao_simples | CR39          | 1.56            | 0            | null         | null         |
| 156ecad3-725c-48d4-a67b-cf22d1fa3028 | Lente CR39 1.56 Visao simples +AR +Fotocromático [-4.00/3.00 | -2.25/-4.00]         | visao_simples | CR39          | 1.56            | 0            | null         | null         |
| 69e4c493-17f0-4b29-966b-e739e7d9eeb2 | Lente CR39 1.56 Multifocal +AR [0.00/3.00 | 0.00/0.00]                              | multifocal    | CR39          | 1.56            | 0            | null         | null         |
| 11abae89-9808-42f2-b141-af3b648213bb | Lente CR39 1.56 Multifocal +AR +BlueLight [-1.00/3.00 | 0.00/0.00]                  | multifocal    | CR39          | 1.56            | 0            | null         | null         |
| b2e206de-dafb-40c9-8cef-67c177758ba5 | Lente CR39 1.56 Multifocal +AR +BlueLight +Fotocromático [-1.00/3.00 | 0.00/0.00]   | multifocal    | CR39          | 1.56            | 0            | null         | null         |
| 596ba805-7e2a-458b-b41c-f3c357a38c05 | Lente CR39 1.56 Multifocal +AR +Fotocromático [0.00/3.00 | 0.00/0.00]               | multifocal    | CR39          | 1.56            | 0            | null         | null         |


-- 3. Amostra de lentes e seus respectivos grupos
SELECT 
    l.nome_lente,
    l.tipo_lente,
    l.material,
    l.indice_refracao,
    g.nome_grupo as grupo_vinculado
FROM lens_catalog.lentes l
JOIN lens_catalog.grupos_canonicos g ON l.grupo_canonico_id = g.id
WHERE l.fornecedor_id = 'e1e1eace-11b4-4f26-9f15-620808a4a410'
LIMIT 10;

| nome_lente                                                           | tipo_lente    | material | indice_refracao | grupo_vinculado                                                             |
| -------------------------------------------------------------------- | ------------- | -------- | --------------- | --------------------------------------------------------------------------- |
| Lente Ac. 1.61 Blue AR Azul Estendido                                | visao_simples | CR39     | 1.61            | Lente CR39 1.61 Visao simples +AR +UV +BlueLight [0.00/-8.00 | -2.25/-4.00] |
| Lente Ac. 1.67 com AR Super Hidrofóbico                              | visao_simples | CR39     | 1.67            | Lente CR39 1.67 Visao simples +AR +UV [6.00/-12.00 | 0.00/-2.00]            |
| Lente Ac. 1.67 com AR Super Hidro                                    | visao_simples | CR39     | 1.67            | Lente CR39 1.67 Visao simples +AR +UV [6.00/-12.00 | 0.00/-2.00]            |
| Lente Ac. 1.50 Transitions Gen.8 com AR                              | visao_simples | CR39     | 1.50            | Lente CR39 1.50 Visao simples +AR +Fotocromático [-2.00/2.00 | 0.00/-2.00]  |
| Multifocal Acabado 1.56 Blue com AR Residual Azul FREE FORM          | multifocal    | CR39     | 1.56            | Lente CR39 1.56 Multifocal +AR +BlueLight [-1.00/3.00 | 0.00/0.00]          |
| Lente Ac. 1.56 Fotossensível com AR Verde Super Hidro Cil. Estendido | visao_simples | CR39     | 1.56            | Lente CR39 1.56 Visao simples +AR +Fotocromático [-4.00/3.00 | -2.25/-4.00] |
| Lente Ac. 1.61 com AR Super Hidrofóbico                              | visao_simples | CR39     | 1.61            | Lente CR39 1.61 Visao simples +AR +UV [-10.00/4.00 | 0.00/-2.00]            |
| Lente Ac. 1.49 Incolor Cil. Estendido                                | visao_simples | CR39     | 1.50            | Lente CR39 1.50 Visao simples [-4.00/4.00 | -2.25/-4.00]                    |
| Lente Ac. 1.56 Blue Verniz Tintável                                  | visao_simples | CR39     | 1.56            | Lente CR39 1.56 Visao simples +AR +BlueLight [-4.00/4.00 | 0.00/-2.00]      |
| Lente Ac. 1.56 Blue AR Verde                                         | visao_simples | CR39     | 1.56            | Lente CR39 1.56 Visao simples +AR +BlueLight [-4.00/4.00 | -4.25/-6.00]     |



-- 4. Verificar se existem grupos inconsistentes (total_lentes = 0 mas ativos)
SELECT COUNT(*) as grupos_vazios_ativos
FROM lens_catalog.grupos_canonicos 
WHERE total_lentes = 0 AND ativo = true;


| grupos_vazios_ativos |
| -------------------- |
| 0                    |
