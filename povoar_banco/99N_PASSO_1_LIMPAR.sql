-- ============================================================================
-- PASSO 1: Limpar tudo
-- ============================================================================

-- Desabilitar triggers
DROP TRIGGER IF EXISTS trg_lentes_associar_grupo ON lens_catalog.lentes;
DROP TRIGGER IF EXISTS trg_lentes_atualizar_estatisticas ON lens_catalog.lentes;
DROP TRIGGER IF EXISTS trg_lente_insert_update ON lens_catalog.lentes;

-- Desassociar lentes
UPDATE lens_catalog.lentes
SET grupo_canonico_id = NULL
WHERE ativo = true;

-- Deletar grupos
DELETE FROM lens_catalog.grupos_canonicos;

-- VALIDAR
SELECT 
  'PASSO 1: Limpeza' as status,
  (SELECT COUNT(*) FROM lens_catalog.grupos_canonicos) as grupos,
  (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND grupo_canonico_id IS NOT NULL) as lentes_associadas;


| status           | grupos | lentes_associadas |
| ---------------- | ------ | ----------------- |
| PASSO 1: Limpeza | 0      | 0                 |