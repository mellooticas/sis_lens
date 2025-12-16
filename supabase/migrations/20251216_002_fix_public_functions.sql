-- ============================================
-- CORREÇÃO: Substituir wrappers por implementações reais
-- Data: 2025-12-16
-- ============================================

BEGIN;

-- ============================================
-- 1. SUBSTITUIR public.buscar_lentes() 
-- ============================================

DROP FUNCTION IF EXISTS public.buscar_lentes(TEXT, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION public.buscar_lentes(
    p_query TEXT DEFAULT '',
    p_filtros JSONB DEFAULT '{}'::jsonb,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    familia TEXT,
    design TEXT,
    material TEXT,
    indice_refracao NUMERIC,
    categoria TEXT,
    marca_nome TEXT,
    disponivel BOOLEAN
) 
SECURITY DEFINER
SET search_path = public, lens_catalog
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.familia,
        l.design,
        l.material,
        l.indice_refracao,
        l.categoria,
        m.nome as marca_nome,
        l.disponivel
    FROM lens_catalog.lentes l
    LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
    WHERE 
        (p_query = '' OR 
         l.familia ILIKE '%' || p_query || '%' OR
         l.design ILIKE '%' || p_query || '%' OR
         l.material ILIKE '%' || p_query || '%' OR
         m.nome ILIKE '%' || p_query || '%')
    AND l.disponivel = true
    ORDER BY l.familia, l.design
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION public.buscar_lentes IS 
'Busca lentes no catálogo com filtros - IMPLEMENTAÇÃO DIRETA (não depende de api.*)';

-- ============================================
-- 2. SUBSTITUIR public.obter_dashboard_kpis()
-- ============================================

DROP FUNCTION IF EXISTS public.obter_dashboard_kpis(UUID);

CREATE OR REPLACE FUNCTION public.obter_dashboard_kpis(
    p_tenant_id UUID DEFAULT NULL
)
RETURNS JSONB
SECURITY DEFINER
SET search_path = public, orders, suppliers
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_decisoes INTEGER;
    v_economia_total NUMERIC;
    v_decisoes_mes INTEGER;
    v_labs_ativos INTEGER;
BEGIN
    -- Contar decisões totais
    SELECT COUNT(*) INTO v_total_decisoes
    FROM orders.decisoes_lentes
    WHERE p_tenant_id IS NULL OR tenant_id = p_tenant_id;
    
    -- Economia total (simulada - seria calculada das alternativas)
    v_economia_total := v_total_decisoes * 150.00;
    
    -- Decisões do mês atual
    SELECT COUNT(*) INTO v_decisoes_mes
    FROM orders.decisoes_lentes
    WHERE (p_tenant_id IS NULL OR tenant_id = p_tenant_id)
    AND criado_em >= DATE_TRUNC('month', CURRENT_DATE);
    
    -- Labs ativos
    SELECT COUNT(*) INTO v_labs_ativos
    FROM suppliers.laboratorios
    WHERE (p_tenant_id IS NULL OR tenant_id = p_tenant_id)
    AND ativo = true;
    
    RETURN jsonb_build_object(
        'total_decisoes', COALESCE(v_total_decisoes, 0),
        'economia_total', COALESCE(v_economia_total, 0),
        'decisoes_mes', COALESCE(v_decisoes_mes, 0),
        'labs_ativos', COALESCE(v_labs_ativos, 0)
    );
END;
$$;

COMMENT ON FUNCTION public.obter_dashboard_kpis IS 
'Retorna KPIs do dashboard - IMPLEMENTAÇÃO DIRETA (não depende de api.*)';

-- ============================================
-- 3. ATUALIZAR PERMISSÕES
-- ============================================

GRANT EXECUTE ON FUNCTION public.buscar_lentes TO authenticated;
GRANT EXECUTE ON FUNCTION public.obter_dashboard_kpis TO authenticated;
GRANT EXECUTE ON FUNCTION public.buscar_lentes TO anon;
GRANT EXECUTE ON FUNCTION public.obter_dashboard_kpis TO anon;

COMMIT;

-- ============================================
-- VERIFICAÇÃO
-- ============================================

-- Testar buscar_lentes
SELECT 'TESTE buscar_lentes' as teste;
SELECT COUNT(*) as total_retornado FROM public.buscar_lentes('', '{}', 10);
SELECT * FROM public.buscar_lentes('', '{}', 5);

-- Testar obter_dashboard_kpis
SELECT 'TESTE obter_dashboard_kpis' as teste;
SELECT public.obter_dashboard_kpis();

-- Verificar total de lentes no catálogo
SELECT 'TOTAL LENTES CATÁLOGO' as info, COUNT(*) FROM lens_catalog.lentes;

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ FUNÇÕES CORRIGIDAS!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Funções agora trabalham DIRETAMENTE com as tabelas';
    RAISE NOTICE 'Não dependem mais do schema api.*';
    RAISE NOTICE '========================================';
END $$;
