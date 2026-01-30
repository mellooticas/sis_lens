-- ============================================================================
-- INVESTIGAÇÃO: LENTES DE CONTATO - SCHEMA E DADOS EXISTENTES
-- ============================================================================
-- Objetivo: Investigar o que já existe em contact_lens e public para
--           preparar a importação dos CSVs lentenet.csv e newlentes.csv
-- ============================================================================

-- ============================================================================
-- PARTE 1: VERIFICAR SCHEMAS E TABELAS
-- ============================================================================

-- Verificar se o schema contact_lens existe
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name = 'contact_lens';


| schema_name  |
| ------------ |
| contact_lens |


-- Verificar tabelas no schema contact_lens
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'contact_lens'
ORDER BY table_name;


| table_name         | table_type |
| ------------------ | ---------- |
| grupos_canonicos   | BASE TABLE |
| lentes             | BASE TABLE |
| marcas             | BASE TABLE |
| v_grupos_canonicos | VIEW       |
| v_lentes_catalogo  | VIEW       |


-- Verificar tabelas relacionadas a lentes em public
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND (table_name ILIKE '%lente%' OR table_name ILIKE '%contact%')
ORDER BY table_name;


| table_name                 | table_type |
| -------------------------- | ---------- |
| v_lentes                   | VIEW       |
| v_lentes_contato           | VIEW       |
| vw_bi_lentes_lucratividade | VIEW       |


-- ============================================================================
-- PARTE 2: VERIFICAR ESTRUTURA DAS TABELAS CONTACT_LENS
-- ============================================================================

-- Estrutura da tabela contact_lens.lentes
SELECT 
  column_name,
  data_type,
  character_maximum_length,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'contact_lens'
  AND table_name = 'lentes'
ORDER BY ordinal_position;


| column_name           | data_type                | character_maximum_length | is_nullable | column_default                       |
| --------------------- | ------------------------ | ------------------------ | ----------- | ------------------------------------ |
| id                    | uuid                     | null                     | NO          | gen_random_uuid()                    |
| fornecedor_id         | uuid                     | null                     | NO          | null                                 |
| marca_id              | uuid                     | null                     | YES         | null                                 |
| nome_produto          | text                     | null                     | NO          | null                                 |
| nome_canonizado       | text                     | null                     | YES         | null                                 |
| slug                  | text                     | null                     | YES         | null                                 |
| sku                   | character varying        | 100                      | YES         | null                                 |
| codigo_fornecedor     | character varying        | 100                      | YES         | null                                 |
| tipo_lente            | USER-DEFINED             | null                     | NO          | null                                 |
| material              | USER-DEFINED             | null                     | NO          | null                                 |
| finalidade            | USER-DEFINED             | null                     | NO          | null                                 |
| diametro              | numeric                  | null                     | YES         | null                                 |
| curva_base            | numeric                  | null                     | YES         | null                                 |
| dk_t                  | integer                  | null                     | YES         | null                                 |
| conteudo_agua         | integer                  | null                     | YES         | null                                 |
| espessura_central     | numeric                  | null                     | YES         | null                                 |
| esferico_min          | numeric                  | null                     | YES         | null                                 |
| esferico_max          | numeric                  | null                     | YES         | null                                 |
| cilindrico_min        | numeric                  | null                     | YES         | 0.00                                 |
| cilindrico_max        | numeric                  | null                     | YES         | 0.00                                 |
| eixo_min              | integer                  | null                     | YES         | null                                 |
| eixo_max              | integer                  | null                     | YES         | null                                 |
| adicao_min            | numeric                  | null                     | YES         | 0.00                                 |
| adicao_max            | numeric                  | null                     | YES         | 0.00                                 |
| protecao_uv           | boolean                  | null                     | YES         | false                                |
| colorida              | boolean                  | null                     | YES         | false                                |
| cor_disponivel        | character varying        | 100                      | YES         | null                                 |
| resistente_depositos  | boolean                  | null                     | YES         | false                                |
| hidratacao_prolongada | boolean                  | null                     | YES         | false                                |
| dias_uso              | integer                  | null                     | YES         | null                                 |
| horas_uso_diario      | integer                  | null                     | YES         | null                                 |
| pode_dormir_com_lente | boolean                  | null                     | YES         | false                                |
| solucao_recomendada   | text                     | null                     | YES         | null                                 |
| preco_custo           | numeric                  | null                     | YES         | 0                                    |
| preco_tabela          | numeric                  | null                     | YES         | 0                                    |
| preco_fabricante      | numeric                  | null                     | YES         | null                                 |
| unidades_por_caixa    | integer                  | null                     | YES         | 1                                    |
| estoque_disponivel    | integer                  | null                     | YES         | 0                                    |
| lead_time_dias        | integer                  | null                     | YES         | 7                                    |
| disponivel            | boolean                  | null                     | YES         | true                                 |
| destaque              | boolean                  | null                     | YES         | false                                |
| novidade              | boolean                  | null                     | YES         | false                                |
| data_lancamento       | date                     | null                     | YES         | null                                 |
| data_descontinuacao   | date                     | null                     | YES         | null                                 |
| descricao_curta       | text                     | null                     | YES         | null                                 |
| descricao_completa    | text                     | null                     | YES         | null                                 |
| beneficios            | ARRAY                    | null                     | YES         | null                                 |
| indicacoes            | ARRAY                    | null                     | YES         | null                                 |
| contraindicacoes      | text                     | null                     | YES         | null                                 |
| status                | USER-DEFINED             | null                     | YES         | 'ativo'::contact_lens.status_produto |
| metadata              | jsonb                    | null                     | YES         | '{}'::jsonb                          |
| observacoes           | text                     | null                     | YES         | null                                 |
| ativo                 | boolean                  | null                     | YES         | true                                 |
| created_at            | timestamp with time zone | null                     | YES         | now()                                |
| updated_at            | timestamp with time zone | null                     | YES         | now()                                |
| deleted_at            | timestamp with time zone | null                     | YES         | null                                 |
| grupo_canonico_id     | uuid                     | null                     | YES         | null                                 |


-- Estrutura da tabela contact_lens.marcas
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'contact_lens'
  AND table_name = 'marcas'
ORDER BY ordinal_position;


| column_name | data_type                | is_nullable | column_default    |
| ----------- | ------------------------ | ----------- | ----------------- |
| id          | uuid                     | NO          | gen_random_uuid() |
| nome        | character varying        | NO          | null              |
| slug        | character varying        | NO          | null              |
| fabricante  | character varying        | YES         | null              |
| pais_origem | character varying        | YES         | null              |
| website     | text                     | YES         | null              |
| logo_url    | text                     | YES         | null              |
| is_premium  | boolean                  | YES         | false             |
| descricao   | text                     | YES         | null              |
| ativo       | boolean                  | YES         | true              |
| created_at  | timestamp with time zone | YES         | now()             |
| updated_at  | timestamp with time zone | YES         | now()             |

lembrarndo que os fornecedores de lentes de contatos estão no mesmo lugar que os fornecedores copmletos

-- Estrutura da tabela contact_lens.grupos_canonicos
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'contact_lens'
  AND table_name = 'grupos_canonicos'
ORDER BY ordinal_position;


| column_name       | data_type                | is_nullable |
| ----------------- | ------------------------ | ----------- |
| id                | uuid                     | NO          |
| nome_grupo        | text                     | NO          |
| slug              | text                     | NO          |
| tipo_lente        | USER-DEFINED             | NO          |
| material          | USER-DEFINED             | NO          |
| finalidade        | USER-DEFINED             | NO          |
| diametro_padrao   | numeric                  | YES         |
| curva_base_padrao | numeric                  | YES         |
| dias_uso          | integer                  | YES         |
| total_lentes      | integer                  | YES         |
| total_marcas      | integer                  | YES         |
| preco_minimo      | numeric                  | YES         |
| preco_maximo      | numeric                  | YES         |
| preco_medio       | numeric                  | YES         |
| is_premium        | boolean                  | YES         |
| tem_uv            | boolean                  | YES         |
| colorida          | boolean                  | YES         |
| peso              | integer                  | YES         |
| ativo             | boolean                  | YES         |
| created_at        | timestamp with time zone | YES         |
| updated_at        | timestamp with time zone | YES         |


-- ============================================================================
-- PARTE 3: VERIFICAR ENUMS (TIPOS CUSTOMIZADOS)
-- ============================================================================

-- Listar todos os ENUMs do schema contact_lens
SELECT 
  t.typname as enum_name,
  e.enumlabel as enum_value,
  e.enumsortorder
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid  
JOIN pg_namespace n ON n.oid = t.typnamespace
WHERE n.nspname = 'contact_lens'
ORDER BY t.typname, e.enumsortorder;


| enum_name          | enum_value        | enumsortorder |
| ------------------ | ----------------- | ------------- |
| finalidade         | visao_simples     | 1             |
| finalidade         | torica            | 2             |
| finalidade         | multifocal        | 3             |
| finalidade         | cosmetica         | 4             |
| finalidade         | terapeutica       | 5             |
| finalidade         | orto_k            | 6             |
| material_contato   | hidrogel          | 1             |
| material_contato   | silicone_hidrogel | 2             |
| material_contato   | rgp_gas_perm      | 3             |
| material_contato   | pmma              | 4             |
| status_produto     | ativo             | 1             |
| status_produto     | inativo           | 2             |
| status_produto     | descontinuado     | 3             |
| status_produto     | pre_lancamento    | 4             |
| tipo_lente_contato | diaria            | 1             |
| tipo_lente_contato | quinzenal         | 2             |
| tipo_lente_contato | mensal            | 3             |
| tipo_lente_contato | trimestral        | 4             |
| tipo_lente_contato | anual             | 5             |
| tipo_lente_contato | rgp               | 6             |
| tipo_lente_contato | escleral          | 7             |


-- ============================================================================
-- PARTE 4: VERIFICAR DADOS EXISTENTES
-- ============================================================================

-- Contar lentes existentes no schema contact_lens
SELECT 
  'contact_lens.lentes' as tabela,
  COUNT(*) as total_registros
FROM contact_lens.lentes;


| tabela              | total_registros |
| ------------------- | --------------- |
| contact_lens.lentes | 0               |


-- Contar marcas existentes
SELECT 
  'contact_lens.marcas' as tabela,
  COUNT(*) as total_registros
FROM contact_lens.marcas;


| tabela              | total_registros |
| ------------------- | --------------- |
| contact_lens.marcas | 7               |


-- Contar grupos canônicos
SELECT 
  'contact_lens.grupos_canonicos' as tabela,
  COUNT(*) as total_registros
FROM contact_lens.grupos_canonicos;


| tabela                        | total_registros |
| ----------------------------- | --------------- |
| contact_lens.grupos_canonicos | 0               |

-- Ver marcas existentes
SELECT 
  id,
  nome,
  slug,
  fabricante,
  is_premium,
  ativo
FROM contact_lens.marcas
ORDER BY nome;


| id                                   | nome      | slug      | fabricante        | is_premium | ativo |
| ------------------------------------ | --------- | --------- | ----------------- | ---------- | ----- |
| 4ba0d55f-70a5-4e51-8ddc-b1f283d298f4 | Acuvue    | acuvue    | Johnson & Johnson | true       | true  |
| b2c6b318-0842-4cea-9871-8f949445dede | Air Optix | air-optix | Alcon             | true       | true  |
| c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88 | Biofinity | biofinity | CooperVision      | true       | true  |
| 58dacfaf-b712-4fca-b972-0cd5a89008f1 | Biosoft   | biosoft   | Bausch+Lomb       | false      | true  |
| 4fcb3afe-be54-49bf-973e-d627090b0e2b | Dailies   | dailies   | Alcon             | true       | true  |
| a16aa23b-815c-421c-96e6-c652fc239d94 | Hidrocor  | hidrocor  | Solótica          | false      | true  |
| 38d91af6-0fed-43bc-97e8-1cab30a9631d | Soflens   | soflens   | Bausch+Lomb       | false      | true  |

-- Ver distribuição de lentes por tipo
SELECT 
  tipo_lente,
  COUNT(*) as quantidade,
  COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as percentual
FROM contact_lens.lentes
WHERE ativo = true
GROUP BY tipo_lente
ORDER BY quantidade DESC;


Success. No rows returned




-- Ver distribuição de lentes por finalidade
SELECT 
  finalidade,
  COUNT(*) as quantidade
FROM contact_lens.lentes
WHERE ativo = true
GROUP BY finalidade
ORDER BY quantidade DESC;


Success. No rows returned




-- Ver distribuição de lentes por marca
SELECT 
  m.nome as marca,
  COUNT(l.id) as quantidade_lentes,
  MIN(l.preco_tabela) as preco_min,
  MAX(l.preco_tabela) as preco_max,
  AVG(l.preco_tabela)::numeric(10,2) as preco_medio
FROM contact_lens.marcas m
LEFT JOIN contact_lens.lentes l ON m.id = l.marca_id AND l.ativo = true
GROUP BY m.id, m.nome
ORDER BY quantidade_lentes DESC;


| marca     | quantidade_lentes | preco_min | preco_max | preco_medio |
| --------- | ----------------- | --------- | --------- | ----------- |
| Air Optix | 0                 | null      | null      | null        |
| Hidrocor  | 0                 | null      | null      | null        |
| Soflens   | 0                 | null      | null      | null        |
| Biosoft   | 0                 | null      | null      | null        |
| Acuvue    | 0                 | null      | null      | null        |
| Dailies   | 0                 | null      | null      | null        |
| Biofinity | 0                 | null      | null      | null        |

-- ============================================================================
-- PARTE 5: VERIFICAR LENTES EM PUBLIC (SE EXISTIR)
-- ============================================================================

-- Verificar se existe tabela de lentes em public
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'lentes'
  ) THEN
    RAISE NOTICE 'Tabela public.lentes EXISTE';
    
    -- Mostrar estrutura
    PERFORM column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'lentes'
    ORDER BY ordinal_position;
  ELSE
    RAISE NOTICE 'Tabela public.lentes NÃO EXISTE';
  END IF;
END $$;


Success. No rows returned




-- ============================================================================
-- PARTE 6: ANÁLISE DOS CSVs (ESTRUTURA ESPERADA)
-- ============================================================================

/*
LENTENET.CSV - Estrutura:
- id: ID do produto
- nome: Nome completo do produto
- sku: SKU (pode estar vazio)
- preco_original: Preço sem desconto (em centavos)
- preco_promocional: Preço com desconto (em centavos)
- categorias: String com categorias separadas por ";"
- descricao: Descrição do produto
- url: URL do produto
- timestamp: Data/hora da coleta
- http_status: Status HTTP (200 = OK)

NEWLENTES.CSV - Estrutura similar:
- id: ID do produto
- nome: Nome completo do produto
- sku: SKU
- preco_original: Preço sem desconto (em centavos)
- preco_promocional: Preço com desconto (em centavos)
- categorias: String com categorias
- descricao: Descrição
- url: URL
- timestamp: Timestamp
- http_status: Status

MAPEAMENTO NECESSÁRIO:
1. Extrair tipo de lente das categorias (Diárias, Mensais, Quinzenais, Anuais)
2. Extrair finalidade (Astigmatismo/Tórica, Multifocal, Colorida)
3. Extrair marca do nome do produto
4. Converter preços de centavos para reais
5. Determinar material (silicone_hidrogel para premium, hidrogel para outros)
6. Mapear para fornecedor (criar se não existir)
*/

-- ============================================================================
-- PARTE 7: VERIFICAR FORNECEDORES
-- ============================================================================

-- Ver fornecedores existentes
SELECT 
  id,
  nome,
  tipo_fornecedor,
  ativo
FROM core.fornecedores
WHERE ativo = true
ORDER BY nome;

-- Verificar se existem fornecedores para lentes de contato
SELECT 
  id,
  nome,
  tipo_fornecedor
FROM core.fornecedores
WHERE nome ILIKE '%lente%'
   OR nome ILIKE '%net%'
   OR nome ILIKE '%contact%'
ORDER BY nome;

-- ============================================================================
-- PARTE 8: PRÓXIMOS PASSOS
-- ============================================================================

/*
PRÓXIMOS PASSOS PARA IMPORTAÇÃO:

1. CRIAR FORNECEDORES (se não existirem):
   - Lentenet
   - NewLentes

2. CRIAR/ATUALIZAR MARCAS:
   - Extrair marcas dos nomes dos produtos
   - Verificar quais já existem
   - Criar as que faltam

3. CRIAR SCRIPT DE IMPORTAÇÃO:
   - Parser para categorias → tipo_lente, finalidade
   - Parser para nome → marca
   - Conversão de preços
   - Mapeamento de campos

4. CRIAR GRUPOS CANÔNICOS:
   - Agrupar lentes similares
   - Calcular estatísticas

5. VALIDAR DADOS:
   - Verificar integridade
   - Conferir preços
   - Validar relacionamentos
*/

-- ============================================================================
-- RESULTADO ESPERADO:
-- ============================================================================
-- Esta query mostra:
-- ✅ Estrutura atual do schema contact_lens
-- ✅ Dados existentes (marcas, lentes, grupos)
-- ✅ Distribuição de produtos
-- ✅ Fornecedores disponíveis
-- ✅ Preparação para importação dos CSVs
-- ============================================================================