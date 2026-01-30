-- ============================================================================
-- DIAGNÓSTICO COMPLETO PARA IMPORTAÇÃO DE LENTES VIA CSV
-- ============================================================================
-- Execute este arquivo ANTES de importar novas lentes de um novo laboratório
-- Ele vai verificar:
-- 1. Estado atual do banco
-- 2. Triggers ativos
-- 3. Fornecedores/Marcas existentes
-- 4. Valores válidos para ENUMS
-- 5. Estrutura esperada do CSV
-- ============================================================================

-- ============================================================================
-- PARTE 1: ESTADO ATUAL DO BANCO
-- ============================================================================

\echo '============================================'
\echo '1. CONTAGEM GERAL DO BANCO'
\echo '============================================'

SELECT
    'Lentes Ativas' as metrica,
    COUNT(*) as valor
FROM lens_catalog.lentes
WHERE status = 'ativo'
UNION ALL
SELECT
    'Lentes Inativas',
    COUNT(*)
FROM lens_catalog.lentes
WHERE status != 'ativo'
UNION ALL
SELECT
    'Fornecedores Ativos',
    COUNT(*)
FROM core.fornecedores
WHERE ativo = true
UNION ALL
SELECT
    'Marcas Ativas',
    COUNT(*)
FROM lens_catalog.marcas
WHERE ativo = true
UNION ALL
SELECT
    'Grupos Canônicos',
    COUNT(*)
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;


| metrica             | valor |
| ------------------- | ----- |
| Lentes Ativas       | 1447  |
| Lentes Inativas     | 0     |
| Fornecedores Ativos | 22    |
| Marcas Ativas       | 18    |
| Grupos Canônicos    | 239   | isso é feito automatico, nçao criamos nada, é trigger e function, igual ao preço de venda, sempre baseia-se no custo x o markup definido automatico

-- ============================================================================
-- PARTE 2: FORNECEDORES (LABORATÓRIOS) EXISTENTES
-- ============================================================================

\echo ''
\echo '============================================'
\echo '2. FORNECEDORES/LABORATÓRIOS CADASTRADOS'
\echo '============================================'

SELECT
    id,
    nome,
    razao_social,
    prazo_visao_simples as lead_time,
    ativo
FROM core.fornecedores
ORDER BY nome;

| id                                   | nome                          | razao_social                                           | lead_time | ativo |
| ------------------------------------ | ----------------------------- | ------------------------------------------------------ | --------- | ----- |
| 7534efcc-3412-488c-abb4-d6acd670d8ec | Alcon Laboratorios do Brasil  | Alcon Laboratorios do Brasil LTDA                      | 3         | true  |
| f0c192cd-1ba8-459b-a82e-b3ff049644d9 | Alcon Laboratorios do Brasil  | Alcon Laboratorios do Brasil LTDA                      | 3         | true  |
| 14ddf79c-224a-4027-8ec9-886f17ad2820 | Bausch & Lomb Brasil          | Bausch & Lomb do Brasil LTDA                           | 5         | true  |
| a725651f-79ee-4558-8f69-dc8b066b3319 | Bausch & Lomb Brasil          | Bausch & Lomb do Brasil LTDA                           | 5         | true  |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Brascor                       | Brascor Distribuidora de Lentes                        | 7         | true  |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | Braslentes                    | Champ Brasil Comercio LTDA                             | 10        | true  |
| 89c13390-fd7b-401b-9f5d-7a9c2ee87366 | CooperVision Brasil           | CooperVision do Brasil Produtos Oftalmicos LTDA        | 5         | true  |
| 9400f665-2f93-47ba-97c5-2a2248236e6a | CooperVision Brasil           | CooperVision do Brasil Produtos Oftalmicos LTDA        | 5         | true  |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express                       | Lentes e Cia Express LTDA                              | 3         | true  |
| e4a24408-3d58-4fc7-a096-cf7140f4f248 | Galeria Florencio lj11        | Galeria Florêncio Comércio de Óptica LTDA              | 7         | true  |
| 4bc166bb-e576-483f-aec1-94c95c5bc68f | Johnson & Johnson Vision Care | Johnson & Johnson do Brasil Industria e Comercio LTDA  | 3         | true  |
| 4b2d639c-1895-4c17-8a6f-442dc8a8d046 | Johnson & Johnson Vision Care | Johnson & Johnson do Brasil Industria e Comercio LTDA  | 3         | true  |
| d90bebaf-e552-4cf0-a226-808c91bda73a | Kaizi Oculos Solares          | Kaizi Importação e Exportação LTDA                     | 7         | true  |
| b01bd4fe-a383-4006-b4ec-1d397ba2c0c1 | Lentenet                      | Lentenet Distribuidora de Produtos Oftalmologicos LTDA | 5         | true  |
| c50ea6eb-a420-4cf7-8aa2-68aaeb41ac95 | Navarro Oculos                | Navarro Distribuidora de Óculos LTDA                   | 7         | true  |
| 4f4dc190-4e26-4352-a7e9-a748880d9365 | Newlens                       | Newlens Distribuidora de Lentes de Contato LTDA        | 5         | true  |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Polylux                       | Polylux Comercio de Produtos Opticos LTDA              | 7         | true  |
| 1d0b088f-dcb1-4179-9a18-5d67ce86c4b6 | Sao Paulo Acessorios          | São Paulo Acessórios LTDA                              | 7         | true  |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | So Blocos                     | S blocos Comercio e Servios Oticos LTDA                | 7         | true  |
| f8b6d0f7-42b5-46ff-b216-ad717ce0e8bb | Solotica                      | Solotica Lentes de Contato LTDA                        | 7         | true  |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | Style                         | Style Primer Lentes Oftalmicas e Armaes                | 7         | true  |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Sygma                         | Sygma Lentes Laboratório Óptico                        | 7         | true  |



-- Contagem de lentes por fornecedor
\echo ''
\echo 'LENTES POR FORNECEDOR:'
SELECT
    f.nome as fornecedor,
    COUNT(l.id) as total_lentes,
    COUNT(CASE WHEN l.status = 'ativo' THEN 1 END) as ativas,
    COUNT(CASE WHEN l.status != 'ativo' THEN 1 END) as inativas
FROM core.fornecedores f
LEFT JOIN lens_catalog.lentes l ON l.fornecedor_id = f.id
GROUP BY f.id, f.nome
ORDER BY total_lentes DESC;

| fornecedor                    | total_lentes | ativas | inativas |
| ----------------------------- | ------------ | ------ | -------- |
| So Blocos                     | 1097         | 1097   | 0        |
| Polylux                       | 158          | 158    | 0        |
| Express                       | 84           | 84     | 0        |
| Brascor                       | 58           | 58     | 0        |
| Braslentes                    | 36           | 36     | 0        |
| Sygma                         | 14           | 14     | 0        |
| Kaizi Oculos Solares          | 0            | 0      | 0        |
| CooperVision Brasil           | 0            | 0      | 0        |
| Galeria Florencio lj11        | 0            | 0      | 0        |
| Bausch & Lomb Brasil          | 0            | 0      | 0        |
| Alcon Laboratorios do Brasil  | 0            | 0      | 0        |
| Style                         | 0            | 0      | 0        |
| Sao Paulo Acessorios          | 0            | 0      | 0        |
| CooperVision Brasil           | 0            | 0      | 0        |
| Bausch & Lomb Brasil          | 0            | 0      | 0        |
| Newlens                       | 0            | 0      | 0        |
| Solotica                      | 0            | 0      | 0        |
| Navarro Oculos                | 0            | 0      | 0        |
| Johnson & Johnson Vision Care | 0            | 0      | 0        |
| Alcon Laboratorios do Brasil  | 0            | 0      | 0        |
| Johnson & Johnson Vision Care | 0            | 0      | 0        |
| Lentenet                      | 0            | 0      | 0        |


temos laboratorios duplicados, já temos que tirar do banco
-- ============================================================================
-- PARTE 3: MARCAS EXISTENTES
-- ============================================================================

\echo ''
\echo '============================================'
\echo '3. MARCAS CADASTRADAS'
\echo '============================================'

SELECT
    id,
    nome,
    slug,
    is_premium,
    ativo
FROM lens_catalog.marcas
ORDER BY is_premium DESC, nome;


| id                                   | nome        | slug        | is_premium | ativo |
| ------------------------------------ | ----------- | ----------- | ---------- | ----- |
| 2aa44ead-9d18-4004-9702-8feffabad94a | ACCLIMATES  | acclimates  | true       | true  |
| befba165-0aa0-496f-bfdf-774bfe94a856 | CRIZAL      | crizal      | true       | true  |
| bbe5a62d-1d7d-4d93-87af-0dbde68c0645 | ESSILOR     | essilor     | true       | true  |
| 852e5fb8-8eae-4805-a5cb-a5a1e8638f5c | HOYA        | hoya        | true       | true  |
| a6091278-c827-40ea-a2fb-dcc26f1c8d20 | KODAK       | kodak       | true       | true  |
| 6c37f0a1-487c-4bb1-a065-c9498172cbfe | LENSCOPE    | lenscope    | true       | true  |
| d92921ad-1b9d-4f5f-93e1-3e75e4375f09 | RODENSTOCK  | rodenstock  | true       | true  |
| 3f8ac428-2224-415e-8a20-c9e6879754d3 | TRANSITIONS | transitions | true       | true  |
| 3f70213e-0b45-4f42-907a-28f7e7ac51c0 | VARILUX     | varilux     | true       | true  |
| a8ee9f1e-53d9-41ed-bc68-9c4a9881e828 | ZEISS       | zeiss       | true       | true  |
| 98deae91-ee66-4c32-8a5d-8a6f83681993 | BRASCOR     | brascor     | false      | true  |
| d53785a4-37a2-48d1-b807-d172a31417ff | BRASLENTES  | braslentes  | false      | true  |
| 7bf35e08-7a88-4547-a06a-a6ce62fcc827 | EXPRESS     | express     | false      | true  |
| 7f1aa237-edaf-4376-8b91-6c93c3c079a4 | GENÉRICA    | generica    | false      | true  |
| e7ef4c94-a80a-492f-9195-24e6ab2f5056 | POLYLUX     | polylux     | false      | true  |
| 4af04ba6-e600-4874-b8dc-45a2e1773725 | SO BLOCOS   | so-blocos   | false      | true  |
| 731a86d5-2d61-42ca-9533-1af470184bad | STYLE       | style       | false      | true  |
| 57fc0111-0a99-4642-8b66-f1d87a79afce | SYGMA       | sygma       | false      | true  |


-- Contagem de lentes por marca
\echo ''
\echo 'LENTES POR MARCA:'
SELECT
    m.nome as marca,
    m.is_premium,
    COUNT(l.id) as total_lentes
FROM lens_catalog.marcas m
LEFT JOIN lens_catalog.lentes l ON l.marca_id = m.id AND l.status = 'ativo'
GROUP BY m.id, m.nome, m.is_premium
ORDER BY total_lentes DESC;


| marca       | is_premium | total_lentes |
| ----------- | ---------- | ------------ |
| SO BLOCOS   | false      | 880          |
| TRANSITIONS | true       | 234          |
| POLYLUX     | false      | 132          |
| BRASCOR     | false      | 56           |
| EXPRESS     | false      | 50           |
| SYGMA       | false      | 38           |
| BRASLENTES  | false      | 36           |
| VARILUX     | true       | 11           |
| GENÉRICA    | false      | 7            |
| ESSILOR     | true       | 3            |
| CRIZAL      | true       | 0            |
| ACCLIMATES  | true       | 0            |
| HOYA        | true       | 0            |
| LENSCOPE    | true       | 0            |
| KODAK       | true       | 0            |
| STYLE       | false      | 0            |
| RODENSTOCK  | true       | 0            |
| ZEISS       | true       | 0            |

-- ============================================================================
-- PARTE 4: VALORES VÁLIDOS PARA ENUMS
-- ============================================================================

\echo ''
\echo '============================================'
\echo '4. VALORES VÁLIDOS PARA CAMPOS ENUM'
\echo '============================================'

-- Tipos de lente usados
\echo ''
\echo 'TIPOS DE LENTE (tipo_lente):'
SELECT DISTINCT tipo_lente, COUNT(*) as qtd
FROM lens_catalog.lentes
WHERE status = 'ativo'
GROUP BY tipo_lente
ORDER BY tipo_lente;

| tipo_lente    | qtd |
| ------------- | --- |
| visao_simples | 479 |
| multifocal    | 966 |
| bifocal       | 2   |


-- Materiais usados
\echo ''
\echo 'MATERIAIS (material):'
SELECT DISTINCT material, COUNT(*) as qtd
FROM lens_catalog.lentes
WHERE status = 'ativo'
GROUP BY material
ORDER BY material;


| material      | qtd  |
| ------------- | ---- |
| CR39          | 1076 |
| POLICARBONATO | 365  |
| HIGH_INDEX    | 6    |


-- Índices de refração usados
\echo ''
\echo 'ÍNDICES DE REFRAÇÃO (indice_refracao):'
SELECT DISTINCT indice_refracao, COUNT(*) as qtd
FROM lens_catalog.lentes
WHERE status = 'ativo'
GROUP BY indice_refracao
ORDER BY indice_refracao;


| indice_refracao | qtd |
| --------------- | --- |
| 1.50            | 337 |
| 1.56            | 199 |
| 1.59            | 369 |
| 1.61            | 24  |
| 1.67            | 288 |
| 1.74            | 230 |


-- Categorias usadas
\echo ''
\echo 'CATEGORIAS (categoria):'
SELECT DISTINCT categoria, COUNT(*) as qtd
FROM lens_catalog.lentes
WHERE status = 'ativo'
GROUP BY categoria
ORDER BY categoria;


| categoria     | qtd |
| ------------- | --- |
| economica     | 458 |
| intermediaria | 988 |
| premium       | 1   |


-- Fotossensível valores
\echo ''
\echo 'FOTOSSENSÍVEL (fotossensivel):'
SELECT DISTINCT fotossensivel, COUNT(*) as qtd
FROM lens_catalog.lentes
WHERE status = 'ativo'
GROUP BY fotossensivel
ORDER BY fotossensivel;


| fotossensivel | qtd  |
| ------------- | ---- |
| acclimates    | 3    |
| fotocromático | 81   |
| nenhum        | 1054 |
| polarizado    | 60   |
| transitions   | 249  |


-- ============================================================================
-- PARTE 5: VERIFICAR TRIGGERS ATIVOS
-- ============================================================================

\echo ''
\echo '============================================'
\echo '5. TRIGGERS ATIVOS NA TABELA LENTES'
\echo '============================================'

SELECT
    tgname as nome_trigger,
    CASE tgenabled
        WHEN 'O' THEN 'ATIVO (Origin)'
        WHEN 'D' THEN 'DESATIVADO'
        WHEN 'R' THEN 'ATIVO (Replica)'
        WHEN 'A' THEN 'ATIVO (Always)'
        ELSE tgenabled::text
    END as status,
    pg_get_triggerdef(oid, true) as definicao
FROM pg_trigger
WHERE tgrelid = 'lens_catalog.lentes'::regclass
  AND NOT tgisinternal
ORDER BY tgname;


| nome_trigger             | status         | definicao                                                                                                                                                                  |
| ------------------------ | -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| trg_calcular_preco_venda | ATIVO (Origin) | CREATE TRIGGER trg_calcular_preco_venda BEFORE INSERT OR UPDATE OF preco_custo ON lens_catalog.lentes FOR EACH ROW EXECUTE FUNCTION lens_catalog.fn_calcular_preco_venda() |
| trg_lente_delete         | ATIVO (Origin) | CREATE TRIGGER trg_lente_delete AFTER DELETE ON lens_catalog.lentes FOR EACH ROW EXECUTE FUNCTION lens_catalog.trigger_deletar_lente_atualizar_grupo()                     |
| trg_lente_insert_update  | ATIVO (Origin) | CREATE TRIGGER trg_lente_insert_update BEFORE INSERT OR UPDATE ON lens_catalog.lentes FOR EACH ROW EXECUTE FUNCTION lens_catalog.trigger_atualizar_grupo_canonico()        |
| trg_lentes_generate_slug | ATIVO (Origin) | CREATE TRIGGER trg_lentes_generate_slug BEFORE INSERT OR UPDATE ON lens_catalog.lentes FOR EACH ROW EXECUTE FUNCTION lens_catalog.generate_lente_slug()                    |
| trg_lentes_updated_at    | ATIVO (Origin) | CREATE TRIGGER trg_lentes_updated_at BEFORE UPDATE ON lens_catalog.lentes FOR EACH ROW EXECUTE FUNCTION lens_catalog.update_lentes_timestamp()                             |



-- ============================================================================
-- PARTE 6: VERIFICAR FUNÇÕES DE CANONIZAÇÃO
-- ============================================================================

\echo ''
\echo '============================================'
\echo '6. FUNÇÕES DE CANONIZAÇÃO'
\echo '============================================'

SELECT
    p.proname as funcao,
    pg_get_function_arguments(p.oid) as argumentos,
    CASE
        WHEN p.prosrc LIKE '%grupos_canonicos%' THEN 'USA grupos_canonicos'
        WHEN p.prosrc LIKE '%lentes_canonicas%' THEN 'USA lentes_canonicas'
        WHEN p.prosrc LIKE '%premium_canonicas%' THEN 'USA premium_canonicas'
        ELSE 'OUTRO'
    END as tipo_canonizacao
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'lens_catalog'
  AND (p.proname LIKE '%canon%' OR p.proname LIKE '%trigger%' OR p.proname LIKE '%vincular%')
ORDER BY p.proname;


| funcao                                | argumentos                                                                                                                                                                                                                                                                                                                                                                                                                                                            | tipo_canonizacao     |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| atualizar_estatisticas_grupo_canonico | p_grupo_id uuid                                                                                                                                                                                                                                                                                                                                                                                                                                                       | USA grupos_canonicos |
| encontrar_ou_criar_grupo_canonico     | p_tipo_lente lens_catalog.tipo_lente, p_material lens_catalog.material_lente, p_indice lens_catalog.indice_refracao, p_categoria lens_catalog.categoria_lente, p_esferico_min numeric, p_esferico_max numeric, p_cilindrico_min numeric, p_cilindrico_max numeric, p_adicao_min numeric, p_adicao_max numeric, p_tem_ar boolean, p_tem_antirrisco boolean, p_tem_uv boolean, p_tem_blue boolean, p_tratamento_foto lens_catalog.tratamento_foto                       | USA grupos_canonicos |
| encontrar_ou_criar_grupo_canonico     | p_tipo_lente lens_catalog.tipo_lente, p_material lens_catalog.material_lente, p_indice lens_catalog.indice_refracao, p_categoria lens_catalog.categoria_lente, p_esferico_min numeric, p_esferico_max numeric, p_cilindrico_min numeric, p_cilindrico_max numeric, p_adicao_min numeric, p_adicao_max numeric, p_tem_ar boolean, p_tem_antirrisco boolean, p_tem_uv boolean, p_tem_blue boolean, p_tratamento_foto lens_catalog.tratamento_foto, p_is_premium boolean | USA grupos_canonicos |
| fn_criar_grupo_canonico_automatico    | p_tipo_lente text, p_material text, p_indice_refracao text, p_grau_esferico_min numeric, p_grau_esferico_max numeric, p_grau_cilindrico_min numeric, p_grau_cilindrico_max numeric, p_adicao_min numeric DEFAULT NULL::numeric, p_adicao_max numeric DEFAULT NULL::numeric                                                                                                                                                                                            | USA grupos_canonicos |
| trigger_atualizar_grupo_canonico      |                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | OUTRO                |
| trigger_deletar_lente_atualizar_grupo |                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | OUTRO                |
| update_canonicas_timestamp            |                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | OUTRO                |


-- ============================================================================
-- PARTE 7: ESTRUTURA DA TABELA LENTES
-- ============================================================================

\echo ''
\echo '============================================'
\echo '7. COLUNAS DA TABELA lens_catalog.lentes'
\echo '============================================'

SELECT
    column_name as coluna,
    data_type as tipo,
    is_nullable as permite_nulo,
    column_default as valor_padrao
FROM information_schema.columns
WHERE table_schema = 'lens_catalog'
  AND table_name = 'lentes'
ORDER BY ordinal_position;


| coluna                    | tipo                     | permite_nulo | valor_padrao                           |
| ------------------------- | ------------------------ | ------------ | -------------------------------------- |
| id                        | uuid                     | NO           | gen_random_uuid()                      |
| fornecedor_id             | uuid                     | NO           | null                                   |
| marca_id                  | uuid                     | YES          | null                                   |
| grupo_canonico_id         | uuid                     | YES          | null                                   |
| nome_lente                | text                     | NO           | null                                   |
| nome_canonizado           | text                     | YES          | null                                   |
| slug                      | text                     | YES          | null                                   |
| sku                       | character varying        | YES          | null                                   |
| codigo_fornecedor         | character varying        | YES          | null                                   |
| tipo_lente                | USER-DEFINED             | NO           | null                                   |
| material                  | USER-DEFINED             | NO           | null                                   |
| indice_refracao           | USER-DEFINED             | NO           | null                                   |
| categoria                 | USER-DEFINED             | NO           | null                                   |
| tratamento_antirreflexo   | boolean                  | NO           | false                                  |
| tratamento_antirrisco     | boolean                  | NO           | false                                  |
| tratamento_uv             | boolean                  | NO           | false                                  |
| tratamento_blue_light     | boolean                  | NO           | false                                  |
| tratamento_fotossensiveis | USER-DEFINED             | YES          | 'nenhum'::lens_catalog.tratamento_foto |
| diametro_mm               | integer                  | YES          | null                                   |
| curva_base                | numeric                  | YES          | null                                   |
| espessura_centro_mm       | numeric                  | YES          | null                                   |
| eixo_optico               | character varying        | YES          | null                                   |
| grau_esferico_min         | numeric                  | YES          | null                                   |
| grau_esferico_max         | numeric                  | YES          | null                                   |
| grau_cilindrico_min       | numeric                  | YES          | null                                   |
| grau_cilindrico_max       | numeric                  | YES          | null                                   |
| adicao_min                | numeric                  | YES          | null                                   |
| adicao_max                | numeric                  | YES          | null                                   |
| preco_custo               | numeric                  | NO           | 0                                      |
| preco_venda_sugerido      | numeric                  | NO           | 0                                      |
| margem_lucro              | numeric                  | YES          | null                                   |
| estoque_disponivel        | integer                  | YES          | 0                                      |
| estoque_minimo            | integer                  | YES          | 0                                      |
| lead_time_dias            | integer                  | YES          | null                                   |
| status                    | USER-DEFINED             | NO           | 'ativo'::lens_catalog.status_lente     |
| ativo                     | boolean                  | NO           | true                                   |
| peso                      | integer                  | YES          | 50                                     |
| metadata                  | jsonb                    | YES          | '{}'::jsonb                            |
| created_at                | timestamp with time zone | NO           | now()                                  |
| updated_at                | timestamp with time zone | NO           | now()                                  |
| deleted_at                | timestamp with time zone | YES          | null                                   |
| sku_fornecedor            | character varying        | YES          | null                                   |
| codigo_original           | character varying        | YES          | null                                   |
| nome_comercial            | text                     | YES          | null                                   |
| descricao_curta           | text                     | YES          | null                                   |
| linha_produto             | character varying        | YES          | null                                   |
| custo_base                | numeric                  | YES          | 0                                      |
| preco_tabela              | numeric                  | YES          | 0                                      |
| preco_fabricante          | numeric                  | YES          | null                                   |
| esferico_min              | numeric                  | YES          | null                                   |
| esferico_max              | numeric                  | YES          | null                                   |
| cilindrico_min            | numeric                  | YES          | null                                   |
| cilindrico_max            | numeric                  | YES          | null                                   |
| dnp_min                   | integer                  | YES          | null                                   |
| dnp_max                   | integer                  | YES          | null                                   |
| prazo_entrega             | integer                  | YES          | 7                                      |
| obs_prazo                 | text                     | YES          | null                                   |
| peso_frete                | numeric                  | YES          | 50.0                                   |
| exige_receita_especial    | boolean                  | YES          | false                                  |
| disponivel                | boolean                  | YES          | true                                   |
| diametro                  | integer                  | YES          | null                                   |
| espessura_central         | numeric                  | YES          | null                                   |
| peso_aproximado           | numeric                  | YES          | null                                   |
| ar                        | boolean                  | YES          | false                                  |
| antirrisco                | boolean                  | YES          | false                                  |
| hidrofobico               | boolean                  | YES          | false                                  |
| antiembaçante             | boolean                  | YES          | false                                  |
| blue                      | boolean                  | YES          | false                                  |
| uv400                     | boolean                  | YES          | false                                  |
| polarizado                | boolean                  | YES          | false                                  |
| digital                   | boolean                  | YES          | false                                  |
| free_form                 | boolean                  | YES          | false                                  |
| indoor                    | boolean                  | YES          | false                                  |
| drive                     | boolean                  | YES          | false                                  |
| fotossensivel             | text                     | YES          | 'nenhum'::text                         |
| destaque                  | boolean                  | YES          | false                                  |
| novidade                  | boolean                  | YES          | false                                  |
| data_lancamento           | date                     | YES          | null                                   |
| data_descontinuacao       | date                     | YES          | null                                   |
| descricao_completa        | text                     | YES          | null                                   |
| contraindicacoes          | text                     | YES          | null                                   |
| observacoes               | text                     | YES          | null                                   |
| beneficios                | ARRAY                    | YES          | null                                   |
| indicacoes                | ARRAY                    | YES          | null                                   |


-- ============================================================================
-- PARTE 8: VERIFICAR LENTES SEM GRUPO CANÔNICO
-- ============================================================================

\echo ''
\echo '============================================'
\echo '8. LENTES SEM GRUPO CANÔNICO (ÓRFÃS)'
\echo '============================================'

SELECT
    COUNT(*) as lentes_orfas,
    CASE
        WHEN COUNT(*) = 0 THEN '✅ OK - Todas as lentes estão canonizadas'
        ELSE '⚠️ ATENÇÃO - Existem lentes sem grupo canônico!'
    END as status
FROM lens_catalog.lentes
WHERE status = 'ativo'
  AND grupo_canonico_id IS NULL;



| lentes_orfas | status                                   |
| ------------ | ---------------------------------------- |
| 0            | ✅ OK - Todas as lentes estão canonizadas |

  


-- Listar as órfãs se existirem
SELECT
    id,
    nome_comercial,
    tipo_lente,
    material,
    fornecedor_id
FROM lens_catalog.lentes
WHERE status = 'ativo'
  AND grupo_canonico_id IS NULL
  AND lente_canonica_id IS NULL
  AND premium_canonica_id IS NULL
LIMIT 10;

-- ============================================================================
-- PARTE 9: ESTATÍSTICAS DE GRUPOS CANÔNICOS
-- ============================================================================

\echo ''
\echo '============================================'
\echo '9. ESTATÍSTICAS DOS GRUPOS CANÔNICOS'
\echo '============================================'

SELECT
    COUNT(*) as total_grupos,
    COUNT(CASE WHEN is_premium = true THEN 1 END) as grupos_premium,
    COUNT(CASE WHEN is_premium = false THEN 1 END) as grupos_standard,
    SUM(total_lentes) as lentes_agrupadas,
    ROUND(AVG(total_lentes), 2) as media_lentes_por_grupo
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;

| total_grupos | grupos_premium | grupos_standard | lentes_agrupadas | media_lentes_por_grupo |
| ------------ | -------------- | --------------- | ---------------- | ---------------------- |
| 239          | 42             | 197             | 978              | 4.09                   |

-- Por tipo de lente
\echo ''
\echo 'GRUPOS POR TIPO DE LENTE:'
SELECT
    tipo_lente,
    COUNT(*) as grupos,
    SUM(total_lentes) as lentes
FROM lens_catalog.grupos_canonicos
WHERE ativo = true
GROUP BY tipo_lente
ORDER BY grupos DESC;


| tipo_lente    | grupos | lentes |
| ------------- | ------ | ------ |
| multifocal    | 167    | 734    |
| visao_simples | 71     | 243    |
| bifocal       | 1      | 1      |

-- ============================================================================
-- PARTE 10: TEMPLATE DO CSV PARA IMPORTAÇÃO
-- ============================================================================

\echo ''
\echo '============================================'
\echo '10. ESTRUTURA ESPERADA DO CSV'
\echo '============================================'
\echo ''
\echo 'CAMPOS OBRIGATÓRIOS:'
\echo '  - id (UUID) ou deixar vazio para gerar automaticamente'
\echo '  - nome_comercial (TEXT) - Nome da lente'
\echo '  - tipo_lente (ENUM) - visao_simples, multifocal, bifocal, ocupacional'
\echo '  - material (ENUM) - CR39, POLICARBONATO, TRIVEX, etc.'
\echo '  - indice_refracao (ENUM) - 1.49, 1.56, 1.59, 1.61, 1.67, 1.74'
\echo '  - categoria (ENUM) - economica, intermediaria, premium'
\echo '  - marca_id (UUID) - ID da marca existente'
\echo '  - fornecedor_id (UUID) - ID do fornecedor/laboratório'
\echo '  - esferico_min (NUMERIC) - Ex: -6.00'
\echo '  - esferico_max (NUMERIC) - Ex: 6.00'
\echo '  - cilindrico_min (NUMERIC) - Ex: -2.00'
\echo '  - cilindrico_max (NUMERIC) - Ex: 0.00'
\echo '  - preco_tabela (NUMERIC) - Preço de venda'
\echo '  - status (TEXT) - ativo'
\echo ''
\echo 'CAMPOS OPCIONAIS:'
\echo '  - sku_fornecedor, codigo_original'
\echo '  - adicao_min, adicao_max (para multifocais)'
\echo '  - ar (BOOLEAN) - Antirreflexo'
\echo '  - blue (BOOLEAN) - Filtro luz azul'
\echo '  - fotossensivel (TEXT) - nenhum, transitions, fotocromático'
\echo '  - polarizado (BOOLEAN)'
\echo '  - custo_base (NUMERIC) - Custo de compra'
\echo ''

-- ============================================================================
-- PARTE 11: EXEMPLO DE INSERT PARA NOVO LABORATÓRIO
-- ============================================================================

\echo ''
\echo '============================================'
\echo '11. EXEMPLO: ADICIONAR NOVO LABORATÓRIO'
\echo '============================================'
\echo ''
\echo 'Para adicionar um NOVO laboratório, execute:'
\echo ''
\echo 'INSERT INTO core.fornecedores ('
\echo '    id, nome, razao_social, telefone, email,'
\echo '    prazo_visao_simples, prazo_multifocal, ativo'
\echo ') VALUES ('
\echo '    gen_random_uuid(),'
\echo '    ''Nome do Laboratório'','
\echo '    ''Razão Social LTDA'','
\echo '    ''(11) 99999-9999'','
\echo '    ''email@laboratorio.com'','
\echo '    7,  -- prazo visão simples (dias)'
\echo '    10, -- prazo multifocal (dias)'
\echo '    true'
\echo ');'
\echo ''

-- ============================================================================
-- PARTE 12: RESUMO FINAL
-- ============================================================================

\echo ''
\echo '============================================'
\echo '12. RESUMO FINAL'
\echo '============================================'

SELECT
    '📊 Total Lentes' as item, COUNT(*)::text as valor
FROM lens_catalog.lentes WHERE status = 'ativo'
UNION ALL
SELECT '🏭 Total Fornecedores', COUNT(*)::text
FROM core.fornecedores WHERE ativo = true
UNION ALL
SELECT '🏷️ Total Marcas', COUNT(*)::text
FROM lens_catalog.marcas WHERE ativo = true
UNION ALL
SELECT '📦 Total Grupos Canônicos', COUNT(*)::text
FROM lens_catalog.grupos_canonicos WHERE ativo = true;



| item                      | valor |
| ------------------------- | ----- |
| 📊 Total Lentes           | 1447  |
| 🏭 Total Fornecedores     | 22    |
| 🏷️ Total Marcas          | 18    |
| 📦 Total Grupos Canônicos | 239   |


\echo ''
\echo '============================================'
\echo 'DIAGNÓSTICO COMPLETO!'
\echo '============================================'
