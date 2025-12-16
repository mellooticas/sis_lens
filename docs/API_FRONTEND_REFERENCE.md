# 📘 API Reference - Frontend

Guia completo de consumo das funções e views expostas no schema `public` do Supabase.

---

## 🔧 Funções Disponíveis

### 1. `buscar_lentes()`
Busca lentes no catálogo com filtros.

```typescript
const { data, error } = await supabase.rpc('buscar_lentes', {
  p_query: 'progressiva',
  p_filtros: {},
  p_limit: 20
});
```

**Retorna:**
```typescript
{
  id: UUID,
  sku_canonico: string,
  nome_comercial: string,
  marca: string,
  categoria: string,
  material: string,
  indice_refracao: number,
  tratamentos: JSONB,
  specs_tecnicas: JSONB,
  preco_referencia: number,
  disponivel: boolean
}[]
```

---

### 2. `criar_decisao_lente()` 🔥
**CRÍTICA** - Cria uma decisão de compra com recomendações.

```typescript
const { data, error } = await supabase.rpc('criar_decisao_lente', {
  p_tenant_id: 'uuid-do-tenant',
  p_cliente_id: 'uuid-do-cliente',
  p_receita: {
    od: { esferico: -2.50, cilindrico: -0.75, eixo: 90 },
    oe: { esferico: -2.25, cilindrico: -0.50, eixo: 85 }
  },
  p_criterio: 'EQUILIBRADO', // ou 'PRECO', 'QUALIDADE', 'PRAZO'
  p_filtros: {}
});
```

**Retorna:**
```typescript
{
  sucesso: boolean,
  decisao_id?: UUID,
  alternativas?: Array<{
    posicao: number,
    lente_id: UUID,
    laboratorio_id: UUID,
    preco_final: number,
    prazo_medio: number,
    score_geral: number,
    recomendada: boolean
  }>,
  erro?: string
}
```

---

### 3. `obter_dashboard_kpis()`
Retorna KPIs para o dashboard.

```typescript
const { data, error } = await supabase.rpc('obter_dashboard_kpis', {
  p_tenant_id: 'uuid-do-tenant' // opcional
});
```

**Retorna:**
```typescript
{
  total_decisoes: number,
  economia_total: number,
  decisoes_mes: number,
  labs_ativos: number
}
```

---

### 4. `listar_laboratorios()`
Lista laboratórios com scores e badges.

```typescript
const { data, error } = await supabase.rpc('listar_laboratorios', {
  p_tenant_id: 'uuid-do-tenant', // opcional
  p_apenas_ativos: true,
  p_min_score: 7.0 // opcional - filtrar por score mínimo
});
```

**Retorna:**
```typescript
{
  id: UUID,
  nome_fantasia: string,
  badge: 'GOLD' | 'SILVER' | 'BRONZE' | 'QUALIFICADO' | 'NAO_QUALIFICADO',
  lead_time_padrao_dias: number,
  ativo: boolean,
  score_geral: number,
  ranking_geral: number
}[]
```

---

### 5. `obter_laboratorio()`
Detalhes completos de um laboratório.

```typescript
const { data, error } = await supabase.rpc('obter_laboratorio', {
  p_laboratorio_id: 'uuid-do-lab'
});
```

**Retorna:**
```typescript
{
  id: UUID,
  nome_fantasia: string,
  cnpj: string,
  contato_comercial: JSONB,
  lead_time_padrao_dias: number,
  atende_regioes: string[],
  ativo: boolean,
  badge: string,
  score_geral: number,
  score_qualidade: number,
  score_preco: number,
  score_prazo: number,
  ranking_geral: number,
  criado_em: timestamp,
  atualizado_em: timestamp
}
```

---

## 📊 Views Disponíveis

### 1. `vw_laboratorios_completo`
Laboratórios com scoring completo.

```typescript
const { data, error } = await supabase
  .from('vw_laboratorios_completo')
  .select('*')
  .eq('ativo', true)
  .order('ranking_geral');
```

**Colunas:**
- `id`, `nome`, `cnpj`, `contato_comercial`
- `lead_time_padrao_dias`, `ativo`, `tenant_id`
- `atende_regioes`, `criado_em`, `atualizado_em`
- **SCORES:** `score_geral`, `score_qualidade`, `score_preco`, `score_prazo`, `score_servico`
- **RANKING:** `ranking_geral`
- **BADGE:** `badge` (GOLD, SILVER, BRONZE, etc.)
- **VALIDADE:** `score_data_calculo`, `score_valido_ate`

---

### 2. `vw_historico_decisoes`
Histórico completo de decisões de compra.

```typescript
const { data, error } = await supabase
  .from('vw_historico_decisoes')
  .select('*')
  .eq('tenant_id', tenantId)
  .order('criado_em', { ascending: false })
  .limit(50);
```

**Colunas:**
- `id`, `tenant_id`, `codigo_decisao`
- `cliente_nome`, `otica_id`, `nome_otica`
- `lente_recomendada_id`, `laboratorio_escolhido_id`
- `preco_final`, `status`, `prioridade`
- `prazo_entrega_prometido`
- `criado_em`, `atualizado_em`
- `total_alternativas` (quantidade de opções geradas)
- `alternativa_recomendada` (JSONB com detalhes da escolha)

---

### 3. `vw_ranking_atual`
Ranking de alternativas por decisão.

```typescript
const { data, error } = await supabase
  .from('vw_ranking_atual')
  .select('*')
  .eq('decisao_id', decisaoId)
  .order('posicao');
```

**Colunas:**
- **IDs:** `id`, `decisao_id`, `lente_id`, `laboratorio_id`
- **LENTE:** `lente_familia`, `lente_design`, `lente_material`, `indice_refracao`
- **LABORATÓRIO:** `laboratorio_nome`, `lead_time_padrao_dias`, `laboratorio_badge`
- **POSIÇÃO:** `posicao`, `tipo_alternativa`, `recomendada`, `ativa`
- **PREÇOS:** `preco_base`, `desconto_percentual`, `preco_final`, `custo_frete`, `preco_total`
- **PRAZOS:** `prazo_minimo`, `prazo_maximo`, `prazo_medio`, `disponibilidade`
- **SCORES ALTERNATIVA:** `score_geral`, `score_qualidade`, `score_preco`, `score_prazo`
- **SCORES LAB:** `lab_score_geral`, `lab_score_qualidade`, `lab_score_preco`, `lab_score_prazo`
- **ADEQUAÇÃO:** `percentual_adequacao`, `pontos_fortes`, `pontos_fracos`, `observacoes`

---

## 🎯 Casos de Uso Práticos

### Dashboard Principal
```typescript
// KPIs
const kpis = await supabase.rpc('obter_dashboard_kpis', { p_tenant_id: tenant });

// Últimas decisões
const decisoes = await supabase
  .from('vw_historico_decisoes')
  .select('*')
  .eq('tenant_id', tenant)
  .order('criado_em', { ascending: false })
  .limit(10);

// Labs ativos
const labs = await supabase.rpc('listar_laboratorios', {
  p_tenant_id: tenant,
  p_apenas_ativos: true
});
```

### Tela de Busca de Lentes
```typescript
const lentes = await supabase.rpc('buscar_lentes', {
  p_query: searchTerm,
  p_limit: 50
});
```

### Criar Nova Cotação
```typescript
const resultado = await supabase.rpc('criar_decisao_lente', {
  p_tenant_id: tenant,
  p_cliente_id: cliente,
  p_receita: receitaMedica,
  p_criterio: 'EQUILIBRADO'
});

// Depois buscar o ranking
if (resultado.sucesso) {
  const ranking = await supabase
    .from('vw_ranking_atual')
    .select('*')
    .eq('decisao_id', resultado.decisao_id)
    .order('posicao');
}
```

### Detalhes de Laboratório
```typescript
const lab = await supabase.rpc('obter_laboratorio', {
  p_laboratorio_id: labId
});

// Badge display
const badgeColor = {
  'GOLD': 'bg-yellow-500',
  'SILVER': 'bg-gray-400',
  'BRONZE': 'bg-amber-600',
  'QUALIFICADO': 'bg-green-500',
  'NAO_QUALIFICADO': 'bg-red-500'
}[lab.badge];
```

---

## 🔐 Permissões

Todas as funções e views têm permissão `authenticated`:
- ✅ Requer autenticação via Supabase Auth
- ✅ Multi-tenant seguro (RLS aplicado)
- ✅ SECURITY DEFINER nas funções críticas

---

## ⚡ Notas de Performance

1. **Views com LATERAL JOIN**: Otimizadas para buscar apenas o score mais recente
2. **Índices criados**: `tenant_id`, `criado_em`, `decisao_id`, `posicao`
3. **Generated columns**: `preco_total`, `prazo_medio` calculados automaticamente
4. **Limite padrão**: 20 itens (configurável via parâmetro)

---

## 🚨 Importante

- Sempre filtrar por `tenant_id` para multi-tenancy
- Verificar `ativo = true` em laboratórios
- Checar `valido_ate >= CURRENT_DATE` para scores válidos
- Tratar casos onde scores podem ser `NULL` (labs sem avaliação)
