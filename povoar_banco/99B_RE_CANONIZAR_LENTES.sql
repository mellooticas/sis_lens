-- ============================================================================
-- RE-CANONIZAÇÃO: Atualizar Grupos Canônicos após Mudanças
-- ============================================================================
-- Data: 22/01/2026
-- Objetivo: Re-processar todas as lentes para garantir que os grupos canônicos
--          estejam corretos após mudanças nos ranges de graus (novos GAPs)
-- ============================================================================
-- ⚠️  ATENÇÃO: Execute este script APENAS se a investigação anterior
--             (99_INVESTIGAR_CANONIZACAO_POS_MUDANCAS.sql) mostrou problemas
-- ============================================================================

-- ============================================================================
-- ESTRATÉGIA
-- ============================================================================
-- 1. Desativar triggers temporariamente (evitar processamento duplicado)
-- 2. Limpar grupo_canonico_id de todas as lentes
-- 3. Reativar triggers
-- 4. Forçar UPDATE em todas as lentes (triggers vão re-canonizar)
-- 5. Limpar grupos órfãos (sem lentes)
-- 6. Validar resultado
-- ============================================================================


-- ============================================================================
-- OPÇÃO 1: RE-CANONIZAÇÃO COMPLETA (RECOMENDADO)
-- ============================================================================
-- Remove todos os grupos e recria do zero

BEGIN;

-- 1. DESATIVAR TRIGGERS TEMPORARIAMENTE
ALTER TABLE lens_catalog.lentes DISABLE TRIGGER trg_lentes_associar_grupo;
ALTER TABLE lens_catalog.lentes DISABLE TRIGGER trg_lentes_atualizar_estatisticas;

-- 2. LIMPAR ASSOCIAÇÕES
UPDATE lens_catalog.lentes
SET grupo_canonico_id = NULL
WHERE ativo = true;

-- 3. DELETAR GRUPOS CANÔNICOS EXISTENTES
-- (Eles serão recriados automaticamente pelos triggers)
DELETE FROM lens_catalog.grupos_canonicos_log;  -- Limpar log primeiro (FK)
DELETE FROM lens_catalog.grupos_canonicos;

-- 4. REATIVAR TRIGGERS
ALTER TABLE lens_catalog.lentes ENABLE TRIGGER trg_lentes_associar_grupo;
ALTER TABLE lens_catalog.lentes ENABLE TRIGGER trg_lentes_atualizar_estatisticas;

-- 5. FORÇAR UPDATE EM TODAS AS LENTES
-- (Triggers vão associar ao grupo correto ou criar novo grupo)
UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE ativo = true;

-- 6. VERIFICAR RESULTADO
SELECT
  'Lentes ativas' as metrica,
  COUNT(*) as total
FROM lens_catalog.lentes
WHERE ativo = true

UNION ALL

SELECT
  'Lentes com grupo' as metrica,
  COUNT(*) as total
FROM lens_catalog.lentes
WHERE ativo = true
  AND grupo_canonico_id IS NOT NULL

UNION ALL

SELECT
  'Lentes órfãs (SEM GRUPO)' as metrica,
  COUNT(*) as total
FROM lens_catalog.lentes
WHERE ativo = true
  AND grupo_canonico_id IS NULL

UNION ALL

SELECT
  'Grupos canônicos criados' as metrica,
  COUNT(*) as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;

COMMIT;


-- ============================================================================
-- OPÇÃO 2: RE-CANONIZAÇÃO PARCIAL (MAIS RÁPIDA)
-- ============================================================================
-- Atualiza apenas as estatísticas dos grupos existentes
-- Use esta opção se os grupos estão corretos, mas as estatísticas estão desatualizadas

BEGIN;

-- Atualizar estatísticas de todos os grupos
SELECT lens_catalog.atualizar_estatisticas_grupo_canonico(id)
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;

-- Verificar resultado
SELECT
  gc.id,
  gc.nome_grupo,
  gc.total_lentes,
  gc.total_marcas,
  gc.preco_minimo,
  gc.preco_maximo,
  gc.preco_medio,
  gc.updated_at
FROM lens_catalog.grupos_canonicos gc
WHERE gc.ativo = true
ORDER BY gc.total_lentes DESC;

COMMIT;


-- ============================================================================
-- OPÇÃO 3: RE-CANONIZAÇÃO SELETIVA (ESPECÍFICA)
-- ============================================================================
-- Re-processa apenas lentes que estão com problemas
-- (ex: lentes com ranges fora do grupo)

BEGIN;

-- Limpar associação apenas de lentes problemáticas
WITH lentes_problematicas AS (
  SELECT l.id
  FROM lens_catalog.lentes l
  JOIN lens_catalog.grupos_canonicos gc ON gc.id = l.grupo_canonico_id
  WHERE l.ativo = true
    AND gc.ativo = true
    AND (
      l.esferico_min < gc.grau_esferico_min
      OR l.esferico_max > gc.grau_esferico_max
      OR l.cilindrico_min < gc.grau_cilindrico_min
      OR l.cilindrico_max > gc.grau_cilindrico_max
    )
)
UPDATE lens_catalog.lentes
SET grupo_canonico_id = NULL, updated_at = NOW()
WHERE id IN (SELECT id FROM lentes_problematicas);

-- Forçar UPDATE para re-associar (triggers farão o trabalho)
WITH lentes_problematicas AS (
  SELECT id FROM lens_catalog.lentes
  WHERE ativo = true AND grupo_canonico_id IS NULL
)
UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE id IN (SELECT id FROM lentes_problematicas);

-- Limpar grupos órfãos
DELETE FROM lens_catalog.grupos_canonicos
WHERE id NOT IN (
  SELECT DISTINCT grupo_canonico_id
  FROM lens_catalog.lentes
  WHERE grupo_canonico_id IS NOT NULL
);

COMMIT;


-- ============================================================================
-- VALIDAÇÃO FINAL (Execute após qualquer opção acima)
-- ============================================================================

-- 1. Verificar integridade
SELECT * FROM lens_catalog.validar_integridade_grupos();

-- 2. Lentes órfãs?
SELECT
  COUNT(*) as lentes_sem_grupo,
  ARRAY_AGG(id) as ids_orfaos
FROM lens_catalog.lentes
WHERE ativo = true
  AND grupo_canonico_id IS NULL;

-- 3. Estatísticas gerais
SELECT
  'Total Lentes Ativas' as metrica,
  COUNT(*)::TEXT as valor
FROM lens_catalog.lentes
WHERE ativo = true

UNION ALL

SELECT
  'Total Grupos Ativos' as metrica,
  COUNT(*)::TEXT as valor
FROM lens_catalog.grupos_canonicos
WHERE ativo = true

UNION ALL

SELECT
  'Lentes por Grupo (Média)' as metrica,
  ROUND(AVG(total_lentes)::NUMERIC, 2)::TEXT as valor
FROM lens_catalog.grupos_canonicos
WHERE ativo = true

UNION ALL

SELECT
  'Marcas por Grupo (Média)' as metrica,
  ROUND(AVG(total_marcas)::NUMERIC, 2)::TEXT as valor
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;

-- 4. Distribuição por tipo de lente
SELECT
  tipo_lente,
  COUNT(DISTINCT id) as total_grupos,
  SUM(total_lentes) as total_lentes,
  ROUND(AVG(preco_medio)::NUMERIC, 2) as preco_medio_geral
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
GROUP BY tipo_lente
ORDER BY total_lentes DESC;


-- ============================================================================
-- LOGS E AUDITORIA
-- ============================================================================

-- Ver log de mudanças nos grupos (últimas 50)
SELECT
  operacao,
  nome_grupo,
  alteracoes_json,
  usuario,
  data_alteracao
FROM lens_catalog.grupos_canonicos_log
ORDER BY data_alteracao DESC
LIMIT 50;


-- ============================================================================
-- RESULTADO ESPERADO APÓS RE-CANONIZAÇÃO:
-- ============================================================================
-- ✅ 0 lentes órfãs (todas com grupo_canonico_id)
-- ✅ Estatísticas corretas (total_lentes = count real)
-- ✅ Ranges corretos (lentes dentro dos ranges dos grupos)
-- ✅ Grupos criados para todos os novos GAPs de graus
-- ✅ Preços e totais atualizados
-- ============================================================================
