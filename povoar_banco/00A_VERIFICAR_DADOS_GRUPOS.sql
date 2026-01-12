-- ============================================================================
-- VERIFICAÇÃO FINAL: Dados e Permissões
-- Data: 2026-01-11
-- ============================================================================

-- Query 1: Contar grupos standard
SELECT COUNT(*) as total_standard
FROM public.v_grupos_canonicos;

| total_standard |
| -------------- |
| 401            |



-- Query 2: Contar grupos premium  
SELECT COUNT(*) as total_premium
FROM public.v_grupos_premium;

| total_premium |
| ------------- |
| 60            |

-- Query 3: Ver amostra de dados standard (5 registros)
SELECT 
    id,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    preco_medio,
    total_lentes,
    total_marcas
FROM public.v_grupos_canonicos
LIMIT 5;


| id                                   | nome_grupo                                                            | tipo_lente    | material      | indice_refracao | preco_medio | total_lentes | total_marcas |
| ------------------------------------ | --------------------------------------------------------------------- | ------------- | ------------- | --------------- | ----------- | ------------ | ------------ |
| 573729aa-91b7-4f74-b2dc-00e5bcd9ea34 | Lente POLICARBONATO 1.59 Visao Simples +UV [-10.00/6.00 | 0.00/-2.00] | visao_simples | POLICARBONATO | 1.59            | 250.00      | 1            | 1            |
| 30d581c1-4b46-41a8-b4a5-6653c862ec7a | Lente CR39 1.50 Visao Simples +UV [-6.00/6.00 | 0.00/-2.00]           | visao_simples | CR39          | 1.50            | 250.00      | 1            | 1            |
| 62d675b2-e9b2-47d3-b98f-9ff53b26eca7 | Lente CR39 1.56 Visao Simples +AR +UV [-8.00/6.00 | 0.00/-2.00]       | visao_simples | CR39          | 1.56            | 253.91      | 1            | 1            |
| 928ddd31-a900-4340-8d3f-094e68538524 | Lente CR39 1.50 Visao Simples +UV [-6.00/6.00 | -2.00/2.00]           | visao_simples | CR39          | 1.50            | 255.87      | 1            | 1            |
| 14a2d496-3947-4b9e-9ff2-aff781d7cee3 | Lente CR39 1.56 Visao Simples +AR +UV [-8.00/6.00 | -2.00/0.00]       | visao_simples | CR39          | 1.56            | 261.73      | 1            | 1            |

-- Query 4: Verificar permissões da view
SELECT 
    grantee,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name = 'v_grupos_canonicos';


| grantee  | privilege_type |
| -------- | -------------- |
| postgres | INSERT         |
| postgres | SELECT         |
| postgres | UPDATE         |
| postgres | DELETE         |
| postgres | TRUNCATE       |
| postgres | REFERENCES     |
| postgres | TRIGGER        |
| PUBLIC   | SELECT         |

-- Query 5: Ver estrutura completa da tabela grupos_canonicos
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'lens_catalog'
  AND table_name = 'grupos_canonicos'
ORDER BY ordinal_position;

| column_name               | data_type                | is_nullable |
| ------------------------- | ------------------------ | ----------- |
| id                        | uuid                     | NO          |
| nome_grupo                | text                     | NO          |
| slug                      | text                     | NO          |
| tipo_lente                | USER-DEFINED             | NO          |
| material                  | USER-DEFINED             | NO          |
| indice_refracao           | USER-DEFINED             | NO          |
| categoria_predominante    | USER-DEFINED             | YES         |
| tem_antirreflexo          | boolean                  | NO          |
| tem_antirrisco            | boolean                  | NO          |
| tem_uv                    | boolean                  | NO          |
| tem_blue_light            | boolean                  | NO          |
| tratamento_foto           | USER-DEFINED             | YES         |
| total_lentes              | integer                  | YES         |
| preco_medio               | numeric                  | YES         |
| preco_minimo              | numeric                  | YES         |
| preco_maximo              | numeric                  | YES         |
| is_premium                | boolean                  | NO          |
| peso                      | integer                  | YES         |
| ativo                     | boolean                  | NO          |
| created_at                | timestamp with time zone | NO          |
| updated_at                | timestamp with time zone | NO          |
| grau_esferico_min         | numeric                  | YES         |
| grau_esferico_max         | numeric                  | YES         |
| grau_cilindrico_min       | numeric                  | YES         |
| grau_cilindrico_max       | numeric                  | YES         |
| adicao_min                | numeric                  | YES         |
| adicao_max                | numeric                  | YES         |
| descricao_ranges          | text                     | YES         |
| total_marcas              | integer                  | YES         |
| tratamento_antirreflexo   | boolean                  | YES         |
| tratamento_antirrisco     | boolean                  | YES         |
| tratamento_uv             | boolean                  | YES         |
| tratamento_blue_light     | boolean                  | YES         |
| tratamento_fotossensiveis | text                     | YES         |

