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

| column_name            | data_type                | udt_name        | character_maximum_length | numeric_precision | is_nullable |
| ---------------------- | ------------------------ | --------------- | ------------------------ | ----------------- | ----------- |
| id                     | uuid                     | uuid            | null                     | null              | YES         |
| marca_id               | uuid                     | uuid            | null                     | null              | YES         |
| fornecedor_id          | uuid                     | uuid            | null                     | null              | YES         |
| lente_canonica_id      | uuid                     | uuid            | null                     | null              | YES         |
| premium_canonica_id    | uuid                     | uuid            | null                     | null              | YES         |
| sku_fornecedor         | character varying        | varchar         | null                     | null              | YES         |
| codigo_original        | character varying        | varchar         | null                     | null              | YES         |
| nome_comercial         | text                     | text            | null                     | null              | YES         |
| marca_nome             | character varying        | varchar         | 100                      | null              | YES         |
| marca_slug             | character varying        | varchar         | 100                      | null              | YES         |
| marca_premium          | boolean                  | bool            | null                     | null              | YES         |
| tipo_lente             | USER-DEFINED             | tipo_lente      | null                     | null              | YES         |
| categoria              | USER-DEFINED             | categoria_lente | null                     | null              | YES         |
| material               | USER-DEFINED             | material_lente  | null                     | null              | YES         |
| indice_refracao        | USER-DEFINED             | indice_refracao | null                     | null              | YES         |
| linha_produto          | character varying        | varchar         | null                     | null              | YES         |
| diametro               | integer                  | int4            | null                     | 32                | YES         |
| espessura_central      | numeric                  | numeric         | null                     | null              | YES         |
| peso_aproximado        | numeric                  | numeric         | null                     | null              | YES         |
| esferico_min           | numeric                  | numeric         | null                     | 4                 | YES         |
| esferico_max           | numeric                  | numeric         | null                     | 4                 | YES         |
| cilindrico_min         | numeric                  | numeric         | null                     | 4                 | YES         |
| cilindrico_max         | numeric                  | numeric         | null                     | 4                 | YES         |
| adicao_min             | numeric                  | numeric         | null                     | 3                 | YES         |
| adicao_max             | numeric                  | numeric         | null                     | 3                 | YES         |
| dnp_min                | integer                  | int4            | null                     | 32                | YES         |
| dnp_max                | integer                  | int4            | null                     | 32                | YES         |
| ar                     | boolean                  | bool            | null                     | null              | YES         |
| antirrisco             | boolean                  | bool            | null                     | null              | YES         |
| hidrofobico            | boolean                  | bool            | null                     | null              | YES         |
| antiembaçante          | boolean                  | bool            | null                     | null              | YES         |
| blue                   | boolean                  | bool            | null                     | null              | YES         |
| uv400                  | boolean                  | bool            | null                     | null              | YES         |
| fotossensivel          | text                     | text            | null                     | null              | YES         |
| polarizado             | boolean                  | bool            | null                     | null              | YES         |
| digital                | boolean                  | bool            | null                     | null              | YES         |
| free_form              | boolean                  | bool            | null                     | null              | YES         |
| indoor                 | boolean                  | bool            | null                     | null              | YES         |
| drive                  | boolean                  | bool            | null                     | null              | YES         |
| custo_base             | numeric                  | numeric         | null                     | 10                | YES         |
| preco_fabricante       | numeric                  | numeric         | null                     | 10                | YES         |
| preco_tabela           | numeric                  | numeric         | null                     | 10                | YES         |
| prazo_entrega          | integer                  | int4            | null                     | 32                | YES         |
| obs_prazo              | text                     | text            | null                     | null              | YES         |
| peso_frete             | numeric                  | numeric         | null                     | null              | YES         |
| exige_receita_especial | boolean                  | bool            | null                     | null              | YES         |
| descricao_curta        | text                     | text            | null                     | null              | YES         |
| descricao_completa     | text                     | text            | null                     | null              | YES         |
| beneficios             | ARRAY                    | _text           | null                     | null              | YES         |
| indicacoes             | ARRAY                    | _text           | null                     | null              | YES         |
| contraindicacoes       | text                     | text            | null                     | null              | YES         |
| observacoes            | text                     | text            | null                     | null              | YES         |
| status                 | USER-DEFINED             | status_lente    | null                     | null              | YES         |
| disponivel             | boolean                  | bool            | null                     | null              | YES         |
| destaque               | boolean                  | bool            | null                     | null              | YES         |
| novidade               | boolean                  | bool            | null                     | null              | YES         |
| data_lancamento        | date                     | date            | null                     | null              | YES         |
| data_descontinuacao    | date                     | date            | null                     | null              | YES         |
| created_at             | timestamp with time zone | timestamptz     | null                     | null              | YES         |
| updated_at             | timestamp with time zone | timestamptz     | null                     | null              | YES         |



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


| id                                   | nome_comercial | tipo_lente    | categoria | material | indice_refracao | preco_tabela | marca_nome | marca_premium | ar    | blue  | fotossensivel | uv400 | esferico_min | esferico_max | cilindrico_min | cilindrico_max | adicao_min | adicao_max |
| ------------------------------------ | -------------- | ------------- | --------- | -------- | --------------- | ------------ | ---------- | ------------- | ----- | ----- | ------------- | ----- | ------------ | ------------ | -------------- | -------------- | ---------- | ---------- |
| f8f167ad-34c0-4aa7-9b15-17bc41529157 | null           | visao_simples | economica | CR39     | 1.50            | 0.00         | SO BLOCOS  | false         | false | false | nenhum        | false | null         | null         | null           | null           | 0.00       | 0.00       |
| fa5e2bf2-3928-4187-ba2b-0d2e122d3026 | null           | visao_simples | economica | CR39     | 1.50            | 0.00         | SO BLOCOS  | false         | false | false | nenhum        | false | null         | null         | null           | null           | 0.00       | 0.00       |
| f66fccfe-47af-451d-92cc-7e6619277ad2 | null           | visao_simples | economica | CR39     | 1.50            | 0.00         | SO BLOCOS  | false         | false | false | nenhum        | false | null         | null         | null           | null           | 0.50       | 4.50       |



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


| enum_name       | enum_value    | sort_order |
| --------------- | ------------- | ---------- |
| categoria_lente | economica     | 1          |
| categoria_lente | intermediaria | 2          |
| categoria_lente | premium       | 3          |
| categoria_lente | super_premium | 4          |
| indice_refracao | 1.50          | 1          |
| indice_refracao | 1.56          | 2          |
| indice_refracao | 1.59          | 3          |
| indice_refracao | 1.61          | 4          |
| indice_refracao | 1.67          | 5          |
| indice_refracao | 1.74          | 6          |
| indice_refracao | 1.90          | 7          |
| material_lente  | CR39          | 1          |
| material_lente  | POLICARBONATO | 2          |
| material_lente  | TRIVEX        | 3          |
| material_lente  | HIGH_INDEX    | 4          |
| material_lente  | VIDRO         | 5          |
| material_lente  | ACRILICO      | 6          |
| tipo_lente      | visao_simples | 1          |
| tipo_lente      | multifocal    | 2          |
| tipo_lente      | bifocal       | 3          |
| tipo_lente      | leitura       | 4          |
| tipo_lente      | ocupacional   | 5          |
| tratamento_foto | nenhum        | 1          |
| tratamento_foto | transitions   | 2          |
| tratamento_foto | fotocromático | 3          |
| tratamento_foto | polarizado    | 4          |


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

Success. No rows returned





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


| column_name | data_type         | udt_name | character_maximum_length |
| ----------- | ----------------- | -------- | ------------------------ |
| nome        | character varying | varchar  | 100                      |