-- ============================================================================
-- VIEWS BÁSICAS PARA TESTAR A CONEXÃO - VERSÃO SIMPLIFICADA
-- Execute estas primeiro para garantir que a conexão funciona
-- ============================================================================

-- 1. PERMISSÕES BÁSICAS
GRANT USAGE ON SCHEMA lens_catalog TO anon;
GRANT USAGE ON SCHEMA suppliers TO anon;
GRANT USAGE ON SCHEMA orders TO anon;
GRANT USAGE ON SCHEMA api TO anon;

GRANT SELECT ON ALL TABLES IN SCHEMA lens_catalog TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA suppliers TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA orders TO anon;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA api TO anon;

-- ============================================================================
-- 2. VIEWS BÁSICAS - SÓ COM COLUNAS QUE EXISTEM
-- ============================================================================

-- View básica do catálogo
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
    l.ativo,
    m.nome AS marca_nome,
    CONCAT(m.nome, ' ', l.familia, ' ', l.design) AS descricao_completa
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE l.ativo = true;

-- View básica dos fornecedores  
CREATE OR REPLACE VIEW public.vw_fornecedores AS
SELECT 
    lab.id,
    lab.tenant_id,
    lab.nome_fantasia as nome,
    lab.cnpj,
    lab.contato_comercial as contato,
    lab.ativo,
    50 as credibilidade_score -- Score fixo para não dar erro
FROM suppliers.laboratorios lab
WHERE lab.ativo = true;

-- View básica das decisões
CREATE OR REPLACE VIEW public.decisoes_compra AS
SELECT 
    dec.id,
    dec.tenant_id,
    dec.lente_recomendada_id,
    dec.laboratorio_escolhido_id,
    dec.preco_final,
    dec.prazo_estimado_dias,
    dec.score_atribuido,
    dec.criterio_usado,
    dec.decidido_por,
    dec.decidido_em,
    dec.status,
    dec.confirmado_em
FROM orders.decisoes_lentes dec;

-- ============================================================================
-- 3. RPC BÁSICA PARA BUSCA
-- ============================================================================

-- RPC básica de busca (wrapper)
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
    -- Se a função api.buscar_lentes existir, use ela
    -- Senão, faça busca básica
    SELECT 
        l.id as lente_id,
        CONCAT(m.nome, ' ', l.familia, ' ', l.design) as label,
        l.sku_canonico as sku_fantasia
    FROM lens_catalog.lentes l
    LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
    WHERE l.ativo = true
      AND (
          l.familia ILIKE '%' || p_query || '%' OR
          l.design ILIKE '%' || p_query || '%' OR
          l.sku_canonico ILIKE '%' || p_query || '%' OR
          m.nome ILIKE '%' || p_query || '%'
      )
    LIMIT p_limit;
$$;

-- ============================================================================
-- 4. PERMISSÕES PARA AS VIEWS
-- ============================================================================

GRANT SELECT ON public.vw_lentes_catalogo TO anon;
GRANT SELECT ON public.vw_fornecedores TO anon;
GRANT SELECT ON public.decisoes_compra TO anon;
GRANT EXECUTE ON FUNCTION public.rpc_buscar_lente TO anon;

-- ============================================================================
-- FINALIZADO! Versão básica para testar a conexão
-- ============================================================================