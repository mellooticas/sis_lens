-- ============================================
-- DIAGNÓSTICO DOS ENUMS DO BANCO
-- Descobrir valores possíveis dos enums
-- ============================================

-- 1. ENUM: tipo_lente
SELECT 
  '=== ENUM: lens_catalog.tipo_lente ===' as info,
  enumlabel as valor_possivel,
  enumsortorder as ordem
FROM pg_enum
WHERE enumtypid = 'lens_catalog.tipo_lente'::regtype
ORDER BY enumsortorder;


| info                                  | valor_possivel | ordem |
| ------------------------------------- | -------------- | ----- |
| === ENUM: lens_catalog.tipo_lente === | visao_simples  | 1     |
| === ENUM: lens_catalog.tipo_lente === | multifocal     | 2     |
| === ENUM: lens_catalog.tipo_lente === | bifocal        | 3     |
| === ENUM: lens_catalog.tipo_lente === | leitura        | 4     |
| === ENUM: lens_catalog.tipo_lente === | ocupacional    | 5     |


-- 2. ENUM: categoria_lente
SELECT 
  '=== ENUM: lens_catalog.categoria_lente ===' as info,
  enumlabel as valor_possivel,
  enumsortorder as ordem
FROM pg_enum
WHERE enumtypid = 'lens_catalog.categoria_lente'::regtype
ORDER BY enumsortorder;

| info                                       | valor_possivel | ordem |
| ------------------------------------------ | -------------- | ----- |
| === ENUM: lens_catalog.categoria_lente === | economica      | 1     |
| === ENUM: lens_catalog.categoria_lente === | intermediaria  | 2     |
| === ENUM: lens_catalog.categoria_lente === | premium        | 3     |
| === ENUM: lens_catalog.categoria_lente === | super_premium  | 4     |


-- 3. ENUM: material_lente
SELECT 
  '=== ENUM: lens_catalog.material_lente ===' as info,
  enumlabel as valor_possivel,
  enumsortorder as ordem
FROM pg_enum
WHERE enumtypid = 'lens_catalog.material_lente'::regtype
ORDER BY enumsortorder;

| info                                      | valor_possivel | ordem |
| ----------------------------------------- | -------------- | ----- |
| === ENUM: lens_catalog.material_lente === | CR39           | 1     |
| === ENUM: lens_catalog.material_lente === | POLICARBONATO  | 2     |
| === ENUM: lens_catalog.material_lente === | TRIVEX         | 3     |
| === ENUM: lens_catalog.material_lente === | HIGH_INDEX     | 4     |
| === ENUM: lens_catalog.material_lente === | VIDRO          | 5     |
| === ENUM: lens_catalog.material_lente === | ACRILICO       | 6     |


-- 4. ENUM: indice_refracao
SELECT 
  '=== ENUM: lens_catalog.indice_refracao ===' as info,
  enumlabel as valor_possivel,
  enumsortorder as ordem
FROM pg_enum
WHERE enumtypid = 'lens_catalog.indice_refracao'::regtype
ORDER BY enumsortorder;

| info                                       | valor_possivel | ordem |
| ------------------------------------------ | -------------- | ----- |
| === ENUM: lens_catalog.indice_refracao === | 1.50           | 1     |
| === ENUM: lens_catalog.indice_refracao === | 1.56           | 2     |
| === ENUM: lens_catalog.indice_refracao === | 1.59           | 3     |
| === ENUM: lens_catalog.indice_refracao === | 1.61           | 4     |
| === ENUM: lens_catalog.indice_refracao === | 1.67           | 5     |
| === ENUM: lens_catalog.indice_refracao === | 1.74           | 6     |
| === ENUM: lens_catalog.indice_refracao === | 1.90           | 7     |


-- 5. ENUM: tratamento_foto
SELECT 
  '=== ENUM: lens_catalog.tratamento_foto ===' as info,
  enumlabel as valor_possivel,
  enumsortorder as ordem
FROM pg_enum
WHERE enumtypid = 'lens_catalog.tratamento_foto'::regtype
ORDER BY enumsortorder;

| info                                       | valor_possivel | ordem |
| ------------------------------------------ | -------------- | ----- |
| === ENUM: lens_catalog.tratamento_foto === | nenhum         | 1     |
| === ENUM: lens_catalog.tratamento_foto === | transitions    | 2     |
| === ENUM: lens_catalog.tratamento_foto === | fotocromático  | 3     |
| === ENUM: lens_catalog.tratamento_foto === | polarizado     | 4     |


-- 6. ENUM: status_lente
SELECT 
  '=== ENUM: lens_catalog.status_lente ===' as info,
  enumlabel as valor_possivel,
  enumsortorder as ordem
FROM pg_enum
WHERE enumtypid = 'lens_catalog.status_lente'::regtype
ORDER BY enumsortorder;

| info                                    | valor_possivel | ordem |
| --------------------------------------- | -------------- | ----- |
| === ENUM: lens_catalog.status_lente === | ativo          | 1     |
| === ENUM: lens_catalog.status_lente === | inativo        | 2     |
| === ENUM: lens_catalog.status_lente === | descontinuado  | 3     |
| === ENUM: lens_catalog.status_lente === | em_falta       | 4     |


-- 7. LISTAR TODOS OS ENUMS DO SCHEMA lens_catalog
SELECT 
  '=== TODOS OS ENUMS DO SCHEMA lens_catalog ===' as info,
  t.typname as enum_name,
  STRING_AGG(e.enumlabel, ', ' ORDER BY e.enumsortorder) as valores_possiveis
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid  
JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
WHERE n.nspname = 'lens_catalog'
GROUP BY t.typname
ORDER BY t.typname;

| info                                          | enum_name       | valores_possiveis                                        |
| --------------------------------------------- | --------------- | -------------------------------------------------------- |
| === TODOS OS ENUMS DO SCHEMA lens_catalog === | categoria_lente | economica, intermediaria, premium, super_premium         |
| === TODOS OS ENUMS DO SCHEMA lens_catalog === | indice_refracao | 1.50, 1.56, 1.59, 1.61, 1.67, 1.74, 1.90                 |
| === TODOS OS ENUMS DO SCHEMA lens_catalog === | material_lente  | CR39, POLICARBONATO, TRIVEX, HIGH_INDEX, VIDRO, ACRILICO |
| === TODOS OS ENUMS DO SCHEMA lens_catalog === | status_lente    | ativo, inativo, descontinuado, em_falta                  |
| === TODOS OS ENUMS DO SCHEMA lens_catalog === | tipo_lente      | visao_simples, multifocal, bifocal, leitura, ocupacional |
| === TODOS OS ENUMS DO SCHEMA lens_catalog === | tratamento_foto | nenhum, transitions, fotocromático, polarizado           |

