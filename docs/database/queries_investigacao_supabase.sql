-- ============================================================================
-- QUERIES DE INVESTIGAÇÃO - SUPABASE (SIS LENS)
-- ============================================================================
-- Execute estas queries no Supabase SQL Editor
-- URL: https://supabase.com/dashboard/project/ahcikwsoxhmqqteertkx/sql
-- ============================================================================

-- ============================================================================
-- 1. OVERVIEW GERAL DO SISTEMA
-- ============================================================================

-- Total de lentes por status
SELECT
    status,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE disponivel = true) as disponiveis,
    ROUND(AVG(preco_tabela), 2) as preco_medio
FROM lens_catalog.lentes
WHERE ativo = true
GROUP BY status
ORDER BY total DESC;

| status | total | disponiveis | preco_medio |
| ------ | ----- | ----------- | ----------- |
| ativo  | 1411  | 1411        | 0.00        |


-- Total de lentes por categoria
SELECT
    categoria,
    COUNT(*) as total,
    MIN(preco_tabela) as preco_min,
    MAX(preco_tabela) as preco_max,
    ROUND(AVG(preco_tabela), 2) as preco_medio
FROM lens_catalog.lentes
WHERE ativo = true
GROUP BY categoria
ORDER BY preco_medio;

| categoria     | total | preco_min | preco_max | preco_medio |
| ------------- | ----- | --------- | --------- | ----------- |
| intermediaria | 963   | 0.00      | 0.00      | 0.00        |
| economica     | 448   | 0.00      | 0.00      | 0.00        |


-- ============================================================================
-- 2. FORNECEDORES COM ESTATÍSTICAS
-- ============================================================================

SELECT
    f.id,
    f.nome,
    f.prazo_visao_simples,
    f.prazo_multifocal,
    COUNT(l.id) as total_lentes,
    COUNT(l.id) FILTER (WHERE l.disponivel = true) as lentes_disponiveis,
    ROUND(AVG(l.preco_tabela), 2) as preco_medio
FROM core.fornecedores f
LEFT JOIN lens_catalog.lentes l ON l.fornecedor_id = f.id AND l.ativo = true
WHERE f.ativo = true
GROUP BY f.id, f.nome, f.prazo_visao_simples, f.prazo_multifocal
ORDER BY total_lentes DESC;

| id                                   | nome                   | prazo_visao_simples | prazo_multifocal | total_lentes | lentes_disponiveis | preco_medio |
| ------------------------------------ | ---------------------- | ------------------- | ---------------- | ------------ | ------------------ | ----------- |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | So Blocos              | 7                   | 10               | 1097         | 1097               | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Polylux                | 7                   | 10               | 158          | 158                | 0.00        |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express                | 3                   | 5                | 84           | 84                 | 0.00        |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Brascor                | 7                   | 10               | 58           | 58                 | 0.00        |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Sygma                  | 7                   | 10               | 14           | 14                 | 0.00        |
| d90bebaf-e552-4cf0-a226-808c91bda73a | Kaizi Oculos Solares   | 7                   | 10               | 0            | 0                  | null        |
| e4a24408-3d58-4fc7-a096-cf7140f4f248 | Galeria Florencio lj11 | 7                   | 10               | 0            | 0                  | null        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | Braslentes             | 10                  | 12               | 0            | 0                  | null        |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | Style                  | 7                   | 10               | 0            | 0                  | null        |
| 1d0b088f-dcb1-4179-9a18-5d67ce86c4b6 | Sao Paulo Acessorios   | 7                   | 10               | 0            | 0                  | null        |
| c50ea6eb-a420-4cf7-8aa2-68aaeb41ac95 | Navarro Oculos         | 7                   | 10               | 0            | 0                  | null        |


-- ============================================================================
-- 3. MARCAS COM ESTATÍSTICAS
-- ============================================================================

SELECT
    m.nome,
    m.is_premium,
    COUNT(l.id) as total_lentes,
    ROUND(AVG(l.preco_tabela), 2) as preco_medio
FROM lens_catalog.marcas m
LEFT JOIN lens_catalog.lentes l ON l.marca_id = m.id AND l.ativo = true
WHERE m.ativo = true
GROUP BY m.nome, m.is_premium
ORDER BY total_lentes DESC;

| nome        | is_premium | total_lentes | preco_medio |
| ----------- | ---------- | ------------ | ----------- |
| SO BLOCOS   | false      | 880          | 0.00        |
| TRANSITIONS | true       | 234          | 0.00        |
| POLYLUX     | false      | 132          | 0.00        |
| BRASCOR     | false      | 56           | 0.00        |
| EXPRESS     | false      | 50           | 0.00        |
| SYGMA       | false      | 38           | 0.00        |
| VARILUX     | true       | 11           | 0.00        |
| GENÉRICA    | false      | 10           | 0.00        |
| LENSCOPE    | true       | 0            | null        |
| ESSILOR     | true       | 0            | null        |
| ZEISS       | true       | 0            | null        |
| BRASLENTES  | false      | 0            | null        |
| HOYA        | true       | 0            | null        |
| RODENSTOCK  | true       | 0            | null        |
| STYLE       | false      | 0            | null        |
| KODAK       | true       | 0            | null        |
| CRIZAL      | true       | 0            | null        |



-- ============================================================================
-- 4. GRUPOS CANÔNICOS MAIS POPULARES
-- ============================================================================

SELECT
    gc.nome_grupo,
    gc.tipo_lente,
    gc.material,
    gc.indice_refracao,
    gc.total_lentes,
    gc.preco_medio,
    gc.is_premium
FROM lens_catalog.grupos_canonicos gc
WHERE gc.ativo = true AND gc.total_lentes > 0
ORDER BY gc.total_lentes DESC
LIMIT 20;

| nome_grupo                                                                                        | tipo_lente    | material      | indice_refracao | total_lentes | preco_medio | is_premium |
| ------------------------------------------------------------------------------------------------- | ------------- | ------------- | --------------- | ------------ | ----------- | ---------- |
| Lente CR39 1.50 Multifocal +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]               | multifocal    | CR39          | 1.50            | 36           | 4750.11     | true       |
| Lente CR39 1.50 Multifocal +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                              | multifocal    | CR39          | 1.50            | 36           | 2620.31     | false      |
| Lente POLICARBONATO 1.59 Multifocal +UV +BlueLight [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]         | multifocal    | POLICARBONATO | 1.59            | 30           | 3218.35     | false      |
| Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                          | multifocal    | CR39          | 1.50            | 24           | 2424.77     | false      |
| Lente CR39 1.50 Multifocal +AR +UV +fotocromático [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]           | multifocal    | CR39          | 1.50            | 24           | 4554.57     | true       |
| Lente CR39 1.67 Multifocal +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                             | multifocal    | CR39          | 1.67            | 24           | 5437.77     | false      |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV +BlueLight [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]     | multifocal    | POLICARBONATO | 1.59            | 20           | 3022.81     | false      |
| Lente CR39 1.67 Multifocal +AR +UV [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                         | multifocal    | CR39          | 1.67            | 16           | 5242.23     | false      |
| Lente POLICARBONATO 1.59 Multifocal +UV +fotocromático [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]     | multifocal    | POLICARBONATO | 1.59            | 15           | 5377.15     | true       |
| Lente CR39 1.56 Multifocal +UV +BlueLight [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]                   | multifocal    | CR39          | 1.56            | 15           | 2795.98     | false      |
| Lente POLICARBONATO 1.59 Multifocal +UV [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]                    | multifocal    | POLICARBONATO | 1.59            | 15           | 2874.19     | false      |
| Lente POLICARBONATO 1.59 Visao Simples +UV +BlueLight [-10.00/8.00 | -6.00/0.00]                  | visao_simples | POLICARBONATO | 1.59            | 12           | 3237.90     | false      |
| Lente CR39 1.74 Multifocal +UV [-13.00/10.00 | -6.00/0.00 | 0.50/4.50]                            | multifocal    | CR39          | 1.74            | 12           | 7275.88     | false      |
| Lente CR39 1.67 Multifocal +UV +BlueLight [-13.00/9.00 | -6.00/0.00 | 0.50/4.50]                  | multifocal    | CR39          | 1.67            | 12           | 5388.88     | false      |
| Lente CR39 1.67 Multifocal +UV [-13.00/9.00 | -8.00/0.00 | 0.50/4.50]                             | multifocal    | CR39          | 1.67            | 12           | 5134.68     | false      |
| Lente CR39 1.74 Multifocal +UV [-15.00/10.00 | -8.00/0.00 | 0.50/4.50]                            | multifocal    | CR39          | 1.74            | 12           | 7314.99     | false      |
| Lente CR39 1.50 Visao Simples +UV +fotocromático [-8.00/6.50 | -6.00/0.00]                        | visao_simples | CR39          | 1.50            | 12           | 4684.93     | true       |
| Lente CR39 1.56 Multifocal +AR +UV +BlueLight [-8.00/6.50 | -6.00/0.00 | 0.50/4.50]               | multifocal    | CR39          | 1.56            | 10           | 2600.43     | false      |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV +fotocromático [-10.00/8.00 | -6.00/0.00 | 0.50/4.50] | multifocal    | POLICARBONATO | 1.59            | 10           | 5181.61     | true       |
| Lente POLICARBONATO 1.59 Multifocal +AR +UV [-10.00/8.00 | -6.00/0.00 | 0.50/4.50]                | multifocal    | POLICARBONATO | 1.59            | 10           | 2678.65     | false      |


-- ============================================================================
-- 5. DISTRIBUIÇÃO DE TRATAMENTOS
-- ============================================================================

SELECT
    COUNT(*) FILTER (WHERE ar = true) as total_ar,
    COUNT(*) FILTER (WHERE blue = true) as total_blue,
    COUNT(*) FILTER (WHERE antirrisco = true) as total_antirrisco,
    COUNT(*) FILTER (WHERE polarizado = true) as total_polarizado,
    COUNT(*) FILTER (WHERE fotossensivel != 'nenhum') as total_fotossensivel
FROM lens_catalog.lentes
WHERE ativo = true;

| total_ar | total_blue | total_antirrisco | total_polarizado | total_fotossensivel |
| -------- | ---------- | ---------------- | ---------------- | ------------------- |
| 0        | 0          | 0                | 0                | 0                   |

-- ============================================================================
-- 6. LENTES POR FAIXA DE PREÇO
-- ============================================================================

SELECT
    CASE
        WHEN preco_tabela < 150 THEN 'Entrada (< R$150)'
        WHEN preco_tabela < 300 THEN 'Básico (R$150-300)'
        WHEN preco_tabela < 500 THEN 'Intermediário (R$300-500)'
        WHEN preco_tabela < 800 THEN 'Premium (R$500-800)'
        ELSE 'Super Premium (R$800+)'
    END as faixa,
    COUNT(*) as total
FROM lens_catalog.lentes
WHERE ativo = true
GROUP BY
    CASE
        WHEN preco_tabela < 150 THEN 'Entrada (< R$150)'
        WHEN preco_tabela < 300 THEN 'Básico (R$150-300)'
        WHEN preco_tabela < 500 THEN 'Intermediário (R$300-500)'
        WHEN preco_tabela < 800 THEN 'Premium (R$500-800)'
        ELSE 'Super Premium (R$800+)'
    END
ORDER BY MIN(preco_tabela);

| faixa             | total |
| ----------------- | ----- |
| Entrada (< R$150) | 1411  |


-- ============================================================================
-- 7. LENTES DESTAQUES/NOVIDADES
-- ============================================================================

SELECT
    l.nome_comercial,
    m.nome as marca,
    f.nome as fornecedor,
    l.preco_tabela,
    l.destaque,
    l.novidade
FROM lens_catalog.lentes l
JOIN lens_catalog.marcas m ON l.marca_id = m.id
JOIN core.fornecedores f ON l.fornecedor_id = f.id
WHERE l.ativo = true
  AND (l.destaque = true OR l.novidade = true)
ORDER BY l.preco_tabela
LIMIT 10;

Success. No rows returned




-- ============================================================================
-- 8. STATUS DO ESTOQUE
-- ============================================================================

SELECT
    COUNT(*) as total_itens_estoque,
    SUM(quantidade_disponivel) as qtd_total,
    ROUND(SUM(valor_total_estoque), 2) as valor_total
FROM compras.estoque_saldo;

| total_itens_estoque | qtd_total | valor_total |
| ------------------- | --------- | ----------- |
| 0                   | null      | null        |



-- ============================================================================
-- 9. LENTES ÓRFÃS (sem grupo canônico)
-- ============================================================================

SELECT
    COUNT(*) as total_orfas
FROM lens_catalog.lentes
WHERE ativo = true AND grupo_canonico_id IS NULL;

| total_orfas |
| ----------- |
| 0           |


-- ============================================================================
-- 10. VERIFICAR CAMPOS DUPLICADOS
-- ============================================================================

SELECT
    COUNT(*) as total_lentes,
    COUNT(*) FILTER (WHERE grau_esferico_min IS DISTINCT FROM esferico_min) as dif_esferico_min,
    COUNT(*) FILTER (WHERE tratamento_antirreflexo IS DISTINCT FROM ar) as dif_ar
FROM lens_catalog.lentes
WHERE ativo = true;

| total_lentes | dif_esferico_min | dif_ar |
| ------------ | ---------------- | ------ |
| 1411         | 1411             | 620    |

