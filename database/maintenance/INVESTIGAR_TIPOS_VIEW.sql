-- ============================================
-- INVESTIGAÇÃO: Tipos de dados da view vw_lentes_catalogo
-- Execute no Supabase SQL Editor e cole os resultados
-- ============================================

-- Query 1: Ver estrutura completa da view com tipos de dados
SELECT 
    column_name,
    data_type,
    udt_name,
    character_maximum_length,
    numeric_precision,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'vw_lentes_catalogo'
ORDER BY ordinal_position;

-- ============================================
-- Query 2: Ver os primeiros 3 registros com todos os campos
SELECT 
    id,
    nome_comercial,
    tipo_lente,
    categoria,
    material,
    indice_refracao,
    preco_tabela,
    marca_nome,
    marca_premium,
    ar,
    blue,
    fotossensivel,
    uv400,
    esferico_min,
    esferico_max,
    cilindrico_min,
    cilindrico_max,
    adicao_min,
    adicao_max
FROM public.vw_lentes_catalogo
LIMIT 3;

-- ============================================
-- Query 3: Verificar tipos de ENUM
SELECT 
    t.typname AS enum_name,
    e.enumlabel AS enum_value,
    e.enumsortorder AS sort_order
FROM pg_type t
JOIN pg_enum e ON t.oid = e.enumtypid
WHERE t.typname IN (
    'tipo_lente',
    'categoria_lente', 
    'material_lente',
    'indice_refracao',
    'tratamento_foto'
)
ORDER BY t.typname, e.enumsortorder;

-- ============================================
-- Query 4: Testar função com cast simples
SELECT 
    id,
    nome_comercial::TEXT,
    tipo_lente::TEXT,
    categoria::TEXT,
    material::TEXT,
    indice_refracao::TEXT,
    preco_tabela::NUMERIC,
    marca_nome::TEXT,
    marca_premium::BOOLEAN,
    ar::BOOLEAN,
    blue::BOOLEAN,
    fotossensivel::TEXT,
    uv400::BOOLEAN,
    esferico_min::NUMERIC,
    esferico_max::NUMERIC,
    cilindrico_min::NUMERIC,
    cilindrico_max::NUMERIC,
    adicao_min::NUMERIC,
    adicao_max::NUMERIC
FROM public.vw_lentes_catalogo
WHERE esferico_min <= -2.00 AND esferico_max >= -2.00
  AND cilindrico_min <= -0.50 AND cilindrico_max >= -0.50
LIMIT 5;

-- ============================================
-- Query 5: Ver definição da tabela lens_catalog.marcas
SELECT 
    column_name,
    data_type,
    udt_name,
    character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'lens_catalog' 
  AND table_name = 'marcas'
  AND column_name = 'nome';
