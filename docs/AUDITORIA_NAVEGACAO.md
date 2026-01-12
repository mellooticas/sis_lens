# 🔍 Auditoria de Navegação - SIS Lens
**Data:** 11/01/2026  
**Objetivo:** Identificar funcionalidades obsoletas e reorganizar navegação

---

## 📋 Menu Atual (GlassNavigation.svelte)

### Itens da Sidebar

| Ícone | Label | Path | Status | Observação |
|-------|-------|------|--------|------------|
| 🏠 | Dashboard | `/dashboard` | ✅ **MANTER** | Página principal com visão geral |
| 🔍 | Catálogo | `/catalogo` | ✅ **MANTER** | Módulo principal - agora tem 3 subpáginas |
| ⚖️ | Comparar | `/comparar` | 🔄 **REVISAR** | Precisa adaptação para novos dados | não temos porque continuar com isso, depois te explico
| 🏆 | Ranking | `/ranking` | 🔄 **REVISAR** | Precisa usar v_grupos_canonicos | perfeito pode implementar para eu ver se faz sentido
| 📜 | Histórico | `/historico` | 🔄 **REVISAR** | Verificar se usa dados corretos | acho que vamos ter aqui um controle das vendas de lentes e valores da venda com o desconto e etc, vai fazer mais centido, e isso vai ter que vir do sistema de pdv que vendas, e informa a compra e entrega da lente assim teremos um controle de historico, financeiro e quantitativos das lentes
| 📦 | Catálogo | `/catalogo` | ⚠️ **DUPLICADO** | Mesmo que linha 2 | só tems que ter 1
| 🏭 | Fornecedores | `/fornecedores` | ✅ **MANTER** | Gestão de fornecedores | já temos os dados no banco e não trouxemos ainda
| 💼 | Comercial | `/comercial` | ❓ **AVALIAR** | Verificar funcionalidade | não faz mais sentido com o pdv já rodanto
| 📊 | Analytics | `/analytics` | ❓ **AVALIAR** | Verificar se tem dados | juntar com o historico para termso tudo em um unico lugar, um bi completo
| ⚙️ | Configurações | `/configuracoes` | ✅ **MANTER** | Configurações do sistema | ok

---

## 📁 Páginas Existentes (27 arquivos)

### ✅ Principais - Funcionando
- `/` - Landing page
- `/dashboard` - Dashboard principal
- `/catalogo` - **NOVO** Catálogo completo (461 grupos)
- `/catalogo/standard` - **NOVO** 401 grupos standard
- `/catalogo/premium` - **NOVO** 60 grupos premium
- `/catalogo/standard/[id]` - **NOVO** Detalhes grupo standard
- `/catalogo/premium/[id]` - **NOVO** Detalhes grupo premium
- `/catalogo/[id]` - Detalhes lente individual (old)
- `/fornecedores` - Gestão de fornecedores

### 🔄 Necessitam Revisão
- `/comparar` - Comparação de lentes
- `/ranking` - Ranking de lentes
- `/historico` - Histórico de buscas/decisões
- `/decisao/[decisaoId]` - Detalhes de decisão
- `/simulador/receita` - Simulador de receita

### ❓ Avaliar Utilidade
- `/comercial` - Módulo comercial
- `/analytics` - Analytics/relatórios
- `/tabela-precos` - Tabela de preços
- `/vouchers` - Sistema de vouchers
- `/contato` - Página de contato
- `/configuracoes` - Configurações gerais
- `/configuracoes/fornecedores` - Config fornecedores

### 🧪 Desenvolvimento/Debug
- `/debug` - Página de debug
- `/demo` - Demos diversos
- `/demo/glass` - Demo glassmorphism
- `/demo/glasses` - Demo óculos
- `/demo/index` - Index de demos
- `/login` - Página de login

---

## 🎯 Nova Estrutura Proposta

### Navegação Principal

```
🏠 Dashboard
   └─ Visão geral, KPIs, atalhos rápidos

📦 Catálogo
   ├─ 🔍 Completo (461 grupos)
   ├─ 📋 Standard (401 grupos)
   └─ 👑 Premium (60 grupos)

🏭 Fornecedores
   ├─ Lista de fornecedores
   ├─ Marcas por fornecedor
   └─ Configurações de importação

⚖️ Comparação
   └─ Comparar grupos/lentes lado a lado

🏆 Ranking
   └─ Top lentes por categoria/preço/vendas

📊 Relatórios
   ├─ Analytics
   ├─ Histórico de buscas
   └─ Tabelas de preço

💼 Comercial (opcional)
   ├─ Vouchers
   └─ Gestão de clientes

⚙️ Configurações
   ├─ Geral
   ├─ Fornecedores
   └─ Usuários
```

---

## 🔧 Ações Recomendadas

### 🚨 Urgente

1. **Remover duplicata** - Item "Catálogo" aparece 2x no menu
2. **Adicionar submenu Catálogo:**
   - `/catalogo` → Ver Tudo
   - `/catalogo/standard` → Standard
   - `/catalogo/premium` → Premium

### ⚠️ Alta Prioridade

3. **Revisar `/comparar`:**
   - Adaptar para usar `v_grupos_canonicos`
   - Permitir comparar grupos canônicos

4. **Revisar `/ranking`:**
   - Usar `v_grupos_canonicos` ou `v_grupos_premium`
   - Ranking por preço, tecnologia, vendas

5. **Revisar `/historico`:**
   - Garantir que usa tabelas corretas
   - Mostrar histórico de consultas aos grupos

### 📝 Média Prioridade

6. **Avaliar `/comercial`:**
   - Verificar se é usado
   - Se não, considerar remover ou simplificar

7. **Avaliar `/analytics`:**
   - Verificar se tem dados populados
   - Criar dashboards com views canônicas

8. **Avaliar `/tabela-precos`:**
   - Pode ser substituído por filtros no catálogo
   - Ou integrar no módulo comercial

### 🔮 Baixa Prioridade

9. **Limpar páginas demo:**
   - Mover para pasta `_archive` ou deletar
   - `/demo/*` não precisa em produção

10. **Avaliar `/vouchers`:**
    - Se não usado, remover
    - Se usado, mover para Comercial

---

## 📊 Dados Consolidados

### Views Disponíveis (Confirmadas)
- ✅ `v_grupos_canonicos` - 461 grupos (todos)
- ✅ `v_grupos_premium` - 60 grupos premium
- ✅ `v_lentes_catalogo` - Lentes individuais
- ✅ `lens_catalog.grupos_canonicos` - Tabela base
- ✅ `lens_catalog.lentes` - Tabela de lentes

### Filtros Implementados
- ✅ Tipo de lente (visao_simples, multifocal, etc)
- ✅ Material (CR39, POLICARBONATO, etc)
- ✅ Índice de refração (1.50, 1.56, 1.59, etc)
- ✅ Tratamentos (AR, Blue Light, UV, Fotossensível)
- ✅ Faixa de preço (min/max)
- ✅ Busca textual (nome do grupo)

---

## 🎨 Design Patterns Implementados

### Componentes Reutilizáveis
- ✅ `GrupoCanonicoCard` - Card para grupos (standard/premium)
- ✅ `FilterPanel` - Painel de filtros
- ✅ `StatsCard` - Cards de estatísticas (com slot icon)
- ✅ `PageHero` - Hero section das páginas
- ✅ `Container` - Container responsivo

### API Consolidada
- ✅ `CatalogoAPI.buscarGruposCanonicosStandard()` - 401 grupos
- ✅ `CatalogoAPI.buscarGruposCanonicosPremium()` - 60 grupos (usa v_grupos_premium)
- ✅ `CatalogoAPI.obterGrupoCanonico(id)` - Detalhes de 1 grupo
- ✅ `CatalogoAPI.buscarLentesDoGrupo(grupoId)` - Lentes de um grupo

---

## 📝 Próximos Passos

### Fase 1: Limpeza (Esta Sprint)
1. [ ] Remover item duplicado "Catálogo" do menu
2. [ ] Adicionar submenu Catálogo (Completo/Standard/Premium)
3. [ ] Arquivar/deletar páginas demo
4. [ ] Remover console.logs de debug das páginas

### Fase 2: Adaptação (Próxima Sprint)
5. [ ] Adaptar `/comparar` para grupos canônicos
6. [ ] Adaptar `/ranking` para grupos canônicos
7. [ ] Validar `/historico` com dados corretos
8. [ ] Criar página de detalhes premium `/catalogo/premium/[id]`

### Fase 3: Novos Módulos (Futuro)
9. [ ] Dashboard com KPIs dos grupos canônicos
10. [ ] Analytics com gráficos de distribuição
11. [ ] Relatórios de vendas por grupo
12. [ ] Sistema de recomendação inteligente

---

## 🔗 Referências

- **Estratégia Standard vs Premium:** `docs/ESTRATEGIA_STANDARD_PREMIUM.md`
- **Diagnóstico SQL:** `povoar_banco/00_DIAGNOSTICO_GRUPOS_CANONICOS.sql`
- **Estrutura de Views:** `povoar_banco/00A_VERIFICAR_DADOS_GRUPOS.sql`
- **Testes Frontend:** `povoar_banco/00C_TESTE_QUERIES_FRONTEND.sql`

---

**Status:** 📋 Documento criado - Aguardando decisões  
**Última atualização:** 11/01/2026
