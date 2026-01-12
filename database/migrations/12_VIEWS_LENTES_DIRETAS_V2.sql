-- ============================================
-- 12_VIEWS_LENTES_DIRETAS_V2.sql
-- Views públicas para acessar lentes reais e canônicas
-- Corrigido com os nomes reais das colunas da tabela lens_catalog.lentes
-- ============================================

-- ====================
-- 0. DIAGNÓSTICO - Ver colunas reais da tabela lentes
-- ====================
-- Descomentar e executar para ver estrutura:
-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_schema = 'lens_catalog' AND table_name = 'lentes'
-- ORDER BY ordinal_position;

-- ====================
-- 1. View: Todas as Lentes do Catálogo
-- ====================
DROP VIEW IF EXISTS public.vw_lentes_catalogo CASCADE;
CREATE OR REPLACE VIEW public.vw_lentes_catalogo AS
SELECT 
  l.id,
  l.familia,
  l.design,
  
  -- Marca
  m.id as marca_id,
  m.nome as marca_nome,
  m.slug as marca_slug,
  m.pais_origem,
  
  -- Características Técnicas
  l.material,
  l.indice_refracao,
  l.tratamentos,
  l.tipo_lente,
  l.corredor_progressao,
  l.specs_tecnicas,
  
  -- Descrição completa
  CONCAT(m.nome, ' ', l.familia, ' ', l.design, ' ', l.indice_refracao) AS descricao_completa,
  
  -- Metadata
  l.ativo,
  l.criado_em,
  l.atualizado_em
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE l.ativo = true;

COMMENT ON VIEW public.vw_lentes_catalogo IS 'Lista completa do catálogo de lentes com informações da marca';

-- ====================
-- 2. View: Lentes Canônicas Genéricas (para comparação)
-- ====================
DROP VIEW IF EXISTS public.vw_canonicas_genericas CASCADE;
CREATE OR REPLACE VIEW public.vw_canonicas_genericas AS
SELECT 
  lc.id,
  lc.nome_canonico,
  lc.slug,
  lc.tipo_lente,
  lc.material_base,
  lc.categoria_uso,
  lc.tratamento_minimo,
  lc.descricao,
  lc.tags,
  lc.criado_em,
  lc.atualizado_em,
  
  -- Agregações das lentes que pertencem a este grupo
  COUNT(l.id) as total_lentes,
  COUNT(DISTINCT l.marca_id) as total_marcas,
  MIN(l.indice_refracao) as indice_min,
  MAX(l.indice_refracao) as indice_max,
  
  -- Lista de marcas disponíveis
  array_agg(DISTINCT m.nome ORDER BY m.nome) FILTER (WHERE m.nome IS NOT NULL) as marcas_disponiveis
  
FROM lens_catalog.lentes_canonicas lc
LEFT JOIN lens_catalog.lentes l ON l.familia ILIKE '%' || lc.nome_canonico || '%' AND l.ativo = true
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
GROUP BY lc.id, lc.nome_canonico, lc.slug, lc.tipo_lente, 
         lc.material_base, lc.categoria_uso, lc.tratamento_minimo, 
         lc.descricao, lc.tags, lc.criado_em, lc.atualizado_em;

COMMENT ON VIEW public.vw_canonicas_genericas IS 'Grupos canônicos de lentes genéricas com estatísticas';

-- ====================
-- 3. View: Lentes Premium Canônicas (para comparação)
-- ====================
DROP VIEW IF EXISTS public.vw_canonicas_premium CASCADE;
CREATE OR REPLACE VIEW public.vw_canonicas_premium AS
SELECT 
  pc.id,
  pc.nome_canonico,
  pc.slug,
  pc.tipo_lente,
  pc.tecnologia_base,
  pc.nivel_premium,
  pc.categoria_uso,
  pc.descricao,
  pc.tags,
  pc.criado_em,
  pc.atualizado_em,
  
  -- Agregações das lentes que pertencem a este grupo  
  COUNT(l.id) as total_lentes,
  COUNT(DISTINCT l.marca_id) as total_marcas,
  MIN(l.indice_refracao) as indice_min,
  MAX(l.indice_refracao) as indice_max,
  
  -- Lista de marcas disponíveis
  array_agg(DISTINCT m.nome ORDER BY m.nome) FILTER (WHERE m.nome IS NOT NULL) as marcas_disponiveis
  
FROM lens_catalog.premium_canonicas pc
LEFT JOIN lens_catalog.lentes l ON l.familia ILIKE '%' || pc.nome_canonico || '%' AND l.ativo = true
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
GROUP BY pc.id, pc.nome_canonico, pc.slug, pc.tipo_lente,
         pc.tecnologia_base, pc.nivel_premium, pc.categoria_uso,
         pc.descricao, pc.tags, pc.criado_em, pc.atualizado_em;

COMMENT ON VIEW public.vw_canonicas_premium IS 'Grupos canônicos de lentes premium com estatísticas';

-- ====================
-- 4. View: Comparativo de Marcas por Canônica Genérica
-- ====================
DROP VIEW IF EXISTS public.vw_comparativo_canonicas_genericas CASCADE;
CREATE OR REPLACE VIEW public.vw_comparativo_canonicas_genericas AS
SELECT 
  lc.id as canonica_id,
  lc.nome_canonico,
  lc.slug as canonica_slug,
  lc.tipo_lente,
  
  -- Informações da lente real
  l.id as lente_id,
  l.familia,
  l.design,
  l.indice_refracao,
  l.material,
  l.tratamentos,
  
  -- Marca
  m.id as marca_id,
  m.nome as marca_nome,
  m.slug as marca_slug,
  m.pais_origem,
  
  -- Descrição
  CONCAT(m.nome, ' ', l.familia, ' ', l.design) as descricao_lente
  
FROM lens_catalog.lentes_canonicas lc
INNER JOIN lens_catalog.lentes l ON l.familia ILIKE '%' || lc.nome_canonico || '%' AND l.ativo = true
INNER JOIN lens_catalog.marcas m ON l.marca_id = m.id
ORDER BY lc.nome_canonico, m.nome, l.indice_refracao;

COMMENT ON VIEW public.vw_comparativo_canonicas_genericas IS 'Comparativo de todas as marcas disponíveis para cada canônica genérica';

-- ====================
-- 5. View: Comparativo de Marcas por Canônica Premium
-- ====================
DROP VIEW IF EXISTS public.vw_comparativo_canonicas_premium CASCADE;
CREATE OR REPLACE VIEW public.vw_comparativo_canonicas_premium AS
SELECT 
  pc.id as canonica_id,
  pc.nome_canonico,
  pc.slug as canonica_slug,
  pc.tipo_lente,
  pc.nivel_premium,
  
  -- Informações da lente real
  l.id as lente_id,
  l.familia,
  l.design,
  l.indice_refracao,
  l.material,
  l.tratamentos,
  l.specs_tecnicas,
  
  -- Marca
  m.id as marca_id,
  m.nome as marca_nome,
  m.slug as marca_slug,
  m.pais_origem,
  
  -- Descrição
  CONCAT(m.nome, ' ', l.familia, ' ', l.design) as descricao_lente
  
FROM lens_catalog.premium_canonicas pc
INNER JOIN lens_catalog.lentes l ON l.familia ILIKE '%' || pc.nome_canonico || '%' AND l.ativo = true
INNER JOIN lens_catalog.marcas m ON l.marca_id = m.id
ORDER BY pc.nome_canonico, m.nome, l.indice_refracao;

COMMENT ON VIEW public.vw_comparativo_canonicas_premium IS 'Comparativo de todas as marcas disponíveis para cada canônica premium';

-- ====================
-- 6. View: Estatísticas do Catálogo
-- ====================
DROP VIEW IF EXISTS public.vw_stats_catalogo CASCADE;
CREATE OR REPLACE VIEW public.vw_stats_catalogo AS
SELECT 
  COUNT(*) as total_lentes,
  COUNT(DISTINCT marca_id) as total_marcas,
  COUNT(DISTINCT familia) as total_familias,
  COUNT(DISTINCT tipo_lente) as total_tipos,
  COUNT(CASE WHEN tipo_lente = 'monofocal' THEN 1 END) as total_monofocais,
  COUNT(CASE WHEN tipo_lente = 'progressiva' THEN 1 END) as total_progressivas,
  COUNT(CASE WHEN tipo_lente = 'bifocal' THEN 1 END) as total_bifocais,
  COUNT(CASE WHEN tipo_lente = 'ocupacional' THEN 1 END) as total_ocupacionais,
  MIN(indice_refracao) as indice_min,
  MAX(indice_refracao) as indice_max
FROM lens_catalog.lentes
WHERE ativo = true;

COMMENT ON VIEW public.vw_stats_catalogo IS 'Estatísticas gerais do catálogo de lentes';

-- ====================
-- Permissões
-- ====================
GRANT SELECT ON public.vw_lentes_catalogo TO anon, authenticated;
GRANT SELECT ON public.vw_canonicas_genericas TO anon, authenticated;
GRANT SELECT ON public.vw_canonicas_premium TO anon, authenticated;
GRANT SELECT ON public.vw_comparativo_canonicas_genericas TO anon, authenticated;
GRANT SELECT ON public.vw_comparativo_canonicas_premium TO anon, authenticated;
GRANT SELECT ON public.vw_stats_catalogo TO anon, authenticated;

-- ====================
-- Testes de Verificação
-- ====================
-- Para executar após criação das views:

-- 1. Verificar total de lentes no catálogo
-- SELECT * FROM public.vw_lentes_catalogo LIMIT 10;

-- 2. Verificar canônicas genéricas com stats
-- SELECT nome_canonico, total_lentes, total_marcas, marcas_disponiveis 
-- FROM public.vw_canonicas_genericas 
-- ORDER BY total_lentes DESC;

-- 3. Verificar canônicas premium com stats
-- SELECT nome_canonico, nivel_premium, total_lentes, total_marcas, marcas_disponiveis 
-- FROM public.vw_canonicas_premium 
-- ORDER BY total_lentes DESC;

-- 4. Comparar marcas de uma canônica específica
-- SELECT canonica_slug, marca_nome, COUNT(*) as total_variacoes
-- FROM public.vw_comparativo_canonicas_genericas
-- WHERE canonica_slug = 'transitions'
-- GROUP BY canonica_slug, marca_nome;

-- 5. Estatísticas gerais
-- SELECT * FROM public.vw_stats_catalogo;
