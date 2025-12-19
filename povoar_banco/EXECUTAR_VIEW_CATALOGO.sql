-- ============================================
-- EXECUTAR ESTE SCRIPT NO SUPABASE SQL EDITOR
-- Garante que a view vw_lentes_catalogo existe
-- ============================================

-- Passo 1: Criar/Recriar a view (se não existir ou precisar atualizar)
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

-- Passo 2: Garantir permissões
GRANT SELECT ON public.vw_lentes_catalogo TO anon, authenticated;

-- Passo 3: Verificar se funcionou
SELECT 
  '✅ View criada com sucesso!' as resultado,
  COUNT(*) as total_lentes,
  COUNT(DISTINCT marca_nome) as total_marcas,
  ROUND(AVG(preco_tabela)::numeric, 2) as preco_medio
FROM public.vw_lentes_catalogo;


| resultado                  | total_lentes | total_marcas | preco_medio |
| -------------------------- | ------------ | ------------ | ----------- |
| ✅ View criada com sucesso! | 1411         | 6            | 3563.56     |

-- Passo 4: Ver algumas lentes de exemplo
SELECT 
  nome_comercial,
  marca_nome,
  categoria,
  tipo_lente,
  preco_tabela
FROM public.vw_lentes_catalogo
LIMIT 10;


| nome_comercial                                 | marca_nome | categoria     | tipo_lente    | preco_tabela |
| ---------------------------------------------- | ---------- | ------------- | ------------- | ------------ |
| SYGMA PRIME 1.67 PHOTO BLUECUT                 | EXPRESS    | premium       | visao_simples | 1867.50      |
| MULTI 1.49 FREEVIEW SILVER AR FAST SH          | SOBLOCOS   | premium       | visao_simples | 2136.00      |
| VS HDI 1.74 SLIM BLUE FILTER AR FAST AZUL      | SOBLOCOS   | super_premium | visao_simples | 6116.10      |
| LT 1.59 POLICARBONATO FOTO AR (RESIDUAL VERDE) | EXPRESS    | economica     | visao_simples | 120.00       |
| MULTI 1.49 TOP VIEW FF (AR FAST)               | SOBLOCOS   | intermediaria | multifocal    | 1222.00      |
| MULTI 1.59 FREEVIEW HD BLUE FILTER AR FAST     | SOBLOCOS   | premium       | visao_simples | 2653.50      |
| VS FREE FORM 1.67 AR FAST SH                   | SOBLOCOS   | super_premium | visao_simples | 4856.00      |
| MULTI 1.59 FREEVIEW GENESIS AR FAST            | SOBLOCOS   | super_premium | visao_simples | 3696.00      |
| MULTI 1.67 FREEVIEW HDI FOTO AR FAST TITANIUM  | SOBLOCOS   | super_premium | visao_simples | 5920.00      |
| FREEVIEW HDI 1.67 BLUE FILTER AR FAST TITANIUM | SOBLOCOS   | super_premium | visao_simples | 5395.00      |