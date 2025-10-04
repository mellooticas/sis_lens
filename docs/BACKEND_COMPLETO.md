# 📋 Documentação Completa do Backend - BestLens

## 🎯 Visão Geral

Este documento apresenta a estrutura completa do backend do **BestLens** - Sistema Decisor de Lentes, implementado em PostgreSQL com arquitetura multi-tenant e baseado nos padrões descritos no Blueprint.

### 🏗️ Arquitetura Geral

- **Database**: PostgreSQL 15+ com extensões UUID, RLS
- **Arquitetura**: Multi-tenant com isolamento por Row Level Security (RLS)
- **Schemas**: 8 schemas principais + 1 schema de API pública
- **Segurança**: Row Level Security (RLS) + Políticas de acesso baseadas em tenant
- **Performance**: Índices otimizados, triggers automáticos, cache para relatórios

---

## 📁 Estrutura de Schemas

### 1. **meta_system** - Sistema Meta
Gerenciamento de tenants, feature flags e parâmetros do sistema.

### 2. **lens_catalog** - Catálogo de Lentes
Catálogo canônico de marcas e lentes com especificações técnicas.

### 3. **suppliers** - Fornecedores
Laboratórios parceiros e mapeamento de produtos disponíveis.

### 4. **commercial** - Comercial
Preços, descontos e regras comerciais por laboratório.

### 5. **logistics** - Logística
Prazos de entrega, custos de frete e métricas de performance.

### 6. **scoring** - Scoring/Qualificação
Sistema de pontuação e ranking de laboratórios.

### 7. **orders** - Pedidos/Decisões
Decisões de lentes, alternativas e histórico de status.

### 8. **analytics** - Analytics
Relatórios, KPIs, métricas e sistema de alertas.

### 9. **api** - API Pública
Funções e views públicas para integração com frontend.

---

## 🗃️ Tabelas Principais por Schema

### 📊 Meta System
- `tenants` - Organizações/clientes do sistema
- `feature_flags` - Controle de funcionalidades por tenant
- `parametros_sistema` - Configurações personalizáveis

### 👓 Lens Catalog
- `marcas` - Marcas de lentes (Essilor, Zeiss, etc.)
- `lentes` - Catálogo canônico com especificações técnicas

### 🏭 Suppliers
- `laboratorios` - Laboratórios parceiros
- `produtos_laboratorio` - Mapeamento lente → laboratório

### 💰 Commercial
- `precos_produtos` - Preços por laboratório/lente
- `descontos` - Regras de desconto
- `regras_comerciais` - Lógica comercial avançada

### 🚚 Logistics
- `tabela_prazos` - Prazos e custos de frete
- `zonas_entrega` - Definição de regiões
- `historico_entregas` - Métricas reais de entrega

### ⭐ Scoring
- `criterios_scoring` - Critérios de avaliação
- `avaliacoes_laboratorios` - Avaliações por critério
- `scores_laboratorios` - Scores consolidados
- `historico_scores` - Auditoria de mudanças

### 📋 Orders
- `decisoes_lentes` - Decisões principais
- `alternativas_cotacao` - Opções geradas
- `historico_status` - Rastreamento de mudanças
- `criterios_decisao` - Configuração do algoritmo

### 📈 Analytics
- `relatorios_configuracao` - Definição de relatórios
- `execucoes_relatorios` - Histórico e cache
- `metricas_kpi` - Definição de KPIs
- `valores_kpi` - Valores históricos
- `alertas_analytics` - Sistema de alertas

---

## 🔧 Funcionalidades Técnicas

### 🛡️ Segurança (RLS)
- **Isolamento total por tenant** - Cada organização só vê seus dados
- **Políticas automáticas** - RLS aplicado em todas as tabelas
- **Roles diferenciados** - USER, MANAGER, ADMIN, OWNER
- **Service role bypass** - Para operações internas do sistema

### ⚡ Performance
- **Índices estratégicos** - Otimizados para consultas frequentes
- **Triggers automáticos** - Cálculos em tempo real
- **Cache inteligente** - Para relatórios e consultas pesadas
- **Queries otimizadas** - Com CTEs e agregações eficientes

### 🔄 Automação
- **Triggers de auditoria** - updated_at automático
- **Cálculos automáticos** - Scores, rankings, métricas
- **Geração de códigos** - Códigos únicos de decisão
- **Alertas automáticos** - Baseados em thresholds de KPIs

---

## 🚀 APIs e Funções Públicas

### 📋 Catálogo de Lentes
```sql
-- Buscar lentes com filtros
SELECT * FROM api.buscar_lentes(
    p_marca => 'Essilor',
    p_tipo_lente => 'PROGRESSIVA',
    p_material => 'POLICARBONATO'
);

-- Detalhes completos de uma lente
SELECT * FROM api.obter_lente('uuid-da-lente');
```

### 🏭 Laboratórios
```sql
-- Listar laboratórios com scores
SELECT * FROM api.listar_laboratorios(p_regiao => 'SUDESTE');

-- Detalhes com métricas de performance
SELECT * FROM api.obter_laboratorio('uuid-do-laboratorio');
```

### 🎯 Motor de Decisão
```sql
-- Criar decisão automática
SELECT * FROM api.criar_decisao_lente(
    p_cliente_nome => 'João Silva',
    p_receita => '{
        "esferico_od": -2.5,
        "cilindrico_od": -1.0,
        "adicao": 1.5
    }'::jsonb,
    p_especificacoes => '{
        "uso_principal": "COMPUTADOR"
    }'::jsonb
);

-- Obter decisão com alternativas
SELECT * FROM api.obter_decisao('uuid-da-decisao');
```

### 📊 Analytics
```sql
-- Dashboard principal
SELECT * FROM api.obter_dashboard_kpis();

-- Estatísticas gerais
SELECT * FROM api.vw_estatisticas_gerais;
```

---

## 📈 Sistema de Scoring

### 🎯 Critérios de Avaliação
- **Qualidade dos Produtos** (peso 2.0)
- **Pontualidade na Entrega** (peso 1.8)
- **Velocidade de Entrega** (peso 1.5)
- **Competitividade de Preços** (peso 1.7)
- **Atendimento ao Cliente** (peso 1.3)
- **Variedade de Produtos** (peso 1.2)
- **Estabilidade Financeira** (peso 1.4)
- **Inovação Tecnológica** (peso 1.1)

### 🏆 Níveis de Qualificação
- **GOLD** (9.0+) - 🥇 Excelência
- **SILVER** (7.5+) - 🥈 Alta qualidade
- **BRONZE** (6.0+) - 🥉 Qualificado
- **QUALIFICADO** (4.0+) - ✅ Básico
- **NÃO_QUALIFICADO** (<4.0) - ⚪ Não recomendado

---

## 🧮 Motor de Decisão

### 🔍 Algoritmo Principal
1. **Filtro de Compatibilidade** - Remove lentes incompatíveis com a receita
2. **Cálculo de Adequação** - Avalia adequação técnica (0-100%)
3. **Normalização de Scores** - Converte métricas para escala 0-10
4. **Ponderação por Prioridades** - Aplica pesos definidos pelo usuário
5. **Ranking Final** - Ordena por score ponderado

### ⚖️ Fatores de Decisão
- **Adequação à Receita** (sempre peso alto)
- **Score do Laboratório** (conforme prioridade)
- **Competitividade de Preço** (conforme prioridade)
- **Prazo de Entrega** (conforme prioridade)

---

## 📊 Sistema de Analytics

### 📈 KPIs Principais
- **Total de Decisões** - Volume de processamento
- **Taxa de Aprovação** - % de decisões aprovadas
- **Prazo Médio de Entrega** - Performance logística
- **Score Médio Laboratórios** - Qualidade da rede
- **Laboratórios Ativos** - Tamanho da rede

### 🚨 Sistema de Alertas
- **KPI Crítico** - Valores abaixo do limite crítico
- **KPI Atenção** - Valores em zona de atenção
- **Erro de Relatório** - Falhas na execução
- **Anomalias** - Detecção automática de padrões

---

## 🗂️ Estrutura de Arquivos

```
supabase/migrations/
├── 20251002_001_create_schemas.sql      # Criação dos schemas
├── 20251002_002_meta_system.sql        # Sistema meta
├── 20251002_003_lens_catalog.sql       # Catálogo de lentes
├── 20251002_004_suppliers.sql          # Laboratórios
├── 20251002_005_commercial.sql         # Comercial
├── 20251002_006_logistics.sql          # Logística
├── 20251002_007_scoring.sql            # Scoring
├── 20251002_008_orders.sql             # Decisões
├── 20251002_009_analytics.sql          # Analytics
├── 20251002_010_rls_policies.sql       # Segurança RLS
└── 20251002_011_api_functions.sql      # API pública
```

---

## 🔐 Configuração de Segurança

### 🎫 Autenticação
- **JWT Tokens** - Autenticação via Supabase Auth
- **Roles Hierárquicos** - USER → MANAGER → ADMIN → OWNER
- **Tenant Isolation** - Isolamento automático por organização

### 🛡️ Row Level Security (RLS)
- **Habilitado em todas as tabelas**
- **Políticas automáticas por tenant**
- **Bypass para service_role**
- **Funções de validação de acesso**

### 🔒 Privilégios Mínimos
- **READ** - Usuários autenticados
- **WRITE** - Apenas tabelas específicas (orders, scoring)
- **ADMIN** - Configurações e relatórios
- **EXECUTE** - Funções da API pública

---

## 🧪 Dados de Exemplo

Cada migration inclui dados de exemplo para demonstração:

- **3 Laboratórios** com diferentes perfis de qualidade/preço
- **15+ Lentes** cobrindo principais tipos e materiais
- **Preços e prazos** realistas por região
- **Avaliações e scores** calculados automaticamente
- **1 Decisão exemplo** com alternativas geradas

---

## 🚀 Como Usar

### 1. **Executar Migrations**
```bash
supabase db reset
# ou aplicar individualmente:
supabase db push
```

### 2. **Testar APIs**
```sql
-- Dashboard
SELECT * FROM api.obter_dashboard_kpis();

-- Buscar lentes progressivas
SELECT * FROM api.buscar_lentes(p_tipo_lente => 'PROGRESSIVA');

-- Criar decisão
SELECT * FROM api.criar_decisao_lente(
    'João Silva',
    NULL,
    '{"esferico_od": -2.5, "adicao": 1.5}'::jsonb
);
```

### 3. **Verificar Segurança**
```sql
-- Testar isolamento de tenants
SELECT * FROM meta_system.test_tenant_isolation();

-- Verificar RLS
SELECT count(*) FROM orders.decisoes_lentes; -- Só vê do tenant atual
```

---

## 📚 Próximos Passos

### 🔧 Para Desenvolvimento
1. **Integrar com Frontend** - Usar funções da API
2. **Implementar Auth** - Configurar JWT e roles
3. **Customizar Algoritmo** - Ajustar pesos e critérios
4. **Adicionar Dados** - Importar catálogos reais

### 🚀 Para Produção
1. **Configurar Backup** - Estratégia de backup/restore
2. **Monitoramento** - Logs, métricas, alertas
3. **Performance** - Tuning de queries pesadas
4. **Migração de Dados** - Import de sistemas legados

---

## 🤝 Suporte

Este backend foi desenvolvido seguindo as especificações do **Blueprint Completo — Sistema Decisor de Lentes** e está pronto para integração com o frontend SvelteKit.

### 📖 Documentação Técnica
- Todas as funções possuem comentários explicativos
- Views incluem documentação de uso
- Triggers documentados com propósito
- Políticas RLS explicadas

### 🔍 Debug e Logs
- Funções com tratamento de erro
- Logs automáticos de mudanças importantes
- Sistema de auditoria completo
- Métricas de performance integradas

---

*Documentação gerada em 02/10/2024 - BestLens Backend v1.0*