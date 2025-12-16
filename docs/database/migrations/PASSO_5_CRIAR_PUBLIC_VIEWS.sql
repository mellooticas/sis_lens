-- ============================================
-- PASSO 5: CRIAR PUBLIC VIEWS PARA FRONTEND
-- ============================================
-- Views públicas (schema public) para consumo do frontend
-- Sem expor estrutura interna do banco
--
-- ⚠️  NOTA: Funcionalidade de preços será implementada quando
--    a tabela produtos_laboratorio tiver as colunas necessárias
-- ============================================

-- ============================================
-- 5.1: VIEW - Buscar Lentes (Motor Principal)
-- ============================================

CREATE OR REPLACE VIEW public.vw_buscar_lentes AS
SELECT 
    -- IDs (para frontend)
    l.id as lente_id,
    l.tenant_id,
    
    -- SKUs
    l.sku_canonico as sku,
    l.sku_laboratorio as codigo_laboratorio,
    
    -- Informações do Produto
    v.nome_produto,
    v.linha,
    l.nome_comercial,
    l.familia,
    
    -- Classificação
    v.tipo,
    l.nivel_qualidade,
    
    -- Marca e Laboratório
    v.marca,
    v.marca_id,
    v.laboratorio,
    v.laboratorio_id,
    
    -- Características Técnicas
    l.tipo_lente,
    l.material::text as material,
    l.indice_refracao,
    ARRAY_TO_JSON(l.tratamentos) as tratamentos,
    l.design,
    l.corredor_progressao,
    l.specs_tecnicas,
    
    -- Agrupamento (para mostrar alternativas)
    v.grupo_canonico_id,
    v.sku_canonico_grupo,
    v.labs_disponiveis,
    v.rank_lab,
    
    -- Metadata
    l.ativo,
    l.criado_em,
    l.atualizado_em
    
FROM lens_catalog.lentes l
JOIN lens_catalog.v_motor_lentes v ON v.lente_id = l.id
WHERE l.ativo = TRUE;

COMMENT ON VIEW public.vw_buscar_lentes IS 'Motor de busca de lentes - consumo do frontend';

-- ============================================
-- 5.2: VIEW - Produtos Premium (Catálogo)
-- ============================================

CREATE OR REPLACE VIEW public.vw_produtos_premium AS
SELECT 
    pc.id,
    pc.tenant_id,
    pc.sku_canonico_premium as sku,
    
    -- Produto
    pc.linha_produto,
    pc.nome_base as nome,
    pc.descricao,
    
    -- Marca
    m.nome as marca,
    m.id as marca_id,
    m.pais_origem,
    
    -- Características
    pc.tipo_lente::text,
    pc.material::text,
    pc.indice_refracao,
    ARRAY_TO_JSON(pc.tratamentos_base) as tratamentos,
    pc.specs_tecnicas,
    
    -- Disponibilidade
    COUNT(DISTINCT l.laboratorio_id) as qtd_laboratorios,
    
    -- Labs que vendem
    JSON_AGG(
        DISTINCT JSONB_BUILD_OBJECT(
            'laboratorio_id', lab.id,
            'laboratorio', lab.nome_fantasia,
            'sku_laboratorio', l.sku_laboratorio
        )
    ) FILTER (WHERE lab.id IS NOT NULL) as laboratorios,
    
    pc.ativo,
    pc.criado_em
    
FROM lens_catalog.premium_canonicas pc
JOIN lens_catalog.marcas m ON m.id = pc.marca_id
LEFT JOIN lens_catalog.lentes l ON l.premium_canonica_id = pc.id AND l.ativo = TRUE
LEFT JOIN suppliers.laboratorios lab ON lab.id = l.laboratorio_id
WHERE pc.ativo = TRUE
GROUP BY pc.id, m.id, m.nome, m.pais_origem;

COMMENT ON VIEW public.vw_produtos_premium IS 'Catálogo de produtos premium com labs disponíveis';

-- ============================================
-- 5.3: VIEW - Produtos Genéricos (Catálogo)
-- ============================================

CREATE OR REPLACE VIEW public.vw_produtos_genericos AS
SELECT 
    lc.id,
    lc.tenant_id,
    lc.sku_canonico as sku,
    
    -- Produto
    lc.nome_comercial as nome,
    lc.linha_produto as descricao,
    
    -- Características
    lc.tipo_lente,
    lc.material,
    lc.indice_refracao,
    
    -- Tratamentos (converter flags para array)
    JSON_BUILD_ARRAY(
        CASE WHEN lc.tem_ar THEN 'AR' END,
        CASE WHEN lc.tem_blue THEN 'BLUE' END,
        CASE WHEN lc.tem_hc THEN 'HC' END,
        CASE WHEN lc.tem_polarizado THEN 'POLAR' END,
        CASE WHEN lc.tem_fotossensivel THEN 'FOTO' END
    ) as tratamentos,
    lc.tratamentos_detalhes,
    lc.specs_tecnicas,
    
    -- Disponibilidade
    COUNT(DISTINCT l.laboratorio_id) as qtd_laboratorios,
    
    -- Labs que vendem
    JSON_AGG(
        DISTINCT JSONB_BUILD_OBJECT(
            'laboratorio_id', lab.id,
            'laboratorio', lab.nome_fantasia,
            'marca', m.nome,
            'sku_laboratorio', l.sku_laboratorio
        )
    ) FILTER (WHERE lab.id IS NOT NULL) as laboratorios,
    
    lc.ativo,
    lc.criado_em
    
FROM lens_catalog.lentes_canonicas lc
LEFT JOIN lens_catalog.lentes l ON l.lente_canonica_id = lc.id AND l.ativo = TRUE
LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
LEFT JOIN suppliers.laboratorios lab ON lab.id = l.laboratorio_id
WHERE lc.ativo = TRUE
GROUP BY lc.id;

COMMENT ON VIEW public.vw_produtos_genericos IS 'Catálogo de produtos genéricos com labs disponíveis';

-- ============================================
-- 5.4: VIEW - Marcas (Dropdown)
-- ============================================

CREATE OR REPLACE VIEW public.vw_marcas AS
SELECT 
    m.id,
    m.tenant_id,
    m.nome,
    m.pais_origem,
    
    -- Estatísticas
    COUNT(DISTINCT CASE WHEN l.is_premium THEN l.id END) as produtos_premium,
    COUNT(DISTINCT CASE WHEN NOT l.is_premium THEN l.id END) as produtos_genericos,
    COUNT(DISTINCT l.id) as total_produtos,
    
    m.ativo,
    m.criado_em
    
FROM lens_catalog.marcas m
LEFT JOIN lens_catalog.lentes l ON l.marca_id = m.id AND l.ativo = TRUE
WHERE m.ativo = TRUE
GROUP BY m.id
ORDER BY m.nome;

COMMENT ON VIEW public.vw_marcas IS 'Lista de marcas para dropdowns e filtros';

-- ============================================
-- 5.5: VIEW - Laboratórios (Dropdown)
-- ============================================

CREATE OR REPLACE VIEW public.vw_laboratorios AS
SELECT 
    lab.id,
    lab.tenant_id,
    lab.nome_fantasia as nome,
    lab.razao_social,
    lab.cnpj,
    
    -- Estatísticas
    COUNT(DISTINCT l.id) as total_produtos,
    COUNT(DISTINCT CASE WHEN l.is_premium THEN l.id END) as produtos_premium,
    
    lab.ativo,
    lab.criado_em
    
FROM suppliers.laboratorios lab
LEFT JOIN lens_catalog.lentes l ON l.laboratorio_id = lab.id AND l.ativo = TRUE
WHERE lab.ativo = TRUE
GROUP BY lab.id
ORDER BY lab.nome_fantasia;

COMMENT ON VIEW public.vw_laboratorios IS 'Lista de laboratórios para dropdowns e filtros';

-- ============================================
-- 5.6: VIEW - Filtros Disponíveis
-- ============================================

CREATE OR REPLACE VIEW public.vw_filtros_disponiveis AS
SELECT 
    tenant_id,
    
    -- Tipos de lente
    JSON_AGG(DISTINCT tipo_lente) FILTER (WHERE tipo_lente IS NOT NULL) as tipos_lente,
    
    -- Materiais
    JSON_AGG(DISTINCT material) FILTER (WHERE material IS NOT NULL) as materiais,
    
    -- Índices de refração
    JSON_AGG(DISTINCT indice_refracao ORDER BY indice_refracao) FILTER (WHERE indice_refracao IS NOT NULL) as indices,
    
    -- Tratamentos disponíveis
    JSON_AGG(DISTINCT tratamento) FILTER (WHERE tratamento IS NOT NULL) as tratamentos,
    
    -- Designs
    JSON_AGG(DISTINCT design) FILTER (WHERE design IS NOT NULL) as designs
    
FROM (
    SELECT 
        l.tenant_id,
        l.tipo_lente::text,
        l.material::text,
        l.indice_refracao,
        UNNEST(l.tratamentos)::text as tratamento,
        l.design
    FROM lens_catalog.lentes l
    WHERE l.ativo = TRUE
) sub
GROUP BY tenant_id;

COMMENT ON VIEW public.vw_filtros_disponiveis IS 'Filtros disponíveis para busca (tipos, materiais, índices, etc)';

-- ============================================
-- 5.7: VIEW - Comparar Labs
-- ============================================

CREATE OR REPLACE VIEW public.vw_comparar_labs AS
SELECT 
    COALESCE(l.premium_canonica_id, l.lente_canonica_id) as grupo_id,
    l.tenant_id,
    
    -- Produto
    CASE 
        WHEN l.is_premium THEN pc.nome_base
        ELSE lc.nome_comercial
    END as produto,
    
    CASE 
        WHEN l.is_premium THEN 'PREMIUM'
        ELSE 'GENÉRICA'
    END as tipo,
    
    -- Marca (se premium)
    m.nome as marca,
    
    -- Características
    l.tipo_lente::text,
    l.material::text,
    l.indice_refracao,
    ARRAY_TO_JSON(l.tratamentos) as tratamentos,
    
    -- Comparação de Labs
    JSON_AGG(
        JSON_BUILD_OBJECT(
            'lente_id', l.id,
            'sku', l.sku_canonico,
            'sku_laboratorio', l.sku_laboratorio,
            'laboratorio_id', lab.id,
            'laboratorio', lab.nome_fantasia,
            'disponivel', TRUE
        )
    ) as opcoes_labs,
    
    -- Estatísticas
    COUNT(DISTINCT l.laboratorio_id) as qtd_labs
    
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.premium_canonicas pc ON pc.id = l.premium_canonica_id
LEFT JOIN lens_catalog.lentes_canonicas lc ON lc.id = l.lente_canonica_id
LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
LEFT JOIN suppliers.laboratorios lab ON lab.id = l.laboratorio_id
WHERE l.ativo = TRUE
  AND (l.premium_canonica_id IS NOT NULL OR l.lente_canonica_id IS NOT NULL)
GROUP BY 
    COALESCE(l.premium_canonica_id, l.lente_canonica_id),
    l.tenant_id,
    l.is_premium,
    pc.nome_base,
    lc.nome_comercial,
    m.nome,
    l.tipo_lente,
    l.material,
    l.indice_refracao,
    l.tratamentos
HAVING COUNT(DISTINCT l.laboratorio_id) > 0;

COMMENT ON VIEW public.vw_comparar_labs IS 'Comparação do mesmo produto em diferentes labs';

-- ============================================
-- 5.8: FUNCTION - Buscar Lentes (API)
-- ============================================

CREATE OR REPLACE FUNCTION public.fn_api_buscar_lentes(
    p_tenant_id UUID,
    p_tipo_lente TEXT DEFAULT NULL,
    p_material TEXT DEFAULT NULL,
    p_indice_min NUMERIC DEFAULT NULL,
    p_indice_max NUMERIC DEFAULT NULL,
    p_tratamentos TEXT[] DEFAULT NULL,
    p_marca_id UUID DEFAULT NULL,
    p_laboratorio_id UUID DEFAULT NULL,
    p_apenas_premium BOOLEAN DEFAULT FALSE,
    p_ordenar_por TEXT DEFAULT 'nome',  -- 'nome', 'marca', 'tipo'
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    lente_id UUID,
    sku TEXT,
    nome TEXT,
    tipo TEXT,
    marca TEXT,
    laboratorio TEXT,
    labs_disponiveis BIGINT,
    caracteristicas JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.lente_id,
        v.sku,
        v.nome_produto as nome,
        v.tipo,
        v.marca,
        v.laboratorio,
        v.labs_disponiveis,
        JSONB_BUILD_OBJECT(
            'tipo_lente', v.tipo_lente,
            'material', v.material,
            'indice', v.indice_refracao,
            'tratamentos', v.tratamentos,
            'design', v.design,
            'corredor', v.corredor_progressao
        ) as caracteristicas
    FROM public.vw_buscar_lentes v
    WHERE v.tenant_id = p_tenant_id
      AND (p_tipo_lente IS NULL OR v.tipo_lente::text = p_tipo_lente)
      AND (p_material IS NULL OR v.material = p_material)
      AND (p_indice_min IS NULL OR v.indice_refracao >= p_indice_min)
      AND (p_indice_max IS NULL OR v.indice_refracao <= p_indice_max)
      AND (p_tratamentos IS NULL OR v.tratamentos::text[] @> p_tratamentos)
      AND (p_marca_id IS NULL OR v.marca_id = p_marca_id)
      AND (p_laboratorio_id IS NULL OR v.laboratorio_id = p_laboratorio_id)
      AND (p_apenas_premium = FALSE OR v.tipo = 'PREMIUM')
    ORDER BY 
        CASE WHEN p_ordenar_por = 'nome' THEN v.nome_produto END,
        CASE WHEN p_ordenar_por = 'marca' THEN v.marca END,
        CASE WHEN p_ordenar_por = 'tipo' THEN v.tipo END
    LIMIT p_limite
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.fn_api_buscar_lentes IS 'API de busca de lentes para frontend - com filtros completos';

-- ============================================
-- 5.9: FUNCTION - Detalhes da Lente (API)
-- ============================================

CREATE OR REPLACE FUNCTION public.fn_api_detalhes_lente(
    p_lente_id UUID,
    p_tenant_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_resultado JSON;
BEGIN
    SELECT JSON_BUILD_OBJECT(
        'lente', JSON_BUILD_OBJECT(
            'id', v.lente_id,
            'sku', v.sku,
            'nome', v.nome_produto,
            'tipo', v.tipo,
            'nivel_qualidade', v.nivel_qualidade
        ),
        'marca', JSON_BUILD_OBJECT(
            'id', v.marca_id,
            'nome', v.marca
        ),
        'laboratorio', JSON_BUILD_OBJECT(
            'id', v.laboratorio_id,
            'nome', v.laboratorio,
            'codigo_produto', v.codigo_laboratorio
        ),
        'caracteristicas', JSON_BUILD_OBJECT(
            'tipo_lente', v.tipo_lente,
            'material', v.material,
            'indice_refracao', v.indice_refracao,
            'tratamentos', v.tratamentos,
            'design', v.design,
            'corredor_progressao', v.corredor_progressao
        ),
        'alternativas', (
            SELECT JSON_AGG(
                JSON_BUILD_OBJECT(
                    'lente_id', alt.lente_id,
                    'laboratorio', alt.laboratorio,
                    'sku_laboratorio', alt.codigo_laboratorio
                ) ORDER BY alt.laboratorio
            )
            FROM public.vw_buscar_lentes alt
            WHERE alt.grupo_canonico_id = v.grupo_canonico_id
              AND alt.lente_id != v.lente_id
              AND alt.tenant_id = p_tenant_id
        ),
        'metadata', JSON_BUILD_OBJECT(
            'labs_disponiveis', v.labs_disponiveis,
            'criado_em', v.criado_em,
            'atualizado_em', v.atualizado_em
        )
    ) INTO v_resultado
    FROM public.vw_buscar_lentes v
    WHERE v.lente_id = p_lente_id
      AND v.tenant_id = p_tenant_id;
    
    RETURN v_resultado;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.fn_api_detalhes_lente IS 'Detalhes completos de uma lente incluindo alternativas';

-- ============================================
-- VERIFICAÇÃO FINAL
-- ============================================

SELECT 'Public Views criadas com sucesso!' as status;

-- Listar todas as views públicas
SELECT 
    table_name as view_name,
    COALESCE(obj_description(('"public"."' || table_name || '"')::regclass), 'Sem descrição') as descricao
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE 'vw_%'
ORDER BY table_name;


| view_name                   | descricao                                                                        |
| --------------------------- | -------------------------------------------------------------------------------- |
| vw_buscar_lentes            | Motor de busca de lentes - consumo do frontend                                   |
| vw_comparar_labs            | Comparação do mesmo produto em diferentes labs                                   |
| vw_filtros_disponiveis      | Filtros disponíveis para busca (tipos, materiais, índices, etc)                  |
| vw_fornecedores             | Sem descrição                                                                    |
| vw_fornecedores_disponiveis | Sem descrição                                                                    |
| vw_historico_decisoes       | Histórico de decisões com alternativas - Facilita dashboard e relatórios         |
| vw_laboratorios             | Lista de laboratórios para dropdowns e filtros                                   |
| vw_laboratorios_completo    | 🏅 View enriquecida com scores e badges - RESOLVE GAP #2 (Laboratórios com Alma) |
| vw_lentes_catalogo          | Sem descrição                                                                    |
| vw_marcas                   | Lista de marcas para dropdowns e filtros                                         |
| vw_produtos_genericos       | Catálogo de produtos genéricos com labs disponíveis                              |
| vw_produtos_premium         | Catálogo de produtos premium com labs disponíveis                                |
| vw_ranking_atual            | Ranking enriquecido com badges e scores dos laboratórios                         |
| vw_ranking_opcoes           | Sem descrição                                                                    |
| vw_todas_lentes             | Sem descrição                                                                    |
| vw_usuarios                 | Sem descrição                                                                    |