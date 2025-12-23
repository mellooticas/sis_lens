-- ============================================
-- EXTRAORDINARY_DB_REPAIR_AND_UPGRADE.sql
-- 1. Corrige a estrutura da tabela (Adiciona colunas comerciais se faltarem)
-- 2. Aplica índices de performance
-- 3. Cria motor de busca avançado
-- ============================================

-- ============================================
-- PASSO 1: ESTRUTURA COMERCIAL COMPLETA
-- ============================================
-- Se o banco seguiu apenas as migrations "canônicas", ele não tem preços.
-- Vamos adicionar as colunas necessárias para o módulo de vendas.

DO $$
BEGIN
    -- Adicionar colunas de Preço se não existirem
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='preco_tabela') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN preco_tabela NUMERIC(10,2) DEFAULT 0;
        ALTER TABLE lens_catalog.lentes ADD COLUMN custo_base NUMERIC(10,2) DEFAULT 0;
        ALTER TABLE lens_catalog.lentes ADD COLUMN preco_fabricante NUMERIC(10,2);
    END IF;

    -- Adicionar colunas de Identificação Comercial
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='nome_comercial') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN nome_comercial TEXT;
        -- Tentar preencher nome_comercial com familia + design se estiver null
        UPDATE lens_catalog.lentes SET nome_comercial = familia || ' ' || design WHERE nome_comercial IS NULL AND familia IS NOT NULL;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='descricao_curta') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN descricao_curta TEXT;
    END IF;

    -- Adicionar colunas de Grade (Flat) se estiverem faltando (para facilitar busca simples sem join)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='esferico_min') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN esferico_min NUMERIC(4,2);
        ALTER TABLE lens_catalog.lentes ADD COLUMN esferico_max NUMERIC(4,2);
        ALTER TABLE lens_catalog.lentes ADD COLUMN cilindrico_min NUMERIC(4,2);
        ALTER TABLE lens_catalog.lentes ADD COLUMN cilindrico_max NUMERIC(4,2);
        ALTER TABLE lens_catalog.lentes ADD COLUMN adicao_min NUMERIC(4,2);
        ALTER TABLE lens_catalog.lentes ADD COLUMN adicao_max NUMERIC(4,2);
    END IF;
    
    -- Garantir coluna status
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='status') THEN
         -- Se já tiver 'ativo' (boolean), criamos status como texto ou enum baseando-se nele
         ALTER TABLE lens_catalog.lentes ADD COLUMN status TEXT DEFAULT 'ativo';
    END IF;

    -- Garantir disponivel
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='disponivel') THEN
         ALTER TABLE lens_catalog.lentes ADD COLUMN disponivel BOOLEAN DEFAULT true;
    END IF;

END $$;

-- ============================================
-- PASSO 2: INDEXAÇÃO (Agora seguro pois as colunas existem)
-- ============================================

CREATE INDEX IF NOT EXISTS idx_lentes_preco ON lens_catalog.lentes(preco_tabela);
CREATE INDEX IF NOT EXISTS idx_lentes_marca_id ON lens_catalog.lentes(marca_id);
-- Cast para text em tipo_lente para evitar erro se for enum
CREATE INDEX IF NOT EXISTS idx_lentes_tipo_txt ON lens_catalog.lentes((tipo_lente::text)); 

-- ============================================
-- PASSO 3: FUNÇÃO DE PRESCRIÇÃO (Prescription Matcher)
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
    preco_tabela NUMERIC,
    marca_nome TEXT,
    match_score INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.nome_comercial,
        CAST(l.tipo_lente AS TEXT),
        l.preco_tabela,
        m.nome as marca_nome,
        -- Score: Premium ganha pontos, Alto Índice ganha pontos
        (CASE WHEN m.is_premium THEN 10 ELSE 0 END + 
         CASE WHEN l.indice_refracao::text IN ('1.67', '1.74', '1.76') THEN 5 ELSE 0 END) as match_score
    FROM lens_catalog.lentes l
    JOIN lens_catalog.marcas m ON l.marca_id = m.id
    WHERE 
      -- Regra de Status: Verifica texto ou boolean dependendo do que tiver
      (
        (to_jsonb(l) ? 'status' AND (l.status::text = 'ativo')) OR 
        (to_jsonb(l) ? 'ativo' AND (l.ativo = true))
      )
      AND l.disponivel = true
      
      -- Filtros de Dioptria (verifica se colunas não são nulas)
      AND (l.esferico_min IS NULL OR p_esferico >= l.esferico_min)
      AND (l.esferico_max IS NULL OR p_esferico <= l.esferico_max)
      AND (l.cilindrico_min IS NULL OR p_cilindrico >= l.cilindrico_min)
      AND (l.cilindrico_max IS NULL OR p_cilindrico <= l.cilindrico_max)
      
      -- Filtro de Adição
      AND (
          p_adicao IS NULL 
          OR 
          (l.adicao_min IS NOT NULL AND p_adicao >= l.adicao_min AND p_adicao <= l.adicao_max)
          OR
          (CAST(l.tipo_lente AS TEXT) = 'visao_simples')
      )
      -- Filtro Tipo (Case insensitive safe)
      AND (p_tipo_lente IS NULL OR CAST(l.tipo_lente AS TEXT) = p_tipo_lente)
    ORDER BY match_score DESC, l.preco_tabela ASC;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.buscar_lentes_por_receita TO anon, authenticated;

-- ============================================
-- PASSO 4: Full Text Search (Busca "Google-like")
-- ============================================

-- Remover coluna se já existir para recriar logicamente correta
ALTER TABLE lens_catalog.lentes DROP COLUMN IF EXISTS busca_vector;

-- Adicionar coluna gerada
ALTER TABLE lens_catalog.lentes 
ADD COLUMN busca_vector tsvector 
GENERATED ALWAYS AS (
    setweight(to_tsvector('portuguese', coalesce(nome_comercial, '')), 'A') || 
    setweight(to_tsvector('portuguese', coalesce(descricao_curta, '')), 'B') 
) STORED;

CREATE INDEX IF NOT EXISTS idx_lentes_busca ON lens_catalog.lentes USING GIN(busca_vector);

-- RPC de Busca
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
    ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.buscar_lentes_texto TO anon, authenticated;

-- ============================================
-- PASSO 5: View de BI (Lucratividade)
-- ============================================
CREATE OR REPLACE VIEW public.vw_bi_lentes_lucratividade AS
SELECT 
    m.nome as marca,
    l.categoria,
    COUNT(*) as qtd_produtos,
    AVG(l.custo_base)::numeric(10,2) as custo_medio,
    AVG(l.preco_tabela)::numeric(10,2) as preco_medio,
    AVG(l.preco_tabela - l.custo_base)::numeric(10,2) as margem_media_abs
FROM lens_catalog.lentes l
JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE (l.status::text = 'ativo') AND l.custo_base > 0
GROUP BY m.nome, l.categoria
ORDER BY margem_media_abs DESC;

GRANT SELECT ON public.vw_bi_lentes_lucratividade TO authenticated; 
