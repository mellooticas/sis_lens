-- ============================================================================
-- COMPLETAR VIEWS E TABELAS FALTANTES - SISTEMA HÍBRIDO BESTLENS
-- Execute no Supabase Dashboard para completar a conexão
-- ============================================================================

-- 1. CRIAR VIEWS FALTANTES DO SISTEMA DE LENTES
-- ============================================================================

-- View: produtos_laboratorio (que estava faltando)
CREATE OR REPLACE VIEW public.produtos_laboratorio AS
SELECT 
    prod.*,
    lab.nome_fantasia as laboratorio_nome,
    50 as credibilidade_score, -- Score padrão
    lente.sku_canonico as lente_sku,
    lente.familia as lente_familia
FROM suppliers.produtos_laboratorio prod
LEFT JOIN suppliers.laboratorios lab ON prod.laboratorio_id = lab.id
LEFT JOIN lens_catalog.lentes lente ON prod.lente_id = lente.id;

-- View: mv_economia_por_fornecedor (analytics)
CREATE OR REPLACE VIEW public.mv_economia_por_fornecedor AS
SELECT 
    lab.id as laboratorio_id,
    lab.nome_fantasia as laboratorio_nome,
    COUNT(dec.id) as total_decisoes,
    AVG(dec.preco_final) as preco_medio,
    SUM(dec.preco_final) as economia_total, -- Usando preco_final em vez de economia_gerada
    AVG(dec.score_atribuido) as score_medio
FROM suppliers.laboratorios lab
LEFT JOIN orders.decisoes_lentes dec ON lab.id = dec.laboratorio_escolhido_id
WHERE lab.ativo = true
GROUP BY lab.id, lab.nome_fantasia;

-- ============================================================================
-- 2. CRIAR RPC FALTANTE
-- ============================================================================

-- RPC: rpc_rank_opcoes (ranking de opções)
CREATE OR REPLACE FUNCTION public.rpc_rank_opcoes(
    p_lente_id UUID,
    p_criterio TEXT,
    p_filtros JSONB DEFAULT '{}'
)
RETURNS TABLE(
    laboratorio_id UUID,
    laboratorio_nome TEXT,
    sku_fantasia TEXT,
    preco_final DECIMAL,
    prazo_dias INTEGER,
    custo_frete DECIMAL,
    score_qualidade INTEGER,
    score_ponderado DECIMAL,
    rank_posicao INTEGER,
    justificativa TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    preco_max DECIMAL;
    prazo_max INTEGER;
BEGIN
    -- Extrair filtros
    preco_max := COALESCE((p_filtros->>'preco_maximo')::DECIMAL, 999999);
    prazo_max := COALESCE((p_filtros->>'prazo_maximo_dias')::INTEGER, 365);
    
    RETURN QUERY
    WITH opcoes_base AS (
        SELECT 
            prod.laboratorio_id,
            lab.nome_fantasia AS laboratorio_nome,
            prod.sku_fantasia,
            COALESCE(prod.preco_base, 100) AS preco_final,
            COALESCE(prod.prazo_producao_dias, 15) AS prazo_dias,
            0::DECIMAL AS custo_frete,
            50 AS score_qualidade, -- Score padrão
            -- Score ponderado baseado no critério
            CASE 
                WHEN p_criterio = 'URGENCIA' THEN 
                    (100 - COALESCE(prod.prazo_producao_dias, 15) * 2) * 0.7 + 50 * 0.3
                WHEN p_criterio = 'ESPECIAL' THEN 
                    50 * 0.8 + (100 - (COALESCE(prod.preco_base, 100) / 100)) * 0.2
                ELSE -- NORMAL
                    50 * 0.4 + 
                    (100 - COALESCE(prod.prazo_producao_dias, 15)) * 0.3 + 
                    (100 - (COALESCE(prod.preco_base, 100) / 50)) * 0.3
            END AS score_ponderado
        FROM suppliers.produtos_laboratorio prod
        JOIN suppliers.laboratorios lab ON prod.laboratorio_id = lab.id
        WHERE prod.lente_id = p_lente_id
          AND prod.disponivel = true
          AND lab.ativo = true
          AND COALESCE(prod.preco_base, 100) <= preco_max
          AND COALESCE(prod.prazo_producao_dias, 15) <= prazo_max
    ),
    opcoes_rankeadas AS (
        SELECT 
            *,
            ROW_NUMBER() OVER (ORDER BY score_ponderado DESC, preco_final ASC) AS rank_posicao,
            CASE 
                WHEN p_criterio = 'URGENCIA' THEN 'Priorizado por urgência de entrega'
                WHEN p_criterio = 'ESPECIAL' THEN 'Priorizado por qualidade'
                ELSE 'Melhor custo-benefício'
            END AS justificativa
        FROM opcoes_base
    )
    SELECT * FROM opcoes_rankeadas
    ORDER BY rank_posicao
    LIMIT 10;
END;
$$;

-- ============================================================================
-- 3. CRIAR TABELAS DE VOUCHERS FALTANTES (se não existirem)
-- ============================================================================

-- Tabela: usuarios (se não existir)
CREATE TABLE IF NOT EXISTS public.usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    nome TEXT NOT NULL,
    tipo_usuario TEXT NOT NULL DEFAULT 'cliente',
    loja_id UUID,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Tabela: lojas (se não existir)
CREATE TABLE IF NOT EXISTS public.lojas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome TEXT NOT NULL,
    cnpj TEXT UNIQUE,
    endereco JSONB,
    contato JSONB,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Tabela: clientes (se não existir)
CREATE TABLE IF NOT EXISTS public.clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome TEXT NOT NULL,
    email TEXT,
    telefone TEXT,
    cpf TEXT UNIQUE,
    endereco JSONB,
    loja_id UUID REFERENCES public.lojas(id),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Tabela: vouchers (se não existir)
CREATE TABLE IF NOT EXISTS public.vouchers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,
    cliente_id UUID REFERENCES public.clientes(id),
    loja_id UUID REFERENCES public.lojas(id),
    valor_desconto DECIMAL(10,2),
    porcentagem_desconto INTEGER,
    produto_aplicavel TEXT,
    data_validade DATE,
    usado BOOLEAN DEFAULT false,
    usado_em TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- 4. PERMISSÕES PARA ANON
-- ============================================================================

-- Views
GRANT SELECT ON public.produtos_laboratorio TO anon;
GRANT SELECT ON public.mv_economia_por_fornecedor TO anon;

-- RPC
GRANT EXECUTE ON FUNCTION public.rpc_rank_opcoes TO anon;

-- Tabelas (somente leitura para anon)
GRANT SELECT ON public.usuarios TO anon;
GRANT SELECT ON public.lojas TO anon;
GRANT SELECT ON public.clientes TO anon;
GRANT SELECT ON public.vouchers TO anon;

-- ============================================================================
-- 5. COMENTÁRIOS
-- ============================================================================

COMMENT ON VIEW public.produtos_laboratorio IS 'View para produtos de laboratório - sistema híbrido SIS Lens';
COMMENT ON VIEW public.mv_economia_por_fornecedor IS 'Análise de economia por fornecedor - sistema híbrido SIS Lens';
COMMENT ON FUNCTION public.rpc_rank_opcoes IS 'Ranking de opções para decisão de lentes - sistema híbrido SIS Lens';

-- ============================================================================
-- FINALIZADO! Sistema híbrido completo
-- ============================================================================