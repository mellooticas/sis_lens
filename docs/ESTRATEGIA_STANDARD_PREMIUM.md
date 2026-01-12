# 📊 Estratégia: Lentes Canônicas Standard vs Premium

## 🎯 Objetivo

Definir claramente o que diferencia grupos **Standard** de **Premium** e como apresentar cada um no sistema.

---

## 📋 Estado Atual do Banco

### Dados Reais:
- **401 grupos Standard** (`is_premium = false`)
- **60 grupos Premium** (`is_premium = true`)
- **Total: 461 grupos canônicos**

### Campos Disponíveis:
```sql
-- Identificação
id, slug, nome_grupo

-- Especificações Técnicas
tipo_lente              -- visao_simples, multifocal, bifocal, leitura, ocupacional
material                -- CR39, POLICARBONATO, HIGH_INDEX, etc
indice_refracao         -- 1.50, 1.56, 1.59, 1.61, 1.67, 1.74

-- Categoria
categoria_predominante  -- economica, intermediaria, premium, super_premium

-- Ranges Óticos
grau_esferico_min/max
grau_cilindrico_min/max
adicao_min/max
descricao_ranges        -- texto descritivo

-- Tratamentos (booleanos)
tratamento_antirreflexo
tratamento_antirrisco
tratamento_uv
tratamento_blue_light
tratamento_fotossensiveis  -- "nenhum", "transitions", "fotocromático"

-- Precificação
preco_minimo
preco_maximo
preco_medio

-- Estatísticas
total_lentes           -- quantas lentes pertencem ao grupo
total_marcas           -- quantas marcas diferentes

-- Controle
peso                   -- para ordenação
is_premium            -- flag standard/premium
```

---

## 🏷️ Diferenciação: Standard vs Premium

### 📦 **STANDARD** (`is_premium = false`)
**Conceito**: Lentes genéricas/econômicas organizadas por especificações técnicas básicas.

**Características:**
- Agrupamento por **especificações técnicas puras**
- Múltiplas marcas competindo no mesmo grupo
- Foco em **melhor custo-benefício**
- Cliente escolhe **funcionalidade técnica**, não marca específica

**Critérios de Agrupamento:**
```
material + indice_refracao + tipo_lente + tratamentos básicos
```

**Exemplo Real (do banco):**
```
Nome: "Lente CR39 1.50 Visao Simples +UV [-6.00/6.00 | 0.00/-2.00]"
- Material: CR39
- Índice: 1.50
- Tipo: Visão Simples
- Tratamento: UV
- Preço: R$ 250,00
- Lentes: 1
- Marcas: 1
```

**Uso no Sistema:**
- Página: `/catalogo/standard`
- Card: **GrupoCanonicoCard** (specs técnicas em destaque)
- Ordenação: **preço médio crescente**
- Filtros: tipo, material, índice, tratamentos básicos, faixa de preço

---

### 💎 **PREMIUM** (`is_premium = true`)
**Conceito**: Lentes de marca/design diferenciado com tecnologias proprietárias.

**Características:**
- Agrupamento por **linha de produto + marca**
- Tecnologias exclusivas/patenteadas
- Foco em **diferenciação e qualidade**
- Cliente escolhe **marca e design específico**

**Critérios de Agrupamento:**
```
marca + linha_produto + tecnologia_proprietaria + design
```

**Exemplos Esperados (baseados em marcas premium):**
```
"Essilor Varilux X 4D - Progressiva Digital"
- Marca: Essilor
- Linha: Varilux X Series
- Tecnologia: 4D, Age Intelligence
- Preço médio: R$ 1.200+

"Zeiss SmartLife Individual - Progressive"
- Marca: Zeiss
- Linha: SmartLife
- Tecnologia: Digital Optimized
- Preço médio: R$ 1.100+

"Hoya iD MyStyle - Lifestyle Progressive"
- Marca: Hoya
- Linha: iD Series
- Tecnologia: Binocular Eye Model
- Preço médio: R$ 1.000+
```

**Uso no Sistema:**
- Página: `/catalogo/premium`
- Card: Destaque para **marca e tecnologia**
- Ordenação: **ranking de qualidade/inovação**
- Filtros: marca, linha de produto, tecnologias, faixa de preço premium

---

## 🎨 Apresentação Visual

### Standard Card (GrupoCanonicoCard)
```
┌─────────────────────────────────────┐
│ 📦 CR39 1.50 Visão Simples +UV     │ ← Nome técnico
│                                     │
│ 🔹 Material: CR39                   │
│ 🔹 Índice: 1.50                     │
│ 🔹 Tipo: Visão Simples              │
│                                     │
│ 💰 R$ 250,00 (1 lente, 1 marca)   │
│                                     │
│ ✓ UV Protection                     │
│                                     │
│ [Ver Opções]                        │
└─────────────────────────────────────┘
```

### Premium Card (GrupoCanonicoCard adaptado)
```
┌─────────────────────────────────────┐
│ 💎 ESSILOR Varilux X 4D             │ ← Marca+Linha
│ ⭐⭐⭐⭐⭐                              │
│                                     │
│ 🚀 Tecnologia 4D                    │
│ 🎯 Age Intelligence                 │
│ 📱 Digital Optimized                │
│                                     │
│ 💰 R$ 1.299 - R$ 1.599              │
│ (5 opções, 2 fornecedores)          │
│                                     │
│ [Consultar]                         │
└─────────────────────────────────────┘
```

---

## 🔄 Fluxo de Navegação

### Standard:
```
/catalogo/standard
  ↓ Clica no grupo
/catalogo/standard/{id}
  ↓ Mostra todas as lentes do grupo (LenteCard)
  ↓ Cliente escolhe lente específica
/catalogo/{lente_id}
  ↓ Detalhes completos da lente
```

### Premium:
```
/catalogo/premium
  ↓ Clica no grupo premium
/catalogo/premium/{id}
  ↓ Mostra opções da linha (diferentes tratamentos/fornecedores)
  ↓ Destaque para diferenciais tecnológicos
/catalogo/{lente_id}
  ↓ Detalhes com foco em tecnologia/marca
```

---

## 🎯 Módulos a Implementar

### ✅ Já Criado:
- [x] TypeScript interface `VGruposCanonico`
- [x] API: `buscarGruposCanonicosStandard()`
- [x] API: `obterGrupoCanonico(id)`
- [x] API: `buscarLentesDoGrupo(id)`
- [x] Componente: `GrupoCanonicoCard.svelte`
- [x] Página: `/catalogo/standard/+page.svelte`
- [x] Página: `/catalogo/standard/[id]/+page.svelte`

### 🔄 Pendente:
- [ ] API: `buscarGruposCanonicorPremium()` (igual standard mas `is_premium=true`)
- [ ] Página: `/catalogo/premium/+page.svelte` (clone de standard)
- [ ] Página: `/catalogo/premium/[id]/+page.svelte` (detalhes premium)
- [ ] Adaptar GrupoCanonicoCard: prop `variant="premium"` com visual diferenciado

---

## 📊 Query de Teste: Ver Distribuição

Execute para ver como estão distribuídos:

```sql
-- Distribuição Standard por tipo
SELECT 
    tipo_lente,
    COUNT(*) as total_grupos,
    AVG(preco_medio)::numeric(10,2) as preco_medio,
    SUM(total_lentes) as total_lentes_agregado
FROM public.v_grupos_canonicos
GROUP BY tipo_lente
ORDER BY total_grupos DESC;

-- Distribuição Premium por categoria
SELECT 
    categoria_predominante,
    COUNT(*) as total_grupos,
    AVG(preco_medio)::numeric(10,2) as preco_medio,
    SUM(total_lentes) as total_lentes_agregado
FROM public.v_grupos_premium
GROUP BY categoria_predominante
ORDER BY total_grupos DESC;

-- Top 10 grupos standard mais populares (mais lentes)
SELECT 
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    preco_medio,
    total_lentes,
    total_marcas
FROM public.v_grupos_canonicos
ORDER BY total_lentes DESC
LIMIT 10;

-- Top 10 grupos premium mais caros
SELECT 
    nome_grupo,
    categoria_predominante,
    preco_medio,
    total_lentes,
    total_marcas
FROM public.v_grupos_premium
ORDER BY preco_medio DESC
LIMIT 10;
```

---

## ✅ Decisões de Implementação

### Standard:
1. **Foco**: Especificações técnicas e preço
2. **Ordenação padrão**: Preço crescente
3. **Destaque**: Melhor custo-benefício
4. **Badges**: Tratamentos incluídos (AR, Blue, UV, Foto)
5. **Call-to-action**: "Ver Opções" → lista comparativa

### Premium:
1. **Foco**: Marca, tecnologia e diferenciais
2. **Ordenação padrão**: Destaque (peso) ou preço
3. **Destaque**: Tecnologias proprietárias
4. **Badges**: "Premium", marcas, tecnologias específicas
5. **Call-to-action**: "Consultar" → enfatiza atendimento especializado

---

## 🚀 Próximos Passos

1. ✅ Confirmar que dados standard funcionam (401 grupos)
2. 🔄 Testar se API buscarGruposCanonicosStandard() retorna dados
3. 🔄 Criar módulo Premium (clone adaptado)
4. 🔄 Adicionar navegação no menu principal
5. 🔄 Popular banco com mais grupos premium reais (Essilor, Zeiss, Hoya)

---

**Perguntas para o usuário:**

1. Os 60 grupos premium atuais têm dados reais de marcas como Essilor/Zeiss/Hoya?
2. Quer que eu crie o módulo Premium agora (será idêntico ao Standard)?
3. Precisa de filtros diferentes no Premium (ex: filtrar por marca)?
