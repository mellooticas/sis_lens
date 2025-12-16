-- ARQUIVO UNIFICADO DE ATUALIZAÇÃO DO BANCO (SIS Lens v2)
-- Data: 2025-12-09
-- Este script aplica todas as melhorias recentes:
-- 1. Grades de Disponibilidade (Ranges)
-- 2. Integração Modular (Webhooks)
-- 3. Estratégia de Marca Própria (Private Label)
-- 4. Views Públicas para o Backend (Correção de Erro 500)

-- ==============================================================================
-- PARTE 1: GRADES DE DISPONIBILIDADE E INTEGRAÇÃO
-- ==============================================================================

-- 1.1. GRADES DE DISPONIBILIDADE (Range Rules)
-- Permite definir faixas exatas de fabricação/estoque para cada lente.
CREATE TABLE IF NOT EXISTS lens_catalog.grades_disponibilidade (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lente_id UUID NOT NULL REFERENCES lens_catalog.lentes(id) ON DELETE CASCADE,
    
    -- Definição do Retângulo de Disponibilidade
    esferico_min NUMERIC(4,2) NOT NULL,
    esferico_max NUMERIC(4,2) NOT NULL,
    cilindrico_min NUMERIC(4,2) NOT NULL DEFAULT 0, -- Geralmente 0
    cilindrico_max NUMERIC(4,2) NOT NULL, -- Geralmente negativo, ex: -6.00
    adicao_min NUMERIC(4,2) DEFAULT 0,
    adicao_max NUMERIC(4,2) DEFAULT 0,
    
    -- Parâmetros Extras
    diametro_mm INTEGER, -- ex: 65, 70, 75
    curva_base NUMERIC(4,2), 
    
    -- Controle
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT ck_grade_esferico CHECK (esferico_max >= esferico_min),
    CONSTRAINT ck_grade_cilindrico CHECK (cilindrico_min >= cilindrico_max),
    CONSTRAINT ck_grade_adicao CHECK (adicao_max >= adicao_min)
);

CREATE INDEX IF NOT EXISTS idx_grades_busca ON lens_catalog.grades_disponibilidade (lente_id, esferico_min, esferico_max, cilindrico_min, cilindrico_max);
COMMENT ON TABLE lens_catalog.grades_disponibilidade IS 'Define faixas de dioptrias (graus) suportadas por cada lente.';

-- 1.2. INTEGRAÇÃO MODULAR (Schema integration)
CREATE SCHEMA IF NOT EXISTS integration;

-- Clientes autorizados a consumir a API
CREATE TABLE IF NOT EXISTS integration.clientes_api (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT NOT NULL, 
    api_key_hash TEXT NOT NULL,
    webhook_url TEXT,
    tenant_id UUID REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Fila de Webhooks
CREATE TABLE IF NOT EXISTS integration.eventos_webhook (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_api_id UUID REFERENCES integration.clientes_api(id),
    decisao_id UUID REFERENCES orders.decisoes_lentes(id) ON DELETE SET NULL,
    tipo_evento TEXT NOT NULL, 
    payload JSONB NOT NULL,
    status TEXT DEFAULT 'PENDENTE',
    tentativas INTEGER DEFAULT 0,
    proxima_tentativa TIMESTAMPTZ DEFAULT NOW(),
    erro_log TEXT,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_webhook_status ON integration.eventos_webhook(status) WHERE status IN ('PENDENTE', 'FALHA');

CREATE OR REPLACE TRIGGER tr_webhook_updated_at
    BEFORE UPDATE ON integration.eventos_webhook
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

-- 1.3. FUNÇÃO HELPER DE DISPONIBILIDADE
CREATE OR REPLACE FUNCTION lens_catalog.verificar_disponibilidade(
    p_lente_id UUID,
    p_esferico NUMERIC,
    p_cilindrico NUMERIC,
    p_adicao NUMERIC DEFAULT 0
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM lens_catalog.grades_disponibilidade
        WHERE lente_id = p_lente_id
          AND ativo = true
          AND p_esferico BETWEEN esferico_min AND esferico_max
          AND p_cilindrico BETWEEN cilindrico_max AND cilindrico_min
          AND p_adicao BETWEEN adicao_min AND adicao_max
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- ==============================================================================
-- PARTE 2: MARCA PRÓPRIA (PRIVATE LABEL)
-- ==============================================================================

-- 2.1. TIPOS DE MARCA
ALTER TABLE lens_catalog.marcas 
ADD COLUMN IF NOT EXISTS tipo_marca TEXT DEFAULT 'GRIFE' CHECK (tipo_marca IN ('GRIFE', 'PROPRIA'));

COMMENT ON COLUMN lens_catalog.marcas.tipo_marca IS 'GRIFE: Marcas de mercado. PROPRIA: Marcas da ótica com sourcing dinâmico.';

-- 2.2. HOMOLOGAÇÃO DE PRODUTOS (Sourcing)
CREATE TABLE IF NOT EXISTS lens_catalog.homologacao_marca_propria (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    lente_marca_propria_id UUID NOT NULL REFERENCES lens_catalog.lentes(id) ON DELETE CASCADE,
    produto_lab_id UUID NOT NULL REFERENCES suppliers.produtos_laboratorio(id) ON DELETE CASCADE,
    
    prioridade INTEGER DEFAULT 1, 
    fator_qualidade NUMERIC(3,2) DEFAULT 1.0, 
    
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(lente_marca_propria_id, produto_lab_id)
);

CREATE INDEX IF NOT EXISTS idx_homologacao_busca ON lens_catalog.homologacao_marca_propria(lente_marca_propria_id) WHERE ativo = true;

-- 2.3. VIEW DE SOURCING DINÂMICO
CREATE OR REPLACE VIEW lens_catalog.vw_opcoes_marca_propria AS
SELECT 
    h.lente_marca_propria_id as lente_virtual_id,
    -- Nota: Usando 'familia' || ' ' || 'design' como fallback para nome comercial
    CONCAT(l_virtual.familia, ' ', l_virtual.design) as nome_virtual,
    
    h.produto_lab_id as produto_real_id,
    pl.nome_comercial as nome_real_laboratorio,
    pl.laboratorio_id,
    lab.nome_fantasia as nome_laboratorio,
    
    -- Preço de Custo Vigente
    (SELECT preco_tabela 
     FROM commercial.precos_base pb 
     WHERE pb.produto_lab_id = pl.id 
       AND pb.ativo = true
     ORDER BY pb.vigencia_inicio DESC LIMIT 1) as custo_atual,
     
    lp.prazo_medio,
    h.prioridade
    
FROM lens_catalog.homologacao_marca_propria h
JOIN lens_catalog.lentes l_virtual ON l_virtual.id = h.lente_marca_propria_id
JOIN suppliers.produtos_laboratorio pl ON pl.id = h.produto_lab_id
JOIN suppliers.laboratorios lab ON lab.id = pl.laboratorio_id
LEFT JOIN logistics.tabela_prazos lp ON lp.laboratorio_id = lab.id
WHERE h.ativo = true;

-- SEED: Dados de Demonstração SIS Lens (Marca Própria & Sourcing)
-- Data: 2025-12-09

DO $$
DECLARE
    v_tenant_id UUID;
    v_marca_sis UUID;
    v_lente_gold UUID;
    v_lente_silver UUID;
    v_lab_a UUID; 
    v_lab_b UUID;
    v_lab_c UUID;
    v_prod_a UUID;
    v_prod_b UUID;
    v_prod_c UUID;
BEGIN
    -- 1. Obter Tenant Demo
    SELECT id INTO v_tenant_id FROM meta_system.tenants WHERE slug = 'demo';
    
    -- Se não existir tenant, cria
    IF v_tenant_id IS NULL THEN
        INSERT INTO meta_system.tenants (nome, slug) VALUES ('Ótica Demo', 'demo') 
        RETURNING id INTO v_tenant_id;
    END IF;

    -- 2. Criar Laboratórios (Fornecedores Reais)
    -- Tentativa resiliente de inserir laboratórios (coluna 'nome' removida pois usuário reportou que não existe)
    
    -- Lab A: O "Rápido"
    INSERT INTO suppliers.laboratorios (tenant_id, nome_fantasia, lead_time_padrao_dias)
    VALUES (v_tenant_id, 'Lab Speed', 2)
    ON CONFLICT DO NOTHING;
    SELECT id INTO v_lab_a FROM suppliers.laboratorios WHERE nome_fantasia = 'Lab Speed';

    -- Lab B: O "Barato"
    INSERT INTO suppliers.laboratorios (tenant_id, nome_fantasia, lead_time_padrao_dias)
    VALUES (v_tenant_id, 'Lab Eco', 5)
    ON CONFLICT DO NOTHING;
    SELECT id INTO v_lab_b FROM suppliers.laboratorios WHERE nome_fantasia = 'Lab Eco';

    -- Lab C: O "Premium"
    INSERT INTO suppliers.laboratorios (tenant_id, nome_fantasia, lead_time_padrao_dias)
    VALUES (v_tenant_id, 'Lab Precision', 4)
    ON CONFLICT DO NOTHING;
    SELECT id INTO v_lab_c FROM suppliers.laboratorios WHERE nome_fantasia = 'Lab Precision';

    -- 3. Criar Marca Própria SIS Lens
    INSERT INTO lens_catalog.marcas (tenant_id, nome, pais_origem, tipo_marca)
    VALUES (v_tenant_id, 'SIS Lens', 'Brasil', 'PROPRIA')
    ON CONFLICT (tenant_id, nome) DO UPDATE SET tipo_marca = 'PROPRIA'
    RETURNING id INTO v_marca_sis;

    -- 4. Criar Lentes Virtuais (Face Cliente)
    
    -- 4.1 SIS Lens Gold (A Top de Linha)
    INSERT INTO lens_catalog.lentes (
        tenant_id, sku_canonico, marca_id, familia, design, material, 
        indice_refracao, tratamentos, tipo_lente, ativo
    ) VALUES (
        v_tenant_id, 'SIS-GOLD-167-DIG', v_marca_sis, 'SIS Gold', 'Digital HD', 'HIGH_INDEX_167',
        1.67, ARRAY['AR_PREMIUM', 'BLUE_CUT', 'UV400'], 'PROGRESSIVA', true
    )
    ON CONFLICT (tenant_id, sku_canonico) DO UPDATE SET ativo = true
    RETURNING id INTO v_lente_gold;

    -- 4.2 SIS Lens Silver (A Custo-Benefício)
    INSERT INTO lens_catalog.lentes (
        tenant_id, sku_canonico, marca_id, familia, design, material, 
        indice_refracao, tratamentos, tipo_lente, ativo
    ) VALUES (
        v_tenant_id, 'SIS-SILV-159-DIG', v_marca_sis, 'SIS Silver', 'Digital Soft', 'POLICARBONATO',
        1.59, ARRAY['AR_STANDARD', 'HARD_COAT'], 'PROGRESSIVA', true
    )
    ON CONFLICT (tenant_id, sku_canonico) DO UPDATE SET ativo = true
    RETURNING id INTO v_lente_silver;

    -- 5. Criar Produtos nos Laboratórios (O que compramos deles)
    
    -- Lab A tem a "Speed 1.67" (que vai virar Gold)
    INSERT INTO suppliers.produtos_laboratorio (
        tenant_id, laboratorio_id, sku_laboratorio, nome_comercial, sku_fantasia, lente_id, disponivel
    ) VALUES (
        v_tenant_id, v_lab_a, 'LABA-167-HD', 'Speed High Index 1.67', 'SPEED-167', v_lente_gold, true
    ) RETURNING id INTO v_prod_a;

    -- Lab B tem a "Eco Digital 1.67" (que também vira Gold)
    INSERT INTO suppliers.produtos_laboratorio (
        tenant_id, laboratorio_id, sku_laboratorio, nome_comercial, sku_fantasia, lente_id, disponivel
    ) VALUES (
        v_tenant_id, v_lab_b, 'LABB-ECO-167', 'EcoView 1.67 Digital', 'ECO-167', v_lente_gold, true
    ) RETURNING id INTO v_prod_b;

    -- 6. Definir Preços de Custo (Aqui mora o lucro!)
    
    -- Lab A (Rápido) custa R$ 300
    INSERT INTO commercial.precos_base (tenant_id, produto_lab_id, preco_tabela, vigencia_inicio, ativo)
    VALUES (v_tenant_id, v_prod_a, 300.00, NOW(), true);

    -- Lab B (Barato) custa R$ 180 (Sourcing preferido!)
    INSERT INTO commercial.precos_base (tenant_id, produto_lab_id, preco_tabela, vigencia_inicio, ativo)
    VALUES (v_tenant_id, v_prod_b, 180.00, NOW(), true);

    -- 7. Homologar Sourcing (Ligar Virtual -> Real)
    
    -- SIS Gold -> Lab A (Prioridade 2, mais caro)
    INSERT INTO lens_catalog.homologacao_marca_propria (
        lente_marca_propria_id, produto_lab_id, prioridade, fator_qualidade
    ) VALUES (v_lente_gold, v_prod_a, 2, 1.0)
    ON CONFLICT DO NOTHING;

    -- SIS Gold -> Lab B (Prioridade 1, mais barato e bom)
    INSERT INTO lens_catalog.homologacao_marca_propria (
        lente_marca_propria_id, produto_lab_id, prioridade, fator_qualidade
    ) VALUES (v_lente_gold, v_prod_b, 1, 0.95)
    ON CONFLICT DO NOTHING;

    -- 8. Grades de Disponibilidade (Exemplo)
    -- SIS Gold vai de -6 a +4
    INSERT INTO lens_catalog.grades_disponibilidade (
        lente_id, esferico_min, esferico_max, cilindrico_min, cilindrico_max, adicao_min, adicao_max
    ) VALUES 
    (v_lente_gold, -6.00, 4.00, 0.00, -4.00, 1.00, 3.50);

END $$;

-- ============================================================================
-- PARTE 3: VIEWS PÚBLICAS PARA O BACKEND (CORREÇÃO DE CONEXÃO)
-- ============================================================================

GRANT USAGE ON SCHEMA lens_catalog TO anon;
GRANT USAGE ON SCHEMA suppliers TO anon;
GRANT USAGE ON SCHEMA orders TO anon;
GRANT USAGE ON SCHEMA scoring TO anon;
GRANT USAGE ON SCHEMA commercial TO anon;
GRANT USAGE ON SCHEMA api TO anon;

GRANT SELECT ON ALL TABLES IN SCHEMA lens_catalog TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA suppliers TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA orders TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA scoring TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA commercial TO anon;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA api TO anon;

-- View: vw_lentes_catalogo
CREATE OR REPLACE VIEW public.vw_lentes_catalogo AS
SELECT 
    l.id AS lente_id, l.tenant_id, l.sku_canonico, l.familia, l.design, l.material, l.indice_refracao,
    l.tratamentos, l.tipo_lente, l.corredor_progressao, l.specs_tecnicas, l.ativo,
    m.nome AS marca_nome, m.pais_origem,
    CONCAT(m.nome, ' ', l.familia, ' ', l.design, ' ', l.indice_refracao) AS descricao_completa
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE l.ativo = true;

-- View: vw_fornecedores
CREATE OR REPLACE VIEW public.vw_fornecedores AS
SELECT 
    lab.id, lab.tenant_id, lab.nome_fantasia as nome, lab.cnpj, lab.contato_comercial as contato,
    50 as credibilidade_score, lab.ativo,
    COUNT(prod.id) AS total_produtos,
    COUNT(CASE WHEN prod.disponivel = true THEN 1 END) AS produtos_disponiveis
FROM suppliers.laboratorios lab
LEFT JOIN suppliers.produtos_laboratorio prod ON lab.id = prod.laboratorio_id
WHERE lab.ativo = true
GROUP BY lab.id, lab.tenant_id, lab.nome_fantasia, lab.cnpj, lab.contato_comercial, lab.ativo;

-- View: decisoes_compra
CREATE OR REPLACE VIEW public.decisoes_compra AS
SELECT 
    dec.id, dec.tenant_id, dec.lente_id, dec.laboratorio_id, dec.produto_lab_id,
    'NORMAL' as criterio, dec.preco_final, dec.prazo_estimado_dias, dec.custo_frete,
    dec.score_atribuido, dec.motivo, dec.alternativas_consideradas, dec.decidido_por,
    dec.decidido_em, dec.status, dec.payload_decisao, dec.created_at, dec.updated_at
FROM orders.decisoes_lentes dec;

-- View: produtos_laboratorio
CREATE OR REPLACE VIEW public.produtos_laboratorio AS
SELECT 
    prod.*, lab.nome_fantasia as laboratorio_nome, 50 as credibilidade_score,
    lente.sku_canonico as lente_sku, lente.familia as lente_familia
FROM suppliers.produtos_laboratorio prod
LEFT JOIN suppliers.laboratorios lab ON prod.laboratorio_id = lab.id
LEFT JOIN lens_catalog.lentes lente ON prod.lente_id = lente.id;

-- View: mv_economia_por_fornecedor
CREATE OR REPLACE VIEW public.mv_economia_por_fornecedor AS
SELECT 
    lab.id as laboratorio_id, lab.nome_fantasia as laboratorio_nome,
    COUNT(dec.id) as total_decisoes,
    AVG(dec.preco_final) as preco_medio,
    SUM(COALESCE(dec.economia_gerada, 0)) as economia_total,
    AVG(dec.score_atribuido) as score_medio
FROM suppliers.laboratorios lab
LEFT JOIN orders.decisoes_lentes dec ON lab.id = dec.laboratorio_id
WHERE lab.ativo = true
GROUP BY lab.id, lab.nome_fantasia;

-- View: v_dashboard_vouchers (Mock temporário para não quebrar analytics)
CREATE OR REPLACE VIEW public.v_dashboard_vouchers AS
SELECT 
    COUNT(id) as total_vouchers_gerados,
    SUM(preco_final) as valor_total_economia_gerada
FROM orders.decisoes_lentes;

GRANT SELECT ON public.vw_lentes_catalogo TO anon;
GRANT SELECT ON public.vw_fornecedores TO anon;
GRANT SELECT ON public.decisoes_compra TO anon;
GRANT SELECT ON public.produtos_laboratorio TO anon;
GRANT SELECT ON public.mv_economia_por_fornecedor TO anon;
GRANT SELECT ON public.v_dashboard_vouchers TO anon;

-- RPC wrappers omitidos para brevidade (já estão no script anterior se necessário ser rodado separado, mas as Views são o crítico)
