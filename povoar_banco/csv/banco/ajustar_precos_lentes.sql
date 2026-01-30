-- ============================================================================
-- SCRIPT DE AJUSTE: CORREÇÃO DE PREÇOS DE LENTES DE CONTATO
-- ============================================================================
-- Objetivo: Identificar produtos onde Preço Tabela = Preço Custo (ou Tabela vazio)
-- e mover o valor original para Custo, aplicando Markup de 2.2x no Preço Tabela.
-- ============================================================================

BEGIN;

-- 1. Backup temporário para segurança (opcional, apenas para logica)
-- (Não necessário em transação, basta update)

-- 2. Atualizar registros onde o Preco Custo está zerado mas o Tabela tem valor
-- (Assumindo que a importação jogou o custo no tabela)
UPDATE contact_lens.lentes
SET 
    preco_custo = preco_tabela, -- Move o valor atual para custo
    preco_tabela = ROUND((preco_tabela * 2.2)::numeric, 2) -- Aplica Markup 120%
WHERE 
    (preco_custo IS NULL OR preco_custo = 0) -- Não tem custo definido
    AND preco_tabela > 0; -- Mas tem preço tabela definido

-- 3. Atualizar registros onde Custo e Tabela são iguais
UPDATE contact_lens.lentes
SET 
    preco_tabela = ROUND((preco_custo * 2.2)::numeric, 2)
WHERE 
    preco_custo > 0 
    AND preco_tabela = preco_custo;

-- 4. Verifica resultados (apenas para debug manual, não afeta execução)
-- SELECT count(*) FROM contact_lens.lentes WHERE preco_tabela > preco_custo;

COMMIT;
