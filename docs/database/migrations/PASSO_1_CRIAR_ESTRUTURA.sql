-- ============================================
-- PLANO DE MIGRAÇÃO COMPLETO
-- ============================================
-- Executar em ORDEM para transformar o banco na arquitetura definitiva

-- ============================================
-- PARTE 1: CRIAR TABELA premium_canonicas
-- ============================================

CREATE TABLE IF NOT EXISTS lens_catalog.premium_canonicas (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id),
    sku_canonico_premium VARCHAR(100) NOT NULL,
    marca_id UUID NOT NULL REFERENCES lens_catalog.marcas(id),
    linha_produto TEXT NOT NULL,
    nome_base TEXT NOT NULL,
    tipo_lente tipo_lente NOT NULL,
    indice_refracao NUMERIC(3,2) NOT NULL,
    material material_lente NOT NULL,
    tratamentos_base tratamento_lente[],
    caracteristicas_hash TEXT NOT NULL,
    descricao TEXT,
    specs_tecnicas JSONB,
    ativo BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT premium_canonicas_pkey PRIMARY KEY (id),
    CONSTRAINT uk_premium_canon_tenant_sku UNIQUE (tenant_id, sku_canonico_premium),
    CONSTRAINT uk_premium_canon_hash UNIQUE (tenant_id, caracteristicas_hash)
);

CREATE INDEX idx_premium_canon_marca ON lens_catalog.premium_canonicas(marca_id);
CREATE INDEX idx_premium_canon_tipo ON lens_catalog.premium_canonicas(tipo_lente);
CREATE INDEX idx_premium_canon_tenant ON lens_catalog.premium_canonicas(tenant_id);

COMMENT ON TABLE lens_catalog.premium_canonicas IS 'Agrupamento inteligente de lentes premium - mesmo produto em múltiplos labs';

-- ============================================
-- PARTE 2: ADICIONAR COLUNAS EM lentes
-- ============================================

-- Verificar quais colunas já existem
DO $$
BEGIN
    -- sku_laboratorio
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema='lens_catalog' 
                   AND table_name='lentes' 
                   AND column_name='sku_laboratorio') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN sku_laboratorio VARCHAR(100);
    END IF;
    
    -- laboratorio_id
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema='lens_catalog' 
                   AND table_name='lentes' 
                   AND column_name='laboratorio_id') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN laboratorio_id UUID REFERENCES suppliers.laboratorios(id);
    END IF;
    
    -- nome_comercial
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema='lens_catalog' 
                   AND table_name='lentes' 
                   AND column_name='nome_comercial') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN nome_comercial TEXT;
    END IF;
    
    -- nivel_qualidade
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema='lens_catalog' 
                   AND table_name='lentes' 
                   AND column_name='nivel_qualidade') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN nivel_qualidade INTEGER DEFAULT 3;
    END IF;
    
    -- is_premium
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema='lens_catalog' 
                   AND table_name='lentes' 
                   AND column_name='is_premium') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN is_premium BOOLEAN DEFAULT FALSE;
    END IF;
    
    -- lente_canonica_id
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema='lens_catalog' 
                   AND table_name='lentes' 
                   AND column_name='lente_canonica_id') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN lente_canonica_id UUID REFERENCES lens_catalog.lentes_canonicas(id);
    END IF;
    
    -- premium_canonica_id
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema='lens_catalog' 
                   AND table_name='lentes' 
                   AND column_name='premium_canonica_id') THEN
        ALTER TABLE lens_catalog.lentes ADD COLUMN premium_canonica_id UUID REFERENCES lens_catalog.premium_canonicas(id);
    END IF;
END $$;

-- Adicionar constraints
ALTER TABLE lens_catalog.lentes 
DROP CONSTRAINT IF EXISTS check_lente_classificacao;

ALTER TABLE lens_catalog.lentes 
ADD CONSTRAINT check_lente_classificacao CHECK (
    (lente_canonica_id IS NOT NULL AND premium_canonica_id IS NULL) OR
    (lente_canonica_id IS NULL AND premium_canonica_id IS NOT NULL) OR
    (lente_canonica_id IS NULL AND premium_canonica_id IS NULL)
);

ALTER TABLE lens_catalog.lentes 
DROP CONSTRAINT IF EXISTS check_nivel_qualidade;

ALTER TABLE lens_catalog.lentes 
ADD CONSTRAINT check_nivel_qualidade CHECK (nivel_qualidade BETWEEN 1 AND 5);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_lentes_laboratorio ON lens_catalog.lentes(laboratorio_id);
CREATE INDEX IF NOT EXISTS idx_lentes_sku_lab ON lens_catalog.lentes(sku_laboratorio);
CREATE INDEX IF NOT EXISTS idx_lentes_canonica ON lens_catalog.lentes(lente_canonica_id);
CREATE INDEX IF NOT EXISTS idx_lentes_premium_canon ON lens_catalog.lentes(premium_canonica_id);
CREATE INDEX IF NOT EXISTS idx_lentes_is_premium ON lens_catalog.lentes(is_premium);
CREATE INDEX IF NOT EXISTS idx_lentes_nivel ON lens_catalog.lentes(nivel_qualidade);

-- Comentários
COMMENT ON COLUMN lens_catalog.lentes.sku_laboratorio IS 'Código do produto no laboratório (para fazer pedidos)';
COMMENT ON COLUMN lens_catalog.lentes.laboratorio_id IS 'Laboratório que vende esta lente';
COMMENT ON COLUMN lens_catalog.lentes.nivel_qualidade IS '1-3 = genérica | 4-5 = premium';
COMMENT ON COLUMN lens_catalog.lentes.is_premium IS 'Auto-preenchido pelo trigger';
COMMENT ON COLUMN lens_catalog.lentes.lente_canonica_id IS 'FK para lente genérica canônica (auto)';
COMMENT ON COLUMN lens_catalog.lentes.premium_canonica_id IS 'FK para lente premium canônica (auto)';

-- ============================================
-- PARTE 3: CRIAR TRIGGERS
-- ============================================

-- TRIGGER 1: Classificar lente
CREATE OR REPLACE FUNCTION lens_catalog.fn_classificar_lente()
RETURNS TRIGGER AS $$
BEGIN
    NEW.is_premium := (COALESCE(NEW.nivel_qualidade, 3) >= 4);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_classificar_lente ON lens_catalog.lentes;
CREATE TRIGGER trg_classificar_lente
BEFORE INSERT OR UPDATE OF nivel_qualidade ON lens_catalog.lentes
FOR EACH ROW
EXECUTE FUNCTION lens_catalog.fn_classificar_lente();

-- TRIGGER 2: Vincular canônica genérica
CREATE OR REPLACE FUNCTION lens_catalog.fn_vincular_canonica()
RETURNS TRIGGER AS $$
DECLARE
    v_canonica_id UUID;
    v_tem_ar BOOLEAN;
    v_tem_blue BOOLEAN;
    v_tem_hc BOOLEAN;
    v_tem_polar BOOLEAN;
    v_tem_foto BOOLEAN;
BEGIN
    IF NEW.is_premium = FALSE THEN
        -- Extrair tratamentos do array para flags booleanas
        v_tem_ar := 'AR' = ANY(NEW.tratamentos);
        v_tem_blue := 'BLUE' = ANY(NEW.tratamentos);
        v_tem_hc := 'HC' = ANY(NEW.tratamentos);
        v_tem_polar := 'POLAR' = ANY(NEW.tratamentos);
        v_tem_foto := 'FOTO' = ANY(NEW.tratamentos);
        
        -- Buscar canônica existente com as mesmas características
        SELECT id INTO v_canonica_id
        FROM lens_catalog.lentes_canonicas
        WHERE tenant_id = NEW.tenant_id
          AND tipo_lente = NEW.tipo_lente::text
          AND material = NEW.material::text
          AND indice_refracao = NEW.indice_refracao
          AND COALESCE(tem_ar, FALSE) = v_tem_ar
          AND COALESCE(tem_blue, FALSE) = v_tem_blue
          AND COALESCE(tem_hc, FALSE) = v_tem_hc
          AND COALESCE(tem_polarizado, FALSE) = v_tem_polar
          AND COALESCE(tem_fotossensivel, FALSE) = v_tem_foto
        LIMIT 1;
        
        IF v_canonica_id IS NULL THEN
            -- Criar nova canônica
            INSERT INTO lens_catalog.lentes_canonicas (
                tenant_id,
                sku_canonico,
                nome_comercial,
                linha_produto,
                tipo_lente,
                material,
                indice_refracao,
                categoria,
                tem_ar,
                tem_blue,
                tem_hc,
                tem_polarizado,
                tem_fotossensivel,
                tratamentos_detalhes,
                ativo
            ) VALUES (
                NEW.tenant_id,
                'CANON-GEN-' || SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8),
                COALESCE(NEW.familia, 'Genérica'),
                COALESCE(NEW.familia, 'Linha Genérica'),
                NEW.tipo_lente::text,
                NEW.material::text,
                NEW.indice_refracao,
                'SURFACADA',
                v_tem_ar,
                v_tem_blue,
                v_tem_hc,
                v_tem_polar,
                v_tem_foto,
                array_to_string(NEW.tratamentos, ', '),
                TRUE
            )
            RETURNING id INTO v_canonica_id;
        END IF;
        
        NEW.lente_canonica_id := v_canonica_id;
        NEW.premium_canonica_id := NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_vincular_canonica ON lens_catalog.lentes;
CREATE TRIGGER trg_vincular_canonica
BEFORE INSERT OR UPDATE ON lens_catalog.lentes
FOR EACH ROW
WHEN (NEW.is_premium = FALSE)
EXECUTE FUNCTION lens_catalog.fn_vincular_canonica();

-- TRIGGER 3: Vincular premium canônica
CREATE OR REPLACE FUNCTION lens_catalog.fn_vincular_premium_canonica()
RETURNS TRIGGER AS $$
DECLARE
    v_premium_canon_id UUID;
    v_hash TEXT;
BEGIN
    IF NEW.is_premium = TRUE THEN
        v_hash := MD5(
            COALESCE(NEW.marca_id::TEXT, '') ||
            COALESCE(NEW.familia, '') ||
            COALESCE(NEW.tipo_lente::TEXT, '') ||
            COALESCE(NEW.material::TEXT, '') ||
            COALESCE(NEW.indice_refracao::TEXT, '') ||
            COALESCE(array_to_string(NEW.tratamentos, ','), '')
        );
        
        SELECT id INTO v_premium_canon_id
        FROM lens_catalog.premium_canonicas
        WHERE tenant_id = NEW.tenant_id
          AND caracteristicas_hash = v_hash
        LIMIT 1;
        
        IF v_premium_canon_id IS NULL THEN
            INSERT INTO lens_catalog.premium_canonicas (
                tenant_id,
                sku_canonico_premium,
                marca_id,
                linha_produto,
                nome_base,
                tipo_lente,
                indice_refracao,
                material,
                tratamentos_base,
                caracteristicas_hash,
                ativo
            ) VALUES (
                NEW.tenant_id,
                'PREM-CANON-' || SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8),
                NEW.marca_id,
                COALESCE(NEW.familia, 'Premium'),
                COALESCE(NEW.nome_comercial, NEW.familia),
                NEW.tipo_lente,
                NEW.indice_refracao,
                NEW.material,
                NEW.tratamentos,
                v_hash,
                TRUE
            )
            RETURNING id INTO v_premium_canon_id;
        END IF;
        
        NEW.premium_canonica_id := v_premium_canon_id;
        NEW.lente_canonica_id := NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_vincular_premium_canonica ON lens_catalog.lentes;
CREATE TRIGGER trg_vincular_premium_canonica
BEFORE INSERT OR UPDATE ON lens_catalog.lentes
FOR EACH ROW
WHEN (NEW.is_premium = TRUE)
EXECUTE FUNCTION lens_catalog.fn_vincular_premium_canonica();

-- ============================================
-- VERIFICAÇÃO FINAL
-- ============================================

SELECT 'Estrutura criada com sucesso!' as status;
