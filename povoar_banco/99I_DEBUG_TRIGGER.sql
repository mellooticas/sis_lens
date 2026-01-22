-- ============================================================================
-- DEBUG: Por que o trigger não está criando grupos?
-- ============================================================================

-- 0. Verificar valores dos enums
SELECT 
  'tipo_lente' as enum_name,
  unnest(enum_range(NULL::lens_catalog.tipo_lente))::TEXT as valores
UNION ALL
SELECT 
  'material_lente' as enum_name,
  unnest(enum_range(NULL::lens_catalog.material_lente))::TEXT as valores
UNION ALL
SELECT 
  'indice_refracao' as enum_name,
  unnest(enum_range(NULL::lens_catalog.indice_refracao))::TEXT as valores
UNION ALL
SELECT 
  'categoria_lente' as enum_name,
  unnest(enum_range(NULL::lens_catalog.categoria_lente))::TEXT as valores
UNION ALL
SELECT 
  'tratamento_foto' as enum_name,
  unnest(enum_range(NULL::lens_catalog.tratamento_foto))::TEXT as valores;
| --------------- | ------------- |
| tipo_lente      | visao_simples |
| tipo_lente      | multifocal    |
| tipo_lente      | bifocal       |
| tipo_lente      | leitura       |
| tipo_lente      | ocupacional   |
| material_lente  | CR39          |
| material_lente  | POLICARBONATO |
| material_lente  | TRIVEX        |
| material_lente  | HIGH_INDEX    |
| material_lente  | VIDRO         |
| material_lente  | ACRILICO      |
| indice_refracao | 1.50          |
| indice_refracao | 1.56          |
| indice_refracao | 1.59          |
| indice_refracao | 1.61          |
| indice_refracao | 1.67          |
| indice_refracao | 1.74          |
| indice_refracao | 1.90          |
| categoria_lente | economica     |
| categoria_lente | intermediaria |
| categoria_lente | premium       |
| categoria_lente | super_premium |



-- 1. Testar a função encontrar_ou_criar_grupo_canonico com valores reais de uma lente
WITH lente_real AS (
  SELECT 
    tipo_lente,
    material,
    indice_refracao,
    categoria,
    esferico_min,
    esferico_max,
    cilindrico_min,
    cilindrico_max,
    adicao_min,
    adicao_max,
    COALESCE(ar, false) as ar,
    COALESCE(antirrisco, false) as antirrisco,
    COALESCE(uv400, false) as uv400,
    COALESCE(blue, false) as blue,
    CASE 
      WHEN fotossensivel IN ('transitions', 'xtractive', 'acclimates', 'sunsync', 'sensity') 
      THEN 'nenhum'::lens_catalog.tratamento_foto
      ELSE COALESCE(fotossensivel::lens_catalog.tratamento_foto, 'nenhum'::lens_catalog.tratamento_foto)
    END as fotossensivel
  FROM lens_catalog.lentes
  WHERE ativo = true
  LIMIT 1
)
SELECT 
  tipo_lente,
  material,
  indice_refracao,
  categoria,
  lens_catalog.encontrar_ou_criar_grupo_canonico(
    tipo_lente,
    material,
    indice_refracao,
    categoria,
    esferico_min,
    esferico_max,
    cilindrico_min,
    cilindrico_max,
    adicao_min,
    adicao_max,
    ar,
    antirrisco,
    uv400,
    blue,
    fotossensivel::lens_catalog.tratamento_foto
  ) as grupo_criado
FROM lente_real;

Error: Failed to run sql query: ERROR: 42883: operator does not exist: text = lens_catalog.tratamento_foto HINT: No operator matches the given name and argument types. You might need to add explicit type casts. QUERY: SELECT id FROM lens_catalog.grupos_canonicos WHERE tipo_lente = p_tipo_lente AND material = p_material AND indice_refracao = p_indice AND categoria_predominante = p_categoria AND grau_esferico_min = p_esferico_min AND grau_esferico_max = p_esferico_max AND grau_cilindrico_min = p_cilindrico_min AND grau_cilindrico_max = p_cilindrico_max AND COALESCE(adicao_min, 0) = COALESCE(p_adicao_min, 0) AND COALESCE(adicao_max, 0) = COALESCE(p_adicao_max, 0) AND tratamento_antirreflexo = p_tem_ar AND tratamento_antirrisco = p_tem_antirrisco AND tratamento_uv = p_tem_uv AND tratamento_blue_light = p_tem_blue AND COALESCE(tratamento_fotossensiveis, 'nenhum') = COALESCE(p_tratamento_foto, 'nenhum') LIMIT 1 CONTEXT: PL/pgSQL function lens_catalog.encontrar_ou_criar_grupo_canonico(lens_catalog.tipo_lente,lens_catalog.material_lente,lens_catalog.indice_refracao,lens_catalog.categoria_lente,numeric,numeric,numeric,numeric,numeric,numeric,boolean,boolean,boolean,boolean,lens_catalog.tratamento_foto) line 8 at SQL statement





-- 2. Ver se criou algum grupo
SELECT COUNT(*) as total_grupos_apos_teste
FROM lens_catalog.grupos_canonicos;

| total_grupos_apos_teste |
| ----------------------- |
| 0                       |



-- 3. Ver código completo da função encontrar_ou_criar_grupo_canonico
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'encontrar_ou_criar_grupo_canonico'
LIMIT 1;


| pg_get_functiondef                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CREATE OR REPLACE FUNCTION lens_catalog.encontrar_ou_criar_grupo_canonico(p_tipo_lente lens_catalog.tipo_lente, p_material lens_catalog.material_lente, p_indice lens_catalog.indice_refracao, p_categoria lens_catalog.categoria_lente, p_esferico_min numeric, p_esferico_max numeric, p_cilindrico_min numeric, p_cilindrico_max numeric, p_adicao_min numeric, p_adicao_max numeric, p_tem_ar boolean, p_tem_antirrisco boolean, p_tem_uv boolean, p_tem_blue boolean, p_tratamento_foto lens_catalog.tratamento_foto)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_grupo_id UUID;
  v_nome_grupo TEXT;
  v_slug TEXT;
BEGIN
  -- Buscar grupo existente com mesmas características
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
    AND COALESCE(tratamento_fotossensiveis, 'nenhum') = COALESCE(p_tratamento_foto, 'nenhum')
  LIMIT 1;
  
  -- Se não encontrou, criar novo grupo
  IF v_grupo_id IS NULL THEN
    -- Gerar nome descritivo
    v_nome_grupo := 'Lente ' || p_material || ' ' || p_indice || ' ' || 
                    REPLACE(INITCAP(p_tipo_lente::TEXT), '_', ' ');
    
    IF p_tem_ar THEN v_nome_grupo := v_nome_grupo || ' +AR'; END IF;
    IF p_tem_uv THEN v_nome_grupo := v_nome_grupo || ' +UV'; END IF;
    IF p_tem_blue THEN v_nome_grupo := v_nome_grupo || ' +BlueLight'; END IF;
    IF p_tratamento_foto IS NOT NULL AND p_tratamento_foto != 'nenhum' THEN 
      v_nome_grupo := v_nome_grupo || ' +' || INITCAP(p_tratamento_foto::TEXT);
    END IF;
    
    v_nome_grupo := v_nome_grupo || ' [' || 
                    p_esferico_min || '/' || p_esferico_max || ' | ' ||
                    p_cilindrico_min || '/' || p_cilindrico_max || ']';
    
    -- Gerar slug
    v_slug := LOWER(REGEXP_REPLACE(v_nome_grupo, '[^a-zA-Z0-9]+', '-', 'g'));
    v_slug := TRIM(BOTH '-' FROM v_slug);
    
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
      p_tem_ar, p_tem_antirrisco, p_tem_uv, p_tem_blue, p_tratamento_foto,
      0, 0, 0, 0, 0, -- estatísticas iniciais
      50, false, true -- peso padrão, não premium, ativo
    )
    RETURNING id INTO v_grupo_id;
    
    RAISE NOTICE 'Novo grupo canônico criado: % (ID: %)', v_nome_grupo, v_grupo_id;
  END IF;
  
  RETURN v_grupo_id;
END;
$function$
 |
 