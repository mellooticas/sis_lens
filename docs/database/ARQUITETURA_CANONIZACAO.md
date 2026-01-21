# 🎯 ARQUITETURA DE CANONIZAÇÃO - SIS LENS

## 📌 PROPÓSITO DO SISTEMA

**Problema:** Múltiplos laboratórios vendem lentes IDÊNTICAS com nomes diferentes
**Solução:** Sistema de canonização que agrupa lentes equivalentes

### Exemplo Real:
```
Laboratório A: "Multifocal Premium CR39 1.50 AR+UV"
Laboratório B: "Lente Progressive Base 150 Antireflexo"
Laboratório C: "Multi 1.50 com tratamento AR"

→ TODAS SÃO A MESMA LENTE CANÔNICA!
```

---

## 🗂️ ESTRUTURA ATUAL DO BANCO (3 schemas principais)

### 1️⃣ **lens_catalog** - Canonização e Catálogo
### 2️⃣ **core** - Fornecedores/Laboratórios
### 3️⃣ **compras** - Pedidos e Estoque (não usado ainda)

---

## 📊 TABELAS E PROPÓSITO

### **lens_catalog** (8 tabelas)

| Tabela | Registros | Propósito | Status |
|--------|-----------|-----------|--------|
| **lentes** | 1.411 | **Produtos reais dos laboratórios** | ✅ CORE |
| **grupos_canonicos** | 461 | **Lentes agrupadas por equivalência** | ✅ CORE |
| **marcas** | 17 | Marcas das lentes (SO BLOCOS, TRANSITIONS, etc) | ✅ Ativo |
| **lentes_canonicas** | ? | Referência genérica (não premium) | ⚠️ Não usado? |
| **premium_canonicas** | ? | Referência premium (Varilux, etc) | ⚠️ Não usado? |
| **grupos_canonicos_backup_old** | ? | Backup histórico | 📦 Backup |
| **stg_lentes_import** | ? | Staging para importação | 🔄 ETL |
| **grupos_canonicos_log** | ? | Log de mudanças | 📝 Auditoria |

---

## 🔗 FLUXO DE CANONIZAÇÃO

```
IMPORTAÇÃO
│
├─→ [1] stg_lentes_import (staging)
│    ↓
├─→ [2] lentes (produtos dos labs)
│    ├── fornecedor_id → core.fornecedores
│    ├── marca_id → lens_catalog.marcas
│    └── grupo_canonico_id → grupos_canonicos ⭐
│
├─→ [3] TRIGGER automático associa ao grupo
│    fn_associar_lente_grupo_automatico()
│    ↓
│    Analisa: tipo + material + índice + tratamentos
│    Busca grupo existente OU cria novo
│    ↓
└─→ [4] grupos_canonicos (lentes equivalentes)
     ├── total_lentes (contador automático)
     ├── preco_medio (calculado)
     └── triggers atualizam estatísticas
```

---

## ✅ O QUE ESTÁ FUNCIONANDO

### 1. **Canonização Automática** ✅
- **100% das lentes** estão em grupos (0 órfãs!)
- 1.411 lentes → 461 grupos
- Média: **3 lentes por grupo** (mesma especificação, labs diferentes)

### 2. **Triggers Automáticos** ✅
```sql
-- Quando insere/atualiza lente
fn_associar_lente_grupo_automatico()
  → Atribui automaticamente ao grupo correto

-- Quando muda grupo
fn_atualizar_estatisticas_grupo()
  → Recalcula: total_lentes, preco_medio, ranges

-- Auditoria
fn_auditar_grupos()
  → Log em grupos_canonicos_log
```

### 3. **Preços dos Grupos** ✅
- Grupos têm `preco_medio` correto (R$ 2.424 - R$ 7.314)
- Calcula média ponderada das lentes do grupo

---

## ⚠️ PROBLEMAS IDENTIFICADOS

### 1. **Preços Individuais Zerados** 🔴 CRÍTICO
```
lens_catalog.lentes.preco_tabela = 0.00 (todas!)
lens_catalog.lentes.custo_base = 0.00
lens_catalog.lentes.preco_fabricante = NULL
```
**Impacto:** Não pode fazer cotação por lab específico
**Solução:** Preencher preços individuais OU usar só preços dos grupos

### 2. **Campos Duplicados** 🔴 CRÍTICO
```sql
-- 100% das lentes têm valores diferentes:
grau_esferico_min != esferico_min
tratamento_antirreflexo != ar (44%)
diametro_mm != diametro
```
**Impacto:** Dados corrompidos, queries inconsistentes
**Solução:** Normalizar para um único conjunto de campos

### 3. **Tratamentos Vazios** 🟡 MÉDIO
```
ar, blue, antirrisco, polarizado = false (todos!)
fotossensivel = 'nenhum' (todos!)
```
**Mas o nome_grupo TEM os tratamentos:** "+AR +UV +BlueLight"
**Solução:** Extrair do nome_grupo e popular campos booleanos

### 4. **Tabelas Sem Uso Claro** 🟡 MÉDIO
```
lens_catalog.lentes_canonicas (?)
lens_catalog.premium_canonicas (?)
```
**Impacto:** Confusão arquitetural
**Solução:** Definir propósito OU remover

---

## 🎯 ARQUITETURA RECOMENDADA

### **MODELO 1: Grupos como Única Fonte** (mais simples)

```
grupos_canonicos (fonte principal)
  ↓
  lentes (variações por laboratório)
    ├── preco_custo (preço do lab)
    ├── prazo_entrega (prazo do lab)
    └── fornecedor_id
```

**Vantagem:** Simples, já funciona
**Desvantagem:** Perde granularidade de preços por lab

---

### **MODELO 2: Canônicas + Premium** (mais estruturado)

```
lentes_canonicas (genéricas)
  ├── Ex: "CR39 1.50 Multifocal"
  └── Specs técnicas padronizadas

premium_canonicas (marcas premium)
  ├── Ex: "Varilux X Series"
  ├── marca_id (Essilor, Zeiss, etc)
  └── linha_produto

grupos_canonicos (agrupamento)
  └── Junta canônicas + premium

lentes (produtos dos labs)
  ├── lente_canonica_id (se genérica)
  ├── premium_canonica_id (se premium)
  ├── grupo_canonico_id
  └── Preços/prazos específicos do lab
```

**Vantagem:** Separação clara genérico/premium
**Desvantagem:** Mais complexo, precisa popular

---

## 📋 TABELAS A REVISAR/LIMPAR

### ✅ **MANTER (core do sistema)**
1. `lens_catalog.lentes` - Produtos dos labs
2. `lens_catalog.grupos_canonicos` - Canonização
3. `lens_catalog.marcas` - Marcas
4. `core.fornecedores` - Laboratórios

### ❓ **DEFINIR PROPÓSITO**
5. `lens_catalog.lentes_canonicas` - Usar OU remover?
6. `lens_catalog.premium_canonicas` - Usar OU remover?

### 🗑️ **CONSIDERAR REMOVER**
7. `lens_catalog.grupos_canonicos_backup_old` - Backup antigo
8. `lens_catalog.lentes_grupos_backup_old` - Backup antigo

### 🔄 **STAGING/LOG (manter)**
9. `lens_catalog.stg_lentes_import` - ETL
10. `lens_catalog.grupos_canonicos_log` - Auditoria

### ⚠️ **SCHEMAS NÃO USADOS**
11. `compras.*` - Sistema de pedidos (0 registros)
12. `contact_lens` - Schema vazio

---

## 🔧 CORREÇÕES PRIORITÁRIAS

### 1. **Normalizar Campos Duplicados** 🔴 URGENTE
```sql
-- Decisão: Usar qual conjunto?
-- Opção A: grau_esferico_min/max (remover esferico_min/max)
-- Opção B: esferico_min/max (remover grau_esferico_min/max)

-- Após decidir:
ALTER TABLE lens_catalog.lentes
DROP COLUMN grau_esferico_min,
DROP COLUMN grau_esferico_max;

-- Mesma coisa para:
-- - tratamento_antirreflexo vs ar
-- - diametro_mm vs diametro
```

### 2. **Popular Tratamentos dos Grupos** 🔴 URGENTE
```sql
-- Extrair do nome_grupo e setar campos booleanos
UPDATE lens_catalog.lentes l
SET
  ar = (gc.nome_grupo LIKE '%+AR%'),
  blue = (gc.nome_grupo LIKE '%+Blue%'),
  uv400 = (gc.nome_grupo LIKE '%+UV%'),
  fotossensivel = CASE
    WHEN gc.nome_grupo LIKE '%fotocromático%' THEN 'fotocromático'
    WHEN gc.nome_grupo LIKE '%Transitions%' THEN 'transitions'
    ELSE 'nenhum'
  END
FROM lens_catalog.grupos_canonicos gc
WHERE l.grupo_canonico_id = gc.id;
```

### 3. **Preencher Preços** 🟡 IMPORTANTE
```sql
-- Opção A: Copiar do grupo (simples)
UPDATE lens_catalog.lentes l
SET preco_tabela = gc.preco_medio
FROM lens_catalog.grupos_canonicos gc
WHERE l.grupo_canonico_id = gc.id;

-- Opção B: Importar preços reais dos labs (melhor)
-- Depende de ter fonte externa de dados
```

### 4. **Definir Uso das Canônicas** 🟡 IMPORTANTE
```sql
-- Se usar o MODELO 2:
-- Popular lentes_canonicas e premium_canonicas
-- Linkar lentes a elas

-- Se NÃO usar:
DROP TABLE lens_catalog.lentes_canonicas;
DROP TABLE lens_catalog.premium_canonicas;
```

---

## 🎬 QUERIES PARA APPS (simplificadas)

### **Use os GRUPOS como unidade principal**

```sql
-- 1. Listar lentes canonizadas
SELECT * FROM lens_catalog.grupos_canonicos
WHERE ativo = true AND total_lentes > 0
ORDER BY preco_medio;

-- 2. Ver variações de um grupo (labs diferentes)
SELECT
  l.id,
  l.nome_comercial,
  f.nome as laboratorio,
  l.preco_tabela, -- ⚠️ zerado, usar gc.preco_medio
  f.prazo_visao_simples
FROM lens_catalog.lentes l
JOIN core.fornecedores f ON l.fornecedor_id = f.id
WHERE l.grupo_canonico_id = 'uuid-do-grupo'
  AND l.ativo = true;

-- 3. Buscar por especificação
SELECT * FROM lens_catalog.grupos_canonicos
WHERE tipo_lente = 'multifocal'
  AND material = 'CR39'
  AND indice_refracao = '1.50'
  AND nome_grupo LIKE '%+AR%' -- tem AR
ORDER BY preco_medio;
```

---

## 📊 ESTATÍSTICAS DO SISTEMA

### Canonização Atual:
```
1.411 lentes de labs
  ↓ agrupadas em
461 grupos canônicos
  ↓ resultado:
3,06 lentes/grupo (média)
```

### Distribuição:
- **36 lentes** no maior grupo (CR39 1.50 Multifocal +UV)
- **461 grupos** ativos
- **0 lentes órfãs** (100% canonizadas!)

### Labs:
- **So Blocos**: 1.097 lentes (78%)
- **Polylux**: 158 lentes (11%)
- **Express**: 84 lentes (6%)
- **Outros**: 72 lentes (5%)

---

## 🚀 PRÓXIMOS PASSOS

### Fase 1: Limpeza (1-2 dias)
1. ✅ Normalizar campos duplicados
2. ✅ Popular tratamentos
3. ✅ Definir canônicas/premium

### Fase 2: Preços (3-5 dias)
4. ✅ Importar/preencher preços individuais
5. ✅ Validar cálculo de preco_medio

### Fase 3: API Simplificada (2-3 dias)
6. ✅ Criar views finais para apps
7. ✅ Documentar endpoints Supabase
8. ✅ Testar queries de busca

---

**Última atualização:** 20/01/2026
**Versão:** Produção (ahcikwsoxhmqqteertkx)
