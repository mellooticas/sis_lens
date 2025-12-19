-- ============================================
-- VERIFICAÇÃO: View vw_lentes_catalogo
-- ============================================

-- 1. Verificar se a view existe
SELECT 
  table_name,
  table_type
FROM information_schema.tables
WHERE table_schema = 'public' 
  AND table_name = 'vw_lentes_catalogo';

-- 2. Contar total de lentes na view
SELECT 
  '=== Total de Lentes na View ===' as info,
  COUNT(*) as total_lentes
FROM public.vw_lentes_catalogo;

-- 3. Ver algumas lentes de exemplo (primeiras 5)
SELECT 
  '=== Exemplo de Lentes ===' as info,
  nome_comercial,
  marca_nome,
  tipo_lente,
  categoria,
  material,
  indice_refracao,
  preco_tabela,
  disponivel
FROM public.vw_lentes_catalogo
LIMIT 5;

-- 4. Estatísticas gerais
SELECT 
  '=== Estatísticas ===' as info,
  COUNT(*) as total,
  COUNT(DISTINCT marca_nome) as total_marcas,
  COUNT(DISTINCT categoria) as total_categorias,
  COUNT(DISTINCT tipo_lente) as total_tipos,
  ROUND(AVG(preco_tabela)::numeric, 2) as preco_medio,
  MIN(preco_tabela) as preco_min,
  MAX(preco_tabela) as preco_max
FROM public.vw_lentes_catalogo;

-- 5. Distribuição por categoria
SELECT 
  '=== Por Categoria ===' as info,
  categoria,
  COUNT(*) as total
FROM public.vw_lentes_catalogo
GROUP BY categoria
ORDER BY total DESC;

-- 6. Distribuição por tipo
SELECT 
  '=== Por Tipo ===' as info,
  tipo_lente,
  COUNT(*) as total
FROM public.vw_lentes_catalogo
GROUP BY tipo_lente
ORDER BY total DESC;

-- 7. Top 10 marcas
SELECT 
  '=== Top 10 Marcas ===' as info,
  marca_nome,
  COUNT(*) as total_lentes,
  ROUND(AVG(preco_tabela)::numeric, 2) as preco_medio
FROM public.vw_lentes_catalogo
GROUP BY marca_nome
ORDER BY total_lentes DESC
LIMIT 10;
