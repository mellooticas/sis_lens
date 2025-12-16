-- ARQUIVO UNIFICADO DE ATUALIZAÇÃO DO BANCO (SIS Lens v2)
-- Data: 2025-12-09
-- Este script aplica todas as melhorias recentes:
-- 1. Grades de Disponibilidade (Ranges)
-- 2. Integração Modular (Webhooks)
-- 3. Estratégia de Marca Própria (Private Label)

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
