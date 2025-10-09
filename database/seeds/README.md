# 📊 Scripts de População do Banco de Dados - BestLens

## 🎯 Visão Geral

Esta pasta contém todos os scripts SQL necessários para popular o banco de dados do sistema BestLens com dados iniciais, catálogos de produtos e informações comerciais.

## 📁 Estrutura dos Scripts

```
database/seeds/
├── README.md                    # Este arquivo
├── executar_populacao.sh        # Script de execução automatizada
├── 001_dados_basicos.sql        # ✅ Tenants, marcas, laboratórios básicos
├── 002_catalogo_essilor.sql     # ✅ Catálogo completo Essilor
├── 003_catalogo_zeiss.sql       # 🚧 A criar - Catálogo Zeiss
├── 004_catalogo_hoya.sql        # 🚧 A criar - Catálogo Hoya
├── 005_precos_comercial.sql     # 🚧 A criar - Preços e condições
├── 006_dados_simulados.sql      # 🚧 A criar - Histórico simulado
└── logs/                        # Logs de execução
```

## 🚀 Como Executar

### **Opção 1: Execução Automatizada (Recomendada)**

```bash
# Dar permissão de execução
chmod +x executar_populacao.sh

# Executar todos os scripts
./executar_populacao.sh dev
```

### **Opção 2: Execução Manual por Script**

```bash
# Via Supabase CLI (local)
supabase db reset
psql "$DATABASE_URL" -f 001_dados_basicos.sql
psql "$DATABASE_URL" -f 002_catalogo_essilor.sql

# Via cliente SQL direto
# Cole o conteúdo dos scripts no seu cliente SQL favorito
```

### **Opção 3: Através do Dashboard Supabase**

1. Acesse o **SQL Editor** no dashboard
2. Cole o conteúdo de cada script na ordem
3. Execute um por vez

## 📋 Detalhes dos Scripts

### **001_dados_basicos.sql** ✅
**Descrição:** Dados fundamentais para o sistema funcionar  
**Conteúdo:**
- 2 tenants (BestLens Demo, Ótica Central)
- 8 marcas principais (Essilor, Zeiss, Hoya, etc.)
- 5 laboratórios brasileiros
- 6 representantes comerciais
- 5 critérios de scoring
- 3 usuários demo

**Registros criados:** ~30

### **002_catalogo_essilor.sql** ✅
**Descrição:** Catálogo técnico completo da Essilor  
**Conteúdo:**
- Linha Varilux (X Series, Comfort, Liberty)
- Tratamentos Crizal (Sapphire UV)
- Lentes Transitions (Signature VIII)
- Preços oficiais 2025
- Controle de estoque
- Scores de qualidade

**Registros criados:** ~35

### **003_catalogo_zeiss.sql** 🚧
**Planejado:**
- SmartLife Individual
- Individual Progressive
- DuraVision (Platinum, BlueProtect)
- PhotoFusion (Clear, Brown, Grey)

### **004_catalogo_hoya.sql** 🚧
**Planejado:**
- iD MyStyle (Lifestyle, WorkStyle)
- Hi-Vision (LongLife, BlueControl)
- Sensity (Dark, Light)

### **005_precos_comercial.sql** 🚧
**Planejado:**
- Tabelas de preço de todos os laboratórios
- Condições comerciais
- Descontos e promoções
- Contratos e prazos

### **006_dados_simulados.sql** 🚧
**Planejado:**
- Histórico de 6 meses de decisões
- Métricas de performance
- Dados de analytics
- Movimentação de estoque

## 🔍 Verificação dos Dados

Após executar os scripts, você pode verificar se tudo foi inserido corretamente:

```sql
-- Contar registros por tabela
SELECT 
    schemaname,
    tablename,
    n_tup_ins as registros_inseridos
FROM pg_stat_user_tables 
WHERE schemaname IN ('meta_system', 'lens_catalog', 'suppliers', 'commercial', 'logistics', 'scoring', 'orders')
ORDER BY schemaname, tablename;

-- Verificar tenant demo
SELECT 
    t.nome as tenant,
    COUNT(DISTINCT m.id) as marcas,
    COUNT(DISTINCT l.id) as lentes,
    COUNT(DISTINCT s.id) as laboratorios
FROM meta_system.tenants t
LEFT JOIN lens_catalog.marcas m ON t.id = m.tenant_id
LEFT JOIN lens_catalog.lentes l ON t.id = l.tenant_id  
LEFT JOIN suppliers.laboratorios s ON t.id = s.tenant_id
WHERE t.slug = 'bestlens-demo'
GROUP BY t.id, t.nome;
```

## ⚙️ Configuração de Ambiente

### **Variáveis Necessárias**

```bash
# Para execução via psql
export DATABASE_URL="postgresql://user:pass@host:port/database"

# Para Supabase CLI
export SUPABASE_PROJECT_ID="seu-project-id"
export SUPABASE_DB_PASSWORD="sua-senha"
```

### **Dependências**

- PostgreSQL client (`psql`) ou
- Supabase CLI (`supabase`) ou  
- Acesso ao Dashboard Supabase

## 📊 Dados Estatísticos

### **Após Scripts Básicos (001-002)**
- **Total de registros:** ~65
- **Marcas:** 8 principais
- **Lentes:** 6 modelos Essilor
- **Laboratórios:** 5 principais
- **Preços:** Tabela 2025 completa

### **Meta Final (001-006)**
- **Total estimado:** ~2.000 registros
- **Lentes:** 150+ modelos
- **Histórico:** 6 meses simulados
- **Analytics:** Métricas completas

## 🚨 Troubleshooting

### **Erro: "relation does not exist"**
- ✅ Execute primeiro todas as migrations
- ✅ Verifique se os schemas foram criados

### **Erro: "duplicate key value"**
- ✅ Reset do banco antes de executar
- ✅ UUIDs fixos podem conflitar

### **Erro: "permission denied"**
- ✅ Verifique permissões do usuário
- ✅ RLS policies podem estar ativas

### **Scripts demoram muito**
- ✅ Execute em ambiente local primeiro
- ✅ Use transações menores se necessário

## 🎯 Próximos Passos

1. **✅ Executar scripts básicos (001-002)**
2. **🚧 Criar script Zeiss (003)**
3. **🚧 Criar script Hoya (004)**
4. **🚧 Adicionar dados comerciais (005)**
5. **🚧 Simular histórico (006)**
6. **🚀 Deploy em produção**

## 📞 Suporte

Em caso de problemas com os scripts:

1. Verifique os logs em `logs/`
2. Execute os scripts um por vez
3. Consulte a documentação das migrations
4. Verifique as permissões do banco

---

**Última atualização:** 04/10/2025  
**Versão:** 1.0  
**Status:** 🚧 Em desenvolvimento