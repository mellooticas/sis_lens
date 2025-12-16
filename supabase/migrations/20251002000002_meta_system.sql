-- Migration: 002_meta_system.sql
-- Schema meta_system: Multi-tenant, autenticação e configurações

-- ============================================
-- TABELA: tenants
-- ============================================
CREATE TABLE meta_system.tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    configuracoes JSONB DEFAULT '{}',
    ativo BOOLEAN NOT NULL DEFAULT true,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_tenants_slug ON meta_system.tenants(slug);
CREATE INDEX idx_tenants_ativo ON meta_system.tenants(ativo);

-- ============================================
-- TABELA: feature_flags
-- ============================================
CREATE TABLE meta_system.feature_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    flag_nome TEXT NOT NULL,
    habilitado BOOLEAN NOT NULL DEFAULT false,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, flag_nome)
);

-- Índices
CREATE INDEX idx_feature_flags_tenant ON meta_system.feature_flags(tenant_id);
CREATE INDEX idx_feature_flags_nome ON meta_system.feature_flags(flag_nome);

-- ============================================
-- TABELA: parametros_tenant
-- ============================================
CREATE TABLE meta_system.parametros_tenant (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    chave TEXT NOT NULL,
    valor JSONB NOT NULL,
    tipo TEXT NOT NULL CHECK (tipo IN ('PESOS', 'CONFIG', 'INTEGRACAO')),
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, chave)
);

-- Índices
CREATE INDEX idx_parametros_tenant ON meta_system.parametros_tenant(tenant_id);
CREATE INDEX idx_parametros_chave ON meta_system.parametros_tenant(chave);
CREATE INDEX idx_parametros_tipo ON meta_system.parametros_tenant(tipo);

-- ============================================
-- TRIGGERS PARA UPDATED_AT
-- ============================================
CREATE OR REPLACE FUNCTION meta_system.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER tr_tenants_updated_at
    BEFORE UPDATE ON meta_system.tenants
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

CREATE TRIGGER tr_feature_flags_updated_at
    BEFORE UPDATE ON meta_system.feature_flags
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

CREATE TRIGGER tr_parametros_tenant_updated_at
    BEFORE UPDATE ON meta_system.parametros_tenant
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE meta_system.tenants IS 'Tenants do sistema multi-inquilino';
COMMENT ON COLUMN meta_system.tenants.configuracoes IS 'Configurações em JSON: moeda_padrao, pesos_ranking, notificacoes, etc.';

COMMENT ON TABLE meta_system.feature_flags IS 'Feature flags por tenant para habilitar/desabilitar funcionalidades';

COMMENT ON TABLE meta_system.parametros_tenant IS 'Parâmetros customizáveis por tenant (pesos de ranking, configs, etc.)';
COMMENT ON COLUMN meta_system.parametros_tenant.valor IS 'Valor do parâmetro em formato JSON flexível';

-- ============================================
-- DADOS INICIAIS (EXEMPLO)
-- ============================================
-- Tenant padrão para desenvolvimento
INSERT INTO meta_system.tenants (nome, slug, configuracoes) VALUES (
    'SIS Lens Demo',
    'demo',
    '{
        "moeda_padrao": "BRL",
        "pesos_ranking": {
            "urgencia": {"prazo": 0.6, "preco": 0.25, "qualidade": 0.15},
            "normal": {"preco": 0.6, "prazo": 0.3, "qualidade": 0.1},
            "especial": {"qualidade": 0.6, "prazo": 0.25, "preco": 0.15}
        },
        "notificacoes": {
            "email_decisao": true,
            "webhook_dcl": null
        },
        "regiao_padrao": "SUDESTE"
    }'
);

-- Feature flags padrão
INSERT INTO meta_system.feature_flags (tenant_id, flag_nome, habilitado) 
SELECT 
    id,
    flag,
    true
FROM meta_system.tenants t,
UNNEST(ARRAY['ranking_avancado', 'historico_decisoes', 'export_csv', 'webhooks']) AS flag
WHERE t.slug = 'demo';