-- =====================================================
-- VIEW DE ESTATÍSTICAS PARA DASHBOARD
-- Usa as views existentes (v_lentes_catalogo, v_grupos_canonicos, v_grupos_premium)
-- ao invés de queries complexas
-- =====================================================

DROP VIEW IF EXISTS public.vw_stats_catalogo CASCADE;

CREATE OR REPLACE VIEW public.vw_stats_catalogo AS
SELECT
    -- Lentes do catálogo
    (SELECT COUNT(*) FROM public.v_lentes_catalogo) as total_lentes,
    (SELECT COUNT(*) FROM public.v_lentes_catalogo WHERE grupo_canonico_id IS NOT NULL) as lentes_genericas,
    (SELECT COUNT(*) FROM public.v_lentes_catalogo WHERE is_premium = true) as lentes_premium,
    
    -- Grupos canônicos (standard)
    (SELECT COUNT(*) FROM public.v_grupos_canonicos) as grupos_genericos,
    (SELECT COUNT(*) FROM public.v_grupos_canonicos WHERE is_premium = true) as grupos_premium_standard,
    
    -- Grupos premium
    (SELECT COUNT(*) FROM public.v_grupos_premium) as grupos_premium,
    
    -- Marcas
    (SELECT COUNT(DISTINCT marca_id) FROM public.v_lentes_catalogo) as total_marcas,
    (SELECT COUNT(DISTINCT marca_id) FROM public.v_lentes_catalogo WHERE is_premium = true) as marcas_premium,
    
    -- Fornecedores
    (SELECT COUNT(DISTINCT fornecedor_id) FROM public.v_lentes_catalogo) as total_fornecedores,
    
    -- Faixas de preço
    (SELECT MIN(preco_venda_sugerido) FROM public.v_lentes_catalogo) as preco_minimo_catalogo,
    (SELECT MAX(preco_venda_sugerido) FROM public.v_lentes_catalogo) as preco_maximo_catalogo,
    (SELECT AVG(preco_venda_sugerido) FROM public.v_lentes_catalogo) as preco_medio_catalogo;

COMMENT ON VIEW public.vw_stats_catalogo IS 
'View de estatísticas agregadas do catálogo para o dashboard. Usa as views públicas existentes (v_lentes_catalogo, v_grupos_canonicos, v_grupos_premium).';

-- Permissões
GRANT SELECT ON public.vw_stats_catalogo TO anon, authenticated;

-- Teste
SELECT * FROM public.vw_stats_catalogo;
