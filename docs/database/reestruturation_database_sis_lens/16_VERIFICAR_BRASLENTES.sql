-- ============================================================================
-- VERIFICAÇÃO: Lentes do fornecedor 'Braslentes'
-- ============================================================================
-- Objetivo: Verificar o estado atual das lentes Braslentes no banco
-- ============================================================================

-- 1. Verificar ID do fornecedor Braslentes e contagem
SELECT 
    f.id,
    f.nome as fornecedor,
    f.razao_social,
    COUNT(l.id) as total_lentes,
    COUNT(CASE WHEN l.status = 'ativo' THEN 1 END) as ativas
FROM core.fornecedores f
LEFT JOIN lens_catalog.lentes l ON l.fornecedor_id = f.id
WHERE f.nome ILIKE '%Braslentes%'
GROUP BY f.id, f.nome, f.razao_social;

| id                                   | fornecedor | razao_social               | total_lentes | ativas |
| ------------------------------------ | ---------- | -------------------------- | ------------ | ------ |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | Braslentes | Champ Brasil Comercio LTDA | 36           | 36     |



-- 2. Amostra das lentes da Braslentes se existirem
SELECT 
    nome_lente,
    tipo_lente,
    material,
    indice_refracao,
    preco_custo,
    status
FROM lens_catalog.lentes 
WHERE fornecedor_id IN (SELECT id FROM core.fornecedores WHERE nome ILIKE '%Braslentes%')
LIMIT 20;


| nome_lente                      | tipo_lente    | material      | indice_refracao | preco_custo | status |
| ------------------------------- | ------------- | ------------- | --------------- | ----------- | ------ |
| 1.59 POLICARBONATO AR BLUE      | visao_simples | POLICARBONATO | 1.59            | 58.00       | ativo  |
| 1.59 POLICARBONATO AR BLUE FOTO | visao_simples | POLICARBONATO | 1.59            | 78.00       | ativo  |
| 1.59 POLICARBONATO AR BLUE FOTO | visao_simples | POLICARBONATO | 1.59            | 98.00       | ativo  |
| 1.50 CR39                       | visao_simples | CR39          | 1.50            | 9.00        | ativo  |
| 1.50 CR39                       | visao_simples | CR39          | 1.50            | 12.00       | ativo  |
| 1.56 CR39 AR                    | visao_simples | CR39          | 1.56            | 11.00       | ativo  |
| 1.56 CR39 AR                    | visao_simples | CR39          | 1.56            | 20.00       | ativo  |
| 1.56 CR39 AR                    | visao_simples | CR39          | 1.56            | 42.00       | ativo  |
| 1.56 CR39 AR FOTO               | visao_simples | CR39          | 1.56            | 18.00       | ativo  |
| 1.56 CR39 AR FOTO               | visao_simples | CR39          | 1.56            | 26.00       | ativo  |
| 1.56 CR39 AR BLUE               | visao_simples | CR39          | 1.56            | 16.00       | ativo  |
| 1.56 CR39 AR BLUE               | visao_simples | CR39          | 1.56            | 22.00       | ativo  |
| 1.56 CR39 AR BLUE               | visao_simples | CR39          | 1.56            | 48.00       | ativo  |
| 1.56 CR39 AR BLUE               | visao_simples | CR39          | 1.56            | 16.00       | ativo  |
| 1.56 CR39 AR BLUE               | visao_simples | CR39          | 1.56            | 22.00       | ativo  |
| 1.56 CR39 AR BLUE FOTO          | visao_simples | CR39          | 1.56            | 42.00       | ativo  |
| 1.56 CR39 AR BLUE FOTO          | visao_simples | CR39          | 1.56            | 52.00       | ativo  |
| 1.59 POLICARBONATO AR           | visao_simples | POLICARBONATO | 1.59            | 18.00       | ativo  |
| 1.59 POLICARBONATO AR           | visao_simples | POLICARBONATO | 1.59            | 32.00       | ativo  |
| 1.59 POLICARBONATO AR           | visao_simples | POLICARBONATO | 1.59            | 16.00       | ativo  |


-- 3. Verificar marcas associadas à Braslentes
SELECT 
    m.nome as marca,
    COUNT(l.id) as total_lentes
FROM lens_catalog.marcas m
JOIN lens_catalog.lentes l ON l.marca_id = m.id
WHERE l.fornecedor_id IN (SELECT id FROM core.fornecedores WHERE nome ILIKE '%Braslentes%')
GROUP BY m.nome;


| marca      | total_lentes |
| ---------- | ------------ |
| BRASLENTES | 36           |
