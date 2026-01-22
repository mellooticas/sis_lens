-- ============================================================================
-- 99X - VERIFICAÇÃO DE MARCAS E IS_PREMIUM NAS LENTES
-- ============================================================================
-- Verifica se todas as lentes têm:
-- 1. marca_id definida (não NULL)
-- 2. is_premium definido (não NULL)
-- ============================================================================

\echo '===================================================================='
\echo 'VERIFICAÇÃO 1: Lentes SEM marca_id'
\echo '===================================================================='

SELECT 
    COUNT(*) as total_sem_marca,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ TODAS as lentes têm marca definida'
        ELSE '⚠️  ATENÇÃO: Existem lentes sem marca'
    END as status
FROM lens_catalog.lentes
WHERE ativo = true 
  AND marca_id IS NULL;


| total_sem_marca | status                               |
| --------------- | ------------------------------------ |
| 0               | ✅ TODAS as lentes têm marca definida |


\echo ''
\echo '===================================================================='
\echo 'VERIFICAÇÃO 2: Lentes com marcas SEM is_premium definido'
\echo '===================================================================='

SELECT 
    COUNT(*) as total_sem_premium,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ TODAS as marcas têm is_premium definido'
        ELSE '⚠️  ATENÇÃO: Existem marcas sem is_premium'
    END as status
FROM lens_catalog.lentes l
JOIN lens_catalog.marcas m ON m.id = l.marca_id
WHERE l.ativo = true 
  AND m.is_premium IS NULL;


| total_sem_premium | status                                    |
| ----------------- | ----------------------------------------- |
| 0                 | ✅ TODAS as marcas têm is_premium definido |


\echo ''
\echo '===================================================================='
\echo 'DISTRIBUIÇÃO: Lentes por is_premium (via marca)'
\echo '===================================================================='

SELECT 
    m.is_premium,
    COUNT(l.id) as total_lentes,
    ROUND(COUNT(l.id) * 100.0 / SUM(COUNT(l.id)) OVER (), 2) as percentual
FROM lens_catalog.lentes l
JOIN lens_catalog.marcas m ON m.id = l.marca_id
WHERE l.ativo = true
GROUP BY m.is_premium
ORDER BY m.is_premium DESC NULLS LAST;


| is_premium | total_lentes | percentual |
| ---------- | ------------ | ---------- |
| true       | 248          | 17.58      |
| false      | 1163         | 82.42      |


\echo ''
\echo '===================================================================='
\echo 'DISTRIBUIÇÃO: Lentes por Marca'
\echo '===================================================================='

SELECT 
    m.nome as marca,
    COUNT(l.id) as total_lentes,
    COUNT(CASE WHEN l.is_premium = true THEN 1 END) as lentes_premium,
    COUNT(CASE WHEN l.is_premium = false THEN 1 END) as lentes_standard,
    ROUND(COUNT(l.id) * 100.0 / SUM(COUNT(l.id)) OVER (), 2) as percentual
FROM lens_catalog.marcas m
LEFT JOIN lens_catalog.lentes l ON l.marca_id = m.id AND l.ativo = true
WHERE m.ativo = true
GROUP BY m.id, m.nome
ORDER BY total_lentes DESC;

Error: Failed to run sql query: ERROR: 42703: column l.is_premium does not exist LINE 5: COUNT(CASE WHEN l.is_premium = true THEN 1 END) as lentes_premium, ^ HINT: Perhaps you meant to reference the column "m.is_premium".




\echo ''
\echo '===================================================================='
\echo 'PROBLEMAS: Lentes sem marca_id (se houver)'
\echo '===================================================================='

SELECT 
    id,
    nome,
    tipo_lente,
    categoria,
    is_premium,
    fornecedor_id
FROM lens_catalog.lentes
WHERE ativo = true 
  AND marca_id IS NULL
LIMIT 10;


Error: Failed to run sql query: ERROR: 42703: column "nome" does not exist LINE 4: nome, ^




\echo ''
\echo '===================================================================='
\echo 'PROBLEMAS: Marcas sem is_premium (se houver)'
\echo '===================================================================='

SELECT 
    m.id,
    m.nome as marca,
    m.is_premium,
    COUNT(l.id) as total_lentes_afetadas
FROM lens_catalog.marcas m
LEFT JOIN lens_catalog.lentes l ON l.marca_id = m.id AND l.ativo = true
WHERE m.ativo = true 
  AND m.is_premium IS NULL
GROUP BY m.id, m.nome, m.is_premium
LIMIT 10;

Success. No rows returned





\echo ''
\echo '===================================================================='
\echo 'VALIDAÇÃO FINAL'
\echo '===================================================================='

WITH validacao AS (
    SELECT 
        COUNT(l.id) as total_lentes,
        COUNT(CASE WHEN l.marca_id IS NULL THEN 1 END) as sem_marca,
        COUNT(CASE WHEN m.is_premium IS NULL THEN 1 END) as marcas_sem_premium,
        COUNT(CASE WHEN l.marca_id IS NOT NULL AND m.is_premium IS NOT NULL THEN 1 END) as lentes_ok
    FROM lens_catalog.lentes l
    LEFT JOIN lens_catalog.marcas m ON m.id = l.marca_id
    WHERE l.ativo = true
)
SELECT 
    total_lentes,
    lentes_ok,
    sem_marca,
    marcas_sem_premium,
    CASE 
        WHEN sem_marca = 0 AND marcas_sem_premium = 0 THEN '✅ TUDO OK - Pode executar 99V e 99W'
        ELSE '⚠️  CORRIGIR antes de executar 99V e 99W'
    END as resultado
FROM validacao;


| total_lentes | lentes_ok | sem_marca | marcas_sem_premium | resultado                           |
| ------------ | --------- | --------- | ------------------ | ----------------------------------- |
| 1411         | 1411      | 0         | 0                  | ✅ TUDO OK - Pode executar 99V e 99W |

