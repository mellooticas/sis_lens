-- =====================================================
-- INVESTIGAÇÃO DE ESTRUTURA PARA DASHBOARD
-- Responda executando cada query no Supabase e colando os resultados
-- =====================================================

-- =========================================
-- 1. ENUMS - Valores permitidos
-- =========================================

-- Query 1.1: Tipo de Lente
SELECT enumlabel as valor, enumsortorder as ordem
FROM pg_enum 
WHERE enumtypid = 'lens_catalog.tipo_lente'::regtype
ORDER BY enumsortorder;

-- RESULTADO:
-- | valor | ordem |
-- |-------|-------|
-- |       |       |


-- Query 1.2: Material
SELECT enumlabel as valor, enumsortorder as ordem
FROM pg_enum 
WHERE enumtypid = 'lens_catalog.material_lente'::regtype
ORDER BY enumsortorder;

-- RESULTADO:
-- | valor | ordem |
-- |-------|-------|
-- |       |       |


-- Query 1.3: Categoria de Lente
SELECT enumlabel as valor, enumsortorder as ordem
FROM pg_enum 
WHERE enumtypid = 'lens_catalog.categoria_lente'::regtype
ORDER BY enumsortorder;

-- RESULTADO:
-- | valor | ordem |
-- |-------|-------|
-- |       |       |


-- Query 1.4: Tratamento Fotossensível
SELECT enumlabel as valor, enumsortorder as ordem
FROM pg_enum 
WHERE enumtypid = 'lens_catalog.tratamento_foto'::regtype
ORDER BY enumsortorder;

-- RESULTADO:
-- | valor | ordem |
-- |-------|-------|
-- |       |       |


-- =========================================
-- 2. CONTADORES - Verificar dados reais
-- =========================================

-- Query 2.1: Total por tipo de lente
SELECT 
    tipo_lente,
    COUNT(*) as total
FROM lens_catalog.lentes 
WHERE ativo = true AND deleted_at IS NULL
GROUP BY tipo_lente
ORDER BY total DESC;

-- RESULTADO:
-- | tipo_lente | total |
-- |------------|-------|
-- |            |       |


-- Query 2.2: Total por material
SELECT 
    material,
    COUNT(*) as total
FROM lens_catalog.lentes 
WHERE ativo = true AND deleted_at IS NULL
GROUP BY material
ORDER BY total DESC;

-- RESULTADO:
-- | material | total |
-- |----------|-------|
-- |          |       |


-- Query 2.3: Total por categoria
SELECT 
    categoria,
    COUNT(*) as total
FROM lens_catalog.lentes 
WHERE ativo = true AND deleted_at IS NULL
GROUP BY categoria
ORDER BY total DESC;

-- RESULTADO:
-- | categoria | total |
-- |-----------|-------|
-- |           |       |


-- Query 2.4: Total por índice de refração
SELECT 
    indice_refracao,
    COUNT(*) as total
FROM lens_catalog.lentes 
WHERE ativo = true AND deleted_at IS NULL
GROUP BY indice_refracao
ORDER BY indice_refracao;

-- RESULTADO:
-- | indice_refracao | total |
-- |-----------------|-------|
-- |                 |       |


-- =========================================
-- 3. TRATAMENTOS - Verificar campos booleanos
-- =========================================

-- Query 3.1: Tratamentos disponíveis
SELECT 
    COUNT(*) FILTER (WHERE tratamento_antirreflexo = true) as com_ar,
    COUNT(*) FILTER (WHERE tratamento_blue_light = true) as com_blue,
    COUNT(*) FILTER (WHERE tratamento_uv = true) as com_uv,
    COUNT(*) FILTER (WHERE tratamento_antirrisco = true) as com_antirrisco,
    COUNT(*) FILTER (WHERE tratamento_fotossensiveis IS NOT NULL AND tratamento_fotossensiveis != 'nenhum') as com_foto
FROM lens_catalog.lentes 
WHERE ativo = true AND deleted_at IS NULL;

-- RESULTADO:
-- | com_ar | com_blue | com_uv | com_antirrisco | com_foto |
-- |--------|----------|--------|----------------|----------|
-- |        |          |        |                |          |


-- =========================================
-- 4. GRUPOS CANÔNICOS - Premium vs Standard
-- =========================================

-- Query 4.1: Grupos por tipo
SELECT 
    is_premium,
    COUNT(*) as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
GROUP BY is_premium;

-- RESULTADO:
-- | is_premium | total |
-- |------------|-------|
-- |            |       |


-- Query 4.2: Marcas premium
SELECT 
    is_premium,
    COUNT(*) as total
FROM lens_catalog.marcas
WHERE ativo = true
GROUP BY is_premium;

-- RESULTADO:
-- | is_premium | total |
-- |------------|-------|
-- |            |       |


-- =========================================
-- 5. VERIFICAR COLUNAS - Confirmar existência
-- =========================================

-- Query 5.1: Colunas da tabela lentes
SELECT 
    column_name,
    data_type,
    udt_name
FROM information_schema.columns
WHERE table_schema = 'lens_catalog' 
  AND table_name = 'lentes'
  AND column_name IN (
    'tipo_lente', 'material', 'categoria', 'indice_refracao',
    'tratamento_antirreflexo', 'tratamento_blue_light', 'tratamento_uv',
    'tratamento_antirrisco', 'tratamento_fotossensiveis',
    'preco_venda_sugerido', 'grupo_canonico_id', 'ativo', 'deleted_at'
  )
ORDER BY column_name;

-- RESULTADO:
-- | column_name | data_type | udt_name |
-- |-------------|-----------|----------|
-- |             |           |          |
