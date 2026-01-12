# 🔍 Resultados da Investigação - Nova Sidebar

**Data:** 11/01/2026  
**Objetivo:** Investigar dados disponíveis no banco para implementar nova estrutura de navegação

---

## 📊 RESUMO EXECUTIVO

### Recursos Disponíveis no Banco:
- ✅ **11 Fornecedores** (`core.fornecedores`)
- ✅ **Marcas** (`lens_catalog.marcas`) - quantidade a confirmar após rodar query corrigida
- ✅ **1,411 Lentes Individuais** ativas (`lens_catalog.lentes`)
- ✅ **461 Grupos Canônicos** (`lens_catalog.grupos_canonicos`)
- ✅ **401 Grupos Standard** (filtrados de `v_grupos_canonicos`)
- ✅ **60 Grupos Premium** (`v_grupos_premium`)

### Schemas Identificados:
- `core` - Dados mestres (fornecedores)
- `lens_catalog` - Catálogo de lentes (grupos, lentes, marcas)
- `compras` - Sistema de compras JIT (estoque, pedidos, histórico preços)
- `public` - Views para acesso da aplicação
- `auth`, `storage`, `realtime` - Supabase internals

---

## 1️⃣ FORNECEDORES - ✅ IMPLEMENTÁVEL

### Dados Disponíveis:
```
Tabela: core.fornecedores
Total: 11 fornecedores
Campos: 17 colunas
```

### Estrutura da Tabela:
| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | uuid | Identificador único |
| `nome` | text | Nome fantasia |
| `razao_social` | text | Razão social |
| `cnpj` | varchar | CNPJ |
| `cep_origem`, `cidade_origem`, `estado_origem` | text | Localização |
| `prazo_visao_simples` | integer | Prazo de entrega (dias) |
| `prazo_multifocal` | integer | Prazo de entrega (dias) |
| `prazo_surfacada` | integer | Prazo de entrega (dias) |
| `prazo_free_form` | integer | Prazo de entrega (dias) |
| `frete_config` | jsonb | Configuração de frete |
| `desconto_volume` | jsonb | Regras de desconto |
| `ativo` | boolean | Status ativo/inativo |
| `created_at`, `updated_at`, `deleted_at` | timestamp | Auditoria |

### Marcas por Fornecedor:
Query 1.3B retorna total de lentes por fornecedor e quantidade de marcas diferentes usadas.

### Status: 🟢 **PRONTO PARA IMPLEMENTAR**
- Criar página `/fornecedores/+page.svelte`
- Exibir cards com informações de cada fornecedor
- Mostrar estatísticas: total_lentes, marcas_diferentes_usadas
- Adicionar filtros: ativo/inativo, por estado
- Menu: 🏭 Fornecedores

---

## 2️⃣ RANKING - ✅ IMPLEMENTÁVEL

### Dados Disponíveis:
Usar view `public.v_grupos_canonicos` com ordenações diferentes.

### Top 10 Grupos Mais Caros:
```
Exemplo: Lente CR39 1.74 Multifocal +UV [-13.00/10.00] = R$ 7.275,88
Material predominante: CR39 1.74 (alto índice)
Tipo: Multifocal
```

### Top 10 Grupos com Mais Lentes:
```
Exemplo: Lente CR39 1.50 Multifocal +UV [-8.00/6.50] = 36 lentes disponíveis
Material predominante: CR39 1.50 (entrada)
Preço médio: R$ 2.620,31
```

### Top 10 Grupos Premium:
```
Exemplo: Lente CR39 1.74 Multifocal +UV +fotocromático = R$ 9.123,76
Tratamentos: UV + Fotocromático
Tipo: Multifocal
```

### Distribuição por Tipo de Lente:
| Tipo | Total Grupos | Preço Médio | Total Lentes |
|------|--------------|-------------|--------------|
| Visão Simples | 218 | R$ 1.501,23 | 394 |
| Multifocal | 182 | R$ 2.946,94 | 754 |
| Bifocal | 1 | R$ 555,05 | 2 |

### Status: 🟢 **PRONTO PARA IMPLEMENTAR**
- Criar página `/ranking/+page.svelte`
- Seções: Mais Caros, Mais Populares, Premium Destaque
- Gráficos: Distribuição por tipo, por material
- Filtros: tipo_lente, material, is_premium
- Menu: 🏆 Ranking

---

## 3️⃣ HISTÓRICO/VENDAS - ⚠️ ESTRUTURA EXISTE, INTEGRAÇÃO PENDENTE

### Descoberta Importante:
O usuário esclareceu a arquitetura:

> "isso o outro app que vai USAR e devemos fazer da sequinte maneira, criar um documento de como usar, e a jornada da compra é a seguinte, comprou no pdv, vai para uma tabela de historico de compra, ou seja, entrada no estoque jit, e quando o outro app que é o de compra de lentes ai sim, faz a compra correta, porque devemos pensar assim, o pdv só tem acesso as lentes canonicas standard e premium, e com isso só depois da compra no laboratoio teremos o id real da lente ou o sku real"

### Tabelas Existentes no Schema `compras`:
| Tabela | Tipo | Descrição |
|--------|------|-----------|
| `pedidos` | BASE TABLE | Pedidos de compra |
| `pedido_itens` | BASE TABLE | Itens dos pedidos |
| `estoque_movimentacoes` | BASE TABLE | Movimentações de estoque |
| `estoque_saldo` | BASE TABLE | Saldo atual de estoque |
| `historico_precos` | BASE TABLE | Histórico de preços |
| `v_pedidos_completos` | VIEW | Pedidos com todos os dados |
| `v_itens_pendentes` | VIEW | Itens pendentes de recebimento |
| `v_estoque_alertas` | VIEW | Alertas de estoque baixo |

### Views Disponíveis em `public`:
- `v_lentes_cotacao_compra` - Cotações para compra
- `v_pedidos_pendentes` - Pedidos pendentes

### Estrutura de Pedidos:
**Campos principais:**
- `id`, `numero_pedido`, `fornecedor_id`, `status`
- `data_pedido`, `data_confirmacao`, `data_previsao_entrega`, `data_recebimento`
- `valor_total`, `valor_frete`, `valor_desconto`, `subtotal`
- `observacoes`, `observacoes_internas`, `codigo_rastreio`
- `created_by`, `created_at`, `updated_at`, `deleted_at`

**Campos de Itens:**
- `pedido_id`, `lente_id`, `quantidade`, `quantidade_recebida`
- `preco_unitario`, `desconto_unitario`, `subtotal`

### Fluxo da Jornada:
1. **PDV** → Vende grupo canônico (Standard ou Premium)
2. **Histórico de Compra** → Registra entrada no estoque JIT
3. **App de Compras** → Faz compra real no laboratório
4. **SKU Real** → Só após compra no laboratório temos ID real da lente

### Status: 🟡 **ESTRUTURA PRONTA, INTEGRAÇÃO NECESSÁRIA**
- ✅ Tabelas de pedidos e estoque existem
- ✅ Views de análise existem
- ⚠️ Precisa integração com PDV (sistema externo)
- ⚠️ Precisa documentar jornada de uso
- 📝 Ação: Criar documento de integração PDV → Histórico → Compras

---

## 4️⃣ ANALYTICS/BI - ✅ DADOS DISPONÍVEIS

### Distribuição de Preços:
| Faixa de Preço | Quantidade Grupos | Premium |
|----------------|-------------------|---------|
| Até R$ 300 | 20 | false |
| R$ 300 - 500 | 69 | false |
| R$ 500 - 1000 | 82 | false |
| R$ 1000 - 2000 | 64 | false |
| Acima de R$ 2000 | 166 | false |

### Distribuição por Material:
| Material | Total Grupos | Preço Médio | Total Lentes | Premium | Standard |
|----------|--------------|-------------|--------------|---------|----------|
| CR39 | 301 | R$ 2.329,18 | 851 | 0 | 301 |
| POLICARBONATO | 100 | R$ 1.630,86 | 299 | 0 | 100 |

### Tratamentos Mais Comuns:
| Tratamento | Grupos com Tratamento |
|------------|----------------------|
| UV | 401 |
| Antirreflexo | 214 |
| Blue Light | 179 |
| Fotossensível | 69 |

### Status: 🟢 **DADOS PRONTOS**
- Decisão do usuário: "juntar com o historico para termos tudo em um unico lugar"
- Criar módulo unificado: **📊 BI/Relatórios**
- Combinar analytics de catálogo + dados de vendas (quando integrado)
- Dashboards: Preços, Materiais, Tratamentos, Performance de Vendas

---

## 5️⃣ CATÁLOGO - ✅ IMPLEMENTADO

### Totais Confirmados:
| Tipo | Total Grupos | Preço Médio | Total Lentes |
|------|--------------|-------------|--------------|
| **Todos** | 401 | R$ 2.155,03 | 1.150 |
| **Standard** | 401 | R$ 2.155,03 | 1.150 |
| **Premium** | 60 | R$ 4.589,95 | 261 |

### Páginas Já Implementadas:
- ✅ `/catalogo` - Ver Tudo (401 grupos)
- ✅ `/catalogo/standard` - Standard (401 grupos)
- ✅ `/catalogo/premium` - Premium (60 grupos)

### Status: 🟢 **COMPLETO**
- Decisão do usuário: "só tems que ter 1" (remover duplicata do menu)
- Criar submenu:
  ```
  📦 Catálogo
     ├─ Ver Tudo
     ├─ Standard
     └─ Premium
  ```

---

## 6️⃣ COMPARAÇÃO - ❌ REMOVER

### Investigação:
```sql
-- Query 6.1: Verificar se existe tabela de comparações salvas
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name LIKE '%compar%';

-- Resultado: Success. No rows returned
```

```sql
-- Query 6.2: Verificar se existe histórico de decisões
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name LIKE '%decisao%' OR table_name LIKE '%decision%';

-- Resultado: Success. No rows returned
```

### Status: 🔴 **REMOVER DO MENU**
- Nenhuma tabela de comparação encontrada
- Nenhuma tabela de decisões encontrada
- Decisão do usuário: "não temos porque continuar com isso, depois te explico"
- Ação: Remover `/comparar` e `/decisao/[decisaoId]`

---

## 7️⃣ COMERCIAL - ❌ REMOVER

### Investigação:
```sql
-- Query 7.1: Verificar tabelas relacionadas a comercial
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name LIKE '%voucher%' 
   OR table_name LIKE '%cliente%'
   OR table_name LIKE '%comercial%';

-- Resultado: 
-- public.v_grupos_por_receita_cliente (view)
```

### Status: 🔴 **REMOVER DO MENU**
- Apenas 1 view relacionada (`v_grupos_por_receita_cliente`)
- Decisão do usuário: "não faz mais sentido com o pdv já rodando"
- PDV já gerencia parte comercial
- Ação: Remover `/comercial` do menu
- Considerar: Verificar se `/vouchers` é usado ou pode ser removido

---

## 📋 PLANO DE AÇÃO

### Fase 1: Limpeza de Navegação (30 minutos)
- [ ] Remover duplicata de Catálogo no menu
- [ ] Adicionar submenu ao Catálogo (Ver Tudo / Standard / Premium)
- [ ] Remover item "Comparar" do menu
- [ ] Remover item "Comercial" do menu
- [ ] Mesclar "Histórico" + "Analytics" em "📊 BI/Relatórios"

### Fase 2: Implementar Ranking (2 horas)
- [ ] Criar `/ranking/+page.svelte`
- [ ] Adicionar API method `CatalogoAPI.buscarGruposRanking()`
- [ ] Seções: Top Caros, Top Populares, Top Premium
- [ ] Gráficos: Distribuição tipo/material
- [ ] Adicionar ao menu: 🏆 Ranking

### Fase 3: Implementar Fornecedores (2 horas)
- [ ] Criar `/fornecedores/+page.svelte`
- [ ] Criar `FornecedoresAPI` com métodos CRUD
- [ ] Exibir cards com dados dos 11 fornecedores
- [ ] Mostrar estatísticas de lentes por fornecedor
- [ ] Exibir prazos de entrega por tipo
- [ ] Verificar se já existe no menu (🏭 Fornecedores)

### Fase 4: Documentar Integração (1 hora)
- [ ] Criar `docs/INTEGRACAO_PDV_HISTORICO.md`
- [ ] Documentar jornada: PDV → Histórico → Compras
- [ ] Explicar conceito de grupo canônico vs SKU real
- [ ] Definir contratos de API entre sistemas
- [ ] Especificar tabelas usadas: `compras.pedidos`, `compras.estoque_movimentacoes`

### Fase 5: Módulo BI/Relatórios (4 horas)
- [ ] Criar `/bi/+page.svelte` (unificação de Histórico + Analytics)
- [ ] Seção 1: Analytics de Catálogo (preços, materiais, tratamentos)
- [ ] Seção 2: Histórico de Vendas (quando integrado com PDV)
- [ ] Seção 3: Performance de Fornecedores (prazos, volumes)
- [ ] Dashboards interativos com gráficos
- [ ] Atualizar menu: 📊 BI/Relatórios

### Fase 6: Remover Páginas Obsoletas (30 minutos)
- [ ] Arquivar páginas demo: `/demo/*`
- [ ] Remover `/comparar` (se existir)
- [ ] Remover `/comercial` (se existir)
- [ ] Remover `/decisao/[decisaoId]` (se existir)
- [ ] Avaliar: `/vouchers`, `/simulador/receita`

---

## 🗂️ TABELAS DISPONÍVEIS (Resumo)

### Schema `core`:
- `fornecedores` (11 registros)

### Schema `lens_catalog`:
- `lentes` (1,411 ativos)
- `grupos_canonicos` (461 grupos)
- `marcas` (quantidade TBD)
- `lentes_canonicas`
- `premium_canonicas`

### Schema `compras`:
- `pedidos`
- `pedido_itens`
- `estoque_movimentacoes`
- `estoque_saldo`
- `historico_precos`

### Schema `public` (Views):
- `v_grupos_canonicos` (401 standard)
- `v_grupos_premium` (60 premium)
- `v_lentes_catalogo`
- `v_fornecedores_catalogo`
- `v_estatisticas_catalogo`
- `v_grupos_por_faixa_preco`
- `v_grupos_melhor_margem`
- `v_lentes_cotacao_compra`
- `v_pedidos_pendentes`
- E mais 15 views...

---

## ✅ CONCLUSÕES

### ✅ Implementável Imediatamente:
1. **Ranking** - Dados completos, só precisa UI
2. **Fornecedores** - 11 fornecedores prontos com estrutura completa

### ⚠️ Precisa Integração:
3. **BI/Relatórios** - Analytics pronto, vendas depende de PDV

### ❌ Remover:
4. **Comparar** - Sem dados, sem necessidade
5. **Comercial** - PDV já gerencia

### 🎯 Próximos Passos:
1. Executar query FINAL corrigida para confirmar totais
2. Iniciar Fase 1 (Limpeza de navegação)
3. Implementar Ranking (prioridade usuário: "para eu ver se faz sentido")
4. Implementar Fornecedores (dados já disponíveis)
