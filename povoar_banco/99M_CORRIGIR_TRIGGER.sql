-- ============================================================================
-- CORRIGIR trigger_atualizar_grupo_canonico
-- ============================================================================
-- Problema: NEW.fotossensivel é TEXT mas função espera ENUM
-- Solução: Converter valores TEXT para ENUM válido
-- ============================================================================

CREATE OR REPLACE FUNCTION lens_catalog.trigger_atualizar_grupo_canonico()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_grupo_id UUID;
  v_grupo_antigo_id UUID;
  v_fotossensivel_enum lens_catalog.tratamento_foto;
BEGIN
  -- SEMPRE que grupo_canonico_id está NULL, encontrar ou criar
  IF NEW.grupo_canonico_id IS NULL THEN
    
    -- CONVERSÃO: TEXT -> ENUM
    -- Mapear valores TEXT do banco para valores ENUM válidos
    IF NEW.fotossensivel = 'fotocromático' THEN
      v_fotossensivel_enum := 'fotocromático'::lens_catalog.tratamento_foto;
    ELSIF NEW.fotossensivel IN ('transitions', 'xtractive', 'acclimates', 'sunsync', 'sensity', 'polarizado') THEN
      -- Marcas/tipos específicos de fotossensível -> 'fotocromático'
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
      v_fotossensivel_enum
    );
    
    -- Atualizar lente com o grupo encontrado/criado
    NEW.grupo_canonico_id := v_grupo_id;
    
    -- Atualizar estatísticas do novo grupo
    PERFORM lens_catalog.atualizar_estatisticas_grupo_canonico(v_grupo_id);
    
  -- Se grupo mudou em UPDATE, atualizar estatísticas do grupo antigo
  ELSIF TG_OP = 'UPDATE' AND OLD.grupo_canonico_id IS NOT NULL AND OLD.grupo_canonico_id != NEW.grupo_canonico_id THEN
    -- Guardar grupo antigo
    v_grupo_antigo_id := OLD.grupo_canonico_id;
    v_grupo_id := NEW.grupo_canonico_id;
    
    -- Atualizar estatísticas de ambos os grupos
    PERFORM lens_catalog.atualizar_estatisticas_grupo_canonico(v_grupo_antigo_id);
    PERFORM lens_catalog.atualizar_estatisticas_grupo_canonico(v_grupo_id);
  END IF;
  
  RETURN NEW;
END;
$$;

-- ============================================================================
-- TESTAR A FUNÇÃO CORRIGIDA
-- ============================================================================

-- Limpar grupos
DELETE FROM lens_catalog.grupos_canonicos;

-- Testar UPDATE em uma lente
DO $$
DECLARE
  v_lente_id UUID;
BEGIN
  SELECT id INTO v_lente_id
  FROM lens_catalog.lentes
  WHERE ativo = true
  LIMIT 1;
  
  RAISE NOTICE 'Testando lente: %', v_lente_id;
  
  UPDATE lens_catalog.lentes
  SET updated_at = NOW()
  WHERE id = v_lente_id;
END $$;

-- Verificar resultado
SELECT 
  'TESTE' as status,
  COUNT(*) as grupos_criados
FROM lens_catalog.grupos_canonicos;

| status | grupos_criados |
| ------ | -------------- |
| TESTE  | 1              |


SELECT 
  COUNT(*) as lentes_associadas
FROM lens_catalog.lentes
WHERE ativo = true
  AND grupo_canonico_id IS NOT NULL;


| lentes_associadas |
| ----------------- |
| 1                 |

