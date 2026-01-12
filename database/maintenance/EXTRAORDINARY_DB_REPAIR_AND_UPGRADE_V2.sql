-- ============================================
-- EXTRAORDINARY_DB_REPAIR_AND_UPGRADE_V2.sql
-- Versão Robusta com SQL Dinâmico para evitar erros de compilação
-- ============================================

DO $$
DECLARE
    v_tem_familia boolean;
    v_tem_nome_comercial boolean;
BEGIN
    -- 1. Verificar Colunas Existentes
    SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='familia') INTO v_tem_familia;
    SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='nome_comercial') INTO v_tem_nome_comercial;

    -- 2. Adicionar Preços se faltarem
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='preco_tabela') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN preco_tabela NUMERIC(10,2) DEFAULT 0;
        ALTER TABLE lens_catalog.lentes ADD COLUMN custo_base NUMERIC(10,2) DEFAULT 0;
        ALTER TABLE lens_catalog.lentes ADD COLUMN preco_fabricante NUMERIC(10,2);
    END IF;

    -- 3. Adicionar Ou Atualizar Nome Comercial
    IF NOT v_tem_nome_comercial THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN nome_comercial TEXT;
        
        -- Se tiver família, popula inicial
        IF v_tem_familia THEN
            EXECUTE 'UPDATE lens_catalog.lentes SET nome_comercial = familia || '' '' || design WHERE nome_comercial IS NULL';
        ELSE
            -- Se não tiver família, usa SKU ou algo genérico
            EXECUTE 'UPDATE lens_catalog.lentes SET nome_comercial = ''Lente Generica '' || id WHERE nome_comercial IS NULL';
        END IF;
    END IF;

    -- 4. Garantir Colunas de Grade (Flat)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='esferico_min') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN esferico_min NUMERIC(4,2);
        ALTER TABLE lens_catalog.lentes ADD COLUMN esferico_max NUMERIC(4,2);
        ALTER TABLE lens_catalog.lentes ADD COLUMN cilindrico_min NUMERIC(4,2);
        ALTER TABLE lens_catalog.lentes ADD COLUMN cilindrico_max NUMERIC(4,2);
        ALTER TABLE lens_catalog.lentes ADD COLUMN adicao_min NUMERIC(4,2);
        ALTER TABLE lens_catalog.lentes ADD COLUMN adicao_max NUMERIC(4,2);
    END IF;
    
    -- 5. Garantir outras colunas secundárias
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='descricao_curta') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN descricao_curta TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='status') THEN
         ALTER TABLE lens_catalog.lentes ADD COLUMN status TEXT DEFAULT 'ativo';
    ELSE
         -- Se já existe mas é enum ou outro tipo, não faz nada por enquanto, trataremos no SELECT com cast
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='disponivel') THEN
         ALTER TABLE lens_catalog.lentes ADD COLUMN disponivel BOOLEAN DEFAULT true;
    END IF;

END $$;

-- ============================================
-- PASSO 2: INDEXAÇÃO (Seguro agora)
-- ============================================

CREATE INDEX IF NOT EXISTS idx_lentes_preco_v2 ON lens_catalog.lentes(preco_tabela);
CREATE INDEX IF NOT EXISTS idx_lentes_marca_id_v2 ON lens_catalog.lentes(marca_id);
-- Cast para text em tipo_lente para evitar erro de tipo
CREATE INDEX IF NOT EXISTS idx_lentes_tipo_txt_v2 ON lens_catalog.lentes((CAST(tipo_lente AS TEXT))); 

-- ============================================
-- PASSO 3: FUNÇÃO DE PRESCRIÇÃO (Mais permissiva com TIPOS)
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
        COALESCE(l.nome_comercial, 'Sem Nome'),
        CAST(l.tipo_lente AS TEXT),
        COALESCE(l.preco_tabela, 0),
        COALESCE(m.nome, 'Genérico') as marca_nome,
        -- Score Simplificado seguro
        (CASE WHEN m.is_premium IS TRUE THEN 10 ELSE 0 END + 
         CASE WHEN l.indice_refracao::text IN ('1.67', '1.74', '1.76') THEN 5 ELSE 0 END) as match_score
    FROM lens_catalog.lentes l
    LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
    WHERE 
      -- Verificação de Status segura (tenta cast para texto)
      (
        l.status::text = 'ativo' OR l.status::text = 'ATIVO'
      )
      AND (l.disponivel IS TRUE OR l.disponivel IS NULL) -- Default true
      
      -- Filtros de Dioptria (se colunas nulas, aceita a lente)
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

DO $$
BEGIN
    -- Só recria se não existir ou se precisar (drop seguro)
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='busca_vector') THEN
        -- Opcional: Dropar para recriar com novas regras
        -- ALTER TABLE lens_catalog.lentes DROP COLUMN busca_vector;
        NULL;
    ELSE
        ALTER TABLE lens_catalog.lentes 
        ADD COLUMN busca_vector tsvector 
        GENERATED ALWAYS AS (
            setweight(to_tsvector('portuguese', coalesce(nome_comercial, '')), 'A') || 
            setweight(to_tsvector('portuguese', coalesce(descricao_curta, '')), 'B') 
        ) STORED;
        
        CREATE INDEX IF NOT EXISTS idx_lentes_busca_v2 ON lens_catalog.lentes USING GIN(busca_vector);
    END IF;
END $$;

-- RPC de Busca
DROP FUNCTION IF EXISTS public.buscar_lentes_texto;
CREATE OR REPLACE FUNCTION public.buscar_lentes_texto(
    busca TEXT
)
RETURNS SETOF public.vw_lentes_catalogo AS $$
BEGIN
    -- Verifica se search vector existe antes de usar
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='busca_vector') THEN
        RETURN QUERY
        SELECT *
        FROM public.vw_lentes_catalogo
        WHERE id IN (
            SELECT id FROM lens_catalog.lentes
            WHERE busca_vector @@ plainto_tsquery('portuguese', busca)
        )
        ORDER BY created_at DESC;
    ELSE
        -- Fallback se vetor não existir (busca simples ILIKE)
        RETURN QUERY
        SELECT *
        FROM public.vw_lentes_catalogo
        WHERE nome_comercial ILIKE '%' || busca || '%'
        ORDER BY created_at DESC;
    END IF;
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
WHERE (l.status::text = 'ativo' OR l.status::text = 'ATIVO') AND l.custo_base > 0
GROUP BY m.nome, l.categoria
ORDER BY margem_media_abs DESC;

GRANT SELECT ON public.vw_bi_lentes_lucratividade TO authenticated;
