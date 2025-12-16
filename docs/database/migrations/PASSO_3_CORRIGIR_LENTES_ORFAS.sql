-- ============================================
-- PASSO 3: CORRIGIR DADOS DAS 896 LENTES SEM LABORATÓRIO
-- ============================================

-- Problema: 1.411 lentes mas só 515 têm laboratório
-- Causa: CSV original tinha duplicatas que foram removidas

-- Solução: Precisamos do CSV COMPLETO (1.411 linhas) para popular corretamente

-- ============================================
-- 3.1: ANALISAR SITUAÇÃO
-- ============================================

-- Ver lentes sem laboratório
SELECT 
    l.sku_canonico,
    l.familia,
    l.tipo_lente,
    l.material,
    l.indice_refracao,
    m.nome as marca
FROM lens_catalog.lentes l
JOIN lens_catalog.marcas m ON m.id = l.marca_id
WHERE l.tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND l.laboratorio_id IS NULL
LIMIT 20;

| sku_canonico        | familia  | tipo_lente  | material      | indice_refracao | marca    |
| ------------------- | -------- | ----------- | ------------- | --------------- | -------- |
| LENS-0025-MLTYBRIR3 | VS HDI   | PROGRESSIVA | ORGANICO      | 1.56            | POLYLUX  |
| LENS-0052-MLTST4S6O | VS HDI   | MONOFOCAL   | ORGANICO      | 1.49            | POLYLUX  |
| LENS-0056-MLTDRR5ND | ACOMODA  | MONOFOCAL   | ORGANICO      | 1.67            | BRASCOR  |
| LENS-0059-MLTAUV40O | FREEVIEW | MONOFOCAL   | ORGANICO      | 1.67            | SOBLOCOS |
| LENS-0061-MLT8SPCWI | TOP VIEW | PROGRESSIVA | ORGANICO      | 1.56            | BRASCOR  |
| LENS-0076-MLT834PCP | VS HDI   | MONOFOCAL   | POLICARBONATO | 1.59            | SOBLOCOS |
| LENS-0079-MLTII4OAF | VS HDI   | MONOFOCAL   | ORGANICO      | 1.74            | SOBLOCOS |
| LENS-0081-MLTNFVK7G | FREEVIEW | MONOFOCAL   | ORGANICO      | 1.67            | BRASCOR  |
| LENS-0082-MLTJA8M46 | FREEVIEW | PROGRESSIVA | ORGANICO      | 1.56            | SOBLOCOS |
| LENS-0086-MLTSQ4FQ7 | FREEVIEW | MONOFOCAL   | ORGANICO      | 1.74            | SOBLOCOS |
| LENS-0091-MLTNTL171 | TOP VIEW | PROGRESSIVA | ORGANICO      | 1.56            | BRASCOR  |
| LENS-0095-MLTBW6ZB5 | TOP VIEW | PROGRESSIVA | ORGANICO      | 1.49            | SOBLOCOS |
| LENS-0096-MLT406WRV | VS HDI   | PROGRESSIVA | ORGANICO      | 1.67            | POLYLUX  |
| LENS-0097-MLTBRJF4F | VS HDI   | PROGRESSIVA | ORGANICO      | 1.56            | POLYLUX  |
| LENS-0102-MLTBS13U4 | VS HDI   | PROGRESSIVA | ORGANICO      | 1.56            | POLYLUX  |
| LENS-0105-MLTWWAEIL | ACOMODA  | PROGRESSIVA | ORGANICO      | 1.67            | SOBLOCOS |
| LENS-0109-MLT30J0ZI | FREEVIEW | PROGRESSIVA | POLICARBONATO | 1.59            | ESSILOR  |
| LENS-0119-MLT94191P | FREEVIEW | PROGRESSIVA | POLICARBONATO | 1.59            | ESSILOR  |
| LENS-0122-MLT55R9NY | FREEVIEW | MONOFOCAL   | ORGANICO      | 1.61            | POLYLUX  |
| LENS-0123-MLTXA48PB | FREEVIEW | MONOFOCAL   | ORGANICO      | 1.67            | POLYLUX  |

-- ============================================
-- 3.2: OPÇÃO A - Usar CSV original completo
-- ============================================

-- 1. Ler produtos_laboratorio_import.csv (1.411 linhas)
-- 2. Criar script para popular todas as lentes

-- Exemplo de estrutura do INSERT:
/*
INSERT INTO suppliers.produtos_laboratorio (
    tenant_id,
    laboratorio_id,
    sku_laboratorio,
    lente_id,
    nome_comercial,
    sku_fantasia,
    preco_custo,
    preco_sugerido,
    ativo
)
SELECT 
    '229220bb-d480-4608-a07c-ae9ab5266caf',
    csv.laboratorio_id,
    csv.sku_laboratorio,
    (SELECT id FROM lens_catalog.lentes WHERE sku_canonico = 'LENS-' || csv.sku_fantasia),
    csv.nome_comercial,
    csv.sku_fantasia,
    csv.preco_custo,
    csv.preco_sugerido,
    TRUE
FROM csv_import
ON CONFLICT (tenant_id, laboratorio_id, sku_laboratorio) DO NOTHING;
*/

-- ============================================
-- 3.3: OPÇÃO B - Criar lentes faltantes do zero
-- ============================================

-- Se as 896 lentes sem laboratório forem variações que não existem
-- em produtos_laboratorio, precisamos de novos dados ou podemos removê-las

-- Remover lentes órfãs (SEM EXECUTAR AINDA!)
-- DELETE FROM lens_catalog.lentes
-- WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
--   AND laboratorio_id IS NULL;

-- ============================================
-- 3.4: DECISÃO NECESSÁRIA
-- ============================================

-- ❓ Pergunta: As 896 lentes sem laboratório são:
--   A) Variações reais que precisam de dados de laboratório?
--   B) Duplicatas/lixo que podem ser removidas?
--
-- Se A: Precisamos do CSV completo original (produtos_laboratorio_import.csv)
-- Se B: Podemos remover essas lentes

-- Ver estatísticas para decidir
SELECT 
    'Lentes com laboratório' as tipo,
    COUNT(*) as qtd,
    COUNT(DISTINCT familia) as familias_diferentes,
    COUNT(DISTINCT marca_id) as marcas_diferentes
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND laboratorio_id IS NOT NULL

UNION ALL

SELECT 
    'Lentes SEM laboratório',
    COUNT(*),
    COUNT(DISTINCT familia),
    COUNT(DISTINCT marca_id)
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND laboratorio_id IS NULL;

| tipo                   | qtd | familias_diferentes | marcas_diferentes |
| ---------------------- | --- | ------------------- | ----------------- |
| Lentes com laboratório | 515 | 9                   | 6                 |
| Lentes SEM laboratório | 896 | 7                   | 6                 |