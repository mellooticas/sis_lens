-- ============================================================================
-- DIAGNÓSTICO DE SAÚDE DO CATÁLOGO DE LENTES
-- ============================================================================

-- 1. Visão Geral: Quantidade por Fornecedor e Status
SELECT 
    f.nome AS fornecedor,
    COUNT(l.id) AS total_lentes,
    COUNT(DISTINCT l.marca_id) AS total_marcas,
    ROUND(AVG(l.preco_custo), 2) AS preco_custo_medio,
    MIN(l.preco_custo) AS preco_minimo,
    MAX(l.preco_custo) AS preco_maximo
FROM core.fornecedores f
LEFT JOIN lens_catalog.lentes l ON f.id = l.fornecedor_id
GROUP BY f.nome
ORDER BY total_lentes DESC;

| fornecedor                    | total_lentes | total_marcas | preco_custo_medio | preco_minimo | preco_maximo |
| ----------------------------- | ------------ | ------------ | ----------------- | ------------ | ------------ |
| Brascor                       | 2649         | 5            | 903.21            | 3.50         | 5254.00      |
| Polylux                       | 287          | 5            | 229.46            | 10.00        | 1560.00      |
| Style                         | 270          | 5            | 418.61            | 3.50         | 1141.00      |
| Hoya                          | 192          | 1            | 3305.23           | 590.00       | 7115.00      |
| Sygma                         | 141          | 3            | 200.64            | 12.00        | 1600.00      |
| So Blocos                     | 60           | 1            | 112.89            | 12.80        | 380.00       |
| Express                       | 44           | 1            | 251.70            | 13.00        | 750.00       |
| Braslentes                    | 36           | 1            | 47.17             | 9.00         | 230.00       |
| High Vision                   | 19           | 1            | 103.42            | 13.00        | 640.00       |
| Sao Paulo Acessorios          | 0            | 0            | null              | null         | null         |
| Solotica                      | 0            | 0            | null              | null         | null         |
| Kaizi Oculos Solares          | 0            | 0            | null              | null         | null         |
| Bausch & Lomb Brasil          | 0            | 0            | null              | null         | null         |
| CooperVision Brasil           | 0            | 0            | null              | null         | null         |
| Galeria Florencio lj11        | 0            | 0            | null              | null         | null         |
| Johnson & Johnson Vision Care | 0            | 0            | null              | null         | null         |
| Alcon Laboratorios do Brasil  | 0            | 0            | null              | null         | null         |
| Lentenet                      | 0            | 0            | null              | null         | null         |
| Navarro Oculos                | 0            | 0            | null              | null         | null         |
| Newlens                       | 0            | 0            | null              | null         | null         |



-- 2. Alertas de Qualidade (O que deve ser zero)
SELECT 
    'Preço de Custo Zero ou Negativo' AS alerta, COUNT(*) AS total FROM lens_catalog.lentes WHERE preco_custo <= 0
UNION ALL
SELECT 'Lentes sem Índice de Refração', COUNT(*) FROM lens_catalog.lentes WHERE indice_refracao IS NULL
UNION ALL
SELECT 'Lentes sem Material Atribuído', COUNT(*) FROM lens_catalog.lentes WHERE material IS NULL
UNION ALL
SELECT 'Lentes sem Grupo Canônico', COUNT(*) FROM lens_catalog.lentes WHERE grupo_canonico_id IS NULL
UNION ALL
SELECT 'Marcas não identificadas (Geral)', COUNT(*) FROM lens_catalog.lentes WHERE marca_id IS NULL;


| alerta                           | total |
| -------------------------------- | ----- |
| Preço de Custo Zero ou Negativo  | 0     |
| Lentes sem Índice de Refração    | 0     |
| Lentes sem Material Atribuído    | 0     |
| Lentes sem Grupo Canônico        | 0     |
| Marcas não identificadas (Geral) | 0     |



-- 3. Verificação do Sistema de Canonização (Grupos)
SELECT 
    COUNT(*) AS total_grupos_criados,
    MIN(total_lentes) AS min_lentes_por_grupo,
    MAX(total_lentes) AS max_lentes_por_grupo,
    ROUND(AVG(total_lentes), 2) AS media_lentes_por_grupo
FROM lens_catalog.grupos_canonicos;

| total_grupos_criados | min_lentes_por_grupo | max_lentes_por_grupo | media_lentes_por_grupo |
| -------------------- | -------------------- | -------------------- | ---------------------- |
| 1004                 | 0                    | 209                  | 2.99                   |


-- 4. Top 10 Grupos mais "Populosos" (Ver se o agrupamento faz sentido)
SELECT 
    nome_grupo,
    total_lentes,
    preco_minimo,
    preco_maximo
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
ORDER BY total_lentes DESC
LIMIT 10;

| nome_grupo                                                                 | total_lentes | preco_minimo | preco_maximo |
| -------------------------------------------------------------------------- | ------------ | ------------ | ------------ |
| Lente CR39 1.50 Multifocal [-4.00/4.00 | -4.00/0.00]                       | 209          | 396.00       | 3496.00      |
| Lente CR39 1.50 Multifocal [-6.00/6.00 | -4.00/0.00]                       | 167          | 316.00       | 3532.00      |
| Lente HIGH_INDEX 1.67 Multifocal [-8.00/9.00 | -6.00/0.00]                 | 157          | 1316.00      | 8120.00      |
| Lente CR39 1.56 Multifocal [-6.00/6.00 | -4.00/0.00]                       | 144          | 592.00       | 2320.00      |
| Lente POLICARBONATO 1.59 Multifocal [-6.00/7.00 | -5.00/0.00]              | 126          | 736.00       | 3960.00      |
| Lente POLICARBONATO 1.59 Visao simples [PREMIUM] [-10.00/6.00 | 0.00/0.00] | 73           | 1684.00      | 7912.00      |
| Lente CR39 1.50 Visao simples [PREMIUM] [-10.00/6.00 | 0.00/0.00]          | 63           | 1684.00      | 5576.00      |
| Lente CR39 1.56 Multifocal [PREMIUM] [-10.00/6.00 | 0.00/0.00]             | 59           | 5968.00      | 14132.00     |
| Lente POLICARBONATO 1.59 Multifocal [PREMIUM] [-10.00/6.00 | 0.00/0.00]    | 59           | 6468.00      | 14628.00     |
| Lente POLICARBONATO 1.59 Multifocal [-7.00/8.00 | -5.00/0.00]              | 48           | 940.00       | 2520.00      |



-- ... (queries anteriores mantidas) ...

-- ============================================================================
-- 6. INVESTIGAÇÃO PROFUNDA: INTEGRIDADE DE CAMPOS PARA CANONIZAÇÃO
-- ============================================================================
-- Objetivo: Verificar se existem campos "críticos" que afetam o agrupamento
-- que ainda estão com valores padrão ou suspeitos.

SELECT 
    'Grupos com Nome NULL (ERRO CRÍTICO)' AS teste, COUNT(*) AS total FROM lens_catalog.grupos_canonicos WHERE nome_grupo IS NULL
UNION ALL
SELECT 'Lentes com Esférico/Cilindrico EXATAMENTE 0.00 (Suspeito se em massa)', COUNT(*) FROM lens_catalog.lentes WHERE esferico_min = 0 AND esferico_max = 0 AND cilindrico_min = 0
UNION ALL
SELECT 'Lentes Brascor com nome genérico "Lente Brascor"', COUNT(*) FROM lens_catalog.lentes WHERE nome_lente LIKE 'Lente Brascor%'
UNION ALL
SELECT 'Lentes sem Preço de Venda Sugerido', COUNT(*) FROM lens_catalog.lentes WHERE preco_venda_sugerido <= 0
UNION ALL
SELECT 'Lentes com Adição Zerada em Multifocais/Bifocais', COUNT(*) FROM lens_catalog.lentes WHERE tipo_lente IN ('multifocal', 'bifocal') AND adicao_max = 0;


| teste                                                                 | total |
| --------------------------------------------------------------------- | ----- |
| Grupos com Nome NULL (ERRO CRÍTICO)                                   | 0     |
| Lentes com Esférico/Cilindrico EXATAMENTE 0.00 (Suspeito se em massa) | 168   |
| Lentes Brascor com nome genérico "Lente Brascor"                      | 15    |
| Lentes sem Preço de Venda Sugerido                                    | 0     |
| Lentes com Adição Zerada em Multifocais/Bifocais                      | 614   |


-- 7. Análise de Nomes Genéricos (Brascor)
-- Se este número for alto, precisamos ajustar o parser para extrair o nome das células corretas
SELECT 
    nome_lente, 
    fornecedor_id, 
    tipo_lente, 
    COUNT(*) as ocorrencias
FROM lens_catalog.lentes 
WHERE nome_lente LIKE 'Lente Brascor%'
GROUP BY nome_lente, fornecedor_id, tipo_lente
ORDER BY ocorrencias DESC
LIMIT 10;


| nome_lente               | fornecedor_id                        | tipo_lente  | ocorrencias |
| ------------------------ | ------------------------------------ | ----------- | ----------- |
| Lente Brascor (861.00)   | 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | ocupacional | 2           |
| Lente Brascor (386.00)   | 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | ocupacional | 2           |
| Lente Brascor (388.00)   | 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | ocupacional | 2           |
| Lente Brascor (478.00)   | 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | ocupacional | 2           |
| Lente Brascor (647.00)   | 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | ocupacional | 2           |
| Lente Brascor (694.00)   | 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | ocupacional | 2           |
| Lente Brascor (861.00.1) | 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | ocupacional | 2           |
| Lente Brascor (239.00)   | 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | ocupacional | 1           |


-- 8. Verificação de Coerência de Tratamentos vs Nome
-- Busca lentes que dizem "Transitions" ou "AR" no nome mas o booleano está falso
SELECT 
    nome_lente,
    tratamento_antirreflexo as AR,
    tratamento_fotossensiveis as FOTO
FROM lens_catalog.lentes
WHERE (nome_lente ILIKE '%TRANSITIONS%' AND tratamento_fotossensiveis = 'nenhum')
   OR (nome_lente ILIKE '%CRIZAL%' AND tratamento_antirreflexo = false)
   OR (nome_lente ILIKE '%BLUE%' AND tratamento_blue_light = false)
LIMIT 20;


| nome_lente                                                                        | ar    | foto        |
| --------------------------------------------------------------------------------- | ----- | ----------- |
| CRIZAL 1.50 TRANSITIONS S/ AR (GEN8)                                              | false | transitions |
| CRIZAL 1.50 (GEN8)                                                                | false | transitions |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV CINZA (AWAY)       | true  | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV CINZA (CLARUS)     | true  | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV CINZA (BLUE PROT)  | false | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV CINZA (CLEAN)      | true  | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV CINZA (WHITE)      | false | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV CINZA (INCOLOR)    | false | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV MARROM (AWAY)      | true  | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV MARROM (CLARUS)    | true  | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV MARROM (BLUE PROT) | false | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV MARROM (CLEAN)     | true  | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV MARROM (WHITE)     | false | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV MARROM (INCOLOR)   | false | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV VERDE (AWAY)       | true  | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV VERDE (CLARUS)     | true  | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV VERDE (BLUE PROT)  | false | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV VERDE (CLEAN)      | true  | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV VERDE (WHITE)      | false | nenhum      |
| PRODIGE PLATINUM DIGITAL RESINA 1.50 TRANSITIONS GEN S BLUE UV VERDE (INCOLOR)    | false | nenhum      |


-- 9. Saúde da Tabela de Grupos: Slugs Duplicados
SELECT slug, COUNT(*) 
FROM lens_catalog.grupos_canonicos 
GROUP BY slug 
HAVING COUNT(*) > 1;


Success. No rows returned




-- 10. Lentes Órfãs (Sem fornecedor válido - não deve existir)
SELECT l.nome_lente 
FROM lens_catalog.lentes l
LEFT JOIN core.fornecedores f ON l.fornecedor_id = f.id
WHERE f.id IS NULL;

Success. No rows returned



-- ============================================================================
-- 11. INVESTIGAÇÃO DE MARKUP E REGRAS DE PREÇO
-- ============================================================================

-- A. Lentes abaixo do preço mínimo de R$ 250,00
SELECT 
    fornecedor_id,
    nome_lente,
    preco_custo,
    preco_tabela as preco_venda
FROM lens_catalog.lentes
WHERE preco_tabela < 250.00
ORDER BY preco_tabela ASC;


| fornecedor_id                        | nome_lente                                                                               | preco_custo | preco_venda |
| ------------------------------------ | ---------------------------------------------------------------------------------------- | ----------- | ----------- |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.59 POLICARBONATO AR BLUE                                                               | 58.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.59 POLICARBONATO AR BLUE FOTO                                                          | 78.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.59 POLICARBONATO AR BLUE FOTO                                                          | 98.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.50 CR39                                                                                | 9.00        | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.50 CR39                                                                                | 12.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR                                                                             | 11.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR                                                                             | 20.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR                                                                             | 42.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR FOTO                                                                        | 18.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR FOTO                                                                        | 26.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR BLUE                                                                        | 16.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR BLUE                                                                        | 22.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR BLUE                                                                        | 48.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR BLUE                                                                        | 16.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR BLUE                                                                        | 22.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR BLUE FOTO                                                                   | 42.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR BLUE FOTO                                                                   | 52.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.59 POLICARBONATO AR                                                                    | 18.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.59 POLICARBONATO AR                                                                    | 32.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.59 POLICARBONATO AR                                                                    | 16.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.59 POLICARBONATO AR                                                                    | 24.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.59 POLICARBONATO AR BLUE                                                               | 28.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.59 POLICARBONATO AR BLUE                                                               | 38.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.61 HIGH_INDEX AR BLUE                                                                  | 38.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.61 HIGH_INDEX AR BLUE                                                                  | 48.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.61 HIGH_INDEX AR BLUE FOTO                                                             | 58.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.61 HIGH_INDEX AR BLUE FOTO                                                             | 68.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR                                                                             | 26.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR                                                                             | 33.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR FOTO                                                                        | 48.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR BLUE                                                                        | 42.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.56 CR39 AR BLUE FOTO                                                                   | 68.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.59 POLICARBONATO AR                                                                    | 68.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.59 POLICARBONATO AR BLUE                                                               | 85.00       | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.67 HIGH_INDEX AR                                                                       | 140.00      | 0.00        |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | 1.67 HIGH_INDEX AR FOTO                                                                  | 230.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA AR BLUE HIDRO VERDE 1                                                        | 190.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.74 RESINA AR HIDRO BLUE                                                                | 370.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE INCOLOR TINTAVEL 1                                                          | 30.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA INCOLOR / TINGIVEL                                                           | 80.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO MULTIFOCAL AR                                                         | 100.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VARILUX CONFORT AIRWEAR                                                                  | 1015.00     | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | BIFOCAL FLAP TOP CR39                                                                    | 95.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.61 RESINA AR BLUE SUPER HIDRO 1                                                        | 120.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM 1.67 INC                                                               | 324.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE AR 1                                                                        | 35.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.61 RESINA AR FOTO BLUE HIDRO 1                                                         | 130.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.56 BLUE FOTO INC                                                 | 175.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.61 RESINA AR BLUE AZUL                                                                 | 87.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA AR BLUE HIDRO AZUL                                                           | 173.20      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA AR BLUE HIDRO VERDE                                                          | 173.20      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA AR BLUE HIDRO AZUL 2                                                         | 230.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA AR BLUE HIDRO AZUL 1                                                         | 190.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.67 BLUE FOTO INC                                                 | 510.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.67 BLUE INC                                                      | 325.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.67 BLUE FOTO AR                                                  | 569.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.67 BLUE AR                                                       | 384.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA AR FOTO                                                                      | 215.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.74 RESINA AR HIDRO BLUE AZUL                                                           | 385.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.74 RESINA AR HIDRO BLUE AZUL 1                                                         | 400.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.74 FOTO AR                                                       | 900.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.74 AR                                                            | 670.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.74 BLUE AR                                                       | 764.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.74 RESINA AR HIDRO                                                                     | 353.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.74 RESINA AR HIDRO 1                                                                   | 376.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO AR BLUE HIDRO AZUL                                                    | 40.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.59 POLI FOTO INC                                                 | 300.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.59 POLI FOTO AR                                                  | 350.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.59 POLI BLUE AR                                                  | 245.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO INCOLOR BLUE 1                                                        | 38.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO AR FOTO BLUE AZUL 1                                                   | 240.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO AR FOTO                                                               | 110.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.59 POLI INC                                                      | 121.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO AR BLUE HIDRO AZUL 1                                                  | 60.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO AR BLUE 1                                                             | 60.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO AR                                                                    | 25.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO INCOLOR BLUE                                                          | 27.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE CR ACCLIMATES                                                                     | 250.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO INCOLOR                                                               | 20.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.70 RESINA AR BLUE 1                                                                    | 190.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 FOTO AR BLUE AZUL 1                                                       | 85.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 FOTO AR BLUE                                                              | 50.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 FOTO AR BLUE 1                                                            | 85.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE PLUS CR ACCLIMATES                                                                | 390.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE SHORT CR                                                                          | 185.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM CR39 INC FOTO                                                          | 179.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VARILUX CONFORT CR TRANSITIONS                                                           | 1430.00     | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM CR39 TRANSITIONS INC                                                   | 285.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VARILUX LIBERTY CR TRANSITIONS                                                           | 1209.00     | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM CR39 INC                                                               | 86.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM CR39 TRANSITIONS AR                                                    | 339.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM CR39 AR                                                                | 146.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE CR                                                                                | 82.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE SHORT CR TRANSITIONS                                                              | 460.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE SHORT CR ACCLIMATES                                                               | 390.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 TRANSITIONS                                                               | 200.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE INCOLOR TINTAVEL                                                            | 20.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM 1.56 BLUE INC FOTO                                                     | 219.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM 1.56 BLUE INC                                                          | 115.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO MULTIFOCAL AR BLUE                                                    | 125.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 MULTIFOCAL FREE FORM                                                      | 60.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 MULTIFOCAL AR-FOTO FREE FORM                                              | 90.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 MULTIFOCAL AR                                                             | 40.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 MULTIFOCAL AR-FOTO                                                        | 78.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 MULTIFOCAL AR-FOTO BLUE AZUL                                              | 110.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 MULTIFOCAL AR BLUE                                                        | 68.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 MULTIFOCAL INC FOTO ANTI RISCO                                            | 38.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 MULTIFOCAL INCOLOR TINTAVEL                                               | 35.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VARILUX CONFORT AIRWEAR TRANSITIONS                                                      | 1560.00     | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VARILUX LIBERTY AIRWEAR TRANSITIONS                                                      | 1365.00     | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VARILUX LIBERTY AIRWEAR                                                                  | 720.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | BIFOCAL ULTEX CR39                                                                       | 79.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 AR EXTENDIDA 2                                                                   | 49.40       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.61 RESINA AR SUPER HIDRO 1                                                             | 102.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 INCOLOR TINTAVEL 5                                                               | 22.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 FOTO AR BLUE                                                              | 62.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM 1.67 BLUE INC FOTO                                                     | 557.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM 1.67 BLUE INC                                                          | 371.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM 1.67 AR                                                                | 386.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM 1.67 BLUE AR FOTO                                                      | 610.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.70 RESINA AR BLUE                                                                      | 160.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE AR CILINDRO ESPECIAL                                                        | 70.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.49 AR                                                            | 131.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 AR EXTENDIDA 1                                                                   | 35.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE AR RESIDUAL AZUL 1                                                          | 35.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.56 BLUE AR                                                       | 155.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.74 RESINA AR HIDRO BLUE 1                                                              | 400.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE AR SUPER HIDRO RES VERDE                                                    | 25.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE AR SUPER HIDRO RES AZUL                                                     | 25.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE AR                                                                          | 19.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE AR SUPER HIDRO RES AZUL 2                                                   | 65.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.49 BLUE AR                                                       | 180.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE AR SUPER HIDRO RES VERDE 1                                                  | 35.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.56 BLUE INC                                                      | 105.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE POLICARBONATO                                                                     | 197.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.56 BLUE FOTO AR                                                  | 225.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.70 RESINA AR BLUE 2                                                                    | 210.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 AR                                                                               | 12.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA AR FOTO 1                                                                    | 235.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA AR HIDRO 1                                                                   | 185.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.59 POLI AR                                                       | 180.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO AR FOTO BLUE AZUL                                                     | 195.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE PLUS CR TRANSITIONS                                                               | 455.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM 1.56 BLUE FOTO AR                                                      | 282.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM 1.67 BLUE AR                                                           | 425.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.49 BLUE INC                                                      | 121.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.49 FOTO AR                                                       | 219.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM POLI BLUE FOTO INC                                                     | 357.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.49 FOTO INC                                                      | 160.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.60 / 1.61 RESINA AR EXTENDIDA                                                          | 75.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.60 / 1.61 RESINA INCOLOR                                                               | 40.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.61 RESINA AR FOTO BLUE HIDRO AZUL 1                                                    | 130.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.61 RESINA AR BLUE AZUL 1                                                               | 120.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE AR SUPER HIDRO RES AZUL 1                                                   | 35.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.61 RESINA AR FOTO BLUE HIDRO AZUL                                                      | 110.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO AR BLUE                                                               | 38.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM POLI INC                                                               | 160.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM POLI BLUE INC                                                          | 257.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM POLI AR                                                                | 220.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM POLI BLUE FOTO AR                                                      | 410.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM POLI BLUE AR                                                           | 310.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 AR HIDROFOBICA                                                                   | 43.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.61 RESINA AR BLUE SUPER HIDRO                                                          | 87.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.61 RESINA AR FOTO BLUE HIDRO                                                           | 110.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.60 / 1.61 RESINA AR                                                                    | 56.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 FOTO AR BLUE AZUL                                                         | 62.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE SHORT POLICARBONATO                                                               | 275.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM CR39 AR FOTO                                                           | 239.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE SMALL CR                                                                          | 82.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA AR FOTO BLUE HIDRO AZUL 1                                                    | 270.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA AR FOTO BLUE HIDRO AZUL                                                      | 230.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 AR ESPECIAL                                                                      | 58.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE PLUS POLI TRANSITIONS                                                             | 637.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO INCOLOR 1                                                             | 50.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.49 TRANSITIONS AR                                                | 339.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.67 AR                                                            | 356.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | POLYLUX FREE FORM 1.56 BLUE AR VERDE                                                     | 159.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.49 TRANSITIONS INC                                               | 280.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.74 INC                                                           | 611.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE PLUS POLICARBONATO                                                                | 275.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.61 RESINA AR SUPER HIDRO                                                               | 74.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.67 INC                                                           | 298.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.74 FOTO INC                                                      | 841.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE PLUS CR                                                                           | 185.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.49 / 1.56 FOTO AR                                                                   | 35.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 BLUE AR RESIDUAL AZUL                                                            | 19.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VARILUX CONFORT CR                                                                       | 770.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.49 INC                                                           | 72.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.74 BLUE INC                                                      | 705.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VISAO SIMPLES DIGITAL 1.59 POLI BLUE INC                                                 | 195.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | VARILUX LIBERTY CR                                                                       | 507.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.59 POLICARBONATO AR 1                                                                  | 55.00       | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | 1.67 RESINA AR HIDRO                                                                     | 160.00      | 0.00        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | CR 1.56 INCOLOR TINTAVEL 1                                                               | 13.00       | 0.00        |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | VARILUX 1.50 LIBERTY (GEN8)                                                              | 3.50        | 10.50       |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | VARILUX 1.50 LIBERTY TRANSITIONS (GEN8)                                                  | 3.50        | 10.50       |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | VARILUX 1.50 COMFORT (GEN8)                                                              | 3.50        | 10.50       |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | VARILUX 1.50 COMFORT TRANSITIONS (GEN8)                                                  | 3.50        | 10.50       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL ORMA CLEAR (Crizal_Prevencia)                                    | 3.50        | 10.50       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL ORMA BLUE UV (Crizal_Prevencia)                                  | 3.50        | 10.50       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL ORMA TRANSITIONS GEN S (Crizal_Prevencia)                        | 3.50        | 10.50       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL ORMA TRANSITIONS EXTRACTIVE (Crizal_Prevencia)                   | 3.50        | 10.50       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL AIRWEAR CLEAR (Crizal_Prevencia)                                 | 3.50        | 10.50       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL AIRWEAR TRANSITIONS GEN S (Crizal_Prevencia)                     | 3.50        | 10.50       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL AIRWEAR TRANSITIONS EXTRACTIVE (Crizal_Prevencia)                | 3.50        | 10.50       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY TRADICIONAL ORMA CLEAR (Crizal_Prevencia)                                | 3.50        | 10.50       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY TRADICIONAL AIRWEAR CLEAR (Crizal_Prevencia)                             | 3.50        | 10.50       |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.50 AR                                                                    | 10.00       | 30.00       |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR                                                                    | 12.00       | 36.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR 1.49 Incolor                                                                       | 12.00       | 36.00       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. com AR 1.56                                                                    | 12.80       | 38.40       |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME CR AR 1.56                                                                      | 13.00       | 39.00       |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express CR AR 1.56                                                                       | 13.00       | 39.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56                                                                            | 13.00       | 39.00       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. com AR 1.49                                                                    | 13.50       | 40.50       |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 INCOLOR                                                               | 13.50       | 40.50       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT MAX DIGITAL ORMA BLUE UV (Crizal_Prevencia)                              | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT MAX DIGITAL ORMA TRANSITIONS GEN S (Crizal_Prevencia)                    | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT MAX DIGITAL ORMA TRANSITIONS EXTRAACTIVE (Crizal_Prevencia)              | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT MAX DIGITAL AIRWEAR POLYPOWER BLUE UV (Crizal_Prevencia)                 | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT MAX DIGITAL AIRWEAR POLYPOWER TRANSITIONS GEN S (Crizal_Prevencia)       | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT MAX DIGITAL AIRWEAR POLYPOWER TRANSITIONS EXTRAACTIVE (Crizal_Prevencia) | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT MAX DIGITAL STYLIS 1.67 BLUE UV (Crizal_Prevencia)                       | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT MAX DIGITAL STYLIS 1.67 TRANSITIONS GEN S (Crizal_Prevencia)             | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT TRADICIONAL ORMA CLEAR (Crizal_Prevencia)                                | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT TRADICIONAL ORMA BLUE UV (Crizal_Prevencia)                              | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT TRADICIONAL AIRWEAR POLYPOWER CLEAR (Crizal_Prevencia)                   | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX COMFORT TRADICIONAL STYLIS 1.67 CLEAR (Crizal_Prevencia)                         | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL ORMA CLEAR (Crizal_Sapphire_HR)                                  | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL ORMA BLUE UV (Crizal_Sapphire_HR)                                | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL ORMA TRANSITIONS GEN S (Crizal_Sapphire_HR)                      | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL ORMA TRANSITIONS EXTRACTIVE (Crizal_Sapphire_HR)                 | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL AIRWEAR CLEAR (Crizal_Sapphire_HR)                               | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL AIRWEAR TRANSITIONS GEN S (Crizal_Sapphire_HR)                   | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY DIGITAL AIRWEAR TRANSITIONS EXTRACTIVE (Crizal_Sapphire_HR)              | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY TRADICIONAL ORMA CLEAR (Crizal_Sapphire_HR)                              | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX LIBERTY TRADICIONAL AIRWEAR CLEAR (Crizal_Sapphire_HR)                           | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX DIGITIME NEAR ORMA (Crizal_Rock)                                                 | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX DIGITIME NEAR AIRWEAR (Crizal_Rock)                                              | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX DIGITIME NEAR STYLIS 1.67 (Crizal_Rock)                                          | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX DIGITIME MID ORMA (Crizal_Rock)                                                  | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX DIGITIME MID AIRWEAR (Crizal_Rock)                                               | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX DIGITIME MID STYLIS 1.67 (Crizal_Rock)                                           | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX ROADPILOT ORMA DAY&NIGHT (Crizal_Rock)                                           | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX ROADPILOT AIRWEAR XPERIO (Crizal_Rock)                                           | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX SPORT AIRWEAR (Crizal_Rock)                                                      | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX SPORT AIRWEAR TRANSITIONS (Crizal_Rock)                                          | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX SPORT WRAP AIRWEAR (Crizal_Rock)                                                 | 14.00       | 42.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | VARILUX SPORT SOLAR AIRWEAR XPERIO (Crizal_Rock)                                         | 14.00       | 42.00       |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.59 INCOLOR                                                               | 15.00       | 45.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR 1.49 Incolor Cil. Ext.                                                             | 15.50       | 46.50       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56 Cil. Ext.                                                                  | 17.00       | 51.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56 Blue (Residual Azul)                                                       | 17.00       | 51.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56 Blue (Residual Verde)                                                      | 17.00       | 51.00       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. Policarbonato Incolor HC                                                       | 17.40       | 52.20       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT Solar 1.50 Plana Degradê                                                              | 18.00       | 54.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Pronta Incolor                                                             | 18.00       | 54.00       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.49 Incolor                                                                   | 18.50       | 55.50       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT 1.59 Policarbonato Incolor                                                            | 19.00       | 57.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT Solar 1.50 Plana Total                                                                | 20.00       | 60.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT Solar 1.59 Policarbonato                                                              | 20.00       | 60.00       |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.59 AR                                                                    | 21.00       | 63.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT 1.59 Policarbonato AR                                                                 | 21.50       | 64.50       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Kodak Intro                                                                              | 21.90       | 65.70       |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME CR AR 1.56 BLUE                                                                 | 22.00       | 66.00       |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME POLI INCOLOR                                                                    | 22.00       | 66.00       |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express CR AR 1.56 BLUE                                                                  | 22.00       | 66.00       |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 INCOLOR                                                               | 22.00       | 66.00       |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR BLUE                                                               | 22.00       | 66.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Solar Incolor                                                              | 22.00       | 66.00       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. Policarbonato com AR                                                           | 22.10       | 66.30       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal CR 1.499                                                                      | 22.50       | 67.50       |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.59 TINGIVEL                                                              | 23.00       | 69.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56 Blue Cil. Ext. (Residual Azul)                                             | 23.00       | 69.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56 Blue Cil. Ext. (Residual Verde)                                            | 23.00       | 69.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Pronta Antirreflexo                                                        | 23.00       | 69.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56 Fotossensível                                                              | 23.50       | 70.50       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.56 Blue Verniz Tintável                                                      | 24.00       | 72.00       |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME POLI AR 1.59                                                                    | 25.00       | 75.00       |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express POLI AR 1.59                                                                     | 25.00       | 75.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Pronta Incolor                                                             | 25.00       | 75.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Solar Incolor                                                              | 25.00       | 75.00       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.49 Incolor Cil. Estendido                                                    | 26.00       | 78.00       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente 1.56 Ac. com AR Verde                                                              | 26.00       | 78.00       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente 1.56 Ac. com AR Azul                                                               | 26.00       | 78.00       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. com AR 1.56 Cil. Estendido                                                     | 27.00       | 81.00       |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal 1.56 C/AR (Residual Verde)                                                    | 27.00       | 81.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Pronta Incolor Cil. Ext.                                                   | 27.00       | 81.00       |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.61 INCOLOR                                                               | 30.00       | 90.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Pronta Resina Blue Cut Verde                                                             | 30.00       | 90.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Pronta Antirreflexo Cil. Ext.                                              | 31.00       | 93.00       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. Policarbonato Blue Incolor HC                                                  | 32.00       | 96.00       |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME CR AR 1.56 CIL EXT                                                              | 32.00       | 96.00       |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express CR AR 1.56 CIL EXT                                                               | 32.00       | 96.00       |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Pronta Resina Blue Cut Azul                                                              | 33.00       | 99.00       |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.56 Blue Verniz Tintável Cil. Estendido                                       | 34.00       | 102.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR EXTENDIDA 1                                                        | 35.00       | 105.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR FOTO                                                               | 35.00       | 105.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.59 INCOLOR                                                               | 35.00       | 105.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Solar Degradê                                                              | 35.00       | 105.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente 1.56 Ac. com AR Verde Cil. Estendido                                               | 36.00       | 108.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente 1.56 Ac. com AR Azul Cil. Estendido                                                | 36.00       | 108.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56 Fotossensível Cil. Ext.                                                    | 36.50       | 109.50      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. Policarbonato com AR Verde                                                     | 37.00       | 111.00      |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME CR AR FOTO                                                                      | 37.00       | 111.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express CR AR FOTO                                                                       | 37.00       | 111.00      |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME POLI INCOLOR CIL EXT                                                            | 38.00       | 114.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Solar Total                                                                | 38.00       | 114.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Super Hidrofóbico                                                          | 39.00       | 117.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Multifocal Acabado 1.56 com AR                                                           | 40.00       | 120.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | MULTIFOCAL 1.56 AR                                                                       | 40.00       | 120.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Visão Simples CR (NÃO TINTÁVEL) 1.50                                                     | 40.00       | 120.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal 1.56 Bluecut C/AR (Residual Azul)                                             | 40.00       | 120.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Solar Total                                                                | 40.00       | 120.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Solar Degradê                                                              | 40.00       | 120.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT 1.59 Policarbonato Blue AR (Residual Verde)                                           | 41.50       | 124.50      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT 1.59 Policarbonato Blue AR (Residual Azul)                                            | 41.50       | 124.50      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT 1.59 Policarbonato Blue AR (Residual Verde)                                           | 41.50       | 124.50      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT 1.59 Policarbonato Blue AR (Residual Azul)                                            | 41.50       | 124.50      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.59 AR BLUE                                                               | 42.00       | 126.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.61 AR                                                                    | 42.00       | 126.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Pronta Poli Blue Cut Verde/Azul                                                          | 42.00       | 126.00      |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME POLI AR 1.59 CIL EXT                                                            | 43.00       | 129.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express POLI AR 1.59 CIL EXT                                                             | 43.00       | 129.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR HIDROFÓBICA                                                        | 43.00       | 129.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.59 BLUE INCOLOR                                                          | 43.00       | 129.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT 1.59 Policarbonato Incolor Cil. Ext.                                                  | 43.00       | 129.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT 1.59 Policarbonato AR Cil. Ext.                                                       | 43.00       | 129.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. Policarbonato Incolor HC Estendido                                             | 44.00       | 132.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente 1.56 Ac. com AR Verde Super Hidrofóbico                                            | 44.00       | 132.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Solar Poly Total                                                           | 44.00       | 132.00      |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME CR AR FOTO CIL EXT                                                              | 45.00       | 135.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express CR AR FOTO CIL EXT                                                               | 45.00       | 135.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal 1.56 Photo C/AR (Residual Verde)                                              | 45.00       | 135.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Pronta Foto Antirreflexo                                                   | 45.00       | 135.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Solar Poly Total                                                           | 45.00       | 135.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Kodak Blue UV                                                                            | 45.00       | 135.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56 Blue Foto (Residual Azul)                                                  | 45.50       | 136.50      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56 Blue Foto (Residual Verde)                                                 | 46.00       | 138.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. Policarbonato Blue Incolor HC Estendido                                        | 47.00       | 141.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Super Hidrofóbico · Cil. Ext.                                              | 47.00       | 141.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Solar Poly Degradê                                                         | 47.00       | 141.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | KODAK INTRO 1.56                                                                         | 47.00       | 141.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. Policarbonato com AR Ext. Cil.                                                 | 48.00       | 144.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.56 Foto com AR                                                               | 48.00       | 144.00      |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME POLI AR 1.59 BLUE                                                               | 48.00       | 144.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express POLI AR 1.59 BLUE                                                                | 48.00       | 144.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Pronta Poli Cil. Ext. Blue Cut Azul                                                      | 48.00       | 144.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Solar Poly Degradê                                                         | 48.00       | 144.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express SOLAR CR 1.50                                                                    | 49.00       | 147.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR BLUE HIDRO                                                         | 49.00       | 147.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR EXTENDIDA 2                                                        | 49.40       | 148.20      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. Policarbonato com AR Verde Super Hidrofóbico                                   | 50.00       | 150.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR FOTO                                                               | 50.00       | 150.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Visão Simples CR Plus (TINTÁVEL) 1.50                                                    | 50.00       | 150.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Visão Simples CR Photo 1.56                                                              | 50.00       | 150.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal CR Plus (NÃO TINTÁVEL) 1.56                                                   | 50.00       | 150.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Ultex CR 1.50                                                                            | 50.00       | 150.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Kriptok CR 1.50                                                                          | 50.00       | 150.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Flat Top CR 1.50                                                                         | 50.00       | 150.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Multifocal Acabado 1.56 Blue com AR Residual Azul FREE FORM                              | 52.00       | 156.00      |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME CR AR FOTO BLUE                                                                 | 52.00       | 156.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express CR AR FOTO BLUE                                                                  | 52.00       | 156.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Pronta Resina Cil. Ext. Blue Cut Verde                                                   | 52.00       | 156.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. Policarbonato com AR Verde Cil. Estendido                                      | 55.00       | 165.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR BLUE                                                               | 55.00       | 165.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.59 AR                                                                    | 55.00       | 165.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Visão Simples CR Bluecut 1.56                                                            | 55.00       | 165.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal Incolor Importado HD (TINTÁVEL) 1.50                                          | 55.00       | 165.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Super Hidrofóbico · Blue Cut                                               | 55.00       | 165.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente 1.56 Ac. com AR Verde Super Hidrofóbico Cil. Estendido                             | 56.00       | 168.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.61 AR                                                                    | 56.00       | 168.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT 1.59 Policarbonato Blue AR Cil. Ext. (Residual Azul)                                  | 57.00       | 171.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT 1.59 Policarbonato Blue AR Cil. Ext. (Residual Azul)                                  | 57.00       | 171.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal 1.56 Photo Bluecut C/AR (Residual Azul)                                       | 57.00       | 171.00      |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME CR AR 1.56 BLUE CIL EXT                                                         | 58.00       | 174.00      |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME POLI AR 1.59 BLUE CIL EXT                                                       | 58.00       | 174.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express CR AR 1.56 BLUE CIL EXT                                                          | 58.00       | 174.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express POLI AR 1.59 BLUE CIL EXT                                                        | 58.00       | 174.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR ESPECIAL                                                           | 58.00       | 174.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.59 BLUE INCOLOR                                                          | 60.00       | 180.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.59 AR BLUE                                                               | 60.00       | 180.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | MULTIFOCAL 1.56 FREE FORM + AR                                                           | 60.00       | 180.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Visão Simples CR C/ AR Externo (Residual Verde) 1.56                                     | 60.00       | 180.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal Incolor AO Compact (TINTÁVEL) 1.50                                            | 60.00       | 180.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal CR Plus Bluecut 1.56                                                          | 60.00       | 180.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Ultex Photo 1.56                                                                         | 60.00       | 180.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Kriptok Photo 1.50                                                                       | 60.00       | 180.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Flat Top Photo 1.56                                                                      | 60.00       | 180.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Super Hidrofóbico                                                          | 60.00       | 180.00      |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | HV PRIME CR AR FOTO BLUE CIL EXT                                                         | 62.00       | 186.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express CR AR FOTO BLUE CIL EXT                                                          | 62.00       | 186.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR FOTO BLUE                                                          | 62.00       | 186.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Pronta Incolor Cil. Ext.                                                   | 62.00       | 186.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56 Blue Foto Cil. Ext. (Residual Verde)                                       | 62.50       | 187.50      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT CR AR 1.56 Blue Foto Cil. Ext. (Residual Azul)                                        | 62.50       | 187.50      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Pronta Foto Antirreflexo Cil. Ext.                                         | 63.00       | 189.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.61 com AR Super Hidrofóbico                                                  | 64.00       | 192.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.61 com AR Super Hidrofóbico Estendido                                        | 64.00       | 192.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.61 com AR Super Hidrofóbico (Esférica Pura)                                  | 64.00       | 192.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.56 Foto com AR Cil. Estendido                                                | 65.00       | 195.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. Policarbonato com AR Verde Super Hidrofóbico Cil. Estendido                    | 65.00       | 195.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Multifocal Acabado 1.56 Foto com AR                                                      | 65.00       | 195.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express POLI AR 1.59 RANGE AMP                                                           | 65.00       | 195.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Visão Simples CR Photo Plus 1.56                                                         | 65.00       | 195.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal CR C/ AR Externo (Residual Verde) 1.56                                        | 65.00       | 195.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Pronta Resina Cil. Ext. Blue Cut Azul                                                    | 65.00       | 195.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Visão Simples Super Hidrofóbico · Blue Cut · Cil. Ext.                                   | 65.00       | 195.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.56 Foto com AR Verde Super Hidro                                             | 66.00       | 198.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | MULTIFOCAL 1.56 AR BLUE                                                                  | 68.00       | 204.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | ESPACE 1.50 ORMA Crizal Easy                                                             | 69.00       | 207.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | ESPACE 1.50 ORMA (GEN8)                                                                  | 70.00       | 210.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | ESPACE 1.50 ORMA ACCLIMATES (GEN8)                                                       | 70.00       | 210.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | ESPACE 1.50 PLUS (GEN8)                                                                  | 70.00       | 210.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | ESPACE 1.50 PLUS TRANSITIONS (GEN8)                                                      | 70.00       | 210.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Visão Simples CR Photo C/ AR Ext. (Residual Azul) 1.56                                   | 70.00       | 210.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Visão Simples CR Photo C/ AR Ext. (Residual Verde) 1.56                                  | 70.00       | 210.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | No Line Orma / Small 1.50                                                                | 70.00       | 210.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Multifocal Acabado 1.56 Blue Foto com AR Residual Azul FREE FORM                         | 72.00       | 216.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express POLI AR 1.59 CIL EXT 70                                                          | 72.00       | 216.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples Digital 1.50 INCOLOR                                                       | 72.00       | 216.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | LT 1.67 AR (Residual Verde)                                                              | 72.00       | 216.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Pronta Poli Cil. Ext. Blue Cut Verde                                                     | 72.00       | 216.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.61 AR HIDRO                                                              | 74.20       | 222.60      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.61 Blue AR Azul                                                              | 75.00       | 225.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | KODAK 1.50 ORMA (GEN8)                                                                   | 75.00       | 225.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | KODAK 1.50 ORMA TRANSITIONS (GEN8)                                                       | 75.00       | 225.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR BLUE HIDRO                                                         | 75.00       | 225.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.61 AR                                                                    | 75.00       | 225.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Visão Simples CR Bluecut C/ AR Ext. (Residual Azul) 1.56                                 | 75.00       | 225.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Visão Simples CR Bluecut C/ AR Ext. (Residual Verde) 1.56                                | 75.00       | 225.00      |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Kodak City                                                                               | 75.90       | 227.70      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Essilor Espace 1.50 INCOLOR                                                              | 77.00       | 231.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | MULTIFOCAL 1.56 AR FOTO                                                                  | 78.00       | 234.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | VS SURFA 1.50 (Incolor)                                                                  | 79.00       | 237.00      |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express SOLAR CR 1.50 CIL EXT                                                            | 79.00       | 237.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | VS SURFA 1.50 (Incolor)                                                                  | 79.00       | 237.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Polylux Free Form 1.50 INCOLOR                                                           | 79.00       | 237.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Bifocal Ultex 1.50 INCOLOR                                                               | 79.00       | 237.00      |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | Lente Ac. 1.56 Fotossensível com AR Verde Super Hidro Cil. Estendido                     | 80.00       | 240.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | BIFOCAL CR BALUX (Incolor)                                                               | 80.00       | 240.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | BIFOCAL CR FLATOP (Incolor)                                                              | 80.00       | 240.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | VARILUX 1.50 LIBERTY Crizal Easy                                                         | 80.00       | 240.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | VARILUX 1.50 LIBERTY TRANSITIONS Crizal Easy                                             | 80.00       | 240.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | VARILUX 1.50 COMFORT Crizal Easy                                                         | 80.00       | 240.00      |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | VARILUX 1.50 COMFORT TRANSITIONS Crizal Easy                                             | 80.00       | 240.00      |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Visão Simples 1.56 AR BLUE CILINDRO ESPECIAL                                             | 80.00       | 240.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal CR Bluecut C/ AR Externo (Residual Verde) 1.56                                | 80.00       | 240.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal CR Bluecut C/ AR Externo (Residual Azul) 1.56                                 | 80.00       | 240.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Multifocal CR Photo SYGMA Plus 1.56                                                      | 80.00       | 240.00      |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Espace Orma 1.50                                                                         | 80.00       | 240.00      |


-- B. Lentes com markup abusivo (acima de 4x o custo)
SELECT 
    fornecedor_id,
    nome_lente,
    preco_custo,
    preco_tabela as preco_venda,
    ROUND(preco_tabela / NULLIF(preco_custo, 0), 2) as markup
FROM lens_catalog.lentes
WHERE (preco_tabela / NULLIF(preco_custo, 0)) > 4.0
ORDER BY markup DESC;


Success. No rows returned




-- C. Verificação de "Preços Iguais para Custos Diferentes"
-- (Se o resultado for alto, a lógica de precificação está ignorando variações de custo)
SELECT 
    preco_tabela, 
    COUNT(DISTINCT preco_custo) as qtd_custos_diferentes
FROM lens_catalog.lentes
GROUP BY preco_tabela
HAVING COUNT(DISTINCT preco_custo) > 1
ORDER BY qtd_custos_diferentes DESC
LIMIT 10;


| preco_tabela | qtd_custos_diferentes |
| ------------ | --------------------- |
| 0.00         | 129                   |

-- D. Resumo de Markup Médio por Fornecedor
SELECT 
    f.nome as fornecedor,
    COUNT(*) as total_lentes,
    ROUND(AVG(l.preco_tabela / NULLIF(l.preco_custo, 0)), 2) as markup_medio_real,
    MIN(l.preco_tabela) as preco_venda_min,
    MAX(l.preco_tabela) as preco_venda_max
FROM core.fornecedores f
JOIN lens_catalog.lentes l ON f.id = l.fornecedor_id
GROUP BY f.nome;


| fornecedor  | total_lentes | markup_medio_real | preco_venda_min | preco_venda_max |
| ----------- | ------------ | ----------------- | --------------- | --------------- |
| Polylux     | 287          | 1.35              | 0.00            | 3288.00         |
| So Blocos   | 60           | 3.00              | 38.40           | 1140.00         |
| High Vision | 19           | 3.00              | 39.00           | 1920.00         |
| Express     | 44           | 3.00              | 39.00           | 2250.00         |
| Hoya        | 192          | 3.00              | 1770.00         | 21345.00        |
| Brascor     | 2649         | 3.00              | 10.50           | 15762.00        |
| Sygma       | 141          | 3.00              | 36.00           | 4800.00         |
| Style       | 270          | 3.00              | 10.50           | 3423.00         |
| Braslentes  | 36           | 0.00              | 0.00            | 0.00            |