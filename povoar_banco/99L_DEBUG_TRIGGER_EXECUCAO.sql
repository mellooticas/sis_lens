-- ============================================================================
-- INVESTIGAR: Por que trigger não cria grupos?
-- ============================================================================

-- 1. Ver valores únicos de fotossensivel nas lentes
SELECT 
  fotossensivel,
  COUNT(*) as total
FROM lens_catalog.lentes
WHERE ativo = true
GROUP BY fotossensivel
ORDER BY total DESC;

| fotossensivel | total |
| ------------- | ----- |
| nenhum        | 1029  |
| transitions   | 238   |
| fotocromático | 81    |
| polarizado    | 60    |
| acclimates    | 3     |



-- 2. Verificar se trigger_atualizar_grupo_canonico tem algum problema
-- Testar UPDATE em uma lente específica com valores válidos
DO $$
DECLARE
  v_lente_id UUID;
BEGIN
  -- Pegar uma lente sem fotossensível
  SELECT id INTO v_lente_id
  FROM lens_catalog.lentes
  WHERE ativo = true
    AND (fotossensivel IS NULL OR fotossensivel = 'nenhum')
  LIMIT 1;
  
  RAISE NOTICE 'Testando UPDATE na lente: %', v_lente_id;
  
  -- Fazer UPDATE que deve disparar trigger
  UPDATE lens_catalog.lentes
  SET updated_at = NOW()
  WHERE id = v_lente_id;
  
  RAISE NOTICE 'UPDATE executado';
END $$;


Success. No rows returned






-- 3. Verificar se criou grupo
SELECT 
  'Após UPDATE de 1 lente' as status,
  COUNT(*) as grupos_criados
FROM lens_catalog.grupos_canonicos;


| status                 | grupos_criados |
| ---------------------- | -------------- |
| Após UPDATE de 1 lente | 0              |

-- 4. Ver se a lente foi associada
SELECT 
  l.id,
  l.nome,
  l.grupo_canonico_id,
  CASE WHEN l.grupo_canonico_id IS NULL THEN 'Órfã' ELSE 'Associada' END as status
FROM lens_catalog.lentes l
WHERE l.ativo = true
  AND (l.fotossensivel IS NULL OR l.fotossensivel = 'nenhum')
LIMIT 1;

Error: Failed to run sql query: ERROR: 42703: column l.nome does not exist LINE 5: l.nome, ^





-- 5. Ver se há algum erro sendo capturado silenciosamente
-- Verificar a função trigger_atualizar_grupo_canonico
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

 