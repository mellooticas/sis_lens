-- ============================================
-- Função buscar_lentes_por_receita 
-- Retorna TODOS os campos compatíveis com VLenteCatalogo
-- ============================================

-- Remove função antiga se existir
DROP FUNCTION IF EXISTS public.buscar_lentes_por_receita(NUMERIC, NUMERIC, NUMERIC, TEXT);

-- Cria função retornando campos compatíveis com frontend
CREATE OR REPLACE FUNCTION public.buscar_lentes_por_receita(
    p_esferico NUMERIC,
    p_cilindrico NUMERIC,
    p_adicao NUMERIC DEFAULT NULL,
    p_tipo_lente TEXT DEFAULT NULL
)
RETURNS SETOF public.vw_lentes_catalogo
LANGUAGE SQL
SECURITY DEFINER
AS $$
    SELECT *
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
'Busca lentes compatíveis com receita oftalmológica - Retorna TODOS os campos da view vw_lentes_catalogo';

-- ============================================
-- TESTE DA FUNÇÃO
-- ============================================

-- Teste 1: Visão simples
SELECT COUNT(*) as total_visao_simples
FROM public.buscar_lentes_por_receita(-2.00, -0.50, NULL, 'visao_simples');


| total_visao_simples |
| ------------------- |
| 100                 |

-- Teste 2: Multifocal com adição
SELECT COUNT(*) as total_multifocal
FROM public.buscar_lentes_por_receita(-2.00, -0.50, 2.00, 'multifocal');

| total_multifocal |
| ---------------- |
| 100              |

-- Teste 3: Ver algumas lentes
SELECT nome_comercial, tipo_lente, material, indice_refracao, preco_tabela
FROM public.buscar_lentes_por_receita(-2.00, -0.50, NULL, 'visao_simples')
LIMIT 5;


| nome_comercial | tipo_lente    | material | indice_refracao | preco_tabela |
| -------------- | ------------- | -------- | --------------- | ------------ |
| null           | visao_simples | CR39     | 1.74            | 0.00         |
| null           | visao_simples | CR39     | 1.67            | 0.00         |
| null           | visao_simples | CR39     | 1.67            | 0.00         |
| null           | visao_simples | CR39     | 1.67            | 0.00         |
| null           | visao_simples | CR39     | 1.74            | 0.00         |