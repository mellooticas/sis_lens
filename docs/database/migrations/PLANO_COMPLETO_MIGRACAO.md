# 📋 PLANO COMPLETO DE MIGRAÇÃO

## 🎯 Objetivo
Transformar o banco atual na **Arquitetura Definitiva** com motor inteligente de lentes.

---

## � IMPORTANTE: Correção de Tipos ENUM

**SE você já executou o PASSO 1 e teve erro:**
```
ERROR: operator does not exist: text = tipo_lente
```

**Execute isto ANTES do PASSO 2:**
```sql
-- Arquivo: CORRECAO_TRIGGERS_ENUM.sql
-- Corrige comparação de tipos ENUM nos triggers
```

**OU** execute novamente o `PASSO_1_CRIAR_ESTRUTURA.sql` atualizado (já corrigido).

---

## �📊 ORDEM DE EXECUÇÃO

### ✅ PASSO 1: Criar Estrutura
**Arquivo:** `PASSO_1_CRIAR_ESTRUTURA.sql`

**O que faz:**
- ✅ Cria tabela `premium_canonicas`
- ✅ Adiciona 7 colunas novas em `lentes`:
  - `sku_laboratorio` (código do lab para pedidos)
  - `laboratorio_id` (qual lab vende)
  - `nome_comercial`
  - `nivel_qualidade` (1-5)
  - `is_premium` (auto)
  - `lente_canonica_id` (auto)
  - `premium_canonica_id` (auto)
- ✅ Cria 3 triggers automáticos:
  - `fn_classificar_lente` (detecta premium)
  - `fn_vincular_canonica` (agrupa genéricas)
  - `fn_vincular_premium_canonica` (agrupa premium)
- ✅ Adiciona índices e constraints

**Status:** ✅ Pronto para executar

---

### ✅ PASSO 2: Migrar Dados Existentes
**Arquivo:** `PASSO_2_MIGRAR_DADOS.sql`

**O que faz:**
- ✅ Popula `sku_laboratorio` e `laboratorio_id` das 515 lentes que têm dados em `produtos_laboratorio`
- ✅ Define `nivel_qualidade` baseado em marca:
  - Nível 5: Essilor, Hoya, Zeiss, Rodenstock
  - Nível 4: Kodak, Shamir, Indo
  - Nível 3: Demais marcas
- ✅ Aciona triggers para classificar e vincular canônicas
- ✅ Verifica resultados

**Status:** ✅ Pronto para executar

---

### ⚠️ PASSO 3: Corrigir Lentes Órfãs
**Arquivo:** `PASSO_3_CORRIGIR_LENTES_ORFAS.sql`

**Problema identificado:**
- 1.411 lentes na tabela
- 515 têm dados de laboratório
- **896 lentes SEM laboratório** ❌

**Opções:**
1. **Importar CSV completo** (1.411 linhas) de `produtos_laboratorio_import.csv`
2. **Remover lentes órfãs** (se forem duplicatas/lixo)

**Status:** ⚠️ Precisa decisão antes de executar

---

### ✅ PASSO 4: Criar Motor de Busca
**Arquivo:** `PASSO_4_CRIAR_MOTOR_BUSCA.sql`

**O que faz:**
- ✅ Cria `VIEW v_motor_lentes` com:
  - Todos os dados necessários
  - Agrupamento por canônicas
  - Ranking de preços
  - Contagem de labs
- ✅ Cria função `fn_buscar_lentes()` para facilitar buscas
- ✅ Exemplos de queries prontas

**Status:** ✅ Pronto para executar (após Passo 1 e 2)

---

## 📝 CHECKLIST DE EXECUÇÃO

```
[ ] 1. BACKUP DO BANCO (CRÍTICO!)

[ ] 2. Executar PASSO_1_CRIAR_ESTRUTURA.sql
    [ ] Verificar: Tabela premium_canonicas criada
    [ ] Verificar: 7 colunas novas em lentes
    [ ] Verificar: 3 triggers criados

[ ] 3. Executar PASSO_2_MIGRAR_DADOS.sql
    [ ] Verificar: 515 lentes com laboratório
    [ ] Verificar: nivel_qualidade definido
    [ ] Verificar: Canônicas criadas automaticamente

[ ] 4. DECISÃO sobre lentes órfãs (896):
    [ ] Opção A: Importar CSV completo
    [ ] Opção B: Remover lentes órfãs
    [ ] Executar PASSO_3_CORRIGIR_LENTES_ORFAS.sql

[ ] 5. Executar PASSO_4_CRIAR_MOTOR_BUSCA.sql
    [ ] Verificar: VIEW criada
    [ ] Verificar: Função de busca funcionando
    [ ] Testar queries de exemplo

[ ] 6. VALIDAÇÃO FINAL
    [ ] Ver relatório de verificação
    [ ] Testar motor de busca
    [ ] Confirmar agrupamentos
```

---

## 🔍 VERIFICAÇÃO FINAL

Após executar todos os passos, rodar:

```sql
-- Resumo completo
SELECT 
    'Total de lentes' as metrica,
    COUNT(*) as valor
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'

UNION ALL

SELECT 'Lentes premium', COUNT(*)
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND is_premium = TRUE

UNION ALL

SELECT 'Lentes genéricas', COUNT(*)
FROM lens_catalog.lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND is_premium = FALSE

UNION ALL

SELECT 'Canônicas genéricas', COUNT(*)
FROM lens_catalog.lentes_canonicas
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'

UNION ALL

SELECT 'Canônicas premium', COUNT(*)
FROM lens_catalog.premium_canonicas
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'

UNION ALL

SELECT 'Produtos com múltiplos labs', COUNT(DISTINCT grupo_canonico_id)
FROM lens_catalog.v_motor_lentes
WHERE tenant_id = '229220bb-d480-4608-a07c-ae9ab5266caf'
  AND labs_disponiveis > 1;
```

---

## 📌 PASSO 5: Criar Public Views para Frontend

**Arquivo:** `PASSO_5_CRIAR_PUBLIC_VIEWS.sql`

**O que faz:**
- ✅ Cria 7 views públicas (schema `public`) para consumo do frontend
- ✅ Cria 2 funções de API para busca e detalhes
- ✅ Expõe dados sem revelar estrutura interna do banco

**Views criadas:**
1. `vw_buscar_lentes` - Motor de busca principal
2. `vw_produtos_premium` - Catálogo de produtos premium
3. `vw_produtos_genericos` - Catálogo de produtos genéricos
4. `vw_marcas` - Marcas disponíveis (dropdowns)
5. `vw_laboratorios` - Laboratórios disponíveis (dropdowns)
6. `vw_filtros_disponiveis` - Filtros dinâmicos (tipos, materiais, índices)
7. `vw_comparar_precos` - Comparação de preços entre labs

**Funções criadas:**
1. `fn_api_buscar_lentes()` - API de busca com filtros completos
2. `fn_api_detalhes_lente()` - Detalhes completos + alternativas

**Executar:**
```sql
-- No Supabase SQL Editor
-- Copiar e colar todo o conteúdo de PASSO_5_CRIAR_PUBLIC_VIEWS.sql
```

**Verificar:**
```sql
-- 1. Ver views disponíveis
SELECT table_name, obj_description(('"public"."' || table_name || '"')::regclass)
FROM information_schema.views 
WHERE table_schema = 'public' 
  AND table_name LIKE 'vw_%'
ORDER BY table_name;

-- 2. Testar busca
SELECT * FROM public.fn_api_buscar_lentes(
    '229220bb-d480-4608-a07c-ae9ab5266caf'::UUID,
    p_tipo_lente := 'PROGRESSIVA',
    p_apenas_melhor_preco := TRUE,
    p_limite := 10
);

-- 3. Ver filtros disponíveis
SELECT * FROM public.vw_filtros_disponiveis;

-- 4. Comparar preços de um produto
SELECT 
    produto,
    marca,
    qtd_labs,
    melhor_preco,
    pior_preco,
    diferenca_preco,
    opcoes_labs
FROM public.vw_comparar_precos
WHERE qtd_labs > 1
LIMIT 5;

-- 5. Testar detalhes de lente
SELECT public.fn_api_detalhes_lente(
    'ID_DA_LENTE'::UUID,  -- Substituir por ID real
    '229220bb-d480-4608-a07c-ae9ab5266caf'::UUID
);
```

**Resultado esperado:**
- ✅ 7 views públicas criadas
- ✅ 2 funções de API funcionando
- ✅ Frontend pode consumir sem acessar schemas internos
- ✅ Comparação de preços entre labs funcionando

**Status:** ✅ Pronto para executar

---

## ⚡ RESULTADO ESPERADO

### Antes:
```
❌ Dados espalhados em múltiplas tabelas
❌ Sem agrupamento inteligente
❌ Sem comparação de preços
❌ Dev precisa gerenciar canônicas manualmente
```

### Depois:
```
✅ Único ponto de entrada (tabela lentes)
✅ Agrupamento automático por triggers
✅ Comparação de preços por canônicas
✅ Motor de busca pronto para uso
✅ Dev só insere, sistema faz o resto
```

---

## 🚨 ATENÇÃO

1. **SEMPRE fazer backup antes de executar**
2. Executar em ORDEM (Passo 1 → 2 → 3 → 4 → 5)
3. Verificar resultados de cada passo antes de continuar
4. **Passo 3 precisa de decisão** sobre as 896 lentes órfãs
5. **Passo 5 expõe views públicas** - garantir RLS configurado se necessário

---

## 📞 SUPORTE

Se algo der errado:
1. Verificar mensagens de erro
2. Consultar documentação em `ARQUITETURA_DEFINITIVA.md`
3. Ver exemplos em `EXEMPLOS_USO_ARQUITETURA.sql`
4. Abrir visualização em `visualizacao-banco.html`
