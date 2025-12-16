-- ============================================================================
-- CRIAÇÃO DAS VIEWS PÚBLICAS PARA O BACKEND BESTLENS
-- Execute no Supabase Dashboard para conectar o backend
-- ============================================================================

-- 1. DAR PERMISSÕES PARA ANON ACESSAR OS SCHEMAS
GRANT USAGE ON SCHEMA lens_catalog TO anon;
GRANT USAGE ON SCHEMA suppliers TO anon;
GRANT USAGE ON SCHEMA orders TO anon;
GRANT USAGE ON SCHEMA scoring TO anon;
GRANT USAGE ON SCHEMA commercial TO anon;
GRANT USAGE ON SCHEMA api TO anon;

-- 2. DAR PERMISSÕES PARA TABELAS
GRANT SELECT ON ALL TABLES IN SCHEMA lens_catalog TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA suppliers TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA orders TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA scoring TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA commercial TO anon;

-- 3. DAR PERMISSÕES PARA FUNÇÕES
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA api TO anon;

-- ============================================================================
-- 4. CRIAR VIEWS PÚBLICAS QUE O BACKEND ESPERA
-- ============================================================================

-- View: vw_lentes_catalogo (catálogo completo de lentes)
CREATE OR REPLACE VIEW public.vw_lentes_catalogo AS
SELECT 
    l.id AS lente_id,
    l.tenant_id,
    l.sku_canonico,
    l.familia,
    l.design,
    l.material,
    l.indice_refracao,
    l.tratamentos,
    l.tipo_lente,
    l.corredor_progressao,
    l.specs_tecnicas,
    l.ativo,
    m.nome AS marca_nome,
    m.pais_origem,
    CONCAT(m.nome, ' ', l.familia, ' ', l.design, ' ', l.indice_refracao) AS descricao_completa
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE l.ativo = true;

-- ============================================================================

-- View: vw_fornecedores (laboratórios com estatísticas)
CREATE OR REPLACE VIEW public.vw_fornecedores AS
SELECT 
    lab.id,
    lab.tenant_id,
    lab.nome_fantasia as nome,
    lab.cnpj,
    lab.contato_comercial as contato,
    50 as credibilidade_score, -- Score padrão já que a coluna não existe
    lab.ativo,
    COUNT(prod.id) AS total_produtos,
    COUNT(CASE WHEN prod.disponivel = true THEN 1 END) AS produtos_disponiveis
FROM suppliers.laboratorios lab
LEFT JOIN suppliers.produtos_laboratorio prod ON lab.id = prod.laboratorio_id
WHERE lab.ativo = true
GROUP BY lab.id, lab.tenant_id, lab.nome_fantasia, lab.cnpj, lab.contato_comercial, lab.ativo;

-- ============================================================================

-- View: decisoes_compra (mapeamento para o histórico de decisões)
CREATE OR REPLACE VIEW public.decisoes_compra AS
SELECT 
    dec.id,
    dec.tenant_id,
    dec.lente_id,
    dec.laboratorio_id,
    dec.produto_lab_id,
    'NORMAL' as criterio, -- Critério padrão já que a coluna não existe
    dec.preco_final,
    dec.prazo_estimado_dias,
    dec.custo_frete,
    dec.score_atribuido,
    dec.motivo,
    dec.alternativas_consideradas,
    dec.decidido_por,
    dec.decidido_em,
    dec.status,
    dec.payload_decisao,
    dec.created_at,
    dec.updated_at
FROM orders.decisoes_lentes dec;

-- ============================================================================

-- View: produtos_laboratorio (produtos disponíveis)
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

-- ============================================================================

-- View: mv_economia_por_fornecedor (analytics de economia)
CREATE OR REPLACE VIEW public.mv_economia_por_fornecedor AS
SELECT 
    lab.id as laboratorio_id,
    lab.nome_fantasia as laboratorio_nome,
    COUNT(dec.id) as total_decisoes,
    AVG(dec.preco_final) as preco_medio,
    SUM(COALESCE(dec.economia_gerada, 0)) as economia_total,
    AVG(dec.score_atribuido) as score_medio
FROM suppliers.laboratorios lab
LEFT JOIN orders.decisoes_lentes dec ON lab.id = dec.laboratorio_id
WHERE lab.ativo = true
GROUP BY lab.id, lab.nome_fantasia;

-- ============================================================================
-- 5. CRIAR WRAPPERS PARA AS RPCS DO SCHEMA API
-- ============================================================================

-- RPC: rpc_buscar_lente (wrapper para api.buscar_lentes)
CREATE OR REPLACE FUNCTION public.rpc_buscar_lente(
    p_query TEXT,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE(
    lente_id UUID,
    label TEXT,
    sku_fantasia TEXT
) 
LANGUAGE SQL
SECURITY DEFINER
AS $$
    SELECT * FROM api.buscar_lentes(p_query, p_limit);
$$;

-- ============================================================================

-- RPC: rpc_rank_opcoes (wrapper baseado na estrutura existente)
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
            COALESCE(precos.preco_final, prod.preco_base) AS preco_final,
            prod.prazo_producao_dias AS prazo_dias,
            0::DECIMAL AS custo_frete,
            50 AS score_qualidade, -- Score padrão já que não temos a tabela scores
            -- Score ponderado baseado no critério
            CASE 
                WHEN p_criterio = 'URGENCIA' THEN 
                    (100 - prod.prazo_producao_dias * 2) * 0.7 + 50 * 0.3
                WHEN p_criterio = 'ESPECIAL' THEN 
                    50 * 0.8 + (100 - (COALESCE(precos.preco_final, prod.preco_base) / 100)) * 0.2
                ELSE -- NORMAL
                    50 * 0.4 + 
                    (100 - prod.prazo_producao_dias) * 0.3 + 
                    (100 - (COALESCE(precos.preco_final, prod.preco_base) / 50)) * 0.3
            END AS score_ponderado
        FROM suppliers.produtos_laboratorio prod
        JOIN suppliers.laboratorios lab ON prod.laboratorio_id = lab.id
        LEFT JOIN commercial.precos_base precos ON prod.id = precos.produto_id
        WHERE prod.lente_id = p_lente_id
          AND prod.disponivel = true
          AND lab.ativo = true
          AND COALESCE(precos.preco_final, prod.preco_base) <= preco_max
          AND prod.prazo_producao_dias <= prazo_max
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

-- RPC: rpc_confirmar_decisao (wrapper para api.criar_decisao_lente)
CREATE OR REPLACE FUNCTION public.rpc_confirmar_decisao(
    p_payload JSONB
)
RETURNS UUID
LANGUAGE SQL
SECURITY DEFINER
AS $$
    SELECT api.criar_decisao_lente(p_payload);
$$;

-- ============================================================================
-- 6. DAR PERMISSÕES PARA AS VIEWS E FUNÇÕES CRIADAS
-- ============================================================================

GRANT SELECT ON public.vw_lentes_catalogo TO anon;
GRANT SELECT ON public.vw_fornecedores TO anon;
GRANT SELECT ON public.decisoes_compra TO anon;
GRANT SELECT ON public.produtos_laboratorio TO anon;
GRANT SELECT ON public.mv_economia_por_fornecedor TO anon;

GRANT EXECUTE ON FUNCTION public.rpc_buscar_lente TO anon;
GRANT EXECUTE ON FUNCTION public.rpc_rank_opcoes TO anon;
GRANT EXECUTE ON FUNCTION public.rpc_confirmar_decisao TO anon;

-- ============================================================================
-- 7. COMENTÁRIOS INFORMATIVOS
-- ============================================================================

COMMENT ON VIEW public.vw_lentes_catalogo IS 'View pública para catálogo de lentes - consumida pelo frontend SIS Lens';
COMMENT ON VIEW public.vw_fornecedores IS 'View pública para laboratórios/fornecedores - consumida pelo frontend SIS Lens';
COMMENT ON VIEW public.decisoes_compra IS 'View pública para histórico de decisões - consumida pelo frontend SIS Lens';

COMMENT ON FUNCTION public.rpc_buscar_lente IS 'RPC pública para busca de lentes - wrapper para api.buscar_lentes';
COMMENT ON FUNCTION public.rpc_rank_opcoes IS 'RPC pública para ranking de opções - implementação baseada na estrutura existente';
COMMENT ON FUNCTION public.rpc_confirmar_decisao IS 'RPC pública para confirmar decisões - wrapper para api.criar_decisao_lente';

-- ============================================================================
-- FINALIZADO! 
-- O backend agora deve conseguir conectar às views e RPCs em public
-- ============================================================================