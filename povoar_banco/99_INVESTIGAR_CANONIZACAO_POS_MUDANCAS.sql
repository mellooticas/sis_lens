-- ============================================================================
-- INVESTIGAÇÃO: Canonização após Mudanças nos Graus
-- ============================================================================
-- Data: 22/01/2026
-- Objetivo: Verificar se os grupos canônicos estão corretos após as mudanças
--          nos ranges de graus (novos GAPs adicionados)
-- ============================================================================

-- ============================================================================
-- 1. VERIFICAR TRIGGERS ATIVOS
-- ============================================================================

SELECT
  trigger_name,
  event_object_table as tabela,
  event_manipulation as evento,
  action_statement as funcao
FROM information_schema.triggers
WHERE trigger_schema = 'lens_catalog'
  AND event_object_table = 'lentes'
  AND action_statement LIKE '%grupo%'
ORDER BY trigger_name;


| trigger_name                      | tabela | evento | funcao                                                                |
| --------------------------------- | ------ | ------ | --------------------------------------------------------------------- |
| trg_lente_delete                  | lentes | DELETE | EXECUTE FUNCTION lens_catalog.trigger_deletar_lente_atualizar_grupo() |
| trg_lente_insert_update           | lentes | UPDATE | EXECUTE FUNCTION lens_catalog.trigger_atualizar_grupo_canonico()      |
| trg_lente_insert_update           | lentes | INSERT | EXECUTE FUNCTION lens_catalog.trigger_atualizar_grupo_canonico()      |
| trg_lentes_associar_grupo         | lentes | UPDATE | EXECUTE FUNCTION lens_catalog.fn_associar_lente_grupo_automatico()    |
| trg_lentes_associar_grupo         | lentes | INSERT | EXECUTE FUNCTION lens_catalog.fn_associar_lente_grupo_automatico()    |
| trg_lentes_atualizar_estatisticas | lentes | INSERT | EXECUTE FUNCTION lens_catalog.fn_atualizar_estatisticas_grupo()       |
| trg_lentes_atualizar_estatisticas | lentes | DELETE | EXECUTE FUNCTION lens_catalog.fn_atualizar_estatisticas_grupo()       |
| trg_lentes_atualizar_estatisticas | lentes | UPDATE | EXECUTE FUNCTION lens_catalog.fn_atualizar_estatisticas_grupo()       |


-- Esperado:
-- - trg_lentes_associar_grupo (INSERT/UPDATE) -> fn_associar_lente_grupo_automatico()
-- - trg_lentes_atualizar_estatisticas (INSERT/UPDATE/DELETE) -> fn_atualizar_estatisticas_grupo()


-- ============================================================================
-- 2. VERIFICAR LENTES SEM GRUPO CANÔNICO
-- ============================================================================

SELECT
  COUNT(*) as total_lentes_orfas,
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true) as percentual
FROM lens_catalog.lentes
WHERE ativo = true
  AND grupo_canonico_id IS NULL;


| total_lentes_orfas | percentual             |
| ------------------ | ---------------------- |
| 0                  | 0.00000000000000000000 |

-- Esperado: 0 lentes órfãs


-- ============================================================================
-- 3. VERIFICAR DISTRIBUIÇÃO DE LENTES POR GRUPO
-- ============================================================================

SELECT
  gc.nome_grupo,
  gc.total_lentes as total_registrado,
  COUNT(l.id) as total_real,
  gc.preco_minimo,
  gc.preco_maximo,
  gc.preco_medio,
  gc.updated_at as ultima_atualizacao
FROM lens_catalog.grupos_canonicos gc
LEFT JOIN lens_catalog.lentes l ON l.grupo_canonico_id = gc.id AND l.ativo = true
WHERE gc.ativo = true
GROUP BY gc.id, gc.nome_grupo, gc.total_lentes, gc.preco_minimo, gc.preco_maximo, gc.preco_medio, gc.updated_at
ORDER BY total_real DESC;


| nome_grupo                                                                                        | total_registrado | total_real | preco_minimo | preco_maximo | preco_medio | ultima_atualizacao            |
| ------------------------------------------------------------------------------------------------- | ---------------- | ---------- | ------------ | ------------ | ----------- | ----------------------------- |
| Lente CR39 1.50 Multifocal +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                              | 36               | 36         | 1622.72      | 3539.04      | 2620.31     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]               | 36               | 36         | 4086.56      | 5377.15      | 4750.11     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]         | 30               | 30         | 2209.35      | 4086.56      | 3218.35     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                             | 24               | 24         | 4360.32      | 7137.04      | 5437.77     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                          | 24               | 24         | 1857.37      | 2975.88      | 2424.77     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]           | 24               | 24         | 4321.22      | 4813.99      | 4554.57     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]     | 20               | 20         | 2444.00      | 3523.40      | 3022.81     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +AR +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                         | 16               | 16         | 4594.98      | 6573.88      | 5242.23     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]     | 15               | 15         | 4673.19      | 5983.34      | 5377.15     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +UV [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]                    | 15               | 15         | 2209.35      | 3460.82      | 2874.19     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.56 Multifocal +UV +BlueLight [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                   | 15               | 15         | 1896.48      | 3460.82      | 2795.98     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Visao Simples +UV +fotocromático [-8.00/6.50 | -6.00/0.00]                        | 12               | 12         | 4164.78      | 5142.50      | 4684.93     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +UV +BlueLight [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                  | 12               | 12         | 4360.32      | 6785.06      | 5388.88     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +UV [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]                            | 12               | 12         | 5064.28      | 9444.46      | 7314.99     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Visao Simples +UV +BlueLight [-10.00/8.00 | -6.00/0.00]                  | 12               | 12         | 2287.56      | 4125.67      | 3237.90     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +UV [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]                             | 12               | 12         | 4203.89      | 6002.89      | 5134.68     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +UV [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]                            | 12               | 12         | 5259.83      | 9366.24      | 7275.88     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.56 Multifocal +AR +UV +BlueLight [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]               | 10               | 10         | 2131.13      | 2897.66      | 2600.43     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV +fotocromático [-10.00/8.00 | -6.00/0.00 | 0.50/4.50] | 10               | 10         | 4907.85      | 5420.17      | 5181.61     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]                | 10               | 10         | 2444.00      | 2897.66      | 2678.65     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +UV [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]                              | 9                | 9          | 996.98       | 2795.98      | 1784.37     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Visao Simples +UV [-8.00/6.50 | -6.00/0.00]                                       | 9                | 9          | 1857.37      | 3304.39      | 2683.87     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Visao Simples +UV [-13.00/9.00 | -6.00/0.00]                                      | 9                | 9          | 4399.43      | 5455.37      | 4965.21     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Visao Simples +UV [-14.00/10.00 | -8.00/0.00]                                     | 9                | 9          | 5338.04      | 9014.26      | 7650.67     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +AR +UV [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]                        | 8                | 8          | 5494.48      | 8803.07      | 7080.34     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Visao Simples +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00]                    | 8                | 8          | 4399.43      | 4579.33      | 4489.38     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +AR +UV [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]                        | 8                | 8          | 5298.93      | 8881.29      | 7119.45     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +AR +UV +BlueLight [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]              | 8                | 8          | 4594.98      | 6221.90      | 5193.34     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +AR +UV [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]                         | 8                | 8          | 4438.54      | 5439.73      | 4939.13     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Visao Simples +AR +UV +BlueLight [-10.00/8.00 | -6.00/0.00]              | 8                | 8          | 2522.22      | 3562.51      | 3042.36     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +UV +fotocromático [-6.00/6.00 | -4.00/0.00 | 1.00/3.50]               | 7                | 7          | 914.85       | 5807.35      | 2638.42     | 2026-01-22 00:05:42.306256+00 |
| Lente POLICARBONATO 1.59 Visao Simples +UV +fotocromático [-10.00/8.00 | -6.00/0.00]              | 6                | 6          | 4770.97      | 5748.68      | 5291.11     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +UV +polarizado [-8.00/7.00 | -6.00/0.00 | 0.50/4.50]         | 6                | 6          | 2756.87      | 3695.48      | 3257.46     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +UV +polarizado [-8.00/6.00 | -6.00/0.00 | 0.50/4.50]                  | 6                | 6          | 2659.10      | 3597.71      | 3159.69     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Visao Simples +UV +fotocromático [-14.00/10.00 | -8.00/0.00]                      | 6                | 6          | 8466.74      | 9444.46      | 8986.89     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Visao Simples +AR +UV [-14.00/10.00 | -8.00/0.00]                                 | 6                | 6          | 5572.69      | 8451.10      | 7455.13     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-8.00/6.00 | -4.00/0.00 | 1.00/3.50]      | 6                | 6          | 1255.09      | 2537.86      | 1888.66     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Visao Simples +UV [-8.00/6.00 | -4.00/0.00 | 0.50/1.25]                           | 6                | 6          | 1974.69      | 3421.72      | 2729.49     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]          | 6                | 6          | 1176.88      | 3069.74      | 2154.60     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +UV [-13.00/8.00 | -5.00/0.00 | 0.75/3.50]                             | 6                | 6          | 3187.06      | 4986.06      | 4252.12     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +UV [-6.00/6.00 | -6.00/0.00 | 0.50/4.50]                              | 6                | 6          | 2913.30      | 4555.87      | 3765.87     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +UV +polarizado [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                  | 6                | 6          | 2600.43      | 3539.04      | 3101.02     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Visao Simples +UV [-9.50/7.50 | -4.00/0.00 | 0.50/1.25]                           | 6                | 6          | 4438.54      | 5846.46      | 5173.79     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +UV +polarizado [-9.00/7.00 | -6.00/0.00 | 0.50/4.50]         | 6                | 6          | 2835.09      | 3773.69      | 3335.68     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +AR +UV [-13.00/8.00 | -4.00/0.00 | 1.00/3.50]                         | 6                | 6          | 3187.06      | 3844.09      | 3507.76     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +UV [-12.00/10.00 | -6.00/0.00]                                        | 6                | 6          | 4399.43      | 5846.46      | 5154.23     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Visao Simples +UV +BlueLight [-14.00/10.00 | -8.00/0.00]                          | 6                | 6          | 5298.93      | 6276.65      | 5819.08     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Visao Simples +UV +BlueLight [-13.00/9.00 | -6.00/0.00]                           | 6                | 6          | 4360.32      | 5338.04      | 4880.47     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +UV +fotocromático [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]              | 6                | 6          | 6824.17      | 8036.54      | 7461.64     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Visao Simples +UV +fotocromático [-13.00/9.00 | -6.00/0.00]                       | 6                | 6          | 6824.17      | 7801.89      | 7344.32     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +UV [-13.00/11.00 | -6.00/0.00]                                        | 6                | 6          | 5338.04      | 9288.02      | 7344.32     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.56 Multifocal +UV +BlueLight [-8.00/6.50 | -6.00/0.00]                               | 6                | 6          | 2287.56      | 3265.28      | 2807.71     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +UV [-14.00/10.00 | -6.00/0.00 | 0.50/4.50]                            | 6                | 6          | 5690.02      | 9600.89      | 7676.74     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Visao Simples +UV +BlueLight [-8.00/7.00 | -4.00/0.00 | 0.50/1.25]       | 6                | 6          | 2287.56      | 4203.89      | 3277.01     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +UV [-13.00/8.00 | -5.00/0.00 | 0.75/3.50]                             | 6                | 6          | 4438.54      | 6472.19      | 5301.54     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +UV [-7.00/7.00 | -6.00/0.00 | 0.50/4.50]                     | 6                | 6          | 3421.72      | 5064.28      | 4274.29     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +UV +BlueLight [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]                 | 6                | 6          | 5259.83      | 6315.76      | 5819.08     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +UV +fotocromático [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]             | 6                | 6          | 8466.74      | 9640.00      | 9084.66     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +UV +BlueLight [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]                  | 6                | 6          | 4203.89      | 5729.13      | 4997.80     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -4.00/0.00 | 1.00/3.50]                          | 6                | 6          | 996.98       | 1896.48      | 1438.91     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +UV +BlueLight [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]                 | 6                | 6          | 5064.28      | 6589.52      | 5858.19     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Visao Simples +AR +UV [-13.00/9.00 | -6.00/0.00]                                  | 6                | 6          | 4634.09      | 4892.20      | 4769.66     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]          | 6                | 6          | 1935.59      | 3734.59      | 2866.37     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +UV [-13.00/8.00 | -6.00/0.00 | 0.50/4.50]                             | 6                | 6          | 3891.02      | 5220.72      | 4587.16     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-10.00/7.00 | -6.00/0.00]                     | 6                | 6          | 2444.00      | 4203.89      | 3355.23     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Visao Simples +AR +UV [-8.00/6.50 | -6.00/0.00]                                   | 6                | 6          | 2092.02      | 2741.22      | 2488.32     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +UV [-8.00/6.50 | -6.00/0.00]                                          | 6                | 6          | 1974.69      | 3421.72      | 2729.49     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]               | 6                | 6          | 2874.19      | 3812.80      | 3374.78     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                             | 6                | 6          | 5220.72      | 9053.37      | 7168.33     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.56 Visao Simples +UV +BlueLight [-8.00/6.50 | -6.00/0.00]                            | 6                | 6          | 2287.56      | 3265.28      | 2807.71     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]                          | 6                | 6          | 1231.63      | 2232.81      | 1588.82     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +UV +polarizado [-8.00/7.00 | -5.00/0.00 | 0.75/3.50]         | 6                | 6          | 2404.89      | 3343.50      | 2905.48     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +UV +polarizado [-7.00/6.00 | -5.00/0.00 | 0.75/3.50]                  | 6                | 6          | 2170.24      | 3108.85      | 2670.83     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.56 Multifocal +UV +fotocromático [-5.00/6.00 | 0.00/-4.00 | 1.00/3.00]               | 5                | 5          | 527.67       | 996.98       | 695.84      | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +AR +UV [-13.00/8.00 | -5.00/0.00 | 0.75/3.50]                         | 4                | 4          | 4008.35      | 4282.11      | 4136.43     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Visao Simples +AR +UV +fotocromático [-13.00/9.00 | -6.00/0.00]                   | 4                | 4          | 7058.83      | 7238.73      | 7148.78     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-10.00/7.00 | -6.00/0.00]                 | 4                | 4          | 2678.65      | 3640.72      | 3159.69     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV +polarizado [-8.00/7.00 | -5.00/0.00 | 0.75/3.50]     | 4                | 4          | 2639.54      | 2780.33      | 2709.94     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Visao Simples +AR +UV [-9.50/7.50 | -4.00/0.00 | 0.50/1.25]                       | 4                | 4          | 4673.19      | 5283.29      | 4978.24     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Visao Simples +AR +UV +BlueLight [-13.00/9.00 | -6.00/0.00]                       | 4                | 4          | 4594.98      | 4774.88      | 4684.93     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-8.00/6.00 | -5.00/0.00 | 0.75/3.50]           | 4                | 4          | 3108.85      | 3249.64      | 3179.25     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +AR +UV [-13.00/8.00 | -6.00/0.00 | 0.50/4.50]                         | 4                | 4          | 4125.67      | 4657.55      | 4391.61     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +AR +UV [-12.00/10.00 | -6.00/0.00]                                    | 4                | 4          | 4634.09      | 5283.29      | 4958.69     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +AR +UV +polarizado [-7.00/6.00 | -5.00/0.00 | 0.75/3.50]              | 4                | 4          | 2404.89      | 2545.68      | 2475.29     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +AR +UV +polarizado [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]              | 4                | 4          | 2835.09      | 2975.88      | 2905.49     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.56 Visao Simples +AR +UV +BlueLight [-6.00/6.00 | -2.25/-4.00]                       | 4                | 4          | 281.29       | 304.75       | 293.02      | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.67 Multifocal +AR +UV +fotocromático [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]          | 4                | 4          | 7058.83      | 7473.38      | 7266.11     | 2025-12-27 20:19:15.91958+00  |
| Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-8.00/8.00 | 0.00/-4.00 | 1.00/3.00]      | 4                | 4          | 1231.63      | 2444.00      | 1808.48     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +AR +UV +polarizado [-8.00/6.00 | -6.00/0.00 | 0.50/4.50]              | 4                | 4          | 2893.75      | 3034.54      | 2964.15     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Visao Simples +AR +UV [-8.00/6.00 | -4.00/0.00 | 0.50/1.25]                       | 4                | 4          | 2209.35      | 2858.55      | 2533.95     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +AR +UV [-13.00/8.00 | -5.00/0.00 | 0.75/3.50]                         | 4                | 4          | 4673.19      | 5768.24      | 5211.92     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.56 Multifocal +AR +UV +BlueLight [-8.00/6.50 | -6.00/0.00]                           | 4                | 4          | 2522.22      | 2702.12      | 2612.17     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +UV [-5.00/6.00 | 0.00/-4.00 | 1.00/3.00]                              | 4                | 4          | 605.89       | 918.76       | 752.55      | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.50 Multifocal +AR +UV [-6.00/6.00 | -6.00/0.00 | 0.50/4.50]                          | 4                | 4          | 3147.96      | 3992.70      | 3570.33     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +AR +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                         | 4                | 4          | 5455.37      | 8490.20      | 6972.79     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Visao Simples +AR +UV +BlueLight [-14.00/10.00 | -8.00/0.00]                      | 4                | 4          | 5533.59      | 5713.49      | 5623.54     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +AR +UV [-14.00/10.00 | -6.00/0.00 | 0.50/4.50]                        | 4                | 4          | 5924.67      | 9037.73      | 7481.20     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.74 Multifocal +AR +UV +BlueLight [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]             | 4                | 4          | 5298.93      | 6026.36      | 5662.65     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.56 Visao Simples +AR +UV +BlueLight [-8.00/6.50 | -6.00/0.00]                        | 4                | 4          | 2522.22      | 2702.12      | 2612.17     | 2025-12-27 20:19:15.91958+00  |
| Lente CR39 1.56 Visao Simples +AR +UV +BlueLight +fotocromático [-6.00/6.00 | -2.25/-4.00]        | 4                | 4          | 392.75       | 459.23       | 426.48      | 2025-12-27 20:19:15.91958+00  |


-- Objetivo: Ver se total_registrado = total_real


-- ============================================================================
-- 4. VERIFICAR GRUPOS COM ESTATÍSTICAS DESATUALIZADAS
-- ============================================================================

WITH grupos_reais AS (
  SELECT
    grupo_canonico_id,
    COUNT(*) as total_lentes_real,
    COUNT(DISTINCT marca_id) as total_marcas_real,
    MIN(preco_venda_sugerido) as preco_min_real,
    MAX(preco_venda_sugerido) as preco_max_real,
    ROUND(AVG(preco_venda_sugerido)::NUMERIC, 2) as preco_medio_real
  FROM lens_catalog.lentes
  WHERE ativo = true
    AND grupo_canonico_id IS NOT NULL
  GROUP BY grupo_canonico_id
)
SELECT
  gc.id,
  gc.nome_grupo,
  gc.total_lentes as total_lentes_registrado,
  gr.total_lentes_real,
  gc.total_marcas as total_marcas_registrado,
  gr.total_marcas_real,
  gc.preco_minimo as preco_min_registrado,
  gr.preco_min_real,
  gc.preco_medio as preco_medio_registrado,
  gr.preco_medio_real,
  gc.updated_at as ultima_atualizacao
FROM lens_catalog.grupos_canonicos gc
JOIN grupos_reais gr ON gr.grupo_canonico_id = gc.id
WHERE 
  gc.total_lentes != gr.total_lentes_real
  OR gc.total_marcas != gr.total_marcas_real
  OR ABS(gc.preco_minimo - gr.preco_min_real) > 0.01
  OR ABS(gc.preco_medio - gr.preco_medio_real) > 0.01;

-- Esperado: 0 linhas (tudo sincronizado)

Success. No rows returned



-- ============================================================================
-- 5. VERIFICAR NOVOS RANGES DE GRAUS NOS GRUPOS
-- ============================================================================

SELECT
  tipo_lente,
  material,
  indice_refracao,
  COUNT(*) as total_grupos,
  COUNT(DISTINCT CONCAT(grau_esferico_min, '/', grau_esferico_max)) as ranges_esferico_unicos,
  COUNT(DISTINCT CONCAT(grau_cilindrico_min, '/', grau_cilindrico_max)) as ranges_cilindrico_unicos,
  MIN(grau_esferico_min) as esf_min,
  MAX(grau_esferico_max) as esf_max,
  MIN(grau_cilindrico_min) as cil_min,
  MAX(grau_cilindrico_max) as cil_max
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
GROUP BY tipo_lente, material, indice_refracao
ORDER BY tipo_lente, material, indice_refracao;

-- Objetivo: Ver se existem múltiplos grupos para mesmas características
-- (pode indicar que precisamos re-canonizar)

| tipo_lente    | material      | indice_refracao | total_grupos | ranges_esferico_unicos | ranges_cilindrico_unicos | esf_min | esf_max | cil_min | cil_max |
| ------------- | ------------- | --------------- | ------------ | ---------------------- | ------------------------ | ------- | ------- | ------- | ------- |
| visao_simples | CR39          | 1.50            | 34           | 16                     | 10                       | -24.00  | 12.00   | -6.00   | 2.00    |
| visao_simples | CR39          | 1.56            | 60           | 9                      | 12                       | -8.00   | 8.00    | -6.00   | 0.00    |
| visao_simples | CR39          | 1.61            | 20           | 10                     | 6                        | -10.00  | 6.00    | -4.00   | 0.00    |
| visao_simples | CR39          | 1.67            | 35           | 10                     | 10                       | -15.00  | 9.00    | -6.00   | 4.00    |
| visao_simples | CR39          | 1.74            | 31           | 10                     | 11                       | -15.00  | 10.00   | -8.00   | 4.00    |
| visao_simples | POLICARBONATO | 1.59            | 52           | 11                     | 7                        | -10.00  | 8.00    | -6.00   | 0.00    |
| multifocal    | CR39          | 1.50            | 41           | 11                     | 6                        | -8.00   | 8.00    | -6.00   | 0.00    |
| multifocal    | CR39          | 1.56            | 38           | 9                      | 5                        | -8.00   | 6.50    | -6.00   | 0.00    |
| multifocal    | CR39          | 1.59            | 2            | 1                      | 1                        | -6.00   | 6.00    | -4.00   | 0.00    |
| multifocal    | CR39          | 1.67            | 49           | 7                      | 6                        | -13.00  | 10.00   | -8.00   | 0.00    |
| multifocal    | CR39          | 1.74            | 38           | 8                      | 5                        | -15.00  | 12.00   | -8.00   | 0.00    |
| multifocal    | POLICARBONATO | 1.59            | 60           | 12                     | 6                        | -10.00  | 8.00    | -6.00   | 0.00    |
| bifocal       | CR39          | 1.50            | 1            | 1                      | 1                        | -4.00   | 4.00    | -3.00   | 0.00    |


-- ============================================================================
-- 6. VERIFICAR SE HÁ LENTES COM RANGES FORA DO GRUPO
-- ============================================================================

SELECT
  l.id as lente_id,
  l.nome_lente,
  l.tipo_lente,
  l.material,
  l.indice_refracao,
  gc.nome_grupo,
  l.esferico_min as lente_esf_min,
  l.esferico_max as lente_esf_max,
  gc.grau_esferico_min as grupo_esf_min,
  gc.grau_esferico_max as grupo_esf_max,
  l.cilindrico_min as lente_cil_min,
  l.cilindrico_max as lente_cil_max,
  gc.grau_cilindrico_min as grupo_cil_min,
  gc.grau_cilindrico_max as grupo_cil_max,
  CASE
    WHEN l.esferico_min < gc.grau_esferico_min THEN 'Esférico MIN fora do range'
    WHEN l.esferico_max > gc.grau_esferico_max THEN 'Esférico MAX fora do range'
    WHEN l.cilindrico_min < gc.grau_cilindrico_min THEN 'Cilíndrico MIN fora do range'
    WHEN l.cilindrico_max > gc.grau_cilindrico_max THEN 'Cilíndrico MAX fora do range'
  END as problema
FROM lens_catalog.lentes l
JOIN lens_catalog.grupos_canonicos gc ON gc.id = l.grupo_canonico_id
WHERE l.ativo = true
  AND gc.ativo = true
  AND (
    l.esferico_min < gc.grau_esferico_min
    OR l.esferico_max > gc.grau_esferico_max
    OR l.cilindrico_min < gc.grau_cilindrico_min
    OR l.cilindrico_max > gc.grau_cilindrico_max
  );

-- Esperado: 0 linhas (todas as lentes dentro dos ranges dos grupos)

Success. No rows returned



-- ============================================================================
-- 7. ANÁLISE: IMPACTO DAS MUDANÇAS NOS GAPs
-- ============================================================================

-- 7.1: Quantos grupos existem hoje?
SELECT COUNT(*) as total_grupos_ativos
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;


| total_grupos_ativos |
| ------------------- |
| 461                 |

-- 7.2: Quantos grupos foram criados/atualizados nos últimos 7 dias?
SELECT
  COUNT(*) as grupos_recentes,
  MIN(updated_at) as primeira_atualizacao,
  MAX(updated_at) as ultima_atualizacao
FROM lens_catalog.grupos_canonicos
WHERE updated_at > NOW() - INTERVAL '7 days';


| grupos_recentes | primeira_atualizacao          | ultima_atualizacao            |
| --------------- | ----------------------------- | ----------------------------- |
| 2               | 2026-01-22 00:05:42.306256+00 | 2026-01-22 00:05:42.306256+00 |


-- 7.3: Distribuição de lentes por ranges de graus
SELECT
  tipo_lente,
  CONCAT('[', esferico_min, ' a ', esferico_max, ']') as range_esferico,
  CONCAT('[', cilindrico_min, ' a ', cilindrico_max, ']') as range_cilindrico,
  COUNT(DISTINCT grupo_canonico_id) as total_grupos,
  COUNT(*) as total_lentes,
  MIN(preco_venda_sugerido) as preco_min,
  MAX(preco_venda_sugerido) as preco_max
FROM lens_catalog.lentes
WHERE ativo = true
  AND grupo_canonico_id IS NOT NULL
GROUP BY tipo_lente, esferico_min, esferico_max, cilindrico_min, cilindrico_max
ORDER BY total_lentes DESC
LIMIT 20;


| tipo_lente    | range_esferico   | range_cilindrico | total_grupos | total_lentes | preco_min | preco_max |
| ------------- | ---------------- | ---------------- | ------------ | ------------ | --------- | --------- |
| multifocal    | [-8.00 a 6.50]   | [-6.00 a 0.00]   | 20           | 200          | 1622.72   | 5611.80   |
| multifocal    | [-10.00 a 8.00]  | [-6.00 a 0.00]   | 8            | 105          | 2209.35   | 5983.34   |
| multifocal    | [-13.00 a 9.00]  | [-6.00 a 0.00]   | 12           | 85           | 4360.32   | 9053.37   |
| visao_simples | [-8.00 a 6.50]   | [-6.00 a 0.00]   | 10           | 52           | 1818.26   | 5142.50   |
| multifocal    | [-8.00 a 6.00]   | [-5.00 a 0.00]   | 12           | 50           | 996.98    | 4986.06   |
| multifocal    | [-15.00 a 10.00] | [-8.00 a 0.00]   | 6            | 40           | 5064.28   | 9640.00   |
| visao_simples | [-13.00 a 9.00]  | [-6.00 a 0.00]   | 8            | 40           | 4360.32   | 7801.89   |
| visao_simples | [-10.00 a 8.00]  | [-6.00 a 0.00]   | 8            | 40           | 2287.56   | 5748.68   |
| visao_simples | [-14.00 a 10.00] | [-8.00 a 0.00]   | 8            | 40           | 5298.93   | 9444.46   |
| multifocal    | [-13.00 a 9.00]  | [-8.00 a 0.00]   | 6            | 40           | 4203.89   | 8036.54   |
| multifocal    | [-6.00 a 6.00]   | [-4.00 a 0.00]   | 23           | 36           | 551.14    | 6315.76   |
| multifocal    | [-13.00 a 10.00] | [-6.00 a 0.00]   | 6            | 35           | 5259.83   | 9561.78   |
| visao_simples | [-9.50 a 7.50]   | [-4.00 a 0.00]   | 12           | 35           | 4360.32   | 6276.65   |
| multifocal    | [-13.00 a 8.00]  | [-5.00 a 0.00]   | 8            | 30           | 3187.06   | 6472.19   |
| multifocal    | [-8.00 a 6.00]   | [-4.00 a 0.00]   | 10           | 28           | 762.32    | 2811.62   |
| visao_simples | [-6.00 a 6.00]   | [-2.25 a -4.00]  | 14           | 23           | 265.64    | 801.43    |
| multifocal    | [-10.00 a 7.00]  | [-6.00 a 0.00]   | 6            | 20           | 2444.00   | 5787.79   |
| visao_simples | [-8.00 a 6.00]   | [-4.00 a 0.00]   | 6            | 20           | 1974.69   | 3421.72   |
| multifocal    | [-13.00 a 11.00] | [-6.00 a 0.00]   | 6            | 20           | 5338.04   | 9483.57   |
| visao_simples | [-8.00 a 7.00]   | [-4.00 a 0.00]   | 6            | 20           | 2287.56   | 4203.89   |


-- ============================================================================
-- 8. DECISÃO: PRECISA RE-CANONIZAR?
-- ============================================================================

-- Se encontramos problemas nas queries acima (4, 6), precisamos:
-- OPÇÃO A: Atualizar apenas os grupos desatualizados
-- OPÇÃO B: Re-canonizar tudo do zero

-- ============================================================================
-- RESULTADO ESPERADO:
-- ============================================================================
-- ✅ Todos os triggers estão ativos
-- ✅ 0 lentes órfãs (sem grupo_canonico_id)
-- ✅ Estatísticas sincronizadas (total_registrado = total_real)
-- ✅ Todas as lentes dentro dos ranges dos grupos
-- ⚠️  Se houver problemas → executar script de re-canonização
-- ============================================================================
