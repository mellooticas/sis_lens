# 🌟 SIS Lens - Sistema Decisor de Lentes

Sistema inteligente para comparar e decidir a melhor opção de lentes oftálmicas entre laboratórios parceiros.

## 🚀 Tecnologias

- **Frontend:** SvelteKit + TypeScript + TailwindCSS
- **Backend:** Supabase (PostgreSQL + Auth + APIs)
- **Autenticação:** 4 níveis de usuários com controles específicos
- **Vouchers:** Sistema avançado de descontos com limites mensais

## 📋 Funcionalidades

### Sistema de Autenticação
- **DCL Decisor:** Acesso total, geração de vouchers até 20%
- **Financeiro Supervisor:** Controle financeiro, vouchers até 25%
- **Admin Junior:** Administração, vouchers até 15%
- **Loja Consulta:** Consulta apenas, sem geração de vouchers

### Sistema de Vouchers
- Geração controlada com limites mensais (80 vouchers/mês)
- Limite de valor máximo: R$ 16.000/mês
- Controle por percentual conforme nível de usuário
- Auditoria completa de uso e economia gerada

### APIs Públicas
- `api_listar_vouchers` - Lista vouchers disponíveis
- `api_gerar_voucher_controlado` - Gera novos vouchers
- `api_dashboard_executivo` - Dashboard de controle
- `api_login_usuario` - Sistema de autenticação

## 🛠️ Configuração

### Variáveis de Ambiente (.env)
```bash
VITE_SUPABASE_URL=https://ahcikwsoxhmqqteertkx.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key
VITE_APP_NAME=SIS Lens
VITE_APP_VERSION=1.0.0
VITE_APP_ENVIRONMENT=production
```

### Instalação
```bash
npm install
npm run dev
```

## 📁 Estrutura do Projeto

```
src/
├── lib/
│   ├── supabase.ts          # Cliente Supabase
│   ├── types/               # Tipos TypeScript
│   ├── stores/              # Stores Svelte
│   └── components/          # Componentes reutilizáveis
├── routes/                  # Páginas SvelteKit
└── app.html                 # Template principal

supabase/
└── migrations/
    └── production/          # Scripts SQL de produção
        ├── 01_auth_system.sql
        ├── 02_voucher_controls.sql
        ├── 03_public_api.sql
        └── 04_auth_config.sql
```

## � Estrutura do Banco

### Tabelas Principais
- `usuarios` - Gestão de usuários e permissões
- `vouchers_desconto` - Sistema de vouchers
- `consultas_lens_log` - Log de consultas e economia
- `controle_vouchers_mensal` - Controles mensais
- `ranking_vouchers` - Ranking de economia

### Views Públicas
- `v_vouchers_disponiveis` - Vouchers disponíveis por usuário
- `v_dashboard_vouchers` - Dashboard de controle
- `v_ranking_economia` - Ranking de economia gerada
- `v_user_profile` - Perfil do usuário logado

## 📊 Monitoramento

O sistema inclui:
- Auditoria completa de ações
- Dashboard executivo com métricas
- Controles automáticos de limite
- Sistema de alertas por percentual usado

## � Deploy

Sistema está configurado para Supabase Cloud:
- Projeto: `ahcikwsoxhmqqteertkx`
- Região: US East 1
- PostgreSQL 15+ com RLS ativo

## � Suporte

Para suporte técnico, entre em contato com a equipe DCL - Desenrola Comunicação & Lentes.

---

**Versão:** 1.0.0  
**Status:** Produção  
**Última atualização:** Outubro 2025
npm run dev              # Inicia dev server
npm run lint             # Verifica código
npm run format           # Formata código

# Banco de dados
npm run db:start         # Inicia Supabase local
npm run db:stop          # Para Supabase
npm run db:reset         # Reset DB + migrations
npm run db:push          # Aplica migrations em produção
```

## 🤝 Contribuindo

1. Criar branch: `git checkout -b feat/nova-feature`
2. Commit: `git commit -m "feat: adicionar nova feature"`
3. Push: `git push origin feat/nova-feature`
4. Abrir Pull Request

## 📄 Licença

Proprietário - Todos os direitos reservados