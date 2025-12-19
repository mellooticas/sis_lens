-- ============================================
-- 06_PUBLIC_VIEWS.sql
-- Views públicas para consumo do frontend
-- ============================================
-- 
-- Executar DEPOIS dos triggers de canonização
-- Views expõem dados do lens_catalog no schema public
-- ============================================

-- ============================================
-- VIEW 1: Buscar Lentes (Motor Principal)
-- ============================================

CREATE OR REPLACE VIEW public.vw_buscar_lentes AS
SELECT 
    -- IDs
    l.id,
    l.sku_fornecedor as sku,
    
    -- Produto
    l.nome_comercial,
    l.tipo_lente,
    l.material,
    l.indice_refracao,
    l.categoria,
    
    -- Marca e Fornecedor
    m.nome as marca,
    m.id as marca_id,
    m.is_premium as marca_premium,
    f.nome as fornecedor,
    f.id as fornecedor_id,
    
    -- Tratamentos
    l.ar,
    l.blue,
    l.fotossensivel,
    l.polarizado,
    l.antirrisco,
    l.uv400,
    
    -- Faixas Ópticas
    l.esferico_min,
    l.esferico_max,
    l.cilindrico_min,
    l.cilindrico_max,
    l.adicao_min,
    l.adicao_max,
    
    -- Especificações
    l.diametro,
    l.espessura_central,
    l.peso_aproximado,
    
    -- Preços
    l.custo_base,
    l.preco_tabela,
    
    -- Canônica (genérica OU premium)
    CASE 
        WHEN l.premium_canonica_id IS NOT NULL THEN 'premium'
        ELSE 'generica'
    END as tipo_canonica,
    COALESCE(pc.nome_canonico, lc.nome_canonico) as grupo_canonico,
    COALESCE(l.premium_canonica_id, l.lente_canonica_id) as canonica_id,
    
    -- Stats da Canônica
    COALESCE(pc.total_lentes, lc.total_lentes) as alternativas_disponiveis,
    COALESCE(pc.preco_minimo, lc.preco_minimo) as preco_min_grupo,
    COALESCE(pc.preco_maximo, lc.preco_maximo) as preco_max_grupo,
    COALESCE(pc.preco_medio, lc.preco_medio) as preco_medio_grupo,
    
    -- Metadata
    l.status,
    l.created_at,
    l.updated_at
    
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
LEFT JOIN pessoas.fornecedores f ON f.id = l.fornecedor_id
LEFT JOIN lens_catalog.lentes_canonicas lc ON lc.id = l.lente_canonica_id
LEFT JOIN lens_catalog.premium_canonicas pc ON pc.id = l.premium_canonica_id
WHERE l.status = 'ativo';

COMMENT ON VIEW public.vw_buscar_lentes IS 
'Motor de busca principal - expõe todas as lentes ativas com informações de marca, fornecedor e grupo canônico';

-- ============================================
-- VIEW 2: Grupos Canônicos Genéricos
-- ============================================

CREATE OR REPLACE VIEW public.vw_grupos_genericos AS
SELECT 
    lc.id,
    lc.nome_canonico,
    
    -- Características
    lc.tipo_lente,
    lc.material,
    lc.indice_refracao,
    lc.categoria,
    
    -- Tratamentos
    lc.ar,
    lc.blue,
    lc.fotossensivel,
    lc.polarizado,
    
    -- Faixas Ópticas
    lc.esferico_min,
    lc.esferico_max,
    lc.cilindrico_min,
    lc.cilindrico_max,
    lc.adicao_min,
    lc.adicao_max,
    
    -- Estatísticas
    lc.total_lentes,
    lc.preco_minimo,
    lc.preco_maximo,
    lc.preco_medio,
    
    -- Fornecedores disponíveis
    COUNT(DISTINCT l.fornecedor_id) as qtd_fornecedores,
    JSON_AGG(JSONB_BUILD_OBJECT(
        'fornecedor_id', f.id,
        'fornecedor', f.nome,
        'marca', m.nome,
        'preco', l.preco_tabela
    ) ORDER BY l.preco_tabela) FILTER (WHERE f.id IS NOT NULL) as opcoes_fornecedores,
    
    lc.ativo,
    lc.created_at
    
FROM lens_catalog.lentes_canonicas lc
LEFT JOIN lens_catalog.lentes l ON l.lente_canonica_id = lc.id AND l.status = 'ativo'
LEFT JOIN pessoas.fornecedores f ON f.id = l.fornecedor_id
LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
WHERE lc.ativo = TRUE
GROUP BY lc.id;

COMMENT ON VIEW public.vw_grupos_genericos IS 
'Grupos canônicos genéricos com lista de fornecedores e preços disponíveis';

-- ============================================
-- VIEW 3: Grupos Canônicos Premium
-- ============================================

CREATE OR REPLACE VIEW public.vw_grupos_premium AS
SELECT 
    pc.id,
    pc.nome_canonico,
    
    -- Marca (SEMPRE presente em premium)
    m.nome as marca,
    m.id as marca_id,
    
    -- Características
    pc.tipo_lente,
    pc.material,
    pc.indice_refracao,
    pc.categoria,
    
    -- Tratamentos
    pc.ar,
    pc.blue,
    pc.fotossensivel,
    pc.polarizado,
    
    -- Faixas Ópticas
    pc.esferico_min,
    pc.esferico_max,
    pc.cilindrico_min,
    pc.cilindrico_max,
    pc.adicao_min,
    pc.adicao_max,
    
    -- Estatísticas
    pc.total_lentes,
    pc.preco_minimo,
    pc.preco_maximo,
    pc.preco_medio,
    
    -- Fornecedores disponíveis
    COUNT(DISTINCT l.fornecedor_id) as qtd_fornecedores,
    JSON_AGG(JSONB_BUILD_OBJECT(
        'fornecedor_id', f.id,
        'fornecedor', f.nome,
        'preco', l.preco_tabela
    ) ORDER BY l.preco_tabela) FILTER (WHERE f.id IS NOT NULL) as opcoes_fornecedores,
    
    pc.ativo,
    pc.created_at
    
FROM lens_catalog.premium_canonicas pc
JOIN lens_catalog.marcas m ON m.id = pc.marca_id
LEFT JOIN lens_catalog.lentes l ON l.premium_canonica_id = pc.id AND l.status = 'ativo'
LEFT JOIN pessoas.fornecedores f ON f.id = l.fornecedor_id
WHERE pc.ativo = TRUE
GROUP BY pc.id, m.id, m.nome;

COMMENT ON VIEW public.vw_grupos_premium IS 
'Grupos canônicos premium (por marca) com lista de fornecedores e preços disponíveis';

-- ============================================
-- VIEW 4: Marcas (Dropdown)
-- ============================================

CREATE OR REPLACE VIEW public.vw_marcas AS
SELECT 
    m.id,
    m.nome,
    m.slug,
    m.is_premium,
    m.descricao,
    
    -- Estatísticas
    COUNT(DISTINCT CASE WHEN l.premium_canonica_id IS NOT NULL THEN l.id END) as lentes_premium,
    COUNT(DISTINCT CASE WHEN l.lente_canonica_id IS NOT NULL THEN l.id END) as lentes_genericas,
    COUNT(DISTINCT l.id) as total_lentes,
    
    m.ativo,
    m.created_at
    
FROM lens_catalog.marcas m
LEFT JOIN lens_catalog.lentes l ON l.marca_id = m.id AND l.status = 'ativo'
WHERE m.ativo = TRUE
GROUP BY m.id
ORDER BY m.nome;

COMMENT ON VIEW public.vw_marcas IS 
'Lista de marcas com estatísticas para dropdowns e filtros';

-- ============================================
-- VIEW 5: Fornecedores (Dropdown)
-- ============================================

CREATE OR REPLACE VIEW public.vw_fornecedores AS
SELECT 
    f.id,
    f.nome,
    f.razao_social,
    f.cnpj,
    
    -- Estatísticas
    COUNT(DISTINCT l.id) as total_lentes,
    COUNT(DISTINCT l.marca_id) as qtd_marcas,
    MIN(l.preco_tabela) as preco_minimo,
    MAX(l.preco_tabela) as preco_maximo,
    ROUND(AVG(l.preco_tabela)::numeric, 2) as preco_medio,
    
    f.ativo,
    f.created_at
    
FROM pessoas.fornecedores f
LEFT JOIN lens_catalog.lentes l ON l.fornecedor_id = f.id AND l.status = 'ativo'
WHERE f.ativo = TRUE
GROUP BY f.id
ORDER BY f.nome;

COMMENT ON VIEW public.vw_fornecedores IS 
'Lista de fornecedores com estatísticas para dropdowns e comparações';

-- ============================================
-- VIEW 6: Filtros Disponíveis
-- ============================================

CREATE OR REPLACE VIEW public.vw_filtros_disponiveis AS
SELECT 
    -- Tipos de lente
    JSON_AGG(DISTINCT tipo_lente ORDER BY tipo_lente) as tipos_lente,
    
    -- Materiais
    JSON_AGG(DISTINCT material ORDER BY material) as materiais,
    
    -- Índices de refração
    JSON_AGG(DISTINCT indice_refracao ORDER BY indice_refracao) as indices_refracao,
    
    -- Categorias
    JSON_AGG(DISTINCT categoria ORDER BY categoria) as categorias,
    
    -- Fotossensível
    JSON_AGG(DISTINCT fotossensivel ORDER BY fotossensivel) 
        FILTER (WHERE fotossensivel != 'nenhum') as tipos_fotossensiveis,
    
    -- Tratamentos (flags booleanas)
    JSON_BUILD_OBJECT(
        'ar', COUNT(*) FILTER (WHERE ar = true) > 0,
        'blue', COUNT(*) FILTER (WHERE blue = true) > 0,
        'polarizado', COUNT(*) FILTER (WHERE polarizado = true) > 0,
        'antirrisco', COUNT(*) FILTER (WHERE antirrisco = true) > 0,
        'uv400', COUNT(*) FILTER (WHERE uv400 = true) > 0
    ) as tratamentos_disponiveis
    
FROM lens_catalog.lentes
WHERE status = 'ativo';

COMMENT ON VIEW public.vw_filtros_disponiveis IS 
'Valores disponíveis para todos os filtros de busca';

-- ============================================
-- VIEW 7: Comparar Fornecedores (mesmo produto)
-- ============================================

CREATE OR REPLACE VIEW public.vw_comparar_fornecedores AS
SELECT 
    COALESCE(l.premium_canonica_id, l.lente_canonica_id) as grupo_id,
    
    CASE 
        WHEN l.premium_canonica_id IS NOT NULL THEN pc.nome_canonico
        ELSE lc.nome_canonico
    END as produto,
    
    CASE 
        WHEN l.premium_canonica_id IS NOT NULL THEN 'PREMIUM'
        ELSE 'GENÉRICA'
    END as tipo,
    
    -- Marca (se premium)
    m.nome as marca,
    
    -- Características do grupo
    l.tipo_lente,
    l.material,
    l.indice_refracao,
    l.categoria,
    
    -- Array de fornecedores com preços
    JSON_AGG(
        JSON_BUILD_OBJECT(
            'lente_id', l.id,
            'sku', l.sku_fornecedor,
            'fornecedor_id', f.id,
            'fornecedor', f.nome,
            'marca', m.nome,
            'preco_tabela', l.preco_tabela,
            'custo_base', l.custo_base,
            'nome_comercial', l.nome_comercial
        ) ORDER BY l.preco_tabela
    ) as opcoes
    
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
LEFT JOIN pessoas.fornecedores f ON f.id = l.fornecedor_id
LEFT JOIN lens_catalog.lentes_canonicas lc ON lc.id = l.lente_canonica_id
LEFT JOIN lens_catalog.premium_canonicas pc ON pc.id = l.premium_canonica_id
WHERE l.status = 'ativo'
  AND (l.lente_canonica_id IS NOT NULL OR l.premium_canonica_id IS NOT NULL)
GROUP BY 
    l.premium_canonica_id,
    l.lente_canonica_id,
    pc.nome_canonico,
    lc.nome_canonico,
    l.tipo_lente,
    l.material,
    l.indice_refracao,
    l.categoria,
    m.nome;

COMMENT ON VIEW public.vw_comparar_fornecedores IS 
'Comparação de preços entre fornecedores para o mesmo produto canônico';

-- ============================================
-- VIEW 8: Estatísticas do Catálogo
-- ============================================

CREATE OR REPLACE VIEW public.vw_stats_catalogo AS
SELECT 
    -- Totais gerais
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE status = 'ativo') as total_lentes,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE status = 'ativo' AND lente_canonica_id IS NOT NULL) as lentes_genericas,
    (SELECT COUNT(*) FROM lens_catalog.lentes WHERE status = 'ativo' AND premium_canonica_id IS NOT NULL) as lentes_premium,
    
    -- Grupos canônicos
    (SELECT COUNT(*) FROM lens_catalog.lentes_canonicas WHERE ativo = true) as grupos_genericos,
    (SELECT COUNT(*) FROM lens_catalog.premium_canonicas WHERE ativo = true) as grupos_premium,
    
    -- Marcas e Fornecedores
    (SELECT COUNT(*) FROM lens_catalog.marcas WHERE ativo = true) as total_marcas,
    (SELECT COUNT(*) FROM lens_catalog.marcas WHERE ativo = true AND is_premium = true) as marcas_premium,
    (SELECT COUNT(*) FROM pessoas.fornecedores WHERE ativo = true) as total_fornecedores,
    
    -- Faixas de preço
    (SELECT MIN(preco_tabela) FROM lens_catalog.lentes WHERE status = 'ativo') as preco_minimo_catalogo,
    (SELECT MAX(preco_tabela) FROM lens_catalog.lentes WHERE status = 'ativo') as preco_maximo_catalogo,
    (SELECT ROUND(AVG(preco_tabela)::numeric, 2) FROM lens_catalog.lentes WHERE status = 'ativo') as preco_medio_catalogo;

COMMENT ON VIEW public.vw_stats_catalogo IS 
'Estatísticas gerais do catálogo de lentes';

-- ============================================
-- VERIFICAÇÃO
-- ============================================

-- Testar todas as views
SELECT 'vw_buscar_lentes' as view_name, COUNT(*) as registros FROM public.vw_buscar_lentes
UNION ALL
SELECT 'vw_grupos_genericos', COUNT(*) FROM public.vw_grupos_genericos
UNION ALL
SELECT 'vw_grupos_premium', COUNT(*) FROM public.vw_grupos_premium
UNION ALL
SELECT 'vw_marcas', COUNT(*) FROM public.vw_marcas
UNION ALL
SELECT 'vw_fornecedores', COUNT(*) FROM public.vw_fornecedores;

| view_name           | registros |
| ------------------- | --------- |
| vw_buscar_lentes    | 1411      |
| vw_grupos_genericos | 187       |
| vw_grupos_premium   | 250       |
| vw_marcas           | 7         |
| vw_fornecedores     | 5         |

-- Ver exemplo de busca
SELECT 
    nome_comercial,
    marca,
    fornecedor,
    tipo_canonica,
    grupo_canonico,
    alternativas_disponiveis,
    preco_tabela,
    preco_medio_grupo
FROM public.vw_buscar_lentes
LIMIT 5;

| nome_comercial                                 | marca    | fornecedor | tipo_canonica | grupo_canonico                           | alternativas_disponiveis | preco_tabela | preco_medio_grupo |
| ---------------------------------------------- | -------- | ---------- | ------------- | ---------------------------------------- | ------------------------ | ------------ | ----------------- |
| FREEVIEW HDI 1.67 BLUE FILTER AR FAST TITANIUM | SOBLOCOS | So Blocos  | premium       | SOBLOCOS visao_simples CR39 1.67         | 36                       | 5395.00      | 5113.49           |
| SYGMA PRIME 1.67 PHOTO BLUECUT                 | EXPRESS  | Express    | premium       | EXPRESS visao_simples CR39 1.67          | 2                        | 1867.50      | 1929.75           |
| MULTI 1.49 FREEVIEW SILVER AR FAST SH          | SOBLOCOS | So Blocos  | premium       | SOBLOCOS visao_simples CR39 1.50         | 57                       | 2136.00      | 2435.02           |
| VS HDI 1.74 SLIM BLUE FILTER AR FAST AZUL      | SOBLOCOS | So Blocos  | premium       | SOBLOCOS visao_simples CR39 1.74         | 24                       | 6116.10      | 6215.43           |
| LT 1.59 POLICARBONATO FOTO AR (RESIDUAL VERDE) | EXPRESS  | Express    | premium       | EXPRESS visao_simples POLICARBONATO 1.59 | 1                        | 120.00       | 120.00            |


-- Ver filtros disponíveis
SELECT * FROM public.vw_filtros_disponiveis;

| tipos_lente                              | materiais                         | indices_refracao                            | categorias                                              | tipos_fotossensiveis            | tratamentos_disponiveis                                                   |
| ---------------------------------------- | --------------------------------- | ------------------------------------------- | ------------------------------------------------------- | ------------------------------- | ------------------------------------------------------------------------- |
| ["visao_simples","multifocal","bifocal"] | ["CR39","POLICARBONATO","TRIVEX"] | ["1.50","1.56","1.59","1.61","1.67","1.74"] | ["economica","intermediaria","premium","super_premium"] | ["transitions","fotocromático"] | {"ar":true,"blue":true,"polarizado":true,"antirrisco":false,"uv400":true} |



-- Ver estatísticas
SELECT * FROM public.vw_stats_catalogo;

| total_lentes | lentes_genericas | lentes_premium | grupos_genericos | grupos_premium | total_marcas | marcas_premium | total_fornecedores | preco_minimo_catalogo | preco_maximo_catalogo | preco_medio_catalogo |
| ------------ | ---------------- | -------------- | ---------------- | -------------- | ------------ | -------------- | ------------------ | --------------------- | --------------------- | -------------------- |
| 1411         | 0                | 1411           | 187              | 250            | 7            | 6              | 5                  | 36.00                 | 9640.00               | 3563.56              |