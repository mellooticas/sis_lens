-- ============================================
-- EXTRAORDINARY_DB_STRUCTURE_FIX_V5.sql
-- Upgrade da função buscar_lentes_por_receita para retornar objeto completo
-- Necessário para o Simulador DB e fluxo de venda técnica
-- ============================================

DROP FUNCTION IF EXISTS public.buscar_lentes_por_receita;

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
    ar BOOLEAN,
    blue BOOLEAN,
    fotossensivel TEXT,
    esferico_min NUMERIC,
    esferico_max NUMERIC,
    cilindrico_min NUMERIC,
    cilindrico_max NUMERIC,
    match_score INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        COALESCE(l.nome_comercial, 'Lente sem nome'),
        CAST(l.tipo_lente AS TEXT),
        CAST(l.categoria AS TEXT),
        CAST(l.material AS TEXT),
        CAST(l.indice_refracao AS TEXT),
        COALESCE(l.preco_tabela, 0),
        COALESCE(m.nome, 'Genérico'),
        l.ar,
        l.blue,
        l.fotossensivel,
        l.esferico_min,
        l.esferico_max,
        l.cilindrico_min,
        l.cilindrico_max,
        (CASE WHEN m.is_premium IS TRUE THEN 10 ELSE 0 END + 
         CASE WHEN l.indice_refracao::text IN ('1.67', '1.74', '1.76') THEN 5 ELSE 0 END) as match_score
    FROM lens_catalog.lentes l
    LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
    WHERE 
      (l.status::text = 'ativo' OR l.status::text = 'ATIVO') AND (l.disponivel IS TRUE OR l.disponivel IS NULL)
      AND (l.esferico_min IS NULL OR p_esferico >= l.esferico_min)
      AND (l.esferico_max IS NULL OR p_esferico <= l.esferico_max)
      AND (l.cilindrico_min IS NULL OR p_cilindrico >= l.cilindrico_min)
      AND (l.cilindrico_max IS NULL OR p_cilindrico <= l.cilindrico_max)
      AND (
          p_adicao IS NULL 
          OR (l.adicao_min IS NOT NULL AND p_adicao >= l.adicao_min AND p_adicao <= l.adicao_max)
          OR (CAST(l.tipo_lente AS TEXT) = 'visao_simples')
      )
      AND (p_tipo_lente IS NULL OR CAST(l.tipo_lente AS TEXT) ILIKE p_tipo_lente)
    ORDER BY match_score DESC, l.preco_tabela ASC;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.buscar_lentes_por_receita TO anon, authenticated;
