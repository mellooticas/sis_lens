-- ============================================================================
-- LIMPEZA: Remover lentes do fornecedor 'So Blocos'
-- ============================================================================
-- Objetivo: Limpar o catálogo do laboratório So Blocos para nova importação
-- Data: 30/01/2026
-- ============================================================================

BEGIN;

-- 1. Identificar o ID do fornecedor (garantindo que estamos pegando o correto)
-- Baseado no diagnóstico: 4af04ba6-e600-4874-b8dc-45a2e1773725 (marca) 
-- e e1e1eace-11b4-4f26-9f15-620808a4a410 (fornecedor)

DO $$ 
DECLARE 
    v_fornecedor_id UUID := 'e1e1eace-11b4-4f26-9f15-620808a4a410';
    v_count_lentes INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count_lentes 
    FROM lens_catalog.lentes 
    WHERE fornecedor_id = v_fornecedor_id;

    RAISE NOTICE 'Removendo % lentes do fornecedor So Blocos...', v_count_lentes;

    -- Deletar as lentes (os triggers de atualização de grupos canônicos estão ativos e vão recalcular os grupos)
    DELETE FROM lens_catalog.lentes 
    WHERE fornecedor_id = v_fornecedor_id;

    RAISE NOTICE 'Limpeza concluída.';
END $$;

COMMIT; -- Alterado de ROLLBACK para COMMIT para efetivar a limpeza
-- ROLLBACK; -- Removido por segurança agora que confirmamos os dados
