-- ============================================
-- 03_TRIGGERS_CANONIZACAO.sql
-- Triggers para auto-canonização de lentes
-- ============================================
-- 
-- Executar DEPOIS de popular as lentes
-- Estas triggers criam/vinculam automaticamente grupos canônicos
-- ============================================

-- ============================================
-- FUNÇÃO: Atualizar estatísticas de canônica OU premium
-- ============================================

CREATE OR REPLACE FUNCTION lens_catalog.fn_atualizar_stats_canonica()
RETURNS TRIGGER AS $$
DECLARE
    v_canonica_id UUID;
    v_premium_id UUID;
BEGIN
    -- Determinar qual canônica foi afetada
    v_canonica_id := COALESCE(NEW.lente_canonica_id, OLD.lente_canonica_id);
    v_premium_id := COALESCE(NEW.premium_canonica_id, OLD.premium_canonica_id);
    
    -- Atualizar lentes_canonicas
    IF v_canonica_id IS NOT NULL THEN
        UPDATE lens_catalog.lentes_canonicas lc
        SET 
            total_lentes = (
                SELECT COUNT(*)
                FROM lens_catalog.lentes l
                WHERE l.lente_canonica_id = lc.id
                  AND l.status = 'ativo'
            ),
            preco_minimo = (
                SELECT MIN(preco_tabela)
                FROM lens_catalog.lentes l
                WHERE l.lente_canonica_id = lc.id
                  AND l.status = 'ativo'
            ),
            preco_maximo = (
                SELECT MAX(preco_tabela)
                FROM lens_catalog.lentes l
                WHERE l.lente_canonica_id = lc.id
                  AND l.status = 'ativo'
            ),
            preco_medio = (
                SELECT AVG(preco_tabela)
                FROM lens_catalog.lentes l
                WHERE l.lente_canonica_id = lc.id
                  AND l.status = 'ativo'
            ),
            updated_at = NOW()
        WHERE lc.id = v_canonica_id;
    END IF;
    
    -- Atualizar premium_canonicas
    IF v_premium_id IS NOT NULL THEN
        UPDATE lens_catalog.premium_canonicas pc
        SET 
            total_lentes = (
                SELECT COUNT(*)
                FROM lens_catalog.lentes l
                WHERE l.premium_canonica_id = pc.id
                  AND l.status = 'ativo'
            ),
            preco_minimo = (
                SELECT MIN(preco_tabela)
                FROM lens_catalog.lentes l
                WHERE l.premium_canonica_id = pc.id
                  AND l.status = 'ativo'
            ),
            preco_maximo = (
                SELECT MAX(preco_tabela)
                FROM lens_catalog.lentes l
                WHERE l.premium_canonica_id = pc.id
                  AND l.status = 'ativo'
            ),
            preco_medio = (
                SELECT AVG(preco_tabela)
                FROM lens_catalog.lentes l
                WHERE l.premium_canonica_id = pc.id
                  AND l.status = 'ativo'
            ),
            updated_at = NOW()
        WHERE pc.id = v_premium_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNÇÃO: Auto-vincular lente à canônica OU premium
-- ============================================

CREATE OR REPLACE FUNCTION lens_catalog.fn_vincular_canonica()
RETURNS TRIGGER AS $$
DECLARE
    v_canonica_id UUID;
    v_premium_id UUID;
    v_nome_canonico TEXT;
    v_is_premium BOOLEAN;
BEGIN
    -- Só processar lentes ativas
    IF NEW.status != 'ativo' THEN
        RETURN NEW;
    END IF;
    
    -- Verificar se a marca é premium
    SELECT is_premium INTO v_is_premium
    FROM lens_catalog.marcas
    WHERE id = NEW.marca_id;
    
    -- ============================================
    -- MARCAS PREMIUM → premium_canonicas
    -- ============================================
    IF v_is_premium = true THEN
        -- Criar nome canônico incluindo a marca
        SELECT nome INTO v_nome_canonico
        FROM lens_catalog.marcas
        WHERE id = NEW.marca_id;
        
        v_nome_canonico := v_nome_canonico || ' ' || NEW.tipo_lente || ' ' || NEW.material || ' ' || NEW.indice_refracao;
        
        -- Buscar premium canônica existente (mesma MARCA + características)
        SELECT id INTO v_premium_id
        FROM lens_catalog.premium_canonicas
        WHERE marca_id = NEW.marca_id
          AND tipo_lente = NEW.tipo_lente
          AND material = NEW.material
          AND indice_refracao = NEW.indice_refracao
          AND categoria = NEW.categoria
          AND ar = NEW.ar
          AND blue = NEW.blue
          AND fotossensivel = (NEW.fotossensivel != 'nenhum')
          AND polarizado = NEW.polarizado
        LIMIT 1;
        
        -- Se não encontrou, criar nova premium canônica
        IF v_premium_id IS NULL THEN
            INSERT INTO lens_catalog.premium_canonicas (
                nome_canonico,
                marca_id,
                tipo_lente,
                material,
                indice_refracao,
                categoria,
                ar,
                blue,
                fotossensivel,
                polarizado,
                esferico_min,
                esferico_max,
                cilindrico_min,
                cilindrico_max,
                adicao_min,
                adicao_max,
                ativo
            ) VALUES (
                v_nome_canonico,
                NEW.marca_id,
                NEW.tipo_lente,
                NEW.material,
                NEW.indice_refracao,
                NEW.categoria,
                NEW.ar,
                NEW.blue,
                (NEW.fotossensivel != 'nenhum'),
                NEW.polarizado,
                NEW.esferico_min,
                NEW.esferico_max,
                NEW.cilindrico_min,
                NEW.cilindrico_max,
                NEW.adicao_min,
                NEW.adicao_max,
                TRUE
            )
            RETURNING id INTO v_premium_id;
            
            RAISE NOTICE 'Nova PREMIUM canônica criada: % (ID: %)', v_nome_canonico, v_premium_id;
        ELSE
            -- Atualizar faixas ópticas se necessário
            UPDATE lens_catalog.premium_canonicas
            SET 
                esferico_min = LEAST(esferico_min, NEW.esferico_min),
                esferico_max = GREATEST(esferico_max, NEW.esferico_max),
                cilindrico_min = LEAST(cilindrico_min, NEW.cilindrico_min),
                cilindrico_max = GREATEST(cilindrico_max, NEW.cilindrico_max),
                adicao_min = LEAST(COALESCE(adicao_min, NEW.adicao_min), COALESCE(NEW.adicao_min, adicao_min)),
                adicao_max = GREATEST(COALESCE(adicao_max, NEW.adicao_max), COALESCE(NEW.adicao_max, adicao_max)),
                updated_at = NOW()
            WHERE id = v_premium_id;
        END IF;
        
        -- Vincular lente à premium canônica
        NEW.premium_canonica_id := v_premium_id;
        NEW.lente_canonica_id := NULL;
        
    -- ============================================
    -- MARCAS GENÉRICAS → lentes_canonicas
    -- ============================================
    ELSE
        -- Criar nome canônico SEM marca
        v_nome_canonico := NEW.tipo_lente || ' ' || NEW.material || ' ' || NEW.indice_refracao || ' ' || NEW.categoria;
        
        -- Buscar canônica existente (SEM considerar marca)
        SELECT id INTO v_canonica_id
        FROM lens_catalog.lentes_canonicas
        WHERE tipo_lente = NEW.tipo_lente
          AND material = NEW.material
          AND indice_refracao = NEW.indice_refracao
          AND categoria = NEW.categoria
          AND ar = NEW.ar
          AND blue = NEW.blue
          AND fotossensivel = (NEW.fotossensivel != 'nenhum')
          AND polarizado = NEW.polarizado
        LIMIT 1;
        
        -- Se não encontrou, criar nova canônica
        IF v_canonica_id IS NULL THEN
            INSERT INTO lens_catalog.lentes_canonicas (
                nome_canonico,
                tipo_lente,
                material,
                indice_refracao,
                categoria,
                ar,
                blue,
                fotossensivel,
                polarizado,
                esferico_min,
                esferico_max,
                cilindrico_min,
                cilindrico_max,
                adicao_min,
                adicao_max,
                ativo
            ) VALUES (
                v_nome_canonico,
                NEW.tipo_lente,
                NEW.material,
                NEW.indice_refracao,
                NEW.categoria,
                NEW.ar,
                NEW.blue,
                (NEW.fotossensivel != 'nenhum'),
                NEW.polarizado,
                NEW.esferico_min,
                NEW.esferico_max,
                NEW.cilindrico_min,
                NEW.cilindrico_max,
                NEW.adicao_min,
                NEW.adicao_max,
                TRUE
            )
            RETURNING id INTO v_canonica_id;
            
            RAISE NOTICE 'Nova canônica GENÉRICA criada: % (ID: %)', v_nome_canonico, v_canonica_id;
        ELSE
            -- Atualizar faixas ópticas se necessário
            UPDATE lens_catalog.lentes_canonicas
            SET 
                esferico_min = LEAST(esferico_min, NEW.esferico_min),
                esferico_max = GREATEST(esferico_max, NEW.esferico_max),
                cilindrico_min = LEAST(cilindrico_min, NEW.cilindrico_min),
                cilindrico_max = GREATEST(cilindrico_max, NEW.cilindrico_max),
                adicao_min = LEAST(COALESCE(adicao_min, NEW.adicao_min), COALESCE(NEW.adicao_min, adicao_min)),
                adicao_max = GREATEST(COALESCE(adicao_max, NEW.adicao_max), COALESCE(NEW.adicao_max, adicao_max)),
                updated_at = NOW()
            WHERE id = v_canonica_id;
        END IF;
        
        -- Vincular lente à canônica genérica
        NEW.lente_canonica_id := v_canonica_id;
        NEW.premium_canonica_id := NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CRIAR TRIGGERS
-- ============================================

-- Trigger para vincular lente à canônica ao inserir/atualizar
DROP TRIGGER IF EXISTS trg_vincular_canonica ON lens_catalog.lentes;
CREATE TRIGGER trg_vincular_canonica
    BEFORE INSERT OR UPDATE ON lens_catalog.lentes
    FOR EACH ROW
    EXECUTE FUNCTION lens_catalog.fn_vincular_canonica();

-- Trigger para atualizar estatísticas ao modificar lentes
DROP TRIGGER IF EXISTS trg_atualizar_stats_canonica ON lens_catalog.lentes;
CREATE TRIGGER trg_atualizar_stats_canonica
    AFTER INSERT OR UPDATE OR DELETE ON lens_catalog.lentes
    FOR EACH ROW
    EXECUTE FUNCTION lens_catalog.fn_atualizar_stats_canonica();

-- ============================================
-- ATUALIZAR LENTES EXISTENTES
-- ============================================

-- Forçar re-vinculação de todas as lentes existentes
UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE status = 'ativo';

-- ============================================
-- VERIFICAÇÃO
-- ============================================

-- Ver quantas canônicas GENÉRICAS foram criadas
SELECT 
    COUNT(*) as total_canonicas_genericas,
    SUM(total_lentes) as lentes_vinculadas
FROM lens_catalog.lentes_canonicas;

-- Ver quantas canônicas PREMIUM foram criadas
SELECT 
    COUNT(*) as total_canonicas_premium,
    SUM(total_lentes) as lentes_vinculadas
FROM lens_catalog.premium_canonicas;

-- Ver distribuição GENÉRICAS por categoria
SELECT 
    categoria,
    COUNT(*) as grupos,
    SUM(total_lentes) as lentes,
    ROUND(AVG(preco_medio)::numeric, 2) as preco_medio_geral
FROM lens_catalog.lentes_canonicas
GROUP BY categoria
ORDER BY categoria;

-- Ver distribuição PREMIUM por marca
SELECT 
    m.nome as marca,
    COUNT(*) as grupos_premium,
    SUM(pc.total_lentes) as lentes,
    ROUND(AVG(pc.preco_medio)::numeric, 2) as preco_medio
FROM lens_catalog.premium_canonicas pc
JOIN lens_catalog.marcas m ON m.id = pc.marca_id
GROUP BY m.nome
ORDER BY grupos_premium DESC;

-- Ver top 10 canônicas GENÉRICAS
SELECT 
    nome_canonico,
    categoria,
    total_lentes,
    ROUND(preco_minimo::numeric, 2) as preco_min,
    ROUND(preco_maximo::numeric, 2) as preco_max,
    ROUND(preco_medio::numeric, 2) as preco_medio
FROM lens_catalog.lentes_canonicas
ORDER BY total_lentes DESC
LIMIT 10;

-- Ver top 10 canônicas PREMIUM
SELECT 
    pc.nome_canonico,
    m.nome as marca,
    pc.total_lentes,
    ROUND(pc.preco_minimo::numeric, 2) as preco_min,
    ROUND(pc.preco_maximo::numeric, 2) as preco_max,
    ROUND(pc.preco_medio::numeric, 2) as preco_medio
FROM lens_catalog.premium_canonicas pc
JOIN lens_catalog.marcas m ON m.id = pc.marca_id
ORDER BY pc.total_lentes DESC
LIMIT 10;

-- Verificar lentes SEM vinculação (não deveria haver)
SELECT COUNT(*) as lentes_sem_canonica
FROM lens_catalog.lentes
WHERE lente_canonica_id IS NULL
  AND premium_canonica_id IS NULL
  AND status = 'ativo';

-- Resumo geral
SELECT 
    'Total Lentes' as metrica,
    COUNT(*) as valor
FROM lens_catalog.lentes
WHERE status = 'ativo'
UNION ALL
SELECT 
    'Lentes Genéricas',
    COUNT(*)
FROM lens_catalog.lentes
WHERE lente_canonica_id IS NOT NULL AND status = 'ativo'
UNION ALL
SELECT 
    'Lentes Premium',
    COUNT(*)
FROM lens_catalog.lentes
WHERE premium_canonica_id IS NOT NULL AND status = 'ativo'
UNION ALL
SELECT 
    'Canônicas Genéricas',
    COUNT(*)
FROM lens_catalog.lentes_canonicas
UNION ALL
SELECT 
    'Canônicas Premium',
    COUNT(*)
FROM lens_catalog.premium_canonicas;
