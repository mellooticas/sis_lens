-- ============================================================================
-- PROCESSAR TODAS AS LENTES RESTANTES
-- ============================================================================

-- Processar todas as lentes órfãs
UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE ativo = true
  AND grupo_canonico_id IS NULL;

-- VALIDAÇÃO COMPLETA
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

-- Ver top 10 grupos por quantidade de lentes
SELECT 
  nome_grupo,
  total_lentes,
  total_marcas,
  tratamento_antirreflexo as ar,
  tratamento_uv as uv,
  tratamento_blue_light as blue,
  tratamento_fotossensiveis as foto
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
ORDER BY total_lentes DESC
LIMIT 10;


| nome_grupo                                                                        | total_lentes | total_marcas | ar    | uv   | blue  | foto          |
| --------------------------------------------------------------------------------- | ------------ | ------------ | ----- | ---- | ----- | ------------- |
| Lente CR39 1.50 Multifocal +UV +Fotocromático [-8.00/6.50 | -6.00/0.00]           | 44           | 2            | false | true | false | fotocromático |
| Lente CR39 1.50 Multifocal +UV [-8.00/6.50 | -6.00/0.00]                          | 41           | 1            | false | true | false | nenhum        |
| Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-10.00/8.00 | -6.00/0.00]     | 32           | 1            | false | true | true  | nenhum        |
| Lente CR39 1.50 Multifocal +AR +UV +Fotocromático [-8.00/6.50 | -6.00/0.00]       | 29           | 2            | true  | true | false | fotocromático |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00]                      | 27           | 1            | true  | true | false | nenhum        |
| Lente CR39 1.67 Multifocal +UV [-13.00/9.00 | -6.00/0.00]                         | 23           | 1            | false | true | false | nenhum        |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-10.00/8.00 | -6.00/0.00] | 21           | 1            | true  | true | true  | nenhum        |
| Lente CR39 1.56 Multifocal +UV +BlueLight [-8.00/6.50 | -6.00/0.00]               | 20           | 1            | false | true | true  | nenhum        |
| Lente CR39 1.67 Multifocal +AR +UV [-13.00/9.00 | -6.00/0.00]                     | 15           | 1            | true  | true | false | nenhum        |
| Lente CR39 1.67 Multifocal +UV +BlueLight [-13.00/9.00 | -6.00/0.00]              | 14           | 1            | false | true | true  | nenhum        |
