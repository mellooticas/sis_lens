-- ============================================================================
-- INVESTIGAÇÃO: Por que os triggers não criaram grupos?
-- ============================================================================

-- 1. Verificar quais triggers estão REALMENTE ativos
SELECT 
  trigger_name,
  event_manipulation as evento,
  action_statement as funcao
FROM information_schema.triggers
WHERE trigger_schema = 'lens_catalog'
  AND event_object_table = 'lentes'
  AND trigger_name LIKE '%grupo%'
ORDER BY trigger_name;

| trigger_name              | evento | funcao                                                             |
| ------------------------- | ------ | ------------------------------------------------------------------ |
| trg_lentes_associar_grupo | INSERT | EXECUTE FUNCTION lens_catalog.fn_associar_lente_grupo_automatico() |
| trg_lentes_associar_grupo | UPDATE | EXECUTE FUNCTION lens_catalog.fn_associar_lente_grupo_automatico() |


-- 2. Ver o código da função que CRIA grupos
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



-- 3. Ver o código da função trigger_atualizar_grupo_canonico
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'trigger_atualizar_grupo_canonico'
LIMIT 1;

| pg_get_functiondef                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CREATE OR REPLACE FUNCTION lens_catalog.trigger_atualizar_grupo_canonico()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_grupo_id UUID;
  v_grupo_antigo_id UUID;
BEGIN
  -- Se está inserindo ou grupo mudou na atualização
  IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND OLD.grupo_canonico_id != NEW.grupo_canonico_id) THEN
    
    -- Guardar grupo antigo para atualizar depois (no UPDATE)
    IF TG_OP = 'UPDATE' THEN
      v_grupo_antigo_id := OLD.grupo_canonico_id;
    END IF;
    
    -- Se grupo_canonico_id está NULL, encontrar ou criar
    IF NEW.grupo_canonico_id IS NULL THEN
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
        COALESCE(NEW.fotossensivel, 'nenhum')
      );
      
      -- Atualizar lente com o grupo encontrado/criado
      NEW.grupo_canonico_id := v_grupo_id;
    ELSE
      v_grupo_id := NEW.grupo_canonico_id;
    END IF;
    
    -- Atualizar estatísticas do novo grupo
    PERFORM lens_catalog.atualizar_estatisticas_grupo_canonico(v_grupo_id);
    
    -- Se foi UPDATE e mudou de grupo, atualizar estatísticas do grupo antigo
    IF TG_OP = 'UPDATE' AND v_grupo_antigo_id IS NOT NULL AND v_grupo_antigo_id != v_grupo_id THEN
      PERFORM lens_catalog.atualizar_estatisticas_grupo_canonico(v_grupo_antigo_id);
    END IF;
  END IF;
  
  RETURN NEW;
END;
$function$
 |


-- 4. Verificar se a função existe
SELECT 
  n.nspname as schema,
  p.proname as funcao,
  pg_get_function_arguments(p.oid) as parametros
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'lens_catalog'
  AND (p.proname LIKE '%grupo%' OR p.proname LIKE '%canonic%')
ORDER BY p.proname;


| schema       | funcao                                | parametros                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------ | ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| lens_catalog | atualizar_estatisticas_grupo_canonico | p_grupo_id uuid                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| lens_catalog | atualizar_estatisticas_grupo_manual   | p_grupo_id uuid DEFAULT NULL::uuid                                                                                                                                                                                                                                                                                                                                                                                                              |
| lens_catalog | encontrar_ou_criar_grupo_canonico     | p_tipo_lente lens_catalog.tipo_lente, p_material lens_catalog.material_lente, p_indice lens_catalog.indice_refracao, p_categoria lens_catalog.categoria_lente, p_esferico_min numeric, p_esferico_max numeric, p_cilindrico_min numeric, p_cilindrico_max numeric, p_adicao_min numeric, p_adicao_max numeric, p_tem_ar boolean, p_tem_antirrisco boolean, p_tem_uv boolean, p_tem_blue boolean, p_tratamento_foto lens_catalog.tratamento_foto |
| lens_catalog | fn_associar_lente_grupo_automatico    |                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| lens_catalog | fn_atualizar_estatisticas_grupo       |                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| lens_catalog | fn_auditar_grupos                     |                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| lens_catalog | fn_criar_grupo_canonico_automatico    | p_tipo_lente text, p_material text, p_indice_refracao text, p_grau_esferico_min numeric, p_grau_esferico_max numeric, p_grau_cilindrico_min numeric, p_grau_cilindrico_max numeric, p_adicao_min numeric DEFAULT NULL::numeric, p_adicao_max numeric DEFAULT NULL::numeric                                                                                                                                                                      |
| lens_catalog | trigger_atualizar_grupo_canonico      |                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| lens_catalog | trigger_deletar_lente_atualizar_grupo |                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| lens_catalog | update_canonicas_timestamp            |                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| lens_catalog | update_grupos_timestamp               |                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| lens_catalog | validar_integridade_grupos            |                                                                                                                                                                                                                                                                                                                                                                                                                                                 |


