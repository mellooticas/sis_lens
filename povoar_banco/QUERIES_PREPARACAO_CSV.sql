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
FROM pessoas.fornecedores 
WHERE ativo = true 
ORDER BY nome;

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

-- 3. VALORES PERMITIDOS PARA ENUMS (Listas de Opções)
-- O CSV deve conter EXATAMENTE um destes valores nas colunas respectivas.

-- Coluna: tipo_lente
SELECT enumlabel as "Valores para tipo_lente" 
FROM pg_enum WHERE enumtypid = 'lens_catalog.tipo_lente'::regtype;

-- Coluna: categoria
SELECT enumlabel as "Valores para categoria" 
FROM pg_enum WHERE enumtypid = 'lens_catalog.categoria_lente'::regtype;

-- Coluna: material
SELECT enumlabel as "Valores para material" 
FROM pg_enum WHERE enumtypid = 'lens_catalog.material_lente'::regtype;

-- Coluna: indice_refracao
SELECT enumlabel as "Valores para indice_refracao" 
FROM pg_enum WHERE enumtypid = 'lens_catalog.indice_refracao'::regtype;

-- Coluna: fotossensivel
SELECT enumlabel as "Valores para fotossensivel" 
FROM pg_enum WHERE enumtypid = 'lens_catalog.tratamento_foto'::regtype;

-- 4. VERIFICAR TRIGGERS ATIVOS
-- Confirma se a automação de canonização está ativa na tabela de lentes.
SELECT 
    trigger_name, 
    event_manipulation, 
    action_statement 
FROM information_schema.triggers 
WHERE event_object_table = 'lentes' 
AND event_object_schema = 'lens_catalog';

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
