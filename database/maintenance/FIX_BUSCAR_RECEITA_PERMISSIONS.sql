-- ============================================
-- Função buscar_lentes_por_receita 
-- Usa VIEW vw_lentes_catalogo (a que tem os campos corretos)
-- ============================================

-- Remove função antiga se existir
DROP FUNCTION IF EXISTS public.buscar_lentes_por_receita(NUMERIC, NUMERIC, NUMERIC, TEXT);

-- Cria função usando vw_lentes_catalogo (view com todos os campos)
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
LANGUAGE SQL
SECURITY DEFINER
AS $$
    SELECT 
        v.id,
        v.nome_comercial,
        v.tipo_lente::TEXT,
        v.categoria::TEXT,
        v.material::TEXT,
        v.indice_refracao::TEXT,
        v.preco_tabela,
        v.marca_nome::TEXT,
        v.marca_premium,
        v.ar,
        v.blue,
        v.fotossensivel,
        v.uv400,
        v.esferico_min,
        v.esferico_max,
        v.cilindrico_min,
        v.cilindrico_max,
        v.adicao_min,
        v.adicao_max
    FROM public.vw_lentes_catalogo v
    WHERE 
        -- Validação do esférico
        (v.esferico_min IS NULL OR p_esferico >= v.esferico_min)
        AND (v.esferico_max IS NULL OR p_esferico <= v.esferico_max)
        
        -- Validação do cilíndrico
        AND (v.cilindrico_min IS NULL OR p_cilindrico >= v.cilindrico_min)
        AND (v.cilindrico_max IS NULL OR p_cilindrico <= v.cilindrico_max)
        
        -- Validação da adição (apenas para multifocal/bifocal)
        AND (
            p_adicao IS NULL 
            OR v.tipo_lente::TEXT = 'visao_simples'
            OR (v.adicao_min IS NOT NULL AND p_adicao >= v.adicao_min AND p_adicao <= v.adicao_max)
        )
        
        -- Validação do tipo de lente
        AND (p_tipo_lente IS NULL OR v.tipo_lente::TEXT = p_tipo_lente)
    
    -- Ordenação: premium primeiro, depois por índice, depois por preço
    ORDER BY 
        v.marca_premium DESC NULLS LAST,
        CASE 
            WHEN v.indice_refracao::TEXT IN ('1.67', '1.74', '1.90') THEN 1
            WHEN v.indice_refracao::TEXT IN ('1.59', '1.61') THEN 2
            WHEN v.indice_refracao::TEXT = '1.56' THEN 3
            ELSE 4
        END,
        v.preco_tabela ASC NULLS LAST
    LIMIT 100;
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
