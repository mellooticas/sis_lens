-- Migration: 003_lens_catalog.sql
-- Schema lens_catalog: Catálogo canônico de lentes (fonte da verdade técnica)

-- ============================================
-- TABELA: marcas
-- ============================================
CREATE TABLE lens_catalog.marcas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    pais_origem TEXT,
    ativo BOOLEAN NOT NULL DEFAULT true,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, nome)
);

-- Índices
CREATE INDEX idx_marcas_tenant ON lens_catalog.marcas(tenant_id);
CREATE INDEX idx_marcas_nome ON lens_catalog.marcas(nome);
CREATE INDEX idx_marcas_ativo ON lens_catalog.marcas(ativo);

-- ============================================
-- TABELA: lentes
-- ============================================
CREATE TABLE lens_catalog.lentes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    sku_canonico TEXT NOT NULL,
    marca_id UUID NOT NULL REFERENCES lens_catalog.marcas(id),
    familia TEXT NOT NULL,
    design TEXT NOT NULL,
    material public.material_lente NOT NULL,
    indice_refracao NUMERIC(3,2) NOT NULL CHECK (indice_refracao BETWEEN 1.49 AND 1.90),
    tratamentos public.tratamento_lente[] DEFAULT '{}',
    tipo_lente public.tipo_lente NOT NULL,
    corredor_progressao INTEGER,
    specs_tecnicas JSONB DEFAULT '{}',
    ativo BOOLEAN NOT NULL DEFAULT true,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, sku_canonico)
);

-- Índices
CREATE INDEX idx_lentes_tenant ON lens_catalog.lentes(tenant_id);
CREATE INDEX idx_lentes_sku ON lens_catalog.lentes(sku_canonico);
CREATE INDEX idx_lentes_marca ON lens_catalog.lentes(marca_id);
CREATE INDEX idx_lentes_familia ON lens_catalog.lentes(familia);
CREATE INDEX idx_lentes_tipo ON lens_catalog.lentes(tipo_lente);
CREATE INDEX idx_lentes_material ON lens_catalog.lentes(material);
CREATE INDEX idx_lentes_indice ON lens_catalog.lentes(indice_refracao);
CREATE INDEX idx_lentes_tratamentos ON lens_catalog.lentes USING gin(tratamentos);
CREATE INDEX idx_lentes_specs ON lens_catalog.lentes USING gin(specs_tecnicas);
CREATE INDEX idx_lentes_ativo ON lens_catalog.lentes(ativo);

-- ============================================
-- CONSTRAINTS E VALIDAÇÕES
-- ============================================

-- Validação: corredor_progressao só para lentes progressivas
ALTER TABLE lens_catalog.lentes 
ADD CONSTRAINT ck_corredor_progressao 
CHECK (
    (tipo_lente = 'PROGRESSIVA' AND corredor_progressao IS NOT NULL AND corredor_progressao BETWEEN 8 AND 25) OR
    (tipo_lente != 'PROGRESSIVA' AND corredor_progressao IS NULL)
);

-- Validação: SKU canônico deve seguir padrão
ALTER TABLE lens_catalog.lentes 
ADD CONSTRAINT ck_sku_canonico_formato 
CHECK (sku_canonico ~ '^LENS-[0-9]{4}-[A-Z0-9-]{3,50}$');

-- ============================================
-- TRIGGERS
-- ============================================
CREATE TRIGGER tr_marcas_updated_at
    BEFORE UPDATE ON lens_catalog.marcas
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

CREATE TRIGGER tr_lentes_updated_at
    BEFORE UPDATE ON lens_catalog.lentes
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

-- ============================================
-- FUNÇÕES AUXILIARES
-- ============================================

-- Função para gerar próximo SKU canônico
CREATE OR REPLACE FUNCTION lens_catalog.gerar_proximo_sku(p_tenant_id UUID)
RETURNS TEXT AS $$
DECLARE
    v_next_num INTEGER;
    v_sku TEXT;
BEGIN
    -- Pega o próximo número sequencial por tenant
    SELECT COALESCE(MAX(
        CAST(substring(sku_canonico FROM 'LENS-([0-9]{4})-') AS INTEGER)
    ), 0) + 1
    INTO v_next_num
    FROM lens_catalog.lentes 
    WHERE tenant_id = p_tenant_id;
    
    -- Formata com zero à esquerda
    v_sku := 'LENS-' || LPAD(v_next_num::TEXT, 4, '0') || '-';
    
    RETURN v_sku;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE lens_catalog.marcas IS 'Marcas de lentes (Essilor, Hoya, Zeiss, etc.)';
COMMENT ON TABLE lens_catalog.lentes IS 'Catálogo canônico de lentes - fonte única da verdade técnica';

COMMENT ON COLUMN lens_catalog.lentes.sku_canonico IS 'SKU interno único e imutável (ex: LENS-0001-ESS-VLX-X-167-HC-AR-BLUE)';
COMMENT ON COLUMN lens_catalog.lentes.tratamentos IS 'Array de tratamentos aplicados (HC, AR, BLUE, etc.)';
COMMENT ON COLUMN lens_catalog.lentes.specs_tecnicas IS 'Especificações técnicas flexíveis em JSON';
COMMENT ON COLUMN lens_catalog.lentes.corredor_progressao IS 'Tamanho do corredor em mm (apenas para progressivas)';

-- ============================================
-- DADOS INICIAIS (EXEMPLOS)
-- ============================================

-- Marcas principais
INSERT INTO lens_catalog.marcas (tenant_id, nome, pais_origem) 
SELECT 
    t.id,
    marca.nome,
    marca.pais
FROM meta_system.tenants t,
(VALUES 
    ('Essilor', 'França'),
    ('Hoya', 'Japão'),
    ('Zeiss', 'Alemanha'),
    ('Kodak', 'Estados Unidos'),
    ('Rodenstock', 'Alemanha')
) AS marca(nome, pais)
WHERE t.slug = 'demo';

-- Lentes de exemplo
DO $$
DECLARE
    v_tenant_id UUID;
    v_essilor_id UUID;
    v_hoya_id UUID;
    v_zeiss_id UUID;
BEGIN
    -- Pega IDs para o tenant demo
    SELECT id INTO v_tenant_id FROM meta_system.tenants WHERE slug = 'demo';
    SELECT id INTO v_essilor_id FROM lens_catalog.marcas WHERE tenant_id = v_tenant_id AND nome = 'Essilor';
    SELECT id INTO v_hoya_id FROM lens_catalog.marcas WHERE tenant_id = v_tenant_id AND nome = 'Hoya';
    SELECT id INTO v_zeiss_id FROM lens_catalog.marcas WHERE tenant_id = v_tenant_id AND nome = 'Zeiss';
    
    -- Lentes Essilor
    INSERT INTO lens_catalog.lentes (
        tenant_id, sku_canonico, marca_id, familia, design, material, 
        indice_refracao, tratamentos, tipo_lente, corredor_progressao, specs_tecnicas
    ) VALUES 
    (v_tenant_id, 'LENS-0001-ESS-VLX-X-167-HC-AR-BLUE', v_essilor_id, 'Varilux', 'X Series', 'HIGH_INDEX_167', 1.67, 
     ARRAY['HC', 'AR', 'BLUE']::public.tratamento_lente[], 'PROGRESSIVA', 14, 
     '{"tecnologia": "Nanoptix", "adicao_maxima": 3.50, "adaptacao": "Rapida"}'),
    
    (v_tenant_id, 'LENS-0002-ESS-VLX-C-160-AR', v_essilor_id, 'Varilux', 'Comfort Max', 'HIGH_INDEX_160', 1.60,
     ARRAY['AR']::public.tratamento_lente[], 'PROGRESSIVA', 17,
     '{"tecnologia": "W.A.V.E 2.0", "adicao_maxima": 3.00, "campo_visao": "Ampliado"}'),
     
    -- Lentes Hoya
    (v_tenant_id, 'LENS-0003-HOY-ID-MYV-167-HC-AR', v_hoya_id, 'iD', 'MyView', 'HIGH_INDEX_167', 1.67,
     ARRAY['HC', 'AR']::public.tratamento_lente[], 'PROGRESSIVA', 15,
     '{"tecnologia": "Binocular Eye Model", "personalizacao": "Total", "adaptacao": "Instantanea"}'),
     
    -- Lentes Zeiss
    (v_tenant_id, 'LENS-0004-ZEI-SML-DRV-160-AR-BLUE', v_zeiss_id, 'SmartLife', 'DriveSafe', 'HIGH_INDEX_160', 1.60,
     ARRAY['AR', 'BLUE']::public.tratamento_lente[], 'PROGRESSIVA', 16,
     '{"tecnologia": "Age Intelligence", "especializacao": "Dirigir", "reducao_ofuscamento": true}');
END $$;