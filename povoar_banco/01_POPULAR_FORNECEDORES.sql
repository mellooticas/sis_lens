-- ============================================
-- 01_POPULAR_FORNECEDORES.sql
-- Adiciona fornecedores REAIS do banco existente
-- ============================================
-- 
-- DADOS EXTRAÍDOS DO BANCO ATUAL em 17/12/2025
-- Arquivo: csvs/laboratorios_rows.csv (DADOS COMPLETOS)
-- Total: 5 fornecedores (apenas os que aparecem nas lentes)
-- ============================================

TRUNCATE TABLE pessoas.fornecedores CASCADE;

-- Inserir apenas os fornecedores que têm lentes cadastradas
INSERT INTO pessoas.fornecedores (
    id,
    nome,
    razao_social,
    cnpj,
    telefone,
    email,
    prazo_visao_simples,
    prazo_multifocal,
    prazo_surfacada,
    prazo_free_form,
    ativo
) VALUES
-- Brascor (58 lentes) - Lead time: 7 dias
(
    '15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1',
    'Brascor',
    'Brascor Distribuidora de Lentes',
    NULL,
    '(11) 93047-3110',
    'vendas@brascorlab.com.br',
    7,
    10,
    12,
    15,
    true
),
-- Sygma (14 lentes) - Lead time: 7 dias
-- Site: https://www.sygmalentes.com.br
(
    '199bae08-0217-4b70-b054-d3f0960b4a78',
    'Sygma',
    'Sygma Lentes Laboratório Óptico',
    NULL,
    '(11) 3667-8803',
    'contato@sygmalentes.com.br',
    7,
    10,
    12,
    15,
    true
),
-- Polylux (158 lentes) - Lead time: 7 dias
(
    '3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21',
    'Polylux',
    'Polylux Comercio de Produtos Opticos LTDA',
    NULL,
    '(11) 4123-1319',
    'atendimento@polilux.com',
    7,
    10,
    12,
    15,
    true
),
-- Express (84 lentes) - Lead time: 3 dias ⚡
-- Atendimento: seg-sex 9h-16h, sáb 9h-14h (exceto último sáb do mês)
-- Local: Galeria Florêncio (Rua Senador Queiroz, 360, 1º andar, BOX 114A)
(
    '8eb9498c-3d99-4d26-bb8c-e503f97ccf2c',
    'Express',
    'Lentes e Cia Express LTDA',
    NULL,
    '(11) 94165-8875',
    'lentesexpress25@gmail.com',
    3,  -- Lead time mais rápido!
    5,
    7,
    10,
    true
),
-- So Blocos (1.097 lentes - MAIOR FORNECEDOR) ⭐
-- Lead time: 7 dias
(
    'e1e1eace-11b4-4f26-9f15-620808a4a410',
    'So Blocos',
    'Só blocos Comercio e Serviços Oticos LTDA',
    NULL,
    '(11) 93778-3087',
    NULL,
    7,
    10,
    12,
    15,
    true
);

-- ============================================
-- VERIFICAÇÃO
-- ============================================
SELECT 
    COUNT(*) as total_fornecedores,
    COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
    COUNT(CASE WHEN ativo = false THEN 1 END) as inativos
FROM pessoas.fornecedores;

-- Mostrar todos os fornecedores cadastrados com lead times
SELECT 
    id, 
    nome, 
    razao_social,
    telefone,
    email,
    prazo_visao_simples as lead_time_padrao,
    ativo
FROM pessoas.fornecedores
ORDER BY prazo_visao_simples, nome;

-- ============================================
-- RESULTADO ESPERADO
-- ============================================
-- total_fornecedores: 5
-- ativos: 5
-- inativos: 0
-- 
-- Express tem o menor lead time (3 dias) ⚡
-- So Blocos é o maior fornecedor (1.097 lentes) ⭐


| id                                   | nome      | razao_social                              | telefone        | email                      | lead_time_padrao | ativo |
| ------------------------------------ | --------- | ----------------------------------------- | --------------- | -------------------------- | ---------------- | ----- |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express   | Lentes e Cia Express LTDA                 | (11) 94165-8875 | lentesexpress25@gmail.com  | 3                | true  |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Brascor   | Brascor Distribuidora de Lentes           | (11) 93047-3110 | vendas@brascorlab.com.br   | 7                | true  |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Polylux   | Polylux Comercio de Produtos Opticos LTDA | (11) 4123-1319  | atendimento@polilux.com    | 7                | true  |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | So Blocos | Só blocos Comercio e Serviços Oticos LTDA | (11) 93778-3087 | null                       | 7                | true  |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Sygma     | Sygma Lentes Laboratório Óptico           | (11) 3667-8803  | contato@sygmalentes.com.br | 7                | true  |

