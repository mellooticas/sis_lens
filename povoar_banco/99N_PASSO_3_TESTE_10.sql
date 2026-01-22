-- ============================================================================
-- PASSO 3: Processar primeiras 10 lentes (TESTE)
-- ============================================================================

UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE id IN (
  SELECT id
  FROM lens_catalog.lentes
  WHERE ativo = true
  LIMIT 10
);

-- VALIDAR
SELECT 
  'PASSO 3: 10 lentes processadas' as status,
  (SELECT COUNT(*) FROM lens_catalog.grupos_canonicos WHERE ativo = true) as grupos_criados,
  (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND grupo_canonico_id IS NOT NULL) as lentes_associadas;


| status                         | grupos_criados | lentes_associadas |
| ------------------------------ | -------------- | ----------------- |
| PASSO 3: 10 lentes processadas | 0              | 10                |

-- Ver os grupos criados
SELECT 
  nome_grupo,
  total_lentes
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
ORDER BY created_at;

Success. No rows returned


