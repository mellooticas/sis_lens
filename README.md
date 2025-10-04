# 🔍 BestLens - Sistema Decisor de Lentes Híbrido# 🔍 BestLens - Sistema Decisor de Lentes Híbrido# 🌟 BestLens - Sistema Decisor de Lentes



> **Sistema inteligente para tomada de decisões na compra de lentes oftálmicas com sistema integrado de vouchers e descontos.**



## 🎯 **Sobre o Projeto**> **Sistema inteligente para tomada de decisões na compra de lentes oftálmicas com sistema integrado de vouchers e descontos.**Sistema inteligente para comparar e decidir a melhor opção de lentes oftálmicas entre laboratórios parceiros.



O BestLens é um sistema híbrido que combina:

- **🔍 Decisor de Lentes**: Análise inteligente de fornecedores, preços e prazos

- **🎫 Sistema de Vouchers**: Gestão de descontos e promoções para lojas## 🎯 **Sobre o Projeto**## 🚀 Tecnologias

- **📊 Analytics**: Dashboard com métricas de economia e performance



## ⚡ **Quick Start**

O BestLens é um sistema híbrido que combina:- **Frontend:** SvelteKit + TypeScript + TailwindCSS

```bash

# 1. Instalar dependências- **🔍 Decisor de Lentes**: Análise inteligente de fornecedores, preços e prazos- **Backend:** Supabase (PostgreSQL + Auth + APIs)

npm install

- **🎫 Sistema de Vouchers**: Gestão de descontos e promoções para lojas- **Autenticação:** 4 níveis de usuários com controles específicos

# 2. Configurar variáveis de ambiente

cp .env.example .env- **📊 Analytics**: Dashboard com métricas de economia e performance- **Vouchers:** Sistema avançado de descontos com limites mensais

# Edite .env com suas credenciais do Supabase



# 3. Executar em desenvolvimento

npm run dev## ⚡ **Quick Start**## 📋 Funcionalidades



# 4. Acessar aplicação

# Frontend: http://localhost:5173

# Debug: http://localhost:5173/debug```bash### Sistema de Autenticação

```

# 1. Instalar dependências- **DCL Decisor:** Acesso total, geração de vouchers até 20%

## 🏗️ **Arquitetura**

npm install- **Financeiro Supervisor:** Controle financeiro, vouchers até 25%

```

🏢 Frontend (SvelteKit)- **Admin Junior:** Administração, vouchers até 15%

├─ 🔍 /buscar - Busca de lentes

├─ 📊 /ranking - Ranking de fornecedores  # 2. Configurar variáveis de ambiente- **Loja Consulta:** Consulta apenas, sem geração de vouchers

├─ 📋 /debug - Auditoria completa

└─ 🏠 / - Dashboard principalcp .env.example .env



🗄️ Backend (Supabase)# Edite .env com suas credenciais do Supabase### Sistema de Vouchers

├─ 📊 Schemas especializados (lens_catalog, suppliers, orders...)

├─ 🔗 Views públicas (vw_lentes_catalogo, vw_fornecedores...)- Geração controlada com limites mensais (80 vouchers/mês)

├─ ⚙️ RPCs (rpc_buscar_lente, rpc_rank_opcoes...)

└─ 🎫 Sistema de vouchers (usuarios, lojas, clientes, vouchers)# 3. Executar em desenvolvimento- Limite de valor máximo: R$ 16.000/mês

```

npm run dev- Controle por percentual conforme nível de usuário

## 🚀 **Funcionalidades**

- Auditoria completa de uso e economia gerada

### 🔍 **Decisor de Lentes**

- ✅ Catálogo completo de lentes (4 lentes ativas)# 4. Acessar aplicação

- ✅ Ranking inteligente de fornecedores (3 laboratórios)

- ✅ Critérios: NORMAL, URGÊNCIA, ESPECIAL# Frontend: http://localhost:5173### APIs Públicas

- ✅ Análise de preços, prazos e qualidade

# Debug: http://localhost:5173/debug- `api_listar_vouchers` - Lista vouchers disponíveis

### 🎫 **Sistema de Vouchers**

- ✅ Gestão de clientes e lojas```- `api_gerar_voucher_controlado` - Gera novos vouchers

- ✅ Vouchers com desconto fixo ou percentual

- ✅ Dashboard de economia gerada- `api_dashboard_executivo` - Dashboard de controle

- ✅ Controle de validade e uso

## 🏗️ **Arquitetura**- `api_login_usuario` - Sistema de autenticação

### 📊 **Analytics**

- ✅ Métricas de economia por fornecedor

- ✅ Histórico de decisões

- ✅ Relatórios de performance```## 🛠️ Configuração

- ✅ Dashboard executivo

🏢 Frontend (SvelteKit)

## 🛠️ **Stack Tecnológica**

├─ 🔍 /buscar - Busca de lentes### Variáveis de Ambiente (.env)

- **Frontend**: SvelteKit + TypeScript + Tailwind CSS

- **Backend**: Supabase (PostgreSQL)├─ 📊 /ranking - Ranking de fornecedores  ```bash

- **Autenticação**: Supabase Auth

- **Deployment**: Vercel/Netlify Ready├─ 📋 /debug - Auditoria completaVITE_SUPABASE_URL=https://ahcikwsoxhmqqteertkx.supabase.co



## 📁 **Estrutura do Projeto**└─ 🏠 / - Dashboard principalVITE_SUPABASE_ANON_KEY=your_anon_key



```VITE_APP_NAME=BestLens

best_lens/

├─ 📱 src/                    # Código fonte SvelteKit🗄️ Backend (Supabase)VITE_APP_VERSION=1.0.0

├─ 📚 docs/                   # Documentação e scripts

│  ├─ 🗄️ database/           # Migrações e seeds Supabase├─ 📊 Schemas especializados (lens_catalog, suppliers, orders...)VITE_APP_ENVIRONMENT=production

│  ├─ migrations-completas/   # Scripts SQL completos

│  ├─ testes-auditoria/      # Scripts de teste├─ 🔗 Views públicas (vw_lentes_catalogo, vw_fornecedores...)```

│  └─ scripts-desenvolvimento/ # Documentação técnica

├─ 🌐 static/                 # Assets estáticos├─ ⚙️ RPCs (rpc_buscar_lente, rpc_rank_opcoes...)

└─ ⚙️ supabase/               # Configuração Supabase

```└─ 🎫 Sistema de vouchers (usuarios, lojas, clientes, vouchers)### Instalação



## 🧪 **Testes e Auditoria**``````bash



```bashnpm install

# Auditoria completa do sistema

node docs/testes-auditoria/auditoria_completa.js## 🚀 **Funcionalidades**npm run dev



# Teste de views específicas  ```

node docs/testes-auditoria/teste_completo.js

### 🔍 **Decisor de Lentes**

# Verificar conexão do backend

# Acessar: http://localhost:5173/debug- ✅ Catálogo completo de lentes (4 lentes ativas)## 📁 Estrutura do Projeto

```

- ✅ Ranking inteligente de fornecedores (3 laboratórios)

## 📊 **Status do Sistema**

- ✅ Critérios: NORMAL, URGÊNCIA, ESPECIAL```

- ✅ **100% das estruturas** funcionando

- ✅ **Sistema híbrido** operacional  - ✅ Análise de preços, prazos e qualidadesrc/

- ✅ **Backend conectado** às views

- ✅ **4 lentes** no catálogo├── lib/

- ✅ **3 fornecedores** ativos

- ✅ **Sistema de vouchers** com dados### 🎫 **Sistema de Vouchers**│   ├── supabase.ts          # Cliente Supabase



## 📚 **Documentação Completa**- ✅ Gestão de clientes e lojas│   ├── types/               # Tipos TypeScript



Para documentação detalhada, consulte:- ✅ Vouchers com desconto fixo ou percentual│   ├── stores/              # Stores Svelte

- **📋 [Documentação Completa](docs/README.md)**

- **🏗️ [Database e Migrações](docs/database/)**- ✅ Dashboard de economia gerada│   └── components/          # Componentes reutilizáveis

- **🔧 [Setup e Configuração](docs/scripts-desenvolvimento/)**

- ✅ Controle de validade e uso├── routes/                  # Páginas SvelteKit

## 🤝 **Contribuição**

└── app.html                 # Template principal

Este é um sistema híbrido completo e funcional. Para modificações:

### 📊 **Analytics**

1. Consulte a documentação em `/docs`

2. Execute testes com os scripts de auditoria- ✅ Métricas de economia por fornecedorsupabase/

3. Use o sistema de debug para validar mudanças

- ✅ Histórico de decisões└── migrations/

## 📄 **Licença**

- ✅ Relatórios de performance    └── production/          # Scripts SQL de produção

Projeto privado - Sistema BestLens © 2025

- ✅ Dashboard executivo        ├── 01_auth_system.sql

---

        ├── 02_voucher_controls.sql

**🎯 Sistema 100% operacional e pronto para produção!**
## 🛠️ **Stack Tecnológica**        ├── 03_public_api.sql

        └── 04_auth_config.sql

- **Frontend**: SvelteKit + TypeScript + Tailwind CSS```

- **Backend**: Supabase (PostgreSQL)

- **Autenticação**: Supabase Auth## � Estrutura do Banco

- **Deployment**: Vercel/Netlify Ready

### Tabelas Principais

## 📁 **Estrutura do Projeto**- `usuarios` - Gestão de usuários e permissões

- `vouchers_desconto` - Sistema de vouchers

```- `consultas_lens_log` - Log de consultas e economia

best_lens/- `controle_vouchers_mensal` - Controles mensais

├─ 📱 src/                    # Código fonte SvelteKit- `ranking_vouchers` - Ranking de economia

├─ 🗄️ database/              # Migrações Supabase

├─ 📚 docs/                   # Documentação e scripts### Views Públicas

│  ├─ migrations-completas/   # Scripts SQL completos- `v_vouchers_disponiveis` - Vouchers disponíveis por usuário

│  ├─ testes-auditoria/      # Scripts de teste  - `v_dashboard_vouchers` - Dashboard de controle

│  └─ scripts-desenvolvimento/ # Documentação- `v_ranking_economia` - Ranking de economia gerada

├─ 🌐 static/                 # Assets estáticos- `v_user_profile` - Perfil do usuário logado

└─ ⚙️ supabase/               # Configuração Supabase

```## 📊 Monitoramento



## 🧪 **Testes e Auditoria**O sistema inclui:

- Auditoria completa de ações

```bash- Dashboard executivo com métricas

# Auditoria completa do sistema- Controles automáticos de limite

node docs/testes-auditoria/auditoria_completa.js- Sistema de alertas por percentual usado



# Teste de views específicas  ## � Deploy

node docs/testes-auditoria/teste_completo.js

Sistema está configurado para Supabase Cloud:

# Verificar conexão do backend- Projeto: `ahcikwsoxhmqqteertkx`

# Acessar: http://localhost:5173/debug- Região: US East 1

```- PostgreSQL 15+ com RLS ativo



## 📊 **Status do Sistema**## � Suporte



- ✅ **100% das estruturas** funcionandoPara suporte técnico, entre em contato com a equipe DCL - Desenrola Comunicação & Lentes.

- ✅ **Sistema híbrido** operacional  

- ✅ **Backend conectado** às views---

- ✅ **4 lentes** no catálogo

- ✅ **3 fornecedores** ativos**Versão:** 1.0.0  

- ✅ **Sistema de vouchers** com dados**Status:** Produção  

**Última atualização:** Outubro 2025

## 📚 **Documentação Completa**npm run dev              # Inicia dev server

npm run lint             # Verifica código

Para documentação detalhada, consulte:npm run format           # Formata código

- **📋 [Documentação Completa](docs/README.md)**

- **🏗️ [Arquitetura do Sistema](docs/scripts-desenvolvimento/README_Sistema_Completo.md)**# Banco de dados

- **🔧 [Setup e Configuração](docs/scripts-desenvolvimento/SETUP_STATUS.md)**npm run db:start         # Inicia Supabase local

npm run db:stop          # Para Supabase

## 🤝 **Contribuição**npm run db:reset         # Reset DB + migrations

npm run db:push          # Aplica migrations em produção

Este é um sistema híbrido completo e funcional. Para modificações:```



1. Consulte a documentação em `/docs`## 🤝 Contribuindo

2. Execute testes com os scripts de auditoria

3. Use o sistema de debug para validar mudanças1. Criar branch: `git checkout -b feat/nova-feature`

2. Commit: `git commit -m "feat: adicionar nova feature"`

## 📄 **Licença**3. Push: `git push origin feat/nova-feature`

4. Abrir Pull Request

Projeto privado - Sistema BestLens © 2025

## 📄 Licença

---

Proprietário - Todos os direitos reservados
**🎯 Sistema 100% operacional e pronto para produção!**