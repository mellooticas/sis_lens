-- ============================================
-- Função buscar_lentes_por_receita usando VIEW pública
-- Resolve erro: permission denied for schema lens_catalog
-- ============================================

-- Remove função antiga se existir
DROP FUNCTION IF EXISTS public.buscar_lentes_por_receita(NUMERIC, NUMERIC, NUMERIC, TEXT);

-- Cria nova função usando vw_lentes_catalogo (view pública)
CREATE OR REPLACE FUNCTION public.buscar_lentes_por_receita(
    p_esferico NUMERIC,
    p_cilindrico NUMERIC,
    p_adicao NUMERIC DEFAULT NULL,
    p_tipo_lente TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    nome_lente TEXT,
    nome_comercial TEXT,
    tipo_lente TEXT,
    categoria TEXT,
    material TEXT,
    indice_refracao TEXT,
    preco_tabela NUMERIC,
    marca_nome TEXT,
    fornecedor_nome TEXT,
    tratamento_antirreflexo BOOLEAN,
    tratamento_blue_light BOOLEAN,
    tratamento_fotossensiveis TEXT,
    tratamento_uv BOOLEAN,
    grau_esferico_min NUMERIC,
    grau_esferico_max NUMERIC,
    grau_cilindrico_min NUMERIC,
    grau_cilindrico_max NUMERIC,
    adicao_min NUMERIC,
    adicao_max NUMERIC,
    marca_premium BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.id,
        v.nome_lente,
        v.nome_lente as nome_comercial, -- alias para compatibilidade
        v.tipo_lente,
        v.categoria,
        v.material,
        v.indice_refracao,
        v.preco_tabela,
        v.marca_nome,
        v.fornecedor_nome,
        v.tratamento_antirreflexo,
        v.tratamento_blue_light,
        v.tratamento_fotossensiveis,
        v.tratamento_uv,
        v.grau_esferico_min,
        v.grau_esferico_max,
        v.grau_cilindrico_min,
        v.grau_cilindrico_max,
        v.adicao_min,
        v.adicao_max,
        v.marca_premium
    FROM public.vw_lentes_catalogo v
    WHERE 
        -- Validação do esférico
        (v.grau_esferico_min IS NULL OR p_esferico >= v.grau_esferico_min)
        AND (v.grau_esferico_max IS NULL OR p_esferico <= v.grau_esferico_max)
        
        -- Validação do cilíndrico
        AND (v.grau_cilindrico_min IS NULL OR p_cilindrico >= v.grau_cilindrico_min)
        AND (v.grau_cilindrico_max IS NULL OR p_cilindrico <= v.grau_cilindrico_max)
        
        -- Validação da adição (apenas para multifocal/bifocal)
        AND (
            p_adicao IS NULL 
            OR v.tipo_lente = 'visao_simples'
            OR (v.adicao_min IS NOT NULL AND p_adicao >= v.adicao_min AND p_adicao <= v.adicao_max)
        )
        
        -- Validação do tipo de lente
        AND (p_tipo_lente IS NULL OR v.tipo_lente = p_tipo_lente)
    
    -- Ordenação: premium primeiro, depois por índice, depois por preço
    ORDER BY 
        v.marca_premium DESC NULLS LAST,
        CASE 
            WHEN v.indice_refracao IN ('1.67', '1.74', '1.76') THEN 1
            WHEN v.indice_refracao IN ('1.60', '1.61') THEN 2
            ELSE 3
        END,
        v.preco_tabela ASC NULLS LAST
    LIMIT 100;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Garante permissões para usuários anônimos e autenticados
GRANT EXECUTE ON FUNCTION public.buscar_lentes_por_receita TO anon, authenticated;

-- Comentário da função
COMMENT ON FUNCTION public.buscar_lentes_por_receita IS 
'Busca lentes compatíveis com uma receita oftalmológica. 
Usa a view pública vw_lentes_catalogo para evitar problemas de permissão.
Retorna até 100 resultados ordenados por qualidade e preço.';

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
SELECT nome_lente, tipo_lente, material, indice_refracao, preco_tabela
FROM public.buscar_lentes_por_receita(-2.00, -0.50, NULL, 'visao_simples')
LIMIT 5;
