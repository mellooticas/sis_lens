-- ============================================================================
-- ARQUIVO FINAL: SISTEMA DE PRECIFICAÇÃO DINÂMICA (MARGEM ELÁSTICA)
-- ============================================================================
-- Objetivo: Implementar regra progressiva [Piso 250 | Topo 4x]
-- Data: 30/01/2026
-- ============================================================================

BEGIN;

-- 1. CRIAR SCHEMA COMERCIAL (CASO NÃO EXISTA)
CREATE SCHEMA IF NOT EXISTS commercial;

-- 2. TABELA DE CONFIGURAÇÃO DE MARKUP
-- Permite ajuste fino da curva sem mexer na função
CREATE TABLE IF NOT EXISTS commercial.markup_config (
    id SERIAL PRIMARY KEY,
    piso_venda_fixo NUMERIC(10,2) DEFAULT 216.26, -- Valor base para atingir R$ 250 nas lentes de custo ~R$ 8,50
    multiplicador_alvo NUMERIC(10,2) DEFAULT 4.0,   -- O markup que será atingido no final da curva
    ativo BOOLEAN DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir configuração inicial
INSERT INTO commercial.markup_config (piso_venda_fixo, multiplicador_alvo)
VALUES (216.26, 4.0)
ON CONFLICT DO NOTHING;

-- 3. FUNÇÃO DE CÁLCULO DINÂMICO
-- Aplica a fórmula: Venda = (Custo * Multiplicador) + Piso_Fixo
CREATE OR REPLACE FUNCTION lens_catalog.fn_calcular_preco_venda_dinamico()
RETURNS TRIGGER AS $$
DECLARE
    v_piso NUMERIC;
    v_mult NUMERIC;
    v_venda NUMERIC;
BEGIN
    -- Obter parâmetros ativos
    SELECT piso_venda_fixo, multiplicador_alvo INTO v_piso, v_mult 
    FROM commercial.markup_config 
    WHERE ativo = true 
    LIMIT 1;

    -- Fallback se a tabela estiver vazia
    IF v_piso IS NULL THEN v_piso := 216.26; v_mult := 4.0; END IF;

    -- Se custo for zero ou nulo, venda é zero
    IF NEW.preco_custo IS NULL OR NEW.preco_custo <= 0 THEN
        NEW.preco_tabela := 0;
        RETURN NEW;
    END IF;

    -- CÁLCULO DA CURVA PROGRESSIVA
    v_venda := (NEW.preco_custo * v_mult) + v_piso;

    -- Arredondamento para 2 casas decimais
    NEW.preco_tabela := ROUND(v_venda, 2);
    
    -- Sincronizar o preço sugerido para novos itens
    IF TG_OP = 'INSERT' OR NEW.preco_venda_sugerido = 0 THEN
        NEW.preco_venda_sugerido := NEW.preco_tabela;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. TRIGGER (GATILHO AUTOMÁTICO)
-- Roda antes de qualquer INSERT ou UPDATE na tabela de lentes
DROP TRIGGER IF EXISTS trg_calcular_preco_venda ON lens_catalog.lentes;
CREATE TRIGGER trg_calcular_preco_venda
    BEFORE INSERT OR UPDATE OF preco_custo ON lens_catalog.lentes
    FOR EACH ROW
    EXECUTE FUNCTION lens_catalog.fn_calcular_preco_venda_dinamico();

-- 5. ATUALIZAR TODO O CATÁLOGO EXISTENTE
-- Dispara o trigger para recalcular os preços de todas as lentes ativas
DO $$ 
BEGIN 
    RAISE NOTICE 'Iniciando atualização de preços de todo o catálogo...';
    UPDATE lens_catalog.lentes 
    SET preco_custo = preco_custo 
    WHERE ativo = true;
    RAISE NOTICE 'Atualização concluída com sucesso.';
END $$;

COMMIT; 


-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================
