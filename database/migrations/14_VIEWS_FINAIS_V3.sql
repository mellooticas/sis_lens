-- ============================================
-- VIEWS PÚBLICAS - CATÁLOGO DE LENTES v3
-- Estrutura CORRETA baseada na arquitetura real
-- ============================================

-- ====================
-- 1. View: Catálogo Completo (BUSCAR LENTES)
-- Para o módulo "Buscar Lentes" - todas as 1.411 lentes
-- ====================
DROP VIEW IF EXISTS public.vw_lentes_catalogo CASCADE;
CREATE OR REPLACE VIEW public.vw_lentes_catalogo AS
SELECT 
  -- IDs
  l.id,
  l.marca_id,
  l.fornecedor_id,
  l.lente_canonica_id,
  l.premium_canonica_id,
  
  -- Códigos e Nomes
  l.sku_fornecedor,
  l.codigo_original,
  l.nome_comercial,
  
  -- Marca
  m.nome as marca_nome,
  m.slug as marca_slug,
  m.is_premium as marca_premium,
  
  -- Características Técnicas
  l.tipo_lente,
  l.categoria,
  l.material,
  l.indice_refracao,
  l.linha_produto,
  
  -- Especificações Ópticas
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
  
  -- Tratamentos
  l.ar,
  l.antirrisco,
  l.hidrofobico,
  l.antiembaçante,
  l.blue,
  l.uv400,
  l.fotossensivel,
  l.polarizado,
  
  -- Tecnologias
  l.digital,
  l.free_form,
  l.indoor,
  l.drive,
  
  -- Preços
  l.custo_base,
  l.preco_fabricante,
  l.preco_tabela,
  
  -- Logística
  l.prazo_entrega,
  l.obs_prazo,
  l.peso_frete,
  l.exige_receita_especial,
  
  -- Descrições
  l.descricao_curta,
  l.descricao_completa,
  l.beneficios,
  l.indicacoes,
  l.contraindicacoes,
  l.observacoes,
  
  -- Status
  l.status,
  l.disponivel,
  l.destaque,
  l.novidade,
  l.data_lancamento,
  l.data_descontinuacao,
  
  -- Metadata
  l.created_at,
  l.updated_at

FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE l.status = 'ativo'
ORDER BY l.created_at DESC;

COMMENT ON VIEW public.vw_lentes_catalogo IS 'Catálogo completo de lentes para módulo Buscar Lentes (1.411 lentes)';

-- ====================
-- 2. View: Catálogo de Canônicas (MÓDULO CATÁLOGO)
-- Para o módulo "Catálogo" - 187 lentes normalizadas
-- ====================
DROP VIEW IF EXISTS public.vw_canonicas_genericas CASCADE;
CREATE OR REPLACE VIEW public.vw_canonicas_genericas AS
SELECT 
  lc.id,
  lc.nome_canonico,
  lc.descricao,
  lc.tipo_lente,
  lc.material,
  lc.indice_refracao,
  lc.categoria,
  
  -- Características Técnicas
  lc.ar,
  lc.blue,
  lc.fotossensivel,
  lc.polarizado,
  
  -- Faixas Ópticas
  lc.esferico_min,
  lc.esferico_max,
  lc.cilindrico_min,
  lc.cilindrico_max,
  lc.adicao_min,
  lc.adicao_max,
  
  -- Estatísticas (já calculadas na tabela)
  lc.total_lentes,
  lc.preco_minimo,
  lc.preco_maximo,
  lc.preco_medio,
  
  -- Agregações adicionais de lentes associadas via premium_canonica
  COUNT(l.id) as lentes_ativas,
  COUNT(DISTINCT l.marca_id) as total_marcas,
  array_agg(DISTINCT m.nome ORDER BY m.nome) FILTER (WHERE m.nome IS NOT NULL) as marcas_disponiveis,
  
  -- Metadata
  lc.ativo,
  lc.created_at,
  lc.updated_at

FROM lens_catalog.lentes_canonicas lc
LEFT JOIN lens_catalog.lentes l ON l.lente_canonica_id = lc.id AND l.status = 'ativo'
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE lc.ativo = true
GROUP BY lc.id, lc.nome_canonico, lc.descricao, lc.tipo_lente, lc.material,
         lc.indice_refracao, lc.categoria, lc.ar, lc.blue, lc.fotossensivel,
         lc.polarizado, lc.esferico_min, lc.esferico_max, lc.cilindrico_min,
         lc.cilindrico_max, lc.adicao_min, lc.adicao_max, lc.total_lentes,
         lc.preco_minimo, lc.preco_maximo, lc.preco_medio, lc.ativo,
         lc.created_at, lc.updated_at
ORDER BY lc.nome_canonico;

COMMENT ON VIEW public.vw_canonicas_genericas IS 'Lentes canônicas genéricas para módulo Catálogo (187 grupos)';

-- ====================
-- 3. View: Catálogo Premium (MÓDULO PREMIUM)
-- Para o módulo "Premium" - 250 lentes premium
-- ====================
DROP VIEW IF EXISTS public.vw_canonicas_premium CASCADE;
CREATE OR REPLACE VIEW public.vw_canonicas_premium AS
SELECT 
  pc.id,
  pc.marca_id,
  pc.linha_produto,
  pc.nome_canonico,
  pc.descricao,
  pc.tipo_lente,
  pc.material,
  pc.indice_refracao,
  pc.categoria,
  
  -- Marca
  m.nome as marca_nome,
  m.slug as marca_slug,
  m.is_premium as marca_premium,
  
  -- Características Técnicas
  pc.ar,
  pc.blue,
  pc.fotossensivel,
  pc.polarizado,
  
  -- Faixas Ópticas
  pc.esferico_min,
  pc.esferico_max,
  pc.cilindrico_min,
  pc.cilindrico_max,
  pc.adicao_min,
  pc.adicao_max,
  
  -- Estatísticas (já calculadas na tabela)
  pc.total_lentes,
  pc.preco_minimo,
  pc.preco_maximo,
  pc.preco_medio,
  
  -- Agregações adicionais de lentes associadas
  COUNT(l.id) as lentes_ativas,
  
  -- Metadata
  pc.ativo,
  pc.created_at,
  pc.updated_at

FROM lens_catalog.premium_canonicas pc
LEFT JOIN lens_catalog.marcas m ON pc.marca_id = m.id
LEFT JOIN lens_catalog.lentes l ON l.premium_canonica_id = pc.id AND l.status = 'ativo'
WHERE pc.ativo = true
GROUP BY pc.id, pc.marca_id, pc.linha_produto, pc.nome_canonico, pc.descricao,
         pc.tipo_lente, pc.material, pc.indice_refracao, pc.categoria,
         m.nome, m.slug, m.is_premium, pc.ar, pc.blue, pc.fotossensivel,
         pc.polarizado, pc.esferico_min, pc.esferico_max, pc.cilindrico_min,
         pc.cilindrico_max, pc.adicao_min, pc.adicao_max, pc.total_lentes,
         pc.preco_minimo, pc.preco_maximo, pc.preco_medio, pc.ativo,
         pc.created_at, pc.updated_at
ORDER BY m.nome, pc.nome_canonico;

COMMENT ON VIEW public.vw_canonicas_premium IS 'Lentes premium canônicas para módulo Premium (250 grupos)';

-- ====================
-- 4. View: Detalhes/Comparativo Premium (BOTÃO DETALHES)
-- Retorna todas as lentes reais de uma premium_canonica específica
-- Usar com WHERE canonica_id = $1 no frontend
-- ====================
DROP VIEW IF EXISTS public.vw_detalhes_premium CASCADE;
CREATE OR REPLACE VIEW public.vw_detalhes_premium AS
SELECT 
  pc.id as canonica_id,
  pc.nome_canonico,
  pc.linha_produto as canonica_linha,
  pc.tipo_lente as canonica_tipo_lente,
  pc.material as canonica_material,
  pc.indice_refracao as canonica_indice,
  
  -- Informações da lente real
  l.id as lente_id,
  l.sku_fornecedor,
  l.codigo_original,
  l.nome_comercial,
  l.linha_produto,
  l.categoria,
  l.material,
  l.indice_refracao,
  
  -- Marca (laboratório)
  m.id as marca_id,
  m.nome as marca_nome,
  m.slug as marca_slug,
  m.is_premium as marca_premium,
  
  -- Tratamentos
  l.ar,
  l.antirrisco,
  l.hidrofobico,
  l.antiembaçante,
  l.blue,
  l.uv400,
  l.fotossensivel,
  l.polarizado,
  
  -- Tecnologias Premium
  l.digital,
  l.free_form,
  l.indoor,
  l.drive,
  
  -- Especificações Ópticas
  l.esferico_min,
  l.esferico_max,
  l.cilindrico_min,
  l.cilindrico_max,
  l.adicao_min,
  l.adicao_max,
  l.diametro,
  l.espessura_central,
  
  -- Preços
  l.custo_base,
  l.preco_tabela,
  l.preco_fabricante,
  
  -- Logística
  l.disponivel,
  l.prazo_entrega,
  l.obs_prazo,
  
  -- Status
  l.destaque,
  l.novidade,
  
  -- Descrições
  l.descricao_curta,
  l.beneficios

FROM lens_catalog.premium_canonicas pc
INNER JOIN lens_catalog.lentes l ON l.premium_canonica_id = pc.id
INNER JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE pc.ativo = true 
  AND l.status = 'ativo'
  AND l.disponivel = true
ORDER BY pc.nome_canonico, m.nome, l.preco_tabela;

COMMENT ON VIEW public.vw_detalhes_premium IS 'Detalhes das lentes reais de cada premium canônica - usar com WHERE canonica_id = $1';

-- ====================
-- 5. View: Estatísticas do Catálogo
-- ====================
DROP VIEW IF EXISTS public.vw_stats_catalogo CASCADE;
CREATE OR REPLACE VIEW public.vw_stats_catalogo AS
SELECT 
  -- Totais Gerais
  COUNT(*) as total_lentes,
  COUNT(DISTINCT marca_id) as total_marcas,
  COUNT(DISTINCT tipo_lente) as total_tipos,
  
  -- Por Categoria
  COUNT(*) FILTER (WHERE categoria = 'economica') as total_economicas,
  COUNT(*) FILTER (WHERE categoria = 'intermediaria') as total_intermediarias,
  COUNT(*) FILTER (WHERE categoria = 'premium') as total_premium,
  COUNT(*) FILTER (WHERE categoria = 'super_premium') as total_super_premium,
  
  -- Por Tipo
  COUNT(*) FILTER (WHERE tipo_lente = 'visao_simples') as total_visao_simples,
  COUNT(*) FILTER (WHERE tipo_lente = 'multifocal') as total_multifocal,
  COUNT(*) FILTER (WHERE tipo_lente = 'bifocal') as total_bifocal,
  COUNT(*) FILTER (WHERE tipo_lente = 'leitura') as total_leitura,
  COUNT(*) FILTER (WHERE tipo_lente = 'ocupacional') as total_ocupacional,
  
  -- Por Material
  COUNT(*) FILTER (WHERE material = 'CR39') as total_cr39,
  COUNT(*) FILTER (WHERE material = 'POLICARBONATO') as total_policarbonato,
  COUNT(*) FILTER (WHERE material = 'TRIVEX') as total_trivex,
  COUNT(*) FILTER (WHERE material = 'HIGH_INDEX') as total_high_index,
  COUNT(*) FILTER (WHERE material = 'VIDRO') as total_vidro,
  COUNT(*) FILTER (WHERE material = 'ACRILICO') as total_acrilico,
  
  -- Tratamentos
  COUNT(*) FILTER (WHERE ar = true) as total_com_ar,
  COUNT(*) FILTER (WHERE blue = true) as total_com_blue,
  COUNT(*) FILTER (WHERE fotossensivel != 'nenhum') as total_fotossensiveis,
  COUNT(*) FILTER (WHERE polarizado = true) as total_polarizados,
  COUNT(*) FILTER (WHERE digital = true) as total_digitais,
  COUNT(*) FILTER (WHERE free_form = true) as total_free_form,
  
  -- Preços
  MIN(preco_tabela) as preco_minimo,
  MAX(preco_tabela) as preco_maximo,
  AVG(preco_tabela)::numeric(10,2) as preco_medio,
  
  -- Status
  COUNT(*) FILTER (WHERE disponivel = true) as total_disponiveis,
  COUNT(*) FILTER (WHERE destaque = true) as total_destaques,
  COUNT(*) FILTER (WHERE novidade = true) as total_novidades

FROM lens_catalog.lentes
WHERE status = 'ativo';

COMMENT ON VIEW public.vw_stats_catalogo IS 'Estatísticas gerais do catálogo de lentes';

-- ====================
-- 6. PERMISSÕES - Garantir acesso público às views
-- ====================
GRANT SELECT ON public.vw_lentes_catalogo TO anon, authenticated;
GRANT SELECT ON public.vw_canonicas_genericas TO anon, authenticated;
GRANT SELECT ON public.vw_canonicas_premium TO anon, authenticated;
GRANT SELECT ON public.vw_detalhes_premium TO anon, authenticated;
GRANT SELECT ON public.vw_stats_catalogo TO anon, authenticated;

-- ====================
-- FIM DO SCRIPT
-- ====================
