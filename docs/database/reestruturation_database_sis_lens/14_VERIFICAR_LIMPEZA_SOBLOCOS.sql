-- ============================================================================
-- VERIFICAÇÃO: Lentes restantes do fornecedor 'So Blocos'
-- ============================================================================
-- Objetivo: Confirmar se a deleção foi completa e checar por resíduos
-- ============================================================================

SELECT 
    f.nome as fornecedor,
    COUNT(l.id) as total_lentes,
    COUNT(CASE WHEN l.status = 'ativo' THEN 1 END) as ativas,
    COUNT(CASE WHEN l.deleted_at IS NOT NULL THEN 1 END) as marcadas_como_deletadas
FROM core.fornecedores f
LEFT JOIN lens_catalog.lentes l ON l.fornecedor_id = f.id
WHERE f.nome ILIKE '%So Blocos%'
GROUP BY f.nome;

| fornecedor | total_lentes | ativas | marcadas_como_deletadas |
| ---------- | ------------ | ------ | ----------------------- |
| So Blocos  | 1097         | 1097   | 0                       |


-- Verificação por ID direto para não haver erro de nome
SELECT 
    'Lentes com ID fixo So Blocos' as metrica,
    COUNT(*) as total
FROM lens_catalog.lentes 
WHERE fornecedor_id = 'e1e1eace-11b4-4f26-9f15-620808a4a410';


| metrica                      | total |
| ---------------------------- | ----- |
| Lentes com ID fixo So Blocos | 1097  |


-- Verificar se sobrou alguma marca do So Blocos sem lentes
SELECT 
    m.nome as marca,
    COUNT(l.id) as total_lentes
FROM lens_catalog.marcas m
LEFT JOIN lens_catalog.lentes l ON l.marca_id = m.id
WHERE m.nome ILIKE '%SO BLOCOS%'
GROUP BY m.nome;


| marca     | total_lentes |
| --------- | ------------ |
| SO BLOCOS | 880          |
