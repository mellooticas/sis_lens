# 🔄 Migração: vw_lentes_catalogo → v_lentes_catalogo

**Data:** 11 de janeiro de 2026  
**Status:** ✅ Concluída  
**Motivo:** vw_lentes_catalogo estava vazia (preços zerados, tratamentos null), v_lentes_catalogo contém todos os dados reais

---

## 📊 Análise Comparativa

### **v_lentes_catalogo** ✅ POPULADA
- **Registros:** 1.411 lentes com dados completos
- **Preços:** R$ 250 ~ R$ 9.640 (média R$ 3.557)
- **Tratamentos:** 620 AR, 466 Blue, 382 Foto
- **Grupo canônico:** 1.411 lentes vinculadas
- **Prazos:** Definidos para todos os tipos
- **Colunas:** 46 campos

### **vw_lentes_catalogo** ❌ VAZIA
- **Registros:** 1.411 (mesma quantidade)
- **Preços:** R$ 0,00 (todos zerados)
- **Tratamentos:** 0 (nenhum tratamento registrado)
- **Campos null:** nome_comercial, canonica_id, premium_canonica_id
- **Tecnologias:** 0 digital, 0 free_form
- **Colunas:** 60 campos (mais complexa, porém vazia)

---

## 🔧 Mudanças Implementadas

### 1. **Tipos TypeScript** (`database-views.ts`)

Criado novo tipo `VLenteCatalogo`:

```typescript
export interface VLenteCatalogo {
  // Nomes de campos
  nome_lente: string;                    // ← foi nome_comercial
  fornecedor_nome: string | null;        // ← agora presente
  grupo_id: string | null;               // ← vinculação canônica
  nome_grupo: string | null;
  
  // Tratamentos (nomenclatura diferente)
  tratamento_antirreflexo: boolean;      // ← foi ar
  tratamento_blue_light: boolean;        // ← foi blue
  tratamento_fotossensiveis: TratamentoFoto; // ← foi fotossensivel
  tratamento_uv: boolean;                // ← foi uv400
  
  // Preços
  preco_custo: number;                   // ← foi custo_base
  preco_venda_sugerido: number;          // ← foi preco_tabela
  margem_lucro: number | null;           // ← novo campo!
  
  // Faixas ópticas
  grau_esferico_min: number | null;      // ← foi esferico_min
  grau_esferico_max: number | null;      // ← foi esferico_max
  grau_cilindrico_min: number | null;    // ← foi cilindrico_min
  grau_cilindrico_max: number | null;    // ← foi cilindrico_max
  
  // Prazos (específicos por tipo)
  prazo_visao_simples: number | null;
  prazo_multifocal: number | null;
  prazo_surfacada: number | null;
  prazo_free_form: number | null;
  
  // Estoque
  estoque_disponivel: number | null;
  estoque_reservado: number | null;
}

// Alias para compatibilidade
export type LenteCatalogo = VLenteCatalogo;
```

### 2. **API Client** (`catalogo-api.ts`)

**Todas as queries atualizadas:**

```typescript
// Antes:
.from('vw_lentes_catalogo')

// Depois:
.from('v_lentes_catalogo')
```

**Filtros de tratamentos:**

```typescript
// Antes:
if (filtros.tratamentos.ar === true) query = query.eq('ar', true);
if (filtros.tratamentos.blue === true) query = query.eq('blue', true);

// Depois:
if (filtros.tratamentos.ar === true) query = query.eq('tratamento_antirreflexo', true);
if (filtros.tratamentos.blue === true) query = query.eq('tratamento_blue_light', true);
if (filtros.tratamentos.fotossensivel === true) query = query.neq('tratamento_fotossensiveis', 'nenhum');
```

**Filtros de preço:**

```typescript
// Antes:
query = query.gte('preco_tabela', filtros.preco.min);

// Depois:
query = query.gte('preco_venda_sugerido', filtros.preco.min);
```

**Busca textual:**

```typescript
// Antes:
query = query.ilike('nome_comercial', `%${filtros.busca}%`);

// Depois:
query = query.ilike('nome_lente', `%${filtros.busca}%`);
```

### 3. **Componentes** (`LenteCard.svelte`)

**Campos atualizados:**

```svelte
<!-- Nome -->
{lente.nome_lente}               <!-- foi nome_comercial -->

<!-- Fornecedor -->
{lente.fornecedor_nome}           <!-- agora disponível direto -->

<!-- Tratamentos -->
{lente.tratamento_antirreflexo}   <!-- foi ar -->
{lente.tratamento_blue_light}     <!-- foi blue -->
{lente.tratamento_fotossensiveis} <!-- foi fotossensivel -->

<!-- Preços -->
{lente.preco_venda_sugerido}      <!-- foi preco_tabela -->
{lente.margem_lucro}              <!-- novo campo! -->

<!-- Faixas ópticas -->
{lente.grau_esferico_min}         <!-- foi esferico_min -->
{lente.grau_cilindrico_min}       <!-- foi cilindrico_min -->
```

### 4. **Página Catálogo** (`+page.svelte`)

**Ordenação padrão atualizada:**

```typescript
// Antes:
ordenar: 'preco_tabela'

// Depois:
ordenar: 'preco_venda_sugerido'
```

---

## 🎯 Vantagens da Nova View

1. **✅ Dados Reais Populados**
   - Preços reais (R$ 250 ~ R$ 9.640)
   - Tratamentos registrados (620 AR, 466 Blue, 382 Foto)
   - Margem de lucro calculada

2. **✅ Informações Completas**
   - Fornecedor direto (sem JOINs adicionais)
   - Grupo canônico vinculado
   - Prazos específicos por tipo de lente

3. **✅ Nomenclatura Clara**
   - `tratamento_antirreflexo` mais explícito que `ar`
   - `preco_venda_sugerido` mais claro que `preco_tabela`
   - `grau_esferico_min` mais descritivo que `esferico_min`

---

## 📝 Checklist de Migração

- [x] Análise das views (COMPARAR_VIEWS_CATALOGO.sql)
- [x] Atualização de tipos TypeScript (VLenteCatalogo)
- [x] Migração API (catalogo-api.ts)
- [x] Atualização componentes (LenteCard.svelte)
- [x] Verificação de filtros (FilterPanel.svelte)
- [x] Atualização de ordenação (+page.svelte)
- [ ] Teste completo em desenvolvimento
- [ ] Validação com dados reais
- [ ] Deploy em produção

---

## 🚀 Próximos Passos

1. **Testar Catálogo:**
   ```bash
   npm run dev
   ```
   - Verificar se 1.411 lentes aparecem
   - Testar filtros (Tipo, Material, Índice)
   - Testar tratamentos (AR, Blue, Foto)
   - Verificar preços (R$ 250 ~ R$ 9.640)

2. **Validar Funcionalidades:**
   - [ ] Busca textual por nome
   - [ ] Filtros combinados
   - [ ] Ordenação por preço
   - [ ] Exibição de tratamentos
   - [ ] Cálculo de margem
   - [ ] Prazos por tipo

3. **Performance:**
   - View já criada no banco
   - 1.411 registros carregam rápido
   - Índices existentes no banco

---

## 📌 Observações Importantes

### Campos Removidos (não existem em v_lentes_catalogo)
- ❌ `lente_canonica_id` → usar `grupo_id`
- ❌ `premium_canonica_id` → não disponível
- ❌ `digital`, `free_form`, `indoor`, `drive` → não disponíveis
- ❌ `descricao_completa`, `beneficios`, `indicacoes` → não disponíveis
- ❌ `disponivel`, `destaque`, `novidade` → não disponíveis

### Campos Novos (agora disponíveis)
- ✅ `fornecedor_nome` → nome direto do fornecedor
- ✅ `grupo_id` → ID do grupo canônico
- ✅ `nome_grupo` → nome do grupo canônico
- ✅ `margem_lucro` → margem calculada
- ✅ `estoque_disponivel` → quantidade em estoque
- ✅ `prazo_visao_simples`, `prazo_multifocal` → prazos específicos

### Mapeamento de Campos Críticos

| Frontend (antigo) | v_lentes_catalogo | Tipo |
|---|---|---|
| `ar` | `tratamento_antirreflexo` | boolean |
| `blue` | `tratamento_blue_light` | boolean |
| `fotossensivel` | `tratamento_fotossensiveis` | enum |
| `preco_tabela` | `preco_venda_sugerido` | numeric |
| `custo_base` | `preco_custo` | numeric |
| `nome_comercial` | `nome_lente` | text |
| `esferico_min` | `grau_esferico_min` | numeric |
| `cilindrico_min` | `grau_cilindrico_min` | numeric |

---

## ✅ Conclusão

A migração para `v_lentes_catalogo` foi **essencial** porque:
- vw_lentes_catalogo estava completamente vazia
- v_lentes_catalogo contém todos os 1.411 registros populados
- Nomenclatura mais clara e explícita
- Campos adicionais úteis (margem_lucro, prazos específicos)

**Status:** Pronto para testes! 🎉
