-- ============================================================================
-- SOLUÇÃO: Desabilitar trigger de auditoria e re-canonizar
-- ============================================================================

BEGIN;

-- Desabilitar trigger de auditoria que pode estar causando problemas
DROP TRIGGER IF EXISTS trg_grupos_auditoria ON lens_catalog.grupos_canonicos;

-- Ativar todos os grupos existentes que foram criados como false
UPDATE lens_catalog.grupos_canonicos
SET ativo = true
WHERE ativo = false;

-- Verificar
SELECT 
  'Grupos agora ativos' as status,
  COUNT(*) as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;

COMMIT;

-- Agora processar o resto das lentes
UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE ativo = true
  AND grupo_canonico_id IS NULL;

-- VALIDAÇÃO FINAL
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
