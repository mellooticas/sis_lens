-- ============================================================================
-- LIMPEZA: Remover Fornecedores Duplicados
-- ============================================================================
-- Data: Janeiro/2026
-- Problema: Existem fornecedores duplicados no banco:
--   - Alcon Laboratorios do Brasil (2x)
--   - Bausch & Lomb Brasil (2x)
--   - CooperVision Brasil (2x)
--   - Johnson & Johnson Vision Care (2x)
-- ============================================================================

-- ============================================================================
-- PARTE 1: DIAGNÓSTICO - Ver duplicados
-- ============================================================================

\echo '============================================'
\echo '1. FORNECEDORES DUPLICADOS'
\echo '============================================'

SELECT
    nome,
    COUNT(*) as quantidade,
    STRING_AGG(id::text, ', ') as ids
FROM core.fornecedores
GROUP BY nome
HAVING COUNT(*) > 1
ORDER BY nome;


| nome                          | quantidade | ids                                                                        |
| ----------------------------- | ---------- | -------------------------------------------------------------------------- |
| Alcon Laboratorios do Brasil  | 2          | 7534efcc-3412-488c-abb4-d6acd670d8ec, f0c192cd-1ba8-459b-a82e-b3ff049644d9 |
| Bausch & Lomb Brasil          | 2          | a725651f-79ee-4558-8f69-dc8b066b3319, 14ddf79c-224a-4027-8ec9-886f17ad2820 |
| CooperVision Brasil           | 2          | 9400f665-2f93-47ba-97c5-2a2248236e6a, 89c13390-fd7b-401b-9f5d-7a9c2ee87366 |
| Johnson & Johnson Vision Care | 2          | 4bc166bb-e576-483f-aec1-94c95c5bc68f, 4b2d639c-1895-4c17-8a6f-442dc8a8d046 |

-- Detalhes dos duplicados
\echo ''
\echo 'DETALHES DOS DUPLICADOS:'
SELECT
    id,
    nome,
    razao_social,
    created_at
FROM core.fornecedores
WHERE nome IN (
    SELECT nome FROM core.fornecedores GROUP BY nome HAVING COUNT(*) > 1
)
ORDER BY nome, created_at;


| id                                   | nome                          | razao_social                                          | created_at                    |
| ------------------------------------ | ----------------------------- | ----------------------------------------------------- | ----------------------------- |
| 7534efcc-3412-488c-abb4-d6acd670d8ec | Alcon Laboratorios do Brasil  | Alcon Laboratorios do Brasil LTDA                     | 2026-01-22 20:59:42.467847+00 |
| f0c192cd-1ba8-459b-a82e-b3ff049644d9 | Alcon Laboratorios do Brasil  | Alcon Laboratorios do Brasil LTDA                     | 2026-01-22 21:06:35.331465+00 |
| a725651f-79ee-4558-8f69-dc8b066b3319 | Bausch & Lomb Brasil          | Bausch & Lomb do Brasil LTDA                          | 2026-01-22 20:59:42.467847+00 |
| 14ddf79c-224a-4027-8ec9-886f17ad2820 | Bausch & Lomb Brasil          | Bausch & Lomb do Brasil LTDA                          | 2026-01-22 21:06:35.331465+00 |
| 9400f665-2f93-47ba-97c5-2a2248236e6a | CooperVision Brasil           | CooperVision do Brasil Produtos Oftalmicos LTDA       | 2026-01-22 20:59:42.467847+00 |
| 89c13390-fd7b-401b-9f5d-7a9c2ee87366 | CooperVision Brasil           | CooperVision do Brasil Produtos Oftalmicos LTDA       | 2026-01-22 21:06:35.331465+00 |
| 4bc166bb-e576-483f-aec1-94c95c5bc68f | Johnson & Johnson Vision Care | Johnson & Johnson do Brasil Industria e Comercio LTDA | 2026-01-22 20:59:42.467847+00 |
| 4b2d639c-1895-4c17-8a6f-442dc8a8d046 | Johnson & Johnson Vision Care | Johnson & Johnson do Brasil Industria e Comercio LTDA | 2026-01-22 21:06:35.331465+00 |

-- ============================================================================
-- PARTE 2: VERIFICAR SE HÁ LENTES VINCULADAS
-- ============================================================================

\echo ''
\echo '============================================'
\echo '2. LENTES VINCULADAS AOS DUPLICADOS'
\echo '============================================'

SELECT
    f.id as fornecedor_id,
    f.nome,
    COUNT(l.id) as total_lentes
FROM core.fornecedores f
LEFT JOIN lens_catalog.lentes l ON l.fornecedor_id = f.id
WHERE f.nome IN (
    SELECT nome FROM core.fornecedores GROUP BY nome HAVING COUNT(*) > 1
)
GROUP BY f.id, f.nome
ORDER BY f.nome, total_lentes DESC;


| fornecedor_id                        | nome                          | total_lentes |
| ------------------------------------ | ----------------------------- | ------------ |
| 7534efcc-3412-488c-abb4-d6acd670d8ec | Alcon Laboratorios do Brasil  | 0            |
| f0c192cd-1ba8-459b-a82e-b3ff049644d9 | Alcon Laboratorios do Brasil  | 0            |
| 14ddf79c-224a-4027-8ec9-886f17ad2820 | Bausch & Lomb Brasil          | 0            |
| a725651f-79ee-4558-8f69-dc8b066b3319 | Bausch & Lomb Brasil          | 0            |
| 9400f665-2f93-47ba-97c5-2a2248236e6a | CooperVision Brasil           | 0            |
| 89c13390-fd7b-401b-9f5d-7a9c2ee87366 | CooperVision Brasil           | 0            |
| 4b2d639c-1895-4c17-8a6f-442dc8a8d046 | Johnson & Johnson Vision Care | 0            |
| 4bc166bb-e576-483f-aec1-94c95c5bc68f | Johnson & Johnson Vision Care | 0            |


-- ============================================================================
-- PARTE 3: IDENTIFICAR QUAL MANTER (o mais antigo ou o com mais lentes)
-- ============================================================================

\echo ''
\echo '============================================'
\echo '3. QUAL ID MANTER POR FORNECEDOR'
\echo '============================================'

-- Vamos manter o mais antigo (primeiro criado)
WITH duplicados AS (
    SELECT
        nome,
        id,
        created_at,
        ROW_NUMBER() OVER (PARTITION BY nome ORDER BY created_at ASC) as rn
    FROM core.fornecedores
    WHERE nome IN (
        SELECT nome FROM core.fornecedores GROUP BY nome HAVING COUNT(*) > 1
    )
)
SELECT
    nome,
    id,
    CASE WHEN rn = 1 THEN '✅ MANTER' ELSE '❌ REMOVER' END as acao,
    created_at
FROM duplicados
ORDER BY nome, rn;


| nome                          | id                                   | acao      | created_at                    |
| ----------------------------- | ------------------------------------ | --------- | ----------------------------- |
| Alcon Laboratorios do Brasil  | 7534efcc-3412-488c-abb4-d6acd670d8ec | ✅ MANTER  | 2026-01-22 20:59:42.467847+00 |
| Alcon Laboratorios do Brasil  | f0c192cd-1ba8-459b-a82e-b3ff049644d9 | ❌ REMOVER | 2026-01-22 21:06:35.331465+00 |
| Bausch & Lomb Brasil          | a725651f-79ee-4558-8f69-dc8b066b3319 | ✅ MANTER  | 2026-01-22 20:59:42.467847+00 |
| Bausch & Lomb Brasil          | 14ddf79c-224a-4027-8ec9-886f17ad2820 | ❌ REMOVER | 2026-01-22 21:06:35.331465+00 |
| CooperVision Brasil           | 9400f665-2f93-47ba-97c5-2a2248236e6a | ✅ MANTER  | 2026-01-22 20:59:42.467847+00 |
| CooperVision Brasil           | 89c13390-fd7b-401b-9f5d-7a9c2ee87366 | ❌ REMOVER | 2026-01-22 21:06:35.331465+00 |
| Johnson & Johnson Vision Care | 4bc166bb-e576-483f-aec1-94c95c5bc68f | ✅ MANTER  | 2026-01-22 20:59:42.467847+00 |
| Johnson & Johnson Vision Care | 4b2d639c-1895-4c17-8a6f-442dc8a8d046 | ❌ REMOVER | 2026-01-22 21:06:35.331465+00 |


-- ============================================================================
-- PARTE 4: REMOVER DUPLICADOS (EXECUTAR COM CUIDADO!)
-- ============================================================================

\echo ''
\echo '============================================'
\echo '4. REMOVENDO DUPLICADOS...'
\echo '============================================'

-- Criar tabela temporária com IDs a remover
CREATE TEMP TABLE ids_para_remover AS
WITH duplicados AS (
    SELECT
        id,
        nome,
        ROW_NUMBER() OVER (PARTITION BY nome ORDER BY created_at ASC) as rn
    FROM core.fornecedores
    WHERE nome IN (
        SELECT nome FROM core.fornecedores GROUP BY nome HAVING COUNT(*) > 1
    )
)
SELECT id, nome FROM duplicados WHERE rn > 1;

-- Mostrar o que será removido
SELECT * FROM ids_para_remover;

-- Verificar se há lentes vinculadas aos que serão removidos
\echo ''
\echo 'VERIFICANDO LENTES NOS IDs A REMOVER:'
SELECT
    ipr.id,
    ipr.nome,
    COUNT(l.id) as lentes_vinculadas
FROM ids_para_remover ipr
LEFT JOIN lens_catalog.lentes l ON l.fornecedor_id = ipr.id
GROUP BY ipr.id, ipr.nome;

-- Se houver lentes, precisamos migrar primeiro (descomente se necessário)
/*
-- Migrar lentes para o ID que será mantido
UPDATE lens_catalog.lentes l
SET fornecedor_id = (
    SELECT id FROM core.fornecedores f2
    WHERE f2.nome = (SELECT nome FROM core.fornecedores WHERE id = l.fornecedor_id)
    ORDER BY created_at ASC
    LIMIT 1
)
WHERE fornecedor_id IN (SELECT id FROM ids_para_remover);
*/

-- DELETAR os duplicados (somente se não houver lentes vinculadas!)
DELETE FROM core.fornecedores
WHERE id IN (SELECT id FROM ids_para_remover)
  AND NOT EXISTS (
    SELECT 1 FROM lens_catalog.lentes l WHERE l.fornecedor_id = core.fornecedores.id
  );

-- Limpar tabela temporária
DROP TABLE IF EXISTS ids_para_remover;

-- ============================================================================
-- PARTE 5: VERIFICAÇÃO FINAL
-- ============================================================================

\echo ''
\echo '============================================'
\echo '5. VERIFICAÇÃO FINAL'
\echo '============================================'

-- Verificar se ainda há duplicados
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN '✅ OK - Nenhum duplicado restante'
        ELSE '⚠️ ATENÇÃO - Ainda há duplicados!'
    END as status
FROM (
    SELECT nome FROM core.fornecedores GROUP BY nome HAVING COUNT(*) > 1
) duplicados;

-- Listar fornecedores finais
\echo ''
\echo 'FORNECEDORES APÓS LIMPEZA:'
SELECT
    id,
    nome,
    ativo,
    (SELECT COUNT(*) FROM lens_catalog.lentes l WHERE l.fornecedor_id = f.id) as total_lentes
FROM core.fornecedores f
ORDER BY nome;

\echo ''
\echo '============================================'
\echo 'LIMPEZA CONCLUÍDA!'
\echo '============================================'
