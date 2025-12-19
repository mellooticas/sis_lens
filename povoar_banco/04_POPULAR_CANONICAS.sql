-- ============================================
-- 04_POPULAR_CANONICAS.sql
-- Popula tabelas canônicas automaticamente
-- ============================================
-- 
-- PRÉ-REQUISITO: Executar 03_POPULAR_LENTES.sql primeiro
-- (deve ter ~1.411 lentes importadas)
--
-- Este script agrupa lentes em grupos canônicos
-- baseado em características comuns
-- ============================================

-- ============================================
-- PARTE 1: Lentes Canônicas Genéricas
-- ============================================

-- Limpar dados antigos
TRUNCATE TABLE lens_catalog.lentes_canonicas CASCADE;

-- Agrupar lentes genéricas (econômicas + intermediárias)
INSERT INTO lens_catalog.lentes_canonicas (
    nome_canonico,
    tipo_lente,
    material,
    indice_refracao,
    categoria,
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
    total_lentes,
    preco_minimo,
    preco_maximo,
    preco_medio
)
SELECT 
    l.tipo_lente || ' ' || l.material || ' ' || l.indice_refracao as nome_canonico,
    l.tipo_lente,
    l.material,
    l.indice_refracao,
    l.categoria,
    MIN(l.esferico_min) as esferico_min,
    MAX(l.esferico_max) as esferico_max,
    MIN(l.cilindrico_min) as cilindrico_min,
    MAX(l.cilindrico_max) as cilindrico_max,
    MIN(NULLIF(l.adicao_min, 0)) as adicao_min,
    MAX(NULLIF(l.adicao_max, 0)) as adicao_max,
    bool_or(l.ar) as ar,
    bool_or(l.blue) as blue,
    CASE WHEN bool_or(l.fotossensivel != 'nenhum') THEN true ELSE false END as fotossensivel,
    bool_or(l.polarizado) as polarizado,
    COUNT(*) as total_lentes,
    MIN(l.preco_tabela) as preco_minimo,
    MAX(l.preco_tabela) as preco_maximo,
    AVG(l.preco_tabela) as preco_medio
FROM lens_catalog.lentes l
WHERE 
    l.categoria IN ('economica', 'intermediaria')
    AND l.status = 'ativo'
GROUP BY 
    l.tipo_lente,
    l.material,
    l.indice_refracao,
    l.categoria
HAVING COUNT(*) > 0;

-- Lentes canônicas criadas com sucesso
-- Nota: A coluna is_representante não existe mais no schema v2.0

-- ============================================
-- PARTE 2: Lentes Premium (usando mesma tabela)
-- ============================================

-- Adicionar lentes premium na mesma tabela canônicas

-- Agrupar lentes premium (todas as categorias restantes)
INSERT INTO lens_catalog.lentes_canonicas (
    nome_canonico,
    tipo_lente,
    material,
    indice_refracao,
    categoria,
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
    total_lentes,
    preco_minimo,
    preco_maximo,
    preco_medio
)
SELECT 
    m.nome || ' ' || l.tipo_lente || ' ' || l.material || ' ' || l.indice_refracao as nome_canonico,
    l.tipo_lente,
    l.material,
    l.indice_refracao,
    l.categoria,
    MIN(l.esferico_min) as esferico_min,
    MAX(l.esferico_max) as esferico_max,
    MIN(l.cilindrico_min) as cilindrico_min,
    MAX(l.cilindrico_max) as cilindrico_max,
    MIN(NULLIF(l.adicao_min, 0)) as adicao_min,
    MAX(NULLIF(l.adicao_max, 0)) as adicao_max,
    bool_or(l.ar) as ar,
    bool_or(l.blue) as blue,
    CASE WHEN bool_or(l.fotossensivel != 'nenhum') THEN true ELSE false END as fotossensivel,
    bool_or(l.polarizado) as polarizado,
    COUNT(*) as total_lentes,
    MIN(l.preco_tabela) as preco_minimo,
    MAX(l.preco_tabela) as preco_maximo,
    AVG(l.preco_tabela) as preco_medio
FROM lens_catalog.lentes l
INNER JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE 
    l.categoria IN ('premium', 'super_premium')
    AND l.status = 'ativo'
GROUP BY 
    m.nome,
    l.tipo_lente,
    l.material,
    l.indice_refracao,
    l.categoria
HAVING COUNT(*) > 0;

-- Lentes premium canonizadas com sucesso

-- ============================================
-- VERIFICAÇÃO
-- ============================================

-- Ver estatísticas de canonização
SELECT 
    categoria,
    COUNT(*) as total_grupos,
    SUM(total_lentes) as lentes_agrupadas,
    ROUND(AVG(preco_medio)::numeric, 2) as preco_medio_geral
FROM lens_catalog.lentes_canonicas
GROUP BY categoria
ORDER BY categoria;

| categoria     | total_grupos | lentes_agrupadas | preco_medio_geral |
| ------------- | ------------ | ---------------- | ----------------- |
| economica     | 10           | 194              | 358.03            |
| intermediaria | 10           | 143              | 1145.07           |
| premium       | 18           | 403              | 2546.04           |
| super_premium | 13           | 671              | 4859.23           |


-- Ver distribuição por tipo
SELECT 
    tipo_lente,
    material,
    indice_refracao,
    categoria,
    COUNT(*) as grupos,
    SUM(total_lentes) as lentes
FROM lens_catalog.lentes_canonicas
GROUP BY tipo_lente, material, indice_refracao, categoria
ORDER BY lentes DESC;


| tipo_lente    | material      | indice_refracao | categoria     | grupos | lentes |
| ------------- | ------------- | --------------- | ------------- | ------ | ------ |
| visao_simples | CR39          | 1.67            | super_premium | 2      | 214    |
| visao_simples | CR39          | 1.74            | super_premium | 2      | 197    |
| visao_simples | POLICARBONATO | 1.59            | premium       | 2      | 137    |
| visao_simples | CR39          | 1.50            | premium       | 1      | 117    |
| visao_simples | POLICARBONATO | 1.59            | super_premium | 1      | 108    |
| visao_simples | CR39          | 1.50            | super_premium | 1      | 101    |
| visao_simples | CR39          | 1.56            | economica     | 1      | 76     |
| visao_simples | CR39          | 1.56            | premium       | 1      | 58     |
| visao_simples | POLICARBONATO | 1.59            | economica     | 1      | 33     |
| multifocal    | CR39          | 1.50            | premium       | 2      | 33     |
| multifocal    | CR39          | 1.56            | economica     | 1      | 28     |
| multifocal    | CR39          | 1.50            | intermediaria | 1      | 27     |
| multifocal    | POLICARBONATO | 1.59            | premium       | 3      | 23     |
| multifocal    | POLICARBONATO | 1.59            | intermediaria | 1      | 22     |
| visao_simples | CR39          | 1.67            | intermediaria | 1      | 19     |
| visao_simples | CR39          | 1.50            | intermediaria | 1      | 19     |
| multifocal    | CR39          | 1.67            | super_premium | 1      | 18     |
| visao_simples | CR39          | 1.61            | economica     | 1      | 18     |
| visao_simples | POLICARBONATO | 1.59            | intermediaria | 1      | 18     |
| multifocal    | CR39          | 1.74            | super_premium | 1      | 15     |
| visao_simples | CR39          | 1.50            | economica     | 1      | 15     |
| visao_simples | CR39          | 1.67            | premium       | 3      | 13     |
| multifocal    | CR39          | 1.67            | premium       | 2      | 12     |
| visao_simples | CR39          | 1.74            | intermediaria | 1      | 12     |
| multifocal    | CR39          | 1.56            | intermediaria | 1      | 11     |
| visao_simples | CR39          | 1.56            | intermediaria | 1      | 9      |
| visao_simples | CR39          | 1.74            | premium       | 2      | 8      |
| multifocal    | POLICARBONATO | 1.59            | super_premium | 1      | 7      |
| multifocal    | CR39          | 1.50            | economica     | 1      | 7      |
| multifocal    | CR39          | 1.50            | super_premium | 2      | 6      |
| multifocal    | POLICARBONATO | 1.59            | economica     | 1      | 6      |
| visao_simples | CR39          | 1.67            | economica     | 1      | 6      |
| multifocal    | CR39          | 1.67            | intermediaria | 1      | 4      |
| visao_simples | CR39          | 1.74            | economica     | 1      | 3      |
| multifocal    | TRIVEX        | 1.59            | super_premium | 1      | 3      |
| bifocal       | CR39          | 1.50            | economica     | 1      | 2      |
| visao_simples | CR39          | 1.61            | intermediaria | 1      | 2      |
| visao_simples | CR39          | 1.56            | super_premium | 1      | 2      |
| multifocal    | TRIVEX        | 1.59            | premium       | 1      | 1      |
| multifocal    | CR39          | 1.56            | premium       | 1      | 1      |



-- Ver todas as canônicas criadas
SELECT 
    nome_canonico,
    categoria,
    total_lentes,
    preco_minimo,
    preco_maximo,
    ROUND(preco_medio::numeric, 2) as preco_medio
FROM lens_catalog.lentes_canonicas
ORDER BY total_lentes DESC
LIMIT 20;


| nome_canonico                             | categoria     | total_lentes | preco_minimo | preco_maximo | preco_medio |
| ----------------------------------------- | ------------- | ------------ | ------------ | ------------ | ----------- |
| SOBLOCOS visao_simples CR39 1.67          | super_premium | 212          | 3376.80      | 8000.00      | 5461.29     |
| SOBLOCOS visao_simples CR39 1.74          | super_premium | 195          | 4960.00      | 9640.00      | 7163.29     |
| SOBLOCOS visao_simples POLICARBONATO 1.59 | premium       | 135          | 1720.00      | 3462.60      | 2725.30     |
| SOBLOCOS visao_simples CR39 1.50          | premium       | 117          | 1600.00      | 3301.20      | 2485.04     |
| SOBLOCOS visao_simples POLICARBONATO 1.59 | super_premium | 108          | 3240.00      | 5900.00      | 4391.66     |
| SOBLOCOS visao_simples CR39 1.50          | super_premium | 101          | 3200.00      | 5280.00      | 4464.10     |
| visao_simples CR39 1.56                   | economica     | 76           | 42.00        | 520.00       | 198.74      |
| SOBLOCOS visao_simples CR39 1.56          | premium       | 58           | 1760.00      | 3278.50      | 2627.53     |
| visao_simples POLICARBONATO 1.59          | economica     | 33           | 36.00        | 484.00       | 204.54      |
| SOBLOCOS multifocal CR39 1.50             | premium       | 29           | 1890.00      | 3647.20      | 2735.00     |
| multifocal CR39 1.56                      | economica     | 28           | 141.00       | 540.00       | 340.08      |
| multifocal CR39 1.50                      | intermediaria | 27           | 805.50       | 1795.40      | 1273.36     |
| multifocal POLICARBONATO 1.59             | intermediaria | 22           | 720.00       | 1813.50      | 1323.50     |
| SOBLOCOS multifocal POLICARBONATO 1.59    | premium       | 21           | 1950.50      | 3394.50      | 2696.26     |
| visao_simples CR39 1.50                   | intermediaria | 19           | 600.00       | 1560.00      | 1033.01     |
| visao_simples CR39 1.67                   | intermediaria | 19           | 672.00       | 1670.40      | 1103.54     |
| visao_simples CR39 1.61                   | economica     | 18           | 160.00       | 565.50       | 374.45      |
| visao_simples POLICARBONATO 1.59          | intermediaria | 18           | 622.50       | 1470.00      | 962.01      |
| SOBLOCOS multifocal CR39 1.67             | super_premium | 18           | 3966.80      | 5490.00      | 4489.53     |
| SOBLOCOS multifocal CR39 1.74             | super_premium | 15           | 4860.00      | 7200.00      | 5846.46     |