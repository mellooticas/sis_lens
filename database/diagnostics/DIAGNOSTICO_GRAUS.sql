-- ============================================================================
-- DIAGNÓSTICO: Campos de Grau do Banco
-- ============================================================================
-- Data: 2026-01-21
-- Objetivo: Verificar a estrutura e dados dos campos de grau nas lentes
-- ============================================================================

-- 1. ESTRUTURA DOS CAMPOS DE GRAU
-- ============================================================================
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'lens_catalog' 
  AND table_name = 'lentes'
  AND column_name LIKE '%grau%'
  OR column_name LIKE '%esferico%'
  OR column_name LIKE '%cilindrico%'
  OR column_name LIKE '%adicao%'
ORDER BY ordinal_position;

| column_name         | data_type | is_nullable | column_default |
| ------------------- | --------- | ----------- | -------------- |
| grau_esferico_min   | numeric   | YES         | null           |
| grau_esferico_min   | numeric   | YES         | null           |
| grau_esferico_max   | numeric   | YES         | null           |
| grau_esferico_max   | numeric   | YES         | null           |
| grau_cilindrico_min | numeric   | YES         | null           |
| grau_esferico_min   | numeric   | YES         | null           |
| grau_cilindrico_min | numeric   | YES         | null           |
| grau_cilindrico_max | numeric   | YES         | null           |
| grau_cilindrico_max | numeric   | YES         | null           |
| grau_esferico_max   | numeric   | YES         | null           |
| grau_cilindrico_min | numeric   | YES         | null           |
| adicao_min          | numeric   | YES         | null           |
| adicao_min          | numeric   | YES         | null           |
| adicao_max          | numeric   | YES         | null           |
| adicao_max          | numeric   | YES         | null           |
| grau_cilindrico_max | numeric   | YES         | null           |
| adicao_min          | numeric   | YES         | null           |
| adicao_max          | numeric   | YES         | null           |
| esferico_min        | numeric   | YES         | null           |
| esferico_min        | numeric   | YES         | null           |
| esferico_max        | numeric   | YES         | null           |
| esferico_max        | numeric   | YES         | null           |
| esferico_min        | text      | YES         | null           |
| esferico_steps      | numeric   | YES         | 0.25           |
| esferico_steps      | numeric   | YES         | null           |
| esferico_max        | text      | YES         | null           |
| cilindrico_min      | numeric   | YES         | null           |
| cilindrico_min      | numeric   | YES         | null           |
| cilindrico_min      | text      | YES         | null           |
| esferico_min        | numeric   | YES         | null           |
| cilindrico_max      | numeric   | YES         | null           |
| cilindrico_max      | numeric   | YES         | null           |
| cilindrico_max      | text      | YES         | null           |
| esferico_max        | numeric   | YES         | null           |
| adicao_min          | text      | YES         | null           |
| cilindrico_steps    | numeric   | YES         | 0.25           |
| cilindrico_min      | numeric   | YES         | 0.00           |
| adicao_disponivel   | ARRAY     | YES         | null           |
| adicao_max          | text      | YES         | null           |
| adicao_disponivel   | ARRAY     | YES         | null           |
| cilindrico_max      | numeric   | YES         | 0.00           |
| esferico_min        | numeric   | YES         | null           |
| amplitude_esferico  | text      | YES         | null           |
| esferico_max        | numeric   | YES         | null           |
| grau_esferico_min   | numeric   | YES         | null           |
| cilindrico_min      | numeric   | YES         | null           |
| cilindrico_max      | numeric   | YES         | null           |
| adicao_min          | numeric   | YES         | 0.00           |
| grau_esferico_max   | numeric   | YES         | null           |
| grau_esferico_min   | numeric   | YES         | null           |
| adicao_min          | numeric   | YES         | null           |
| grau_cilindrico_min | numeric   | YES         | null           |
| grau_esferico_max   | numeric   | YES         | null           |
| adicao_max          | numeric   | YES         | 0.00           |
| adicao_max          | numeric   | YES         | null           |
| grau_cilindrico_max | numeric   | YES         | null           |
| grau_cilindrico_min | numeric   | YES         | null           |
| grau_cilindrico_max | numeric   | YES         | null           |
| adicao_min          | numeric   | YES         | null           |
| grau_esferico_min   | numeric   | YES         | null           |
| adicao_max          | numeric   | YES         | null           |
| adicao_min          | numeric   | YES         | null           |
| adicao_max          | numeric   | YES         | null           |
| grau_esferico_max   | numeric   | YES         | null           |
| grau_cilindrico_min | numeric   | YES         | null           |
| grau_cilindrico_max | numeric   | YES         | null           |
| adicao_min          | numeric   | YES         | null           |
| adicao_max          | numeric   | YES         | null           |
| esferico_min        | numeric   | YES         | null           |
| esferico_max        | numeric   | YES         | null           |
| cilindrico_min      | numeric   | YES         | null           |
| cilindrico_max      | numeric   | YES         | null           |



-- 2. AMOSTRA DE DADOS - GRAUS EM LENTES
-- ============================================================================
SELECT 
    id,
    nome_comercial,
    familia,
    design,
    grau_esferico_min,
    grau_esferico_max,
    grau_cilindrico_min,
    grau_cilindrico_max,
    adicao_min,
    adicao_max,
    exige_receita_especial,
    ativo
FROM lens_catalog.lentes
WHERE ativo = true
LIMIT 10;

-- 3. DISTRIBUIÇÃO DE LENTES POR DISPONIBILIDADE DE GRAUS
-- ============================================================================
SELECT 
    COUNT(*) AS total_lentes,
    COUNT(CASE WHEN grau_esferico_min IS NOT NULL THEN 1 END) AS com_grau_esferico,
    COUNT(CASE WHEN grau_cilindrico_min IS NOT NULL THEN 1 END) AS com_grau_cilindrico,
    COUNT(CASE WHEN adicao_min IS NOT NULL THEN 1 END) AS com_adicao,
    COUNT(CASE WHEN exige_receita_especial = true THEN 1 END) AS exigem_receita_especial
FROM lens_catalog.lentes
WHERE ativo = true;

| total_lentes | com_grau_esferico | com_grau_cilindrico | com_adicao | exigem_receita_especial |
| ------------ | ----------------- | ------------------- | ---------- | ----------------------- |
| 1411         | 1411              | 1411                | 1308       | 0                       |



-- 4. FAIXAS DE GRAU DISPONÍVEIS NO CATÁLOGO
-- ============================================================================
SELECT 
    'Esfera' AS tipo_grau,
    ROUND(MIN(grau_esferico_min)::NUMERIC, 2) AS minimo,
    ROUND(MAX(grau_esferico_max)::NUMERIC, 2) AS maximo,
    COUNT(*) AS total_lentes
FROM lens_catalog.lentes
WHERE ativo = true AND grau_esferico_min IS NOT NULL
UNION ALL
SELECT 
    'Cilindro',
    ROUND(MIN(grau_cilindrico_min)::NUMERIC, 2),
    ROUND(MAX(grau_cilindrico_max)::NUMERIC, 2),
    COUNT(*)
FROM lens_catalog.lentes
WHERE ativo = true AND grau_cilindrico_min IS NOT NULL
UNION ALL
SELECT 
    'Adição',
    ROUND(MIN(adicao_min)::NUMERIC, 2),
    ROUND(MAX(adicao_max)::NUMERIC, 2),
    COUNT(*)
FROM lens_catalog.lentes
WHERE ativo = true AND adicao_min IS NOT NULL
ORDER BY tipo_grau;

| tipo_grau | minimo | maximo | total_lentes |
| --------- | ------ | ------ | ------------ |
| Adição    | 0.00   | 4.50   | 1308         |
| Cilindro  | -8.00  | 4.00   | 1411         |
| Esfera    | -24.00 | 12.00  | 1411         |



-- 5. LENTES SEM INFORMAÇÃO DE GRAU
-- ============================================================================
SELECT 
    id,
    nome_comercial,
    familia,
    tipo_lente,
    grau_esferico_min,
    grau_cilindrico_min,
    adicao_min,
    exige_receita_especial
FROM lens_catalog.lentes
WHERE ativo = true
  AND (
      grau_esferico_min IS NULL
      OR grau_cilindrico_min IS NULL
      OR adicao_min IS NULL
  )
ORDER BY nome_comercial
LIMIT 20;

-- 6. ESTATÍSTICAS POR TIPO DE LENTE
-- ============================================================================
SELECT 
    tipo_lente,
    COUNT(*) AS total,
    COUNT(CASE WHEN grau_esferico_min IS NOT NULL THEN 1 END) AS com_esfera,
    COUNT(CASE WHEN grau_cilindrico_min IS NOT NULL THEN 1 END) AS com_cilindro,
    COUNT(CASE WHEN adicao_min IS NOT NULL THEN 1 END) AS com_adicao,
    ROUND(AVG(CAST(exige_receita_especial AS INT))::NUMERIC, 2) AS percentual_exige_receita
FROM lens_catalog.lentes
WHERE ativo = true
GROUP BY tipo_lente
ORDER BY total DESC;

| tipo_lente    | total | com_esfera | com_cilindro | com_adicao | percentual_exige_receita |
| ------------- | ----- | ---------- | ------------ | ---------- | ------------------------ |
| multifocal    | 957   | 957        | 957          | 957        | 0.00                     |
| visao_simples | 452   | 452        | 452          | 349        | 0.00                     |
| bifocal       | 2     | 2          | 2            | 2          | 0.00                     |



-- 7. VALIDAÇÃO - Verificar inconsistências nos graus
-- ============================================================================
SELECT 
    id,
    nome_comercial,
    CASE 
        WHEN grau_esferico_min > grau_esferico_max THEN 'ERRO: Esfera min > max'
        WHEN grau_cilindrico_min > grau_cilindrico_max THEN 'ERRO: Cilindro min > max'
        WHEN adicao_min > adicao_max THEN 'ERRO: Adição min > max'
        WHEN grau_esferico_min IS NOT NULL AND grau_esferico_min > 0 THEN 'AVISO: Esfera positiva?'
        ELSE 'OK'
    END AS validacao
FROM lens_catalog.lentes
WHERE ativo = true
  AND (
      grau_esferico_min > grau_esferico_max
      OR grau_cilindrico_min > grau_cilindrico_max
      OR adicao_min > adicao_max
      OR (grau_esferico_min IS NOT NULL AND grau_esferico_min > 0)
  )
ORDER BY nome_comercial;

| id                                   | nome_comercial | validacao                |
| ------------------------------------ | -------------- | ------------------------ |
| 59828728-37d1-4c3b-9780-a2fce84a0b34 | null           | ERRO: Cilindro min > max |
| 68f26ff7-808e-4ae8-bb91-7808313da3a9 | null           | ERRO: Cilindro min > max |
| ed866791-4a61-4814-a1a7-3bbf0342c714 | null           | ERRO: Cilindro min > max |
| fbec76e1-25c3-4fc0-8400-fa88b27795ec | null           | ERRO: Cilindro min > max |
| 429114d1-311c-48c7-a849-e5e4bb1a133b | null           | ERRO: Cilindro min > max |
| 5536e3e4-393f-4efb-85da-205bcaec96b1 | null           | ERRO: Cilindro min > max |
| 45989268-17ba-4f3a-89d0-8826863feb16 | null           | ERRO: Cilindro min > max |
| abce6a12-ee6e-4474-bb12-b0d78cc8fae7 | null           | ERRO: Cilindro min > max |
| 7a331f60-9d90-4311-9247-bcc5cecd075d | null           | ERRO: Cilindro min > max |
| 6e6d62f1-c198-4e31-82d7-beb24a7f8b07 | null           | ERRO: Cilindro min > max |
| 08272024-ba29-4324-84a0-01cbe3b3f6c1 | null           | ERRO: Cilindro min > max |
| 7808928b-ff6e-4f56-b6f7-83b288b2e7a3 | null           | ERRO: Cilindro min > max |
| e0e75e90-5973-481d-8bef-af607257365c | null           | ERRO: Cilindro min > max |
| 9b7ef9b1-ad38-49ec-924a-c10c5953c07e | null           | ERRO: Cilindro min > max |
| 04131836-0611-435e-85b0-59666a2538ba | null           | ERRO: Cilindro min > max |
| 211079c9-e317-4c5c-87e0-10b31ae89308 | null           | ERRO: Cilindro min > max |
| b5d609e9-508b-4871-942c-46b0eaeca2aa | null           | ERRO: Cilindro min > max |
| 2c415dd6-fa31-46c8-8630-0e166a92eab9 | null           | ERRO: Cilindro min > max |
| 919b83ab-8d88-4032-ab09-f1f4811be1df | null           | ERRO: Cilindro min > max |
| 655dfc66-3c88-4e4a-9d50-796f7701653d | null           | ERRO: Cilindro min > max |
| b15d87f1-9f2d-41b4-bb35-9e124653ec38 | null           | ERRO: Cilindro min > max |
| 53de5654-8986-4c56-aa7c-4f04d3e5c766 | null           | ERRO: Cilindro min > max |
| c3623f26-7b07-4fc6-b4ba-c05fd16217bf | null           | ERRO: Cilindro min > max |
| da9b128a-e15f-4f80-843e-6f83c7a958e0 | null           | ERRO: Cilindro min > max |
| c3a57bf1-d5a7-4382-a2d4-f88412373d9f | null           | ERRO: Cilindro min > max |
| 48edab4f-f6c0-4038-9db5-322e5cc714b9 | null           | ERRO: Cilindro min > max |
| 0a5dd9c9-4185-4183-b173-c9b14ccf9372 | null           | ERRO: Cilindro min > max |
| f9a1e7e4-3cb1-487e-ba29-dd67e7638f37 | null           | ERRO: Cilindro min > max |
| b1e29c04-b108-4b5b-ab95-4186fd639849 | null           | ERRO: Cilindro min > max |
| e41d8dfd-396e-47c0-b74e-a3d45c7386c7 | null           | ERRO: Cilindro min > max |
| 26ba2feb-8739-4d74-8357-97a17736d07b | null           | ERRO: Cilindro min > max |
| 73a60c66-1bf2-4af6-a4c6-f6c8e505635f | null           | ERRO: Cilindro min > max |
| 7f480276-2b1b-4a9a-8dc2-3c9a5ea78015 | null           | ERRO: Cilindro min > max |
| 92b72555-124e-4320-b270-053f35bd662c | null           | ERRO: Cilindro min > max |
| 3ec4b4c5-a96b-450d-a565-88c5846ed45c | null           | ERRO: Cilindro min > max |
| e24ea22c-90d5-4215-81cc-08d9e5250c52 | null           | ERRO: Cilindro min > max |
| 59f3ddf3-12fb-4b0a-a814-1a08d2cc8add | null           | ERRO: Cilindro min > max |
| 9feb05a9-2f7d-450d-b265-fbeffe0ef6cb | null           | ERRO: Cilindro min > max |
| 5efe3471-b961-45a5-bcb4-f1897788c4ac | null           | ERRO: Cilindro min > max |
| 71da6d60-6957-4cdf-a31d-8cb1819eed09 | null           | ERRO: Cilindro min > max |
| 02766abb-0204-413f-9716-e78f871103f9 | null           | ERRO: Cilindro min > max |
| f0539bb2-a057-44e9-adc0-a7c0193b29e6 | null           | ERRO: Cilindro min > max |
| 951b2024-eedb-4f4d-9740-70bf68988a37 | null           | ERRO: Cilindro min > max |
| 87f464fb-dc2d-4e3f-ada0-c7025d20b9bd | null           | ERRO: Cilindro min > max |
| 93ab93a2-9b1e-4b9b-97f2-3382e9b9e63b | null           | ERRO: Cilindro min > max |
| 58edb8fb-4283-4d84-b7e8-663a3c8a5cc1 | null           | ERRO: Cilindro min > max |
| 1bf9f319-f50c-41d3-93a8-47cc2a243939 | null           | ERRO: Cilindro min > max |
| ce26e038-93da-4b71-8476-7914b67d45ae | null           | ERRO: Cilindro min > max |
| 5b2d1d93-e608-4b12-a322-dd1df3cf2d2f | null           | ERRO: Cilindro min > max |
| db9f4f59-94d1-485e-b407-b282474b673c | null           | ERRO: Cilindro min > max |
| 34e8dfdc-909d-46b2-b946-5e2c4ad736ae | null           | ERRO: Cilindro min > max |
| 52ac31d4-71a8-41d0-8d01-4c7c4bf5de5f | null           | ERRO: Cilindro min > max |
| b2f58d1d-085c-4115-984e-45574b7e988d | null           | ERRO: Cilindro min > max |
| d4093999-48b4-4e89-ae4d-077ac2f66459 | null           | ERRO: Cilindro min > max |
| 21a3a24e-811f-4a8e-bcfc-157aa63ec4bd | null           | ERRO: Cilindro min > max |
| 1752e545-177f-4da1-a83f-4979303650e1 | null           | ERRO: Cilindro min > max |
| 3e77bfdb-f3dc-4fe7-96fa-4fea4f491151 | null           | ERRO: Cilindro min > max |
| 37f084ce-b33a-44fd-8de0-23e48d9d7a87 | null           | ERRO: Cilindro min > max |
| 8f5168f4-1ea3-415c-b0cd-55a9e8fea6f0 | null           | ERRO: Cilindro min > max |
| 649ce378-3a8d-403f-8445-1f01fd9c442e | null           | ERRO: Cilindro min > max |
| a6bc5365-a617-420b-96f4-28a129d9cd62 | null           | ERRO: Cilindro min > max |
| d9713281-9ab4-4184-bdb6-8abe511dff04 | null           | ERRO: Cilindro min > max |
| cdd1de10-92c9-40cf-a57a-3dac21552e52 | null           | ERRO: Cilindro min > max |
| da9c4040-38cf-4681-9f48-2a10334832ed | null           | ERRO: Cilindro min > max |
| 11ef6464-4743-418e-8255-9699a67f4a52 | null           | ERRO: Cilindro min > max |
| 77b302ff-39c3-475f-ba67-76708a865ea3 | null           | ERRO: Cilindro min > max |
| 00b71f1f-3e75-4451-8d99-24a25979042c | null           | ERRO: Cilindro min > max |
| 4ed47993-78ba-4e9e-bb8b-28988d962c66 | null           | ERRO: Cilindro min > max |
| 6d6469f7-f590-4089-86f0-c7d6a1b46221 | null           | ERRO: Cilindro min > max |
| 6037cbcb-733d-49d9-8954-98ed5ef41db2 | null           | ERRO: Cilindro min > max |
| 9565e154-dd53-4d08-b88f-ed8a325d1412 | null           | ERRO: Cilindro min > max |
| 37dd13b3-1614-4d35-9b19-4f61e01acdd5 | null           | ERRO: Cilindro min > max |
| b9068441-9c89-49cd-8e65-6c999a8fb9e8 | null           | ERRO: Cilindro min > max |
| 5cf9ed7c-eb91-4171-9a81-77eb8af72bae | null           | ERRO: Cilindro min > max |
| 4b877386-0b56-43e9-ac46-21b0ae936713 | null           | ERRO: Cilindro min > max |
| 2b7595b0-cd83-4bd9-bfa5-bfdb9388067a | null           | ERRO: Cilindro min > max |
| cf00f02a-17e3-4acb-9c3a-1124e35e3dfe | null           | ERRO: Cilindro min > max |
| 7ec07396-da88-4513-8959-a384b9a288c1 | null           | ERRO: Cilindro min > max |
| b2f095d0-8df7-4e55-952f-bfa6a6dbe20a | null           | ERRO: Cilindro min > max |
| 3627fdb1-7441-4ab8-ac66-9ec557237e61 | null           | ERRO: Cilindro min > max |
| da45ded7-ca77-4209-8adb-9f4a0a75af7e | null           | ERRO: Cilindro min > max |
| f13e7133-4a3c-483c-bea0-38c5b306b001 | null           | ERRO: Cilindro min > max |
| c005396c-32d6-4107-8b71-161521e54fd5 | null           | ERRO: Cilindro min > max |
| 1f0115e6-c73a-425b-8ec3-2921f1d971fe | null           | ERRO: Cilindro min > max |
| 1823cfe2-a94e-4895-b8b3-b0d6ac332e5c | null           | ERRO: Cilindro min > max |
| 8ecfd4ea-db3e-4162-aa32-bcdb798c8943 | null           | ERRO: Cilindro min > max |
| d88c19b8-2bab-4273-8fa2-90e4aeaf5229 | null           | ERRO: Cilindro min > max |
| d3799e25-3328-41a0-af34-6709ea7925db | null           | ERRO: Cilindro min > max |
| 0816d3a1-7c6d-4e76-b9ea-77161a94b88b | null           | ERRO: Cilindro min > max |
| b74cd45f-a9d6-42d1-b9a4-d8f6211d0045 | null           | ERRO: Cilindro min > max |
| dcd7ba91-e9a0-45e2-807d-42391b443c6f | null           | ERRO: Cilindro min > max |
| 0f62c057-f771-4127-865b-2c7a793cacf3 | null           | ERRO: Cilindro min > max |
| 367e4045-3337-4938-936e-31dce7009687 | null           | ERRO: Cilindro min > max |
| 467c529c-79d7-4b12-abb9-a588ec129406 | null           | ERRO: Cilindro min > max |
| 00594427-93b0-4842-854c-9171a76ca911 | null           | ERRO: Cilindro min > max |
| 307dcffb-ebd4-4e86-9797-14365fcbfee8 | null           | ERRO: Cilindro min > max |
| af22dfa2-230d-48cc-b663-f9f02ef63b6a | null           | ERRO: Cilindro min > max |
| ec8c7ced-8e16-4046-96ba-92677d080818 | null           | ERRO: Cilindro min > max |
| 4a9aed28-d834-4b31-b29e-c2df7107a4e4 | null           | ERRO: Cilindro min > max |
| ccfea982-2dd0-4912-9c5d-e1058fa932ba | null           | ERRO: Cilindro min > max |
| f18854af-c3c7-4f40-9563-77c0ca7232ca | null           | ERRO: Cilindro min > max |
| 08fa44ef-8d82-4f5b-b6da-b981c533080b | null           | ERRO: Cilindro min > max |
| a1355fc3-1bb4-4236-892a-5200fd0979a1 | null           | ERRO: Cilindro min > max |
| 5bee5b4e-bfc1-48b1-9059-2eb5aa360e70 | null           | ERRO: Cilindro min > max |
| 13e50463-bba2-4163-b242-2d2a1bd067fe | null           | ERRO: Cilindro min > max |
| 42d403f7-f9a3-40f7-9d20-655a8ce0a9bf | null           | ERRO: Cilindro min > max |
| a48b35e1-381d-43b2-a094-614160acaf23 | null           | ERRO: Cilindro min > max |
| 2cc91b1d-fed5-49b2-8a4b-fef24e5d7976 | null           | ERRO: Cilindro min > max |
| 5a464ac2-b4c1-43b4-a19b-f6af81c28230 | null           | ERRO: Cilindro min > max |
| db6b4cf0-033a-4641-82fd-54e6140bd936 | null           | ERRO: Cilindro min > max |
| d8271ad0-32ca-4e3e-b75b-cdf1240908ee | null           | ERRO: Cilindro min > max |
| 56aa9b6d-11bb-41a0-b8af-260b81514c4a | null           | ERRO: Cilindro min > max |
| 1af71fc0-190d-4838-82f9-d63ecbb0ee77 | null           | ERRO: Cilindro min > max |
| 561e46cc-1077-45e8-b8d5-3b4248647d47 | null           | ERRO: Cilindro min > max |
| 8fdd0b09-0588-40b3-af3e-2c0984bff3a3 | null           | ERRO: Cilindro min > max |
| e8357742-4217-4501-b331-6993749739ed | null           | ERRO: Cilindro min > max |
| 5f9beabf-9ff6-45ea-8bab-f57c4d5da7bd | null           | ERRO: Cilindro min > max |
| 610d1d6d-0fc3-4220-b154-d3e366db3c08 | null           | ERRO: Cilindro min > max |
| f46fe989-de7f-44a8-9a22-81520db3f6ae | null           | ERRO: Cilindro min > max |
| 49e84824-e3e1-4790-b637-64caf912b096 | null           | ERRO: Cilindro min > max |
| f29466f5-9830-46c8-8d84-5c402bbb9d6d | null           | ERRO: Cilindro min > max |
| 12a254c1-9f22-462e-92ec-6b3933e04fab | null           | ERRO: Cilindro min > max |
| c3826e40-f1d1-40d6-9e86-9cb4c142c2e9 | null           | ERRO: Cilindro min > max |
| 9e4c4669-cc94-4e93-a101-afa320b88b2f | null           | ERRO: Cilindro min > max |
| 628ca1e3-d3ca-482b-b9bc-2588c7b2ca07 | null           | AVISO: Esfera positiva?  |
| 76c8abda-9cdc-4aa6-8547-c4e61bcc4a6a | null           | AVISO: Esfera positiva?  |
| a73dedb0-8bac-4eff-a3d1-11a5d5d5b872 | null           | ERRO: Cilindro min > max |
| 7c6af4de-04be-41bf-9914-487ddb3bb2e8 | null           | ERRO: Cilindro min > max |
| 177978c4-41a4-4a28-ab8d-d57532e3c97f | null           | ERRO: Cilindro min > max |
| 795691d5-a939-484a-bb5e-20f2e23056d5 | null           | ERRO: Cilindro min > max |
| 74269892-b929-472f-87c6-3a7ffb8c3508 | null           | ERRO: Cilindro min > max |
| 77a12436-1bbf-4ab6-882c-7aea1f2ffa97 | null           | ERRO: Cilindro min > max |
| 183ba2bb-9eb9-48a8-b429-5f10e5a7566f | null           | ERRO: Cilindro min > max |
| e92a3770-d61c-4fad-a5ee-333f6b88c42c | null           | ERRO: Cilindro min > max |
| a4ebdeae-ce65-4cfc-bfef-a7167b10f93c | null           | ERRO: Cilindro min > max |
| 359d8660-432d-41d4-a113-09549ce87d61 | null           | ERRO: Cilindro min > max |
| e59ff4cd-a9ff-479d-87be-6f325a3c5665 | null           | ERRO: Cilindro min > max |



-- 8. RESUMO FINAL
-- ============================================================================
SELECT 
    'Total de lentes ativas' AS metrica,
    COUNT(*)::TEXT AS valor
FROM lens_catalog.lentes
WHERE ativo = true
UNION ALL
SELECT 'Com informação de graus',
    COUNT(*)::TEXT
FROM lens_catalog.lentes
WHERE ativo = true
  AND grau_esferico_min IS NOT NULL
  AND grau_cilindrico_min IS NOT NULL
UNION ALL
SELECT 'Sem informação de graus',
    COUNT(*)::TEXT
FROM lens_catalog.lentes
WHERE ativo = true
  AND (grau_esferico_min IS NULL OR grau_cilindrico_min IS NULL)
UNION ALL
SELECT 'Que exigem receita especial',
    COUNT(*)::TEXT
FROM lens_catalog.lentes
WHERE ativo = true AND exige_receita_especial = true;


| metrica                     | valor |
| --------------------------- | ----- |
| Total de lentes ativas      | 1411  |
| Com informação de graus     | 1411  |
| Sem informação de graus     | 0     |
| Que exigem receita especial | 0     |
