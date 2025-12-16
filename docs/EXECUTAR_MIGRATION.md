# 🚀 Guia de Execução - Supabase Migration

## Passo a Passo para disponibilizar a API para o Frontend

---

## 1️⃣ Executar a Migration Principal

Vá no **Supabase Dashboard → SQL Editor** e execute:

```sql
-- Cole TODO o conteúdo do arquivo:
-- supabase/migrations/20251216_001_expose_api_to_public.sql
```

**Ou se preferir via CLI:**

```bash
supabase db push
```

---

## 2️⃣ Verificar se a Migration foi aplicada

Execute esta query para confirmar:

```sql
-- Verificar funções criadas
SELECT 
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
    'buscar_lentes',
    'criar_decisao_lente',
    'obter_dashboard_kpis',
    'listar_laboratorios',
    'obter_laboratorio'
);

-- Deve retornar 5 funções

-- Verificar views criadas
SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
    'vw_laboratorios_completo',
    'vw_historico_decisoes',
    'vw_ranking_atual'
);

-- Deve retornar 3 views
```

---

## 3️⃣ Testar as Funções

### Teste 1: Buscar Lentes
```sql
SELECT * FROM public.buscar_lentes(
    p_query := '',
    p_filtros := '{}'::jsonb,
    p_limit := 10
);
```

### Teste 2: Listar Laboratórios
```sql
SELECT * FROM public.listar_laboratorios(
    p_apenas_ativos := true
);
```

### Teste 3: Dashboard KPIs
```sql
SELECT public.obter_dashboard_kpis();
```

---

## 4️⃣ Testar as Views

### View: Laboratórios Completos
```sql
SELECT 
    nome,
    badge,
    score_geral,
    score_qualidade,
    score_preco,
    score_prazo,
    ranking_geral
FROM public.vw_laboratorios_completo
WHERE ativo = true
ORDER BY ranking_geral NULLS LAST;
```

### View: Histórico de Decisões
```sql
SELECT 
    codigo_decisao,
    cliente_nome,
    status,
    preco_final,
    total_alternativas,
    criado_em
FROM public.vw_historico_decisoes
ORDER BY criado_em DESC
LIMIT 10;
```

### View: Ranking de Alternativas
```sql
SELECT 
    posicao,
    lente_familia,
    laboratorio_nome,
    laboratorio_badge,
    preco_final,
    prazo_medio,
    score_geral,
    recomendada
FROM public.vw_ranking_atual
WHERE decisao_id = 'UUID-DA-DECISAO' -- substituir por um ID real
ORDER BY posicao;
```

---

## 5️⃣ Verificar Permissões

```sql
-- Confirmar que authenticated tem acesso
SELECT 
    grantee,
    privilege_type,
    table_name
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
AND table_name IN (
    'vw_laboratorios_completo',
    'vw_historico_decisoes',
    'vw_ranking_atual'
)
AND grantee = 'authenticated';

-- Deve mostrar SELECT para as 3 views
```

---

## 6️⃣ Teste Completo: Criar Decisão

⚠️ **Apenas se você já tiver dados de lentes e laboratórios no banco!**

```sql
SELECT public.criar_decisao_lente(
    p_tenant_id := '550e8400-e29b-41d4-a716-446655440000', -- substituir pelo seu tenant
    p_cliente_id := '00000000-0000-0000-0000-000000000001', -- substituir por cliente real
    p_receita := '{
        "od": {"esferico": -2.50, "cilindrico": -0.75, "eixo": 90},
        "oe": {"esferico": -2.25, "cilindrico": -0.50, "eixo": 85}
    }'::jsonb,
    p_criterio := 'EQUILIBRADO',
    p_filtros := '{}'::jsonb
);
```

---

## 🔧 Troubleshooting

### Erro: "function does not exist"
**Causa:** Migration não foi executada ou schema errado  
**Solução:** Execute a migration novamente

### Erro: "permission denied"
**Causa:** RLS policies não configuradas  
**Solução:** Execute:
```sql
GRANT EXECUTE ON FUNCTION public.buscar_lentes TO authenticated;
GRANT EXECUTE ON FUNCTION public.criar_decisao_lente TO authenticated;
GRANT EXECUTE ON FUNCTION public.obter_dashboard_kpis TO authenticated;
GRANT EXECUTE ON FUNCTION public.listar_laboratorios TO authenticated;
GRANT EXECUTE ON FUNCTION public.obter_laboratorio TO authenticated;

GRANT SELECT ON public.vw_laboratorios_completo TO authenticated;
GRANT SELECT ON public.vw_historico_decisoes TO authenticated;
GRANT SELECT ON public.vw_ranking_atual TO authenticated;
```

### Views retornam vazio
**Causa:** Não há dados nas tabelas base  
**Solução:** 
1. Verifique se há laboratórios: `SELECT * FROM suppliers.laboratorios;`
2. Verifique se há lentes: `SELECT * FROM lens_catalog.lentes;`
3. Se vazio, execute os seeds de dados

### Scores são NULL
**Normal!** Significa que não há scores calculados ainda.  
Os laboratórios sem score aparecem com badge `'QUALIFICADO'` por padrão.

---

## 📊 Queries Úteis para Popular Dados de Teste

### Verificar Tenant
```sql
SELECT id, nome, slug FROM meta_system.tenants;
```

### Ver Laboratórios
```sql
SELECT 
    id, 
    nome_fantasia, 
    ativo 
FROM suppliers.laboratorios;
```

### Ver Lentes
```sql
SELECT 
    id,
    sku_canonico,
    familia,
    material,
    ativo
FROM lens_catalog.lentes;
```

### Ver Scores Existentes
```sql
SELECT 
    l.nome_fantasia,
    s.score_geral,
    s.nivel_qualificacao,
    s.data_calculo,
    s.valido_ate
FROM scoring.scores_laboratorios s
JOIN suppliers.laboratorios l ON l.id = s.laboratorio_id
WHERE s.valido_ate >= CURRENT_DATE
ORDER BY s.score_geral DESC;
```

---

## ✅ Checklist Final

- [ ] Migration executada sem erros
- [ ] 5 funções criadas no schema public
- [ ] 3 views criadas no schema public
- [ ] Permissões concedidas para authenticated
- [ ] Testes básicos executados
- [ ] Views retornam dados (ou vazio se não houver registros)
- [ ] Frontend pode chamar `supabase.rpc('buscar_lentes')`
- [ ] Frontend pode fazer SELECT nas views

---

## 🎯 Pronto para o Frontend!

Agora você pode usar no código TypeScript/JavaScript:

```typescript
// Exemplo 1: Buscar lentes
const { data: lentes } = await supabase.rpc('buscar_lentes', { p_limit: 20 });

// Exemplo 2: Listar labs
const { data: labs } = await supabase.from('vw_laboratorios_completo').select('*');

// Exemplo 3: Dashboard
const { data: kpis } = await supabase.rpc('obter_dashboard_kpis');
```
