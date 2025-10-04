-- ============================================================================
-- MIGRATION 001: SCHEMA INICIAL SISTEMA DECISOR DE LENTES
-- Criação das tabelas principais, views e RPCs
-- ============================================================================

-- Extensions necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. TABELAS PRINCIPAIS
-- ============================================================================

-- Marcas de lentes
CREATE TABLE marcas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome VARCHAR(100) NOT NULL,
  pais_origem VARCHAR(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Lentes (catálogo)
CREATE TABLE lentes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
  sku_canonico VARCHAR(100) NOT NULL UNIQUE,
  marca_id UUID REFERENCES marcas(id),
  familia VARCHAR(100) NOT NULL,
  design VARCHAR(100) NOT NULL,
  material VARCHAR(50) NOT NULL,
  indice_refracao DECIMAL(3,2) NOT NULL,
  tratamentos TEXT[] DEFAULT '{}',
  tipo_lente VARCHAR(20) CHECK (tipo_lente IN ('monofocal', 'bifocal', 'progressiva')),
  corredor_progressao INTEGER,
  specs_tecnicas JSONB DEFAULT '{}',
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Laboratórios/Fornecedores
CREATE TABLE laboratorios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
  nome VARCHAR(200) NOT NULL,
  cnpj VARCHAR(18) UNIQUE,
  endereco JSONB DEFAULT '{}',
  contato JSONB DEFAULT '{}',
  credibilidade_score INTEGER DEFAULT 50 CHECK (credibilidade_score >= 0 AND credibilidade_score <= 100),
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Produtos por laboratório
CREATE TABLE produtos_laboratorio (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
  laboratorio_id UUID REFERENCES laboratorios(id),
  lente_id UUID REFERENCES lentes(id),
  sku_fantasia VARCHAR(100) NOT NULL,
  nome_comercial VARCHAR(200) NOT NULL,
  preco_base DECIMAL(10,2) NOT NULL DEFAULT 0,
  prazo_producao_dias INTEGER DEFAULT 7,
  disponivel BOOLEAN DEFAULT true,
  descontinuado BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(laboratorio_id, sku_fantasia)
);

-- Decisões de compra
CREATE TABLE decisoes_compra (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
  lente_id UUID REFERENCES lentes(id),
  laboratorio_id UUID REFERENCES laboratorios(id),
  produto_lab_id UUID REFERENCES produtos_laboratorio(id),
  criterio VARCHAR(20) CHECK (criterio IN ('URGENCIA', 'NORMAL', 'ESPECIAL')),
  preco_final DECIMAL(10,2) NOT NULL,
  prazo_estimado_dias INTEGER NOT NULL,
  custo_frete DECIMAL(10,2) DEFAULT 0,
  score_atribuido INTEGER CHECK (score_atribuido >= 0 AND score_atribuido <= 100),
  motivo TEXT,
  alternativas_consideradas JSONB DEFAULT '[]',
  decidido_por UUID, -- user_id
  decidido_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  status VARCHAR(20) DEFAULT 'DECIDIDO' CHECK (status IN ('DECIDIDO', 'ENVIADO', 'CONFIRMADO', 'ENTREGUE')),
  payload_decisao JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 2. ÍNDICES PARA PERFORMANCE
-- ============================================================================

CREATE INDEX idx_lentes_tenant_ativo ON lentes(tenant_id, ativo);
CREATE INDEX idx_lentes_tipo_material ON lentes(tipo_lente, material);
CREATE INDEX idx_lentes_indice_refracao ON lentes(indice_refracao);
CREATE INDEX idx_lentes_marca ON lentes(marca_id);

CREATE INDEX idx_laboratorios_tenant_ativo ON laboratorios(tenant_id, ativo);
CREATE INDEX idx_laboratorios_credibilidade ON laboratorios(credibilidade_score DESC);

CREATE INDEX idx_produtos_lab_laboratorio ON produtos_laboratorio(laboratorio_id);
CREATE INDEX idx_produtos_lab_lente ON produtos_laboratorio(lente_id);
CREATE INDEX idx_produtos_lab_disponivel ON produtos_laboratorio(disponivel);

CREATE INDEX idx_decisoes_tenant_decidido ON decisoes_compra(tenant_id, decidido_em DESC);
CREATE INDEX idx_decisoes_criterio ON decisoes_compra(criterio);
CREATE INDEX idx_decisoes_status ON decisoes_compra(status);

-- ============================================================================
-- 3. VIEWS OTIMIZADAS
-- ============================================================================

-- View para catálogo de lentes com informações da marca
CREATE OR REPLACE VIEW vw_lentes_catalogo AS
SELECT 
  l.id AS lente_id,
  l.tenant_id,
  l.sku_canonico,
  l.familia,
  l.design,
  l.material,
  l.indice_refracao,
  l.tratamentos,
  l.tipo_lente,
  l.corredor_progressao,
  l.specs_tecnicas,
  l.ativo,
  m.nome AS marca_nome,
  m.pais_origem,
  CONCAT(m.nome, ' ', l.familia, ' ', l.design, ' ', l.indice_refracao) AS descricao_completa
FROM lentes l
LEFT JOIN marcas m ON l.marca_id = m.id
WHERE l.ativo = true;

-- View para fornecedores ativos
CREATE OR REPLACE VIEW vw_fornecedores AS
SELECT 
  l.id,
  l.tenant_id,
  l.nome,
  l.cnpj,
  l.endereco,
  l.contato,
  l.credibilidade_score,
  l.ativo,
  COUNT(pl.id) AS total_produtos,
  COUNT(CASE WHEN pl.disponivel = true THEN 1 END) AS produtos_disponiveis
FROM laboratorios l
LEFT JOIN produtos_laboratorio pl ON l.id = pl.laboratorio_id
WHERE l.ativo = true
GROUP BY l.id, l.tenant_id, l.nome, l.cnpj, l.endereco, l.contato, l.credibilidade_score, l.ativo;

-- ============================================================================
-- 4. FUNCTIONS/RPCs PRINCIPAIS
-- ============================================================================

-- RPC: Buscar lentes no catálogo
CREATE OR REPLACE FUNCTION rpc_buscar_lente(
  p_query TEXT,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE(
  lente_id UUID,
  label TEXT,
  sku_fantasia TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.lente_id,
    l.descricao_completa AS label,
    l.sku_canonico AS sku_fantasia
  FROM vw_lentes_catalogo l
  WHERE 
    l.descricao_completa ILIKE '%' || p_query || '%'
    OR l.sku_canonico ILIKE '%' || p_query || '%'
    OR l.familia ILIKE '%' || p_query || '%'
  ORDER BY 
    -- Priorizar matches exatos
    CASE WHEN l.sku_canonico ILIKE p_query THEN 1
         WHEN l.familia ILIKE p_query THEN 2
         ELSE 3 END,
    l.descricao_completa
  LIMIT p_limit;
END;
$$;

-- RPC: Gerar ranking de opções para uma lente
CREATE OR REPLACE FUNCTION rpc_rank_opcoes(
  p_lente_id UUID,
  p_criterio TEXT,
  p_filtros JSONB DEFAULT '{}'
)
RETURNS TABLE(
  laboratorio_id UUID,
  laboratorio_nome TEXT,
  sku_fantasia TEXT,
  preco_final DECIMAL,
  prazo_dias INTEGER,
  custo_frete DECIMAL,
  score_qualidade INTEGER,
  score_ponderado DECIMAL,
  rank_posicao INTEGER,
  justificativa TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
  preco_max DECIMAL;
  prazo_max INTEGER;
BEGIN
  -- Extrair filtros
  preco_max := COALESCE((p_filtros->>'preco_maximo')::DECIMAL, 999999);
  prazo_max := COALESCE((p_filtros->>'prazo_maximo_dias')::INTEGER, 365);
  
  RETURN QUERY
  WITH opcoes_base AS (
    SELECT 
      pl.laboratorio_id,
      l.nome AS laboratorio_nome,
      pl.sku_fantasia,
      pl.preco_base AS preco_final,
      pl.prazo_producao_dias AS prazo_dias,
      0::DECIMAL AS custo_frete, -- Temporário
      l.credibilidade_score AS score_qualidade,
      -- Score ponderado baseado no critério
      CASE 
        WHEN p_criterio = 'URGENCIA' THEN 
          (100 - pl.prazo_producao_dias * 2) * 0.7 + l.credibilidade_score * 0.3
        WHEN p_criterio = 'ESPECIAL' THEN 
          l.credibilidade_score * 0.8 + (100 - (pl.preco_base / 100)) * 0.2
        ELSE -- NORMAL
          l.credibilidade_score * 0.4 + 
          (100 - pl.prazo_producao_dias) * 0.3 + 
          (100 - (pl.preco_base / 50)) * 0.3
      END AS score_ponderado
    FROM produtos_laboratorio pl
    JOIN laboratorios l ON pl.laboratorio_id = l.id
    WHERE pl.lente_id = p_lente_id
      AND pl.disponivel = true
      AND l.ativo = true
      AND pl.preco_base <= preco_max
      AND pl.prazo_producao_dias <= prazo_max
  ),
  opcoes_rankeadas AS (
    SELECT 
      *,
      ROW_NUMBER() OVER (ORDER BY score_ponderado DESC, preco_final ASC) AS rank_posicao,
      CASE 
        WHEN p_criterio = 'URGENCIA' THEN 'Priorizado por urgência de entrega'
        WHEN p_criterio = 'ESPECIAL' THEN 'Priorizado por qualidade'
        ELSE 'Melhor custo-benefício'
      END AS justificativa
    FROM opcoes_base
  )
  SELECT * FROM opcoes_rankeadas
  ORDER BY rank_posicao
  LIMIT 10;
END;
$$;

-- RPC: Confirmar decisão de compra
CREATE OR REPLACE FUNCTION rpc_confirmar_decisao(
  p_payload JSONB
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  decisao_id UUID;
BEGIN
  INSERT INTO decisoes_compra (
    lente_id,
    laboratorio_id,
    produto_lab_id,
    criterio,
    preco_final,
    prazo_estimado_dias,
    custo_frete,
    score_atribuido,
    motivo,
    alternativas_consideradas,
    payload_decisao
  ) VALUES (
    (p_payload->>'lente_id')::UUID,
    (p_payload->>'laboratorio_id')::UUID,
    (p_payload->>'produto_lab_id')::UUID,
    p_payload->>'criterio',
    (p_payload->>'preco_final')::DECIMAL,
    (p_payload->>'prazo_estimado_dias')::INTEGER,
    COALESCE((p_payload->>'custo_frete')::DECIMAL, 0),
    (p_payload->>'score_atribuido')::INTEGER,
    p_payload->>'motivo',
    COALESCE(p_payload->'alternativas', '[]'::JSONB),
    p_payload
  ) RETURNING id INTO decisao_id;
  
  RETURN decisao_id;
END;
$$;

-- ============================================================================
-- 5. TRIGGERS PARA UPDATED_AT
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_marcas_updated_at BEFORE UPDATE ON marcas 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lentes_updated_at BEFORE UPDATE ON lentes 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_laboratorios_updated_at BEFORE UPDATE ON laboratorios 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_produtos_laboratorio_updated_at BEFORE UPDATE ON produtos_laboratorio 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_decisoes_compra_updated_at BEFORE UPDATE ON decisoes_compra 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 6. INSERIR DADOS DE EXEMPLO
-- ============================================================================

-- Marcas de exemplo
INSERT INTO marcas (nome, pais_origem) VALUES 
('Varilux', 'França'),
('Zeiss', 'Alemanha'),
('Hoya', 'Japão'),
('Kodak', 'EUA'),
('Transitions', 'EUA');

-- Lentes de exemplo
WITH marca_varilux AS (SELECT id FROM marcas WHERE nome = 'Varilux' LIMIT 1),
     marca_zeiss AS (SELECT id FROM marcas WHERE nome = 'Zeiss' LIMIT 1)
INSERT INTO lentes (marca_id, sku_canonico, familia, design, material, indice_refracao, tipo_lente, tratamentos) VALUES
((SELECT id FROM marca_varilux), 'VAR-X-167-AR', 'X Series', 'Digital', 'CR39', 1.67, 'progressiva', ARRAY['AR', 'HC']),
((SELECT id FROM marca_varilux), 'VAR-C-150-BAS', 'Comfort', 'Standard', 'CR39', 1.50, 'progressiva', ARRAY['Basic']),
((SELECT id FROM marca_zeiss), 'ZEI-SF-174-PREM', 'SmartFocus', 'Individual', 'Trivex', 1.74, 'progressiva', ARRAY['AR', 'HC', 'Blue']);

-- Laboratórios de exemplo
INSERT INTO laboratorios (nome, cnpj, credibilidade_score) VALUES
('Óticas São Paulo Ltda', '12.345.678/0001-90', 85),
('Lab Vision Pro', '98.765.432/0001-10', 92),
('Central das Lentes', '11.222.333/0001-44', 78);

-- Produtos por laboratório
WITH lente1 AS (SELECT id FROM lentes WHERE sku_canonico = 'VAR-X-167-AR' LIMIT 1),
     lente2 AS (SELECT id FROM lentes WHERE sku_canonico = 'VAR-C-150-BAS' LIMIT 1),
     lente3 AS (SELECT id FROM lentes WHERE sku_canonico = 'ZEI-SF-174-PREM' LIMIT 1),
     lab1 AS (SELECT id FROM laboratorios WHERE nome = 'Óticas São Paulo Ltda' LIMIT 1),
     lab2 AS (SELECT id FROM laboratorios WHERE nome = 'Lab Vision Pro' LIMIT 1),
     lab3 AS (SELECT id FROM laboratorios WHERE nome = 'Central das Lentes' LIMIT 1)
INSERT INTO produtos_laboratorio (laboratorio_id, lente_id, sku_fantasia, nome_comercial, preco_base, prazo_producao_dias) VALUES
((SELECT id FROM lab1), (SELECT id FROM lente1), 'VAR-X-PREMIUM', 'Varilux X Premium', 450.00, 5),
((SELECT id FROM lab2), (SELECT id FROM lente1), 'VARILUX-X-PRO', 'Varilux X Professional', 420.00, 3),
((SELECT id FROM lab1), (SELECT id FROM lente2), 'VAR-COMFORT-STD', 'Varilux Comfort Standard', 280.00, 7),
((SELECT id FROM lab3), (SELECT id FROM lente3), 'ZEISS-SMART-IND', 'Zeiss SmartFocus Individual', 650.00, 10);

COMMENT ON TABLE lentes IS 'Catálogo de lentes com especificações técnicas';
COMMENT ON TABLE laboratorios IS 'Fornecedores/laboratórios parceiros';
COMMENT ON TABLE produtos_laboratorio IS 'Produtos específicos oferecidos por cada laboratório';
COMMENT ON TABLE decisoes_compra IS 'Histórico de decisões de compra realizadas';

COMMENT ON FUNCTION rpc_buscar_lente IS 'Busca lentes no catálogo por texto livre';
COMMENT ON FUNCTION rpc_rank_opcoes IS 'Gera ranking de opções para uma lente específica';
COMMENT ON FUNCTION rpc_confirmar_decisao IS 'Registra uma decisão de compra no histórico';