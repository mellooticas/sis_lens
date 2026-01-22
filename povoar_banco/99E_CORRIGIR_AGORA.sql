-- ============================================================================
-- CORREÇÃO EMERGENCIAL - Criar Grupos Canônicos
-- ============================================================================
-- O trigger trg_lente_insert_update não criou os grupos
-- Vamos usar a função correta manualmente
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. REATIVAR TODOS OS TRIGGERS (precisa do que cria grupos)
-- ============================================================================

ALTER TABLE lens_catalog.lentes ENABLE TRIGGER trg_lentes_associar_grupo;
ALTER TABLE lens_catalog.lentes ENABLE TRIGGER trg_lentes_atualizar_estatisticas;
ALTER TABLE lens_catalog.lentes ENABLE TRIGGER trg_lente_insert_update;

-- ============================================================================
-- 2. FORÇAR UPDATE EM TODAS AS LENTES NOVAMENTE
-- ============================================================================
-- Agora com os triggers corretos ativos

UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE ativo = true;

-- ============================================================================
-- 3. VALIDAR
-- ============================================================================

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

COMMIT;

-- Verificar incompatibilidades
SELECT COUNT(*) as total_incompatibilidades
FROM lens_catalog.grupos_canonicos gc
JOIN lens_catalog.lentes l ON l.grupo_canonico_id = gc.id
WHERE gc.ativo = true
  AND l.ativo = true
  AND (
    l.ar != gc.tratamento_antirreflexo
    OR l.uv400 != gc.tratamento_uv
    OR l.blue != gc.tratamento_blue_light
    OR COALESCE(l.fotossensivel, 'nenhum') != COALESCE(gc.tratamento_fotossensiveis, 'nenhum')
  );
