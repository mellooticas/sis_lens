-- ============================================
-- PASSO 6: VIEWS COMPLEMENTARES PARA FRONTEND
-- ============================================
-- Cria views adicionais em public que facilitam
-- o consumo dos dados já existentes em lens_catalog
--
-- IMPORTANTE: Não altera tabelas em lens_catalog
-- Apenas cria views úteis para o frontend
-- ============================================

-- ============================================
-- 6.1: VIEW DE CATÁLOGO COMPLETO UNIFICADO
-- ============================================
-- Une lentes + lentes_canonicas + premium_canonicas

CREATE OR REPLACE VIEW public.vw_catalogo_completo AS
SELECT 
    -- Identificação
    l.id as lente_id,
    l.tenant_id,
    l.sku_canonico,
    l.sku_laboratorio,
    
    -- Classificação
    CASE 
        WHEN l.is_premium THEN 'PREMIUM'
        ELSE 'GENÉRICA'
    END as tipo_lente,
    
    l.is_premium,
    l.nivel_qualidade,
    
    -- Marca
    m.nome as marca,
    m.id as marca_id,
    m.pais_origem,
    m.tier as tier_marca,
    
    -- Laboratório
    lab.nome_fantasia as laboratorio,
    l.laboratorio_id,
    lab.cnpj as cnpj_lab,
    
    -- Nomes comerciais
    l.nome_comercial,
    l.familia,
    
    -- Canônicas (COALESCE entre genérica e premium)
    COALESCE(c.nome_comercial, pc.nome_base) as nome_canonico,
    
    -- Características técnicas principais
    l.tipo_lente::text as tipo,
    l.material::text,
    l.indice_refracao,
    l.categoria::text,
    
    -- Tratamentos (booleanos + array)
    l.tem_ar,
    l.tem_blue,
    l.tem_hc,
    l.tem_polarizado,
    l.tem_fotossensivel,
    l.tem_tintavel,
    ARRAY_TO_JSON(l.tratamentos) as tratamentos,
    
    -- Especificações adicionais
    l.design,
    l.corredor_progressao,
    l.specs_tecnicas,
    
    -- Vínculos para navegação
    l.lente_canonica_id,
    l.premium_canonica_id,
    
    -- Metadata
    l.ativo,
    l.criado_em,
    l.atualizado_em
    
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
LEFT JOIN suppliers.laboratorios lab ON lab.id = l.laboratorio_id
LEFT JOIN lens_catalog.lentes_canonicas c ON c.id = l.lente_canonica_id
LEFT JOIN lens_catalog.premium_canonicas pc ON pc.id = l.premium_canonica_id
WHERE l.ativo = true;

COMMENT ON VIEW public.vw_catalogo_completo IS 
'Catálogo completo unificado: lentes genéricas + premium com todas as informações';

-- ============================================
-- 6.2: VIEW DE COMPARAÇÃO POR CANÔNICA
-- ============================================
-- Agrupa lentes pela canônica para comparar labs/preços

CREATE OR REPLACE VIEW public.vw_lentes_por_canonica AS
SELECT 
    -- Identificador da canônica
    COALESCE(l.lente_canonica_id, l.premium_canonica_id) as canonica_id,
    
    -- Tipo da canônica
    CASE 
        WHEN l.lente_canonica_id IS NOT NULL THEN 'GENÉRICA'
        WHEN l.premium_canonica_id IS NOT NULL THEN 'PREMIUM'
        ELSE 'SEM_CANONICA'
    END as tipo_canonica,
    
    -- Nome do produto canônico
    COALESCE(c.nome_comercial, pc.nome_base, 'Sem agrupamento') as produto,
    
    -- Características canônicas
    COALESCE(c.tipo_lente::text, pc.tipo_lente::text, l.tipo_lente::text) as tipo_lente,
    COALESCE(c.material::text, pc.material::text, l.material::text) as material,
    COALESCE(c.indice_refracao, pc.indice_refracao, l.indice_refracao) as indice,
    
    -- Marca (só para premium)
    m.nome as marca_premium,
    
    -- Tratamentos comuns
    COALESCE(c.tem_ar, pc.tem_ar, false) as tem_ar,
    COALESCE(c.tem_blue, pc.tem_blue, false) as tem_blue,
    COALESCE(c.tem_fotossensivel, pc.tem_fotossensivel, false) as tem_fotossensivel,
    
    -- Agregação de laboratórios disponíveis
    COUNT(DISTINCT l.laboratorio_id) as qtd_labs_disponiveis,
    ARRAY_AGG(DISTINCT lab.nome_fantasia ORDER BY lab.nome_fantasia) 
        FILTER (WHERE lab.nome_fantasia IS NOT NULL) as labs_disponiveis,
    
    -- IDs das lentes individuais
    ARRAY_AGG(l.id ORDER BY l.nivel_qualidade DESC, l.criado_em) as lente_ids,
    
    -- Níveis de qualidade disponíveis
    ARRAY_AGG(DISTINCT l.nivel_qualidade ORDER BY l.nivel_qualidade DESC) 
        FILTER (WHERE l.nivel_qualidade IS NOT NULL) as niveis_qualidade
    
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.lentes_canonicas c ON c.id = l.lente_canonica_id
LEFT JOIN lens_catalog.premium_canonicas pc ON pc.id = l.premium_canonica_id
LEFT JOIN lens_catalog.marcas m ON m.id = pc.marca_id
LEFT JOIN suppliers.laboratorios lab ON lab.id = l.laboratorio_id
WHERE l.ativo = true
GROUP BY 
    COALESCE(l.lente_canonica_id, l.premium_canonica_id),
    CASE 
        WHEN l.lente_canonica_id IS NOT NULL THEN 'GENÉRICA'
        WHEN l.premium_canonica_id IS NOT NULL THEN 'PREMIUM'
        ELSE 'SEM_CANONICA'
    END,
    COALESCE(c.nome_comercial, pc.nome_base, 'Sem agrupamento'),
    COALESCE(c.tipo_lente::text, pc.tipo_lente::text, l.tipo_lente::text),
    COALESCE(c.material::text, pc.material::text, l.material::text),
    COALESCE(c.indice_refracao, pc.indice_refracao, l.indice_refracao),
    COALESCE(c.tem_ar, pc.tem_ar, false),
    COALESCE(c.tem_blue, pc.tem_blue, false),
    COALESCE(c.tem_fotossensivel, pc.tem_fotossensivel, false),
    m.nome;

COMMENT ON VIEW public.vw_lentes_por_canonica IS 
'Agrupa lentes por canônica mostrando labs disponíveis - útil para comparação';

-- ============================================
-- 6.3: VIEW DE LENTES SEM CANÔNICA (ÓRFÃS)
-- ============================================
-- Identifica lentes que ainda não foram agrupadas

CREATE OR REPLACE VIEW public.vw_lentes_orfas AS
SELECT 
    l.id,
    l.sku_canonico,
    l.sku_laboratorio,
    l.nome_comercial,
    l.familia,
    l.tipo_lente::text,
    l.material::text,
    l.indice_refracao,
    l.categoria::text,
    l.tem_ar,
    l.tem_blue,
    l.tem_fotossensivel,
    l.nivel_qualidade,
    m.nome as marca,
    lab.nome_fantasia as laboratorio,
    l.criado_em
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
LEFT JOIN suppliers.laboratorios lab ON lab.id = l.laboratorio_id
WHERE l.ativo = true
  AND l.lente_canonica_id IS NULL
  AND l.premium_canonica_id IS NULL
ORDER BY l.criado_em DESC;

COMMENT ON VIEW public.vw_lentes_orfas IS 
'Lentes sem vínculo canônico - precisam ser analisadas e agrupadas';

-- ============================================
-- 6.4: VIEW DE MARCAS COM ESTATÍSTICAS
-- ============================================
-- Marcas com contagem de produtos

CREATE OR REPLACE VIEW public.vw_marcas_estatisticas AS
SELECT 
    m.id,
    m.nome,
    m.nome_fantasia,
    m.pais_origem,
    m.tier,
    m.ativo,
    
    -- Contagens
    COUNT(DISTINCT l.id) as total_produtos,
    COUNT(DISTINCT l.id) FILTER (WHERE l.is_premium) as total_premium,
    COUNT(DISTINCT l.id) FILTER (WHERE NOT l.is_premium) as total_genericas,
    
    -- Níveis de qualidade
    ARRAY_AGG(DISTINCT l.nivel_qualidade ORDER BY l.nivel_qualidade DESC) 
        FILTER (WHERE l.nivel_qualidade IS NOT NULL) as niveis_disponiveis,
    
    -- Tipos de lente
    ARRAY_AGG(DISTINCT l.tipo_lente::text ORDER BY l.tipo_lente::text) 
        FILTER (WHERE l.tipo_lente IS NOT NULL) as tipos_lente,
    
    -- Laboratórios que produzem
    COUNT(DISTINCT l.laboratorio_id) as qtd_labs_produzem,
    
    m.criado_em
    
FROM lens_catalog.marcas m
LEFT JOIN lens_catalog.lentes l ON l.marca_id = m.id AND l.ativo = true
WHERE m.ativo = true
GROUP BY m.id, m.nome, m.nome_fantasia, m.pais_origem, m.tier, m.ativo, m.criado_em;

COMMENT ON VIEW public.vw_marcas_estatisticas IS 
'Marcas com estatísticas de produtos, labs e tipos de lente';

-- ============================================
-- 6.5: VIEW DE LABORATÓRIOS COM ESTATÍSTICAS
-- ============================================
-- Laboratórios com contagem de produtos

CREATE OR REPLACE VIEW public.vw_laboratorios_estatisticas AS
SELECT 
    lab.id,
    lab.nome_fantasia,
    lab.razao_social,
    lab.cnpj,
    lab.cidade,
    lab.uf,
    lab.ativo,
    
    -- Contagens
    COUNT(DISTINCT l.id) as total_produtos,
    COUNT(DISTINCT l.marca_id) as qtd_marcas_diferentes,
    
    -- Níveis de qualidade que produz
    ARRAY_AGG(DISTINCT l.nivel_qualidade ORDER BY l.nivel_qualidade DESC) 
        FILTER (WHERE l.nivel_qualidade IS NOT NULL) as niveis_produz,
    
    -- Tipos de lente que produz
    ARRAY_AGG(DISTINCT l.tipo_lente::text ORDER BY l.tipo_lente::text) 
        FILTER (WHERE l.tipo_lente IS NOT NULL) as tipos_produz,
    
    -- Categorias
    ARRAY_AGG(DISTINCT l.categoria::text ORDER BY l.categoria::text) 
        FILTER (WHERE l.categoria IS NOT NULL) as categorias_produz,
    
    lab.criado_em
    
FROM suppliers.laboratorios lab
LEFT JOIN lens_catalog.lentes l ON l.laboratorio_id = lab.id AND l.ativo = true
WHERE lab.ativo = true
GROUP BY lab.id, lab.nome_fantasia, lab.razao_social, lab.cnpj, 
         lab.cidade, lab.uf, lab.ativo, lab.criado_em;

COMMENT ON VIEW public.vw_laboratorios_estatisticas IS 
'Laboratórios com estatísticas de produção, tipos e categorias';

-- ============================================
-- 6.6: VIEW DE PRAZOS COM INFORMAÇÕES COMPLETAS
-- ============================================
-- Prazos com nome do laboratório e região

CREATE OR REPLACE VIEW public.vw_prazos_completos AS
SELECT 
    p.id,
    p.tenant_id,
    
    -- Laboratório
    lab.nome_fantasia as laboratorio,
    p.laboratorio_id,
    lab.cidade as cidade_lab,
    lab.uf as uf_lab,
    
    -- Região de entrega
    p.regiao_destino,
    
    -- Prazos
    p.prazo_dias,
    p.prazo_horas,
    p.prazo_display,
    
    -- Custos
    p.custo_envio,
    
    -- Validade
    p.data_inicio_vigencia,
    p.data_fim_vigencia,
    
    -- Status
    p.ativo,
    
    -- Metadata
    p.criado_em,
    p.atualizado_em
    
FROM logistics.tabela_prazos p
JOIN suppliers.laboratorios lab ON lab.id = p.laboratorio_id
WHERE p.ativo = true
ORDER BY lab.nome_fantasia, p.regiao_destino;

COMMENT ON VIEW public.vw_prazos_completos IS 
'Prazos de entrega com informações completas do laboratório e região';

-- ============================================
-- FIM DO PASSO 6
-- ============================================
-- Views criadas com sucesso!
-- Próximo passo: PASSO_7 (migração de dados canônicos)
