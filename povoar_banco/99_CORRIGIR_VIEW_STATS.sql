-- =====================================================
-- VIEW DE ESTATÍSTICAS COMPLETA PARA DASHBOARD
-- Busca diretamente nos schemas: lens_catalog e core
-- Inclui: totais, tratamentos, tipos, materiais, índices, faixas de preço
-- =====================================================

DROP VIEW IF EXISTS public.vw_stats_catalogo CASCADE;

CREATE OR REPLACE VIEW public.vw_stats_catalogo AS
SELECT
    -- =========================================
    -- TOTAIS GERAIS
    -- =========================================
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL) as total_lentes,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND grupo_canonico_id IS NOT NULL) as lentes_genericas,
    
    -- Por categoria (economica, intermediaria, premium, super_premium)
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND categoria = 'economica') as lentes_economicas,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND categoria = 'intermediaria') as lentes_intermediarias,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND categoria = 'premium') as lentes_premium,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND categoria = 'super_premium') as lentes_super_premium,
    
    -- Grupos canônicos
    (SELECT COUNT(*) FROM lens_catalog.grupos_canonicos WHERE ativo = true) as grupos_genericos,
    (SELECT COUNT(*) FROM lens_catalog.grupos_canonicos WHERE ativo = true AND is_premium = false) as grupos_standard,
    (SELECT COUNT(*) FROM lens_catalog.grupos_canonicos WHERE ativo = true AND is_premium = true) as grupos_premium,
    
    -- Marcas e Fornecedores
    (SELECT COUNT(*) FROM lens_catalog.marcas WHERE ativo = true) as total_marcas,
    (SELECT COUNT(*) FROM lens_catalog.marcas WHERE ativo = true AND is_premium = false) as marcas_standard,
    (SELECT COUNT(*) FROM lens_catalog.marcas WHERE ativo = true AND is_premium = true) as marcas_premium,
    (SELECT COUNT(*) FROM core.fornecedores WHERE ativo = true) as total_fornecedores,
    
    -- =========================================
    -- TRATAMENTOS E TECNOLOGIAS
    -- =========================================
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tratamento_antirreflexo = true) as total_com_ar,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tratamento_blue_light = true) as total_com_blue,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tratamento_fotossensiveis IS NOT NULL AND tratamento_fotossensiveis != 'nenhum') as total_fotossensiveis,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tratamento_uv = true) as total_uv400,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tratamento_antirrisco = true) as total_antirrisco,
    
    -- Tratamentos fotossensíveis detalhados
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tratamento_fotossensiveis = 'transitions') as total_transitions,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tratamento_fotossensiveis = 'fotocromático') as total_fotocromatico,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tratamento_fotossensiveis = 'polarizado') as total_polarizado,
    
    -- =========================================
    -- TIPOS DE LENTE (valores: visao_simples, multifocal, bifocal, leitura, ocupacional)
    -- =========================================
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tipo_lente = 'visao_simples') as total_visao_simples,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tipo_lente = 'multifocal') as total_multifocal,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tipo_lente = 'bifocal') as total_bifocal,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tipo_lente = 'leitura') as total_leitura,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND tipo_lente = 'ocupacional') as total_ocupacional,
    
    -- =========================================
    -- MATERIAIS (valores: CR39, POLICARBONATO, TRIVEX, HIGH_INDEX, VIDRO, ACRILICO)
    -- =========================================
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND material = 'CR39') as total_cr39,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND material = 'POLICARBONATO') as total_policarbonato,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND material = 'TRIVEX') as total_trivex,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND material = 'HIGH_INDEX') as total_high_index,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND material = 'VIDRO') as total_vidro,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND material = 'ACRILICO') as total_acrilico,
    
    -- =========================================
    -- ÍNDICES DE REFRAÇÃO (enum: '1.50', '1.56', '1.59', '1.61', '1.67', '1.74', '1.90')
    -- =========================================
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND indice_refracao = '1.50') as total_indice_150,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND indice_refracao = '1.56') as total_indice_156,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND indice_refracao = '1.59') as total_indice_159,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND indice_refracao = '1.61') as total_indice_161,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND indice_refracao = '1.67') as total_indice_167,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND indice_refracao = '1.74') as total_indice_174,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND indice_refracao = '1.90') as total_indice_190,
    
    -- =========================================
    -- FAIXAS DE PREÇO
    -- =========================================
    (SELECT MIN(preco_venda_sugerido) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL) as preco_minimo_catalogo,
    (SELECT MAX(preco_venda_sugerido) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL) as preco_maximo_catalogo,
    (SELECT ROUND(AVG(preco_venda_sugerido)::numeric, 2) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL) as preco_medio_catalogo,
    (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY preco_venda_sugerido) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL) as preco_mediano_catalogo,
    
    -- Faixas de preço (distribuição)
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND preco_venda_sugerido < 500) as faixa_economica,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND preco_venda_sugerido >= 500 AND preco_venda_sugerido < 1500) as faixa_intermediaria,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND preco_venda_sugerido >= 1500 AND preco_venda_sugerido < 3000) as faixa_premium,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE ativo = true AND deleted_at IS NULL AND preco_venda_sugerido >= 3000) as faixa_ultra_premium;

COMMENT ON VIEW public.vw_stats_catalogo IS 
'Estatísticas completas do catálogo para o dashboard. Busca diretamente nos schemas lens_catalog e core. Inclui totais, tratamentos, tipos, materiais, índices e faixas de preço.';

-- Permissões
GRANT SELECT ON public.vw_stats_catalogo TO anon, authenticated;
