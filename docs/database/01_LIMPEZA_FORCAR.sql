-- ============================================================================
-- SCRIPT 1: LIMPEZA FORÇADA - SIS LENS
-- ============================================================================
-- Este script força a remoção de TODAS as dependências primeiro
-- ============================================================================

-- ============================================================================
-- PARTE 1: DROPAR TODAS AS VIEWS QUE PODEM DEPENDER DAS COLUNAS
-- ============================================================================

-- Buscar TODAS as views que usam a tabela lentes
DO $$
DECLARE
  view_record RECORD;
BEGIN
  FOR view_record IN
    SELECT schemaname, viewname
    FROM pg_views
    WHERE definition LIKE '%lente_canonica_id%'
       OR definition LIKE '%premium_canonica_id%'
       OR schemaname IN ('public', 'lens_catalog')
  LOOP
    EXECUTE format('DROP VIEW IF EXISTS %I.%I CASCADE',
                   view_record.schemaname,
                   view_record.viewname);
    RAISE NOTICE 'Dropped view: %.%', view_record.schemaname, view_record.viewname;
  END LOOP;
END $$;

-- Dropar explicitamente as views conhecidas
DROP VIEW IF EXISTS public.vw_lentes_catalogo CASCADE;
DROP VIEW IF EXISTS public.vw_canonicas_genericas CASCADE;
DROP VIEW IF EXISTS public.vw_canonicas_premium CASCADE;
DROP VIEW IF EXISTS public.vw_detalhes_premium CASCADE;
DROP VIEW IF EXISTS public.vw_stats_catalogo CASCADE;
DROP VIEW IF EXISTS public.v_lentes_catalogo CASCADE;
DROP VIEW IF EXISTS public.v_lentes_busca CASCADE;

-- ============================================================================
-- PARTE 2: DROPAR TODAS AS FUNÇÕES QUE PODEM DEPENDER
-- ============================================================================

DROP FUNCTION IF EXISTS public.buscar_lentes_por_receita(numeric, numeric, numeric, text) CASCADE;
DROP FUNCTION IF EXISTS public.buscar_lentes(
  lens_catalog.tipo_lente,
  lens_catalog.material_lente,
  lens_catalog.indice_refracao,
  numeric, numeric, boolean, boolean,
  uuid, uuid, integer, integer
) CASCADE;
DROP FUNCTION IF EXISTS public.obter_alternativas_lente(uuid, integer) CASCADE;

-- ============================================================================
-- PARTE 3: AGORA SIM, DROPAR AS TABELAS E COLUNAS
-- ============================================================================

-- 3.1 - Dropar tabelas canônicas
DROP TABLE IF EXISTS lens_catalog.lentes_canonicas CASCADE;
DROP TABLE IF EXISTS lens_catalog.premium_canonicas CASCADE;

-- 3.2 - Dropar backups
DROP TABLE IF EXISTS lens_catalog.grupos_canonicos_backup_old CASCADE;
DROP TABLE IF EXISTS lens_catalog.lentes_grupos_backup_old CASCADE;

-- 3.3 - FINALMENTE dropar as colunas
ALTER TABLE lens_catalog.lentes
  DROP COLUMN IF EXISTS lente_canonica_id,
  DROP COLUMN IF EXISTS premium_canonica_id;

-- ============================================================================
-- PARTE 4: DROPAR SCHEMA COMPRAS
-- ============================================================================

DROP SCHEMA IF EXISTS compras CASCADE;

-- ============================================================================
-- PARTE 5: RECRIAR VIEWS ESSENCIAIS (SEM AS COLUNAS REMOVIDAS)
-- ============================================================================

-- 5.1 - View principal de lentes
CREATE VIEW public.vw_lentes_catalogo AS
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

-- 5.2 - Função de busca por receita
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
-- PARTE 6: VERIFICAÇÕES FINAIS
-- ============================================================================

-- Verificar tabelas restantes
SELECT 'Tabelas lens_catalog:' as info;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'lens_catalog'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Verificar se colunas foram removidas
SELECT 'Colunas removidas (deve retornar vazio):' as info;
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'lens_catalog'
  AND table_name = 'lentes'
  AND column_name IN ('lente_canonica_id', 'premium_canonica_id');

-- Verificar schema compras
SELECT 'Schema compras (deve retornar vazio):' as info;
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'compras';

-- Listar views recriadas
SELECT 'Views public recriadas:' as info;
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE '%lente%'
ORDER BY table_name;

-- ============================================================================
-- SUCESSO!
-- ============================================================================
-- Se chegou até aqui sem erros:
-- ✅ Todas as views/funções antigas foram removidas
-- ✅ Tabelas canônicas removidas
-- ✅ Colunas lente_canonica_id e premium_canonica_id removidas
-- ✅ Schema compras removido
-- ✅ View vw_lentes_catalogo recriada (sem as colunas antigas)
-- ✅ Função buscar_lentes_por_receita() recriada
-- ============================================================================
