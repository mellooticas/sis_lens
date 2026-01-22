-- ============================================================================
-- PASSO 2: Criar trigger
-- ============================================================================

CREATE TRIGGER trg_lente_insert_update
  BEFORE INSERT OR UPDATE ON lens_catalog.lentes
  FOR EACH ROW
  EXECUTE FUNCTION lens_catalog.trigger_atualizar_grupo_canonico();

-- VALIDAR
SELECT 
  'PASSO 2: Trigger criado' as status,
  tgname as trigger_name,
  proname as function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE n.nspname = 'lens_catalog'
  AND c.relname = 'lentes'
  AND NOT t.tgisinternal;


| status                  | trigger_name             | function_name                         |
| ----------------------- | ------------------------ | ------------------------------------- |
| PASSO 2: Trigger criado | trg_lente_delete         | trigger_deletar_lente_atualizar_grupo |
| PASSO 2: Trigger criado | trg_lente_insert_update  | trigger_atualizar_grupo_canonico      |
| PASSO 2: Trigger criado | trg_lentes_generate_slug | generate_lente_slug                   |
| PASSO 2: Trigger criado | trg_lentes_updated_at    | update_lentes_timestamp               |

