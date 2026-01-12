-- PARTE 1: ESTRUTURA (STRUCTURE)
-- Data: 2025-12-10
-- Este script atualiza a estrutura do banco de dados (Tabelas, Colunas, Views).
-- NÃO insere dados de exemplo (Seed).

-- ==============================================================================
-- 0. GARANTIR ENUMS (Correção para erro 22P02)
-- ==============================================================================
DO $$
BEGIN
    -- Tenta adicionar valores ao Enum se não existirem
    ALTER TYPE public.material_lente ADD VALUE 'HIGH_INDEX_167';
EXCEPTION
    WHEN duplicate_object THEN null; -- Já existe, ignora
    WHEN others THEN null; -- Outro erro (ex: tipo não existe), ignora
END $$;

DO $$
BEGIN
    ALTER TYPE public.material_lente ADD VALUE 'HIGH_INDEX_160';
EXCEPTION
    WHEN duplicate_object THEN null;
    WHEN others THEN null;
END $$;

DO $$
BEGIN
    ALTER TYPE public.material_lente ADD VALUE 'HIGH_INDEX_174';
EXCEPTION
    WHEN duplicate_object THEN null;
    WHEN others THEN null;
END $$;

DO $$
BEGIN
    ALTER TYPE public.material_lente ADD VALUE 'POLICARBONATO';
EXCEPTION
    WHEN duplicate_object THEN null;
    WHEN others THEN null;
    WHEN others THEN null;
END $$;

DO $$
BEGIN
    ALTER TYPE public.tratamento_lente ADD VALUE 'AR_PREMIUM';
EXCEPTION
    WHEN duplicate_object THEN null;
    WHEN others THEN null;
END $$;

DO $$
BEGIN
    ALTER TYPE public.tratamento_lente ADD VALUE 'AR_STANDARD';
EXCEPTION
    WHEN duplicate_object THEN null;
    WHEN others THEN null;
END $$;

DO $$
BEGIN
    ALTER TYPE public.tratamento_lente ADD VALUE 'BLUE_CUT';
EXCEPTION
    WHEN duplicate_object THEN null;
    WHEN others THEN null;
END $$;

DO $$
BEGIN
    ALTER TYPE public.tratamento_lente ADD VALUE 'UV400';
EXCEPTION
    WHEN duplicate_object THEN null;
    WHEN others THEN null;
END $$;

-- ==============================================================================
-- 1. GRADES DE DISPONIBILIDADE (Range Rules)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS lens_catalog.grades_disponibilidade (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lente_id UUID NOT NULL REFERENCES lens_catalog.lentes(id) ON DELETE CASCADE,
    esferico_min NUMERIC(4,2) NOT NULL,
    esferico_max NUMERIC(4,2) NOT NULL,
    cilindrico_min NUMERIC(4,2) NOT NULL DEFAULT 0,
    cilindrico_max NUMERIC(4,2) NOT NULL,
    adicao_min NUMERIC(4,2) DEFAULT 0,
    adicao_max NUMERIC(4,2) DEFAULT 0,
    diametro_mm INTEGER,
    curva_base NUMERIC(4,2), 
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT ck_grade_esferico CHECK (esferico_max >= esferico_min),
    CONSTRAINT ck_grade_cilindrico CHECK (cilindrico_min >= cilindrico_max),
    CONSTRAINT ck_grade_adicao CHECK (adicao_max >= adicao_min)
);

CREATE INDEX IF NOT EXISTS idx_grades_busca ON lens_catalog.grades_disponibilidade (lente_id, esferico_min, esferico_max, cilindrico_min, cilindrico_max);

-- 2. INTEGRAÇÃO MODULAR
CREATE SCHEMA IF NOT EXISTS integration;

CREATE TABLE IF NOT EXISTS integration.clientes_api (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT NOT NULL, 
    api_key_hash TEXT NOT NULL,
    webhook_url TEXT,
    tenant_id UUID REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW()
);

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

-- 3. MARCA PRÓPRIA (PRIVATE LABEL)
ALTER TABLE lens_catalog.marcas 
ADD COLUMN IF NOT EXISTS tipo_marca TEXT DEFAULT 'GRIFE' CHECK (tipo_marca IN ('GRIFE', 'PROPRIA'));

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

CREATE OR REPLACE VIEW lens_catalog.vw_opcoes_marca_propria AS
SELECT 
    h.lente_marca_propria_id as lente_virtual_id,
    CONCAT(l_virtual.familia, ' ', l_virtual.design) as nome_virtual,
    h.produto_lab_id as produto_real_id,
    pl.nome_comercial as nome_real_laboratorio,
    pl.laboratorio_id,
    lab.nome_fantasia as nome_laboratorio,
    (SELECT preco_tabela FROM commercial.precos_base pb WHERE pb.produto_lab_id = pl.id AND pb.ativo = true ORDER BY pb.vigencia_inicio DESC LIMIT 1) as custo_atual,
    lp.prazo_medio,
    h.prioridade
FROM lens_catalog.homologacao_marca_propria h
JOIN lens_catalog.lentes l_virtual ON l_virtual.id = h.lente_marca_propria_id
JOIN suppliers.produtos_laboratorio pl ON pl.id = h.produto_lab_id
JOIN suppliers.laboratorios lab ON lab.id = pl.laboratorio_id
LEFT JOIN logistics.tabela_prazos lp ON lp.laboratorio_id = lab.id
WHERE h.ativo = true;

-- 4. VIEWS PÚBLICAS (Correção de Erro 500 no Analytics)
DROP VIEW IF EXISTS public.vw_lentes_catalogo CASCADE;
CREATE OR REPLACE VIEW public.vw_lentes_catalogo AS
SELECT 
    l.id AS lente_id, l.tenant_id, l.sku_canonico, l.familia, l.design, l.material, l.indice_refracao,
    l.tratamentos, l.tipo_lente, l.corredor_progressao, l.specs_tecnicas, l.ativo,
    m.nome AS marca_nome, m.pais_origem,
    CONCAT(m.nome, ' ', l.familia, ' ', l.design, ' ', l.indice_refracao) AS descricao_completa
FROM lens_catalog.lentes l
LEFT JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE l.ativo = true;

DROP VIEW IF EXISTS public.vw_fornecedores CASCADE;
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

DROP VIEW IF EXISTS public.decisoes_compra CASCADE;
CREATE OR REPLACE VIEW public.decisoes_compra AS
SELECT 
    dec.id,
    dec.tenant_id,
    dec.lente_recomendada_id as lente_id,
    dec.laboratorio_escolhido_id as laboratorio_id,
    NULL::UUID as produto_lab_id,
    dec.criterio_usado::TEXT as criterio,
    dec.preco_final,
    dec.prazo_estimado_dias, 
    dec.custo_frete, 
    dec.score_atribuido, 
    dec.motivo_decisao as motivo, 
    dec.alternativas_consideradas, 
    dec.decidido_por, 
    dec.decidido_em, 
    dec.status::TEXT, 
    jsonb_build_object(
        'receita', '{}'::jsonb, 
        'especificacoes', '{}'::jsonb
    ) as payload_decisao,
    dec.decidido_em as created_at,
    dec.decidido_em as updated_at
FROM orders.decisoes_lentes dec;

DROP VIEW IF EXISTS public.produtos_laboratorio CASCADE;
CREATE OR REPLACE VIEW public.produtos_laboratorio AS
SELECT 
    prod.*, lab.nome_fantasia as laboratorio_nome, 50 as credibilidade_score,
    lente.sku_canonico as lente_sku, lente.familia as lente_familia
FROM suppliers.produtos_laboratorio prod
LEFT JOIN suppliers.laboratorios lab ON prod.laboratorio_id = lab.id
LEFT JOIN lens_catalog.lentes lente ON prod.lente_id = lente.id;

DROP VIEW IF EXISTS public.mv_economia_por_fornecedor CASCADE;
CREATE OR REPLACE VIEW public.mv_economia_por_fornecedor AS
SELECT 
    lab.id as laboratorio_id, lab.nome_fantasia as laboratorio_nome,
    COUNT(dec.id) as total_decisoes,
    AVG(dec.preco_final) as preco_medio,
    0 as economia_total, -- Não existe economia_gerada
    AVG(COALESCE(dec.score_atribuido, 50)) as score_medio -- Usando coluna real score_atribuido
FROM suppliers.laboratorios lab
LEFT JOIN orders.decisoes_lentes dec ON lab.id = dec.laboratorio_escolhido_id -- Corrigido join para coluna correta
WHERE lab.ativo = true
GROUP BY lab.id, lab.nome_fantasia;

DROP VIEW IF EXISTS public.v_dashboard_vouchers CASCADE;
CREATE OR REPLACE VIEW public.v_dashboard_vouchers AS
SELECT 
    COUNT(id) as total_vouchers_gerados,
    SUM(preco_final) as valor_total_economia_gerada
FROM orders.decisoes_lentes;

-- Permissões
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
GRANT SELECT ON public.vw_lentes_catalogo TO anon;
GRANT SELECT ON public.vw_fornecedores TO anon;
GRANT SELECT ON public.decisoes_compra TO anon;
GRANT SELECT ON public.produtos_laboratorio TO anon;
GRANT SELECT ON public.mv_economia_por_fornecedor TO anon;
GRANT SELECT ON public.v_dashboard_vouchers TO anon;

-- Wrapper RPC
CREATE OR REPLACE FUNCTION public.rpc_buscar_lente(p_query TEXT, p_limit INTEGER DEFAULT 20)
RETURNS TABLE(lente_id UUID, label TEXT, sku_fantasia TEXT) LANGUAGE SQL SECURITY DEFINER AS $$
    SELECT 
        l.id,
        CONCAT(m.nome, ' ', l.familia, ' ', l.design) as label,
        l.sku_canonico as sku_fantasia
    FROM lens_catalog.lentes l
    JOIN lens_catalog.marcas m ON m.id = l.marca_id
    WHERE l.ativo = true
      AND (
          p_query IS NULL 
          OR m.nome ILIKE '%' || p_query || '%'
          OR l.familia ILIKE '%' || p_query || '%'
          OR l.sku_canonico ILIKE '%' || p_query || '%'
      )
    LIMIT p_limit;
$$;
GRANT EXECUTE ON FUNCTION public.rpc_buscar_lente TO anon;

