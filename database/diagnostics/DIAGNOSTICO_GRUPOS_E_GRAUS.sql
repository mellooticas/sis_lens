-- ============================================================================
-- DIAGNÓSTICO: Grupos Canônicos e Campos de Grau
-- ============================================================================
-- Data: 2026-01-21
-- Objetivo: Verificar a estrutura e dados dos grupos canônicos que contêm
--           informações de graus (grupo_nome e grupo_slug)
-- ============================================================================

-- 1. ESTRUTURA DA TABELA DE GRUPOS CANÔNICOS
-- ============================================================================
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'lens_catalog' 
  AND table_name = 'grupos_canonicos'
ORDER BY ordinal_position;

-- 2. AMOSTRA DE GRUPOS CANÔNICOS COM SEUS DADOS
-- ============================================================================
SELECT 
    id,
    nome,
    slug,
    tipo_lente,
    material,
    indice_refracao,
    grau_esferico_min,
    grau_esferico_max,
    grau_cilindrico_min,
    grau_cilindrico_max,
    adicao_min,
    adicao_max
FROM lens_catalog.grupos_canonicos
LIMIT 15;

-- 3. VERIFICAR COMO GRUPO_NOME ENCAPSULA OS GRAUS
-- ============================================================================
SELECT 
    gc.id,
    gc.nome AS grupo_nome,
    gc.slug AS grupo_slug,
    gc.grau_esferico_min,
    gc.grau_esferico_max,
    gc.grau_cilindrico_min,
    gc.grau_cilindrico_max,
    gc.adicao_min,
    gc.adicao_max,
    COUNT(DISTINCT l.id) AS total_lentes_neste_grupo
FROM lens_catalog.grupos_canonicos gc
LEFT JOIN lens_catalog.lentes l ON l.grupo_canonico_id = gc.id AND l.ativo = true
GROUP BY gc.id, gc.nome, gc.slug, gc.grau_esferico_min, gc.grau_esferico_max,
         gc.grau_cilindrico_min, gc.grau_cilindrico_max, gc.adicao_min, gc.adicao_max
ORDER BY total_lentes_neste_grupo DESC
LIMIT 20;

-- 4. SINCRONIZAÇÃO: GRUPO vs LENTES
-- ============================================================================
-- Verificar se os graus do grupo batem com as lentes do grupo
SELECT 
    gc.id,
    gc.nome,
    gc.grau_esferico_min AS grupo_esf_min,
    MIN(l.grau_esferico_min) AS lentes_esf_min,
    gc.grau_esferico_max AS grupo_esf_max,
    MAX(l.grau_esferico_max) AS lentes_esf_max,
    CASE 
        WHEN gc.grau_esferico_min != MIN(l.grau_esferico_min) THEN '⚠️ DESINCRONIZADO'
        WHEN gc.grau_esferico_max != MAX(l.grau_esferico_max) THEN '⚠️ DESINCRONIZADO'
        ELSE '✓ OK'
    END AS status_esfera
FROM lens_catalog.grupos_canonicos gc
LEFT JOIN lens_catalog.lentes l ON l.grupo_canonico_id = gc.id AND l.ativo = true
WHERE gc.id IN (
    SELECT DISTINCT grupo_canonico_id 
    FROM lens_catalog.lentes 
    WHERE ativo = true
)
GROUP BY gc.id, gc.nome, gc.grau_esferico_min, gc.grau_esferico_max
HAVING COUNT(l.id) > 0
ORDER BY status_esfera DESC, gc.nome
LIMIT 20;

-- 5. ESTRUTURA DO SLUG - Analisar padrão de codificação de graus
-- ============================================================================
SELECT 
    id,
    nome,
    slug,
    -- Extrair padrão do slug
    CASE 
        WHEN slug LIKE '%-esf-%' THEN 'Contém esfera'
        ELSE 'Sem esfera no slug'
    END AS tem_esfera_no_slug,
    CASE 
        WHEN slug LIKE '%-cil-%' THEN 'Contém cilindro'
        ELSE 'Sem cilindro no slug'
    END AS tem_cilindro_no_slug,
    CASE 
        WHEN slug LIKE '%-add-%' THEN 'Contém adição'
        ELSE 'Sem adição no slug'
    END AS tem_adicao_no_slug
FROM lens_catalog.grupos_canonicos
LIMIT 20;

-- 6. ANÁLISE: Grupos sem informação de grau
-- ============================================================================
SELECT 
    id,
    nome,
    slug,
    tipo_lente,
    material,
    grau_esferico_min,
    grau_esferico_max,
    grau_cilindrico_min,
    grau_cilindrico_max,
    adicao_min,
    adicao_max,
    COUNT(DISTINCT l.id) AS total_lentes
FROM lens_catalog.grupos_canonicos gc
LEFT JOIN lens_catalog.lentes l ON l.grupo_canonico_id = gc.id AND l.ativo = true
WHERE (
    gc.grau_esferico_min IS NULL
    OR gc.grau_esferico_max IS NULL
    OR gc.grau_cilindrico_min IS NULL
    OR gc.grau_cilindrico_max IS NULL
)
GROUP BY gc.id, gc.nome, gc.slug, gc.tipo_lente, gc.material,
         gc.grau_esferico_min, gc.grau_esferico_max,
         gc.grau_cilindrico_min, gc.grau_cilindrico_max,
         gc.adicao_min, gc.adicao_max
ORDER BY total_lentes DESC;

-- 7. ESTATÍSTICAS CONSOLIDADAS
-- ============================================================================
SELECT 
    COUNT(*) AS total_grupos,
    COUNT(CASE WHEN grau_esferico_min IS NOT NULL THEN 1 END) AS grupos_com_esfera,
    COUNT(CASE WHEN grau_cilindrico_min IS NOT NULL THEN 1 END) AS grupos_com_cilindro,
    COUNT(CASE WHEN adicao_min IS NOT NULL THEN 1 END) AS grupos_com_adicao,
    COUNT(CASE WHEN (grau_esferico_min IS NULL 
                   OR grau_cilindrico_min IS NULL 
                   OR adicao_min IS NULL) THEN 1 END) AS grupos_incompletos
FROM lens_catalog.grupos_canonicos;

-- 8. RELAÇÃO ENTRE LENTES E GRUPOS (via v_lentes)
-- ============================================================================
SELECT 
    grupo_nome,
    grupo_slug,
    tipo_lente,
    material,
    COUNT(*) AS total_lentes,
    COUNT(DISTINCT fornecedor_nome) AS total_fornecedores,
    COUNT(DISTINCT marca_nome) AS total_marcas,
    ROUND(AVG(preco_venda_sugerido)::NUMERIC, 2) AS preco_medio,
    ROUND(AVG(prazo_dias)::NUMERIC, 0) AS prazo_medio_dias
FROM v_lentes
WHERE ativo = true
GROUP BY grupo_nome, grupo_slug, tipo_lente, material
ORDER BY total_lentes DESC
LIMIT 20;

-- 9. EXEMPLO ESPECÍFICO: Lente com detalhes completos
-- ============================================================================
SELECT 
    id,
    nome_lente,
    nome_comercial,
    grupo_nome,
    grupo_slug,
    tipo_lente,
    material,
    indice_refracao,
    grau_esferico_min,
    grau_esferico_max,
    grau_cilindrico_min,
    grau_cilindrico_max,
    adicao_min,
    adicao_max,
    dnp_min,
    dnp_max,
    tem_ar,
    tem_blue,
    tem_uv,
    preco_venda_sugerido,
    prazo_dias
FROM v_lentes
WHERE ativo = true
  AND grupo_nome IS NOT NULL
  AND grupo_slug IS NOT NULL
LIMIT 10;

-- 10. RESUMO FINAL
-- ============================================================================
SELECT 
    'Total de grupos canônicos' AS metrica,
    COUNT(*)::TEXT AS valor
FROM lens_catalog.grupos_canonicos
UNION ALL
SELECT 'Grupos com informação completa de graus',
    COUNT(*)::TEXT
FROM lens_catalog.grupos_canonicos
WHERE grau_esferico_min IS NOT NULL
  AND grau_cilindrico_min IS NOT NULL
  AND adicao_min IS NOT NULL
UNION ALL
SELECT 'Lentes na view v_lentes',
    COUNT(*)::TEXT
FROM v_lentes
WHERE ativo = true
UNION ALL
SELECT 'Lentes com grupo_nome preenchido',
    COUNT(*)::TEXT
FROM v_lentes
WHERE ativo = true AND grupo_nome IS NOT NULL
UNION ALL
SELECT 'Lentes com grupo_slug preenchido',
    COUNT(*)::TEXT
FROM v_lentes
WHERE ativo = true AND grupo_slug IS NOT NULL;
