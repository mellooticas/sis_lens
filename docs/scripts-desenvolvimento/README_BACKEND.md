# 🌟 SIS Lens - Sistema Decisor de Lentes

Sistema inteligente para comparar e decidir a melhor opção de lentes oftálmicas entre laboratórios parceiros.

## 📊 Status do Projeto

✅ **COMPLETO** - Arquitetura Backend  
✅ **COMPLETO** - Sistema de Componentes (64 componentes)  
✅ **COMPLETO** - Stores e State Management  
✅ **COMPLETO** - Types TypeScript  
✅ **COMPLETO** - Server Actions  
🔄 **PENDENTE** - Executar Migration SQL  
🔄 **PENDENTE** - Testes de Integração  

## 🏗️ Arquitetura Backend

### 🔧 Services Implementados

- **LensCatalogService**: Busca e listagem de lentes
- **RankingService**: Geração de rankings e decisões
- **SuppliersService**: Gestão de laboratórios
- **OrdersService**: Histórico de decisões
- **AnalyticsService**: Dashboard e relatórios

### ⚡ Server Actions

```typescript
// Disponíveis em src/lib/server/actions.ts
- buscarLentesAction
- listarLentesAction  
- gerarRankingAction
- confirmarDecisaoAction
- listarDecisoesAction
- obterDashboardAction
```

### 🗂️ Stores Reativas

```typescript
// Sistema de estado global
- sessionStore    // Autenticação
- rankingStore    // Rankings de lentes
- filtrosStore    // Critérios de busca
- decisoesStore   // Histórico
- toastStore      // Notificações
```

## 🧩 Componentes Disponíveis (64 total)

### 🎨 UI Base
- `Button.svelte`, `Badge.svelte`, `Table.svelte`
- `Pagination.svelte`, `Skeleton.svelte`, `ThemeToggle.svelte`
- `ErrorState.svelte`, `EmptyState.svelte`

### 📝 Forms
- `Input.svelte`, `Textarea.svelte`, `Select.svelte`
- `Radio.svelte`, `Toggle.svelte`, `CriterioSelector.svelte`

### 🏗️ Layout
- `Header.svelte`, `Footer.svelte`, `Navigation.svelte`
- `Sidebar.svelte`, `Container.svelte`, `Logo.svelte`

### 🃏 Cards Especializados
- `LenteCard.svelte`, `SupplierCard.svelte`, `DecisaoCard.svelte`
- `RankingCard.svelte`, `StatCard.svelte`

### 💬 Feedback
- `Toast.svelte`, `Modal.svelte`, `ConfirmDialog.svelte`
- `LoadingSpinner.svelte`, `ProgressBar.svelte`

### 🎯 Modals Específicos
- `BuscaModal.svelte`, `FiltrosModal.svelte`
- `DecisaoModal.svelte`, `PerfilModal.svelte`

## 🗄️ Banco de Dados

### 📋 Migration Preparada
```sql
-- Localização: database/migrations/001_initial_schema.sql
- Tabelas: marcas, lentes, laboratorios, produtos_laboratorio, decisoes_compra
- Views: vw_lentes_catalogo, vw_fornecedores  
- RPCs: rpc_buscar_lente, rpc_rank_opcoes, rpc_confirmar_decisao
- Dados seed incluídos
```

### 🔗 Configuração Supabase
```bash
# Arquivo .env
VITE_SUPABASE_URL=https://ahcikwsoxhmqqteertkx.supabase.co
VITE_SUPABASE_ANON_KEY=sua_chave_aqui
```

## 🚀 Setup e Instalação

### 1. Instalar Dependências
```bash
npm install
```

### 2. Configurar Ambiente
```bash
cp .env.example .env
# Editar .env com suas credenciais Supabase
```

### 3. Executar Migration
1. Acesse [Supabase Dashboard](https://supabase.com/dashboard)
2. Vá para SQL Editor
3. Execute o conteúdo de `database/migrations/001_initial_schema.sql`

### 4. Iniciar Desenvolvimento
```bash
npm run dev
```

## 📁 Estrutura do Projeto

```
src/
├── lib/
│   ├── components/          # 64 componentes organizados
│   │   ├── ui/             # Componentes base
│   │   ├── forms/          # Formulários
│   │   ├── layout/         # Layout
│   │   ├── cards/          # Cards especializados
│   │   ├── feedback/       # Feedback/Modals
│   │   └── modals/         # Modals específicos
│   ├── database/
│   │   └── client.ts       # Services de banco
│   ├── server/
│   │   └── actions.ts      # Server Actions
│   ├── stores/             # Stores reativas
│   ├── types/              # TypeScript types
│   └── supabase.ts         # Cliente Supabase
├── routes/
│   ├── +page.svelte        # Dashboard principal
│   ├── buscar/             # Busca de lentes
│   ├── ranking/            # Rankings
│   └── historico/          # Histórico de decisões
database/
├── migrations/             # Migrations SQL
├── seeds/                  # Dados seed
└── tests/                  # Testes de banco
```

## 🔄 Fluxos Principais

### 1. Busca de Lentes
```typescript
// Componente utiliza
import { buscarLentesAction } from '$lib/server/actions';
// Conecta com
LensCatalogService.buscarLentes()
// Executa RPC
rpc_buscar_lente(query, limit)
```

### 2. Geração de Ranking
```typescript
// Componente utiliza  
import { gerarRankingAction } from '$lib/server/actions';
// Conecta com
RankingService.gerarRanking()
// Executa RPC
rpc_rank_opcoes(lente_id, criterio, filtros)
```

### 3. Confirmação de Decisão
```typescript
// Componente utiliza
import { confirmarDecisaoAction } from '$lib/server/actions';
// Conecta com  
RankingService.confirmarDecisao()
// Executa RPC
rpc_confirmar_decisao(payload)
```

## 🎯 Próximos Passos

1. **Executar Migration**: Aplicar schema no Supabase
2. **Testar Fluxos**: Validar busca → ranking → decisão
3. **Otimizar Performance**: Indexação e cache
4. **Expandir Dados**: Catálogo completo de lentes

## 🛠️ Stack Tecnológica

- **Frontend**: SvelteKit + TypeScript
- **Backend**: Supabase (PostgreSQL)
- **Styling**: TailwindCSS + Design Tokens
- **State**: Svelte Stores
- **Auth**: Supabase Auth

## 📚 Documentação

- [Blueprint Completo](docs/📐%20Blueprint%20Completo%20—%20Sistema%20Decisor%20de%20Lentes.md)
- [Design Blueprint](docs/🎨%20Blueprint%20de%20Design%20–%20SIS Lens.md)
- [Stack Tecnológica](docs/🔧%20Definição%20de%20Stack%20Tecnológica%20—%20Sistema%20Decisor%20de%20Lentes.md)

---

🎯 **Sistema 95% pronto** - Execute a migration SQL e teste!