-- ============================================================================
-- SCRIPT 1: LIMPEZA DO BANCO - SIS LENS
-- ============================================================================
-- Objetivo: Remover tabelas obsoletas e schemas não utilizados
-- Executar no Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- PARTE 1: REMOVER TABELAS OBSOLETAS DO lens_catalog
-- ============================================================================

-- 1.1 - Remover canônicas (não estão sendo usadas)
DROP TABLE IF EXISTS lens_catalog.lentes_canonicas CASCADE;
DROP TABLE IF EXISTS lens_catalog.premium_canonicas CASCADE;

-- 1.2 - Remover backups antigos
DROP TABLE IF EXISTS lens_catalog.grupos_canonicos_backup_old CASCADE;
DROP TABLE IF EXISTS lens_catalog.lentes_grupos_backup_old CASCADE;

-- 1.3 - Limpar colunas de referência nas lentes (já que apagamos as canônicas)
ALTER TABLE lens_catalog.lentes
  DROP COLUMN IF EXISTS lente_canonica_id,
  DROP COLUMN IF EXISTS premium_canonica_id;

-- ============================================================================
-- PARTE 2: REMOVER SCHEMA COMPRAS COMPLETO
-- ============================================================================

-- 2.1 - Dropar views primeiro (dependências)
DROP VIEW IF EXISTS compras.v_estoque_alertas CASCADE;
DROP VIEW IF EXISTS compras.v_itens_pendentes CASCADE;
DROP VIEW IF EXISTS compras.v_pedidos_completos CASCADE;

-- 2.2 - Dropar tabelas
DROP TABLE IF EXISTS compras.estoque_movimentacoes CASCADE;
DROP TABLE IF EXISTS compras.historico_precos CASCADE;
DROP TABLE IF EXISTS compras.pedido_itens CASCADE;
DROP TABLE IF EXISTS compras.pedidos CASCADE;
DROP TABLE IF EXISTS compras.estoque_saldo CASCADE;

-- 2.3 - Dropar types/enums do schema compras
DROP TYPE IF EXISTS compras.status_pedido CASCADE;
DROP TYPE IF EXISTS compras.tipo_movimentacao CASCADE;

-- 2.4 - Dropar o schema
DROP SCHEMA IF EXISTS compras CASCADE;

-- ============================================================================
-- PARTE 3: VERIFICAÇÃO FINAL
-- ============================================================================

-- 3.1 - Verificar tabelas restantes no lens_catalog
SELECT table_name,
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'lens_catalog'
ORDER BY table_name;

-- 3.2 - Verificar se schema compras foi removido
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'compras';
-- Deve retornar 0 linhas

-- ============================================================================
-- RESULTADO ESPERADO:
-- ============================================================================
-- lens_catalog deve ter apenas:
--   ✅ lentes (core)
--   ✅ grupos_canonicos (core)
--   ✅ marcas (core)
--   ✅ stg_lentes_import (ETL)
--   ✅ grupos_canonicos_log (auditoria)
--
-- Removido:
--   ❌ lentes_canonicas
--   ❌ premium_canonicas
--   ❌ grupos_canonicos_backup_old
--   ❌ lentes_grupos_backup_old
--   ❌ Schema compras completo
-- ============================================================================
