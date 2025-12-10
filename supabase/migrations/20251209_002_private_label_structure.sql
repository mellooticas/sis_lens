-- Migration: Private Label (Marca Própria) Support
-- Data: 2025-12-09
-- Description: Adiciona suporte a marcas próprias com sourcing dinâmico entre múltiplos laboratórios.

-- ============================================
-- 1. TIPOS DE MARCA
-- ============================================

ALTER TABLE lens_catalog.marcas 
ADD COLUMN IF NOT EXISTS tipo_marca TEXT DEFAULT 'GRIFE' CHECK (tipo_marca IN ('GRIFE', 'PROPRIA'));

COMMENT ON COLUMN lens_catalog.marcas.tipo_marca IS 'GRIFE: Marcas de mercado (Varilux, Zeiss). PROPRIA: Marcas da ótica (BestLens) com sourcing dinâmico.';

-- ============================================
-- 2. HOMOLOGAÇÃO DE PRODUTOS (The "Sourcing" Table)
-- ============================================
-- Liga uma lente "Virtual" (Marca Própria) a várias lentes "Reais" (Laboratórios)

CREATE TABLE IF NOT EXISTS lens_catalog.homologacao_marca_propria (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- A Lente "Face Cliente" (ex: BestLens Gold)
    lente_marca_propria_id UUID NOT NULL REFERENCES lens_catalog.lentes(id) ON DELETE CASCADE,
    
    -- A Lente "Face Laboratório" (ex: Lab A - Digital X)
    produto_lab_id UUID NOT NULL REFERENCES suppliers.produtos_laboratorio(id) ON DELETE CASCADE,
    
    -- Regras de Sourcing
    prioridade INTEGER DEFAULT 1, -- 1 = Preferido, 2 = Backup
    fator_qualidade NUMERIC(3,2) DEFAULT 1.0, -- Multiplicador de qualidade (se essa opção for tecnicamente superior/inferior)
    
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    
    -- Garante que o mesmo produto não é mapeado 2x para a mesma marca própria
    UNIQUE(lente_marca_propria_id, produto_lab_id)
);

CREATE INDEX idx_homologacao_busca ON lens_catalog.homologacao_marca_propria(lente_marca_propria_id) WHERE ativo = true;

-- ============================================
-- 3. VIEW: Sourcing Dinâmico
-- ============================================
-- Mostra todas as opções reais de compra para uma lente de marca própria

CREATE OR REPLACE VIEW lens_catalog.vw_opcoes_marca_propria AS
SELECT 
    h.lente_marca_propria_id as lente_virtual_id,
    l_virtual.nome_comercial as nome_virtual, -- Precisa garantir que a tabela lentes tenha nome_comercial ou usar familia/design
    
    h.produto_lab_id as produto_real_id,
    pl.nome_comercial as nome_real_laboratorio,
    pl.laboratorio_id,
    lab.nome_fantasia as nome_laboratorio,
    
    -- Preço de Custo (Busca o vigente)
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
LEFT JOIN logistics.tabela_prazos lp ON lp.laboratorio_id = lab.id -- Simplificado, idealmente filtra por região
WHERE h.ativo = true;
