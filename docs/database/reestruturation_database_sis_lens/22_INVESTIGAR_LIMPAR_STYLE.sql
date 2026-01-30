-- ============================================================================
-- INVESTIGAÇÃO E LIMPEZA: Fornecedor Style e Marcas Premium
-- ============================================================================

-- 1. IDENTIFICAR O FORNECEDOR STYLE
SELECT id, nome FROM core.fornecedores WHERE nome ILIKE '%Style%';
-- Retorno esperado: d88018ac-ecae-4b38-b321-94babe5f85e3

| id                                   | nome  |
| ------------------------------------ | ----- |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | Style |


-- 2. IDENTIFICAR AS MARCAS PREMIUM NO BANCO
-- Precisamos destes IDs para o script de normalização ficar perfeito
SELECT id, nome, is_premium 
FROM lens_catalog.marcas 
WHERE nome IN ('STYLE', 'CRIZAL', 'VARILUX', 'HOYA', 'KODAK', 'ESPACE', 'ESSILOR');


| id                                   | nome    | is_premium |
| ------------------------------------ | ------- | ---------- |
| 3f70213e-0b45-4f42-907a-28f7e7ac51c0 | VARILUX | true       |
| 852e5fb8-8eae-4805-a5cb-a5a1e8638f5c | HOYA    | true       |
| a6091278-c827-40ea-a2fb-dcc26f1c8d20 | KODAK   | true       |
| bbe5a62d-1d7d-4d93-87af-0dbde68c0645 | ESSILOR | true       |
| befba165-0aa0-496f-bfdf-774bfe94a856 | CRIZAL  | true       |
| 731a86d5-2d61-42ca-9533-1af470184bad | STYLE   | false      |


-- 3. LIMPEZA TOTAL DA STYLE (Caso algo tenha subido errado)
-- Se você já tentou subir o CSV anterior, rode isto para limpar e começar do zero agora com o premium certo
BEGIN;
DELETE FROM lens_catalog.lentes 
WHERE fornecedor_id = 'd88018ac-ecae-4b38-b321-94babe5f85e3';
-- COMMIT; -- Execute o COMMIT se os IDs de marca acima baterem com o que você espera
ROLLBACK;
