# 🎯 Estratégia de Migração: Lentes Canônicas vs Produtos de Laboratório

**Autor**: Sistema SIS Lens  
**Data**: 06/10/2025  
**Status**: 🔴 **DECISÃO ARQUITETURAL CRÍTICA**

---

## 🚨 **PROBLEMA IDENTIFICADO**

A ordem original de migração está **arquiteturalmente incorreta**:

```
❌ ORDEM ERRADA:
1. ✅ Fornecedores (Laboratórios)
2. ✅ Marcas
3. ❌ Lentes Canônicas  <-- ERRO! Não podemos criar ainda!
4. ❌ Lentes Premium     <-- ERRO! Não podemos criar ainda!
5. ❌ Produtos Lab
6. ❌ Preços
7. ❌ Prazos
```

---

## 🧩 **ARQUITETURA DE DEPENDÊNCIAS**

### **Como funciona no SIS Lens:**

```
┌─────────────────────────────────────────────────────────┐
│  lens_catalog.lentes_canonicas                          │
│  (SKU Canônico Universal)                               │
│  sku: LENS-0001-ESS-VLX-X-167-HC-AR-BLUE               │
│  → Fonte da Verdade Técnica                             │
└─────────────────────────────────────────────────────────┘
                          ▲
                          │
                          │ FK: lente_id
                          │
┌─────────────────────────┴───────────────────────────────┐
│  suppliers.produtos_laboratorio                         │
│  (Produtos Reais dos Labs)                              │
│  sku_laboratorio: ESS-VLX-X-167-BLU                    │
│  sku_fantasia: VARILUX-X-167-BLUE                      │
│  lente_id → lens_catalog.lentes_canonicas              │
└─────────────────────────────────────────────────────────┘
                          ▲
                          │
                          │ FK: produto_lab_id
                          │
┌─────────────────────────┴───────────────────────────────┐
│  commercial.precos_base                                 │
│  produto_lab_id → suppliers.produtos_laboratorio       │
│  preco_custo: 285.00                                    │
└─────────────────────────────────────────────────────────┘
```

**Relação N:1**:
- **Múltiplos produtos de laboratórios** → **UMA lente canônica**
- Exemplo:
  - Essilor "Varilux X 1.67 Blue" → `LENS-0001`
  - Hoya "iD MyView 1.67" → `LENS-0001` (mesma lente técnica)
  - Zeiss "SmartLife 1.67" → `LENS-0001` (mesma lente técnica)

---

## 📊 **SITUAÇÃO NO MELLO (Sistema Origem)**

### **O que temos:**

```sql
-- Mello tem no SCHEMA LENTE:
lente.fornecedores_lentes      -- Produtos reais de labs com preços
lente.catalogo_mello_lentes    -- Lentes já normalizadas/agrupadas
lente.faixas_custo             -- Faixas de preço
fornecedores.fornecedores      -- Dados dos laboratórios
```

### **Estrutura do Mello:**

```
lente.fornecedores_lentes
├─ id
├─ fornecedor_id (FK → fornecedores.fornecedores)
├─ nome_lente
├─ marca_lente
├─ tipo_lente
├─ material
├─ indice_refracao
├─ sku_geral
├─ sku
├─ codigo_fornecedor
├─ preco_custo
├─ tratamentos (ar, blue, fotossensivel, polarizado, etc.)
└─ ...

lente.catalogo_mello_lentes
├─ id
├─ sku_normalizado (ÚNICO!)
├─ nome_comercial
├─ marca_normalizada
├─ tipo_lente
├─ material
├─ indice_refracao
├─ quantidade_lentes (quantos produtos agregados)
├─ preco_minimo, preco_maximo, preco_medio
├─ lente_representante_id (FK → fornecedores_lentes)
└─ ...
```

🎯 **INSIGHT CRÍTICO**: O Mello **JÁ TEM NORMALIZAÇÃO**! A tabela `catalogo_mello_lentes` já agrupa produtos similares em lentes "canônicas"!

---

## 🔄 **DUAS ESTRATÉGIAS POSSÍVEIS**

### **Estratégia A: Usar Catálogo Normalizado do Mello (RECOMENDADA)**

```
✅ ORDEM CORRETA:
1. ✅ Laboratórios (já feito)
2. ✅ Marcas (já feito)
3. 🆕 Lentes Canônicas 
   └─ Migrar lente.catalogo_mello_lentes → lens_catalog.lentes
   └─ O Mello JÁ FEZ a normalização pra nós!
4. 🆕 Produtos Laboratório
   └─ Migrar lente.fornecedores_lentes → suppliers.produtos_laboratorio
   └─ Mapear para lente_id usando sku_normalizado
5. ✅ Preços
   └─ Extrair de fornecedores_lentes.preco_custo
6. ✅ Prazos
   └─ lead_time schema já tem dados
```

**Vantagens**:
- ✅ Mello **já normalizou** as lentes (catalogo_mello_lentes)
- ✅ sku_normalizado é ÚNICO (perfeito para SKU canônico)
- ✅ Já agrupa produtos similares
- ✅ Tem lente_representante_id para referência
- ✅ Preserva preço min/médio/max

**Desvantagens**:
- ⚠️ Precisa entender a lógica de normalização do Mello
- ⚠️ Pode ter produtos órfãos (não agregados ao catálogo)

---

### **Estratégia B: Normalizar do Zero (NÃO RECOMENDADA)**

```
✅ ORDEM:
1. ✅ Laboratórios (já feito)
2. ✅ Marcas (já feito)
3. 🆕 Produtos Laboratório (sem lente_id)
   └─ Migrar lente.fornecedores_lentes → suppliers.produtos_laboratorio
4. 🆕 Criar Lentes Canônicas Manualmente
   └─ Agrupar por tipo_lente + material + indice + tratamentos
5. 🔄 Atualizar Produtos com lente_id
6. ✅ Preços
7. ✅ Prazos
```

**Vantagens**:
- ✅ Controle total da normalização

**Desvantagens**:
- ❌ Desperdiça trabalho já feito no Mello
- ❌ Mais complexo e propenso a erros
- ❌ Pode criar normalizações diferentes

---

## 🧪 **ANÁLISE NECESSÁRIA: Mapeamento Mello**

### **Queries de Investigação (SCHEMA LENTE):**

```sql
-- 1. Quantos produtos e lentes canônicas temos?
SELECT 
  (SELECT COUNT(*) FROM lente.fornecedores_lentes WHERE status = 'ativo') as produtos_ativos,
  (SELECT COUNT(*) FROM lente.catalogo_mello_lentes) as lentes_canonicas,
  (SELECT COUNT(DISTINCT fornecedor_id) FROM lente.fornecedores_lentes WHERE status = 'ativo') as fornecedores_unicos,
  (SELECT COUNT(DISTINCT marca_lente) FROM lente.fornecedores_lentes WHERE status = 'ativo' AND marca_lente IS NOT NULL) as marcas_unicas;

  para nossa tabela e queries correta é esta


  SELECT 
  (SELECT COUNT(*) FROM lente.fornecedores_lentes ) as produtos_ativos,
  (SELECT COUNT(*) FROM lente.catalogo_mello_lentes) as lentes_canonicas,
  (SELECT COUNT(DISTINCT fornecedor_id) FROM lente.fornecedores_lentes ) as fornecedores_unicos,
  (SELECT COUNT(DISTINCT marca_lente) FROM lente.fornecedores_lentes ) as marcas_unicas;

  | produtos_ativos | lentes_canonicas | fornecedores_unicos | marcas_unicas |
| --------------- | ---------------- | ------------------- | ------------- |
| 1411            | 265              | 5                   | 6             |

-- 2. Ver estrutura do catálogo normalizado (já é tipo "lente canônica")
SELECT 
  sku_normalizado,
  nome_comercial,
  marca_normalizada,
  tipo_lente,
  material,
  indice_refracao,
  quantidade_lentes as qtd_produtos_agregados,
  preco_minimo,
  preco_medio,
  preco_maximo,
  lente_representante_id
FROM lente.catalogo_mello_lentes
ORDER BY quantidade_lentes DESC
LIMIT 10;

| sku_normalizado | nome_comercial                                 | marca_normalizada | tipo_lente | material      | indice_refracao | qtd_produtos_agregados | preco_minimo | preco_medio | preco_maximo | lente_representante_id               |
| --------------- | ---------------------------------------------- | ----------------- | ---------- | ------------- | --------------- | ---------------------- | ------------ | ----------- | ------------ | ------------------------------------ |
| LVN000019       | LensVision Progressiva CR39 1.49 Foto          | GENERICA          | FREE FORM  | CR-39         | 1.49            | 39                     | 990.00       | 1159.54     | 1320.00      | 70b531b9-8de4-4262-9410-13406d2fc286 |
| LVN000012       | LensVision Progressiva Resina 1.67             | GENERICA          | FREE FORM  | RESINA        | 1.67            | 30                     | 310.00       | 1200.47     | 1770.00      | a4ebdeae-ce65-4cfc-bfef-a7167b10f93c |
| LVN000011       | LensVision Progressiva Policarbonato 1.59      | GENERICA          | FREE FORM  | POLICARBONATO | 1.59            | 30                     | 170.00       | 691.03      | 1240.00      | 843342a7-69d3-4910-bd77-9553c02b58f5 |
| LVN000048       | LensVision Progressiva Resina 1.67 Blue        | GENERICA          | FREE FORM  | RESINA        | 1.67            | 30                     | 340.00       | 1163.20     | 1680.00      | ec8c7ced-8e16-4046-96ba-92677d080818 |
| LVN000047       | LensVision Progressiva Policarbonato 1.59 Blue | GENERICA          | FREE FORM  | POLICARBONATO | 1.59            | 28                     | 196.00       | 685.43      | 1120.00      | 20f0b18e-8309-4b56-9eea-823a01eb3e0e |
| LVN000010       | LensVision Progressiva CR39 1.49               | GENERICA          | FREE FORM  | CR-39         | 1.49            | 28                     | 132.00       | 611.36      | 1110.00      | 61aa6a9e-7d29-466b-a4e9-ebd5e910ae63 |
| LVN000032       | LensVision Progressiva Resina 1.74 Blue        | GENERICA          | FREE FORM  | RESINA        | 1.74            | 27                     | 1240.00      | 1494.67     | 1990.00      | 556ebec0-e98d-4de3-82f4-4f53f3ce3312 |
| LVN000050       | LensVision Progressiva Resina 1.56 Blue        | GENERICA          | FREE FORM  | RESINA        | 1.56            | 27                     | 120.00       | 605.48      | 830.00       | 8ecfd4ea-db3e-4162-aa32-bcdb798c8943 |
| LVN000022       | LensVision Progressiva CR39 1.49 AR Foto       | GENERICA          | FREE FORM  | CR-39         | 1.49            | 26                     | 1050.00      | 1109.54     | 1176.00      | edcaf950-ff96-4bde-bc43-71d374e4979b |
| LVN000036       | LensVision Progressiva Resina 1.74             | GENERICA          | FREE FORM  | RESINA        | 1.74            | 26                     | 520.00       | 1421.23     | 1930.00      | 4a9aed28-d834-4b31-b29e-c2df7107a4e4 |

auqi nao temos fornecedores, pois são lentes padronizadas sem fornecedores, o que liga esta tabela ao catalogo, é o sku_normalizado


-- 3. Verificar mapeamento: Produtos → Catálogo Normalizado
SELECT 
  cat.sku_normalizado,
  cat.nome_comercial,
  COUNT(fl.id) as produtos_vinculados,
  STRING_AGG(DISTINCT fl.marca_lente, ', ') as marcas,
  STRING_AGG(DISTINCT fornecedor_id::text, ', ') as fornecedores
FROM lente.catalogo_mello_lentes cat
LEFT JOIN lente.fornecedores_lentes fl ON fl.id = cat.lente_representante_id
GROUP BY cat.id, cat.sku_normalizado, cat.nome_comercial
ORDER BY produtos_vinculados DESC
LIMIT 10;


temos que pensar nesta aqui, pois está errada

-- 4. Ver exemplos de produtos reais (para entender estrutura)
SELECT 
  id,
  fornecedor_id,
  nome_lente,
  marca_lente,
  tipo_lente,
  material,
  indice_refracao,
  sku_geral,
  codigo_fornecedor,
  preco_custo,
  ar, blue, fotossensivel, polarizado,
  status
FROM lente.fornecedores_lentes
WHERE status = 'ativo' AND preco_custo > 0
ORDER BY created_at DESC
LIMIT 5;


| id                                   | fornecedor_id                        | nome_lente                                           | marca_lente | tipo_lente    | material      | indice_refracao | sku_geral | codigo_fornecedor | preco_custo | ar    | blue  | fotossensivel | polarizado | status |
| ------------------------------------ | ------------------------------------ | ---------------------------------------------------- | ----------- | ------------- | ------------- | --------------- | --------- | ----------------- | ----------- | ----- | ----- | ------------- | ---------- | ------ |
| 951a3a9c-aa79-44fd-b894-7bd26ce16776 | e1e1eace-11b4-4f26-9f15-620808a4a410 | MULTI 1.67 FREEVIEW HD FOTO AR FAST                  | SOBLOCOS    | FREE FORM     | RESINA        | 1.67            | MLTXHUW0W | 10483             | 1180        | true  | false | false         | false      | ATIVO  |
| 16dd26b2-e587-4f5b-a1e9-52c7efa51db4 | 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | ESPACE POLICARBONATO                                 | ESSILOR     | MULTIFOCAL    | POLICARBONATO | 1.59            | MLTF624UJ | 15                | 197         | false | false | false         | false      | ATIVO  |
| d9f48cfa-69e2-4d22-ae21-0a6887e7f573 | e1e1eace-11b4-4f26-9f15-620808a4a410 | MULTI 1.49 TOP VIEW FF POLARIZADO VERDE AR FAST AZUL | SOBLOCOS    | MULTIFOCAL    | CR-39         | 1.49            | MLT3V0QZ2 | 10521             | 596         | true  | false | false         | true       | ATIVO  |
| 37ee2628-eb75-4aee-a678-2483880f29da | e1e1eace-11b4-4f26-9f15-620808a4a410 | ACOMODA HDI 1.67 AR FAST                             | SOBLOCOS    | VISAO SIMPLES | RESINA        | 1.67            | MLTWFZMXB | 12029             | 1140        | true  | false | false         | false      | ATIVO  |
| ed8d6314-7263-4c66-a562-f9f80bfaa819 | e1e1eace-11b4-4f26-9f15-620808a4a410 | MULTI 1.59 TOP VIEW FF POLARIZADO CINZA AR FAST      | SOBLOCOS    | MULTIFOCAL    | POLICARBONATO | 1.59            | MLTVTY3EN | 10524             | 620         | true  | false | false         | true       | ATIVO  |

vc tem que lembrar que não temos nada de lentes ativas, pois não é estoque, é sim um catalogo


-- 5. Ver dados dos fornecedores/laboratórios
SELECT 
  id,
  nome,
  cnpj,
  telefone,
  email
FROM fornecedores.fornecedores
WHERE ativo = true
LIMIT 10;
```

SELECT 
  id,
  nome,
  cnpj,
  telefone,
  email
FROM pessoas.fornecedores
LIMIT 10;
 

 queries correta

 | id                                   | nome                   | cnpj | telefone        | email                           |
| ------------------------------------ | ---------------------- | ---- | --------------- | ------------------------------- |
| 15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 | Brascor                | null | (11) 93047-3110 | vendas@brascorlab.com.br        |
| 3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 | Polylux                | null | (11) 4123-1319  | atendimento@polilux.com         |
| d90bebaf-e552-4cf0-a226-808c91bda73a | Kaizi Oculos Solares   | null | (11) 77777-7777 | contato@kaizi.com.br            |
| c50ea6eb-a420-4cf7-8aa2-68aaeb41ac95 | Navarro Oculos         | null | (11) 88888-8888 | contato@navarro.com.br          |
| e4a24408-3d58-4fc7-a096-cf7140f4f248 | Galeria Florencio lj11 | null | (11) 66666-6666 | contato@galeriaflorencio.com.br |
| 1d0b088f-dcb1-4179-9a18-5d67ce86c4b6 | Sao Paulo Acessorios   | null | (11) 99999-9999 | contato@spacessorios.com.br     |
| 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c | Express                | null | (11) 94165-8875 | lentesexpress25@gmail.com       |
| 43721f5b-4f4a-4a75-bb34-6e8b373c5948 | Braslentes             | null | (11) 91285-8758 | contato@braslentes.com.br       |
| d88018ac-ecae-4b38-b321-94babe5f85e3 | Style                  | null | (11) 91367-9326 | null                            |
| e1e1eace-11b4-4f26-9f15-620808a4a410 | So Blocos              | null | (11) 93778-3087 | null                            |

---

## 💡 **DECISÃO FINAL**

**🎯 ESTRATÉGIA ESCOLHIDA: Migrar TODOS os Produtos Primeiro, Normalizar Depois**

### **Por que essa abordagem?**

1. ✅ **Zero perda de dados**: Todas as 1.4k lentes migradas
2. ✅ **Segurança máxima**: Nada fica de fora
3. ✅ **Flexibilidade**: Podemos agrupar/normalizar no SIS Lens depois
4. ✅ **Auditoria**: Preserva dados originais completos
5. ✅ **Incremental**: Normalização pode ser feita gradualmente

### **Como vai funcionar:**

```
FASE 1: MIGRAÇÃO COMPLETA (1.4k produtos)
lente.fornecedores_lentes (Mello)
└─> suppliers.produtos_laboratorio (SIS Lens)
    ├─ sku_laboratorio: codigo_fornecedor
    ├─ nome_comercial: nome_lente
    ├─ sku_fantasia: sku_geral (gerado)
    └─ lente_id: NULL (temporariamente)

FASE 2: NORMALIZAÇÃO & AGRUPAMENTO
Analisar produtos migrados no SIS Lens
└─> Criar lens_catalog.lentes (canônicas)
    └─ Agrupar por: tipo + material + indice + tratamentos

FASE 3: VINCULAR PRODUTOS → LENTES
UPDATE produtos_laboratorio 
SET lente_id = (lente canônica correspondente)
```

### **Vantagens desta abordagem:**

- ✅ **Dados preservados**: Todos os 1.4k produtos no sistema
- ✅ **Preços originais**: Mantém preco_custo de cada fornecedor
- ✅ **Histórico completo**: Rastreabilidade total
- ✅ **Normalização controlada**: Fazemos no nosso ritmo
- ✅ **Sem dependência**: Não depende do catálogo_mello_lentes

---

## 📋 **PLANO DE EXECUÇÃO - 3 FASES**

---

### **📦 FASE 1: Migrar Produtos Laboratório (1.4k registros)**

**Objetivo**: Trazer TODOS os produtos de `lente.fornecedores_lentes` → `suppliers.produtos_laboratorio`

**Mapeamento de Campos:**

| Mello (fornecedores_lentes) | SIS Lens (produtos_laboratorio) | Transformação |
|------------------------------|----------------------------------|---------------|
| `id` | `id` (preservar UUID) | Direto |
| `fornecedor_id` | `laboratorio_id` | FK resolvida (já migrados) |
| `codigo_fornecedor` | `sku_laboratorio` | Direto |
| `nome_lente` | `nome_comercial` | Direto |
| `sku_geral` | `sku_fantasia` | Se NULL, gerar |
| - | `lente_id` | **NULL** (preencher depois) |
| - | `qualidade_base` | 3 (padrão) |
| `status = 'ativo'` | `disponivel` | TRUE/FALSE |
| - | `tenant_id` | Fixo: `550e8400...` |

**Query de Extração:**
```sql
SELECT 
  fl.id,
  fl.fornecedor_id,
  fl.codigo_fornecedor,
  fl.nome_lente,
  fl.marca_lente,
  fl.tipo_lente,
  fl.material,
  fl.indice_refracao,
  fl.sku_geral,
  fl.sku,
  fl.preco_custo,
  fl.status,
  fl.ar, fl.blue, fl.fotossensivel, fl.polarizado,
  fl.created_at
FROM lente.fornecedores_lentes fl
WHERE fl.status = 'ativo'
ORDER BY fl.fornecedor_id, fl.marca_lente, fl.tipo_lente;
```

**Script SQL de Inserção:**
- Gerar 1.4k INSERTs
- Mapear `fornecedor_id` para UUIDs já migrados
- Gerar `sku_fantasia` se necessário
- `lente_id` fica NULL temporariamente

---

### **🔬 FASE 2: Criar Lentes Canônicas (Normalização)**

**Objetivo**: Agrupar produtos similares em lentes canônicas

**Lógica de Agrupamento:**
```sql
-- Agrupar por características técnicas idênticas
GROUP BY 
  tipo_lente,
  material,
  indice_refracao,
  ar, blue, fotossensivel, polarizado
```

**Criar lentes canônicas:**
```sql
INSERT INTO lens_catalog.lentes (
  tenant_id,
  sku_canonico,
  marca_id,
  familia,
  design,
  material,
  indice_refracao,
  tratamentos,
  tipo_lente
)
SELECT 
  '550e8400-e29b-41d4-a716-446655440000'::uuid,
  -- Gerar SKU único
  'LENS-' || LPAD(ROW_NUMBER() OVER()::text, 4, '0'),
  -- Buscar marca_id
  (SELECT id FROM suppliers.marcas WHERE nome = marca_lente LIMIT 1),
  -- Extrair familia do nome
  SPLIT_PART(nome_lente, ' ', 1),
  -- Extrair design
  SPLIT_PART(nome_lente, ' ', 2),
  -- Material normalizado
  CASE material
    WHEN 'Policarbonato' THEN 'POLICARBONATO'::material_lente
    WHEN 'Resina' THEN 'CR39'::material_lente
    -- ... outros mapeamentos
  END,
  indice_refracao,
  -- Array de tratamentos
  ARRAY[
    CASE WHEN ar THEN 'AR'::tratamento_lente END,
    CASE WHEN blue THEN 'BLUE'::tratamento_lente END,
    CASE WHEN fotossensivel THEN 'PHOTOCHROMIC'::tratamento_lente END,
    CASE WHEN polarizado THEN 'POLARIZED'::tratamento_lente END
  ]::tratamento_lente[],
  -- Tipo normalizado
  CASE tipo_lente
    WHEN 'Monofocal' THEN 'MONOFOCAL'::tipo_lente
    WHEN 'Multifocal' THEN 'PROGRESSIVA'::tipo_lente
    -- ... outros mapeamentos
  END
FROM (
  -- Subquery com produtos únicos agrupados
  SELECT DISTINCT ON (tipo_lente, material, indice_refracao, ar, blue, fotossensivel, polarizado)
    *
  FROM suppliers.produtos_laboratorio
  WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid
) grouped;
```

---

### **🔗 FASE 3: Vincular Produtos → Lentes**

**Objetivo**: Atualizar `lente_id` nos produtos para apontar para lentes canônicas

```sql
UPDATE suppliers.produtos_laboratorio pl
SET lente_id = (
  SELECT l.id 
  FROM lens_catalog.lentes l
  WHERE l.tenant_id = pl.tenant_id
    AND l.tipo_lente = (CASE pl.tipo_lente_original ... END)
    AND l.material = (CASE pl.material_original ... END)
    AND l.indice_refracao = pl.indice_refracao
    -- Comparar tratamentos
    AND l.tratamentos @> ARRAY[...]
  LIMIT 1
)
WHERE pl.tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid;
```

**Validação Final:**
```sql
-- Produtos sem lente_id (órfãos)
SELECT COUNT(*) 
FROM suppliers.produtos_laboratorio 
WHERE lente_id IS NULL 
  AND tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid;

-- Distribuição: quantos produtos por lente canônica
SELECT 
  l.sku_canonico,
  l.familia,
  l.design,
  COUNT(pl.id) as qtd_produtos
FROM lens_catalog.lentes l
LEFT JOIN suppliers.produtos_laboratorio pl ON pl.lente_id = l.id
WHERE l.tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid
GROUP BY l.id, l.sku_canonico, l.familia, l.design
ORDER BY qtd_produtos DESC;
```

---

## 📊 **NOVA ORDEM DE MIGRAÇÃO**

```
✅ ORDEM DEFINITIVA:
1. ✅ Laboratórios (11 migrados)
2. ✅ Marcas (14 criadas)
3. 🆕 PRODUTOS LABORATÓRIO (1.4k - TODOS!)
   └─ lente.fornecedores_lentes → suppliers.produtos_laboratorio
   └─ lente_id = NULL (temporário)
   └─ Preservar preços individuais
4. 🆕 LENTES CANÔNICAS (Normalização)
   └─ Criar lens_catalog.lentes agrupando produtos
   └─ Gerar SKUs canônicos
   └─ ~200-300 lentes canônicas estimadas
5. 🔄 VINCULAR (UPDATE)
   └─ Atualizar produtos_laboratorio.lente_id
   └─ Resolver FKs
6. ✅ PREÇOS (se necessário ajuste)
   └─ Já vieram com os produtos
7. ✅ PRAZOS
   └─ lead_time schema
```

---

## 🤔 **PERGUNTAS PARA VOCÊ (QUERIES SIMPLIFICADAS)**

Execute estas 3 queries essenciais no Mello:

### **Query 1: Contagem Geral**
```sql
SELECT 
  (SELECT COUNT(*) FROM lente.fornecedores_lentes WHERE status = 'ativo') as produtos_ativos,
  (SELECT COUNT(DISTINCT fornecedor_id) FROM lente.fornecedores_lentes WHERE status = 'ativo') as fornecedores_unicos,
  (SELECT COUNT(DISTINCT marca_lente) FROM lente.fornecedores_lentes WHERE status = 'ativo' AND marca_lente IS NOT NULL) as marcas_unicas;
```

### **Query 2: Estrutura dos Campos (5 exemplos)**
```sql
SELECT 
  id,
  fornecedor_id,
  codigo_fornecedor,
  nome_lente,
  marca_lente,
  tipo_lente,
  material,
  indice_refracao,
  sku_geral,
  preco_custo,
  ar, blue, fotossensivel, polarizado,
  status
FROM lente.fornecedores_lentes
WHERE status = 'ativo' AND preco_custo > 0
ORDER BY created_at DESC
LIMIT 5;
```

### **Query 3: Mapeamento Fornecedores**
```sql
SELECT 
  f.id as fornecedor_id,
  f.nome as fornecedor_nome,
  COUNT(fl.id) as qtd_produtos
FROM fornecedores.fornecedores f
LEFT JOIN lente.fornecedores_lentes fl ON fl.fornecedor_id = f.id AND fl.status = 'ativo'
WHERE f.ativo = true
GROUP BY f.id, f.nome
ORDER BY qtd_produtos DESC;
```

---

## 🚀 **PRÓXIMOS PASSOS IMEDIATOS**

1. **Execute as 3 queries acima** e cole os resultados
2. **Vou criar o documento de Migração 03** - Produtos Laboratório (1.4k)
3. **Depois criamos Migração 04** - Lentes Canônicas (normalização)
4. **Por fim Migração 05** - Vincular produtos → lentes

**Pode executar as queries? Com os resultados eu monto o script completo!** 🎯
