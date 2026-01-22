-- ============================================================================
-- EXECUTAR RE-CANONIZAÇÃO AUTOMÁTICA
-- ============================================================================

BEGIN;

-- Remover triggers antigos
DROP TRIGGER IF EXISTS trg_lentes_associar_grupo ON lens_catalog.lentes;
DROP TRIGGER IF EXISTS trg_lentes_atualizar_estatisticas ON lens_catalog.lentes;
DROP TRIGGER IF EXISTS trg_lente_insert_update ON lens_catalog.lentes;

-- Desassociar todas as lentes (SEM trigger ativo)
UPDATE lens_catalog.lentes
SET grupo_canonico_id = NULL
WHERE ativo = true;

-- Limpar grupos órfãos
DELETE FROM lens_catalog.grupos_canonicos;

-- AGORA criar trigger correto
CREATE TRIGGER trg_lente_insert_update
  BEFORE INSERT OR UPDATE ON lens_catalog.lentes
  FOR EACH ROW
  EXECUTE FUNCTION lens_catalog.trigger_atualizar_grupo_canonico();

-- Forçar UPDATE para disparar trigger e criar grupos
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
  'Grupos Criados' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;
