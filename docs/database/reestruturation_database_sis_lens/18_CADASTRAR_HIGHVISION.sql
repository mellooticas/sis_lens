-- ============================================================================
-- CADASTRO: Novo Fornecedor e Marca 'High Vision'
-- ============================================================================
-- Objetivo: Inserir High Vision no banco para permitir a importação de lentes
-- ============================================================================

BEGIN;

-- 1. Inserir Fornecedor
INSERT INTO core.fornecedores (
    id,
    nome,
    razao_social,
    cnpj,
    cep_origem,
    cidade_origem,
    estado_origem,
    prazo_visao_simples,
    prazo_multifocal,
    frete_config,
    ativo
) VALUES (
    '2ee5b31f-0e98-467b-9c69-251f284c4a78', -- ID fixo para usarmos no script de normalização
    'High Vision',
    'HIGH VISION COMERCIO DE LENTES LTDA - EPP',
    '07.889.770/0001-86',
    '02033-000',
    'São Paulo',
    'SP',
    3, -- Prazos baseados na agilidade do laboratório (ajuste se necessário)
    7,
    jsonb_build_object(
        'tipo', 'Entrega Própria/Motoboy',
        'taxa_fixa', 15,
        'frete_gratis_acima', 300,
        'contato', jsonb_build_object(
            'telefone', '(11) 2226-4444',
            'endereco', 'Av. Gen. Ataliba Leonel, 111 - 2 Andar - Santana, São Paulo - SP'
        )
    ),
    true
) ON CONFLICT (cnpj) DO UPDATE SET 
    nome = EXCLUDED.nome,
    razao_social = EXCLUDED.razao_social,
    frete_config = core.fornecedores.frete_config || EXCLUDED.frete_config;

-- 2. Inserir Marca High Vision
INSERT INTO lens_catalog.marcas (
    id,
    nome,
    slug,
    is_premium,
    ativo
) VALUES (
    '89264c78-2dcb-494b-a9f8-d7b6e54c3a10',
    'HIGH VISION',
    'high-vision',
    true,
    true
) ON CONFLICT (id) DO NOTHING;

COMMIT;

-- Verificação
SELECT * FROM core.fornecedores WHERE id = '2ee5b31f-0e98-467b-9c69-251f284c4a78';

| id                                   | nome        | razao_social                              | cnpj               | cep_origem | cidade_origem | estado_origem | prazo_visao_simples | prazo_multifocal | prazo_surfacada | prazo_free_form | frete_config                                                                                                                                                                                     | desconto_volume                                           | ativo | created_at                    | updated_at                    | deleted_at |
| ------------------------------------ | ----------- | ----------------------------------------- | ------------------ | ---------- | ------------- | ------------- | ------------------- | ---------------- | --------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------- | ----- | ----------------------------- | ----------------------------- | ---------- |
| 2ee5b31f-0e98-467b-9c69-251f284c4a78 | High Vision | HIGH VISION COMERCIO DE LENTES LTDA - EPP | 07.889.770/0001-86 | 02033-000  | São Paulo     | SP            | 3                   | 7                | 12              | 15              | {"tipo":"Entrega Própria/Motoboy","contato":{"endereco":"Av. Gen. Ataliba Leonel, 111 - 2 Andar - Santana, São Paulo - SP","telefone":"(11) 2226-4444"},"taxa_fixa":15,"frete_gratis_acima":300} | {"5_unidades":0.03,"10_unidades":0.05,"20_unidades":0.08} | true  | 2026-01-30 03:49:47.225999+00 | 2026-01-30 03:49:47.225999+00 | null       |


SELECT * FROM lens_catalog.marcas WHERE nome = 'HIGH VISION';


| id                                   | nome        | slug        | is_premium | descricao | website | logo_url | ativo | created_at                    | updated_at                    |
| ------------------------------------ | ----------- | ----------- | ---------- | --------- | ------- | -------- | ----- | ----------------------------- | ----------------------------- |
| 89264c78-2dcb-494b-a9f8-d7b6e54c3a10 | HIGH VISION | high-vision | true       | null      | null    | null     | true  | 2026-01-30 03:49:47.225999+00 | 2026-01-30 03:49:47.225999+00 |
