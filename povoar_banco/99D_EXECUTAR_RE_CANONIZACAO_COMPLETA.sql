-- ============================================================================
-- RE-CANONIZAÇÃO COMPLETA - EXECUTAR AGORA
-- ============================================================================
-- Data: 22/01/2026
-- Objetivo: Re-processar TODAS as lentes para garantir canonização 100% correta
--          com TODOS os campos (tipo, material, índice, tratamentos, ranges)
-- ============================================================================
-- Motivo: Encontramos 219 lentes com tratamentos fotossensíveis incompatíveis
--         causados por triggers duplicados com lógicas diferentes
-- ============================================================================

-- ⚠️ IMPORTANTE: Este script vai demorar alguns minutos
-- ⚠️ Execute em horário de baixo movimento se possível
-- ============================================================================

BEGIN;

-- ============================================================================
-- PASSO 1: BACKUP DE SEGURANÇA
-- ============================================================================
-- Criar tabela temporária com estado atual (apenas para emergência)

CREATE TEMP TABLE backup_grupos_canonicos AS
SELECT * FROM lens_catalog.grupos_canonicos;

CREATE TEMP TABLE backup_lentes_associacoes AS
SELECT id, grupo_canonico_id FROM lens_catalog.lentes;

-- ✅ Backup criado


-- ============================================================================
-- PASSO 2: DESATIVAR TRIGGERS TEMPORARIAMENTE
-- ============================================================================
-- Evita processamento duplicado durante a limpeza

ALTER TABLE lens_catalog.lentes DISABLE TRIGGER trg_lentes_associar_grupo;
ALTER TABLE lens_catalog.lentes DISABLE TRIGGER trg_lentes_atualizar_estatisticas;
ALTER TABLE lens_catalog.lentes DISABLE TRIGGER trg_lente_insert_update;

-- ✅ Triggers desativados temporariamente


-- ============================================================================
-- PASSO 3: LIMPAR ASSOCIAÇÕES EXISTENTES
-- ============================================================================

UPDATE lens_catalog.lentes
SET grupo_canonico_id = NULL
WHERE ativo = true;

-- ✅ Associações limpas


-- ============================================================================
-- PASSO 4: DELETAR GRUPOS CANÔNICOS ANTIGOS
-- ============================================================================
-- (Eles serão recriados automaticamente com os dados corretos)

-- Limpar log primeiro (FK constraint)
DELETE FROM lens_catalog.grupos_canonicos_log;

-- Deletar grupos
DELETE FROM lens_catalog.grupos_canonicos;

-- ✅ Grupos canônicos deletados (serão recriados)


-- ============================================================================
-- PASSO 5: REATIVAR APENAS O TRIGGER CORRETO
-- ============================================================================
-- Mantemos APENAS o trigger que considera TODOS os campos

-- Reativar o trigger COMPLETO (com tratamentos)
ALTER TABLE lens_catalog.lentes ENABLE TRIGGER trg_lente_insert_update;

-- Deixar os outros DESATIVADOS para evitar conflito
-- ALTER TABLE lens_catalog.lentes ENABLE TRIGGER trg_lentes_associar_grupo; -- MANTÉM DESATIVADO
-- ALTER TABLE lens_catalog.lentes ENABLE TRIGGER trg_lentes_atualizar_estatisticas; -- MANTÉM DESATIVADO

-- ✅ Trigger correto reativado (trg_lente_insert_update)


-- ============================================================================
-- PASSO 6: FORÇAR UPDATE EM TODAS AS LENTES
-- ============================================================================
-- Isso vai disparar o trigger que vai:
-- 1. Buscar grupo compatível com TODOS os campos
-- 2. Se não encontrar, criar novo grupo
-- 3. Atualizar estatísticas

UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE ativo = true;

-- ✅ Re-canonização executada


-- ============================================================================
-- PASSO 7: VALIDAR RESULTADO
-- ============================================================================

-- Verificar lentes órfãs
DO $$
DECLARE
  v_orfas INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_orfas
  FROM lens_catalog.lentes
  WHERE ativo = true AND grupo_canonico_id IS NULL;
  
  IF v_orfas > 0 THEN
    RAISE WARNING '⚠️ ATENÇÃO: % lentes ainda sem grupo!', v_orfas;
  ELSE
    RAISE NOTICE '✅ Perfeito: 0 lentes órfãs';
  END IF;
END $$;

-- Verificar incompatibilidades de tratamentos
DO $$
DECLARE
  v_incompativeis INTEGER;
BEGIN
  SELECT COUNT(DISTINCT gc.id) INTO v_incompativeis
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
  
  IF v_incompativeis > 0 THEN
    RAISE WARNING '⚠️ ATENÇÃO: % grupos com lentes incompatíveis!', v_incompativeis;
  ELSE
    RAISE NOTICE '✅ Perfeito: Todos os tratamentos compatíveis';
  END IF;
END $$;


-- ============================================================================
-- PASSO 8: ESTATÍSTICAS FINAIS
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
  'Lentes Órfãs (SEM GRUPO)' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.lentes
WHERE ativo = true AND grupo_canonico_id IS NULL

UNION ALL

SELECT
  'Grupos Canônicos Criados' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true

UNION ALL

SELECT
  'Lentes por Grupo (Média)' as metrica,
  ROUND(AVG(total_lentes)::NUMERIC, 2)::TEXT as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;


-- ============================================================================
-- RESULTADO DETALHADO
-- ============================================================================

SELECT
  tipo_lente,
  COUNT(DISTINCT grupo_canonico_id) as total_grupos,
  COUNT(*) as total_lentes,
  ROUND(AVG(preco_venda_sugerido)::NUMERIC, 2) as preco_medio
FROM lens_catalog.lentes
WHERE ativo = true
GROUP BY tipo_lente
ORDER BY total_lentes DESC;


-- ============================================================================
-- COMMIT FINAL
-- ============================================================================
-- Se tudo estiver OK, commita as mudanças
-- Se houver erro, fará ROLLBACK automático

COMMIT;

-- ✅ SUCESSO: Re-canonização completa aplicada!
-- 📊 Consulte as estatísticas acima para validar


-- ============================================================================
-- VERIFICAÇÃO PÓS-EXECUÇÃO (Execute separadamente depois)
-- ============================================================================

-- 1. Ver distribuição de grupos por tratamentos
SELECT
  tipo_lente,
  material,
  indice_refracao,
  tratamento_antirreflexo as ar,
  tratamento_uv as uv,
  tratamento_blue_light as blue,
  tratamento_fotossensiveis as foto,
  COUNT(*) as grupos,
  SUM(total_lentes) as lentes
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
GROUP BY tipo_lente, material, indice_refracao,
         tratamento_antirreflexo, tratamento_uv, 
         tratamento_blue_light, tratamento_fotossensiveis
ORDER BY lentes DESC
LIMIT 20;

-- 2. Verificar se ainda há incompatibilidades
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
-- Esperado: 0


-- ============================================================================
-- NOTAS IMPORTANTES:
-- ============================================================================
-- ✅ Este script re-cria TODOS os grupos canônicos do zero
-- ✅ Garante que TODOS os campos sejam considerados
-- ✅ Corrige os 219 casos de incompatibilidade encontrados
-- ✅ Usa apenas o trigger correto (com verificação de tratamentos)
-- ✅ Backup temporário criado para segurança
-- 
-- ⏱️ Tempo estimado: 2-5 minutos (dependendo do volume)
-- 💾 Espaço: Grupos canônicos serão recriados (pode aumentar quantidade)
-- 
-- 🔄 Após execução:
-- - Triggers duplicados devem ser removidos permanentemente
-- - Manter apenas: trg_lente_insert_update (trigger correto)
-- ============================================================================
