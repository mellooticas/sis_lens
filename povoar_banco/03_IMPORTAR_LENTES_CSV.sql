-- ============================================
-- IMPORTAR LENTES VIA CSV
-- ============================================
-- ANTES de executar este arquivo:
-- 1. Faça upload do arquivo LENTES_IMPORT.csv para seu ambiente
-- 2. Ajuste o caminho do arquivo abaixo se necessário
-- ============================================

-- Método 1: Via COPY (linha de comando PostgreSQL)
-- Execute no terminal do servidor PostgreSQL:
-- \copy lens_catalog.lentes(id,sku_fornecedor,codigo_original,nome_comercial,marca_id,fornecedor_id,tipo_lente,categoria,material,indice_refracao,diametro,esferico_min,esferico_max,cilindrico_min,cilindrico_max,adicao_min,adicao_max,ar,blue,fotossensivel,polarizado,preco_tabela,status) FROM 'LENTES_IMPORT.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Método 2: Via Supabase Table Editor
-- 1. Vá em: Database > Tables > lentes
-- 2. Clique em "Insert" > "Insert via CSV"
-- 3. Faça upload do arquivo LENTES_IMPORT.csv
-- 4. Mapeie as colunas automaticamente

-- Método 3: Via SQL com arquivo local (se tiver acesso ao sistema de arquivos)
-- Ajuste o caminho para onde você salvou o CSV:

COPY lens_catalog.lentes(
    id,
    sku_fornecedor,
    codigo_original,
    nome_comercial,
    marca_id,
    fornecedor_id,
    tipo_lente,
    categoria,
    material,
    indice_refracao,
    diametro,
    esferico_min,
    esferico_max,
    cilindrico_min,
    cilindrico_max,
    adicao_min,
    adicao_max,
    ar,
    blue,
    fotossensivel,
    polarizado,
    preco_tabela,
    status
)
FROM '/path/to/LENTES_IMPORT.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    NULL ''
);

-- ============================================
-- VERIFICAÇÃO APÓS IMPORTAÇÃO
-- ============================================

-- Contar lentes importadas
SELECT COUNT(*) as total_lentes FROM lens_catalog.lentes;
-- Esperado: 1411

-- Ver distribuição por fornecedor
SELECT 
    f.nome_fantasia,
    COUNT(*) as total_lentes
FROM lens_catalog.lentes l
JOIN pessoas.fornecedores f ON f.id = l.fornecedor_id
GROUP BY f.nome_fantasia
ORDER BY total_lentes DESC;

-- Ver distribuição por tipo
SELECT 
    tipo_lente,
    COUNT(*) as total
FROM lens_catalog.lentes
GROUP BY tipo_lente
ORDER BY total DESC;

-- Ver lentes com tratamentos
SELECT 
    ar,
    blue,
    fotossensivel,
    polarizado,
    COUNT(*) as total
FROM lens_catalog.lentes
GROUP BY ar, blue, fotossensivel, polarizado
ORDER BY total DESC
LIMIT 10;
