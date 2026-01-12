# 🔧 Correção: Permissões da Função buscar_lentes_por_receita

## ❌ Problema

```
POST /rpc/buscar_lentes_por_receita 401 (Unauthorized)
Error: permission denied for schema lens_catalog
Code: 42501
```

## 🔍 Causa

A função `buscar_lentes_por_receita` estava acessando diretamente o schema `lens_catalog`, mas usuários anônimos (anon) e autenticados não têm permissão neste schema.

## ✅ Solução

Recriar a função usando a **view pública** `vw_lentes_catalogo` ao invés de acessar tabelas diretas.

## 📋 Como Executar

### 1. Via Supabase SQL Editor

1. Acesse: https://supabase.com/dashboard/project/ahcikwsoxhmqqteertkx/sql
2. Copie o conteúdo de `FIX_BUSCAR_RECEITA_PERMISSIONS.sql`
3. Cole no editor
4. Clique em **Run** (ou Ctrl+Enter)
5. Verifique os testes ao final

### 2. Via psql (se tiver acesso direto)

```bash
psql -h db.ahcikwsoxhmqqteertkx.supabase.co \
     -U postgres \
     -d postgres \
     -f database/maintenance/FIX_BUSCAR_RECEITA_PERMISSIONS.sql
```

## 🧪 Testes

Após executar, teste a função:

```sql
-- Teste básico
SELECT COUNT(*) 
FROM public.buscar_lentes_por_receita(-2.00, -0.50, NULL, 'visao_simples');

-- Deve retornar um número > 0
```

## 📊 O que mudou

### Antes:
```sql
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
```

### Depois:
```sql
FROM public.vw_lentes_catalogo v
```

## 🎯 Benefícios

- ✅ Usa view pública (sem problemas de permissão)
- ✅ SECURITY DEFINER (executa com permissões do criador)
- ✅ Retorna todos os campos necessários para o frontend
- ✅ Ordenação inteligente (premium → índice → preço)
- ✅ Limite de 100 resultados para performance

## 🔄 Campos Retornados

A função agora retorna campos da view `vw_lentes_catalogo`:

- `id` - UUID da lente
- `nome_lente` - Nome da lente
- `tipo_lente` - visao_simples, bifocal, multifocal
- `categoria` - basico, standard, premium
- `material` - CR39, POLICARBONATO, TRIVEX, etc
- `indice_refracao` - 1.50, 1.56, 1.60, etc
- `preco_tabela` - Preço em BRL
- `marca_nome` - Nome da marca
- `fornecedor_nome` - Nome do fornecedor
- `tratamento_*` - Booleanos dos tratamentos
- `grau_*` - Faixas de graus suportados
- `adicao_*` - Faixas de adição
- `marca_premium` - Boolean se é marca premium

## ⚠️ Importante

Esta função substitui completamente a anterior. Não é necessário executar nenhum outro script após este.

## 📝 Validação

Após executar, o simulador de receita deve funcionar sem erros:
- Acesse: http://localhost:5173/simulador/receita
- Preencha OD e OE
- Clique em "Buscar Lentes Compatíveis"
- Deve retornar resultados sem erro 401
