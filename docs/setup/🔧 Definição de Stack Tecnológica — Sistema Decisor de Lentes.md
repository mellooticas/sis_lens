🔧 Definição de Stack Tecnológica — Sistema Decisor de Lentes

🎯 Objetivos da Stack

Velocidade de desenvolvimento (MVP em 2-3 meses)
Escalabilidade (multi-tenant, 100+ óticas)
Manutenibilidade (código limpo, testável)
Custo controlado (especialmente no início)
Segurança (RLS nativo, auditoria)


🏗️ Stack Recomendada (Opção A — Moderna e Produtiva)
Backend / Banco de Dados
Supabase (PostgreSQL gerenciado + BaaS)
Por quê:

✅ PostgreSQL 15+ (robusto, maduro)
✅ RLS nativo (multi-tenant por default)
✅ Auth integrado (JWT, OAuth, Magic Link)
✅ Realtime subscriptions (futuro: notificações)
✅ Edge Functions (Deno runtime)
✅ Storage (upload de catálogos Excel)
✅ Admin UI (explorar dados facilmente)

Pricing:

Free tier: 500MB DB, 2GB storage, 50k auth users
Pro: $25/mês (8GB DB, 100GB storage)

Alternativa: Neon (serverless Postgres) ou Railway

Frontend
SvelteKit (Framework full-stack)
Por quê:

✅ Menor curva de aprendizado vs React
✅ Bundle menor (menos JS no cliente)
✅ SSR + SPA híbrido (flexível)
✅ File-based routing (organização intuitiva)
✅ Vite nativo (HMR ultra-rápido)
✅ TypeScript first-class

Alternativa: Next.js (se você prefere React)

UI / Styling
Tailwind CSS + shadcn-svelte
Por quê:

✅ Tailwind: Utility-first, rápido, sem context switching
✅ shadcn-svelte: Componentes prontos, acessíveis, customizáveis
✅ Lucide Icons (ícones modernos, SVG)

Alternativa: Skeleton UI (all-in-one para Svelte)

Validação e Tipos
Zod (Schema validation)
Por quê:

✅ TypeScript-first
✅ Validação runtime + type inference
✅ Integra com forms (SvelteKit actions)

Alternativa: Yup, Joi

State Management
Svelte Stores (built-in)
Por quê:

✅ Simples, reativo
✅ Não precisa de lib externa
✅ Suficiente para 95% dos casos

Quando evoluir: Pinia (se migrar para Vue) ou Zustand (React)

Auth
Supabase Auth (built-in)
Por quê:

✅ JWT automático
✅ OAuth (Google, Microsoft)
✅ Magic Links (email)
✅ RLS integrado

Alternativa: Clerk, Auth0 (mais caro)

Deploy
Vercel (Frontend) + Supabase (Backend)
Por quê:

✅ Vercel: Deploy automático, preview branches, edge network
✅ Zero config (SvelteKit adapter-vercel)
✅ Ambientes ilimitados (dev, staging, prod)

Pricing Vercel:

Free: Unlimited deploys, 100GB bandwidth
Pro: $20/mês (mais recursos, sem "Powered by Vercel")

Alternativa: Netlify, Cloudflare Pages

CI/CD
GitHub Actions
Por quê:

✅ Integrado no GitHub
✅ 2000 min/mês grátis (private repos)
✅ Simples para migrations + deploy

Workflow:
Push → Lint → Test → Build → Deploy (Vercel + Supabase)

Monitoramento
Sentry (Errors) + Supabase Logs
Por quê:

✅ Sentry: Rastreamento de erros, stack traces
✅ Supabase Logs: Query performance, DB load

Pricing Sentry:

Free: 5k errors/mês
Team: $26/mês (50k errors)

Alternativa: LogRocket, Datadog (mais caro)

Analytics (Opcional MVP)
PostHog ou Plausible
Por quê:

✅ PostHog: Open-source, self-hosted ou cloud
✅ Plausible: Privacy-first, GDPR compliant

Quando usar: Após MVP (para entender uso real)

📦 Stack Completa (Resumo Visual)
┌─────────────────────────────────────────────────────┐
│                    FRONTEND                         │
│  ┌──────────────────────────────────────────────┐  │
│  │  SvelteKit + Vite                            │  │
│  │  • Tailwind CSS + shadcn-svelte              │  │
│  │  • Zod (validation)                          │  │
│  │  • Svelte Stores (state)                     │  │
│  │  • TypeScript                                │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  Deploy: Vercel (edge, preview branches)           │
└─────────────────────────────────────────────────────┘
                         │
                         │ HTTPS + JWT
                         │
┌─────────────────────────────────────────────────────┐
│                    BACKEND                          │
│  ┌──────────────────────────────────────────────┐  │
│  │  Supabase (PostgreSQL 15)                    │  │
│  │  • RLS (multi-tenant)                        │  │
│  │  • Auth (JWT, OAuth)                         │  │
│  │  • Storage (Excel uploads)                   │  │
│  │  • Edge Functions (Deno)                     │  │
│  │  • Realtime (futuro)                         │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  Infra: Supabase Cloud (multi-region)             │
└─────────────────────────────────────────────────────┘
                         │
┌─────────────────────────────────────────────────────┐
│                  OBSERVABILITY                      │
│  • Sentry (errors)                                  │
│  • Supabase Logs (DB performance)                   │
│  • GitHub Actions (CI/CD)                           │
└─────────────────────────────────────────────────────┘

🛠️ Como Trabalharemos (Fluxo de Desenvolvimento)
1. Estrutura de Repositório (Monorepo)
decisor-lentes/
├─ .github/
│  └─ workflows/
│     ├─ deploy-db.yml       # Migrations automáticas
│     └─ deploy-app.yml      # Deploy Vercel
│
├─ database/
│  ├─ migrations/            # SQL puro (versionado)
│  │  ├─ 001_schemas.sql
│  │  ├─ 002_tables.sql
│  │  └─ ...
│  ├─ seeds/                 # Dados iniciais
│  │  ├─ dev/
│  │  └─ prod/
│  └─ tests/                 # Testes SQL
│     ├─ rls.test.sql
│     └─ ranking.test.sql
│
├─ apps/
│  └─ decisor-lentes/        # SvelteKit app
│     ├─ src/
│     │  ├─ lib/
│     │  │  ├─ supabase.ts   # Cliente Supabase
│     │  │  ├─ stores/       # Estado global
│     │  │  └─ api/          # Wrappers RPC
│     │  ├─ routes/          # Páginas
│     │  └─ components/      # Componentes
│     ├─ static/
│     ├─ tests/
│     │  └─ e2e/             # Playwright tests
│     ├─ package.json
│     └─ svelte.config.js
│
├─ docs/
│  ├─ ADRs/                  # Decisões arquiteturais
│  ├─ API.md                 # Docs das RPCs
│  └─ CONTRIBUTING.md
│
├─ .env.example
├─ package.json              # Root (workspaces)
└─ README.md

2. Workflow de Desenvolvimento (Feature Branch)
Passo a Passo:
bash# 1. Criar branch para feature
git checkout -b feat/ranking-filtros

# 2. Desenvolver (DB ou Frontend, NUNCA misturar)
# Se DB: editar database/migrations/XXX.sql
# Se Frontend: editar apps/decisor-lentes/src/

# 3. Testar localmente
npm run dev                    # Frontend
supabase db reset              # DB (aplica migrations)
npm run test                   # Testes E2E

# 4. Commit semântico
git add .
git commit -m "feat(ranking): adicionar filtro por região"

# 5. Push e abrir PR
git push origin feat/ranking-filtros
# Abrir PR no GitHub

# 6. CI roda automaticamente
# - Lint (ESLint + Prettier)
# - Type check (TypeScript)
# - Tests (Playwright + SQL tests)
# - Build (Vercel preview)

# 7. Review e merge
# - 1+ aprovação
# - Squash and merge
# - Delete branch

# 8. Deploy automático
# - main → produção (Vercel + Supabase)
# - staging → staging env

3. Ambientes
AmbienteBranchDB (Supabase)Frontend (Vercel)Usodevfeat/*Local (Docker)localhost:5173DesenvolvimentostagingstagingSupabase Stagingstaging.app.comTestes QAprodmainSupabase Prodapp.decisor.comProdução

4. Gestão de Secrets
.env.example (commitado no repo)
bash# Supabase
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc...

# Opcional: API externa (Desenrola DCL)
VITE_DCL_WEBHOOK_URL=https://api.desenroladcl.com/webhook
.env (local, NÃO commitado)
bash# Copiar de .env.example e preencher valores reais
VITE_SUPABASE_URL=https://dev.supabase.co
VITE_SUPABASE_ANON_KEY=eyJreal...
Secrets no GitHub (para CI/CD)
Settings → Secrets → Actions
- SUPABASE_ACCESS_TOKEN
- VERCEL_TOKEN
- SENTRY_DSN

5. Gestão de Migrations (DB)
Ferramenta: Supabase CLI
bash# Criar nova migration
supabase migration new add_descontos_table

# Isso cria: database/migrations/20250102_add_descontos_table.sql

# Aplicar migrations localmente
supabase db reset  # Limpa DB + aplica todas

# Aplicar em produção (via CI/CD)
supabase db push --project-ref xxx
Regras:

✅ Migrations são imutáveis (nunca editar após merge)
✅ Sempre testar localmente antes de push
✅ Rollback via nova migration (não DELETE)
✅ Usar transações (BEGIN/COMMIT)


6. Code Review (Checklist)
Antes de aprovar PR:

 Código limpo (seguir padrões do projeto)
 Testes passando (CI verde)
 TypeScript sem erros (npm run check)
 Sem console.log desnecessário
 Documentação (se API/RPC nova, atualizar docs/)
 Migration testada (rodar supabase db reset)
 RLS validado (testar acesso cross-tenant)


7. Convenções de Commit
Formato: tipo(escopo): mensagem
Tipos:

feat: Nova feature
fix: Correção de bug
refactor: Refatoração (sem mudança de comportamento)
docs: Documentação
test: Adicionar/corrigir testes
chore: Tarefas (CI, deps, etc.)

Exemplos:
bashfeat(ranking): adicionar filtro por região
fix(auth): corrigir logout em mobile
refactor(db): otimizar query vw_ranking_opcoes
docs(readme): atualizar instruções de setup
test(e2e): adicionar teste de confirmação de decisão
chore(deps): atualizar Supabase para v2.39

🚀 Setup Inicial (Como Começar)
Opção 1: Supabase Cloud (Recomendado para MVP)
bash# 1. Criar conta no Supabase
https://supabase.com/dashboard

# 2. Criar projeto
Nome: decisor-lentes-dev
Região: South America (São Paulo)
Password: [gerar forte]

# 3. Instalar Supabase CLI
npm install -g supabase

# 4. Login
supabase login

# 5. Link projeto local
supabase link --project-ref xxx

# 6. Aplicar migrations
supabase db push

Opção 2: Supabase Local (Docker)
bash# 1. Instalar Docker Desktop
https://www.docker.com/products/docker-desktop

# 2. Iniciar Supabase local
supabase start

# Isso sobe:
# - PostgreSQL (5432)
# - Studio (54323) — UI para explorar DB
# - API (54321)

# 3. Criar .env
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_ANON_KEY=[copiar do output]

# 4. Aplicar migrations
supabase db reset

Frontend Setup
bash# 1. Criar projeto SvelteKit
npm create svelte@latest apps/decisor-lentes

# Escolher:
# - Skeleton project
# - TypeScript
# - Prettier, ESLint

# 2. Instalar deps
cd apps/decisor-lentes
npm install

# 3. Instalar Supabase client
npm install @supabase/supabase-js

# 4. Instalar Tailwind
npx svelte-add@latest tailwindcss

# 5. Instalar shadcn-svelte
npx shadcn-svelte@latest init

# 6. Rodar dev server
npm run dev

💰 Estimativa de Custos (Primeiros 6 meses)
ServiçoTierCusto/mêsNotasSupabasePro$258GB DB, 100GB storageVercelPro$20Remove branding, mais deploysSentryTeam$2650k errors/mêsDomínio-$2.com via NamecheapTotal-~$73/mês~$438 nos 6 meses
Free tier inicial: Você pode rodar 100% grátis nos primeiros 3 meses (Supabase Free + Vercel Hobby + Sentry Free).

🎯 Decisão Final
Stack Proposta:
Frontend:  SvelteKit + Tailwind + shadcn-svelte
Backend:   Supabase (PostgreSQL + RLS + Auth + Edge Functions)
Deploy:    Vercel (frontend) + Supabase Cloud (backend)
CI/CD:     GitHub Actions
Monitoring: Sentry + Supabase Logs
Alternativas (se quiser mudar):
Quer mudarParaPor quêSvelteKitNext.jsEcossistema React maiorSupabaseNeon + ClerkMais controle, mas mais complexoVercelCloudflare PagesMais barato, mas menos featuresTailwindUnoCSSAtomic CSS mais rápido

✅ Próximo Passo
Você concorda com essa stack?
Opção A: Sim, vamos com Supabase + SvelteKit + Vercel
→ Eu gero:

Estrutura de pastas completa
package.json com todas as deps
.env.example
README.md com setup
Primeiro migration (schemas)

Opção B: Quero ajustar algo antes
→ Me diz o que quer mudar e eu adapto
Opção C: Prefiro outra stack completamente
→ Me diz qual (ex: Next.js + Prisma + PlanetScale) e eu refaço
Manda o bala! 🚀