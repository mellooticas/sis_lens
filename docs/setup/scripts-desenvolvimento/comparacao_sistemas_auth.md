# 🔄 Comparação: Sistema Desenrola DCL vs. Proposta SIS Lens

## **Sistema Atual (Desenrola DCL) - FUNCIONAL** ✅

### Arquitetura
- **Schemas**: `auth` (Supabase) + `access` (custom) + `public` (business)
- **Multi-tenancy**: Campo `loja_id` em todas as tabelas
- **Autenticação**: Supabase Auth + tabela `usuarios` customizada
- **Sessões**: Controle customizado com `user_sessions`

### Estrutura de Usuários
```sql
-- Tabela principal
usuarios (
  id uuid PRIMARY KEY,
  email text NOT NULL,
  nome text NOT NULL,
  loja_id uuid,                    -- Multi-tenancy
  role text DEFAULT 'operador',    -- Roles simples
  permissoes text[],               -- Array de permissões
  ativo boolean DEFAULT true,
  user_id uuid                     -- Link com auth.users
)

-- Dados detalhados
colaboradores (
  id uuid PRIMARY KEY,
  usuario_id uuid REFERENCES usuarios(id),
  -- campos específicos do colaborador
)

-- Gamificação
usuario_gamificacao (
  id uuid PRIMARY KEY,
  usuario_id uuid REFERENCES usuarios(id),
  loja_id uuid,
  pontos_totais_historico integer,
  level_atual integer,
  -- sistema de gamificação completo
)
```

### Sistema de Permissões
```sql
-- Schema access
user_roles (
  -- roles customizados
)

user_permission_overrides (
  -- override de permissões específicas
)
```

### Políticas RLS
- Isolation por `loja_id`
- Políticas baseadas em `auth.uid()` e `usuarios.loja_id`
- Controle granular por tabela

---

## **Proposta SIS Lens - NOVA** 🆕

### Arquitetura
- **Schemas**: `auth` (Supabase) + `meta_system` (business)
- **Multi-tenancy**: Schema `meta_system.tenants` + campo `tenant_id`
- **Autenticação**: Sistema ENUM mais estruturado
- **Sessões**: Apenas Supabase Auth padrão

### Estrutura de Usuários
```sql
-- Sistema multi-tenant
meta_system.tenants (
  id uuid PRIMARY KEY,
  nome text NOT NULL,
  slug text UNIQUE,
  configuracoes jsonb
)

-- Usuários com ENUM roles
meta_system.users (
  id uuid PRIMARY KEY,
  auth_user_id uuid REFERENCES auth.users(id),
  tenant_id uuid REFERENCES tenants(id),
  email text NOT NULL,
  nome text NOT NULL,
  role user_role_enum NOT NULL,     -- ENUM: superadmin, admin, etc.
  permissoes_customizadas text[],
  ativo boolean DEFAULT true
)

-- ENUM estruturado
CREATE TYPE user_role_enum AS ENUM (
  'superadmin',
  'admin_rede',
  'admin_loja', 
  'gerente_loja',
  'operador_loja',
  'vendedor',
  'optometrista',
  'montador',
  'readonly'
);
```

---

## **Comparação Detalhada**

| Aspecto | Desenrola DCL (Atual) | SIS Lens (Proposta) |
|---------|----------------------|---------------------|
| **Multi-tenancy** | `loja_id` por tabela | Schema `tenants` + `tenant_id` |
| **Roles** | Text simples ('operador', 'admin') | ENUM estruturado (9 roles) |
| **Permissões** | Array text[] + override tables | Array text[] + ENUM base |
| **Schemas** | `auth` + `access` + `public` | `auth` + `meta_system` |
| **Sessões** | Customizado (`user_sessions`) | Supabase padrão |
| **Gamificação** | Sistema completo integrado | Não planejado inicialmente |
| **Complexity** | Alta (3 schemas + overrides) | Média (2 schemas + ENUM) |
| **Maturidade** | ✅ Testado e funcionando | 🆕 Não implementado |

---

## **Usuários Existentes para Manter**

```sql
-- Emails do sistema atual que devem ser preservados:
dcl@oticastatymello.com.br
financeiroesc@hotmail.com
junior@oticastatymello.com.br  
lojas@oticastatymello.com.br
```

---

## **Recomendação**

### **Opção 1: Adaptar Sistema Atual** ⭐ **RECOMENDADO**
- ✅ **Prós**: Sistema testado, funcionando, usuários já cadastrados
- ✅ **Prós**: Menos risco, migração mais simples
- ✅ **Prós**: Sistema de gamificação já integrado
- ⚠️ **Contras**: Menos "limpo" arquiteturalmente

### **Opção 2: Implementar Sistema Novo**
- ✅ **Prós**: Arquitetura mais limpa e moderna
- ✅ **Prós**: ENUM roles mais estruturado
- ⚠️ **Contras**: Precisa migrar usuários existentes
- ⚠️ **Contras**: Risco de bugs em sistema novo
- ⚠️ **Contras**: Mais trabalho de desenvolvimento

---

## **Decisão Pendente**

**Pergunta para o usuário:**
1. Prefere adaptar o sistema atual (menos risco, rápido)?
2. Ou implementar o novo sistema (mais limpo, mais trabalho)?

**Se escolher Opção 1:**
- Adaptar estrutura do Desenrola DCL para SIS Lens
- Migrar/ajustar usuários existentes
- Manter compatibilidade com emails atuais

**Se escolher Opção 2:**
- Implementar nova estrutura
- Criar migração dos usuários existentes
- Mapear roles atuais para novos ENUMs