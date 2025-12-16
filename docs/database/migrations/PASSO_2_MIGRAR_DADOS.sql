-- ============================================
-- PASSO 2: MIGRAR DADOS EXISTENTES
-- ============================================
-- Popular as novas colunas com dados de produtos_laboratorio

-- ============================================
-- 2.1: POPULAR sku_laboratorio e laboratorio_id
-- ============================================

-- As 1.411 lentes precisam dos dados de laboratório
-- Vamos usar produtos_laboratorio como fonte (515 registros)

UPDATE lens_catalog.lentes l
SET 
    sku_laboratorio = p.sku_laboratorio,
    laboratorio_id = p.laboratorio_id,
    nome_comercial = p.nome_comercial
FROM suppliers.produtos_laboratorio p
WHERE p.lente_id = l.id
  AND l.tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf';

-- Verificar quantas foram atualizadas
SELECT 
    COUNT(*) as total_lentes,
    COUNT(sku_laboratorio) as com_sku_lab,
    COUNT(laboratorio_id) as com_lab_id,
    COUNT(*) - COUNT(sku_laboratorio) as sem_info_lab
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf';

-- Resultado esperado:
-- total_lentes: 1411
-- com_sku_lab: 515
-- com_lab_id: 515
-- sem_info_lab: 896  ← Essas precisam de dados!

-- ============================================
-- 2.2: ATUALIZAR nivel_qualidade BASEADO EM marca
-- ============================================

-- Definir nivel_qualidade baseado na marca
-- Premium (4-5): Essilor, Hoya, Zeiss, etc
-- Genérica (1-3): Outras

-- Lista de marcas premium
UPDATE lens_catalog.lentes l
SET nivel_qualidade = 5
FROM lens_catalog.marcas m
WHERE l.marca_id = m.id
  AND l.tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND m.nome IN ('Essilor', 'Hoya', 'Zeiss', 'Rodenstock');

-- Marcas semi-premium (nível 4)
UPDATE lens_catalog.lentes l
SET nivel_qualidade = 4
FROM lens_catalog.marcas m
WHERE l.marca_id = m.id
  AND l.tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND m.nome IN ('Kodak', 'Shamir', 'Indo');

-- Resto fica com nível padrão (3 - genérica média)
UPDATE lens_catalog.lentes
SET nivel_qualidade = 3
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND nivel_qualidade IS NULL;

-- Verificar distribuição
SELECT 
    m.nome as marca,
    l.nivel_qualidade,
    COUNT(*) as qtd,
    CASE 
        WHEN l.nivel_qualidade >= 4 THEN 'PREMIUM'
        ELSE 'GENÉRICA'
    END as classificacao
FROM lens_catalog.lentes l
JOIN lens_catalog.marcas m ON m.id = l.marca_id
WHERE l.tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
GROUP BY m.nome, l.nivel_qualidade
ORDER BY l.nivel_qualidade DESC, m.nome;

-- ============================================
-- 2.3: ATUALIZAR is_premium (trigger fará isso)
-- ============================================

-- Forçar update para acionar trigger de classificação
UPDATE lens_catalog.lentes
SET nivel_qualidade = nivel_qualidade
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf';

-- Verificar
SELECT 
    is_premium,
    COUNT(*) as qtd
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
GROUP BY is_premium;

-- ============================================
-- 2.4: VINCULAR CANÔNICAS (triggers farão isso)
-- ============================================

-- Forçar update para acionar triggers de vínculo
UPDATE lens_catalog.lentes
SET tipo_lente = tipo_lente
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf';

-- Verificar vínculos criados
SELECT 
    CASE 
        WHEN lente_canonica_id IS NOT NULL THEN 'Genérica vinculada'
        WHEN premium_canonica_id IS NOT NULL THEN 'Premium vinculada'
        ELSE 'Sem vínculo'
    END as status,
    COUNT(*) as qtd
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
GROUP BY status;

-- Ver canônicas criadas
SELECT 
    COUNT(*) as total_canonicas_genericas
FROM lens_catalog.lentes_canonicas
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf';

SELECT 
    COUNT(*) as total_canonicas_premium
FROM lens_catalog.premium_canonicas
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf';

-- ============================================
-- 2.5: VERIFICAÇÃO COMPLETA
-- ============================================

-- Resumo geral
SELECT 
    'Total de lentes' as metrica,
    COUNT(*) as valor
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'

UNION ALL

SELECT 
    'Lentes com laboratório',
    COUNT(*)
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND laboratorio_id IS NOT NULL

UNION ALL

SELECT 
    'Lentes premium',
    COUNT(*)
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND is_premium = TRUE

UNION ALL

SELECT 
    'Lentes genéricas',
    COUNT(*)
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND is_premium = FALSE

UNION ALL

SELECT 
    'Canônicas genéricas criadas',
    COUNT(*)
FROM lens_catalog.lentes_canonicas
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'

UNION ALL

SELECT 
    'Canônicas premium criadas',
    COUNT(*)
FROM lens_catalog.premium_canonicas
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf';

-- Ver exemplos de agrupamento
SELECT 
    pc.sku_canonico_premium,
    pc.linha_produto,
    m.nome as marca,
    COUNT(l.id) as qtd_labs,
    STRING_AGG(DISTINCT lab.nome_fantasia, ', ') as labs
FROM lens_catalog.premium_canonicas pc
LEFT JOIN lens_catalog.lentes l ON l.premium_canonica_id = pc.id
LEFT JOIN lens_catalog.marcas m ON m.id = pc.marca_id
LEFT JOIN suppliers.laboratorios lab ON lab.id = l.laboratorio_id
WHERE pc.tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
GROUP BY pc.id, pc.sku_canonico_premium, pc.linha_produto, m.nome
ORDER BY qtd_labs DESC
LIMIT 20;


| metrica                     | valor |
| --------------------------- | ----- |
| Total de lentes             | 1411  |
| Lentes com laboratório      | 515   |
| Lentes premium              | 0     |
| Lentes genéricas            | 1411  |
| Canônicas genéricas criadas | 3572  |
| Canônicas premium criadas   | 0     |
