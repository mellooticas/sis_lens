-- ============================================
-- EXTRAORDINARY_DB_STRUCTURE_FIX_V3.sql
-- Correção FINAL e DEFINITIVA da estrutura da tabela lentes
-- Usa "IF NOT EXISTS" individualmente para cada coluna para evitar erros.
-- ============================================

-- 1. ADICIONAR COLUNAS COMERCIAIS E DE IDENTIFICAÇÃO
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS sku_fornecedor VARCHAR;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS codigo_original VARCHAR;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS nome_comercial TEXT;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS descricao_curta TEXT;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS linha_produto VARCHAR;

-- 2. ADICIONAR COLUNAS DE PREÇIFICAÇÃO
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS custo_base NUMERIC(10,2) DEFAULT 0;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS preco_tabela NUMERIC(10,2) DEFAULT 0;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS preco_fabricante NUMERIC(10,2);

-- 3. ADICIONAR COLUNAS DE GRADE ÓPTICA (FLAT)
-- Essais para a busca rápida sem JOINs complexos
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS esferico_min NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS esferico_max NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS cilindrico_min NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS cilindrico_max NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS adicao_min NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS adicao_max NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS dnp_min INTEGER;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS dnp_max INTEGER;

-- 4. COLUNAS DE LOGÍSTICA
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS prazo_entrega INTEGER DEFAULT 7;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS obs_prazo TEXT;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS peso_frete NUMERIC DEFAULT 50.0;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS exige_receita_especial BOOLEAN DEFAULT false;

-- 5. AJUSTES DE TIPOS (SE NECESSÁRIO - VIA DO BLOCK PARA EVITAR ERROS)
DO $$
BEGIN
    -- Se status não existe, cria como text. Se existe como enum, OK.
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='status') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN status TEXT DEFAULT 'ativo';
    END IF;

    -- Garantir disponivel
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='disponivel') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN disponivel BOOLEAN DEFAULT true;
    END IF;
    
    -- Garantir fornecedor_id (pode ser FK)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='fornecedor_id') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN fornecedor_id UUID;
    END IF;
END $$;

-- 6. RECRIAÇÃO DOS ÍNDICES (COM IF NOT EXISTS)
CREATE INDEX IF NOT EXISTS idx_lentes_sku_forn ON lens_catalog.lentes(sku_fornecedor);
CREATE INDEX IF NOT EXISTS idx_lentes_nome_com ON lens_catalog.lentes(nome_comercial);
CREATE INDEX IF NOT EXISTS idx_lentes_preco_v3 ON lens_catalog.lentes(preco_tabela);

-- ============================================
-- 7. FUNÇÃO DE BUSCA INTELIGENTE (ATUALIZADA)
-- ============================================
-- Esta função é o coração da experiência "Extraordinária"
-- Ela usa CASTs seguros para evitar conflitos de tipos (ENUMs vs TEXT)

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
        COALESCE(l.nome_comercial, 'Produto sem nome'),
        CAST(l.tipo_lente AS TEXT),
        COALESCE(l.preco_tabela, 0),
        COALESCE(m.nome, 'Genérico'),
        -- Score de Relevância
        (CASE WHEN m.is_premium IS TRUE THEN 10 ELSE 0 END + 
         CASE WHEN l.indice_refracao::text IN ('1.67', '1.74', '1.76') THEN 5 ELSE 0 END +
         CASE WHEN l.blue IS TRUE THEN 2 ELSE 0 END) as match_score
    FROM lens_catalog.lentes l
    LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
    WHERE 
      -- Status (Tratamento robusto para boolean/text/enum)
      (l.status::text = 'ativo' OR l.status::text = 'ATIVO')
      AND (l.disponivel IS TRUE OR l.disponivel IS NULL)
      
      -- Filtro Esférico (Se a grade for nula, assume compatível - produto genérico)
      AND (l.esferico_min IS NULL OR p_esferico >= l.esferico_min)
      AND (l.esferico_max IS NULL OR p_esferico <= l.esferico_max)
      
      -- Filtro Cilíndrico
      AND (l.cilindrico_min IS NULL OR p_cilindrico >= l.cilindrico_min)
      AND (l.cilindrico_max IS NULL OR p_cilindrico <= l.cilindrico_max)
      
      -- Filtro Adição (Só aplica se user mandou E se a lente tem regra)
      AND (
          p_adicao IS NULL 
          OR 
          (l.adicao_min IS NOT NULL AND p_adicao >= l.adicao_min AND p_adicao <= l.adicao_max)
          OR
          (CAST(l.tipo_lente AS TEXT) = 'visao_simples') -- VS ignora adição
      )
      
      -- Filtro Tipo (Case insensitive)
      AND (p_tipo_lente IS NULL OR CAST(l.tipo_lente AS TEXT) ILIKE p_tipo_lente)
      
    ORDER BY match_score DESC, l.preco_tabela ASC;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.buscar_lentes_por_receita TO anon, authenticated;

-- ============================================
-- 8. VIEW DE DASHBOARD (BI)
-- ============================================
CREATE OR REPLACE VIEW public.vw_bi_lentes_lucratividade AS
SELECT 
    COALESCE(m.nome, 'Indefinido') as marca,
    COALESCE(CAST(l.categoria AS TEXT), 'Geral') as categoria,
    COUNT(*) as qtd_produtos,
    AVG(l.custo_base)::numeric(10,2) as custo_medio,
    AVG(l.preco_tabela)::numeric(10,2) as preco_medio
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE l.custo_base > 0
GROUP BY m.nome, l.categoria;

GRANT SELECT ON public.vw_bi_lentes_lucratividade TO authenticated;
