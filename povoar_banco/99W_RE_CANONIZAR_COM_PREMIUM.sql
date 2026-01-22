-- ============================================================================
-- RE-CANONIZAR COM is_premium
-- ============================================================================

BEGIN;

-- Desassociar todas as lentes
DROP TRIGGER IF EXISTS trg_lente_insert_update ON lens_catalog.lentes;

UPDATE lens_catalog.lentes
SET grupo_canonico_id = NULL
WHERE ativo = true;

-- Deletar grupos antigos
DELETE FROM lens_catalog.grupos_canonicos;

-- Recriar trigger
CREATE TRIGGER trg_lente_insert_update
  BEFORE INSERT OR UPDATE ON lens_catalog.lentes
  FOR EACH ROW
  EXECUTE FUNCTION lens_catalog.trigger_atualizar_grupo_canonico();

-- Processar todas as lentes
UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE ativo = true;

COMMIT;

-- VALIDAÇÃO
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
  'Grupos Standard' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true AND is_premium = false

UNION ALL

SELECT
  'Grupos Premium' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true AND is_premium = true

UNION ALL

SELECT
  'Grupos TOTAL' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;

-- Ver distribuição de lentes
SELECT
  'Lentes Standard' as tipo,
  COUNT(*) as total
FROM lens_catalog.lentes l
JOIN lens_catalog.grupos_canonicos gc ON l.grupo_canonico_id = gc.id
WHERE l.ativo = true AND gc.is_premium = false

UNION ALL

SELECT
  'Lentes Premium' as tipo,
  COUNT(*) as total
FROM lens_catalog.lentes l
JOIN lens_catalog.grupos_canonicos gc ON l.grupo_canonico_id = gc.id
WHERE l.ativo = true AND gc.is_premium = true;

| tipo            | total |
| --------------- | ----- |
| Lentes Standard | 1163  |
| Lentes Premium  | 248   |