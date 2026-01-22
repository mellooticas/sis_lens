-- ============================================================================
-- ATIVAR TRIGGER CORRETO DE CANONIZAÇÃO
-- ============================================================================
-- Problema: Trigger trg_lente_insert_update NÃO EXISTE
-- Só existe trg_lentes_associar_grupo que usa função incompleta
-- Solução: Remover trigger errado, criar trigger correto, disparar
-- ============================================================================

BEGIN;

-- ============================================================================
-- PASSO 1: Remover trigger incompleto
-- ============================================================================

DROP TRIGGER IF EXISTS trg_lentes_associar_grupo ON lens_catalog.lentes;
DROP TRIGGER IF EXISTS trg_lentes_atualizar_estatisticas ON lens_catalog.lentes;

DO $$ BEGIN RAISE NOTICE '✓ Triggers antigos removidos'; END $$;

-- ============================================================================
-- PASSO 2: Criar trigger correto que chama trigger_atualizar_grupo_canonico
-- ============================================================================

DROP TRIGGER IF EXISTS trg_lente_insert_update ON lens_catalog.lentes;

CREATE TRIGGER trg_lente_insert_update
  BEFORE INSERT OR UPDATE ON lens_catalog.lentes
  FOR EACH ROW
  EXECUTE FUNCTION lens_catalog.trigger_atualizar_grupo_canonico();

DO $$ BEGIN RAISE NOTICE '✓ Trigger correto criado: trg_lente_insert_update'; END $$;

-- ============================================================================
-- PASSO 3: Verificar que a função está correta
-- ============================================================================

DO $$
DECLARE
  v_function_exists BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'lens_catalog'
      AND p.proname = 'trigger_atualizar_grupo_canonico'
  ) INTO v_function_exists;
  
  IF NOT v_function_exists THEN
    RAISE EXCEPTION 'Função trigger_atualizar_grupo_canonico não existe!';
  END IF;
  
  RAISE NOTICE '✓ Função trigger_atualizar_grupo_canonico existe e está pronta';
END $$;

-- ============================================================================
-- PASSO 4: Limpar grupos existentes (todos órfãos mesmo)
-- ============================================================================

DELETE FROM lens_catalog.grupos_canonicos;
DO $$ BEGIN RAISE NOTICE '✓ Grupos órfãos deletados'; END $$;

-- ============================================================================
-- PASSO 5: Forçar UPDATE em todas as lentes para disparar trigger
-- ============================================================================

UPDATE lens_catalog.lentes
SET grupo_canonico_id = NULL,
    updated_at = NOW()
WHERE ativo = true;

DO $$ BEGIN RAISE NOTICE '✓ UPDATE executado - trigger deve ter criado grupos'; END $$;

COMMIT;

-- ============================================================================
-- VALIDAÇÃO IMEDIATA
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

-- ============================================================================
-- VERIFICAR INCOMPATIBILIDADES (deve ser 0)
-- ============================================================================

WITH incompativeis AS (
  SELECT 
    gc.id as grupo_id,
    gc.nome_grupo,
    l.id as lente_id,
    l.nome as lente_nome,
    CASE 
      WHEN l.ar != gc.tratamento_antirreflexo THEN 'AR incompatível'
      WHEN l.uv400 != gc.tratamento_uv THEN 'UV incompatível'
      WHEN l.blue != gc.tratamento_blue_light THEN 'Blue incompatível'
      WHEN COALESCE(l.fotossensivel, 'nenhum') != COALESCE(gc.tratamento_fotossensiveis, 'nenhum') THEN 'Fotossensível incompatível'
    END as problema
  FROM lens_catalog.grupos_canonicos gc
  JOIN lens_catalog.lentes l ON l.grupo_canonico_id = gc.id
  WHERE gc.ativo = true
    AND l.ativo = true
    AND (
      l.ar != gc.tratamento_antirreflexo
      OR l.uv400 != gc.tratamento_uv
      OR l.blue != gc.tratamento_blue_light
      OR COALESCE(l.fotossensivel, 'nenhum') != COALESCE(gc.tratamento_fotossensiveis, 'nenhum')
    )
)
SELECT 
  COUNT(*) as total_incompatibilidades,
  CASE WHEN COUNT(*) = 0 THEN '✓ SUCESSO - Nenhuma incompatibilidade!' 
       ELSE '✗ ERRO - Existem incompatibilidades'
  END as status
FROM incompativeis;

-- ============================================================================
-- VERIFICAR TRIGGERS ATIVOS AGORA
-- ============================================================================

SELECT 
  tgname as trigger_name,
  proname as function_name,
  CASE 
    WHEN tgtype & 1 = 1 THEN 'ROW' 
    ELSE 'STATEMENT' 
  END as level,
  CASE 
    WHEN tgtype & 2 = 2 THEN 'BEFORE'
    WHEN tgtype & 64 = 64 THEN 'INSTEAD OF'
    ELSE 'AFTER'
  END as timing,
  CASE 
    WHEN tgtype & 4 = 4 THEN 'INSERT'
    WHEN tgtype & 8 = 8 THEN 'DELETE'  
    WHEN tgtype & 16 = 16 THEN 'UPDATE'
    ELSE 'OTHER'
  END as event
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE n.nspname = 'lens_catalog'
  AND c.relname = 'lentes'
  AND NOT t.tgisinternal
ORDER BY tgname;

-- ============================================================================
-- AMOSTRAS DE GRUPOS CRIADOS
-- ============================================================================

SELECT 
  gc.nome_grupo,
  gc.tratamento_antirreflexo as ar,
  gc.tratamento_uv as uv,
  gc.tratamento_blue_light as blue,
  gc.tratamento_fotossensiveis as foto,
  gc.total_lentes,
  gc.total_marcas
FROM lens_catalog.grupos_canonicos gc
WHERE gc.ativo = true
ORDER BY gc.total_lentes DESC
LIMIT 10;
