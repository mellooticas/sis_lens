# 🔧 Correção das Funções Públicas

## Problema Identificado

As funções `public.buscar_lentes()` e `public.obter_dashboard_kpis()` são **wrappers** que tentam chamar funções do schema `api.*` que **provavelmente não existem** no seu banco.

Por isso, mesmo tendo 1.4k lentes, nada aparece no frontend.

## Solução (2 minutos)

### 1️⃣ Primeiro: Diagnóstico

Copie e execute no **Supabase SQL Editor**: `scripts/teste_rapido.sql`

Isso vai mostrar:
- ✅ Quantas lentes você tem (deve ser ~1400)
- ✅ Quantos labs você tem
- ❌ Se o schema `api` existe (provavelmente não)

### 2️⃣ Segundo: Aplicar Correção

Copie e execute no **Supabase SQL Editor**: `supabase/migrations/20251216_002_fix_public_functions.sql`

**O que essa migration faz:**

1. **Remove** as funções wrapper que dependem de `api.*`
2. **Recria** as funções com implementação DIRETA nas tabelas:
   - `public.buscar_lentes()` → busca direto em `lens_catalog.lentes`
   - `public.obter_dashboard_kpis()` → consulta direto `orders.*` e `suppliers.*`

### 3️⃣ Terceiro: Verificar

Após executar a migration, execute no SQL Editor:

```sql
-- Deve retornar 5-10 lentes
SELECT * FROM public.buscar_lentes('', '{}', 10);

-- Deve retornar JSON com labs_ativos > 0
SELECT public.obter_dashboard_kpis();

-- Deve retornar seus labs com scores
SELECT * FROM public.vw_laboratorios_completo;
```

### 4️⃣ Quarto: Testar no Frontend

1. Recarregue http://localhost:5173
2. Abra o DevTools (F12) → Console
3. Veja se há erros de RPC
4. O dashboard deve mostrar:
   - Labs ativos: X
   - Total decisões: Y
   - Lentes no catálogo: ~1400

## Se ainda não funcionar

### Verificar variáveis de ambiente

Arquivo `.env` ou `.env.local`:

```env
VITE_SUPABASE_URL=https://seu-projeto.supabase.co
VITE_SUPABASE_ANON_KEY=sua-chave-anon-aqui
```

### Verificar permissões

Se der erro de permissão, execute:

```sql
GRANT USAGE ON SCHEMA lens_catalog TO authenticated;
GRANT SELECT ON lens_catalog.lentes TO authenticated;
GRANT SELECT ON lens_catalog.marcas TO authenticated;

GRANT USAGE ON SCHEMA suppliers TO authenticated;
GRANT SELECT ON suppliers.laboratorios TO authenticated;

GRANT USAGE ON SCHEMA scoring TO authenticated;
GRANT SELECT ON scoring.scores_laboratorios TO authenticated;

GRANT USAGE ON SCHEMA orders TO authenticated;
GRANT SELECT ON orders.decisoes_lentes TO authenticated;
GRANT SELECT ON orders.alternativas_cotacao TO authenticated;
```

## Explicação Técnica

### ❌ Antes (Quebrado):

```sql
CREATE FUNCTION public.buscar_lentes(...)
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM api.buscar_lentes(...);  -- ❌ api.buscar_lentes não existe!
END;
$$;
```

### ✅ Depois (Funcional):

```sql
CREATE FUNCTION public.buscar_lentes(...)
AS $$
BEGIN
    RETURN QUERY
    SELECT l.id, l.familia, l.design...  -- ✅ Busca direto na tabela!
    FROM lens_catalog.lentes l
    WHERE l.disponivel = true
    LIMIT p_limit;
END;
$$;
```

## Resultado Esperado

Após aplicar a correção:

- ✅ `buscar_lentes()` retorna até 1400 lentes
- ✅ `obter_dashboard_kpis()` retorna dados reais
- ✅ Frontend mostra números corretos
- ✅ Página de busca funciona
- ✅ Dashboard tem métricas reais
