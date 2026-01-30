-- ============================================================================
-- TEMPLATE: IMPORTAR LENTES DE NOVO LABORATÓRIO VIA CSV
-- ============================================================================
--
-- ESTRUTURA REAL DA TABELA lens_catalog.lentes (atualizado Jan/2026)
--
-- INSTRUÇÕES:
-- 1. Copie este arquivo e renomeie para o nome do laboratório
--    Ex: IMPORTAR_LABORATORIO_OPTILAB.sql
-- 2. Preencha os dados do laboratório na PARTE 1
-- 3. Crie a marca se necessário (PARTE 2)
-- 4. Prepare o CSV conforme template (PARTE 3)
-- 5. Execute o import (PARTE 4)
-- 6. Verifique os resultados (PARTE 5)
--
-- IMPORTANTE:
-- - O preço de venda (preco_venda_sugerido) é calculado AUTOMATICAMENTE
--   pela trigger trg_calcular_preco_venda baseado em preco_custo x markup
-- - O grupo canônico é atribuído AUTOMATICAMENTE pela trigger
--   trg_lente_insert_update
-- - O slug é gerado AUTOMATICAMENTE pela trigger trg_lentes_generate_slug
--
-- ============================================================================

-- ============================================================================
-- PARTE 1: CADASTRAR O NOVO LABORATÓRIO (FORNECEDOR)
-- ============================================================================
-- Substitua os valores abaixo pelos dados reais do laboratório

DO $$
DECLARE
    v_fornecedor_id UUID;
    v_nome_lab TEXT := 'NOME_DO_LABORATORIO';  -- <-- ALTERE AQUI
BEGIN
    -- Verificar se já existe
    SELECT id INTO v_fornecedor_id
    FROM core.fornecedores
    WHERE UPPER(nome) = UPPER(v_nome_lab);

    IF v_fornecedor_id IS NOT NULL THEN
        RAISE NOTICE '✅ Laboratório % já existe com ID: %', v_nome_lab, v_fornecedor_id;
    ELSE
        -- Inserir novo laboratório
        INSERT INTO core.fornecedores (
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
        ) VALUES (
            gen_random_uuid(),
            'NOME_DO_LABORATORIO',           -- <-- ALTERE: Nome fantasia
            'RAZAO SOCIAL LTDA',             -- <-- ALTERE: Razão social
            NULL,                             -- <-- ALTERE: CNPJ (opcional)
            '(11) 99999-9999',               -- <-- ALTERE: Telefone
            'contato@laboratorio.com',       -- <-- ALTERE: Email
            7,                                -- <-- ALTERE: Prazo visão simples (dias)
            10,                               -- <-- ALTERE: Prazo multifocal (dias)
            12,                               -- <-- ALTERE: Prazo surfaçada (dias)
            15,                               -- <-- ALTERE: Prazo free form (dias)
            true
        )
        RETURNING id INTO v_fornecedor_id;

        RAISE NOTICE '✅ Laboratório % criado com ID: %', v_nome_lab, v_fornecedor_id;
    END IF;
END $$;

-- Verificar o laboratório criado
SELECT id, nome, telefone, email, prazo_visao_simples
FROM core.fornecedores
WHERE nome = 'NOME_DO_LABORATORIO';  -- <-- ALTERE AQUI

-- ============================================================================
-- PARTE 2: CADASTRAR NOVA MARCA (SE NECESSÁRIO)
-- ============================================================================
-- Se o laboratório trabalha com marca própria, cadastre aqui

DO $$
DECLARE
    v_marca_id UUID;
    v_nome_marca TEXT := 'NOME_DA_MARCA';  -- <-- ALTERE AQUI
BEGIN
    -- Verificar se já existe
    SELECT id INTO v_marca_id
    FROM lens_catalog.marcas
    WHERE UPPER(nome) = UPPER(v_nome_marca);

    IF v_marca_id IS NOT NULL THEN
        RAISE NOTICE '✅ Marca % já existe com ID: %', v_nome_marca, v_marca_id;
    ELSE
        -- Inserir nova marca
        INSERT INTO lens_catalog.marcas (
            id,
            nome,
            slug,
            is_premium,    -- true = marca premium (Essilor, Zeiss, Hoya)
                           -- false = marca genérica/nacional
            descricao,
            ativo
        ) VALUES (
            gen_random_uuid(),
            'NOME_DA_MARCA',                 -- <-- ALTERE: Nome da marca
            'nome-da-marca',                 -- <-- ALTERE: Slug (minúsculo, sem espaços)
            false,                           -- <-- ALTERE: true se for premium
            'Descrição da marca',            -- <-- ALTERE: Descrição
            true
        )
        RETURNING id INTO v_marca_id;

        RAISE NOTICE '✅ Marca % criada com ID: %', v_nome_marca, v_marca_id;
    END IF;
END $$;

-- Verificar a marca criada
SELECT id, nome, slug, is_premium
FROM lens_catalog.marcas
WHERE nome = 'NOME_DA_MARCA';  -- <-- ALTERE AQUI

-- ============================================================================
-- PARTE 3: TEMPLATE DO CSV (ESTRUTURA REAL DA TABELA)
-- ============================================================================
-- O CSV deve ter as seguintes colunas baseado na estrutura REAL:
--
-- OBRIGATÓRIAS (NOT NULL):
-- ------------------------
-- nome_lente              - Nome da lente (TEXT) - CAMPO PRINCIPAL!
-- fornecedor_id           - UUID do fornecedor (será preenchido no INSERT)
-- tipo_lente              - visao_simples | multifocal | bifocal
-- material                - CR39 | POLICARBONATO | HIGH_INDEX
-- indice_refracao         - 1.50 | 1.56 | 1.59 | 1.61 | 1.67 | 1.74
-- categoria               - economica | intermediaria | premium
-- preco_custo             - Custo de compra (NUMERIC) - OBRIGATÓRIO!
--                           O preco_venda_sugerido é calculado automaticamente
--
-- CAMPOS DE GRAU (importantes para canonização):
-- ----------------------------------------------
-- grau_esferico_min       - Ex: -6.00 (usar este, não esferico_min)
-- grau_esferico_max       - Ex: 6.00
-- grau_cilindrico_min     - Ex: -2.00
-- grau_cilindrico_max     - Ex: 0.00
-- adicao_min              - Para multifocais (Ex: 0.75)
-- adicao_max              - Para multifocais (Ex: 3.50)
--
-- TRATAMENTOS (usados na canonização):
-- ------------------------------------
-- tratamento_antirreflexo   - true | false (default: false)
-- tratamento_antirrisco     - true | false (default: false)
-- tratamento_uv             - true | false (default: false)
-- tratamento_blue_light     - true | false (default: false)
-- tratamento_fotossensiveis - nenhum | fotocromático (ENUM lens_catalog.tratamento_foto)
--
-- OPCIONAIS:
-- ----------
-- marca_id                - UUID da marca (pode ser NULL)
-- sku                     - SKU interno
-- codigo_fornecedor       - Código do fornecedor
-- fotossensivel           - nenhum | transitions | fotocromático | acclimates | polarizado (TEXT)
-- ar, blue, uv400, polarizado - Campos legados (boolean)
--
-- ============================================================================
-- VALORES VÁLIDOS DOS ENUMS (baseado no banco atual):
-- ============================================================================
-- tipo_lente:      visao_simples (479), multifocal (966), bifocal (2)
-- material:        CR39 (1076), POLICARBONATO (365), HIGH_INDEX (6)
-- indice_refracao: 1.50 (337), 1.56 (199), 1.59 (369), 1.61 (24), 1.67 (288), 1.74 (230)
-- categoria:       economica (458), intermediaria (988), premium (1)
-- fotossensivel:   nenhum (1054), transitions (249), fotocromático (81), polarizado (60), acclimates (3)
--
-- ============================================================================
-- EXEMPLO DE LINHA DO CSV:
-- ============================================================================
-- nome_lente,tipo_lente,material,indice_refracao,categoria,preco_custo,grau_esferico_min,grau_esferico_max,grau_cilindrico_min,grau_cilindrico_max,tratamento_antirreflexo,tratamento_blue_light,fotossensivel
-- "Lente CR39 1.56 AR+UV",visao_simples,CR39,1.56,intermediaria,50.00,-6.00,6.00,-2.00,0.00,true,false,nenhum

-- ============================================================================
-- PARTE 4: IMPORTAR LENTES DO CSV
-- ============================================================================
-- Substitua 'FORNECEDOR_ID' e 'MARCA_ID' pelos IDs reais obtidos acima

-- Método A: Via tabela temporária (RECOMENDADO)
-- ---------------------------------------------

-- 1. Criar tabela temporária para staging (estrutura correta!)
CREATE TEMP TABLE IF NOT EXISTS temp_lentes_import (
    nome_lente TEXT NOT NULL,
    tipo_lente TEXT NOT NULL,
    material TEXT NOT NULL,
    indice_refracao TEXT NOT NULL,
    categoria TEXT NOT NULL,
    preco_custo NUMERIC NOT NULL,
    grau_esferico_min NUMERIC,
    grau_esferico_max NUMERIC,
    grau_cilindrico_min NUMERIC,
    grau_cilindrico_max NUMERIC,
    adicao_min NUMERIC,
    adicao_max NUMERIC,
    tratamento_antirreflexo BOOLEAN DEFAULT false,
    tratamento_antirrisco BOOLEAN DEFAULT false,
    tratamento_uv BOOLEAN DEFAULT false,
    tratamento_blue_light BOOLEAN DEFAULT false,
    fotossensivel TEXT DEFAULT 'nenhum',
    sku TEXT,
    codigo_fornecedor TEXT
);

-- 2. Importar CSV para tabela temporária
-- \copy temp_lentes_import FROM '/caminho/para/arquivo.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- 3. Inserir na tabela definitiva com IDs do fornecedor e marca
-- NOTA: preco_venda_sugerido é calculado AUTOMATICAMENTE pela trigger!
-- NOTA: grupo_canonico_id é atribuído AUTOMATICAMENTE pela trigger!
/*
INSERT INTO lens_catalog.lentes (
    -- Campos obrigatórios
    nome_lente,
    fornecedor_id,
    marca_id,
    tipo_lente,
    material,
    indice_refracao,
    categoria,
    preco_custo,
    -- Campos de grau
    grau_esferico_min,
    grau_esferico_max,
    grau_cilindrico_min,
    grau_cilindrico_max,
    adicao_min,
    adicao_max,
    -- Tratamentos (usados na canonização)
    tratamento_antirreflexo,
    tratamento_antirrisco,
    tratamento_uv,
    tratamento_blue_light,
    tratamento_fotossensiveis,
    -- Campos legados (opcional)
    fotossensivel,
    ar,
    blue,
    uv400,
    -- Identificadores
    sku,
    codigo_fornecedor,
    -- Status
    status,
    ativo
)
SELECT
    nome_lente,
    'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'::UUID,  -- <-- ALTERE: ID do fornecedor
    'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'::UUID,  -- <-- ALTERE: ID da marca (ou NULL)
    tipo_lente::lens_catalog.tipo_lente,
    material::lens_catalog.material_lente,
    indice_refracao::lens_catalog.indice_refracao,
    categoria::lens_catalog.categoria_lente,
    preco_custo,
    -- Graus
    grau_esferico_min,
    grau_esferico_max,
    grau_cilindrico_min,
    grau_cilindrico_max,
    adicao_min,
    adicao_max,
    -- Tratamentos
    tratamento_antirreflexo,
    tratamento_antirrisco,
    tratamento_uv,
    tratamento_blue_light,
    CASE
        WHEN fotossensivel IN ('transitions', 'fotocromático', 'acclimates') THEN 'fotocromático'::lens_catalog.tratamento_foto
        ELSE 'nenhum'::lens_catalog.tratamento_foto
    END,
    -- Campos legados
    fotossensivel,
    tratamento_antirreflexo,  -- ar = tratamento_antirreflexo
    tratamento_blue_light,     -- blue = tratamento_blue_light
    tratamento_uv,             -- uv400 = tratamento_uv
    -- Identificadores
    COALESCE(sku, 'LVN-' || UPPER(SUBSTRING(md5(random()::text) FROM 1 FOR 8))),
    codigo_fornecedor,
    -- Status
    'ativo'::lens_catalog.status_lente,
    true
FROM temp_lentes_import;
*/

-- 4. Limpar tabela temporária
-- DROP TABLE IF EXISTS temp_lentes_import;

-- ============================================================================
-- PARTE 5: VERIFICAÇÃO PÓS-IMPORTAÇÃO
-- ============================================================================

-- Verificar lentes importadas
\echo ''
\echo '============================================'
\echo 'VERIFICAÇÃO PÓS-IMPORTAÇÃO'
\echo '============================================'

-- Total por fornecedor
SELECT
    f.nome as fornecedor,
    COUNT(l.id) as total_lentes,
    ROUND(MIN(l.preco_tabela), 2) as preco_min,
    ROUND(MAX(l.preco_tabela), 2) as preco_max,
    ROUND(AVG(l.preco_tabela), 2) as preco_medio
FROM core.fornecedores f
LEFT JOIN lens_catalog.lentes l ON l.fornecedor_id = f.id AND l.status = 'ativo'
GROUP BY f.id, f.nome
ORDER BY total_lentes DESC;

-- Verificar se trigger de canonização funcionou
SELECT
    COUNT(*) as total_lentes,
    COUNT(grupo_canonico_id) as com_grupo,
    COUNT(lente_canonica_id) as canonica_generica,
    COUNT(premium_canonica_id) as canonica_premium,
    COUNT(*) - COUNT(grupo_canonico_id) - COUNT(lente_canonica_id) - COUNT(premium_canonica_id) as orfas
FROM lens_catalog.lentes
WHERE status = 'ativo';

-- Distribuição por tipo
SELECT
    tipo_lente,
    COUNT(*) as total
FROM lens_catalog.lentes
WHERE status = 'ativo'
  -- AND fornecedor_id = 'ID_DO_NOVO_FORNECEDOR'  -- <-- Descomente e altere para filtrar
GROUP BY tipo_lente
ORDER BY total DESC;

-- Distribuição por material
SELECT
    material,
    COUNT(*) as total
FROM lens_catalog.lentes
WHERE status = 'ativo'
  -- AND fornecedor_id = 'ID_DO_NOVO_FORNECEDOR'  -- <-- Descomente e altere para filtrar
GROUP BY material
ORDER BY total DESC;

-- ============================================================================
-- PARTE 6: RE-CANONIZAÇÃO (SE NECESSÁRIO)
-- ============================================================================
-- Se as triggers não funcionaram corretamente, forçar re-canonização

/*
-- Forçar re-processamento das lentes importadas
UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE fornecedor_id = 'ID_DO_NOVO_FORNECEDOR'  -- <-- ALTERE
  AND status = 'ativo'
  AND grupo_canonico_id IS NULL
  AND lente_canonica_id IS NULL
  AND premium_canonica_id IS NULL;
*/

-- ============================================================================
-- PRONTO! LENTES IMPORTADAS COM SUCESSO
-- ============================================================================
