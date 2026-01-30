-- ============================================================================
-- LIMPEZA: Remover lentes antigas do fornecedor 'Express'
-- ============================================================================
-- Objetivo: Limpar o catálogo do laboratório Express para nova importação
-- Data: 30/01/2026
-- ============================================================================

BEGIN;

-- 1. Identificar o ID do fornecedor Express: 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c
DO $$ 
DECLARE 
    v_fornecedor_id UUID := '8eb9498c-3d99-4d26-bb8c-e503f97ccf2c';
    v_count_lentes INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count_lentes 
    FROM lens_catalog.lentes 
    WHERE fornecedor_id = v_fornecedor_id;

    RAISE NOTICE 'Removendo % lentes antigas do fornecedor Express...', v_count_lentes;

    -- Deletar as lentes (os triggers vão recalcular os grupos canônicos automaticamente)
    DELETE FROM lens_catalog.lentes 
    WHERE fornecedor_id = v_fornecedor_id;

    RAISE NOTICE 'Limpeza concluída com sucesso.';
END $$;

COMMIT; 
-- ROLLBACK; -- Use em caso de erro
 