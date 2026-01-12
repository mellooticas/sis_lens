-- ============================================================================
-- INVESTIGAÇÃO: Campos Retornados pela View
-- Data: 2026-01-11
-- Objetivo: Ver exatamente quais campos a view v_grupos_canonicos retorna
-- ============================================================================

-- Query 1: Listar TODOS os campos da view
SELECT 
    column_name,
    data_type,
    ordinal_position
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'v_grupos_canonicos'
ORDER BY ordinal_position;

| column_name               | data_type    | ordinal_position |
| ------------------------- | ------------ | ---------------- |
| id                        | uuid         | 1                |
| slug                      | text         | 2                |
| nome_grupo                | text         | 3                |
| tipo_lente                | USER-DEFINED | 4                |
| material                  | USER-DEFINED | 5                |
| indice_refracao           | USER-DEFINED | 6                |
| categoria_predominante    | USER-DEFINED | 7                |
| grau_esferico_min         | numeric      | 8                |
| grau_esferico_max         | numeric      | 9                |
| grau_cilindrico_min       | numeric      | 10               |
| grau_cilindrico_max       | numeric      | 11               |
| adicao_min                | numeric      | 12               |
| adicao_max                | numeric      | 13               |
| descricao_ranges          | text         | 14               |
| tratamento_antirreflexo   | boolean      | 15               |
| tratamento_antirrisco     | boolean      | 16               |
| tratamento_uv             | boolean      | 17               |
| tratamento_blue_light     | boolean      | 18               |
| tratamento_fotossensiveis | text         | 19               |
| preco_minimo              | numeric      | 20               |
| preco_maximo              | numeric      | 21               |
| preco_medio               | numeric      | 22               |
| total_lentes              | integer      | 23               |
| total_marcas              | integer      | 24               |
| peso                      | integer      | 25               |
| is_premium                | boolean      | 26               |



-- Query 2: Ver dados completos de 1 grupo (ver nomes exatos dos campos)
SELECT *
FROM public.v_grupos_canonicos
LIMIT 1;

| id                                   | slug                                                                    | nome_grupo                                                  | tipo_lente    | material | indice_refracao | categoria_predominante | grau_esferico_min | grau_esferico_max | grau_cilindrico_min | grau_cilindrico_max | adicao_min | adicao_max | descricao_ranges                                                        | tratamento_antirreflexo | tratamento_antirrisco | tratamento_uv | tratamento_blue_light | tratamento_fotossensiveis | preco_minimo | preco_maximo | preco_medio | total_lentes | total_marcas | peso | is_premium |
| ------------------------------------ | ----------------------------------------------------------------------- | ----------------------------------------------------------- | ------------- | -------- | --------------- | ---------------------- | ----------------- | ----------------- | ------------------- | ------------------- | ---------- | ---------- | ----------------------------------------------------------------------- | ----------------------- | --------------------- | ------------- | --------------------- | ------------------------- | ------------ | ------------ | ----------- | ------------ | ------------ | ---- | ---------- |
| 30d581c1-4b46-41a8-b4a5-6653c862ec7a | lente-39-150-visao-simples-uv-esf-n6-00-6-00-cil-0-00-n2-00-add-000-000 | Lente CR39 1.50 Visao Simples +UV [-6.00/6.00 | 0.00/-2.00] | visao_simples | CR39     | 1.50            | null                   | -6.00             | 6.00              | 0.00                | -2.00               | 0.00       | 0.00       | Esférico: -6.00 a 6.00 | Cilíndrico: 0.00 a -2.00 | Adição: 0.00 a 0.00 | false                   | false                 | true          | false                 | nenhum                    | 250.00       | 250.00       | 250.00      | 1            | 1            | 50   | false      |


-- Query 3: Testar se campos tratamento_* existem na view
SELECT 
    tratamento_antirreflexo,
    tratamento_antirrisco,
    tratamento_uv,
    tratamento_blue_light,
    tratamento_fotossensiveis
FROM public.v_grupos_canonicos
LIMIT 1;


| tratamento_antirreflexo | tratamento_antirrisco | tratamento_uv | tratamento_blue_light | tratamento_fotossensiveis |
| ----------------------- | --------------------- | ------------- | --------------------- | ------------------------- |
| false                   | false                 | true          | false                 | nenhum                    |

-- Se a Query 3 der erro, teste com tem_*:
-- SELECT 
--     tem_antirreflexo,
--     tem_antirrisco,
--     tem_uv,
--     tem_blue_light,
--     tratamento_foto
-- FROM public.v_grupos_canonicos
-- LIMIT 1;
