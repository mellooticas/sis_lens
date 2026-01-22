-- Ver código da função fn_auditar_grupos
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'fn_auditar_grupos'
LIMIT 1;


| pg_get_functiondef                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| CREATE OR REPLACE FUNCTION lens_catalog.fn_auditar_grupos()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO lens_catalog.grupos_canonicos_log (
            grupo_id, operacao, campo_alterado, valor_antigo
        ) VALUES (
            OLD.id, 'DELETE', 'nome_grupo', OLD.nome_grupo
        );
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Registra apenas alterações relevantes
        IF OLD.total_lentes != NEW.total_lentes THEN
            INSERT INTO lens_catalog.grupos_canonicos_log (
                grupo_id, operacao, campo_alterado, valor_antigo, valor_novo
            ) VALUES (
                NEW.id, 'UPDATE', 'total_lentes', OLD.total_lentes::TEXT, NEW.total_lentes::TEXT
            );
        END IF;
        
        IF OLD.preco_medio != NEW.preco_medio OR (OLD.preco_medio IS NULL AND NEW.preco_medio IS NOT NULL) THEN
            INSERT INTO lens_catalog.grupos_canonicos_log (
                grupo_id, operacao, campo_alterado, valor_antigo, valor_novo
            ) VALUES (
                NEW.id, 'UPDATE', 'preco_medio', 
                COALESCE(OLD.preco_medio::TEXT, 'NULL'), 
                COALESCE(NEW.preco_medio::TEXT, 'NULL')
            );
        END IF;
        
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO lens_catalog.grupos_canonicos_log (
            grupo_id, operacao, campo_alterado, valor_novo
        ) VALUES (
            NEW.id, 'INSERT', 'nome_grupo', NEW.nome_grupo
        );
        RETURN NEW;
    END IF;
END;
$function$
 |
 