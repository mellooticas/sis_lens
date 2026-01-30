-- ============================================================================
-- VERIFICAÇÃO: Lentes do fornecedor 'High Vision'
-- ============================================================================
-- Objetivo: Verificar o estado atual do fornecedor High Vision no banco
-- ============================================================================

-- 1. Verificar se o fornecedor existe (pode estar com nome levemente diferente)
SELECT 
    id,
    nome,
    razao_social,
    ativo
FROM core.fornecedores 
WHERE nome ILIKE '%High Vision%' 
   OR razao_social ILIKE '%High Vision%';

-- 2. Contagem de lentes se o fornecedor for encontrado
-- Nota: Usamos subquery para pegar qualquer variação do nome
SELECT 
    f.nome as fornecedor,
    COUNT(l.id) as total_lentes,
    COUNT(CASE WHEN l.status = 'ativo' THEN 1 END) as ativas
FROM core.fornecedores f
LEFT JOIN lens_catalog.lentes l ON l.fornecedor_id = f.id
WHERE f.nome ILIKE '%High Vision%'
GROUP BY f.nome;

-- 3. Verificar marcas que já podem estar cadastradas para este laboratório
SELECT 
    nome,
    slug,
    is_premium
FROM lens_catalog.marcas
WHERE nome ILIKE '%High Vision%';
