-- ============================================
-- Função buscar_lentes_por_receita 
-- Padrão: Igual a public.buscar_lentes (já funciona)
-- ============================================

-- Remove função antiga se existir
DROP FUNCTION IF EXISTS public.buscar_lentes_por_receita(NUMERIC, NUMERIC, NUMERIC, TEXT);

-- Cria função com acesso direto ao schema (padrão buscar_lentes)
CREATE OR REPLACE FUNCTION public.buscar_lentes_por_receita(
    p_esferico NUMERIC,
    p_cilindrico NUMERIC,
    p_adicao NUMERIC DEFAULT NULL,
    p_tipo_lente TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    nome_comercial TEXT,
    tipo_lente TEXT,
    categoria TEXT,
    material TEXT,
    indice_refracao TEXT,
    preco_tabela NUMERIC,
    marca_nome TEXT,
    marca_premium BOOLEAN,
    ar BOOLEAN,
    blue BOOLEAN,
    fotossensivel TEXT,
    uv400 BOOLEAN,
    esferico_min NUMERIC,
    esferico_max NUMERIC,
    cilindrico_min NUMERIC,
    cilindrico_max NUMERIC,
    adicao_min NUMERIC,
    adicao_max NUMERIC
)
SECURITY DEFINER
SET search_path = public, lens_catalog
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.nome_comercial,
        l.tipo_lente::TEXT,
        l.categoria::TEXT,
        l.material::TEXT,
        l.indice_refracao::TEXT,
        l.preco_tabela,
        m.nome::TEXT as marca_nome,
        m.is_premium as marca_premium,
        l.ar,
        l.blue,
        l.fotossensivel::TEXT,
        l.uv400,
        l.esferico_min,
        l.esferico_max,
        l.cilindrico_min,
        l.cilindrico_max,
        l.adicao_min,
        l.adicao_max
    FROM lens_catalog.lentes l
    LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
    WHERE 
        -- Validação do esférico
        (l.esferico_min IS NULL OR p_esferico >= l.esferico_min)
        AND (l.esferico_max IS NULL OR p_esferico <= l.esferico_max)
        
        -- Validação do cilíndrico
        AND (l.cilindrico_min IS NULL OR p_cilindrico >= l.cilindrico_min)
        AND (l.cilindrico_max IS NULL OR p_cilindrico <= l.cilindrico_max)
        
        -- Validação da adição (apenas para multifocal/bifocal)
        AND (
            p_adicao IS NULL 
            OR l.tipo_lente::TEXT = 'visao_simples'
            OR (l.adicao_min IS NOT NULL AND p_adicao >= l.adicao_min AND p_adicao <= l.adicao_max)
        )
        
        -- Validação do tipo de lente
        AND (p_tipo_lente IS NULL OR l.tipo_lente::TEXT = p_tipo_lente)
        
        -- Apenas lentes ativas
        AND l.status = 'ativo'
    
    -- Ordenação: premium primeiro, depois por índice, depois por preço
    ORDER BY 
        m.is_premium DESC NULLS LAST,
        CASE 
            WHEN l.indice_refracao::TEXT IN ('1.67', '1.74', '1.90') THEN 1
            WHEN l.indice_refracao::TEXT IN ('1.59', '1.61') THEN 2
            WHEN l.indice_refracao::TEXT = '1.56' THEN 3
            ELSE 4
        END,
        l.preco_tabela ASC NULLS LAST
    LIMIT 100;
END;
$$;

-- Garante permissões para usuários anônimos e autenticados
GRANT EXECUTE ON FUNCTION public.buscar_lentes_por_receita TO anon, authenticated;

-- Comentário da função
COMMENT ON FUNCTION public.buscar_lentes_por_receita IS 
'Busca lentes compatíveis com receita oftalmológica - IMPLEMENTAÇÃO DIRETA (padrão buscar_lentes)';

-- ============================================
-- TESTE DA FUNÇÃO
-- ============================================

-- Teste 1: Visão simples
SELECT COUNT(*) as total_visao_simples
FROM public.buscar_lentes_por_receita(-2.00, -0.50, NULL, 'visao_simples');

-- Teste 2: Multifocal com adição
SELECT COUNT(*) as total_multifocal
FROM public.buscar_lentes_por_receita(-2.00, -0.50, 2.00, 'multifocal');

-- Teste 3: Ver algumas lentes
SELECT nome_comercial, tipo_lente, material, indice_refracao, preco_tabela
FROM public.buscar_lentes_por_receita(-2.00, -0.50, NULL, 'visao_simples')
LIMIT 5;
