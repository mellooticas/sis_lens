-- =====================================================
-- VIEW: vw_detalhes_genericas
-- Detalhes das lentes reais de cada lente canônica genérica
-- Similar à vw_detalhes_premium mas para lentes genéricas
-- =====================================================

DROP VIEW IF EXISTS public.vw_detalhes_genericas CASCADE;

CREATE OR REPLACE VIEW public.vw_detalhes_genericas AS
SELECT 
  lc.id as canonica_id,
  lc.nome_canonico,
  lc.tipo_lente as canonica_tipo_lente,
  lc.material as canonica_material,
  lc.indice_refracao as canonica_indice,
  lc.categoria as canonica_categoria,
  
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
  
  -- Tecnologias
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

FROM lens_catalog.lentes_canonicas lc
INNER JOIN lens_catalog.lentes l ON l.lente_canonica_id = lc.id
INNER JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE lc.ativo = true 
  AND l.status = 'ativo'
  AND l.disponivel = true
ORDER BY lc.nome_canonico, m.nome, l.preco_tabela;

COMMENT ON VIEW public.vw_detalhes_genericas IS 'Detalhes das lentes reais de cada lente canônica genérica - usar com WHERE canonica_id = $1';

-- Permissões
GRANT SELECT ON public.vw_detalhes_genericas TO anon, authenticated;

-- Verificação
SELECT 
  canonica_id,
  nome_canonico,
  COUNT(*) as total_lentes,
  COUNT(DISTINCT marca_nome) as total_marcas,
  MIN(preco_tabela) as preco_min,
  AVG(preco_tabela) as preco_medio,
  MAX(preco_tabela) as preco_max
FROM public.vw_detalhes_genericas
GROUP BY canonica_id, nome_canonico
ORDER BY total_lentes DESC
LIMIT 10;
