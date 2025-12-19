# 🔍 DIAGNÓSTICO E CORREÇÃO - Views do Supabase

## ❌ Erro Atual

```
GET https://ahcikwsoxhmqqteertkx.supabase.co/rest/v1/vw_buscar_lentes 503
PGRST002: Could not query the database for the schema cache. Retrying.
```

**Causa:** As views não existem no banco de dados do Supabase.

---

## 📋 PASSO 1: Diagnóstico do Banco

### Executar no Supabase SQL Editor:

1. Acesse: https://supabase.com/dashboard/project/ahcikwsoxhmqqteertkx/sql/new
2. Copie e execute o arquivo: `povoar_banco/00_DIAGNOSTICO_BANCO.sql`

### O que você deve ver:

#### ✅ **Se o banco estiver populado corretamente:**
```sql
-- Schemas existentes:
lens_catalog
pessoas
public

-- Tabelas em lens_catalog:
lentes
lentes_canonicas
marcas
premium_canonicas

-- Tabelas em pessoas:
fornecedores

-- Contagem de registros:
lentes: 1411
marcas: 7
fornecedores: 5
```

#### ⚠️ **Se algo estiver faltando:**
- Schemas não existem → Executar migrations completas
- Tabelas vazias → Executar scripts de povoamento
- Views já existem → Problema pode ser de permissão

---

## 🔧 PASSO 2: Verificar Estrutura Atual

Execute este SQL para ver exatamente o que está no banco:

```sql
-- Ver todas as tabelas e views
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables
WHERE schemaname IN ('lens_catalog', 'pessoas', 'public')
ORDER BY schemaname, tablename;
```

**Me envie o resultado** para eu ajustar o SQL das views se necessário.

---

## ⚡ PASSO 3: Criar as Views (Solução Rápida)

### Opção A: Via Supabase Dashboard (Mais Simples)

1. Acesse o SQL Editor: https://supabase.com/dashboard/project/ahcikwsoxhmqqteertkx/sql/new

2. **Copie TODO o conteúdo** do arquivo:
   ```
   D:\projetos\marketing_total\melhor_preco\povoar_banco\06_PUBLIC_VIEWS.sql
   ```

3. Cole no editor SQL

4. Clique em **Run** (ou pressione F5)

5. Aguarde a mensagem de sucesso

### Opção B: Via Supabase CLI

```bash
cd D:\projetos\marketing_total\melhor_preco

# Fazer login (se ainda não fez)
npx supabase login

# Executar o SQL
npx supabase db execute --db-url "postgresql://postgres:[SUA-SENHA]@db.ahcikwsoxhmqqteertkx.supabase.co:5432/postgres" < povoar_banco/06_PUBLIC_VIEWS.sql
```

---

## ✅ PASSO 4: Verificar se Funcionou

### Teste 1: Verificar se as views foram criadas

```sql
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public' 
  AND table_name LIKE 'vw_%';
```

**Resultado esperado:**
```
vw_buscar_lentes
vw_comparar_fornecedores
vw_filtros_disponiveis
vw_fornecedores
vw_grupos_genericos
vw_grupos_premium
vw_marcas
vw_stats_catalogo
```

### Teste 2: Consultar uma view

```sql
SELECT COUNT(*) as total FROM public.vw_buscar_lentes;
```

**Resultado esperado:** `1411`

### Teste 3: Ver dados de uma lente

```sql
SELECT 
    nome_comercial,
    marca,
    fornecedor,
    preco_tabela,
    tipo_canonica,
    grupo_canonico
FROM public.vw_buscar_lentes
LIMIT 5;
```

---

## 🔐 PASSO 5: Verificar Permissões

As views precisam ser acessíveis publicamente. Execute:

```sql
-- Garantir acesso público às views
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;

-- Especificamente para as views
GRANT SELECT ON public.vw_buscar_lentes TO anon, authenticated;
GRANT SELECT ON public.vw_stats_catalogo TO anon, authenticated;
GRANT SELECT ON public.vw_filtros_disponiveis TO anon, authenticated;
GRANT SELECT ON public.vw_marcas TO anon, authenticated;
GRANT SELECT ON public.vw_fornecedores TO anon, authenticated;
GRANT SELECT ON public.vw_grupos_genericos TO anon, authenticated;
GRANT SELECT ON public.vw_grupos_premium TO anon, authenticated;
GRANT SELECT ON public.vw_comparar_fornecedores TO anon, authenticated;
```

---

## 🎯 PASSO 6: Testar no App

Após criar as views:

1. **Recarregue a página** do browser (Ctrl + Shift + R para limpar cache)

2. Acesse: http://localhost:5173/buscar

3. **Abra o DevTools** (F12) → Console

4. Você deve ver:
   - ✅ Requisições 200 OK
   - ✅ Dados sendo carregados
   - ✅ Cards de lentes aparecendo

---

## 🐛 Troubleshooting

### Erro: "relation does not exist"

**Causa:** Schemas `lens_catalog` ou `pessoas` não existem

**Solução:**
1. Verifique se você executou as migrations completas
2. Execute: `povoar_banco/01_estrutura_basica.sql` primeiro
3. Depois execute: `povoar_banco/06_PUBLIC_VIEWS.sql`

### Erro: "permission denied"

**Causa:** Views não têm permissões públicas

**Solução:** Execute os comandos GRANT do Passo 5

### Erro: "function does not exist"

**Causa:** Alguma função auxiliar está faltando

**Solução:** Execute todas as migrations em ordem:
1. `01_estrutura_basica.sql`
2. `02_triggers_canonizacao.sql`
3. `03_popular_marcas.sql`
4. `04_popular_fornecedores.sql`
5. `05_popular_lentes.sql`
6. `06_PUBLIC_VIEWS.sql`

---

## 📊 Resultado Esperado

Após executar corretamente, você terá:

### No Supabase:
- ✅ 8 views públicas criadas
- ✅ 1.411 lentes acessíveis via `vw_buscar_lentes`
- ✅ Estatísticas via `vw_stats_catalogo`

### No App:
- ✅ Página /buscar mostrando dados reais
- ✅ Estatísticas no topo (Total Lentes, Fornecedores, Preço Médio)
- ✅ Grid de cards com lentes
- ✅ Filtros funcionais
- ✅ Paginação ativa

---

## 📝 Checklist Final

- [ ] Executei o diagnóstico (`00_DIAGNOSTICO_BANCO.sql`)
- [ ] Confirmei que schemas `lens_catalog` e `pessoas` existem
- [ ] Confirmei que há 1.411 lentes na tabela
- [ ] Executei `06_PUBLIC_VIEWS.sql` no Supabase
- [ ] Verifiquei que 8 views foram criadas
- [ ] Executei os GRANT de permissões
- [ ] Testei consulta: `SELECT * FROM vw_buscar_lentes LIMIT 5`
- [ ] Recarreguei a página do app (Ctrl+Shift+R)
- [ ] Os dados aparecem no navegador

---

## 🆘 Precisa de Ajuda?

**Me envie:**

1. O resultado do diagnóstico (Passo 1)
2. Lista de tabelas e schemas existentes (Passo 2)
3. Qualquer mensagem de erro ao executar o SQL

Vou ajustar o SQL das views especificamente para o seu banco.

---

**Arquivo de diagnóstico:** `povoar_banco/00_DIAGNOSTICO_BANCO.sql`  
**Arquivo de views:** `povoar_banco/06_PUBLIC_VIEWS.sql`  
**Status:** ⏳ Aguardando execução das views no Supabase

