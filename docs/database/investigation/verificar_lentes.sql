-- ============================================
-- INVESTIGAÇÃO: Estrutura da tabela lens_catalog.lentes
-- ============================================

-- Verificar todas as colunas da tabela lentes
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'lens_catalog'
    AND table_name = 'lentes'
ORDER BY ordinal_position;

| column_name         | data_type                | is_nullable | column_default           |
| ------------------- | ------------------------ | ----------- | ------------------------ |
| id                  | uuid                     | NO          | uuid_generate_v4()       |
| tenant_id           | uuid                     | NO          | null                     |
| sku_canonico        | text                     | NO          | null                     |
| marca_id            | uuid                     | NO          | null                     |
| familia             | text                     | NO          | null                     |
| design              | text                     | NO          | null                     |
| material            | USER-DEFINED             | NO          | null                     |
| indice_refracao     | numeric                  | NO          | null                     |
| tratamentos         | ARRAY                    | YES         | '{}'::tratamento_lente[] |
| tipo_lente          | USER-DEFINED             | NO          | null                     |
| corredor_progressao | integer                  | YES         | null                     |
| specs_tecnicas      | jsonb                    | YES         | '{}'::jsonb              |
| ativo               | boolean                  | NO          | true                     |
| criado_em           | timestamp with time zone | NO          | now()                    |
| atualizado_em       | timestamp with time zone | NO          | now()                    |



-- Verificar alguns registros de exemplo
SELECT *
FROM lens_catalog.lentes
LIMIT 3;

| id                                   | tenant_id                            | sku_canonico        | marca_id                             | familia     | design          | material      | indice_refracao | tratamentos | tipo_lente  | corredor_progressao | specs_tecnicas                                                                                                                                                                                                | ativo | criado_em                     | atualizado_em                 |
| ------------------------------------ | ------------------------------------ | ------------------- | ------------------------------------ | ----------- | --------------- | ------------- | --------------- | ----------- | ----------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- | ----------------------------- | ----------------------------- |
| d8549ee5-8805-4ce6-8c07-603318c023fc | 229220bb-d480-4608-a07c-ae9ab5266caf | LENS-0001-MLTVNQQXA | a7656b0c-88fb-4aa8-a3ed-a7de84598492 | STANDARD    | CLASSIC         | POLICARBONATO | 1.59            | null        | MONOFOCAL   | null                | {"adicao_max":null,"adicao_min":null,"esferico_max":6,"esferico_min":-6,"cilindrico_max":0,"cilindrico_min":-2,"classificacao_fiscal":"90015010"}                                                             | true  | 2025-12-16 15:36:57.475207+00 | 2025-12-16 15:36:57.47523+00  |
| 0f66bda4-0571-41db-a5ca-4ca29955fd13 | 229220bb-d480-4608-a07c-ae9ab5266caf | LENS-0002-MLTCGPH0X | a7656b0c-88fb-4aa8-a3ed-a7de84598492 | FREEVIEW    | HIGH_DEFINITION | ORGANICO      | 1.50            | null        | PROGRESSIVA | 14                  | {"diametro1":"70","diametro2":"0","adicao_max":0,"adicao_min":0,"altura_max":0,"altura_min":18,"esferico_max":9,"esferico_min":-13,"cilindrico_max":0,"cilindrico_min":-6,"classificacao_fiscal":"90016046"}  | true  | 2025-12-16 15:36:57.475295+00 | 2025-12-16 15:36:57.475298+00 |
| 8f2dfc1a-a694-4e4b-80fd-a8c40a33840f | 229220bb-d480-4608-a07c-ae9ab5266caf | LENS-0003-MLTZ4C3S3 | a1b9169c-1af2-4a36-8451-de372dc67003 | SYGMA PRIME | PRIME           | ORGANICO      | 1.67            | null        | PROGRESSIVA | 14                  | {"diametro1":"75","diametro2":"0","adicao_max":3,"adicao_min":1,"altura_max":18,"altura_min":16,"esferico_max":9,"esferico_min":-12,"cilindrico_max":-6,"cilindrico_min":0,"classificacao_fiscal":"90015010"} | true  | 2025-12-16 15:36:57.475349+00 | 2025-12-16 15:36:57.475351+00 |


