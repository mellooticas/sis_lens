-- ============================================================================
-- SOLUÇÃO: Tornar encontrar_ou_criar_grupo_canonico robusta contra NULLs
-- ============================================================================
-- Se esférico ou cilíndrico forem NULL, a concatenação de strings falha.
-- ============================================================================

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
  p_tratamento_foto lens_catalog.tratamento_foto
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_grupo_id UUID;
  v_nome_grupo TEXT;
  v_slug TEXT;
  v_count INTEGER;
BEGIN
  -- Buscar grupo existente com mesmas características (usando COALESCE para numéricos)
  SELECT id INTO v_grupo_id
  FROM lens_catalog.grupos_canonicos
  WHERE tipo_lente = p_tipo_lente
    AND material = p_material
    AND indice_refracao = p_indice
    AND COALESCE(categoria_predominante, 'economica') = COALESCE(p_categoria, 'economica')
    AND COALESCE(grau_esferico_min, 0) = COALESCE(p_esferico_min, 0)
    AND COALESCE(grau_esferico_max, 0) = COALESCE(p_esferico_max, 0)
    AND COALESCE(grau_cilindrico_min, 0) = COALESCE(p_cilindrico_min, 0)
    AND COALESCE(grau_cilindrico_max, 0) = COALESCE(p_cilindrico_max, 0)
    AND COALESCE(adicao_min, 0) = COALESCE(p_adicao_min, 0)
    AND COALESCE(adicao_max, 0) = COALESCE(p_adicao_max, 0)
    AND tratamento_antirreflexo = p_tem_ar
    AND tratamento_antirrisco = p_tem_antirrisco
    AND tratamento_uv = p_tem_uv
    AND tratamento_blue_light = p_tem_blue
    AND COALESCE(tratamento_fotossensiveis, 'nenhum') = COALESCE(p_tratamento_foto::TEXT, 'nenhum')
  LIMIT 1;
  
  -- Se não encontrou, criar novo grupo
  IF v_grupo_id IS NULL THEN
    -- Gerar nome descritivo (Usando COALESCE para evitar NULL na concatenação)
    v_nome_grupo := 'Lente ' || COALESCE(p_material::TEXT, 'NR') || ' ' || COALESCE(p_indice::TEXT, '1.50') || ' ' || 
                    REPLACE(INITCAP(COALESCE(p_tipo_lente::TEXT, 'VS')), '_', ' ');
    
    IF p_tem_ar THEN v_nome_grupo := v_nome_grupo || ' +AR'; END IF;
    IF p_tem_uv THEN v_nome_grupo := v_nome_grupo || ' +UV'; END IF;
    IF p_tem_blue THEN v_nome_grupo := v_nome_grupo || ' +BlueLight'; END IF;
    IF p_tratamento_foto IS NOT NULL AND p_tratamento_foto != 'nenhum' THEN 
      v_nome_grupo := v_nome_grupo || ' +' || INITCAP(p_tratamento_foto::TEXT);
    END IF;
    
    v_nome_grupo := v_nome_grupo || ' [' || 
                    COALESCE(p_esferico_min, 0) || '/' || COALESCE(p_esferico_max, 0) || ' | ' ||
                    COALESCE(p_cilindrico_min, 0) || '/' || COALESCE(p_cilindrico_max, 0) || ']';
    
    -- Gerar slug
    v_slug := LOWER(REGEXP_REPLACE(v_nome_grupo, '[^a-zA-Z0-9]+', '-', 'g'));
    v_slug := TRIM(BOTH '-' FROM v_slug);
    
    -- Se slug colidir, adicionar sufixo aleatório
    SELECT COUNT(*) INTO v_count FROM lens_catalog.grupos_canonicos WHERE slug = v_slug;
    IF v_count > 0 THEN
       v_slug := v_slug || '-' || SUBSTR(gen_random_uuid()::TEXT, 1, 4);
    END IF;

    -- Inserir novo grupo
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
      50, false, true
    )
    RETURNING id INTO v_grupo_id;
  END IF;
  
  RETURN v_grupo_id;
END;
$$;
