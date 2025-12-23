-- ============================================
-- EXTRAORDINARY_DB_UPGRADE.sql
-- Transformando o banco de dados para uma experiência de App Extraordinária
-- ============================================

-- ============================================
-- 1. INDEXAÇÃO INTELIGENTE (Performance Extrema)
-- ============================================
-- Garante que filtros comuns sejam instantâneos, independente do tamanho do catálogo.

CREATE INDEX IF NOT EXISTS idx_lentes_marca ON lens_catalog.lentes(marca_id);
CREATE INDEX IF NOT EXISTS idx_lentes_tipo ON lens_catalog.lentes(tipo_lente);
CREATE INDEX IF NOT EXISTS idx_lentes_material ON lens_catalog.lentes(material);
CREATE INDEX IF NOT EXISTS idx_lentes_preco ON lens_catalog.lentes(preco_tabela);
CREATE INDEX IF NOT EXISTS idx_lentes_status ON lens_catalog.lentes(status) WHERE status = 'ativo';

-- Índices compostos para filtros comuns (Ex: "Visão Simples de Policarbonato")
CREATE INDEX IF NOT EXISTS idx_lentes_tipo_material ON lens_catalog.lentes(tipo_lente, material);

-- ============================================
-- 2. BUSCA DE LENTES POR RECEITA (Lógica no Banco)
-- ============================================
-- Remove a complexidade do Frontend e traz apenas lentes compatíveis com a receita.
-- "Prescription Matcher" - O diferencial extraordinário.

DROP FUNCTION IF EXISTS public.buscar_lentes_por_receita;
CREATE OR REPLACE FUNCTION public.buscar_lentes_por_receita(
    p_esferico NUMERIC,
    p_cilindrico NUMERIC,
    p_adicao NUMERIC DEFAULT NULL,
    p_tipo_lente TEXT DEFAULT NULL -- opcional
)
RETURNS TABLE (
    id UUID,
    nome_comercial TEXT,
    tipo_lente TEXT,
    preco_tabela NUMERIC,
    marca_nome TEXT,
    match_score INTEGER -- Pontuação de "qualidade" do match
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.nome_comercial,
        CAST(l.tipo_lente AS TEXT),
        l.preco_tabela,
        m.nome as marca_nome,
        -- Cálculo de Score (exemplo simples: marcas premium +10, lentes finas +5)
        (CASE WHEN m.is_premium THEN 10 ELSE 0 END + 
         CASE WHEN l.indice_refracao::text IN ('1.67', '1.74', '1.76') THEN 5 ELSE 0 END) as match_score
    FROM lens_catalog.lentes l
    JOIN lens_catalog.marcas m ON l.marca_id = m.id
    WHERE l.status = 'ativo'
      AND l.disponivel = true
      -- Filtro de Faixa Esférica
      AND (l.esferico_min IS NULL OR p_esferico >= l.esferico_min)
      AND (l.esferico_max IS NULL OR p_esferico <= l.esferico_max)
      -- Filtro de Faixa Cilíndrica
      AND (l.cilindrico_min IS NULL OR p_cilindrico >= l.cilindrico_min)
      AND (l.cilindrico_max IS NULL OR p_cilindrico <= l.cilindrico_max)
      -- Filtro de Adição (apenas se fornecido e se a lente suportar, ex: multifocal)
      AND (
          p_adicao IS NULL 
          OR 
          (l.adicao_min IS NOT NULL AND p_adicao >= l.adicao_min AND p_adicao <= l.adicao_max)
          OR
          (l.tipo_lente::text = 'visao_simples') -- Visão simples ignora adição ou aceita
      )
      -- Filtro Opcional de Tipo
      AND (p_tipo_lente IS NULL OR l.tipo_lente::text = p_tipo_lente)
    ORDER BY match_score DESC, l.preco_tabela ASC;
END;
$$ LANGUAGE plpgsql;

-- Permissões
GRANT EXECUTE ON FUNCTION public.buscar_lentes_por_receita TO anon, authenticated;

-- ============================================
-- 3. BUSCA TEXTUAL AVANÇADA (Full Text Search)
-- ============================================
-- Permite buscar por "Blue" e achar "Blue Cut", "Blue Control", etc.

-- Adicionar coluna gerada para busca (Supported in PG 12+)
ALTER TABLE lens_catalog.lentes 
ADD COLUMN IF NOT EXISTS busca_vector tsvector 
GENERATED ALWAYS AS (
    setweight(to_tsvector('portuguese', coalesce(nome_comercial, '')), 'A') || 
    setweight(to_tsvector('portuguese', coalesce(descricao_curta, '')), 'B') ||
    setweight(to_tsvector('portuguese', coalesce(sku_fornecedor, '')), 'C')
) STORED;

CREATE INDEX IF NOT EXISTS idx_lentes_busca ON lens_catalog.lentes USING GIN(busca_vector);

-- Função RPC para busca textual via Supabase
DROP FUNCTION IF EXISTS public.buscar_lentes_texto;
CREATE OR REPLACE FUNCTION public.buscar_lentes_texto(
    busca TEXT
)
RETURNS SETOF public.vw_lentes_catalogo AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.vw_lentes_catalogo
    WHERE id IN (
        SELECT id FROM lens_catalog.lentes
        WHERE busca_vector @@ plainto_tsquery('portuguese', busca)
    )
    ORDER BY created_at DESC; -- Ou order by rank se quiser
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.buscar_lentes_texto TO anon, authenticated;

-- ============================================
-- 4. VIEW ANALÍTICA DE PREÇOS (Business Intelligence)
-- ============================================
-- Para o Dashboard do Admin: Onde estamos ganhando mais?
CREATE OR REPLACE VIEW public.vw_bi_lentes_lucratividade AS
SELECT 
    m.nome as marca,
    l.categoria,
    COUNT(*) as qtd_produtos,
    AVG(l.custo_base)::numeric(10,2) as custo_medio,
    AVG(l.preco_tabela)::numeric(10,2) as preco_medio,
    AVG(l.preco_tabela - l.custo_base)::numeric(10,2) as margem_media_abs,
    AVG(((l.preco_tabela - l.custo_base)/l.custo_base)*100)::numeric(10,2) as margem_percentual
FROM lens_catalog.lentes l
JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE l.status = 'ativo' AND l.custo_base > 0
GROUP BY m.nome, l.categoria
ORDER BY margem_media_abs DESC;

GRANT SELECT ON public.vw_bi_lentes_lucratividade TO authenticated; -- Apenas logados

