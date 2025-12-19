-- ============================================
-- FUNÇÕES DE PRECIFICAÇÃO DINÂMICA
-- ============================================
-- Execute DEPOIS de popular as lentes
-- Adiciona cálculo automático de markup e preços
-- ============================================

-- ============================================
-- FUNÇÃO: Calcular Precificação Dinâmica
-- ============================================

CREATE OR REPLACE FUNCTION lens_catalog.calcular_precificacao()
RETURNS TRIGGER AS $$
DECLARE
    v_markup_base DECIMAL(5,2);
    v_faixa INTEGER;
BEGIN
    -- Só calcular se tiver custo_base
    IF NEW.custo_base IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Determinar faixa de custo (1 a 5)
    v_faixa := CASE
        WHEN NEW.custo_base < 200 THEN 1
        WHEN NEW.custo_base < 500 THEN 2
        WHEN NEW.custo_base < 1000 THEN 3
        WHEN NEW.custo_base < 2000 THEN 4
        ELSE 5
    END;
    
    -- Markup base por faixa (você pode ajustar esses valores)
    v_markup_base := CASE v_faixa
        WHEN 1 THEN 8.27  -- Produtos baratos: markup alto
        WHEN 2 THEN 4.41  -- Faixa média-baixa
        WHEN 3 THEN 4.20  -- Faixa média
        WHEN 4 THEN 4.09  -- Faixa média-alta
        ELSE 4.02         -- Produtos caros: markup menor
    END;
    
    -- Multiplicadores extras (você pode adicionar colunas na tabela se quiser)
    -- Por exemplo: markup_multiplicador_marca, markup_multiplicador_tratamento
    -- Por ora, vamos usar 1.0 (sem multiplicador)
    
    -- Calcular preço_tabela automaticamente
    -- Fórmula: custo_base * markup_base
    IF NEW.preco_tabela IS NULL OR NEW.preco_tabela = 0 THEN
        NEW.preco_tabela := ROUND(NEW.custo_base * v_markup_base, 2);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGER: Aplicar Precificação Automática
-- ============================================

DROP TRIGGER IF EXISTS trg_lentes_precificacao ON lens_catalog.lentes;
CREATE TRIGGER trg_lentes_precificacao
    BEFORE INSERT OR UPDATE OF custo_base
    ON lens_catalog.lentes
    FOR EACH ROW
    EXECUTE FUNCTION lens_catalog.calcular_precificacao();

-- ============================================
-- HISTÓRICO DE PREÇOS (Auditoria)
-- ============================================

CREATE TABLE IF NOT EXISTS lens_catalog.historico_precos_lente (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lente_id UUID NOT NULL REFERENCES lens_catalog.lentes(id) ON DELETE CASCADE,
    custo_antigo DECIMAL(10,2),
    custo_novo DECIMAL(10,2),
    preco_antigo DECIMAL(10,2),
    preco_novo DECIMAL(10,2),
    alterado_em TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    motivo TEXT
);

CREATE INDEX IF NOT EXISTS idx_historico_precos_lente 
ON lens_catalog.historico_precos_lente(lente_id, alterado_em DESC);

-- ============================================
-- FUNÇÃO: Log de Alterações de Preço
-- ============================================

CREATE OR REPLACE FUNCTION lens_catalog.log_alteracao_preco()
RETURNS TRIGGER AS $$
BEGIN
    -- Registrar alteração de custo ou preço
    IF NEW.custo_base IS DISTINCT FROM OLD.custo_base 
       OR NEW.preco_tabela IS DISTINCT FROM OLD.preco_tabela THEN
        
        INSERT INTO lens_catalog.historico_precos_lente (
            lente_id, 
            custo_antigo, 
            custo_novo,
            preco_antigo, 
            preco_novo
        ) VALUES (
            NEW.id, 
            OLD.custo_base, 
            NEW.custo_base,
            OLD.preco_tabela, 
            NEW.preco_tabela
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGER: Log de Alterações
-- ============================================

DROP TRIGGER IF EXISTS trg_lentes_log_preco ON lens_catalog.lentes;
CREATE TRIGGER trg_lentes_log_preco
    AFTER UPDATE ON lens_catalog.lentes
    FOR EACH ROW
    EXECUTE FUNCTION lens_catalog.log_alteracao_preco();

-- ============================================
-- VIEWS PARA ANÁLISE DE PREÇOS
-- ============================================

-- View: Análise de markup real vs esperado
CREATE OR REPLACE VIEW lens_catalog.vw_analise_markup AS
SELECT 
    l.id,
    l.sku_fornecedor,
    l.nome_comercial,
    l.custo_base,
    l.preco_tabela,
    ROUND((l.preco_tabela / NULLIF(l.custo_base, 0))::numeric, 2) as markup_real,
    CASE
        WHEN l.custo_base < 200 THEN 8.27
        WHEN l.custo_base < 500 THEN 4.41
        WHEN l.custo_base < 1000 THEN 4.20
        WHEN l.custo_base < 2000 THEN 4.09
        ELSE 4.02
    END as markup_esperado,
    ROUND(ABS((l.preco_tabela / NULLIF(l.custo_base, 0)) - 
        CASE
            WHEN l.custo_base < 200 THEN 8.27
            WHEN l.custo_base < 500 THEN 4.41
            WHEN l.custo_base < 1000 THEN 4.20
            WHEN l.custo_base < 2000 THEN 4.09
            ELSE 4.02
        END)::numeric, 2) as diferenca_markup,
    l.status
FROM lens_catalog.lentes l
WHERE l.custo_base > 0;

-- View: Histórico de alterações de preço
CREATE OR REPLACE VIEW lens_catalog.vw_historico_precos AS
SELECT 
    h.id,
    h.lente_id,
    l.sku_fornecedor,
    l.nome_comercial,
    h.custo_antigo,
    h.custo_novo,
    ROUND((h.custo_novo - h.custo_antigo)::numeric, 2) as variacao_custo,
    ROUND((((h.custo_novo - h.custo_antigo) / NULLIF(h.custo_antigo, 0)) * 100)::numeric, 2) as variacao_custo_percent,
    h.preco_antigo,
    h.preco_novo,
    ROUND((h.preco_novo - h.preco_antigo)::numeric, 2) as variacao_preco,
    ROUND((((h.preco_novo - h.preco_antigo) / NULLIF(h.preco_antigo, 0)) * 100)::numeric, 2) as variacao_preco_percent,
    h.alterado_em,
    h.motivo
FROM lens_catalog.historico_precos_lente h
JOIN lens_catalog.lentes l ON l.id = h.lente_id
ORDER BY h.alterado_em DESC;

-- ============================================
-- COMENTÁRIOS
-- ============================================

COMMENT ON FUNCTION lens_catalog.calcular_precificacao() IS 
'Calcula automaticamente o preço de tabela baseado no custo e markup dinâmico por faixa de preço';

COMMENT ON FUNCTION lens_catalog.log_alteracao_preco() IS 
'Registra todas as alterações de custo e preço para auditoria';

COMMENT ON TABLE lens_catalog.historico_precos_lente IS 
'Histórico completo de alterações de preços das lentes';

COMMENT ON VIEW lens_catalog.vw_analise_markup IS 
'Análise de markup aplicado vs esperado para cada lente';

COMMENT ON VIEW lens_catalog.vw_historico_precos IS 
'Histórico de alterações de preços com variações percentuais';

-- ============================================
-- TESTES
-- ============================================

-- Ver exemplo de cálculo de markup
SELECT 
    custo_base,
    markup_real,
    markup_esperado,
    diferenca_markup
FROM lens_catalog.vw_analise_markup
ORDER BY diferenca_markup DESC
LIMIT 10;

| custo_base | markup_real | markup_esperado | diferenca_markup |
| ---------- | ----------- | --------------- | ---------------- |
| 60.00      | 4.00        | 8.27            | 4.27             |
| 160.00     | 4.00        | 8.27            | 4.27             |
| 140.00     | 4.00        | 8.27            | 4.27             |
| 40.00      | 4.00        | 8.27            | 4.27             |
| 9.00       | 4.00        | 8.27            | 4.27             |
| 30.00      | 4.00        | 8.27            | 4.27             |
| 44.00      | 4.00        | 8.27            | 4.27             |
| 50.00      | 4.00        | 8.27            | 4.27             |
| 90.00      | 4.00        | 8.27            | 4.27             |
| 80.00      | 4.00        | 8.27            | 4.27             |



-- Ver lentes com markup fora do esperado (diferença > 0.5)
SELECT COUNT(*) as lentes_com_markup_divergente
FROM lens_catalog.vw_analise_markup
WHERE diferenca_markup > 0.5;


| lentes_com_markup_divergente |
| ---------------------------- |
| 254                          |