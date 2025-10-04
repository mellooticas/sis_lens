-- Migration: 004_suppliers.sql
-- Schema suppliers: Laboratórios e seus catálogos nativos

-- ============================================
-- TABELA: laboratorios
-- ============================================
CREATE TABLE suppliers.laboratorios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    nome_fantasia TEXT,
    cnpj TEXT,
    contato_comercial JSONB DEFAULT '{}',
    lead_time_padrao_dias INTEGER NOT NULL DEFAULT 7,
    atende_regioes TEXT[] DEFAULT ARRAY['NACIONAL'],
    endereco JSONB DEFAULT '{}',
    certificacoes TEXT[] DEFAULT '{}',
    observacoes TEXT,
    ativo BOOLEAN NOT NULL DEFAULT true,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, cnpj),
    CHECK (lead_time_padrao_dias BETWEEN 1 AND 60),
    CHECK (cnpj IS NULL OR cnpj ~ '^[0-9]{14}$')
);

-- Índices
CREATE INDEX idx_laboratorios_tenant ON suppliers.laboratorios(tenant_id);
CREATE INDEX idx_laboratorios_nome ON suppliers.laboratorios(nome);
CREATE INDEX idx_laboratorios_cnpj ON suppliers.laboratorios(cnpj);
CREATE INDEX idx_laboratorios_regioes ON suppliers.laboratorios USING gin(atende_regioes);
CREATE INDEX idx_laboratorios_ativo ON suppliers.laboratorios(ativo);

-- ============================================
-- TABELA: produtos_laboratorio
-- ============================================
CREATE TABLE suppliers.produtos_laboratorio (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    laboratorio_id UUID NOT NULL REFERENCES suppliers.laboratorios(id) ON DELETE CASCADE,
    sku_laboratorio TEXT NOT NULL,
    nome_comercial TEXT NOT NULL,
    sku_fantasia TEXT,
    lente_id UUID NOT NULL REFERENCES lens_catalog.lentes(id),
    qualidade_base INTEGER NOT NULL DEFAULT 3 CHECK (qualidade_base BETWEEN 1 AND 5),
    disponivel BOOLEAN NOT NULL DEFAULT true,
    descontinuado_em DATE,
    observacoes_lab TEXT,
    especificacoes_lab JSONB DEFAULT '{}',
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, laboratorio_id, sku_laboratorio),
    UNIQUE(tenant_id, sku_fantasia),
    CHECK (descontinuado_em IS NULL OR descontinuado_em <= CURRENT_DATE)
);

-- Índices
CREATE INDEX idx_produtos_lab_tenant ON suppliers.produtos_laboratorio(tenant_id);
CREATE INDEX idx_produtos_lab_laboratorio ON suppliers.produtos_laboratorio(laboratorio_id);
CREATE INDEX idx_produtos_lab_sku_lab ON suppliers.produtos_laboratorio(sku_laboratorio);
CREATE INDEX idx_produtos_lab_sku_fantasia ON suppliers.produtos_laboratorio(sku_fantasia);
CREATE INDEX idx_produtos_lab_lente ON suppliers.produtos_laboratorio(lente_id);
CREATE INDEX idx_produtos_lab_disponivel ON suppliers.produtos_laboratorio(disponivel);
CREATE INDEX idx_produtos_lab_qualidade ON suppliers.produtos_laboratorio(qualidade_base);

-- ============================================
-- TABELA: contatos_laboratorio
-- ============================================
CREATE TABLE suppliers.contatos_laboratorio (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    laboratorio_id UUID NOT NULL REFERENCES suppliers.laboratorios(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    cargo TEXT,
    email TEXT,
    telefone TEXT,
    whatsapp TEXT,
    tipo_contato TEXT NOT NULL CHECK (tipo_contato IN ('COMERCIAL', 'TECNICO', 'FINANCEIRO', 'LOGISTICA')),
    principal BOOLEAN NOT NULL DEFAULT false,
    ativo BOOLEAN NOT NULL DEFAULT true,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CHECK (email IS NULL OR email ~ '^[^@]+@[^@]+\.[^@]+$')
);

-- Índices
CREATE INDEX idx_contatos_laboratorio ON suppliers.contatos_laboratorio(laboratorio_id);
CREATE INDEX idx_contatos_tipo ON suppliers.contatos_laboratorio(tipo_contato);
CREATE INDEX idx_contatos_principal ON suppliers.contatos_laboratorio(principal);

-- ============================================
-- TRIGGERS
-- ============================================
CREATE TRIGGER tr_laboratorios_updated_at
    BEFORE UPDATE ON suppliers.laboratorios
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

CREATE TRIGGER tr_produtos_lab_updated_at
    BEFORE UPDATE ON suppliers.produtos_laboratorio
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

-- Trigger para garantir apenas um contato principal por tipo
CREATE OR REPLACE FUNCTION suppliers.enforce_single_principal_contact()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.principal = true THEN
        -- Remove principal de outros contatos do mesmo tipo no mesmo lab
        UPDATE suppliers.contatos_laboratorio 
        SET principal = false 
        WHERE laboratorio_id = NEW.laboratorio_id 
          AND tipo_contato = NEW.tipo_contato 
          AND id != NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_contatos_principal
    AFTER INSERT OR UPDATE ON suppliers.contatos_laboratorio
    FOR EACH ROW 
    WHEN (NEW.principal = true)
    EXECUTE FUNCTION suppliers.enforce_single_principal_contact();

-- ============================================
-- FUNÇÕES AUXILIARES
-- ============================================

-- Função para gerar SKU fantasia baseado no padrão do lab
CREATE OR REPLACE FUNCTION suppliers.gerar_sku_fantasia(
    p_laboratorio_id UUID,
    p_lente_id UUID
)
RETURNS TEXT AS $$
DECLARE
    v_lab_nome TEXT;
    v_familia TEXT;
    v_design TEXT;
    v_indice TEXT;
    v_tratamentos TEXT;
    v_sku TEXT;
BEGIN
    -- Busca dados do laboratório e lente
    SELECT 
        COALESCE(l.nome_fantasia, l.nome),
        le.familia,
        le.design,
        REPLACE(le.indice_refracao::TEXT, '.', ''),
        CASE 
            WHEN array_length(le.tratamentos, 1) > 0 
            THEN array_to_string(le.tratamentos, '-')
            ELSE 'BASE'
        END
    INTO v_lab_nome, v_familia, v_design, v_indice, v_tratamentos
    FROM suppliers.laboratorios l,
         lens_catalog.lentes le
    WHERE l.id = p_laboratorio_id 
      AND le.id = p_lente_id;
    
    -- Monta SKU fantasia
    v_sku := UPPER(
        LEFT(v_lab_nome, 3) || '-' ||
        LEFT(v_familia, 3) || '-' ||
        LEFT(v_design, 3) || '-' ||
        v_indice || '-' ||
        v_tratamentos
    );
    
    RETURN v_sku;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- VIEWS AUXILIARES
-- ============================================

-- View para facilitar consultas de produtos com dados da lente
CREATE OR REPLACE VIEW suppliers.vw_produtos_completos AS
SELECT 
    pl.id,
    pl.tenant_id,
    pl.laboratorio_id,
    lab.nome AS laboratorio_nome,
    lab.nome_fantasia AS laboratorio_fantasia,
    pl.sku_laboratorio,
    pl.sku_fantasia,
    pl.nome_comercial,
    pl.qualidade_base,
    pl.disponivel,
    pl.descontinuado_em,
    -- Dados da lente
    le.id AS lente_id,
    le.sku_canonico,
    le.familia,
    le.design,
    ma.nome AS marca_nome,
    le.material,
    le.indice_refracao,
    le.tratamentos,
    le.tipo_lente,
    le.corredor_progressao,
    -- Metadados
    pl.criado_em,
    pl.atualizado_em
FROM suppliers.produtos_laboratorio pl
JOIN suppliers.laboratorios lab ON lab.id = pl.laboratorio_id
JOIN lens_catalog.lentes le ON le.id = pl.lente_id
JOIN lens_catalog.marcas ma ON ma.id = le.marca_id
WHERE pl.disponivel = true 
  AND lab.ativo = true 
  AND le.ativo = true;

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE suppliers.laboratorios IS 'Laboratórios/fornecedores de lentes oftálmicas';
COMMENT ON COLUMN suppliers.laboratorios.contato_comercial IS 'Dados de contato em JSON: {email, telefone, responsavel, etc.}';
COMMENT ON COLUMN suppliers.laboratorios.atende_regioes IS 'Regiões atendidas: NORTE, NORDESTE, CENTRO_OESTE, SUDESTE, SUL, NACIONAL';
COMMENT ON COLUMN suppliers.laboratorios.certificacoes IS 'Certificações do lab: ISO, ANVISA, etc.';

COMMENT ON TABLE suppliers.produtos_laboratorio IS 'Produtos nativos dos labs mapeados para lentes canônicas';
COMMENT ON COLUMN suppliers.produtos_laboratorio.sku_laboratorio IS 'SKU original do laboratório';
COMMENT ON COLUMN suppliers.produtos_laboratorio.sku_fantasia IS 'SKU comercial nosso (mais amigável)';
COMMENT ON COLUMN suppliers.produtos_laboratorio.qualidade_base IS 'Qualidade percebida inicial (1-5) antes do scoring real';

COMMENT ON TABLE suppliers.contatos_laboratorio IS 'Contatos dos laboratórios organizados por tipo';

-- ============================================
-- DADOS INICIAIS (EXEMPLOS)
-- ============================================

DO $$
DECLARE
    v_tenant_id UUID;
    v_lab_a_id UUID;
    v_lab_b_id UUID;
    v_lab_c_id UUID;
    v_lente_varilux_id UUID;
    v_lente_hoya_id UUID;
BEGIN
    -- Pega tenant demo
    SELECT id INTO v_tenant_id FROM meta_system.tenants WHERE slug = 'demo';
    
    -- Verifica se já existem dados antes de inserir
    IF NOT EXISTS (SELECT 1 FROM suppliers.laboratorios WHERE tenant_id = v_tenant_id) THEN
        -- Insere laboratórios
        INSERT INTO suppliers.laboratorios (
            tenant_id, nome, nome_fantasia, cnpj, contato_comercial, 
            lead_time_padrao_dias, atende_regioes, endereco
        ) VALUES 
        (v_tenant_id, 'Laboratório Óptico Premium LTDA', 'Premium Ótica', '12345678000123', 
         '{"email": "comercial@premium.com", "telefone": "(11) 3333-4444", "responsavel": "João Silva"}',
         5, ARRAY['SUDESTE', 'SUL'], 
         '{"cidade": "São Paulo", "estado": "SP", "cep": "01234-567"}'),
         
        (v_tenant_id, 'Visão Clara Laboratórios S/A', 'Visão Clara', '98765432000189',
         '{"email": "vendas@visaoclara.com", "telefone": "(21) 2222-3333", "responsavel": "Maria Santos"}',
         7, ARRAY['SUDESTE', 'NORDESTE'],
         '{"cidade": "Rio de Janeiro", "estado": "RJ", "cep": "20000-000"}'),
         
        (v_tenant_id, 'Ótica Express Nacional', 'Express', '11122233000145',
         '{"email": "pedidos@express.com", "telefone": "(85) 1111-2222", "responsavel": "Pedro Costa"}',
         10, ARRAY['NACIONAL'],
         '{"cidade": "Fortaleza", "estado": "CE", "cep": "60000-000"}');
    END IF;
    
    -- Pega IDs dos labs inseridos
    SELECT id INTO v_lab_a_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Premium Ótica' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_lab_b_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Visão Clara' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_lab_c_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Express' AND tenant_id = v_tenant_id LIMIT 1;
    
    -- Pega algumas lentes de exemplo
    SELECT id INTO v_lente_varilux_id FROM lens_catalog.lentes WHERE sku_canonico = 'LENS-0001-ESS-VLX-X-167-HC-AR-BLUE' LIMIT 1;
    SELECT id INTO v_lente_hoya_id FROM lens_catalog.lentes WHERE sku_canonico = 'LENS-0003-HOY-ID-MYV-167-HC-AR' LIMIT 1;
    
    -- Mapeia produtos dos labs para lentes (só se ainda não existir)
    IF NOT EXISTS (SELECT 1 FROM suppliers.produtos_laboratorio WHERE tenant_id = v_tenant_id) THEN
        INSERT INTO suppliers.produtos_laboratorio (
            tenant_id, laboratorio_id, sku_laboratorio, nome_comercial, 
            sku_fantasia, lente_id, qualidade_base
        ) VALUES 
        -- Lab Premium tem Varilux
        (v_tenant_id, v_lab_a_id, 'PREM-VLX-X-167-BLU', 'Varilux X Premium Blue', 
         'PREMIUM-VLX-X-167-BLUE', v_lente_varilux_id, 5),
         
        -- Lab Visão Clara também tem Varilux (mesmo produto, preços diferentes)
        (v_tenant_id, v_lab_b_id, 'VC-ESS-VLX-X-167', 'Essilor Varilux X 1.67', 
         'VISAO-VLX-X-167-HC-AR-BLUE', v_lente_varilux_id, 4),
         
        -- Lab Express tem Hoya
        (v_tenant_id, v_lab_c_id, 'EXP-HOYA-ID-MV-167', 'Hoya iD MyView Express', 
         'EXPRESS-HOYA-ID-167', v_lente_hoya_id, 3);
    END IF;
     
    -- Adiciona contatos (só se ainda não existir)
    IF NOT EXISTS (SELECT 1 FROM suppliers.contatos_laboratorio WHERE laboratorio_id = v_lab_a_id) THEN
        INSERT INTO suppliers.contatos_laboratorio (
            laboratorio_id, nome, cargo, email, telefone, tipo_contato, principal
        ) VALUES 
        (v_lab_a_id, 'João Silva', 'Gerente Comercial', 'joao@premium.com', '(11) 99999-8888', 'COMERCIAL', true),
        (v_lab_a_id, 'Ana Costa', 'Supervisora Técnica', 'ana@premium.com', '(11) 99999-7777', 'TECNICO', true),
        
        (v_lab_b_id, 'Maria Santos', 'Diretora de Vendas', 'maria@visaoclara.com', '(21) 88888-6666', 'COMERCIAL', true),
        (v_lab_c_id, 'Pedro Costa', 'Coordenador', 'pedro@express.com', '(85) 77777-5555', 'COMERCIAL', true);
    END IF;
END $$;