# 🔍 Análise Completa dos Dados do Mello

**Data**: 06/10/2025  
**Status**: ✅ **ANÁLISE CONCLUÍDA**

---

## 📊 **DADOS QUANTITATIVOS**

### **Resumo Geral:**

| Métrica | Quantidade | Observação |
|---------|-----------|------------|
| **Produtos Totais** | 1,411 | Todos os produtos (sem filtro de status) |
| **Lentes Canônicas** | 265 | Já normalizadas no catalogo_mello_lentes |
| **Fornecedores Únicos** | 5 | Apenas 5 laboratórios ativos |
| **Marcas Únicas** | 6 | 6 marcas diferentes |

### **Proporção:**
- **Média de produtos por lente canônica**: 1,411 / 265 = ~5.3 produtos por lente
- **Catálogo já tem boa normalização**: 265 lentes canônicas é um número razoável

---

## 🏭 **FORNECEDORES/LABORATÓRIOS**

### **Lista Completa (10 registros encontrados):**

| ID | Nome | Status | Observação |
|----|------|--------|------------|
| `15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1` | **Brascor** | ✅ Migrado | Já existe no SIS Lens |
| `3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21` | **Polylux** | ✅ Migrado | Já existe no SIS Lens |
| `d90bebaf-e552-4cf0-a226-808c91bda73a` | **Kaizi Oculos Solares** | ⚠️ ARMAÇÕES | Não é laboratório de lentes! |
| `c50ea6eb-a420-4cf7-8aa2-68aaeb41ac95` | **Navarro Oculos** | ⚠️ ARMAÇÕES | Não é laboratório de lentes! |
| `e4a24408-3d58-4fc7-a096-cf7140f4f248` | **Galeria Florencio lj11** | ⚠️ ARMAÇÕES | Não é laboratório de lentes! |
| `1d0b088f-dcb1-4179-9a18-5d67ce86c4b6` | **Sao Paulo Acessorios** | ✅ Migrado | Já existe no SIS Lens |
| `8eb9498c-3d99-4d26-bb8c-e503f97ccf2c` | **Express** | ✅ Migrado | Já existe no SIS Lens |
| `43721f5b-4f4a-4a75-bb34-6e8b373c5948` | **Braslentes** | ✅ Migrado | Já existe no SIS Lens |
| `d88018ac-ecae-4b38-b321-94babe5f85e3` | **Style** | ✅ Migrado | Já existe no SIS Lens |
| `e1e1eace-11b4-4f26-9f15-620808a4a410` | **So Blocos** | ✅ Migrado | Já existe no SIS Lens (Só Blocos) |

### **🚨 PROBLEMA IDENTIFICADO:**
- **3 fornecedores são de ARMAÇÕES, não lentes**: Kaizi, Navarro, Galeria Florencio
- **7 laboratórios válidos**: Já foram todos migrados!
- **Mapeamento perfeito**: Todos os labs de lentes já existem no SIS Lens

---

## 🔬 **CATÁLOGO NORMALIZADO (Top 10)**

### **Insights do catalogo_mello_lentes:**

| SKU | Nome Comercial | Marca | Material | Índice | Qtd Agregada | Preço Médio |
|-----|---------------|-------|----------|--------|--------------|-------------|
| LVN000019 | LensVision Progressiva CR39 1.49 Foto | GENERICA | CR-39 | 1.49 | **39** | R$ 1,159.54 |
| LVN000012 | LensVision Progressiva Resina 1.67 | GENERICA | RESINA | 1.67 | **30** | R$ 1,200.47 |
| LVN000011 | LensVision Progressiva Policarbonato 1.59 | GENERICA | POLICARBONATO | 1.59 | **30** | R$ 691.03 |
| LVN000048 | LensVision Progressiva Resina 1.67 Blue | GENERICA | RESINA | 1.67 | **30** | R$ 1,163.20 |
| LVN000047 | LensVision Progressiva Policarbonato 1.59 Blue | GENERICA | POLICARBONATO | 1.59 | **28** | R$ 685.43 |

### **🎯 DESCOBERTAS IMPORTANTES:**

1. **Marca "GENERICA"**: Catálogo usa "GENERICA" como marca padrão
2. **Tipo "FREE FORM"**: Produtos Mello usam este tipo (não existe no SIS Lens)
3. **Agregação eficiente**: Top lente tem 39 produtos agregados
4. **SKU Pattern**: `LVN` + 6 dígitos (ex: LVN000019)
5. **Sem fornecedor**: `catalogo_mello_lentes` é independente de fornecedor
6. **Link**: `lente_representante_id` aponta para UM produto representativo

---

## 📦 **PRODUTOS REAIS (Exemplos)**

### **Análise dos 5 produtos mais recentes:**

#### **Produto 1:**
- **Fornecedor**: So Blocos (`e1e1eace-11b4-4f26-9f15-620808a4a410`)
- **Nome**: MULTI 1.67 FREEVIEW HD FOTO AR FAST
- **Marca**: SOBLOCOS
- **Tipo**: FREE FORM
- **Material**: RESINA
- **Índice**: 1.67
- **Código**: 10483
- **Preço**: R$ 1,180.00
- **Tratamentos**: AR = true, outros = false
- **Status**: ATIVO

#### **Produto 2:**
- **Fornecedor**: Polylux (`3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21`)
- **Nome**: ESPACE POLICARBONATO
- **Marca**: ESSILOR
- **Tipo**: MULTIFOCAL
- **Material**: POLICARBONATO
- **Índice**: 1.59
- **Código**: 15
- **Preço**: R$ 197.00
- **Tratamentos**: Todos false
- **Status**: ATIVO

#### **Produto 3:**
- **Fornecedor**: So Blocos
- **Nome**: MULTI 1.49 TOP VIEW FF POLARIZADO VERDE AR FAST AZUL
- **Marca**: SOBLOCOS
- **Tipo**: MULTIFOCAL
- **Material**: CR-39
- **Índice**: 1.49
- **Preço**: R$ 596.00
- **Tratamentos**: AR = true, polarizado = true

### **🔍 PADRÕES IDENTIFICADOS:**

1. **Status**: Todos são "ATIVO" (não "ativo" minúsculo)
2. **Tipos de lente no Mello**:
   - `FREE FORM` (não existe no SIS Lens!)
   - `MULTIFOCAL` (mapear para PROGRESSIVA)
   - `VISAO SIMPLES` (mapear para MONOFOCAL)
3. **Materiais no Mello**:
   - `RESINA` (mapear para HIGH_INDEX ou CR39)
   - `POLICARBONATO` (existe no SIS Lens)
   - `CR-39` (existe no SIS Lens)
4. **Marcas reais**: SOBLOCOS, ESSILOR (produtos têm marcas específicas)
5. **Tratamentos**: Campos booleanos (ar, blue, fotossensivel, polarizado)
6. **SKU Geral**: Nem sempre preenchido (vários NULL)

---

## 🚨 **PROBLEMAS E DESAFIOS IDENTIFICADOS**

### **1. Tipo de Lente "FREE FORM"**

❌ **Problema**: `FREE FORM` não existe no enum `tipo_lente` do SIS Lens

**Enum SIS Lens:**
```sql
CREATE TYPE tipo_lente AS ENUM (
  'MONOFOCAL',
  'BIFOCAL', 
  'PROGRESSIVA',
  'OCUPACIONAL'
);
```

**Solução necessária:**
- Mapear `FREE FORM` → `PROGRESSIVA` (mais comum)
- Ou criar lógica para detectar se é mono/progressiva pelo nome
- Ou adicionar `FREE_FORM` ao enum (requer migration)

### **2. Tipo de Lente "VISAO SIMPLES"**

❌ **Mello usa**: `VISAO SIMPLES`  
✅ **SIS Lens usa**: `MONOFOCAL`

**Mapeamento simples**: `VISAO SIMPLES` → `MONOFOCAL`

### **3. Material "RESINA" Ambíguo**

❌ **Problema**: "RESINA" pode ser:
- `CR39` (índice 1.49-1.50)
- `HIGH_INDEX_156` (índice 1.56)
- `HIGH_INDEX_160` (índice 1.60)
- `HIGH_INDEX_167` (índice 1.67)
- `HIGH_INDEX_174` (índice 1.74)

**Solução**: Mapear por **índice de refração**:
```sql
CASE 
  WHEN material = 'RESINA' AND indice_refracao = 1.49 THEN 'CR39'
  WHEN material = 'RESINA' AND indice_refracao = 1.50 THEN 'CR39'
  WHEN material = 'RESINA' AND indice_refracao = 1.56 THEN 'HIGH_INDEX_156'
  WHEN material = 'RESINA' AND indice_refracao = 1.60 THEN 'HIGH_INDEX_160'
  WHEN material = 'RESINA' AND indice_refracao = 1.67 THEN 'HIGH_INDEX_167'
  WHEN material = 'RESINA' AND indice_refracao = 1.74 THEN 'HIGH_INDEX_174'
END
```

### **4. Fornecedores de Armações nos Dados**

⚠️ **3 fornecedores não são de lentes**:
- Kaizi Oculos Solares
- Navarro Oculos
- Galeria Florencio lj11

**Solução**: Filtrar produtos desses fornecedores na migração

### **5. Status "ATIVO" vs "ativo"**

❌ **Mello usa**: `ATIVO` (maiúsculo)  
⚠️ **Sua query filtrava**: `status = 'ativo'` (minúsculo)

**Impacto**: Por isso você viu 1,411 produtos SEM filtro, mas possivelmente menos com filtro correto

**Query corrigida**: `WHERE status = 'ATIVO'` ou `WHERE UPPER(status) = 'ATIVO'`

---

## 📋 **MAPEAMENTO COMPLETO DE CAMPOS**

### **Mello → SIS Lens:**

| Mello Campo | Tipo | SIS Lens Campo | Transformação |
|-------------|------|----------------|---------------|
| `id` | UUID | `id` | Preservar UUID |
| `fornecedor_id` | UUID | `laboratorio_id` | Mapear UUIDs já migrados |
| `codigo_fornecedor` | TEXT | `sku_laboratorio` | Direto |
| `nome_lente` | TEXT | `nome_comercial` | Direto |
| `marca_lente` | TEXT | - | Usar para buscar marca_id |
| `tipo_lente` | TEXT | - | Mapear para enum (FASE 2) |
| `material` | TEXT | - | Mapear com índice (FASE 2) |
| `indice_refracao` | NUMERIC | - | Usar na normalização (FASE 2) |
| `sku_geral` | TEXT | `sku_fantasia` | Se NULL, gerar |
| `sku` | TEXT | - | Backup se sku_geral NULL |
| `preco_custo` | NUMERIC | - | Migrar para precos_base |
| `status` | TEXT | `disponivel` | `'ATIVO'` → `true` |
| `ar` | BOOLEAN | - | Array tratamentos (FASE 2) |
| `blue` | BOOLEAN | - | Array tratamentos (FASE 2) |
| `fotossensivel` | BOOLEAN | - | Array tratamentos (FASE 2) |
| `polarizado` | BOOLEAN | - | Array tratamentos (FASE 2) |
| `created_at` | TIMESTAMP | `criado_em` | Preservar |

---

## 🎯 **RECOMENDAÇÕES FINAIS**

### **✅ O QUE FAZER:**

1. **Migrar FASE 1** (Produtos):
   - Filtrar: `WHERE status = 'ATIVO'`
   - Excluir fornecedores de armações (Kaizi, Navarro, Galeria)
   - Preservar UUIDs
   - `lente_id = NULL` (preencher na FASE 3)

2. **FASE 2** (Normalização):
   - Usar `catalogo_mello_lentes` como **referência**
   - Criar 265 lentes canônicas
   - Mapear tipos e materiais corretamente

3. **FASE 3** (Vincular):
   - Usar `sku_normalizado` do catálogo para linking
   - Produtos órfãos: analisar caso a caso

### **⚠️ DECISÕES NECESSÁRIAS:**

1. **FREE FORM**: Mapear para PROGRESSIVA ou adicionar ao enum?
2. **Catálogo Mello**: Usar como base ou criar do zero?
3. **Órfãos**: O que fazer com produtos sem correspondência canônica?

---

## 📊 **ESTATÍSTICAS ESTIMADAS PÓS-MIGRAÇÃO**

| Métrica | Estimativa |
|---------|-----------|
| Produtos migrados | ~1,350-1,400 (excluindo armações) |
| Lentes canônicas | ~265 (do catálogo) |
| Produtos por lente | ~5.3 em média |
| Fornecedores válidos | 7 (todos já migrados) |
| Marcas | 6 (SOBLOCOS, ESSILOR, etc.) |

---

## 🚀 **PRÓXIMO PASSO**

**Criar documento de Migração 03** com:
- Script SQL completo
- Mapeamento de UUIDs de fornecedores
- Filtros corretos (status, fornecedores válidos)
- Transformações de dados
- Queries de validação

**Posso criar agora?** 🎯
