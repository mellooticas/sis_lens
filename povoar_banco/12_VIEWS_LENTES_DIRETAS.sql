-- ============================================
-- 12_VIEWS_LENTES_DIRETAS.sql
-- Views públicas para acessar lentes reais e canônicas
-- ============================================

-- ====================
-- 1. View: Lentes Genéricas (não canônicas)
-- ====================
CREATE OR REPLACE VIEW public.vw_lentes_genericas AS
SELECT 
  l.id,
  l.sku_original,
  l.familia,
  l.nome_comercial,
  
  -- Marca
  m.nome as marca_nome,
  m.slug as marca_slug,
  m.is_premium as marca_is_premium,
  
  -- Fornecedor
  f.nome as fornecedor_nome,
  f.id as fornecedor_id,
  
  -- Características
  l.tipo_lente,
  l.material,
  l.indice_refracao,
  l.categoria,
  
  -- Tratamentos
  l.ar,
  l.blue,
  l.fotossensivel,
  l.polarizado,
  
  -- Faixas Ópticas
  l.esferico_min,
  l.esferico_max,
  l.cilindrico_min,
  l.cilindrico_max,
  l.adicao_min,
  l.adicao_max,
  
  -- Preços
  l.preco_tabela,
  l.custo_base,
  l.desconto_padrao,
  
  -- Referência canônica
  l.lente_canonica_id,
  lc.nome_canonico as grupo_canonico,
  
  -- Metadata
  l.ativo,
  l.created_at,
  l.updated_at
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
LEFT JOIN pessoas.fornecedores f ON l.fornecedor_id = f.id
LEFT JOIN lens_catalog.lentes_canonicas lc ON l.lente_canonica_id = lc.id
WHERE l.is_premium = false
  AND l.ativo = true
ORDER BY l.familia, l.preco_tabela;

-- ====================
-- 2. View: Lentes Premium (não canônicas)
-- ====================
CREATE OR REPLACE VIEW public.vw_lentes_premium AS
SELECT 
  l.id,
  l.sku_original,
  l.familia,
  l.nome_comercial,
  
  -- Marca
  m.nome as marca_nome,
  m.slug as marca_slug,
  m.is_premium as marca_is_premium,
  
  -- Fornecedor
  f.nome as fornecedor_nome,
  f.id as fornecedor_id,
  
  -- Características
  l.tipo_lente,
  l.material,
  l.indice_refracao,
  l.categoria,
  
  -- Tratamentos
  l.ar,
  l.blue,
  l.fotossensivel,
  l.polarizado,
  
  -- Faixas Ópticas
  l.esferico_min,
  l.esferico_max,
  l.cilindrico_min,
  l.cilindrico_max,
  l.adicao_min,
  l.adicao_max,
  
  -- Preços
  l.preco_tabela,
  l.custo_base,
  l.desconto_padrao,
  
  -- Referência canônica
  l.premium_canonica_id,
  pc.nome_canonico as grupo_canonico,
  
  -- Metadata
  l.ativo,
  l.created_at,
  l.updated_at
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
LEFT JOIN pessoas.fornecedores f ON l.fornecedor_id = f.id
LEFT JOIN lens_catalog.premium_canonicas pc ON l.premium_canonica_id = pc.id
WHERE l.is_premium = true
  AND l.ativo = true
ORDER BY m.nome, l.familia, l.preco_tabela;

-- ====================
-- 3. View: Lista de Canônicas Genéricas
-- ====================
CREATE OR REPLACE VIEW public.vw_lista_canonicas_genericas AS
SELECT 
  lc.id,
  lc.nome_canonico,
  
  -- Características
  lc.tipo_lente,
  lc.material,
  lc.indice_refracao,
  lc.categoria,
  
  -- Tratamentos
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
  
  -- Estatísticas (contar lentes ligadas)
  COUNT(l.id) as total_lentes_disponiveis,
  COUNT(DISTINCT l.fornecedor_id) as total_fornecedores,
  MIN(l.preco_tabela) as preco_minimo,
  MAX(l.preco_tabela) as preco_maximo,
  AVG(l.preco_tabela) as preco_medio,
  
  -- Metadata
  lc.ativo,
  lc.created_at
FROM lens_catalog.lentes_canonicas lc
LEFT JOIN lens_catalog.lentes l ON lc.id = l.lente_canonica_id AND l.ativo = true
WHERE lc.ativo = true
GROUP BY lc.id, lc.nome_canonico, lc.tipo_lente, lc.material, lc.indice_refracao, 
         lc.categoria, lc.ar, lc.blue, lc.fotossensivel, lc.polarizado,
         lc.esferico_min, lc.esferico_max, lc.cilindrico_min, lc.cilindrico_max,
         lc.adicao_min, lc.adicao_max, lc.ativo, lc.created_at
ORDER BY lc.nome_canonico;

-- ====================
-- 4. View: Lista de Canônicas Premium
-- ====================
CREATE OR REPLACE VIEW public.vw_lista_canonicas_premium AS
SELECT 
  pc.id,
  pc.nome_canonico,
  
  -- Marca
  m.nome as marca_nome,
  m.slug as marca_slug,
  
  -- Características
  pc.tipo_lente,
  pc.material,
  pc.indice_refracao,
  pc.categoria,
  
  -- Tratamentos
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
  
  -- Estatísticas (contar lentes ligadas)
  COUNT(l.id) as total_lentes_disponiveis,
  COUNT(DISTINCT l.fornecedor_id) as total_fornecedores,
  MIN(l.preco_tabela) as preco_minimo,
  MAX(l.preco_tabela) as preco_maximo,
  AVG(l.preco_tabela) as preco_medio,
  
  -- Metadata
  pc.ativo,
  pc.created_at
FROM lens_catalog.premium_canonicas pc
LEFT JOIN lens_catalog.marcas m ON pc.marca_id = m.id
LEFT JOIN lens_catalog.lentes l ON pc.id = l.premium_canonica_id AND l.ativo = true
WHERE pc.ativo = true
GROUP BY pc.id, pc.nome_canonico, m.nome, m.slug, pc.tipo_lente, pc.material, 
         pc.indice_refracao, pc.categoria, pc.ar, pc.blue, pc.fotossensivel, 
         pc.polarizado, pc.esferico_min, pc.esferico_max, pc.cilindrico_min, 
         pc.cilindrico_max, pc.adicao_min, pc.adicao_max, pc.ativo, pc.created_at
ORDER BY m.nome, pc.nome_canonico;

-- ====================
-- 5. View: Comparativo de Lentes por Canônica
-- ====================
CREATE OR REPLACE VIEW public.vw_comparativo_canonica AS
SELECT 
  -- Tipo de canônica
  CASE 
    WHEN l.lente_canonica_id IS NOT NULL THEN 'GENERICA'
    WHEN l.premium_canonica_id IS NOT NULL THEN 'PREMIUM'
  END as tipo_canonica,
  
  -- ID da canônica
  COALESCE(l.lente_canonica_id::text, l.premium_canonica_id::text) as canonica_id,
  
  -- Nome canônico
  COALESCE(lc.nome_canonico, pc.nome_canonico) as nome_canonico,
  
  -- Lente real
  l.id as lente_id,
  l.sku_original,
  l.familia,
  l.nome_comercial,
  
  -- Fornecedor e Marca
  f.nome as fornecedor_nome,
  f.id as fornecedor_id,
  m.nome as marca_nome,
  
  -- Preços
  l.preco_tabela,
  l.custo_base,
  l.desconto_padrao,
  
  -- Economia vs média do grupo
  l.preco_tabela - AVG(l.preco_tabela) OVER (
    PARTITION BY COALESCE(l.lente_canonica_id, l.premium_canonica_id)
  ) as diferenca_vs_media,
  
  -- Ranking de preço dentro do grupo
  RANK() OVER (
    PARTITION BY COALESCE(l.lente_canonica_id, l.premium_canonica_id)
    ORDER BY l.preco_tabela
  ) as ranking_preco
  
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.lentes_canonicas lc ON l.lente_canonica_id = lc.id
LEFT JOIN lens_catalog.premium_canonicas pc ON l.premium_canonica_id = pc.id
LEFT JOIN pessoas.fornecedores f ON l.fornecedor_id = f.id
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE l.ativo = true
  AND (lc.ativo = true OR pc.ativo = true OR (lc.id IS NULL AND pc.id IS NULL))
ORDER BY canonica_id, l.preco_tabela;

-- ====================
-- Permissões
-- ====================
GRANT SELECT ON public.vw_lentes_genericas TO anon, authenticated;
GRANT SELECT ON public.vw_lentes_premium TO anon, authenticated;
GRANT SELECT ON public.vw_lista_canonicas_genericas TO anon, authenticated;
GRANT SELECT ON public.vw_lista_canonicas_premium TO anon, authenticated;
GRANT SELECT ON public.vw_comparativo_canonica TO anon, authenticated;

-- ====================
-- Verificação
-- ====================
SELECT 'vw_lentes_genericas' as view_name, COUNT(*) as total FROM public.vw_lentes_genericas
UNION ALL
SELECT 'vw_lentes_premium', COUNT(*) FROM public.vw_lentes_premium
UNION ALL
SELECT 'vw_lista_canonicas_genericas', COUNT(*) FROM public.vw_lista_canonicas_genericas
UNION ALL
SELECT 'vw_lista_canonicas_premium', COUNT(*) FROM public.vw_lista_canonicas_premium
UNION ALL
SELECT 'vw_comparativo_canonica', COUNT(*) FROM public.vw_comparativo_canonica;
