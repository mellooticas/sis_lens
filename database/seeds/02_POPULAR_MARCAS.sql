-- ============================================
-- 02_POPULAR_MARCAS.sql
-- Adiciona marcas REAIS do banco existente
-- ============================================
-- 
-- DADOS EXTRAÍDOS DO BANCO ATUAL em 16/12/2025
-- Arquivo: csvs/marcas_rows copy.csv
-- Total: 7 marcas (apenas as que existem nas lentes)
-- ============================================

TRUNCATE TABLE lens_catalog.marcas CASCADE;

-- Inserir somente as marcas que existem no arquivo de lentes
-- PREMIUM: Apenas ESSILOR (marca internacional de alto padrão)
-- GENÉRICAS: Todas as demais marcas nacionais
INSERT INTO lens_catalog.marcas (id, nome, slug, is_premium, descricao, ativo) VALUES
('4c67f7d1-ec57-4a1a-9e00-e1778753b738', 'ESSILOR', 'essilor', true, 'Líder mundial em lentes oftálmicas', true),
('5a43c260-12bf-4651-99c5-a050a23721ad', 'EXPRESS', 'express', false, 'Lentes de alta qualidade Express', true),
('5b64739e-d1f4-4c13-a159-867d8683f934', 'SIS Lens', 'sis-lens', false, 'Marca própria brasileira', true),
('a1b9169c-1af2-4a36-8451-de372dc67003', 'SOBLOCOS', 'soblocos', false, 'Laboratório nacional - lentes de qualidade', true),
('a7656b0c-88fb-4aa8-a3ed-a7de84598492', 'POLYLUX', 'polylux', false, 'Lentes nacionais intermediárias', true),
('ba68f270-20a2-4697-a3eb-73d7d33fbed6', 'BRASCOR', 'brascor', false, 'Distribuidora nacional de lentes', true),
('da2dc10f-b3cb-4b8b-bec6-4e6f35f3dfcb', 'SYGMA', 'sygma', false, 'Laboratório óptico nacional', true);

-- ============================================
-- VERIFICAÇÃO
-- ============================================
SELECT 
    COUNT(*) as total_marcas,
    COUNT(CASE WHEN is_premium = true THEN 1 END) as premium,
    COUNT(CASE WHEN is_premium = false THEN 1 END) as standard
FROM lens_catalog.marcas;

-- Listar todas as marcas
SELECT 
    nome, 
    slug, 
    is_premium, 
    descricao,
    ativo 
FROM lens_catalog.marcas 
ORDER BY is_premium DESC, nome;


| nome     | slug     | is_premium | descricao                                  | ativo |
| -------- | -------- | ---------- | ------------------------------------------ | ----- |
| BRASCOR  | brascor  | true       | Distribuidora nacional de lentes           | true  |
| ESSILOR  | essilor  | true       | Líder mundial em lentes oftálmicas         | true  |
| EXPRESS  | express  | true       | Lentes de alta qualidade Express           | true  |
| POLYLUX  | polylux  | true       | Lentes nacionais intermediárias            | true  |
| SOBLOCOS | soblocos | true       | Laboratório nacional - lentes de qualidade | true  |
| SYGMA    | sygma    | true       | Laboratório óptico nacional                | true  |
| SIS Lens | sis-lens | false      | Marca própria brasileira                   | true  |

