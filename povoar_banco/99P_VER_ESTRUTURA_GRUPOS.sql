-- Ver estrutura da tabela grupos_canonicos
SELECT 
  column_name,
  data_type,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'lens_catalog'
  AND table_name = 'grupos_canonicos'
ORDER BY ordinal_position;


| column_name               | data_type                | column_default                         | is_nullable |
| ------------------------- | ------------------------ | -------------------------------------- | ----------- |
| id                        | uuid                     | gen_random_uuid()                      | NO          |
| nome_grupo                | text                     | null                                   | NO          |
| slug                      | text                     | null                                   | NO          |
| tipo_lente                | USER-DEFINED             | null                                   | NO          |
| material                  | USER-DEFINED             | null                                   | NO          |
| indice_refracao           | USER-DEFINED             | null                                   | NO          |
| categoria_predominante    | USER-DEFINED             | null                                   | YES         |
| tem_antirreflexo          | boolean                  | false                                  | NO          |
| tem_antirrisco            | boolean                  | false                                  | NO          |
| tem_uv                    | boolean                  | false                                  | NO          |
| tem_blue_light            | boolean                  | false                                  | NO          |
| tratamento_foto           | USER-DEFINED             | 'nenhum'::lens_catalog.tratamento_foto | YES         |
| total_lentes              | integer                  | 0                                      | YES         |
| preco_medio               | numeric                  | null                                   | YES         |
| preco_minimo              | numeric                  | null                                   | YES         |
| preco_maximo              | numeric                  | null                                   | YES         |
| is_premium                | boolean                  | false                                  | NO          |
| peso                      | integer                  | 50                                     | YES         |
| ativo                     | boolean                  | true                                   | NO          |
| created_at                | timestamp with time zone | now()                                  | NO          |
| updated_at                | timestamp with time zone | now()                                  | NO          |
| grau_esferico_min         | numeric                  | null                                   | YES         |
| grau_esferico_max         | numeric                  | null                                   | YES         |
| grau_cilindrico_min       | numeric                  | null                                   | YES         |
| grau_cilindrico_max       | numeric                  | null                                   | YES         |
| adicao_min                | numeric                  | null                                   | YES         |
| adicao_max                | numeric                  | null                                   | YES         |
| descricao_ranges          | text                     | null                                   | YES         |
| total_marcas              | integer                  | 0                                      | YES         |
| tratamento_antirreflexo   | boolean                  | false                                  | YES         |
| tratamento_antirrisco     | boolean                  | false                                  | YES         |
| tratamento_uv             | boolean                  | false                                  | YES         |
| tratamento_blue_light     | boolean                  | false                                  | YES         |
| tratamento_fotossensiveis | text                     | null                                   | YES         |



-- Ver triggers na tabela grupos_canonicos
SELECT 
  tgname as trigger_name,
  proname as function_name,
  CASE 
    WHEN tgtype & 2 = 2 THEN 'BEFORE'
    ELSE 'AFTER'
  END as timing
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE n.nspname = 'lens_catalog'
  AND c.relname = 'grupos_canonicos'
  AND NOT t.tgisinternal;


| trigger_name          | function_name           | timing |
| --------------------- | ----------------------- | ------ |
| trg_grupos_auditoria  | fn_auditar_grupos       | AFTER  |
| trg_grupos_updated_at | update_grupos_timestamp | BEFORE |
