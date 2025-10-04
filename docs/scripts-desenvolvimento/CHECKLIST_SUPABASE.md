# 🔍 CHECKLIST DIAGNÓSTICO SUPABASE

## 📋 Execute no SQL Editor do Supabase Dashboard

### **PASSO 1: Verificar o que existe**
```sql
-- Query 1: Listar todas tabelas/views
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_type, table_name;
```

### **PASSO 2: Verificar permissões**
```sql
-- Query 2: Verificar grants para anon
SELECT table_name, privilege_type, grantee
FROM information_schema.role_table_grants 
WHERE grantee = 'anon' AND table_schema = 'public';
```

### **PASSO 3: Testar acesso básico**
```sql
-- Query 3: Testar se consegue acessar
SELECT COUNT(*) FROM vw_lentes_catalogo LIMIT 1;
SELECT COUNT(*) FROM vw_fornecedores LIMIT 1;
```

---

## 🔧 **SE DER ERRO DE PERMISSÃO**

### Execute estes GRANTs:
```sql
-- Dar permissão para anon acessar as views
GRANT SELECT ON public.vw_lentes_catalogo TO anon;
GRANT SELECT ON public.vw_fornecedores TO anon;
GRANT SELECT ON public.decisoes_compra TO anon;
GRANT SELECT ON public.produtos_laboratorio TO anon;

-- Dar permissão para RPCs
GRANT EXECUTE ON FUNCTION public.rpc_buscar_lente TO anon;
GRANT EXECUTE ON FUNCTION public.rpc_rank_opcoes TO anon;
```

---

## 🛡️ **SE RLS ESTIVER BLOQUEANDO**

### Desabilitar temporariamente:
```sql
ALTER TABLE public.decisoes_compra DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.lentes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.laboratorios DISABLE ROW LEVEL SECURITY;
```

---

## ✅ **TESTE FINAL**

### Queries que o backend faz:
```sql
-- Simular o que o DatabaseClient faz
SELECT * FROM vw_lentes_catalogo LIMIT 3;
SELECT * FROM vw_fornecedores LIMIT 3;
SELECT rpc_buscar_lente('test', 5);
```

---

## 📊 **RESULTADO ESPERADO**

✅ **Se funcionar**: Backend conectará automaticamente  
❌ **Se der erro**: Cole aqui o erro para ajustarmos  

---

## 🎯 **VIEWS QUE O BACKEND PRECISA**

- `vw_lentes_catalogo` (catálogo de lentes)
- `vw_fornecedores` (laboratórios ativos)  
- `decisoes_compra` (histórico de decisões)
- `produtos_laboratorio` (produtos por lab)

## ⚙️ **RPCs QUE O BACKEND PRECISA**

- `rpc_buscar_lente(query, limit)`
- `rpc_rank_opcoes(lente_id, criterio, filtros)`
- `rpc_confirmar_decisao(payload)`