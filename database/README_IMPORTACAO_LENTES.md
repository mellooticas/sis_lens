# 📦 Guia de Importação de Lentes via CSV

Este guia explica como importar lentes de novos laboratórios para o sistema SIS Lens.

## 📋 Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Estrutura do Sistema](#estrutura-do-sistema)
3. [Passo a Passo](#passo-a-passo)
4. [Estrutura do CSV](#estrutura-do-csv)
5. [Triggers de Canonização](#triggers-de-canonização)
6. [Troubleshooting](#troubleshooting)

---

## 🔧 Pré-requisitos

Antes de importar, execute o diagnóstico:

```bash
psql -f database/diagnostics/DIAGNOSTICO_IMPORTACAO_CSV.sql
```

Este script mostra:
- Estado atual do banco
- Fornecedores e marcas existentes
- Triggers ativos
- Valores válidos para enums

---

## 🏗️ Estrutura do Sistema

### Schemas Principais

```
lens_catalog     → Lentes, marcas, grupos canônicos
core             → Fornecedores (pessoas.fornecedores ou core.fornecedores)
```

### Fluxo de Canonização

```
INSERT lente → Trigger dispara → Verifica is_premium da marca
    │
    ├── Marca PREMIUM (Essilor, Zeiss...) → premium_canonicas
    │
    └── Marca GENÉRICA → lentes_canonicas ou grupos_canonicos
```

### IDs Existentes

#### Fornecedores

| Nome       | ID                                   | Lead Time |
|------------|--------------------------------------|-----------|
| Express    | `8eb9498c-3d99-4d26-bb8c-e503f97ccf2c` | 3 dias ⚡ |
| Brascor    | `15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1` | 7 dias    |
| Polylux    | `3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21` | 7 dias    |
| So Blocos  | `e1e1eace-11b4-4f26-9f15-620808a4a410` | 7 dias    |
| Sygma      | `199bae08-0217-4b70-b054-d3f0960b4a78` | 7 dias    |

#### Marcas

| Nome     | ID                                   | Premium |
|----------|--------------------------------------|---------|
| ESSILOR  | `4c67f7d1-ec57-4a1a-9e00-e1778753b738` | ✅ Sim  |
| EXPRESS  | `5a43c260-12bf-4651-99c5-a050a23721ad` | ❌ Não  |
| SIS Lens | `5b64739e-d1f4-4c13-a159-867d8683f934` | ❌ Não  |
| SOBLOCOS | `a1b9169c-1af2-4a36-8451-de372dc67003` | ❌ Não  |
| POLYLUX  | `a7656b0c-88fb-4aa8-a3ed-a7de84598492` | ❌ Não  |
| BRASCOR  | `ba68f270-20a2-4697-a3eb-73d7d33fbed6` | ❌ Não  |
| SYGMA    | `da2dc10f-b3cb-4b8b-bec6-4e6f35f3dfcb` | ❌ Não  |

---

## 📝 Passo a Passo

### 1. Cadastrar Novo Laboratório (se necessário)

```sql
INSERT INTO core.fornecedores (
    id, nome, razao_social, telefone, email,
    prazo_visao_simples, prazo_multifocal, ativo
) VALUES (
    gen_random_uuid(),
    'Nome do Lab',
    'Razão Social LTDA',
    '(11) 99999-9999',
    'contato@lab.com',
    7, 10, true
);
```

### 2. Cadastrar Nova Marca (se necessário)

```sql
INSERT INTO lens_catalog.marcas (
    id, nome, slug, is_premium, descricao, ativo
) VALUES (
    gen_random_uuid(),
    'NOME_MARCA',
    'nome-marca',
    false,  -- true se for premium
    'Descrição da marca',
    true
);
```

### 3. Preparar o CSV

Use o template em `database/templates/TEMPLATE_LENTES.csv`

### 4. Converter CSV para SQL (opção A - recomendada)

```bash
python database/scripts/csv_to_sql_lentes.py \
    meu_arquivo.csv \
    saida.sql \
    --fornecedor-id UUID_DO_FORNECEDOR \
    --marca-id UUID_DA_MARCA
```

### 5. Executar o SQL

```bash
psql -f saida.sql
```

### 6. Verificar Resultado

```sql
-- Contar lentes importadas
SELECT COUNT(*) FROM lens_catalog.lentes
WHERE fornecedor_id = 'UUID_DO_FORNECEDOR';

-- Verificar canonização
SELECT
    COUNT(*) as total,
    COUNT(grupo_canonico_id) as com_grupo,
    COUNT(lente_canonica_id) as canonica,
    COUNT(premium_canonica_id) as premium,
    COUNT(*) FILTER (WHERE grupo_canonico_id IS NULL
                     AND lente_canonica_id IS NULL
                     AND premium_canonica_id IS NULL) as orfas
FROM lens_catalog.lentes
WHERE fornecedor_id = 'UUID_DO_FORNECEDOR';
```

---

## 📄 Estrutura do CSV

### Campos Obrigatórios

| Campo           | Tipo    | Valores Válidos                                    |
|-----------------|---------|---------------------------------------------------|
| nome_comercial  | TEXT    | Nome da lente                                      |
| tipo_lente      | ENUM    | `visao_simples`, `multifocal`, `bifocal`, `ocupacional` |
| material        | ENUM    | `CR39`, `POLICARBONATO`, `TRIVEX`                 |
| indice_refracao | ENUM    | `1.49`, `1.56`, `1.59`, `1.61`, `1.67`, `1.74`    |
| categoria       | ENUM    | `economica`, `intermediaria`, `premium`           |
| esferico_min    | NUMERIC | Ex: `-6.00`                                        |
| esferico_max    | NUMERIC | Ex: `6.00`                                         |
| cilindrico_min  | NUMERIC | Ex: `-2.00`                                        |
| cilindrico_max  | NUMERIC | Ex: `0.00`                                         |
| preco_tabela    | NUMERIC | Preço de venda                                     |

### Campos Opcionais

| Campo           | Tipo    | Default   | Descrição                          |
|-----------------|---------|-----------|-----------------------------------|
| adicao_min      | NUMERIC | NULL      | Para multifocais (Ex: 0.75)       |
| adicao_max      | NUMERIC | NULL      | Para multifocais (Ex: 3.50)       |
| ar              | BOOLEAN | false     | Antirreflexo                       |
| blue            | BOOLEAN | false     | Filtro luz azul                    |
| fotossensivel   | TEXT    | 'nenhum'  | `nenhum`, `transitions`, `fotocromático` |
| polarizado      | BOOLEAN | false     | Lente polarizada                   |
| custo_base      | NUMERIC | NULL      | Custo de compra                    |
| sku_fornecedor  | TEXT    | Auto      | SKU interno do lab                 |
| codigo_original | TEXT    | NULL      | Código do fabricante               |

### Exemplo de CSV

```csv
nome_comercial,tipo_lente,material,indice_refracao,categoria,esferico_min,esferico_max,cilindrico_min,cilindrico_max,adicao_min,adicao_max,ar,blue,fotossensivel,polarizado,custo_base,preco_tabela
"Lente CR39 1.56 AR",visao_simples,CR39,1.56,intermediaria,-6.00,6.00,-2.00,0.00,,,true,false,nenhum,false,50.00,299.90
"Multifocal 1.67 AR Blue",multifocal,CR39,1.67,premium,-10.00,6.00,-4.00,0.00,0.75,3.50,true,true,nenhum,false,250.00,1299.90
```

---

## ⚙️ Triggers de Canonização

O sistema possui **dois fluxos** de canonização:

### Fluxo 1: grupos_canonicos (mais recente)

Localização: `docs/database/reestruturation_database_sis_lens/`

- Usa a tabela `grupos_canonicos`
- 16 critérios de agrupamento incluindo `is_premium`
- Trigger: `trg_lente_insert_update`
- Função: `trigger_atualizar_grupo_canonico()`

### Fluxo 2: lentes_canonicas / premium_canonicas (original)

Localização: `database/migrations/05_TRIGGERS_CANONIZACAO.sql`

- Tabelas: `lentes_canonicas` (genéricas) e `premium_canonicas` (premium)
- Trigger: `trg_vincular_canonica`
- Função: `fn_vincular_canonica()`

**IMPORTANTE:** Verifique qual trigger está ativo no seu banco:

```sql
SELECT tgname, tgenabled
FROM pg_trigger
WHERE tgrelid = 'lens_catalog.lentes'::regclass
  AND NOT tgisinternal;
```

---

## 🔧 Troubleshooting

### Lentes não estão sendo canonizadas

1. Verificar se trigger está ativo:
```sql
SELECT * FROM pg_trigger
WHERE tgrelid = 'lens_catalog.lentes'::regclass;
```

2. Reativar trigger se desativado:
```sql
ALTER TABLE lens_catalog.lentes
ENABLE TRIGGER trg_vincular_canonica;
```

3. Forçar re-processamento:
```sql
UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE status = 'ativo'
  AND grupo_canonico_id IS NULL
  AND lente_canonica_id IS NULL;
```

### Marca não encontrada

```sql
-- Verificar marcas existentes
SELECT id, nome, is_premium FROM lens_catalog.marcas;

-- Criar nova marca
INSERT INTO lens_catalog.marcas (id, nome, slug, is_premium, ativo)
VALUES (gen_random_uuid(), 'NOVA_MARCA', 'nova-marca', false, true);
```

### Fornecedor não encontrado

```sql
-- Verificar fornecedores (teste ambos schemas)
SELECT id, nome FROM core.fornecedores;
SELECT id, nome FROM pessoas.fornecedores;

-- Criar novo fornecedor
INSERT INTO core.fornecedores (id, nome, prazo_visao_simples, ativo)
VALUES (gen_random_uuid(), 'Novo Lab', 7, true);
```

### Erro de ENUM inválido

```sql
-- Ver valores válidos
SELECT DISTINCT tipo_lente FROM lens_catalog.lentes;
SELECT DISTINCT material FROM lens_catalog.lentes;
SELECT DISTINCT indice_refracao FROM lens_catalog.lentes;
SELECT DISTINCT categoria FROM lens_catalog.lentes;
```

---

## 📁 Arquivos Úteis

```
database/
├── diagnostics/
│   └── DIAGNOSTICO_IMPORTACAO_CSV.sql   # Diagnóstico pré-import
├── scripts/
│   └── csv_to_sql_lentes.py             # Conversor CSV → SQL
├── seeds/
│   └── TEMPLATE_IMPORTAR_NOVO_LABORATORIO.sql  # Template completo
├── templates/
│   └── TEMPLATE_LENTES.csv              # Exemplo de CSV
└── README_IMPORTACAO_LENTES.md          # Este arquivo
```

---

**Última atualização:** Janeiro/2026
