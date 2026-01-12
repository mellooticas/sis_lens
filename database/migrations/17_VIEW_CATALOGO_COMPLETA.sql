-- ============================================
-- VIEW CATÁLOGO COMPLETA
-- Substitui vw_lentes_catalogo com dados mais completos
-- Inclui: estoque, prazos, grupo canônico, margem
-- ============================================

DROP VIEW IF EXISTS public.v_lentes_catalogo CASCADE;

CREATE OR REPLACE VIEW public.v_lentes_catalogo AS
SELECT
  -- IDs principais
  l.id,
  l.slug,
  l.nome_lente,
  l.nome_canonizado,
  
  -- Fornecedor
  f.id as fornecedor_id,
  f.nome as fornecedor_nome,
  f.prazo_visao_simples,
  f.prazo_multifocal,
  f.prazo_surfacada,
  f.prazo_free_form,
  
  -- Marca
  m.id as marca_id,
  m.nome as marca_nome,
  m.slug as marca_slug,
  m.is_premium as marca_premium,
  
  -- Grupo Canônico
  gc.id as grupo_id,
  gc.nome_grupo,
  gc.slug as grupo_slug,
  
  -- Características técnicas
  l.tipo_lente,
  l.material,
  l.indice_refracao,
  l.categoria,
  
  -- Tratamentos (mapeamento correto)
  l.tratamento_antirreflexo as ar,
  l.tratamento_antirrisco as antirrisco,
  l.tratamento_uv as uv400,
  l.tratamento_blue_light as blue,
  l.tratamento_fotossensiveis as fotossensivel,
  
  -- Especificações ópticas
  l.diametro_mm as diametro,
  l.curva_base,
  l.espessura_centro_mm as espessura_central,
  l.grau_esferico_min as esferico_min,
  l.grau_esferico_max as esferico_max,
  l.grau_cilindrico_min as cilindrico_min,
  l.grau_cilindrico_max as cilindrico_max,
  l.adicao_min,
  l.adicao_max,
  
  -- Preços
  l.preco_custo as custo_base,
  l.preco_venda_sugerido as preco_tabela,
  l.preco_venda_sugerido, -- Mantém campo original também
  l.margem_lucro,
  
  -- Estoque em tempo real
  COALESCE(es.quantidade_disponivel, 0) as estoque_disponivel,
  COALESCE(es.quantidade_reservada, 0) as estoque_reservado,
  
  -- Status e controle
  l.status,
  l.ativo,
  l.peso,
  l.metadata,
  l.created_at,
  l.updated_at
  
FROM lens_catalog.lentes l
JOIN core.fornecedores f ON l.fornecedor_id = f.id
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
LEFT JOIN lens_catalog.grupos_canonicos gc ON l.grupo_canonico_id = gc.id
LEFT JOIN compras.estoque_saldo es ON l.id = es.lente_id
WHERE l.ativo = true
  AND l.deleted_at IS NULL
ORDER BY l.peso DESC, l.preco_venda_sugerido;

COMMENT ON VIEW public.v_lentes_catalogo IS 
'View completa do catálogo com estoque, prazos, grupo canônico e margem de lucro';

-- Grant permissions
GRANT SELECT ON public.v_lentes_catalogo TO anon, authenticated;
