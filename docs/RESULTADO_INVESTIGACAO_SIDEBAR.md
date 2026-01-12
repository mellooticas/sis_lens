# 📊 Resultado da Investigação - Nova Sidebar
**Data:** 11/01/2026  
**Objetivo:** Consolidar dados encontrados no banco para implementar nova navegação

---

## ✅ 1. FORNECEDORES - Dados Disponíveis

### Estrutura da Tabela
- **Schema:** `core.fornecedores`
- **Total:** 11 fornecedores cadastrados
- **Campos principais:**
  - `id`, `nome`, `razao_social`, `cnpj`
  - `cep_origem`, `cidade_origem`, `estado_origem`
  - Prazos: `prazo_visao_simples`, `prazo_multifocal`, `prazo_surfacada`, `prazo_free_form`
  - `frete_config` (JSONB) - configurações de frete
  - `desconto_volume` (JSONB) - descontos por quantidade
  - `ativo`, timestamps

### Fornecedores Cadastrados (Amostra)
1. **Brascor** - Brascor Distribuidora de Lentes
2. **Sygma** - Sygma Lentes Laboratório Óptico
3. **São Paulo Acessórios** - Produtos INFINITY

**Status:** ✅ **PRONTO PARA USAR**
- Dados completos no banco
- Precisa criar interface de listagem/detalhes
- Pode mostrar marcas e lentes vinculadas

---

## 🏆 2. RANKING - Dados para Implementar

### Top 10 Mais Caros
- **Líder:** CR39 1.74 Multifocal +UV - R$ 7.676,74 (6 lentes)
- **Padrão:** CR39 1.74 com tratamentos avançados
- **Faixa:** R$ 7.275 - R$ 7.676

### Top 10 Mais Vendidos (por quantidade)
- **Líder:** CR39 1.50 Multifocal +UV - 36 lentes
- **2º lugar:** POLICARBONATO 1.59 Multifocal +UV +Blue - 30 lentes
- **3º lugar:** CR39 1.67 Multifocal +UV - 24 lentes

### Top 10 Premium Mais Caros
- **Líder:** CR39 1.74 Multifocal +UV +fotocromático - R$ 9.123,76
- **Característica:** Todos com tratamento fotocromático
- **Faixa:** R$ 7.461 - R$ 9.123

### Distribuição por Tipo
- **Visão Simples:** 218 grupos | Preço médio: R$ 1.501 | 394 lentes
- **Multifocal:** 182 grupos | Preço médio: R$ 2.946 | 754 lentes
- **Bifocal:** 1 grupo | Preço médio: R$ 555 | 2 lentes

**Status:** ✅ **DADOS PRONTOS**
- Views já retornam tudo
- Precisa criar página `/ranking`
- Sugestão de abas: Mais Caros | Mais Vendidos | Premium | Por Tipo

---

## 📦 3. HISTÓRICO/VENDAS - Schema Compras Existente

### ⚠️ IMPORTANTE: Integração com PDV

**Jornada da Compra:**
1. **PDV** vende lente → usa grupos canônicos (standard/premium)
2. Registra em **tabela de histórico de compra** (entrada JIT no estoque)
3. **App de Compras** faz pedido real ao laboratório
4. Após confirmação, registra **ID real da lente/SKU** no sistema

**Tabelas Disponíveis no Schema `compras`:**
- ✅ `pedidos` - Pedidos de compra
- ✅ `pedido_itens` - Itens dos pedidos
- ✅ `estoque_movimentacoes` - Movimentações
- ✅ `estoque_saldo` - Saldo atual
- ✅ `historico_precos` - Histórico de preços
- ✅ `v_pedidos_completos` - View consolidada
- ✅ `v_itens_pendentes` - Itens pendentes
- ✅ `v_estoque_alertas` - Alertas de estoque

### Views Public Relacionadas
- `v_lentes_cotacao_compra`
- `v_pedidos_pendentes`

**Status:** 🔄 **INTEGRAÇÃO NECESSÁRIA**
- Schema de compras **EXISTE** mas é do outro app
- Precisa criar **documento de integração**
- Definir tabela de histórico de vendas do PDV
- Mapear: grupo_canonico_id → lente_id real após compra

---

## 📊 4. ANALYTICS/BI - Dados Disponíveis

### Distribuição de Preços
| Faixa | Quantidade | Tipo |
|-------|-----------|------|
| Até R$ 300 | 20 grupos | Standard |
| R$ 300 - 500 | 69 grupos | Standard |
| R$ 500 - 1000 | 82 grupos | Standard |
| R$ 1000 - 2000 | 64 grupos | Standard |
| Acima de R$ 2000 | 166 grupos | Standard |

**Observação:** Nenhum grupo premium nesta distribuição (todos acima de R$ 2000)

### Distribuição por Material
| Material | Grupos | Preço Médio | Lentes | Premium | Standard |
|----------|--------|-------------|--------|---------|----------|
| CR39 | 301 | R$ 2.329 | 851 | 0 | 301 |
| POLICARBONATO | 100 | R$ 1.630 | 299 | 0 | 100 |

### Tratamentos Mais Comuns
*(Query corrigida - aguardando resultado após fix)*

**Status:** ✅ **DADOS PRONTOS**
- Views retornam tudo para gráficos
- Pode criar dashboards interativos
- Sugestão: juntar com Histórico em página única `/analytics`

---

## 📦 5. CATÁLOGO - Confirmação

### Totais Consolidados
- **Todos:** 401 grupos | Preço médio: R$ 2.100 | 1.150 lentes
- **Standard:** 401 grupos | Preço médio: R$ 2.100 | 1.150 lentes  
- **Premium:** 60 grupos | Preço médio: R$ X.XXX | XXX lentes

**Status:** ✅ **IMPLEMENTADO**
- `/catalogo` - Completo (461 grupos)
- `/catalogo/standard` - 401 grupos
- `/catalogo/premium` - 60 grupos
- ⚠️ **Remover duplicata do menu**

---

## ⚖️ 6. COMPARAÇÃO - Não Implementar

### Resultado da Investigação
*(Aguardando resultado das queries 6.1 e 6.2)*

**Decisão do Usuário:** "não temos porque continuar com isso, depois te explico"

**Status:** ❌ **REMOVER DO MENU**
- Não faz sentido manter
- Funcionalidade será explicada depois

---

## 💼 7. COMERCIAL - Não Implementar

### Resultado da Investigação
*(Aguardando resultado das queries 7.1 e 7.2)*

**Decisão do Usuário:** "não faz mais sentido com o pdv já rodanto"

**Status:** ❌ **REMOVER DO MENU**
- PDV já gerencia vendas
- Sistema de vouchers pode ser arquivado
- Funcionalidades comerciais no PDV

---

## 🎯 Resumo Executivo

### ✅ Implementar Agora
1. **Dashboard** - Página inicial com visão geral
2. **Catálogo** - Submenu (Completo, Standard, Premium) ✅ FEITO
3. **Fornecedores** - Lista + detalhes + marcas/lentes
4. **Ranking** - Top lentes por diversos critérios
5. **Analytics** - Dashboards + gráficos (juntar com Histórico)
6. **Configurações** - Manter existente

### ❌ Remover do Menu
- **Comparação** - Não faz mais sentido
- **Comercial** - PDV já gerencia
- **Catálogo duplicado** - Item repetido

### 🔄 Pendente (Integração)
- **Histórico/Vendas** - Aguarda definição de integração com PDV
  - Criar documento de jornada da compra
  - Definir tabela de histórico
  - Mapear grupo_canonico → lente_id real

---

## 📋 Nova Estrutura Final da Sidebar

```
🏠 Dashboard
📦 Catálogo
   ├─ 🔍 Completo (461)
   ├─ 📋 Standard (401)
   └─ 👑 Premium (60)
🏭 Fornecedores
🏆 Ranking
📊 Analytics & Histórico
⚙️ Configurações
```

---

## 🔗 Schemas Importantes

### Schemas Disponíveis
- `auth` - Autenticação Supabase
- **`core`** - Fornecedores, marcas
- **`lens_catalog`** - Lentes, grupos canônicos
- **`compras`** - Pedidos, estoque (outro app)
- `contact_lens` - Lentes de contato
- `public` - Views públicas
- `public_api` - API pública
- `storage`, `realtime`, `vault` - Supabase

### Views Principais
- `public.v_grupos_canonicos` - 461 grupos (todos)
- `public.v_grupos_premium` - 60 grupos premium
- `public.v_lentes_catalogo` - Lentes individuais
- `compras.v_pedidos_completos` - Pedidos completos
- `compras.v_itens_pendentes` - Itens pendentes
- `compras.v_estoque_alertas` - Alertas

---

## 📝 Próximos Passos

### Fase 1: Limpeza (Hoje)
1. [ ] Remover item "Catálogo" duplicado do menu
2. [ ] Remover "Comparação" do menu
3. [ ] Remover "Comercial" do menu
4. [ ] Adicionar submenu Catálogo (dropdown)

### Fase 2: Implementação (Esta Sprint)
5. [ ] Criar página `/fornecedores` completa
6. [ ] Criar página `/ranking` com 4 abas
7. [ ] Criar página `/analytics` (juntar com histórico)
8. [ ] Arquivar páginas demo e obsoletas

### Fase 3: Integração (Próxima Sprint)
9. [ ] Criar documento "Jornada da Compra PDV → Compras"
10. [ ] Definir estrutura de histórico de vendas
11. [ ] Implementar API de integração PDV
12. [ ] Testar fluxo grupo_canonico → lente_id

---

**Status Geral:** 📊 Investigação Completa | 🔄 Aguardando queries finais  
**Última atualização:** 11/01/2026
