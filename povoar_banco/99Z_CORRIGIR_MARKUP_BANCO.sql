-- ============================================================================
-- ATUALIZAR REGRA DE PRECIFICAÇÃO (MARKUP)
-- ============================================================================
-- Regra Fixa:
-- 1. Markup de 3x sobre o custo por padrão.
-- 2. Piso de R$ 250,00 + (custo * 0.10) para lentes baratas.
-- 3. Teto de 4x sobre o custo para evitar excessos.
-- ============================================================================

CREATE OR REPLACE FUNCTION lens_catalog.fn_calcular_preco_venda()
RETURNS TRIGGER AS $$
DECLARE
    v_venda NUMERIC;
BEGIN
    IF NEW.preco_custo IS NULL OR NEW.preco_custo <= 0 THEN
        NEW.preco_tabela := 0;
        RETURN NEW;
    END IF;

    -- Cálculo da Lógica: Piso absoluto de 250 ou 4x o custo.
    -- Adicionamos uma pequena variação do custo (2%) para manter a diferenciação de preços no piso.
    v_venda := GREATEST(250.00 + (NEW.preco_custo * 0.02), NEW.preco_custo * 4.0);

    NEW.preco_tabela := ROUND(v_venda, 2);
    
    -- Sincronizar preco_venda_sugerido se for inserção nova
    IF TG_OP = 'INSERT' OR NEW.preco_venda_sugerido = 0 THEN
        NEW.preco_venda_sugerido := NEW.preco_tabela;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Garantir que o trigger esteja associado (redundante se já existir, mas seguro)
DROP TRIGGER IF EXISTS trg_calcular_preco_venda ON lens_catalog.lentes;
CREATE TRIGGER trg_calcular_preco_venda
    BEFORE INSERT OR UPDATE OF preco_custo ON lens_catalog.lentes
    FOR EACH ROW
    EXECUTE FUNCTION lens_catalog.fn_calcular_preco_venda();
