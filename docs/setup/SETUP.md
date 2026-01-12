# 🚀 Guia Completo de Setup - SIS Lens

Este guia vai te ajudar a configurar o sistema SIS Lens do zero até estar rodando com dados completos.

## 📋 Pré-requisitos

- **Node.js 20+** (recomendado)
- **Git** para clonar o repositório
- **Conta Supabase** (gratuita)
- **PostgreSQL client** (psql) *opcional mas recomendado*

## 🏗️ 1. Configuração Inicial

### **1.1 Clonar o Projeto**

```bash
git clone https://github.com/seu-usuario/best_lens.git
cd best_lens
```

### **1.2 Instalar Dependências**

```bash
npm install
```

### **1.3 Configurar Ambiente**

```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Editar com suas credenciais
nano .env  # ou code .env
```

**Configurar no `.env`:**
```env
PUBLIC_SUPABASE_URL=https://seu-projeto.supabase.co
PUBLIC_SUPABASE_ANON_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOi...
SUPABASE_SERVICE_ROLE_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOi...
```

## 🗄️ 2. Configuração do Banco de Dados

### **2.1 Executar Migrations**

No painel do Supabase:

1. Acesse **SQL Editor**
2. Execute os arquivos de `database/migrations/` na ordem
3. Ou use o Supabase CLI se preferir:

```bash
# Instalar Supabase CLI
npm install -g supabase

# Fazer login
supabase login

# Conectar ao projeto
supabase link --project-ref SEU_PROJECT_ID

# Executar migrations
supabase db reset
```

### **2.2 Popular com Dados Iniciais**

**Opção A: Script Automatizado (Recomendado)**

```bash
cd database/seeds

# Dar permissão de execução
chmod +x executar_populacao.sh

# Configurar DATABASE_URL (se usar psql)
export DATABASE_URL="postgresql://postgres:[SUA-SENHA]@db.[SEU-PROJECT].supabase.co:5432/postgres"

# Executar população
./executar_populacao.sh dev
```

**Opção B: Manual via Dashboard**

1. Acesse **SQL Editor** no Supabase
2. Execute cada arquivo `.sql` da pasta `database/seeds/` na ordem:
   - `001_dados_basicos.sql`
   - `002_catalogo_essilor.sql`
   - `003_catalogo_zeiss.sql`
   - `004_catalogo_hoya.sql`
   - `005_precos_comercial.sql`
   - `006_dados_simulados.sql`

## 🌐 3. Executar a Aplicação

```bash
# Modo desenvolvimento
npm run dev

# Acessar em: http://localhost:5173
```

## 🔐 4. Configurar Autenticação

### **4.1 Usuários Demo Criados**

O script de população cria estes usuários para teste:

| Email | Senha | Perfil | Tenant |
|-------|-------|--------|---------|
| `admin@bestlens.com` | `admin123` | Administrador | SIS Lens Demo |
| `gerente@opticacentral.com` | `gerente123` | Gerente | Ótica Central |
| `vendedor@bestlens.com` | `vendedor123` | Vendedor | SIS Lens Demo |

### **4.2 Login no Sistema**

1. Acesse a aplicação
2. Use um dos usuários demo
3. Explore as funcionalidades!

## 📊 5. Dados Inseridos

Após a população completa, você terá:

### **Catálogo de Produtos**
- **28 lentes** (Essilor, Zeiss, Hoya)
- **3 marcas** principais
- **5 laboratórios** parceiros
- **60+ tabelas de preço**

### **Dados Comerciais**
- **Condições comerciais** por laboratório
- **3 campanhas ativas**
- **Contratos** e descontos
- **Histórico de preços**

### **Analytics e Histórico**
- **6 meses** de decisões simuladas
- **Métricas de performance** diárias
- **Feedback** de usuários
- **Dashboards** prontos

## 🔧 6. Personalização

### **6.1 Configurar Sua Ótica**

1. **Altere o tenant demo:**
   ```sql
   UPDATE meta_system.tenants 
   SET nome = 'Sua Ótica', 
       razao_social = 'Sua Ótica Ltda'
   WHERE slug = 'bestlens-demo';
   ```

2. **Adicione seus laboratórios:**
   - Acesse painel de Fornecedores
   - Cadastre seus parceiros reais

3. **Configure preços reais:**
   - Importe suas tabelas de preço
   - Ajuste condições comerciais

### **6.2 Configurar Vouchers**

1. **Ative o sistema de vouchers** nas configurações
2. **Configure limites mensais** por usuário
3. **Defina regras de desconto** específicas

## 🚀 7. Deploy em Produção

### **7.1 Netlify (Frontend)**

```bash
# Build local
npm run build

# Deploy via Git
# Conecte seu repositório ao Netlify
# Configure as variáveis de ambiente
```

### **7.2 Supabase (Backend)**

O Supabase já está configurado para produção. Apenas:

1. **Upgrade** para plano pago se necessário
2. **Configure domínio** customizado
3. **Ative backups** automáticos

## 🛠️ 8. Troubleshooting

### **Problema: Erro de conexão com Supabase**
- ✅ Verifique `.env` com credenciais corretas
- ✅ Confirme se PROJECT_ID está certo
- ✅ Teste conexão no dashboard

### **Problema: Scripts de população falharam**
- ✅ Execute migrations primeiro
- ✅ Verifique logs em `database/seeds/logs/`
- ✅ Execute scripts um por vez manualmente

### **Problema: Build falha no Netlify**
- ✅ Configure Node.js 20 no `netlify.toml`
- ✅ Adicione variáveis de ambiente
- ✅ Verifique se deps estão instaladas

### **Problema: Usuários não conseguem fazer login**
- ✅ Verifique RLS policies no Supabase
- ✅ Confirme usuários criados na auth
- ✅ Teste autenticação no dashboard

## 📚 9. Próximos Passos

Com o sistema funcionando, você pode:

1. **🎯 Testar decisões** de lentes
2. **📊 Explorar analytics** e relatórios
3. **👥 Criar usuários** reais
4. **💰 Configurar vouchers** e descontos
5. **🔄 Integrar** com sistemas existentes

## 🆘 Suporte

- **📖 Documentação:** `docs/` no repositório
- **🐛 Issues:** GitHub Issues
- **💬 Discussões:** GitHub Discussions
- **📧 Email:** suporte@bestlens.com

---

**🎉 Parabéns! Seu sistema SIS Lens está pronto para usar!**

> Este guia cobre 95% dos casos de uso. Para configurações avançadas, consulte a documentação técnica em `docs/`.

**Última atualização:** 04/10/2025 | **Versão:** 2.0