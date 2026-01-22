-- Verificar se há grupos com ativo=false que estão causando conflito
SELECT 
  'Grupos ATIVOS' as tipo,
  COUNT(*) as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true

UNION ALL

SELECT 
  'Grupos INATIVOS' as tipo,
  COUNT(*) as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = false OR ativo IS NULL

UNION ALL

SELECT 
  'Grupos TOTAL' as tipo,
  COUNT(*) as total
FROM lens_catalog.grupos_canonicos;


| tipo            | total |
| --------------- | ----- |
| Grupos ATIVOS   | 0     |
| Grupos INATIVOS | 8     |
| Grupos TOTAL    | 8     |



-- Ver grupos inativos se existirem
SELECT 
  id,
  nome_grupo,
  ativo,
  created_at
FROM lens_catalog.grupos_canonicos
WHERE ativo = false OR ativo IS NULL
ORDER BY created_at DESC
LIMIT 10;


| id                                   | nome_grupo                                                                                 | ativo | created_at                   |
| ------------------------------------ | ------------------------------------------------------------------------------------------ | ----- | ---------------------------- |
| 25c4c6c4-db61-4a27-aa32-0fafabf0998c | Lente CR39 1.74 Visao simples +AR +UV +BlueLight [-12.00/-2.00 | -2.00/0.00]               | false | 2026-01-22 16:11:27.69976+00 |
| 6d2d1d98-ad3f-4312-b589-7534713a9a8e | Lente CR39 1.56 Visao simples +UV +BlueLight [-4.00/4.00 | -4.00/-2.25]                    | false | 2026-01-22 16:11:27.69976+00 |
| 08c1d077-db90-43a4-8dbb-a914f1852500 | Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00]                               | false | 2026-01-22 16:11:27.69976+00 |
| 59bbd61d-6050-4f28-8989-b48bc358022e | Lente POLICARBONATO 1.59 Visao simples +UV [-7.00/6.00 | -4.00/0.00]                       | false | 2026-01-22 16:11:27.69976+00 |
| 2e210f11-a1bb-4184-a6b7-7a19f985a370 | Lente CR39 1.50 Multifocal +UV +Fotocromático [-5.00/5.00 | -4.00/0.00]                    | false | 2026-01-22 16:11:27.69976+00 |
| 37c32db1-b7be-425b-8ce0-6965a160b76c | Lente CR39 1.50 Visao simples +AR +UV +BlueLight [-12.00/-3.00 | -2.00/0.00]               | false | 2026-01-22 16:11:27.69976+00 |
| 5ab562d2-f72e-4ddd-915c-cb8544038fbf | Lente CR39 1.56 Visao simples +AR +UV +BlueLight +Fotocromático [-4.00/4.00 | -4.00/-2.25] | false | 2026-01-22 16:11:27.69976+00 |
| 2e96f376-49d9-4a8d-9879-bf9f8aae9fdc | Lente POLICARBONATO 1.59 Visao simples +AR +UV [-6.00/6.00 | -4.00/-2.25]                  | false | 2026-01-22 16:11:27.69976+00 |



-- Ver as 10 lentes que foram "associadas" a que grupo?
SELECT 
  l.id,
  l.grupo_canonico_id,
  gc.nome_grupo,
  gc.ativo as grupo_ativo
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.grupos_canonicos gc ON l.grupo_canonico_id = gc.id
WHERE l.ativo = true
  AND l.grupo_canonico_id IS NOT NULL
LIMIT 10;


| id                                   | grupo_canonico_id                    | nome_grupo                                                                                 | grupo_ativo |
| ------------------------------------ | ------------------------------------ | ------------------------------------------------------------------------------------------ | ----------- |
| b878d51f-c014-4be5-b54e-1cee30c5e476 | 25c4c6c4-db61-4a27-aa32-0fafabf0998c | Lente CR39 1.74 Visao simples +AR +UV +BlueLight [-12.00/-2.00 | -2.00/0.00]               | false       |
| c91e50dc-1fc8-46f6-8640-6e7b17f1334b | 6d2d1d98-ad3f-4312-b589-7534713a9a8e | Lente CR39 1.56 Visao simples +UV +BlueLight [-4.00/4.00 | -4.00/-2.25]                    | false       |
| 5f0a3d96-6536-4989-94d9-05a13dd4ea8b | 08c1d077-db90-43a4-8dbb-a914f1852500 | Lente CR39 1.50 Multifocal +AR +UV [-8.00/6.50 | -6.00/0.00]                               | false       |
| cc4092d5-0f2a-4985-adaa-82a99502a42a | 59bbd61d-6050-4f28-8989-b48bc358022e | Lente POLICARBONATO 1.59 Visao simples +UV [-7.00/6.00 | -4.00/0.00]                       | false       |
| 4dafa827-5ac3-475d-9881-2ea0eb8b79cb | 2e210f11-a1bb-4184-a6b7-7a19f985a370 | Lente CR39 1.50 Multifocal +UV +Fotocromático [-5.00/5.00 | -4.00/0.00]                    | false       |
| 23a2270f-a46e-48ef-a1c5-f5ad722fb8f8 | 37c32db1-b7be-425b-8ce0-6965a160b76c | Lente CR39 1.50 Visao simples +AR +UV +BlueLight [-12.00/-3.00 | -2.00/0.00]               | false       |
| 4432efd0-e7d9-416c-a714-b8e57c93a954 | 5ab562d2-f72e-4ddd-915c-cb8544038fbf | Lente CR39 1.56 Visao simples +AR +UV +BlueLight +Fotocromático [-4.00/4.00 | -4.00/-2.25] | false       |
| d2bd6f94-6b9e-482b-befe-c6b9e353fe4a | 5ab562d2-f72e-4ddd-915c-cb8544038fbf | Lente CR39 1.56 Visao simples +AR +UV +BlueLight +Fotocromático [-4.00/4.00 | -4.00/-2.25] | false       |
| a869383a-27e7-45f8-b209-ecedbfd8cecb | 5ab562d2-f72e-4ddd-915c-cb8544038fbf | Lente CR39 1.56 Visao simples +AR +UV +BlueLight +Fotocromático [-4.00/4.00 | -4.00/-2.25] | false       |
| 060803e2-c307-4553-8323-d2c59bd9e50f | 2e96f376-49d9-4a8d-9879-bf9f8aae9fdc | Lente POLICARBONATO 1.59 Visao simples +AR +UV [-6.00/6.00 | -4.00/-2.25]                  | false       |

