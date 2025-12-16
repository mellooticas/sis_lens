-- Migration: Advanced Lens Structure & Integration
-- Data: 2025-12-09
-- Description: Adiciona suporte a grades de disponibilidade complexas e sistema de integração modular.

-- ============================================
-- 1. GRADES DE DISPONIBILIDADE (Range Rules)
-- ============================================
-- Permite definir faixas exatas de fabricação/estoque para cada lente.
-- Ex: "De -4.00 a +4.00 esférico, com cilíndrico até -2.00"

CREATE TABLE IF NOT EXISTS lens_catalog.grades_disponibilidade (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lente_id UUID NOT NULL REFERENCES lens_catalog.lentes(id) ON DELETE CASCADE,
    
    -- Definição do Retângulo de Disponibilidade
    esferico_min NUMERIC(4,2) NOT NULL,
    esferico_max NUMERIC(4,2) NOT NULL,
    cilindrico_min NUMERIC(4,2) NOT NULL DEFAULT 0, -- Geralmente 0
    cilindrico_max NUMERIC(4,2) NOT NULL, -- Geralmente negativo, ex: -6.00. Se for 0, não aceita cilíndrico.
    adicao_min NUMERIC(4,2) DEFAULT 0,
    adicao_max NUMERIC(4,2) DEFAULT 0,
    
    -- Parâmetros Físicos resultantes desta faixa (opcional, ajuda na escolha da armação)
    diametro_mm INTEGER, -- ex: 65, 70, 75, 80
    curva_base NUMERIC(4,2), -- Opcional: Curva base desta faixa
    
    -- Controle
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    
    -- Validações lógicas
    CONSTRAINT ck_grade_esferico CHECK (esferico_max >= esferico_min),
    CONSTRAINT ck_grade_cilindrico CHECK (cilindrico_min >= cilindrico_max), -- Cilíndrico é negativo, então 0 > -2
    CONSTRAINT ck_grade_adicao CHECK (adicao_max >= adicao_min)
);

-- Índice otimizado para busca de candidatos (Range Search)
CREATE INDEX idx_grades_busca ON lens_catalog.grades_disponibilidade (lente_id, esferico_min, esferico_max, cilindrico_min, cilindrico_max);

COMMENT ON TABLE lens_catalog.grades_disponibilidade IS 'Define faixas de dioptrias (graus) suportadas por cada lente.';

-- ============================================
-- 2. INTEGRAÇÃO MODULAR
-- ============================================
-- Estrutura para conversar com CRM e Vendas

CREATE SCHEMA IF NOT EXISTS integration;

-- Clientes autorizados a consumir a API do SIS Lens (Ex: App Vendas, App CRM)
CREATE TABLE IF NOT EXISTS integration.clientes_api (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT NOT NULL, -- ex: "PDV Loja Centro"
    api_key_hash TEXT NOT NULL, -- Hash da chave para autenticação
    webhook_url TEXT, -- Onde notificar mudanças
    tenant_id UUID REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Fila de eventos para Webhooks (Outbox Pattern)
CREATE TABLE IF NOT EXISTS integration.eventos_webhook (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_api_id UUID REFERENCES integration.clientes_api(id),
    decisao_id UUID REFERENCES orders.decisoes_lentes(id) ON DELETE SET NULL,
    tipo_evento TEXT NOT NULL, -- 'DECISAO_PRONTA', 'ERRO_CALCULO', 'STATUS_PEDIDO'
    payload JSONB NOT NULL, -- Dados a enviar
    status TEXT DEFAULT 'PENDENTE', -- PENDENTE, ENVIANDO, SUCESSO, FALHA, MORTO
    tentativas INTEGER DEFAULT 0,
    proxima_tentativa TIMESTAMPTZ DEFAULT NOW(),
    erro_log TEXT,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_webhook_status ON integration.eventos_webhook(status) WHERE status IN ('PENDENTE', 'FALHA');

-- Trigger para atualizar timestamp
CREATE TRIGGER tr_webhook_updated_at
    BEFORE UPDATE ON integration.eventos_webhook
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

-- ============================================
-- 3. FUNÇÃO HELPER: Verificar Disponibilidade
-- ============================================
-- Retorna true se a receita cabe em alguma grade da lente

CREATE OR REPLACE FUNCTION lens_catalog.verificar_disponibilidade(
    p_lente_id UUID,
    p_esferico NUMERIC,
    p_cilindrico NUMERIC,
    p_adicao NUMERIC DEFAULT 0
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM lens_catalog.grades_disponibilidade
        WHERE lente_id = p_lente_id
          AND ativo = true
          AND p_esferico BETWEEN esferico_min AND esferico_max
          -- Nota: Lógica de cilíndrico pode variar (soma transposta), aqui simplificado:
          AND p_cilindrico BETWEEN cilindrico_max AND cilindrico_min -- Lembrar: Cilíndrico é negativo (-2 > -4)
          AND p_adicao BETWEEN adicao_min AND adicao_max
    );
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION lens_catalog.verificar_disponibilidade IS 'Verifica se a receita se encaixa em alguma grade de fabricação da lente.';
