-- ============================================
-- EXTRAORDINARY_DB_STRUCTURE_FIX_V4.sql
-- Correção FINAL e DEFINITIVA da estrutura da tabela lentes
-- Garante TODAS as colunas que a View Pública espera.
-- ============================================

-- 1. IDs e CHAVES ESTRANGEIRAS
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS fornecedor_id UUID;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS lente_canonica_id UUID;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS premium_canonica_id UUID;

-- 2. IDENTIFICAÇÃO COMERCIAL
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS sku_fornecedor VARCHAR;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS codigo_original VARCHAR;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS nome_comercial TEXT;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS descricao_curta TEXT;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS linha_produto VARCHAR;

-- 3. PREÇIFICAÇÃO
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS custo_base NUMERIC(10,2) DEFAULT 0;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS preco_tabela NUMERIC(10,2) DEFAULT 0;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS preco_fabricante NUMERIC(10,2);

-- 4. GRADE ÓPTICA (FLAT)
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS esferico_min NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS esferico_max NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS cilindrico_min NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS cilindrico_max NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS adicao_min NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS adicao_max NUMERIC(4,2);
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS dnp_min INTEGER;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS dnp_max INTEGER;

-- 5. ESPECIFICAÇÕES FÍSICAS
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS diametro INTEGER;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS espessura_central NUMERIC;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS peso_aproximado NUMERIC;

-- 6. TRATAMENTOS (COLUNAS BOOLEANAS PARA FILTRO RÁPIDO)
-- Se o banco original usa array, essas colunas facilitam a view sem explodir array
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS ar BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS antirrisco BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS hidrofobico BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS antiembaçante BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS blue BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS uv400 BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS polarizado BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS digital BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS free_form BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS indoor BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS drive BOOLEAN DEFAULT false;

-- Fotossensível muitas vezes é string/enum (Transitions, Photofusion, None)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='fotossensivel') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN fotossensivel TEXT DEFAULT 'nenhum';
    END IF;
END $$;

-- 7. LOGÍSTICA E STATUS
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS prazo_entrega INTEGER DEFAULT 7;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS obs_prazo TEXT;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS peso_frete NUMERIC DEFAULT 50.0;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS exige_receita_especial BOOLEAN DEFAULT false;

ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS destaque BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS novidade BOOLEAN DEFAULT false;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS data_lancamento DATE;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS data_descontinuacao DATE;

-- Campos Textuais descritivos
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS descricao_completa TEXT;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS contraindicacoes TEXT;
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS observacoes TEXT;
-- Arrays como text[]
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS beneficios TEXT[];
ALTER TABLE lens_catalog.lentes ADD COLUMN IF NOT EXISTS indicacoes TEXT[];


-- 8. GARANTIR STATUS E DISPONIVEL
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='status') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN status TEXT DEFAULT 'ativo';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='lens_catalog' AND table_name='lentes' AND column_name='disponivel') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN disponivel BOOLEAN DEFAULT true;
    END IF;
END $$;

-- 9. RECRIAR FUNÇÃO DE BUSCA E ÍNDICES (COM PROTEÇÃO CONTRA TIPOS)
CREATE INDEX IF NOT EXISTS idx_lentes_sku_v4 ON lens_catalog.lentes(sku_fornecedor);
CREATE INDEX IF NOT EXISTS idx_lentes_canonica_v4 ON lens_catalog.lentes(lente_canonica_id);

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
        COALESCE(l.nome_comercial, 'Lente sem nome'),
        CAST(l.tipo_lente AS TEXT),
        COALESCE(l.preco_tabela, 0),
        COALESCE(m.nome, 'Genérico'),
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
