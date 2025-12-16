-- ============================================
-- PASSO 4: CRIAR VIEW DO MOTOR DE BUSCA
-- ============================================

-- View para facilitar buscas no motor
CREATE OR REPLACE VIEW lens_catalog.v_motor_lentes AS
SELECT 
    l.id as lente_id,
    l.tenant_id,
    l.sku_canonico as nosso_sku,
    l.sku_laboratorio as codigo_pedido_lab,
    l.nome_comercial,
    
    -- Classificação
    CASE 
        WHEN l.is_premium THEN 'PREMIUM'
        ELSE 'GENÉRICA'
    END as tipo,
    l.nivel_qualidade,
    
    -- Produto
    COALESCE(pc.nome_base, lc.nome_comercial, l.familia) as nome_produto,
    COALESCE(pc.linha_produto, lc.linha_produto, l.familia) as linha,
    
    -- Marca e Laboratório
    m.nome as marca,
    m.id as marca_id,
    lab.nome_fantasia as laboratorio,
    lab.id as laboratorio_id,
    
    -- Características
    l.tipo_lente,
    l.material,
    l.indice_refracao,
    l.tratamentos,
    l.design,
    l.corredor_progressao,
    
    -- Agrupamento
    COALESCE(l.premium_canonica_id, l.lente_canonica_id) as grupo_canonico_id,
    CASE 
        WHEN l.premium_canonica_id IS NOT NULL THEN pc.sku_canonico_premium
        WHEN l.lente_canonica_id IS NOT NULL THEN lc.sku_canonico
    END as sku_canonico_grupo,
    
    -- Contagem de labs que vendem o mesmo produto
    COUNT(*) OVER (
        PARTITION BY COALESCE(l.premium_canonica_id, l.lente_canonica_id)
    ) as labs_disponiveis,
    
    -- Ranking dentro do grupo (por ordem de criação)
    ROW_NUMBER() OVER (
        PARTITION BY COALESCE(l.premium_canonica_id, l.lente_canonica_id)
        ORDER BY l.criado_em
    ) as rank_lab,
    
    -- Metadata
    l.ativo,
    l.criado_em,
    l.atualizado_em
    
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.premium_canonicas pc ON pc.id = l.premium_canonica_id
LEFT JOIN lens_catalog.lentes_canonicas lc ON lc.id = l.lente_canonica_id
JOIN lens_catalog.marcas m ON m.id = l.marca_id
LEFT JOIN suppliers.laboratorios lab ON lab.id = l.laboratorio_id
WHERE l.ativo = TRUE;

COMMENT ON VIEW lens_catalog.v_motor_lentes IS 'View completa para motor de busca - inclui preços, agrupamentos e rankings';

-- ============================================
-- EXEMPLOS DE QUERIES NO MOTOR
-- ============================================

-- QUERY 1: Buscar progressiva 1.67 com transitions
SELECT 
    tipo,
    nome_produto,
    marca,
    codigo_pedido_lab,
    laboratorio,
    labs_disponiveis,
    rank_lab
FROM lens_catalog.v_motor_lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND tipo_lente = 'PROGRESSIVA'
  AND indice_refracao = 1.67
  AND 'FOTO' = ANY(tratamentos)
  AND ativo = TRUE
ORDER BY tipo DESC, nome_produto, rank_lab;

-- QUERY 2: Listar produtos com múltiplos labs (comparação)
SELECT 
    tipo,
    nome_produto,
    marca,
    labs_disponiveis,
    STRING_AGG(DISTINCT laboratorio, ', ') as labs
FROM lens_catalog.v_motor_lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND labs_disponiveis > 1
GROUP BY tipo, nome_produto, marca, labs_disponiveis
ORDER BY labs_disponiveis DESC, tipo, nome_produto;

-- QUERY 3: Produtos premium por marca
SELECT 
    marca,
    COUNT(DISTINCT nome_produto) as qtd_produtos,
    COUNT(DISTINCT laboratorio_id) as qtd_labs
FROM lens_catalog.v_motor_lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND tipo = 'PREMIUM'
GROUP BY marca
ORDER BY qtd_produtos DESC;

-- QUERY 4: Lentes por tipo
SELECT 
    tipo_lente,
    tipo,
    nome_produto,
    marca,
    laboratorio,
    labs_disponiveis
FROM lens_catalog.v_motor_lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
GROUP BY tipo_lente, tipo, nome_produto, marca, laboratorio, labs_disponiveis
ORDER BY tipo_lente, labs_disponiveis DESC;

-- ============================================
-- FUNÇÃO AUXILIAR: Buscar lentes
-- ============================================

CREATE OR REPLACE FUNCTION lens_catalog.fn_buscar_lentes(
    p_tenant_id UUID,
    p_tipo_lente tipo_lente DEFAULT NULL,
    p_indice_refracao NUMERIC DEFAULT NULL,
    p_tratamentos tratamento_lente[] DEFAULT NULL,
    p_marca_id UUID DEFAULT NULL,
    p_apenas_premium BOOLEAN DEFAULT FALSE,
    p_limite INTEGER DEFAULT 50
)
RETURNS TABLE (
    tipo TEXT,
    nome_produto TEXT,
    marca TEXT,
    codigo_pedido VARCHAR(100),
    laboratorio TEXT,
    labs_disponiveis BIGINT,
    rank_lab BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.tipo,
        v.nome_produto,
        v.marca,
        v.codigo_pedido_lab,
        v.laboratorio,
        v.labs_disponiveis,
        v.rank_lab
    FROM lens_catalog.v_motor_lentes v
    WHERE v.tenant_id = p_tenant_id
      AND (p_tipo_lente IS NULL OR v.tipo_lente = p_tipo_lente)
      AND (p_indice_refracao IS NULL OR v.indice_refracao = p_indice_refracao)
      AND (p_tratamentos IS NULL OR v.tratamentos @> p_tratamentos)
      AND (p_marca_id IS NULL OR v.marca_id = p_marca_id)
      AND (p_apenas_premium = FALSE OR v.tipo = 'PREMIUM')
    ORDER BY v.tipo DESC, v.nome_produto, v.rank_lab
    LIMIT p_limite;
END;
$$ LANGUAGE plpgsql;

-- Exemplo de uso:
SELECT * FROM lens_catalog.fn_buscar_lentes(
    p_tenant_id := '229220bb-d480-4608-a07c-ae9ab5266caf',
    p_tipo_lente := 'PROGRESSIVA',
    p_indice_refracao := 1.67,
    p_tratamentos := ARRAY['FOTO', 'AR']::tratamento_lente[]
);

| tipo_lente  | tipo     | nome_produto | marca    | laboratorio | labs_disponiveis |
| ----------- | -------- | ------------ | -------- | ----------- | ---------------- |
| MONOFOCAL   | GENÉRICA | STANDARD     | POLYLUX  | null        | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | POLYLUX  | Brascor     | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | SOBLOCOS | Express     | 1                |
| MONOFOCAL   | GENÉRICA | VS FREE FORM | SOBLOCOS | null        | 1                |
| MONOFOCAL   | GENÉRICA | FREEVIEW     | BRASCOR  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | SOBLOCOS | Express     | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | SOBLOCOS | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | EXPRESS  | Brascor     | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | SYGMA    | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | TOP VIEW     | SOBLOCOS | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | VS HDI       | SYGMA    | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | VS FREE FORM | EXPRESS  | null        | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | POLYLUX  | Sygma       | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | BRASCOR  | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | EXPRESS  | Sygma       | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | SOBLOCOS | null        | 1                |
| MONOFOCAL   | GENÉRICA | VS FREE FORM | POLYLUX  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | ACOMODA      | SOBLOCOS | null        | 1                |
| MONOFOCAL   | GENÉRICA | POLYLUX      | SYGMA    | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | TOP VIEW     | SYGMA    | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | SYGMA PRIME  | POLYLUX  | Express     | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | BRASCOR  | null        | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | BRASCOR  | null        | 1                |
| MONOFOCAL   | GENÉRICA | FREEVIEW     | SYGMA    | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | VS HDI       | BRASCOR  | null        | 1                |
| MONOFOCAL   | GENÉRICA | POLYLUX      | SOBLOCOS | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | POLYLUX  | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | EXPRESS  | null        | 1                |
| MONOFOCAL   | GENÉRICA | TOP VIEW     | POLYLUX  | null        | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | SYGMA    | null        | 1                |
| MONOFOCAL   | GENÉRICA | ACOMODA      | SOBLOCOS | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | SYGMA PRIME  | SOBLOCOS | Express     | 1                |
| MONOFOCAL   | GENÉRICA | VS HDI       | EXPRESS  | null        | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | BRASCOR  | Express     | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | EXPRESS  | Express     | 1                |
| MONOFOCAL   | GENÉRICA | VS FREE FORM | SOBLOCOS | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | POLYLUX  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | TOP VIEW     | BRASCOR  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | VS FREE FORM | SYGMA    | null        | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | BRASCOR  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | VS HDI       | BRASCOR  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | POLYLUX      | POLYLUX  | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | SOBLOCOS | null        | 1                |
| MONOFOCAL   | GENÉRICA | TOP VIEW     | EXPRESS  | null        | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | SYGMA    | Brascor     | 1                |
| MONOFOCAL   | GENÉRICA | FREEVIEW     | EXPRESS  | null        | 1                |
| MONOFOCAL   | GENÉRICA | FREEVIEW     | POLYLUX  | null        | 1                |
| MONOFOCAL   | GENÉRICA | TOP VIEW     | BRASCOR  | null        | 1                |
| MONOFOCAL   | GENÉRICA | VS FREE FORM | BRASCOR  | null        | 1                |
| MONOFOCAL   | GENÉRICA | VS FREE FORM | EXPRESS  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | SYGMA PRIME  | EXPRESS  | Express     | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | BRASCOR  | Brascor     | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | BRASCOR  | Sygma       | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | POLYLUX  | Express     | 1                |
| MONOFOCAL   | GENÉRICA | FREEVIEW     | SYGMA    | null        | 1                |
| MONOFOCAL   | GENÉRICA | VS HDI       | POLYLUX  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | EXPRESS  | null        | 1                |
| MONOFOCAL   | GENÉRICA | FREEVIEW     | SOBLOCOS | null        | 1                |
| MONOFOCAL   | GENÉRICA | TOP VIEW     | SOBLOCOS | null        | 1                |
| MONOFOCAL   | GENÉRICA | FREEVIEW     | POLYLUX  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | ACOMODA      | EXPRESS  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | EXPRESS  | Brascor     | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | POLYLUX  | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | TOP VIEW     | POLYLUX  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | BRASCOR  | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | POLYLUX      | BRASCOR  | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | VS FREE FORM | POLYLUX  | null        | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | SOBLOCOS | Brascor     | 1                |
| MONOFOCAL   | GENÉRICA | VS HDI       | POLYLUX  | null        | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | SYGMA    | null        | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | POLYLUX  | Express     | 1                |
| MONOFOCAL   | GENÉRICA | ACOMODA      | POLYLUX  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | SOBLOCOS | Sygma       | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | POLYLUX  | null        | 1                |
| MONOFOCAL   | GENÉRICA | ACOMODA      | BRASCOR  | null        | 1                |
| MONOFOCAL   | GENÉRICA | POLYLUX      | EXPRESS  | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | POLYLUX  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | SOBLOCOS | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | ACOMODA      | SYGMA    | null        | 1                |
| MONOFOCAL   | GENÉRICA | FREEVIEW     | SOBLOCOS | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | POLYLUX  | Brascor     | 1                |
| MONOFOCAL   | GENÉRICA | VS HDI       | SOBLOCOS | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | VS HDI       | SOBLOCOS | null        | 1                |
| MONOFOCAL   | GENÉRICA | STANDARD     | EXPRESS  | Polylux     | 1                |
| MONOFOCAL   | GENÉRICA | ACOMODA      | POLYLUX  | null        | 1                |
| MONOFOCAL   | GENÉRICA | VS HDI       | SYGMA    | null        | 1                |
| MONOFOCAL   | GENÉRICA | ACOMODA      | EXPRESS  | null        | 1                |
| MONOFOCAL   | GENÉRICA | TOP VIEW     | EXPRESS  | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | MULTI        | SOBLOCOS | So Blocos   | 1                |
| MONOFOCAL   | GENÉRICA | FREEVIEW     | BRASCOR  | null        | 1                |
| MONOFOCAL   | GENÉRICA | FREEVIEW     | EXPRESS  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | VS HDI       | ESSILOR  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | SOBLOCOS | Brascor     | 1                |
| PROGRESSIVA | GENÉRICA | VS FREE FORM | POLYLUX  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | TOP VIEW     | EXPRESS  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | TOP VIEW     | POLYLUX  | null        | 1                |
| PROGRESSIVA | GENÉRICA | TOP VIEW     | POLYLUX  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | POLYLUX      | EXPRESS  | Polylux     | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | EXPRESS  | Polylux     | 1                |
| PROGRESSIVA | GENÉRICA | ACOMODA      | POLYLUX  | null        | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | ESSILOR  | null        | 1                |
| PROGRESSIVA | GENÉRICA | TOP VIEW     | EXPRESS  | null        | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | BRASCOR  | Polylux     | 1                |
| PROGRESSIVA | GENÉRICA | TOP VIEW     | SOBLOCOS | null        | 1                |
| PROGRESSIVA | GENÉRICA | POLYLUX      | SOBLOCOS | Polylux     | 1                |
| PROGRESSIVA | GENÉRICA | VS FREE FORM | ESSILOR  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | FREEVIEW     | ESSILOR  | null        | 1                |
| PROGRESSIVA | GENÉRICA | TOP VIEW     | SOBLOCOS | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | VS HDI       | SOBLOCOS | null        | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | POLYLUX  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | VS FREE FORM | SOBLOCOS | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | EXPRESS  | Brascor     | 1                |
| PROGRESSIVA | GENÉRICA | FREEVIEW     | POLYLUX  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | VS HDI       | POLYLUX  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | ACOMODA      | ESSILOR  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | FREEVIEW     | ESSILOR  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | ACOMODA      | SOBLOCOS | null        | 1                |
| PROGRESSIVA | GENÉRICA | POLYLUX      | ESSILOR  | Polylux     | 1                |
| PROGRESSIVA | GENÉRICA | FREEVIEW     | SOBLOCOS | null        | 1                |
| PROGRESSIVA | GENÉRICA | VS FREE FORM | SOBLOCOS | null        | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | POLYLUX  | Polylux     | 1                |
| PROGRESSIVA | GENÉRICA | FREEVIEW     | POLYLUX  | null        | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | SOBLOCOS | null        | 1                |
| PROGRESSIVA | GENÉRICA | POLYLUX      | POLYLUX  | Polylux     | 1                |
| PROGRESSIVA | GENÉRICA | VS HDI       | SOBLOCOS | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | POLYLUX  | null        | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | SOBLOCOS | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | SOBLOCOS | Express     | 1                |
| PROGRESSIVA | GENÉRICA | SYGMA PRIME  | SOBLOCOS | Express     | 1                |
| PROGRESSIVA | GENÉRICA | VS HDI       | ESSILOR  | null        | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | ESSILOR  | Brascor     | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | EXPRESS  | Sygma       | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | BRASCOR  | null        | 1                |
| PROGRESSIVA | GENÉRICA | VS FREE FORM | ESSILOR  | null        | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | ESSILOR  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | SOBLOCOS | null        | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | POLYLUX  | Brascor     | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | POLYLUX  | Express     | 1                |
| PROGRESSIVA | GENÉRICA | TOP VIEW     | BRASCOR  | null        | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | POLYLUX  | null        | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | SOBLOCOS | Polylux     | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | EXPRESS  | null        | 1                |
| PROGRESSIVA | GENÉRICA | SYGMA PRIME  | ESSILOR  | Express     | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | BRASCOR  | Polylux     | 1                |
| PROGRESSIVA | GENÉRICA | ACOMODA      | ESSILOR  | null        | 1                |
| PROGRESSIVA | GENÉRICA | SYGMA PRIME  | POLYLUX  | Express     | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | EXPRESS  | Polylux     | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | SOBLOCOS | Polylux     | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | SOBLOCOS | Express     | 1                |
| PROGRESSIVA | GENÉRICA | VS FREE FORM | POLYLUX  | null        | 1                |
| PROGRESSIVA | GENÉRICA | ACOMODA      | POLYLUX  | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | ESSILOR  | null        | 1                |
| PROGRESSIVA | GENÉRICA | ACOMODA      | SOBLOCOS | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | ESSILOR  | Express     | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | POLYLUX  | Sygma       | 1                |
| PROGRESSIVA | GENÉRICA | MULTI        | SOBLOCOS | Brascor     | 1                |
| PROGRESSIVA | GENÉRICA | FREEVIEW     | SOBLOCOS | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | POLYLUX  | Express     | 1                |
| PROGRESSIVA | GENÉRICA | STANDARD     | SOBLOCOS | So Blocos   | 1                |
| PROGRESSIVA | GENÉRICA | VS HDI       | POLYLUX  | null        | 1                |