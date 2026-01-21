-- ============================================================================
-- SCRIPT 1: LIMPEZA DO BANCO - SIS LENS (CORRIGIDO)
-- ============================================================================
-- Objetivo: Remover tabelas obsoletas e schemas não utilizados
-- Executar no Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- PARTE 0: DROPAR VIEWS/FUNÇÕES QUE DEPENDEM DAS COLUNAS
-- ============================================================================

-- 0.1 - Dropar views que usam lente_canonica_id e premium_canonica_id
DROP VIEW IF EXISTS public.vw_lentes_catalogo CASCADE;
DROP VIEW IF EXISTS public.vw_canonicas_genericas CASCADE;
DROP VIEW IF EXISTS public.vw_canonicas_premium CASCADE;
DROP VIEW IF EXISTS public.vw_detalhes_premium CASCADE;

-- 0.2 - Dropar funções que dependem dessas views
DROP FUNCTION IF EXISTS public.buscar_lentes_por_receita(numeric, numeric, numeric, text) CASCADE;

-- ============================================================================
-- PARTE 1: REMOVER TABELAS OBSOLETAS DO lens_catalog
-- ============================================================================

-- 1.1 - Remover canônicas (não estão sendo usadas)
DROP TABLE IF EXISTS lens_catalog.lentes_canonicas CASCADE;
DROP TABLE IF EXISTS lens_catalog.premium_canonicas CASCADE;

-- 1.2 - Remover backups antigos
DROP TABLE IF EXISTS lens_catalog.grupos_canonicos_backup_old CASCADE;
DROP TABLE IF EXISTS lens_catalog.lentes_grupos_backup_old CASCADE;

-- 1.3 - Agora sim, limpar colunas de referência nas lentes
ALTER TABLE lens_catalog.lentes
  DROP COLUMN IF EXISTS lente_canonica_id CASCADE,
  DROP COLUMN IF EXISTS premium_canonica_id CASCADE;

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
-- PARTE 3: RECRIAR VIEW vw_lentes_catalogo SEM AS COLUNAS REMOVIDAS
-- ============================================================================

CREATE OR REPLACE VIEW public.vw_lentes_catalogo AS
SELECT
  l.id,
  l.marca_id,
  l.fornecedor_id,
  l.grupo_canonico_id,
  l.sku_fornecedor,
  l.codigo_original,
  l.nome_comercial,
  m.nome AS marca_nome,
  m.slug AS marca_slug,
  m.is_premium AS marca_premium,
  l.tipo_lente,
  l.categoria,
  l.material,
  l.indice_refracao,
  l.linha_produto,
  l.diametro,
  l.espessura_central,
  l.peso_aproximado,
  l.esferico_min,
  l.esferico_max,
  l.cilindrico_min,
  l.cilindrico_max,
  l.adicao_min,
  l.adicao_max,
  l.dnp_min,
  l.dnp_max,
  l.ar,
  l.antirrisco,
  l.hidrofobico,
  l.antiembaçante,
  l.blue,
  l.uv400,
  l.fotossensivel,
  l.polarizado,
  l.digital,
  l.free_form,
  l.indoor,
  l.drive,
  l.custo_base,
  l.preco_fabricante,
  l.preco_tabela,
  l.prazo_entrega,
  l.obs_prazo,
  l.peso_frete,
  l.exige_receita_especial,
  l.descricao_curta,
  l.descricao_completa,
  l.beneficios,
  l.indicacoes,
  l.contraindicacoes,
  l.observacoes,
  l.status,
  l.disponivel,
  l.destaque,
  l.novidade,
  l.data_lancamento,
  l.data_descontinuacao,
  l.created_at,
  l.updated_at
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE l.status = 'ativo'
ORDER BY l.created_at DESC;

-- ============================================================================
-- PARTE 4: RECRIAR FUNÇÃO DE BUSCA POR RECEITA
-- ============================================================================

CREATE OR REPLACE FUNCTION public.buscar_lentes_por_receita(
  p_esferico NUMERIC,
  p_cilindrico NUMERIC,
  p_adicao NUMERIC DEFAULT NULL,
  p_tipo_lente TEXT DEFAULT NULL
)
RETURNS SETOF vw_lentes_catalogo
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.vw_lentes_catalogo v
  WHERE v.disponivel = true
    AND (p_tipo_lente IS NULL OR v.tipo_lente::TEXT = p_tipo_lente)
    AND p_esferico BETWEEN v.esferico_min AND v.esferico_max
    AND p_cilindrico BETWEEN v.cilindrico_min AND v.cilindrico_max
    AND (p_adicao IS NULL OR (p_adicao BETWEEN v.adicao_min AND v.adicao_max))
  ORDER BY v.preco_tabela;
END;
$$;

-- ============================================================================
-- PARTE 5: VERIFICAÇÃO FINAL
-- ============================================================================

-- 5.1 - Verificar tabelas restantes no lens_catalog
SELECT table_name,
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'lens_catalog'
ORDER BY table_name;

-- 5.2 - Verificar se schema compras foi removido
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'compras';
-- Deve retornar 0 linhas

-- 5.3 - Verificar se colunas foram removidas
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'lens_catalog'
  AND table_name = 'lentes'
  AND column_name IN ('lente_canonica_id', 'premium_canonica_id');
-- Deve retornar 0 linhas

-- ============================================================================
-- RESULTADO ESPERADO:
-- ============================================================================
-- lens_catalog deve ter apenas:
--   ✅ lentes (core) - SEM lente_canonica_id e premium_canonica_id
--   ✅ grupos_canonicos (core)
--   ✅ marcas (core)
--   ✅ stg_lentes_import (ETL)
--   ✅ grupos_canonicos_log (auditoria)
--
-- Views recriadas:
--   ✅ public.vw_lentes_catalogo (sem campos canônicas)
--   ✅ public.buscar_lentes_por_receita() (função atualizada)
--
-- Removido:
--   ❌ lentes_canonicas
--   ❌ premium_canonicas
--   ❌ grupos_canonicos_backup_old
--   ❌ lentes_grupos_backup_old
--   ❌ Schema compras completo
--   ❌ Views/funções antigas que usavam canônicas
-- ============================================================================
