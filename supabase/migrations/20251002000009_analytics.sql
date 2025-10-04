-- Migration: 009_analytics.sql
-- Schema analytics: Sistema de relatórios e análises

-- ============================================
-- TABELA: relatorios_configuracao
-- ============================================
CREATE TABLE analytics.relatorios_configuracao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    descricao TEXT,
    categoria TEXT NOT NULL,
    tipo_relatorio TEXT NOT NULL,
    
    -- Configuração da Query
    query_base TEXT NOT NULL,
    parametros_disponiveis JSONB DEFAULT '[]',
    filtros_padrao JSONB DEFAULT '{}',
    agrupamentos JSONB DEFAULT '[]',
    
    -- Configuração de Exibição
    colunas_visiveis JSONB NOT NULL DEFAULT '[]',
    ordenacao_padrao JSONB DEFAULT '[]',
    formato_dados JSONB DEFAULT '{}',
    graficos_config JSONB DEFAULT '{}',
    
    -- Permissões e Acesso
    publico BOOLEAN NOT NULL DEFAULT false,
    roles_acesso TEXT[] DEFAULT '{}',
    nivel_permissao TEXT NOT NULL DEFAULT 'USER',
    
    -- Agendamento
    agendamento_ativo BOOLEAN NOT NULL DEFAULT false,
    cronograma TEXT,
    destinatarios TEXT[] DEFAULT '{}',
    formato_envio TEXT DEFAULT 'PDF',
    
    -- Controle
    ativo BOOLEAN NOT NULL DEFAULT true,
    versao INTEGER NOT NULL DEFAULT 1,
    criado_por UUID,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, nome),
    CHECK (categoria IN ('VENDAS', 'OPERACIONAL', 'FINANCEIRO', 'QUALIDADE', 'LABORATORIOS', 'CLIENTES')),
    CHECK (tipo_relatorio IN ('TABULAR', 'GRAFICO', 'DASHBOARD', 'KPI', 'ANALITICO')),
    CHECK (nivel_permissao IN ('USER', 'MANAGER', 'ADMIN', 'OWNER')),
    CHECK (formato_envio IN ('PDF', 'EXCEL', 'CSV', 'EMAIL_HTML')),
    CHECK (versao > 0)
);

-- Índices
CREATE INDEX idx_relatorios_tenant ON analytics.relatorios_configuracao(tenant_id);
CREATE INDEX idx_relatorios_categoria ON analytics.relatorios_configuracao(categoria);
CREATE INDEX idx_relatorios_tipo ON analytics.relatorios_configuracao(tipo_relatorio);
CREATE INDEX idx_relatorios_ativo ON analytics.relatorios_configuracao(ativo);
CREATE INDEX idx_relatorios_publico ON analytics.relatorios_configuracao(publico);
CREATE INDEX idx_relatorios_agendamento ON analytics.relatorios_configuracao(agendamento_ativo);

-- ============================================
-- TABELA: execucoes_relatorios
-- ============================================
CREATE TABLE analytics.execucoes_relatorios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    relatorio_id UUID NOT NULL REFERENCES analytics.relatorios_configuracao(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    
    -- Execução
    executado_por UUID,
    executado_por_nome TEXT,
    tipo_execucao TEXT NOT NULL DEFAULT 'MANUAL',
    parametros_utilizados JSONB DEFAULT '{}',
    
    -- Resultado
    status TEXT NOT NULL DEFAULT 'EXECUTANDO',
    total_registros INTEGER,
    tempo_execucao_ms INTEGER,
    tamanho_resultado_kb NUMERIC(10,2),
    erro_detalhes TEXT,
    
    -- Dados do Resultado
    resultado_dados JSONB,
    resultado_resumo JSONB,
    resultado_url TEXT,
    
    -- Cache
    cache_key TEXT,
    cache_valido_ate TIMESTAMPTZ,
    
    -- Timestamps
    iniciado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finalizado_em TIMESTAMPTZ,
    
    CHECK (tipo_execucao IN ('MANUAL', 'AGENDADO', 'API', 'DASHBOARD')),
    CHECK (status IN ('EXECUTANDO', 'SUCESSO', 'ERRO', 'CANCELADO', 'TIMEOUT')),
    CHECK (total_registros IS NULL OR total_registros >= 0),
    CHECK (tempo_execucao_ms IS NULL OR tempo_execucao_ms >= 0),
    CHECK (tamanho_resultado_kb IS NULL OR tamanho_resultado_kb >= 0)
);

-- Índices
CREATE INDEX idx_execucoes_relatorio ON analytics.execucoes_relatorios(relatorio_id);
CREATE INDEX idx_execucoes_tenant ON analytics.execucoes_relatorios(tenant_id);
CREATE INDEX idx_execucoes_status ON analytics.execucoes_relatorios(status);
CREATE INDEX idx_execucoes_tipo ON analytics.execucoes_relatorios(tipo_execucao);
CREATE INDEX idx_execucoes_data ON analytics.execucoes_relatorios(iniciado_em);
CREATE INDEX idx_execucoes_cache ON analytics.execucoes_relatorios(cache_key);
CREATE INDEX idx_execucoes_cache_validade ON analytics.execucoes_relatorios(cache_valido_ate);

-- ============================================
-- TABELA: metricas_kpi
-- ============================================
CREATE TABLE analytics.metricas_kpi (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    descricao TEXT,
    categoria TEXT NOT NULL,
    
    -- Configuração da Métrica
    query_calculo TEXT NOT NULL,
    unidade TEXT NOT NULL DEFAULT 'unidade',
    formato_exibicao TEXT NOT NULL DEFAULT 'numero',
    meta_valor NUMERIC(15,2),
    meta_tipo TEXT DEFAULT 'MAIOR_MELHOR',
    
    -- Periodicidade
    frequencia_calculo TEXT NOT NULL DEFAULT 'DIARIO',
    periodo_referencia INTEGER NOT NULL DEFAULT 30,
    
    -- Alertas
    alerta_ativo BOOLEAN NOT NULL DEFAULT false,
    limite_critico NUMERIC(15,2),
    limite_atencao NUMERIC(15,2),
    
    -- Configuração
    ativo BOOLEAN NOT NULL DEFAULT true,
    ordem_dashboard INTEGER DEFAULT 1,
    cor_display TEXT DEFAULT '#3B82F6',
    icone TEXT,
    
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(tenant_id, nome),
    CHECK (categoria IN ('VENDAS', 'OPERACIONAL', 'FINANCEIRO', 'QUALIDADE', 'SATISFACAO')),
    CHECK (formato_exibicao IN ('numero', 'percentual', 'moeda', 'tempo', 'texto')),
    CHECK (meta_tipo IN ('MAIOR_MELHOR', 'MENOR_MELHOR', 'EXATO', 'FAIXA')),
    CHECK (frequencia_calculo IN ('TEMPO_REAL', 'HORARIO', 'DIARIO', 'SEMANAL', 'MENSAL')),
    CHECK (periodo_referencia > 0),
    CHECK (ordem_dashboard > 0)
);

-- Índices
CREATE INDEX idx_kpi_tenant ON analytics.metricas_kpi(tenant_id);
CREATE INDEX idx_kpi_categoria ON analytics.metricas_kpi(categoria);
CREATE INDEX idx_kpi_ativo ON analytics.metricas_kpi(ativo);
CREATE INDEX idx_kpi_frequencia ON analytics.metricas_kpi(frequencia_calculo);
CREATE INDEX idx_kpi_ordem ON analytics.metricas_kpi(ordem_dashboard);

-- ============================================
-- TABELA: valores_kpi
-- ============================================
CREATE TABLE analytics.valores_kpi (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kpi_id UUID NOT NULL REFERENCES analytics.metricas_kpi(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    
    -- Valor e Contexto
    valor NUMERIC(15,4) NOT NULL,
    valor_anterior NUMERIC(15,4),
    variacao NUMERIC(15,4) GENERATED ALWAYS AS (valor - COALESCE(valor_anterior, valor)) STORED,
    variacao_percentual NUMERIC(8,2),
    
    -- Período
    data_referencia DATE NOT NULL,
    periodo_inicio TIMESTAMPTZ NOT NULL,
    periodo_fim TIMESTAMPTZ NOT NULL,
    
    -- Avaliação
    status_meta TEXT,
    status_alerta TEXT DEFAULT 'OK',
    observacoes TEXT,
    
    -- Contexto Adicional
    detalhes_calculo JSONB,
    fatores_influencia TEXT[],
    
    calculado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(kpi_id, data_referencia),
    CHECK (status_meta IN ('ATINGIDA', 'NAO_ATINGIDA', 'SUPERADA', 'SEM_META')),
    CHECK (status_alerta IN ('OK', 'ATENCAO', 'CRITICO')),
    CHECK (periodo_fim > periodo_inicio)
);

-- Índices
CREATE INDEX idx_valores_kpi ON analytics.valores_kpi(kpi_id);
CREATE INDEX idx_valores_tenant ON analytics.valores_kpi(tenant_id);
CREATE INDEX idx_valores_data ON analytics.valores_kpi(data_referencia);
CREATE INDEX idx_valores_status ON analytics.valores_kpi(status_alerta);
CREATE INDEX idx_valores_calculado ON analytics.valores_kpi(calculado_em);

-- ============================================
-- TABELA: alertas_analytics
-- ============================================
CREATE TABLE analytics.alertas_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id) ON DELETE CASCADE,
    tipo_alerta TEXT NOT NULL,
    origem_id UUID,
    origem_tipo TEXT NOT NULL,
    
    -- Conteúdo do Alerta
    titulo TEXT NOT NULL,
    descricao TEXT,
    severidade TEXT NOT NULL DEFAULT 'INFO',
    dados_contexto JSONB DEFAULT '{}',
    
    -- Ações
    acoes_sugeridas TEXT[],
    acao_executada TEXT,
    
    -- Estado
    status TEXT NOT NULL DEFAULT 'NOVO',
    atribuido_para UUID,
    resolvido_por UUID,
    data_resolucao TIMESTAMPTZ,
    
    -- Notificação
    notificado BOOLEAN NOT NULL DEFAULT false,
    canais_notificacao TEXT[] DEFAULT '{}',
    data_notificacao TIMESTAMPTZ,
    
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CHECK (tipo_alerta IN ('KPI_CRITICO', 'KPI_ATENCAO', 'RELATORIO_ERRO', 'PERFORMANCE', 'ANOMALIA')),
    CHECK (origem_tipo IN ('KPI', 'RELATORIO', 'SISTEMA', 'USUARIO')),
    CHECK (severidade IN ('INFO', 'ATENCAO', 'CRITICO', 'URGENTE')),
    CHECK (status IN ('NOVO', 'EM_ANDAMENTO', 'RESOLVIDO', 'IGNORADO', 'REABERTO'))
);

-- Índices
CREATE INDEX idx_alertas_tenant ON analytics.alertas_analytics(tenant_id);
CREATE INDEX idx_alertas_tipo ON analytics.alertas_analytics(tipo_alerta);
CREATE INDEX idx_alertas_origem ON analytics.alertas_analytics(origem_id, origem_tipo);
CREATE INDEX idx_alertas_severidade ON analytics.alertas_analytics(severidade);
CREATE INDEX idx_alertas_status ON analytics.alertas_analytics(status);
CREATE INDEX idx_alertas_data ON analytics.alertas_analytics(criado_em);
CREATE INDEX idx_alertas_notificado ON analytics.alertas_analytics(notificado);

-- ============================================
-- TRIGGERS
-- ============================================
CREATE TRIGGER tr_relatorios_updated_at
    BEFORE UPDATE ON analytics.relatorios_configuracao
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

CREATE TRIGGER tr_kpi_updated_at
    BEFORE UPDATE ON analytics.metricas_kpi
    FOR EACH ROW EXECUTE FUNCTION meta_system.update_updated_at_column();

-- Trigger para calcular variação percentual de KPIs
CREATE OR REPLACE FUNCTION analytics.calcular_variacao_percentual()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.valor_anterior IS NOT NULL AND NEW.valor_anterior != 0 THEN
        NEW.variacao_percentual := ROUND(
            ((NEW.valor - NEW.valor_anterior) / ABS(NEW.valor_anterior)) * 100, 
            2
        );
    ELSE
        NEW.variacao_percentual := NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_calcular_variacao_percentual
    BEFORE INSERT OR UPDATE ON analytics.valores_kpi
    FOR EACH ROW EXECUTE FUNCTION analytics.calcular_variacao_percentual();

-- Trigger para gerar alertas automáticos de KPIs
CREATE OR REPLACE FUNCTION analytics.verificar_alertas_kpi()
RETURNS TRIGGER AS $$
DECLARE
    v_kpi RECORD;
    v_status_alerta TEXT := 'OK';
    v_status_meta TEXT := 'SEM_META';
    v_titulo TEXT;
    v_descricao TEXT;
BEGIN
    -- Busca configuração do KPI
    SELECT * INTO v_kpi
    FROM analytics.metricas_kpi
    WHERE id = NEW.kpi_id;
    
    -- Verifica alertas
    IF v_kpi.alerta_ativo THEN
        IF v_kpi.limite_critico IS NOT NULL AND NEW.valor <= v_kpi.limite_critico THEN
            v_status_alerta := 'CRITICO';
        ELSIF v_kpi.limite_atencao IS NOT NULL AND NEW.valor <= v_kpi.limite_atencao THEN
            v_status_alerta := 'ATENCAO';
        END IF;
    END IF;
    
    -- Verifica meta
    IF v_kpi.meta_valor IS NOT NULL THEN
        CASE v_kpi.meta_tipo
            WHEN 'MAIOR_MELHOR' THEN
                v_status_meta := CASE WHEN NEW.valor >= v_kpi.meta_valor THEN 'ATINGIDA' ELSE 'NAO_ATINGIDA' END;
            WHEN 'MENOR_MELHOR' THEN
                v_status_meta := CASE WHEN NEW.valor <= v_kpi.meta_valor THEN 'ATINGIDA' ELSE 'NAO_ATINGIDA' END;
            WHEN 'EXATO' THEN
                v_status_meta := CASE WHEN ABS(NEW.valor - v_kpi.meta_valor) < 0.01 THEN 'ATINGIDA' ELSE 'NAO_ATINGIDA' END;
        END CASE;
    END IF;
    
    NEW.status_alerta := v_status_alerta;
    NEW.status_meta := v_status_meta;
    
    -- Cria alerta se necessário
    IF v_status_alerta IN ('CRITICO', 'ATENCAO') THEN
        v_titulo := FORMAT('KPI %s em %s', v_kpi.nome, v_status_alerta);
        v_descricao := FORMAT('Valor atual: %s %s (Limite: %s)', 
            NEW.valor, v_kpi.unidade, 
            CASE WHEN v_status_alerta = 'CRITICO' THEN v_kpi.limite_critico ELSE v_kpi.limite_atencao END
        );
        
        INSERT INTO analytics.alertas_analytics (
            tenant_id, tipo_alerta, origem_id, origem_tipo,
            titulo, descricao, severidade, dados_contexto
        ) VALUES (
            NEW.tenant_id, 
            CASE WHEN v_status_alerta = 'CRITICO' THEN 'KPI_CRITICO' ELSE 'KPI_ATENCAO' END,
            NEW.kpi_id, 'KPI',
            v_titulo, v_descricao, v_status_alerta,
            jsonb_build_object(
                'kpi_nome', v_kpi.nome,
                'valor_atual', NEW.valor,
                'valor_anterior', NEW.valor_anterior,
                'data_referencia', NEW.data_referencia
            )
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_verificar_alertas_kpi
    BEFORE INSERT OR UPDATE ON analytics.valores_kpi
    FOR EACH ROW EXECUTE FUNCTION analytics.verificar_alertas_kpi();

-- ============================================
-- FUNÇÕES PRINCIPAIS
-- ============================================

-- Função para executar relatório
CREATE OR REPLACE FUNCTION analytics.executar_relatorio(
    p_relatorio_id UUID,
    p_parametros JSONB DEFAULT '{}',
    p_usar_cache BOOLEAN DEFAULT true,
    p_executado_por UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_relatorio RECORD;
    v_execucao_id UUID;
    v_query TEXT;
    v_resultado JSONB;
    v_cache_key TEXT;
    v_cache_valido BOOLEAN := false;
    v_inicio TIMESTAMPTZ := NOW();
    v_fim TIMESTAMPTZ;
    v_total_registros INTEGER;
BEGIN
    -- Busca configuração do relatório
    SELECT * INTO v_relatorio
    FROM analytics.relatorios_configuracao
    WHERE id = p_relatorio_id AND ativo = true;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Relatório não encontrado ou inativo: %', p_relatorio_id;
    END IF;
    
    -- Gera chave de cache
    v_cache_key := MD5(p_relatorio_id::TEXT || p_parametros::TEXT);
    
    -- Verifica cache se solicitado
    IF p_usar_cache THEN
        SELECT COUNT(*) > 0 INTO v_cache_valido
        FROM analytics.execucoes_relatorios
        WHERE cache_key = v_cache_key
          AND cache_valido_ate > NOW()
          AND status = 'SUCESSO';
    END IF;
    
    -- Cria registro de execução
    INSERT INTO analytics.execucoes_relatorios (
        relatorio_id, tenant_id, executado_por, tipo_execucao,
        parametros_utilizados, cache_key, status
    ) VALUES (
        p_relatorio_id, v_relatorio.tenant_id, p_executado_por, 'MANUAL',
        p_parametros, v_cache_key, 'EXECUTANDO'
    ) RETURNING id INTO v_execucao_id;
    
    -- Se tem cache válido, retorna
    IF v_cache_valido THEN
        UPDATE analytics.execucoes_relatorios
        SET status = 'SUCESSO',
            finalizado_em = NOW(),
            tempo_execucao_ms = EXTRACT(EPOCH FROM (NOW() - v_inicio)) * 1000
        WHERE id = v_execucao_id;
        
        RETURN v_execucao_id;
    END IF;
    
    BEGIN
        -- Prepara query substituindo parâmetros
        v_query := v_relatorio.query_base;
        
        -- TODO: Implementar substituição de parâmetros na query
        -- Por simplicidade, assumimos que a query já está pronta
        
        -- Executa query (simulado)
        v_resultado := jsonb_build_object(
            'colunas', v_relatorio.colunas_visiveis,
            'dados', '[]'::jsonb,
            'resumo', jsonb_build_object('total_registros', 0)
        );
        v_total_registros := 0;
        
        v_fim := NOW();
        
        -- Atualiza execução com sucesso
        UPDATE analytics.execucoes_relatorios
        SET status = 'SUCESSO',
            total_registros = v_total_registros,
            tempo_execucao_ms = EXTRACT(EPOCH FROM (v_fim - v_inicio)) * 1000,
            resultado_dados = v_resultado,
            resultado_resumo = v_resultado->'resumo',
            cache_valido_ate = NOW() + INTERVAL '1 hour',
            finalizado_em = v_fim
        WHERE id = v_execucao_id;
        
    EXCEPTION WHEN OTHERS THEN
        -- Atualiza execução com erro
        UPDATE analytics.execucoes_relatorios
        SET status = 'ERRO',
            erro_detalhes = SQLERRM,
            finalizado_em = NOW(),
            tempo_execucao_ms = EXTRACT(EPOCH FROM (NOW() - v_inicio)) * 1000
        WHERE id = v_execucao_id;
        
        RAISE;
    END;
    
    RETURN v_execucao_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para calcular KPI
CREATE OR REPLACE FUNCTION analytics.calcular_kpi(
    p_kpi_id UUID,
    p_data_referencia DATE DEFAULT CURRENT_DATE
)
RETURNS NUMERIC AS $$
DECLARE
    v_kpi RECORD;
    v_valor NUMERIC;
    v_valor_anterior NUMERIC;
    v_periodo_inicio TIMESTAMPTZ;
    v_periodo_fim TIMESTAMPTZ;
BEGIN
    -- Busca configuração do KPI
    SELECT * INTO v_kpi
    FROM analytics.metricas_kpi
    WHERE id = p_kpi_id AND ativo = true;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'KPI não encontrado ou inativo: %', p_kpi_id;
    END IF;
    
    -- Define período
    v_periodo_fim := (p_data_referencia + INTERVAL '1 day')::TIMESTAMPTZ;
    v_periodo_inicio := v_periodo_fim - (v_kpi.periodo_referencia || ' days')::INTERVAL;
    
    -- Busca valor anterior
    SELECT valor INTO v_valor_anterior
    FROM analytics.valores_kpi
    WHERE kpi_id = p_kpi_id
      AND data_referencia < p_data_referencia
    ORDER BY data_referencia DESC
    LIMIT 1;
    
    -- Executa query de cálculo (exemplo simplificado)
    -- Na implementação real, seria executada a query_calculo do KPI
    CASE v_kpi.nome
        WHEN 'Total de Decisões' THEN
            SELECT COUNT(*) INTO v_valor
            FROM orders.decisoes_lentes
            WHERE tenant_id = v_kpi.tenant_id
              AND criado_em BETWEEN v_periodo_inicio AND v_periodo_fim;
        
        WHEN 'Taxa de Aprovação' THEN
            SELECT 
                COALESCE(
                    ROUND(
                        COUNT(*) FILTER (WHERE status = 'APROVADA')::NUMERIC / 
                        NULLIF(COUNT(*), 0) * 100, 
                        2
                    ), 
                    0
                ) INTO v_valor
            FROM orders.decisoes_lentes
            WHERE tenant_id = v_kpi.tenant_id
              AND criado_em BETWEEN v_periodo_inicio AND v_periodo_fim;
        
        WHEN 'Prazo Médio de Entrega' THEN
            SELECT 
                COALESCE(ROUND(AVG(prazo_entrega_prometido), 1), 0) INTO v_valor
            FROM orders.decisoes_lentes
            WHERE tenant_id = v_kpi.tenant_id
              AND criado_em BETWEEN v_periodo_inicio AND v_periodo_fim
              AND prazo_entrega_prometido IS NOT NULL;
        
        ELSE
            v_valor := 0;
    END CASE;
    
    -- Insere/atualiza valor
    INSERT INTO analytics.valores_kpi (
        kpi_id, tenant_id, valor, valor_anterior, data_referencia,
        periodo_inicio, periodo_fim
    ) VALUES (
        p_kpi_id, v_kpi.tenant_id, v_valor, v_valor_anterior, p_data_referencia,
        v_periodo_inicio, v_periodo_fim
    )
    ON CONFLICT (kpi_id, data_referencia)
    DO UPDATE SET
        valor = EXCLUDED.valor,
        valor_anterior = EXCLUDED.valor_anterior,
        periodo_inicio = EXCLUDED.periodo_inicio,
        periodo_fim = EXCLUDED.periodo_fim,
        calculado_em = NOW();
    
    RETURN v_valor;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para calcular todos os KPIs
CREATE OR REPLACE FUNCTION analytics.calcular_todos_kpis(
    p_tenant_id UUID,
    p_data_referencia DATE DEFAULT CURRENT_DATE
)
RETURNS INTEGER AS $$
DECLARE
    v_kpi RECORD;
    v_contador INTEGER := 0;
BEGIN
    FOR v_kpi IN 
        SELECT id 
        FROM analytics.metricas_kpi 
        WHERE tenant_id = p_tenant_id 
          AND ativo = true
    LOOP
        PERFORM analytics.calcular_kpi(v_kpi.id, p_data_referencia);
        v_contador := v_contador + 1;
    END LOOP;
    
    RETURN v_contador;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- VIEWS AUXILIARES
-- ============================================

-- View para dashboard de KPIs
CREATE OR REPLACE VIEW analytics.vw_dashboard_kpis AS
SELECT 
    k.id,
    k.nome,
    k.descricao,
    k.categoria,
    k.unidade,
    k.formato_exibicao,
    k.meta_valor,
    k.cor_display,
    k.icone,
    v.valor,
    v.valor_anterior,
    v.variacao,
    v.variacao_percentual,
    v.status_meta,
    v.status_alerta,
    v.data_referencia,
    CASE k.formato_exibicao
        WHEN 'percentual' THEN v.valor || '%'
        WHEN 'moeda' THEN 'R$ ' || TO_CHAR(v.valor, 'FM999G999G999D90')
        WHEN 'tempo' THEN v.valor || ' dias'
        ELSE v.valor || ' ' || k.unidade
    END as valor_formatado,
    CASE v.status_alerta
        WHEN 'CRITICO' THEN '🔴'
        WHEN 'ATENCAO' THEN '🟠'
        ELSE '🟢'
    END as status_emoji,
    CASE 
        WHEN v.variacao > 0 THEN '📈'
        WHEN v.variacao < 0 THEN '📉'
        ELSE '➖'
    END as tendencia_emoji
FROM analytics.metricas_kpi k
LEFT JOIN analytics.valores_kpi v ON v.kpi_id = k.id 
    AND v.data_referencia = (
        SELECT MAX(data_referencia) 
        FROM analytics.valores_kpi v2 
        WHERE v2.kpi_id = k.id
    )
WHERE k.ativo = true
ORDER BY k.ordem_dashboard, k.nome;

-- View para alertas pendentes
CREATE OR REPLACE VIEW analytics.vw_alertas_pendentes AS
SELECT 
    a.*,
    CASE a.severidade
        WHEN 'URGENTE' THEN '🆘'
        WHEN 'CRITICO' THEN '🔴'
        WHEN 'ATENCAO' THEN '⚠️'
        ELSE 'ℹ️'
    END as severidade_emoji,
    EXTRACT(EPOCH FROM (NOW() - a.criado_em))/3600 as horas_pendente
FROM analytics.alertas_analytics a
WHERE a.status IN ('NOVO', 'EM_ANDAMENTO')
ORDER BY 
    CASE a.severidade
        WHEN 'URGENTE' THEN 1
        WHEN 'CRITICO' THEN 2
        WHEN 'ATENCAO' THEN 3
        ELSE 4
    END,
    a.criado_em DESC;

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE analytics.relatorios_configuracao IS 'Configuração de relatórios personalizáveis';
COMMENT ON COLUMN analytics.relatorios_configuracao.query_base IS 'Query SQL base do relatório com placeholders para parâmetros';
COMMENT ON COLUMN analytics.relatorios_configuracao.parametros_disponiveis IS 'Array de objetos definindo parâmetros: [{"nome": "data_inicio", "tipo": "date", "obrigatorio": true}]';

COMMENT ON TABLE analytics.execucoes_relatorios IS 'Histórico de execuções de relatórios com cache';
COMMENT ON TABLE analytics.metricas_kpi IS 'Definição de KPIs (Key Performance Indicators)';
COMMENT ON TABLE analytics.valores_kpi IS 'Valores históricos calculados dos KPIs';
COMMENT ON TABLE analytics.alertas_analytics IS 'Sistema de alertas baseado em KPIs e relatórios';

-- ============================================
-- DADOS INICIAIS
-- ============================================

DO $$
DECLARE
    v_tenant_id UUID;
    v_relatorio_id UUID;
    v_kpi_id UUID;
BEGIN
    -- Pega referências
    SELECT id INTO v_tenant_id FROM meta_system.tenants WHERE slug = 'demo';
    
    -- KPIs básicos
    INSERT INTO analytics.metricas_kpi (
        tenant_id, nome, descricao, categoria, query_calculo, unidade, 
        formato_exibicao, meta_valor, meta_tipo, frequencia_calculo,
        alerta_ativo, limite_atencao, limite_critico, ordem_dashboard, cor_display, icone
    ) VALUES 
    (v_tenant_id, 'Total de Decisões', 'Número total de decisões de lentes processadas', 'VENDAS', 
     'SELECT COUNT(*) FROM orders.decisoes_lentes WHERE tenant_id = $1', 'decisões', 'numero', 
     50, 'MAIOR_MELHOR', 'DIARIO', true, 30, 20, 1, '#10B981', '📊'),
     
    (v_tenant_id, 'Taxa de Aprovação', 'Percentual de decisões aprovadas vs total', 'VENDAS', 
     'SELECT ROUND(COUNT(*) FILTER (WHERE status = ''APROVADA'') * 100.0 / COUNT(*), 2) FROM orders.decisoes_lentes WHERE tenant_id = $1', '%', 'percentual', 
     80, 'MAIOR_MELHOR', 'DIARIO', true, 60, 40, 2, '#3B82F6', '✅'),
     
    (v_tenant_id, 'Prazo Médio de Entrega', 'Prazo médio prometido para entrega', 'OPERACIONAL', 
     'SELECT ROUND(AVG(prazo_entrega_prometido), 1) FROM orders.decisoes_lentes WHERE tenant_id = $1 AND prazo_entrega_prometido IS NOT NULL', 'dias', 'tempo', 
     5, 'MENOR_MELHOR', 'DIARIO', true, 7, 10, 3, '#F59E0B', '🚚'),
     
    (v_tenant_id, 'Score Médio Laboratórios', 'Score médio de qualificação dos laboratórios ativos', 'QUALIDADE', 
     'SELECT ROUND(AVG(score_geral), 2) FROM scoring.scores_laboratorios WHERE tenant_id = $1 AND valido_ate >= CURRENT_DATE', 'pontos', 'numero', 
     7.5, 'MAIOR_MELHOR', 'SEMANAL', true, 6.0, 5.0, 4, '#8B5CF6', '⭐'),
     
    (v_tenant_id, 'Laboratórios Ativos', 'Número de laboratórios ativos no sistema', 'OPERACIONAL', 
     'SELECT COUNT(*) FROM suppliers.laboratorios WHERE tenant_id = $1 AND ativo = true', 'laboratórios', 'numero', 
     5, 'MAIOR_MELHOR', 'SEMANAL', false, NULL, NULL, 5, '#06B6D4', '🏭');
    
    -- Relatórios pré-configurados
    INSERT INTO analytics.relatorios_configuracao (
        tenant_id, nome, descricao, categoria, tipo_relatorio, query_base,
        colunas_visiveis, publico, ativo
    ) VALUES 
    (v_tenant_id, 'Decisões por Período', 'Relatório de decisões agrupadas por período', 'VENDAS', 'TABULAR',
     'SELECT codigo_decisao, cliente_nome, status, preco_final, criado_em FROM orders.decisoes_lentes WHERE tenant_id = $1',
     '["codigo_decisao", "cliente_nome", "status", "preco_final", "criado_em"]'::jsonb, true, true),
     
    (v_tenant_id, 'Ranking de Laboratórios', 'Ranking atual dos laboratórios por score', 'QUALIDADE', 'TABULAR',
     'SELECT laboratorio_nome, score_geral, ranking_geral, nivel_qualificacao FROM scoring.vw_ranking_laboratorios WHERE tenant_id = $1',
     '["laboratorio_nome", "score_geral", "ranking_geral", "nivel_qualificacao"]'::jsonb, true, true),
     
    (v_tenant_id, 'Análise de Preços', 'Análise comparativa de preços por laboratório', 'FINANCEIRO', 'ANALITICO',
     'SELECT l.nome_fantasia, AVG(cp.preco_final) as preco_medio FROM suppliers.laboratorios l JOIN commercial.precos_produtos cp ON cp.laboratorio_id = l.id WHERE l.tenant_id = $1 GROUP BY l.nome_fantasia',
     '["nome_fantasia", "preco_medio"]'::jsonb, false, true);
    
    -- Calcula KPIs iniciais
    PERFORM analytics.calcular_todos_kpis(v_tenant_id);
    
END $$;