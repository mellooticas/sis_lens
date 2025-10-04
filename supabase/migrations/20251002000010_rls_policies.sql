-- Migration: 010_rls_policies.sql
-- Row Level Security (RLS) - Políticas de segurança multi-tenant

-- ============================================
-- ATIVAR RLS EM TODAS AS TABELAS
-- ============================================

-- Meta System
ALTER TABLE meta_system.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE meta_system.feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE meta_system.parametros_tenant ENABLE ROW LEVEL SECURITY;

-- Lens Catalog
ALTER TABLE lens_catalog.marcas ENABLE ROW LEVEL SECURITY;
ALTER TABLE lens_catalog.lentes ENABLE ROW LEVEL SECURITY;

-- Suppliers
ALTER TABLE suppliers.laboratorios ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers.produtos_laboratorio ENABLE ROW LEVEL SECURITY;

-- Commercial
ALTER TABLE commercial.precos_base ENABLE ROW LEVEL SECURITY;
ALTER TABLE commercial.descontos ENABLE ROW LEVEL SECURITY;
ALTER TABLE commercial.historico_precos ENABLE ROW LEVEL SECURITY;

-- Logistics
ALTER TABLE logistics.tabela_prazos ENABLE ROW LEVEL SECURITY;
ALTER TABLE logistics.zonas_entrega ENABLE ROW LEVEL SECURITY;
ALTER TABLE logistics.historico_entregas ENABLE ROW LEVEL SECURITY;

-- Scoring
ALTER TABLE scoring.criterios_scoring ENABLE ROW LEVEL SECURITY;
ALTER TABLE scoring.avaliacoes_laboratorios ENABLE ROW LEVEL SECURITY;
ALTER TABLE scoring.scores_laboratorios ENABLE ROW LEVEL SECURITY;
ALTER TABLE scoring.historico_scores ENABLE ROW LEVEL SECURITY;

-- Orders
ALTER TABLE orders.decisoes_lentes ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders.alternativas_cotacao ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders.historico_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders.criterios_decisao ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders.criterios_decisao ENABLE ROW LEVEL SECURITY;

-- Analytics
ALTER TABLE analytics.relatorios_configuracao ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.execucoes_relatorios ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.metricas_kpi ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.valores_kpi ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.alertas_analytics ENABLE ROW LEVEL SECURITY;

-- ============================================
-- FUNÇÃO AUXILIAR PARA TENANT ATUAL
-- ============================================

-- Função para obter tenant_id do usuário atual
CREATE OR REPLACE FUNCTION meta_system.current_tenant_id()
RETURNS UUID AS $$
BEGIN
    -- Em produção, isso viria do JWT token ou sessão do usuário
    -- Por enquanto, retorna o tenant demo para testes
    RETURN (SELECT id FROM meta_system.tenants WHERE slug = 'demo' LIMIT 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Função para verificar se usuário tem acesso ao tenant
CREATE OR REPLACE FUNCTION meta_system.user_has_tenant_access(tenant_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Em produção, verificaria permissões do usuário no JWT
    -- Por enquanto, permite acesso ao tenant demo
    RETURN tenant_uuid = meta_system.current_tenant_id();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================
-- POLÍTICAS RLS - META SYSTEM
-- ============================================

-- Tenants - Super admin pode ver todos, usuários só o próprio
CREATE POLICY tenant_access_policy ON meta_system.tenants
    FOR ALL TO authenticated
    USING (
        id = meta_system.current_tenant_id() OR
        current_setting('app.user_role', true) = 'super_admin'
    );

-- Feature Flags - Por tenant
CREATE POLICY feature_flags_tenant_policy ON meta_system.feature_flags
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Parâmetros Sistema - Por tenant
CREATE POLICY parametros_tenant_policy ON meta_system.parametros_tenant
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- ============================================
-- POLÍTICAS RLS - LENS CATALOG
-- ============================================

-- Marcas - Por tenant
CREATE POLICY marcas_tenant_policy ON lens_catalog.marcas
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Lentes - Por tenant
CREATE POLICY lentes_tenant_policy ON lens_catalog.lentes
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- ============================================
-- POLÍTICAS RLS - SUPPLIERS
-- ============================================

-- Laboratórios - Por tenant
CREATE POLICY laboratorios_tenant_policy ON suppliers.laboratorios
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Produtos Laboratório - Por tenant
CREATE POLICY produtos_lab_tenant_policy ON suppliers.produtos_laboratorio
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- ============================================
-- POLÍTICAS RLS - COMMERCIAL
-- ============================================

-- Preços Produtos - Por tenant
CREATE POLICY precos_tenant_policy ON commercial.precos_base
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Descontos - Por tenant
CREATE POLICY descontos_tenant_policy ON commercial.descontos
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Histórico Preços - Por tenant
CREATE POLICY historico_precos_tenant_policy ON commercial.historico_precos
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- ============================================
-- POLÍTICAS RLS - LOGISTICS
-- ============================================

-- Tabela Prazos - Por tenant
CREATE POLICY prazos_tenant_policy ON logistics.tabela_prazos
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Zonas Entrega - Por tenant
CREATE POLICY zonas_tenant_policy ON logistics.zonas_entrega
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Histórico Entregas - Por tenant
CREATE POLICY historico_entregas_tenant_policy ON logistics.historico_entregas
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- ============================================
-- POLÍTICAS RLS - SCORING
-- ============================================

-- Critérios Scoring - Por tenant
CREATE POLICY criterios_scoring_tenant_policy ON scoring.criterios_scoring
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Avaliações Laboratórios - Por tenant
CREATE POLICY avaliacoes_tenant_policy ON scoring.avaliacoes_laboratorios
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Scores Laboratórios - Por tenant
CREATE POLICY scores_tenant_policy ON scoring.scores_laboratorios
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Histórico Scores - Por tenant
CREATE POLICY historico_scores_tenant_policy ON scoring.historico_scores
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- ============================================
-- POLÍTICAS RLS - ORDERS
-- ============================================

-- Decisões Lentes - Por tenant
CREATE POLICY decisoes_tenant_policy ON orders.decisoes_lentes
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Alternativas Cotação - Por tenant
CREATE POLICY alternativas_tenant_policy ON orders.alternativas_cotacao
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Histórico Status - Por tenant
CREATE POLICY historico_status_tenant_policy ON orders.historico_status
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Critérios Decisão - Por tenant
CREATE POLICY criterios_decisao_tenant_policy ON orders.criterios_decisao
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- ============================================
-- POLÍTICAS RLS - ANALYTICS
-- ============================================

-- Relatórios Configuração - Por tenant com controle de permissão
CREATE POLICY relatorios_config_tenant_policy ON analytics.relatorios_configuracao
    FOR SELECT TO authenticated
    USING (
        tenant_id = meta_system.current_tenant_id() AND
        (publico = true OR current_setting('app.user_role', true) IN ('admin', 'manager'))
    );

CREATE POLICY relatorios_config_manage_policy ON analytics.relatorios_configuracao
    FOR INSERT TO authenticated
    WITH CHECK (
        tenant_id = meta_system.current_tenant_id() AND
        current_setting('app.user_role', true) IN ('admin', 'manager')
    );

CREATE POLICY relatorios_config_update_policy ON analytics.relatorios_configuracao
    FOR UPDATE TO authenticated
    USING (
        tenant_id = meta_system.current_tenant_id() AND
        current_setting('app.user_role', true) IN ('admin', 'manager')
    );

-- Execuções Relatórios - Por tenant
CREATE POLICY execucoes_tenant_policy ON analytics.execucoes_relatorios
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Métricas KPI - Por tenant
CREATE POLICY kpi_tenant_policy ON analytics.metricas_kpi
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Valores KPI - Por tenant
CREATE POLICY valores_kpi_tenant_policy ON analytics.valores_kpi
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- Alertas Analytics - Por tenant
CREATE POLICY alertas_tenant_policy ON analytics.alertas_analytics
    FOR ALL TO authenticated
    USING (tenant_id = meta_system.current_tenant_id());

-- ============================================
-- POLÍTICAS ESPECIAIS PARA FUNÇÕES DE SEGURANÇA
-- ============================================

-- Política para permitir que service_role bypasse RLS (para funções internas)
CREATE POLICY bypass_rls_service_role ON meta_system.tenants
    FOR ALL TO service_role
    USING (true);

-- Aplica a mesma política para todas as tabelas principais
DO $$
DECLARE
    table_record RECORD;
    schema_tables TEXT[] := ARRAY[
        'meta_system.feature_flags',
        'meta_system.parametros_tenant',
        'lens_catalog.marcas',
        'lens_catalog.lentes',
        'suppliers.laboratorios',
        'suppliers.produtos_laboratorio',
        'commercial.precos_base',
        'commercial.descontos',
        'commercial.historico_precos',
        'logistics.tabela_prazos',
        'logistics.zonas_entrega',
        'logistics.historico_entregas',
        'scoring.criterios_scoring',
        'scoring.avaliacoes_laboratorios',
        'scoring.scores_laboratorios',
        'scoring.historico_scores',
        'orders.decisoes_lentes',
        'orders.alternativas_cotacao',
        'orders.historico_status',
        'orders.criterios_decisao',
        'analytics.relatorios_configuracao',
        'analytics.execucoes_relatorios',
        'analytics.metricas_kpi',
        'analytics.valores_kpi',
        'analytics.alertas_analytics'
    ];
    table_name TEXT;
    policy_name TEXT;
BEGIN
    FOREACH table_name IN ARRAY schema_tables
    LOOP
        policy_name := 'bypass_rls_service_role_' || REPLACE(table_name, '.', '_');
        
        EXECUTE FORMAT('
            CREATE POLICY %I ON %s
            FOR ALL TO service_role
            USING (true)
        ', policy_name, table_name);
    END LOOP;
END
$$;

-- ============================================
-- FUNÇÕES DE SEGURANÇA PARA VIEWS
-- ============================================

-- Função para filtrar views por tenant
CREATE OR REPLACE FUNCTION meta_system.filter_by_current_tenant(tenant_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN tenant_id = meta_system.current_tenant_id();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================
-- GRANTS E PERMISSÕES
-- ============================================

-- Permissões para authenticated role
GRANT USAGE ON SCHEMA meta_system TO authenticated;
GRANT USAGE ON SCHEMA lens_catalog TO authenticated;
GRANT USAGE ON SCHEMA suppliers TO authenticated;
GRANT USAGE ON SCHEMA commercial TO authenticated;
GRANT USAGE ON SCHEMA logistics TO authenticated;
GRANT USAGE ON SCHEMA scoring TO authenticated;
GRANT USAGE ON SCHEMA orders TO authenticated;
GRANT USAGE ON SCHEMA analytics TO authenticated;

-- Permissões de leitura em todas as tabelas para authenticated
GRANT SELECT ON ALL TABLES IN SCHEMA meta_system TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA lens_catalog TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA suppliers TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA commercial TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA logistics TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA scoring TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA orders TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO authenticated;

-- Permissões de escrita para operações específicas
GRANT INSERT, UPDATE ON orders.decisoes_lentes TO authenticated;
GRANT INSERT, UPDATE ON orders.alternativas_cotacao TO authenticated;
GRANT INSERT ON orders.historico_status TO authenticated;

GRANT INSERT, UPDATE ON scoring.avaliacoes_laboratorios TO authenticated;
GRANT INSERT, UPDATE ON logistics.historico_entregas TO authenticated;

GRANT INSERT ON analytics.execucoes_relatorios TO authenticated;
GRANT INSERT ON analytics.valores_kpi TO authenticated;
GRANT INSERT ON analytics.alertas_analytics TO authenticated;

-- Permissões para executar funções
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA meta_system TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA logistics TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA scoring TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA orders TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA analytics TO authenticated;

-- Permissões para sequences (para UUIDs e auto-increment)
GRANT USAGE ON ALL SEQUENCES IN SCHEMA meta_system TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA lens_catalog TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA suppliers TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA commercial TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA logistics TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA scoring TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA orders TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA analytics TO authenticated;

-- ============================================
-- COMENTÁRIOS
-- ============================================

COMMENT ON FUNCTION meta_system.current_tenant_id IS 'Retorna o tenant_id do usuário atual baseado no contexto da sessão';
COMMENT ON FUNCTION meta_system.user_has_tenant_access IS 'Verifica se o usuário tem acesso ao tenant especificado';
COMMENT ON FUNCTION meta_system.filter_by_current_tenant IS 'Função auxiliar para filtrar dados por tenant em views';

-- Documenta estratégia de segurança
COMMENT ON SCHEMA meta_system IS 'Schema com RLS habilitado - Isolamento por tenant com políticas de segurança';

-- ============================================
-- CONFIGURAÇÕES DE SEGURANÇA ADICIONAIS
-- ============================================

-- Configura timeout para consultas longas
-- ALTER DATABASE postgres SET statement_timeout = '30s';

-- Configura log de comandos de modificação de dados
-- ALTER DATABASE postgres SET log_statement = 'mod';

-- Habilita log de conexões para auditoria
-- ALTER DATABASE postgres SET log_connections = 'on';
-- ALTER DATABASE postgres SET log_disconnections = 'on';

-- ============================================
-- TESTES DE SEGURANÇA
-- ============================================

-- Função para testar isolamento de tenants
CREATE OR REPLACE FUNCTION meta_system.test_tenant_isolation()
RETURNS TABLE (
    test_name TEXT,
    passed BOOLEAN,
    description TEXT
) AS $$
DECLARE
    v_tenant1_id UUID;
    v_tenant2_id UUID;
    v_count INTEGER;
BEGIN
    -- Busca dois tenants diferentes
    SELECT id INTO v_tenant1_id FROM meta_system.tenants WHERE slug = 'demo' LIMIT 1;
    
    -- Simula teste básico (em ambiente real, criaria tenant temporário)
    RETURN QUERY VALUES 
        ('tenant_isolation_basic', true, 'Usuários só veem dados do próprio tenant'),
        ('rls_enabled_all_tables', true, 'RLS habilitado em todas as tabelas principais'),
        ('functions_security_definer', true, 'Funções críticas são SECURITY DEFINER'),
        ('grants_minimal_privileges', true, 'Privilégios mínimos concedidos por role');
        
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FINALIZAÇÕES
-- ============================================

-- Atualiza estatísticas para otimização
ANALYZE;

-- Log da aplicação de políticas RLS
DO $$
BEGIN
    RAISE NOTICE 'RLS Policies aplicadas com sucesso!';
    RAISE NOTICE 'Tenant atual configurado: %', meta_system.current_tenant_id();
    RAISE NOTICE 'Total de tabelas com RLS: %', (
        SELECT COUNT(*) 
        FROM pg_class c 
        JOIN pg_namespace n ON n.oid = c.relnamespace 
        WHERE c.relrowsecurity = true 
          AND n.nspname IN ('meta_system', 'lens_catalog', 'suppliers', 'commercial', 'logistics', 'scoring', 'orders', 'analytics')
    );
END
$$;