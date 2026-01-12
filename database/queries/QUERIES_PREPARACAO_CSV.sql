-- ============================================================================
-- QUERIES DE PREPARAÇÃO PARA IMPORTAÇÃO DE LENTES (CSV)
-- Execute estas queries no Supabase SQL Editor para obter os dados necessários
-- para preencher seu arquivo CSV corretamente.
-- ============================================================================

-- 1. OBTER IDS DE FORNECEDORES (LABORATÓRIOS)
-- Copie o 'id' do laboratório que você quer usar no CSV (coluna: fornecedor_id)
SELECT 
    id, 
    nome, 
    razao_social, 
    ativo 
FROM core.fornecedores 
WHERE ativo = true 
ORDER BY nome;

| id                                   | nome                   | razao_social                              | ativo |
| ------------------------------------ | ---------------------- | ----------------------------------------- | ----- |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Brascor                | Brascor Distribuidora de Lentes           | true  |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | Braslentes             | Champ Brasil Comercio LTDA                | true  |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express                | Lentes e Cia Express LTDA                 | true  |
| e4a24408-3d58-4fc7-a096-cf7140f4f248 | Galeria Florencio lj11 | Galeria Florêncio Comércio de Óptica LTDA | true  |
| d90bebaf-e552-4cf0-a226-808c91bda73a | Kaizi Oculos Solares   | Kaizi Importação e Exportação LTDA        | true  |
| c50ea6eb-a420-4cf7-8aa2-68aaeb41ac95 | Navarro Oculos         | Navarro Distribuidora de Óculos LTDA      | true  |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Polylux                | Polylux Comercio de Produtos Opticos LTDA | true  |
| 1d0b088f-dcb1-4179-9a18-5d67ce86c4b6 | Sao Paulo Acessorios   | São Paulo Acessórios LTDA                 | true  |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | So Blocos              | S blocos Comercio e Servios Oticos LTDA   | true  |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | Style                  | Style Primer Lentes Oftalmicas e Armaes   | true  |
| 199bae08-0217-4b70-b054-d3f0960b4a78 | Sygma                  | Sygma Lentes Laboratório Óptico           | true  |


mudei a queires para ter o resultado correto

-- 2. OBTER IDS DE MARCAS
-- Copie o 'id' da marca correspondente (coluna: marca_id)
-- Se 'is_premium' for true, a lente será tratada como Premium Canônica automaticamente.
SELECT 
    id, 
    nome, 
    slug, 
    is_premium, 
    ativo 
FROM lens_catalog.marcas 
WHERE ativo = true 
ORDER BY nome;


| id                                   | nome        | slug        | is_premium | ativo |
| ------------------------------------ | ----------- | ----------- | ---------- | ----- |
| 98deae91-ee66-4c32-8a5d-8a6f83681993 | BRASCOR     | brascor     | false      | true  |
| d53785a4-37a2-48d1-b807-d172a31417ff | BRASLENTES  | braslentes  | false      | true  |
| befba165-0aa0-496f-bfdf-774bfe94a856 | CRIZAL      | crizal      | true       | true  |
| bbe5a62d-1d7d-4d93-87af-0dbde68c0645 | ESSILOR     | essilor     | true       | true  |
| 7bf35e08-7a88-4547-a06a-a6ce62fcc827 | EXPRESS     | express     | false      | true  |
| 7f1aa237-edaf-4376-8b91-6c93c3c079a4 | GENÉRICA    | generica    | false      | true  |
| 852e5fb8-8eae-4805-a5cb-a5a1e8638f5c | HOYA        | hoya        | true       | true  |
| a6091278-c827-40ea-a2fb-dcc26f1c8d20 | KODAK       | kodak       | true       | true  |
| 6c37f0a1-487c-4bb1-a065-c9498172cbfe | LENSCOPE    | lenscope    | true       | true  |
| e7ef4c94-a80a-492f-9195-24e6ab2f5056 | POLYLUX     | polylux     | false      | true  |
| d92921ad-1b9d-4f5f-93e1-3e75e4375f09 | RODENSTOCK  | rodenstock  | true       | true  |
| 4af04ba6-e600-4874-b8dc-45a2e1773725 | SO BLOCOS   | so-blocos   | false      | true  |
| 731a86d5-2d61-42ca-9533-1af470184bad | STYLE       | style       | false      | true  |
| 57fc0111-0a99-4642-8b66-f1d87a79afce | SYGMA       | sygma       | false      | true  |
| 3f8ac428-2224-415e-8a20-c9e6879754d3 | TRANSITIONS | transitions | true       | true  |
| 3f70213e-0b45-4f42-907a-28f7e7ac51c0 | VARILUX     | varilux     | true       | true  |
| a8ee9f1e-53d9-41ed-bc68-9c4a9881e828 | ZEISS       | zeiss       | true       | true  |




-- 3. VALORES PERMITIDOS PARA ENUMS (Listas de Opções)
-- O CSV deve conter EXATAMENTE um destes valores nas colunas respectivas.

-- Coluna: tipo_lente
SELECT enumlabel as "Valores para tipo_lente" 
FROM pg_enum WHERE enumtypid = 'lens_catalog.tipo_lente'::regtype;


| Valores para tipo_lente |
| ----------------------- |
| bifocal                 |
| leitura                 |
| multifocal              |
| ocupacional             |
| visao_simples           |



-- Coluna: categoria


-- Coluna: material
SELECT enumlabel as "Valores para material" 
FROM pg_enum WHERE enumtypid = 'lens_catalog.material_lente'::regtype;


| Valores para material |
| --------------------- |
| ACRILICO              |
| CR39                  |
| HIGH_INDEX            |
| POLICARBONATO         |
| TRIVEX                |
| VIDRO                 |


-- Coluna: indice_refracao
SELECT enumlabel as "Valores para indice_refracao" 
FROM pg_enum WHERE enumtypid = 'lens_catalog.indice_refracao'::regtype;

| Valores para indice_refracao |
| ---------------------------- |
| 1.50                         |
| 1.56                         |
| 1.59                         |
| 1.61                         |
| 1.67                         |
| 1.74                         |
| 1.90                         |

-- Coluna: fotossensivel
SELECT enumlabel as "Valores para fotossensivel" 
FROM pg_enum WHERE enumtypid = 'lens_catalog.tratamento_foto'::regtype;


| Valores para fotossensivel |
| -------------------------- |
| fotocromático              |
| nenhum                     |
| polarizado                 |
| transitions                |

-- 4. VERIFICAR TRIGGERS ATIVOS
-- Confirma se a automação de canonização está ativa na tabela de lentes.
SELECT 
    trigger_name, 
    event_manipulation, 
    action_statement 
FROM information_schema.triggers 
WHERE event_object_table = 'lentes' 
AND event_object_schema = 'lens_catalog';



| trigger_name                      | event_manipulation | action_statement                                                   |
| --------------------------------- | ------------------ | ------------------------------------------------------------------ |
| trg_lentes_updated_at             | UPDATE             | EXECUTE FUNCTION lens_catalog.update_lentes_timestamp()            |
| trg_lentes_generate_slug          | INSERT             | EXECUTE FUNCTION lens_catalog.generate_lente_slug()                |
| trg_lentes_generate_slug          | UPDATE             | EXECUTE FUNCTION lens_catalog.generate_lente_slug()                |
| trg_lentes_associar_grupo         | INSERT             | EXECUTE FUNCTION lens_catalog.fn_associar_lente_grupo_automatico() |
| trg_lentes_associar_grupo         | UPDATE             | EXECUTE FUNCTION lens_catalog.fn_associar_lente_grupo_automatico() |
| trg_lentes_atualizar_estatisticas | INSERT             | EXECUTE FUNCTION lens_catalog.fn_atualizar_estatisticas_grupo()    |
| trg_lentes_atualizar_estatisticas | DELETE             | EXECUTE FUNCTION lens_catalog.fn_atualizar_estatisticas_grupo()    |
| trg_lentes_atualizar_estatisticas | UPDATE             | EXECUTE FUNCTION lens_catalog.fn_atualizar_estatisticas_grupo()    |


-- ============================================================================
-- ESTRUTURA DO CSV (CABEÇALHO)
-- Copie a linha abaixo para ser a primeira linha do seu arquivo .csv
-- ============================================================================
/*
sku_fornecedor,codigo_original,nome_comercial,marca_id,fornecedor_id,tipo_lente,categoria,material,indice_refracao,diametro,esferico_min,esferico_max,cilindrico_min,cilindrico_max,adicao_min,adicao_max,ar,blue,fotossensivel,polarizado,custo_base,preco_tabela,status
*/

-- Exemplo de linha de dados:
/*
SKU-123,COD-ORIG,Lente Exemplo 1.56,UUID-DA-MARCA,UUID-DO-FORNECEDOR,visao_simples,intermediaria,CR39,1.56,70,-6.00,4.00,-2.00,0.00,,,true,false,nenhum,false,50.00,150.00,ativo
*/
