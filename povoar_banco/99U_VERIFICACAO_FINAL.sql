-- ============================================================================
-- VERIFICAÇÃO FINAL: Fotossensível e Premium
-- ============================================================================

-- 1. VERIFICAR INCOMPATIBILIDADES FOTOSSENSÍVEIS (deve ser 0)
WITH incompativeis AS (
  SELECT 
    gc.id,
    gc.nome_grupo,
    gc.tratamento_fotossensiveis as grupo_foto,
    l.fotossensivel as lente_foto,
    COUNT(*) as total_incompativeis
  FROM lens_catalog.grupos_canonicos gc
  JOIN lens_catalog.lentes l ON l.grupo_canonico_id = gc.id
  WHERE gc.ativo = true
    AND l.ativo = true
    AND (
      -- Grupo sem foto mas lente tem
      (COALESCE(gc.tratamento_fotossensiveis, 'nenhum') = 'nenhum' AND l.fotossensivel != 'nenhum')
      OR
      -- Grupo com foto mas lente não tem
      (COALESCE(gc.tratamento_fotossensiveis, 'nenhum') != 'nenhum' AND l.fotossensivel = 'nenhum')
    )
  GROUP BY gc.id, gc.nome_grupo, gc.tratamento_fotossensiveis, l.fotossensivel
)
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ SUCESSO: 0 incompatibilidades fotossensíveis!'
    ELSE '❌ ERRO: ' || COUNT(*) || ' grupos com incompatibilidades'
  END as status_fotossensiveis,
  COUNT(*) as total_problemas
FROM incompativeis;


| status_fotossensiveis                           | total_problemas |
| ----------------------------------------------- | --------------- |
| ✅ SUCESSO: 0 incompatibilidades fotossensíveis! | 0               |

-- 2. Ver separação de grupos por fotossensível
SELECT 
  'Grupos por Fotossensível' as metrica,
  COALESCE(tratamento_fotossensiveis, 'nenhum') as tratamento,
  COUNT(*) as total_grupos,
  SUM(total_lentes) as total_lentes
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
GROUP BY COALESCE(tratamento_fotossensiveis, 'nenhum')
ORDER BY total_grupos DESC;


| metrica                  | tratamento    | total_grupos | total_lentes |
| ------------------------ | ------------- | ------------ | ------------ |
| Grupos por Fotossensível | nenhum        | 176          | 723          |
| Grupos por Fotossensível | fotocromático | 64           | 261          |



-- 3. VERIFICAR is_premium (TODOS devem estar como false atualmente)
SELECT 
  'Status Premium' as metrica,
  is_premium,
  COUNT(*) as total_grupos
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
GROUP BY is_premium;

| metrica        | is_premium | total_grupos |
| -------------- | ---------- | ------------ |
| Status Premium | false      | 240          |



-- 4. Ver lentes por tipo fotossensível
SELECT 
  'Lentes por Fotossensível' as metrica,
  fotossensivel,
  COUNT(*) as total_lentes
FROM lens_catalog.lentes
WHERE ativo = true
GROUP BY fotossensivel
ORDER BY total_lentes DESC;


| metrica                  | fotossensivel | total_lentes |
| ------------------------ | ------------- | ------------ |
| Lentes por Fotossensível | nenhum        | 1029         |
| Lentes por Fotossensível | transitions   | 238          |
| Lentes por Fotossensível | fotocromático | 81           |
| Lentes por Fotossensível | polarizado    | 60           |
| Lentes por Fotossensível | acclimates    | 3            |


-- 5. RESULTADO FINAL COMPLETO
SELECT
  'Lentes Ativas' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.lentes
WHERE ativo = true

UNION ALL

SELECT
  'Lentes com Grupo' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.lentes
WHERE ativo = true AND grupo_canonico_id IS NOT NULL

UNION ALL

SELECT
  'Lentes Órfãs' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.lentes
WHERE ativo = true AND grupo_canonico_id IS NULL

UNION ALL

SELECT
  'Grupos Criados' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;

| metrica          | total |
| ---------------- | ----- |
| Lentes Ativas    | 1411  |
| Lentes com Grupo | 1411  |
| Lentes Órfãs     | 0     |
| Grupos Criados   | 240   |


-- 6. Amostras de grupos com fotossensível
SELECT 
  nome_grupo,
  tratamento_fotossensiveis,
  total_lentes,
  total_marcas
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
  AND tratamento_fotossensiveis IS NOT NULL
  AND tratamento_fotossensiveis != 'nenhum'
ORDER BY total_lentes DESC
LIMIT 5;


| nome_grupo                                                                            | tratamento_fotossensiveis | total_lentes | total_marcas |
| ------------------------------------------------------------------------------------- | ------------------------- | ------------ | ------------ |
| Lente CR39 1.50 Multifocal +UV +Fotocromático [-8.00/6.50 | -6.00/0.00]               | fotocromático             | 44           | 2            |
| Lente CR39 1.50 Multifocal +AR +UV +Fotocromático [-8.00/6.50 | -6.00/0.00]           | fotocromático             | 29           | 2            |
| Lente POLICARBONATO 1.59 Multifocal +UV +Fotocromático [-10.00/8.00 | -6.00/0.00]     | fotocromático             | 14           | 1            |
| Lente CR39 1.50 Visao simples +UV +Fotocromático [-8.00/6.50 | -6.00/0.00]            | fotocromático             | 11           | 1            |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV +Fotocromático [-10.00/8.00 | -6.00/0.00] | fotocromático             | 9            | 1            |
