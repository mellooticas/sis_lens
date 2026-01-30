-- ============================================================================
-- VERIFICAÇÃO: Lentes do fornecedor 'Express'
-- ============================================================================
-- Objetivo: Verificar o estado atual do fornecedor Express no banco
-- ============================================================================

-- 1. Verificar se o fornecedor existe
SELECT 
    id,
    nome,
    razao_social,
    ativo
FROM core.fornecedores 
WHERE nome ILIKE '%Express%';

| id                                   | nome    | razao_social              | ativo |
| ------------------------------------ | ------- | ------------------------- | ----- |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express | Lentes e Cia Express LTDA | true  |



-- 2. Contagem de lentes atual
SELECT 
    f.nome as fornecedor,
    COUNT(l.id) as total_lentes,
    COUNT(CASE WHEN l.status = 'ativo' THEN 1 END) as ativas
FROM core.fornecedores f
LEFT JOIN lens_catalog.lentes l ON l.fornecedor_id = f.id
WHERE f.nome ILIKE '%Express%'
GROUP BY f.id, f.nome;


| fornecedor | total_lentes | ativas |
| ---------- | ------------ | ------ |
| Express    | 84           | 84     |
