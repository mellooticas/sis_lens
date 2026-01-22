-- ============================================================================
-- CORRIGIR CANONIZAÇÃO: Incluir is_premium como critério
-- ============================================================================

-- 1. Atualizar função para considerar is_premium
CREATE OR REPLACE FUNCTION lens_catalog.encontrar_ou_criar_grupo_canonico(
  p_tipo_lente lens_catalog.tipo_lente,
  p_material lens_catalog.material_lente,
  p_indice lens_catalog.indice_refracao,
  p_categoria lens_catalog.categoria_lente,
  p_esferico_min NUMERIC,
  p_esferico_max NUMERIC,
  p_cilindrico_min NUMERIC,
  p_cilindrico_max NUMERIC,
  p_adicao_min NUMERIC,
  p_adicao_max NUMERIC,
  p_tem_ar BOOLEAN,
  p_tem_antirrisco BOOLEAN,
  p_tem_uv BOOLEAN,
  p_tem_blue BOOLEAN,
  p_tratamento_foto lens_catalog.tratamento_foto,
  p_is_premium BOOLEAN  -- NOVO PARÂMETRO
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_grupo_id UUID;
  v_nome_grupo TEXT;
  v_slug TEXT;
BEGIN
  -- Buscar grupo existente INCLUINDO is_premium
  SELECT id INTO v_grupo_id
  FROM lens_catalog.grupos_canonicos
  WHERE tipo_lente = p_tipo_lente
    AND material = p_material
    AND indice_refracao = p_indice
    AND categoria_predominante = p_categoria
    AND grau_esferico_min = p_esferico_min
    AND grau_esferico_max = p_esferico_max
    AND grau_cilindrico_min = p_cilindrico_min
    AND grau_cilindrico_max = p_cilindrico_max
    AND COALESCE(adicao_min, 0) = COALESCE(p_adicao_min, 0)
    AND COALESCE(adicao_max, 0) = COALESCE(p_adicao_max, 0)
    AND tratamento_antirreflexo = p_tem_ar
    AND tratamento_antirrisco = p_tem_antirrisco
    AND tratamento_uv = p_tem_uv
    AND tratamento_blue_light = p_tem_blue
    AND COALESCE(tratamento_fotossensiveis, 'nenhum') = COALESCE(p_tratamento_foto::TEXT, 'nenhum')
    AND is_premium = p_is_premium  -- NOVA CONDIÇÃO
  LIMIT 1;
  
  IF v_grupo_id IS NOT NULL THEN
    UPDATE lens_catalog.grupos_canonicos
    SET ativo = true
    WHERE id = v_grupo_id AND ativo = false;
    
    RETURN v_grupo_id;
  END IF;
  
  -- Criar novo grupo
  v_nome_grupo := 'Lente ' || p_material || ' ' || p_indice || ' ' || 
                  REPLACE(INITCAP(p_tipo_lente::TEXT), '_', ' ');
  
  IF p_tem_ar THEN v_nome_grupo := v_nome_grupo || ' +AR'; END IF;
  IF p_tem_uv THEN v_nome_grupo := v_nome_grupo || ' +UV'; END IF;
  IF p_tem_blue THEN v_nome_grupo := v_nome_grupo || ' +BlueLight'; END IF;
  IF p_tratamento_foto IS NOT NULL AND p_tratamento_foto != 'nenhum' THEN 
    v_nome_grupo := v_nome_grupo || ' +' || INITCAP(p_tratamento_foto::TEXT);
  END IF;
  IF p_is_premium THEN v_nome_grupo := v_nome_grupo || ' [PREMIUM]'; END IF;  -- ADICIONAR INDICADOR
  
  v_nome_grupo := v_nome_grupo || ' [' || 
                  p_esferico_min || '/' || p_esferico_max || ' | ' ||
                  p_cilindrico_min || '/' || p_cilindrico_max || ']';
  
  v_slug := LOWER(REGEXP_REPLACE(v_nome_grupo, '[^a-zA-Z0-9]+', '-', 'g'));
  v_slug := TRIM(BOTH '-' FROM v_slug);
  
  BEGIN
    INSERT INTO lens_catalog.grupos_canonicos (
      slug, nome_grupo, tipo_lente, material, indice_refracao,
      categoria_predominante, grau_esferico_min, grau_esferico_max,
      grau_cilindrico_min, grau_cilindrico_max, adicao_min, adicao_max,
      tratamento_antirreflexo, tratamento_antirrisco, tratamento_uv,
      tratamento_blue_light, tratamento_fotossensiveis,
      preco_minimo, preco_maximo, preco_medio, total_lentes, total_marcas,
      peso, is_premium, ativo
    ) VALUES (
      v_slug, v_nome_grupo, p_tipo_lente, p_material, p_indice,
      p_categoria, p_esferico_min, p_esferico_max,
      p_cilindrico_min, p_cilindrico_max, p_adicao_min, p_adicao_max,
      p_tem_ar, p_tem_antirrisco, p_tem_uv, p_tem_blue, p_tratamento_foto::TEXT,
      0, 0, 0, 0, 0,
      50, p_is_premium, true  -- USAR p_is_premium
    )
    RETURNING id INTO v_grupo_id;
  EXCEPTION WHEN unique_violation THEN
    SELECT id INTO v_grupo_id
    FROM lens_catalog.grupos_canonicos
    WHERE nome_grupo = v_nome_grupo OR slug = v_slug
    LIMIT 1;
    
    UPDATE lens_catalog.grupos_canonicos
    SET ativo = true
    WHERE id = v_grupo_id AND ativo = false;
  END;
  
  RETURN v_grupo_id;
END;
$$;

-- 2. Atualizar trigger para passar is_premium DA MARCA
CREATE OR REPLACE FUNCTION lens_catalog.trigger_atualizar_grupo_canonico()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_grupo_id UUID;
  v_grupo_antigo_id UUID;
  v_fotossensivel_enum lens_catalog.tratamento_foto;
  v_marca_is_premium BOOLEAN;
BEGIN
  IF NEW.grupo_canonico_id IS NULL THEN
    
    -- Buscar is_premium da marca
    SELECT is_premium INTO v_marca_is_premium
    FROM lens_catalog.marcas
    WHERE id = NEW.marca_id;
    
    IF NEW.fotossensivel = 'fotocromático' THEN
      v_fotossensivel_enum := 'fotocromático'::lens_catalog.tratamento_foto;
    ELSIF NEW.fotossensivel IN ('transitions', 'xtractive', 'acclimates', 'sunsync', 'sensity', 'polarizado') THEN
      v_fotossensivel_enum := 'fotocromático'::lens_catalog.tratamento_foto;
    ELSE
      v_fotossensivel_enum := 'nenhum'::lens_catalog.tratamento_foto;
    END IF;
    
    v_grupo_id := lens_catalog.encontrar_ou_criar_grupo_canonico(
      NEW.tipo_lente,
      NEW.material,
      NEW.indice_refracao,
      NEW.categoria,
      NEW.esferico_min,
      NEW.esferico_max,
      NEW.cilindrico_min,
      NEW.cilindrico_max,
      NEW.adicao_min,
      NEW.adicao_max,
      COALESCE(NEW.ar, false),
      COALESCE(NEW.antirrisco, false),
      COALESCE(NEW.uv400, false),
      COALESCE(NEW.blue, false),
      v_fotossensivel_enum,
      COALESCE(v_marca_is_premium, false)  -- PASSAR is_premium da marca
    );
    
    NEW.grupo_canonico_id := v_grupo_id;
    PERFORM lens_catalog.atualizar_estatisticas_grupo_canonico(v_grupo_id);
    
  ELSIF TG_OP = 'UPDATE' AND OLD.grupo_canonico_id IS NOT NULL AND OLD.grupo_canonico_id != NEW.grupo_canonico_id THEN
    v_grupo_antigo_id := OLD.grupo_canonico_id;
    v_grupo_id := NEW.grupo_canonico_id;
    
    PERFORM lens_catalog.atualizar_estatisticas_grupo_canonico(v_grupo_antigo_id);
    PERFORM lens_catalog.atualizar_estatisticas_grupo_canonico(v_grupo_id);
  END IF;
  
  RETURN NEW;
END;
$$;
