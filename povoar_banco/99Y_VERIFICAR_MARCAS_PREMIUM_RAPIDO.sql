-- ============================================================================
-- 99Y - VERIFICAÇÃO RÁPIDA: Marcas e is_premium nas LENTES
-- ============================================================================
-- Verifica diretamente na tabela lentes (não em grupos)
-- ============================================================================

\echo '===================================================================='
\echo '1. VERIFICAR LENTES - marca_id NULL'
\echo '===================================================================='

SELECT 
    COUNT(*) FILTER (WHERE marca_id IS NULL) as sem_marca,
    COUNT(*) FILTER (WHERE marca_id IS NOT NULL) as com_marca,
    COUNT(*) as total
FROM lens_catalog.lentes
WHERE ativo = true;

| sem_marca | com_marca | total |
| --------- | --------- | ----- |
| 0         | 1411      | 1411  |



\echo ''
\echo '===================================================================='
\echo '2. VERIFICAR LENTES - marca sem is_premium'
\echo '===================================================================='

SELECT 
    COUNT(*) FILTER (WHERE m.is_premium IS NULL) as marcas_sem_premium,
    COUNT(*) FILTER (WHERE m.is_premium IS NOT NULL) as marcas_com_premium,
    COUNT(*) as total_lentes
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
WHERE l.ativo = true;


| marcas_sem_premium | marcas_com_premium | total_lentes |
| ------------------ | ------------------ | ------------ |
| 0                  | 1411               | 1411         |


\echo ''
\echo '===================================================================='
\echo '3. DISTRIBUIÇÃO marca_premium (via marcas.is_premium)'
\echo '===================================================================='

SELECT 
    COALESCE(m.is_premium::TEXT, 'NULL') as marca_premium,
    COUNT(*) as total_lentes,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentual
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
WHERE l.ativo = true
GROUP BY m.is_premium
ORDER BY m.is_premium DESC NULLS LAST;


| marca_premium | total_lentes | percentual |
| ------------- | ------------ | ---------- |
| true          | 248          | 17.58      |
| false         | 1163         | 82.42      |


\echo ''
\echo '===================================================================='
\echo '4. AMOSTRAS: Lentes por marca e premium'
\echo '===================================================================='

SELECT 
    m.nome as marca,
    m.is_premium as marca_is_premium,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE m.is_premium = true) as premium,
    COUNT(*) FILTER (WHERE m.is_premium = false) as standard,
    COUNT(*) FILTER (WHERE m.is_premium IS NULL) as sem_definir
FROM lens_catalog.lentes l
JOIN lens_catalog.marcas m ON m.id = l.marca_id
WHERE l.ativo = true
GROUP BY m.id, m.nome, m.is_premium
ORDER BY total DESC
LIMIT 10;


| marca       | marca_is_premium | total | premium | standard | sem_definir |
| ----------- | ---------------- | ----- | ------- | -------- | ----------- |
| SO BLOCOS   | false            | 880   | 0       | 880      | 0           |
| TRANSITIONS | true             | 234   | 234     | 0        | 0           |
| POLYLUX     | false            | 132   | 0       | 132      | 0           |
| BRASCOR     | false            | 56    | 0       | 56       | 0           |
| EXPRESS     | false            | 50    | 0       | 50       | 0           |
| SYGMA       | false            | 38    | 0       | 38       | 0           |
| VARILUX     | true             | 11    | 11      | 0        | 0           |
| GENÉRICA    | false            | 7     | 0       | 7        | 0           |
| ESSILOR     | true             | 3     | 3       | 0        | 0           |




\echo ''
\echo '===================================================================='
\echo 'RESULTADO FINAL'
\echo '===================================================================='

WITH check AS (
    SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE l.marca_id IS NULL) as sem_marca,
        COUNT(*) FILTER (WHERE m.is_premium IS NULL) as marcas_sem_premium
    FROM lens_catalog.lentes l
    LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
    WHERE l.ativo = true
)
SELECT 
    total,
    sem_marca,
    marcas_sem_premium,
    CASE 
        WHEN sem_marca = 0 AND marcas_sem_premium = 0 THEN '✅ OK - EXECUTAR 99V e 99W'
        ELSE '⚠️  CORRIGIR PRIMEIRO'
    END as status
FROM check;


Error: Failed to run sql query: ERROR: 42601: syntax error at or near "check" LINE 2: WITH check AS ( ^



