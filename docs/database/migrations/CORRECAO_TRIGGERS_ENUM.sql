-- ============================================
-- CORREÇÃO DOS TRIGGERS - EXECUTAR ANTES DO PASSO 2
-- ============================================
-- Este script corrige o erro de tipo ENUM e estrutura da tabela lentes_canonicas
-- Execute isso IMEDIATAMENTE se já rodou o PASSO 1

-- TRIGGER 2: Vincular canônica genérica (CORRIGIDO)
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

-- Verificar se corrigiu
SELECT 'Trigger fn_vincular_canonica corrigido com sucesso!' as status;
