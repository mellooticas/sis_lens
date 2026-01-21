# 📱 APIs RECOMENDADAS PARA APPS - SIS LENS

## 🎯 OBJETIVO
Este documento define **exatamente quais views/queries** os apps devem consumir do Supabase para evitar confusão com a estrutura complexa do banco.

---

## ⚠️ PROBLEMAS ATUAIS DO BANCO

### 🚨 Crítico - Dados Faltando:
1. **Preços zerados**: Todas as 1.411 lentes têm `preco_tabela = 0.00`
2. **Tratamentos vazios**: Campos `ar`, `blue`, `antirrisco` todos = false
3. **Estoque vazio**: Sistema de estoque não está sendo usado
4. **Campos duplicados**: 100% das lentes têm `grau_esferico_min != esferico_min`

### ✅ O que funciona:
- Estrutura de grupos canônicos (461 grupos com preços)
- Fornecedores (5 ativos)
- Marcas (7 ativas)
- Relacionamentos entre tabelas

---

## 📊 VIEWS RECOMENDADAS (JÁ EXISTEM NO BANCO)

### 1️⃣ **Catálogo de Lentes** - `public.v_lentes_catalogo`

**Use para:** Listagem principal de lentes no app

```sql
SELECT * FROM public.v_lentes_catalogo
WHERE ativo = true
  AND disponivel = true
ORDER BY peso DESC, preco_venda_sugerido
LIMIT 50;
```

**Campos importantes:**
- `id`, `slug`, `nome_canonizado`
- `fornecedor_nome`, `marca_nome`
- `tipo_lente`, `material`, `indice_refracao`
- `tratamento_antirreflexo`, `tratamento_blue_light`, etc
- `preco_venda_sugerido` ⚠️ (atualmente zerado)
- `estoque_disponivel` ⚠️ (atualmente 0)

---

### 2️⃣ **Grupos Canônicos** - `public.v_grupos_canonicos`

**Use para:** Comparar lentes similares

```sql
SELECT * FROM public.v_grupos_canonicos
WHERE ativo = true
  AND total_lentes > 0
ORDER BY preco_medio;
```

**Campos importantes:**
- `nome_grupo` - Ex: "Lente CR39 1.50 Multifocal +UV"
- `tipo_lente`, `material`, `indice_refracao`
- `tratamento_antirreflexo`, `tratamento_uv`, etc
- `total_lentes` - Quantas lentes neste grupo
- `preco_minimo`, `preco_maximo`, `preco_medio` ✅ (preenchidos!)

**💡 RECOMENDAÇÃO:** Use os **preços dos grupos** ao invés dos preços individuais das lentes (que estão zerados)

---

### 3️⃣ **Grupos com Lentes** - `public.v_grupos_com_lentes`

**Use para:** Exibir grupo + lentes disponíveis em JSON

```sql
SELECT * FROM public.v_grupos_com_lentes
WHERE grupo_id = 'uuid-do-grupo'
LIMIT 1;
```

**Retorna:** JSON com array de lentes do grupo
```json
{
  "grupo_id": "...",
  "nome_grupo": "...",
  "preco_medio": 2424.77,
  "lentes": [
    {
      "id": "...",
      "slug": "...",
      "nome": "...",
      "fornecedor_nome": "So Blocos",
      "marca": "SO BLOCOS",
      "preco": 2424.77,
      "prazo_dias": 7,
      "tratamentos": {
        "ar": true,
        "blue": false,
        "uv": true
      }
    }
  ]
}
```

---

### 4️⃣ **Busca de Lentes** - `public.v_lentes_busca`

**Use para:** Busca full-text

```sql
SELECT * FROM public.v_lentes_busca
WHERE search_text ILIKE '%transitions%'
  OR search_text ILIKE '%multifocal%'
LIMIT 20;
```

---

### 5️⃣ **Fornecedores** - `public.v_fornecedores_catalogo`

**Use para:** Listar fornecedores disponíveis

```sql
SELECT * FROM public.v_fornecedores_catalogo
WHERE ativo = true
ORDER BY prazo_visao_simples, nome;
```

**Retorna:**
```json
[
  {
    "nome": "Express",
    "prazo_visao_simples": 3,
    "prazo_multifocal": 5,
    "total_lentes": 84,
    "preco_minimo": 0.00,
    "badge_prazo": "express"
  }
]
```

---

### 6️⃣ **Grupos por Faixa de Preço** - `public.v_grupos_por_faixa_preco`

**Use para:** Navegação por categoria de preço

```sql
SELECT * FROM public.v_grupos_por_faixa_preco
WHERE faixa_ordem = 2 -- Básico (R$150-300)
ORDER BY preco_medio;
```

**Faixas disponíveis:**
1. Entrada (< R$150)
2. Básico (R$150-300)
3. Intermediário (R$300-500)
4. Premium (R$500-800)
5. Super Premium (R$800+)

---

### 7️⃣ **Análise de Margem** - `public.v_grupos_melhor_margem`

**Use para:** Recomendações com melhor lucratividade

```sql
SELECT * FROM public.v_grupos_melhor_margem
WHERE margem_percentual >= 400 -- 400% de margem
ORDER BY margem_percentual DESC
LIMIT 10;
```

**Campos:**
- `margem_percentual` - Ex: 450.5 (450.5%)
- `lucro_unitario` - Ex: R$ 1.200,00
- `classificacao_margem` - "Excelente", "Ótima", "Boa"

---

### 8️⃣ **Sugestões de Upgrade** - `public.v_sugestoes_upgrade`

**Use para:** Upsell automático

```sql
SELECT * FROM public.v_sugestoes_upgrade
WHERE grupo_base_id = 'uuid-do-grupo-atual'
ORDER BY diferenca_preco
LIMIT 3;
```

**Retorna:**
```json
[
  {
    "grupo_upgrade_nome": "Lente CR39 1.50 Multifocal +AR +UV",
    "preco_upgrade": 2424.77,
    "diferenca_preco": 195.54,
    "diferenca_percentual": 8.06,
    "tratamentos_adicionais": ["Antirreflexo"],
    "beneficios": "Visão mais nítida e sem reflexos + estética melhor"
  }
]
```

---

### 9️⃣ **Busca por Receita Médica** - Função `public.buscar_lentes_por_receita()`

**Use para:** Filtrar lentes compatíveis com receita do cliente

```sql
SELECT * FROM public.buscar_lentes_por_receita(
  p_esferico := -2.00,
  p_cilindrico := -1.00,
  p_adicao := 2.00,
  p_tipo_lente := 'multifocal'
);
```

---

### 🔟 **Estatísticas** - `public.v_estatisticas_catalogo`

**Use para:** Dashboard/Analytics

```sql
SELECT * FROM public.v_estatisticas_catalogo;
```

**Retorna:**
```json
{
  "total_lentes": 1411,
  "total_marcas": 17,
  "total_fornecedores": 11,
  "total_grupos": 461,
  "lentes_visao_simples": 150,
  "lentes_multifocal": 1261,
  "preco_minimo_geral": 0.00,
  "preco_maximo_geral": 0.00,
  "preco_medio_geral": 0.00
}
```

---

## 🚫 **O QUE OS APPS NÃO DEVEM USAR**

### ❌ Tabela `lens_catalog.lentes` diretamente
**Motivo:** 86 colunas com muita redundância e campos duplicados

### ❌ Campo `preco_tabela` da tabela lentes
**Motivo:** Todos zerados (0.00)

### ❌ Campos de tratamento individuais (ar, blue, antirrisco, etc)
**Motivo:** Todos false/vazios atualmente

### ❌ Sistema de estoque (`compras.estoque_saldo`)
**Motivo:** Vazio (0 registros)

---

## ✅ **ESTRATÉGIA RECOMENDADA**

### Para Apps de Vendas/Cotação:

**1. Listar Produtos:**
```sql
-- Use grupos canônicos (têm preços corretos)
SELECT * FROM public.v_grupos_canonicos
WHERE ativo = true AND total_lentes > 0
ORDER BY preco_medio;
```

**2. Detalhes de um Grupo:**
```sql
-- Pegue o grupo + lentes em JSON
SELECT * FROM public.v_grupos_com_lentes
WHERE grupo_id = '...';
```

**3. Buscar por Receita:**
```sql
-- Função já filtra por ranges de grau
SELECT * FROM public.buscar_lentes_por_receita(
  p_esferico := -2.00,
  p_cilindrico := -1.00,
  p_adicao := 2.00,
  p_tipo_lente := 'multifocal'
);
```

**4. Upsell:**
```sql
-- Sugere upgrades automáticos
SELECT * FROM public.v_sugestoes_upgrade
WHERE grupo_base_id = '...'
LIMIT 3;
```

---

## 🔧 **CORREÇÕES URGENTES NECESSÁRIAS**

### 1. Preencher Preços ⚠️ CRÍTICO
```sql
-- Exemplo: copiar preços dos grupos para as lentes
UPDATE lens_catalog.lentes l
SET preco_tabela = gc.preco_medio
FROM lens_catalog.grupos_canonicos gc
WHERE l.grupo_canonico_id = gc.id
  AND l.preco_tabela = 0;
```

### 2. Normalizar Campos Duplicados
```sql
-- Usar apenas esferico_min/max (remover grau_esferico_min/max)
-- Usar apenas ar (remover tratamento_antirreflexo)
```

### 3. Popular Tratamentos
```sql
-- Extrair tratamentos do nome_grupo e popular campos booleanos
-- Ex: se nome_grupo contém "+AR", setar ar = true
```

### 4. Definir Destaques/Novidades
```sql
-- Marcar produtos estratégicos
UPDATE lens_catalog.lentes
SET destaque = true
WHERE grupo_canonico_id IN (
  SELECT id FROM lens_catalog.grupos_canonicos
  WHERE total_lentes >= 20
  ORDER BY preco_medio
  LIMIT 10
);
```

---

## 📡 **EXEMPLO DE INTEGRAÇÃO (JavaScript/TypeScript)**

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)

// 1. Listar grupos (categorias de lentes)
async function listarGrupos(tipo?: string) {
  let query = supabase
    .from('v_grupos_canonicos')
    .select('*')
    .eq('ativo', true)
    .gt('total_lentes', 0)
    .order('preco_medio')

  if (tipo) {
    query = query.eq('tipo_lente', tipo)
  }

  const { data, error } = await query
  return data
}

// 2. Detalhes de um grupo com lentes
async function detalharGrupo(grupoId: string) {
  const { data, error } = await supabase
    .from('v_grupos_com_lentes')
    .select('*')
    .eq('grupo_id', grupoId)
    .single()

  return data
}

// 3. Buscar por receita
async function buscarPorReceita(receita: Receita) {
  const { data, error } = await supabase
    .rpc('buscar_lentes_por_receita', {
      p_esferico: receita.esferico,
      p_cilindrico: receita.cilindrico,
      p_adicao: receita.adicao,
      p_tipo_lente: receita.tipo
    })

  return data
}

// 4. Sugerir upgrades
async function sugerirUpgrades(grupoBaseId: string) {
  const { data, error } = await supabase
    .from('v_sugestoes_upgrade')
    .select('*')
    .eq('grupo_base_id', grupoBaseId)
    .order('diferenca_preco')
    .limit(3)

  return data
}
```

---

## 🎯 RESUMO PARA DEVS

### ✅ Use:
- **Views** do schema `public.v_*`
- **Grupos canônicos** como unidade principal
- **Preços dos grupos** (não das lentes individuais)
- **Função** `buscar_lentes_por_receita()` para filtros

### ❌ Evite:
- Acessar `lens_catalog.lentes` diretamente
- Confiar em `preco_tabela` individual das lentes
- Usar campos de tratamento (estão vazios)
- Sistema de estoque (ainda não implementado)

### 🔧 Prioridade:
1. **URGENTE:** Preencher preços nas lentes
2. **URGENTE:** Popular campos de tratamento
3. **IMPORTANTE:** Definir produtos destaque
4. **IMPORTANTE:** Normalizar campos duplicados
5. **MÉDIO:** Implementar controle de estoque

---

**Última atualização:** 20/01/2026
**Versão do Banco:** Produção (ahcikwsoxhmqqteertkx)
