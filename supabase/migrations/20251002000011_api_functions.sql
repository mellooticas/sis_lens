-- Migration: 011_api_functions.sql
-- Funções e Views para API pública do sistema

-- ============================================
-- SCHEMA PARA API PÚBLICA
-- ============================================
CREATE SCHEMA IF NOT EXISTS api;

-- ============================================
-- FUNÇÕES DA API - CATÁLOGO DE LENTES
-- ============================================

-- Buscar lentes por critérios
CREATE OR REPLACE FUNCTION api.buscar_lentes(
    p_marca TEXT DEFAULT NULL,
    p_tipo_lente TEXT DEFAULT NULL,
    p_material TEXT DEFAULT NULL,
    p_filtros TEXT[] DEFAULT NULL,
    p_esferico_min NUMERIC DEFAULT NULL,
    p_esferico_max NUMERIC DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    nome TEXT,
    marca TEXT,
    tipo_lente TEXT,
    material TEXT,
    esferico_min NUMERIC,
    esferico_max NUMERIC,
    cilindrico_min NUMERIC,
    cilindrico_max NUMERIC,
    adicao_min NUMERIC,
    adicao_max NUMERIC,
    filtros JSONB,
    caracteristicas JSONB,
    preco_referencia NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.nome,
        l.marca,
        l.tipo_lente,
        l.material,
        l.esferico_min,
        l.esferico_max,
        l.cilindrico_min,
        l.cilindrico_max,
        l.adicao_min,
        l.adicao_max,
        l.filtros,
        l.caracteristicas,
        (
            SELECT AVG(cp.preco_final)
            FROM commercial.precos_produtos cp
            WHERE cp.lente_id = l.id AND cp.ativo = true
        ) as preco_referencia
    FROM lens_catalog.lentes l
    WHERE l.tenant_id = meta_system.current_tenant_id()
      AND l.ativo = true
      AND (p_marca IS NULL OR l.marca ILIKE '%' || p_marca || '%')
      AND (p_tipo_lente IS NULL OR l.tipo_lente = p_tipo_lente)
      AND (p_material IS NULL OR l.material = p_material)
      AND (p_filtros IS NULL OR l.filtros ?& p_filtros)
      AND (p_esferico_min IS NULL OR l.esferico_max >= p_esferico_min)
      AND (p_esferico_max IS NULL OR l.esferico_min <= p_esferico_max)
    ORDER BY l.nome
    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Obter detalhes completos de uma lente
CREATE OR REPLACE FUNCTION api.obter_lente(p_lente_id UUID)
RETURNS TABLE (
    id UUID,
    nome TEXT,
    marca TEXT,
    tipo_lente TEXT,
    material TEXT,
    especificacoes JSONB,
    filtros JSONB,
    caracteristicas JSONB,
    laboratorios JSONB,
    precos JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.nome,
        l.marca,
        l.tipo_lente,
        l.material,
        jsonb_build_object(
            'esferico_min', l.esferico_min,
            'esferico_max', l.esferico_max,
            'cilindrico_min', l.cilindrico_min,
            'cilindrico_max', l.cilindrico_max,
            'adicao_min', l.adicao_min,
            'adicao_max', l.adicao_max,
            'indice_refracao', l.indice_refracao,
            'espessura_centro', l.espessura_centro
        ) as especificacoes,
        l.filtros,
        l.caracteristicas,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', lab.id,
                    'nome', lab.nome,
                    'nome_fantasia', lab.nome_fantasia,
                    'score', sl.score_geral,
                    'nivel', sl.nivel_qualificacao
                )
            )
            FROM suppliers.produtos_laboratorio pl
            JOIN suppliers.laboratorios lab ON lab.id = pl.laboratorio_id
            LEFT JOIN scoring.scores_laboratorios sl ON sl.laboratorio_id = lab.id 
                AND sl.valido_ate >= CURRENT_DATE
            WHERE pl.lente_id = l.id AND lab.ativo = true
        ) as laboratorios,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'laboratorio_id', cp.laboratorio_id,
                    'preco_base', cp.preco_base,
                    'preco_final', cp.preco_final,
                    'desconto', cp.desconto_percentual,
                    'data_vigencia', cp.data_vigencia
                )
            )
            FROM commercial.precos_produtos cp
            WHERE cp.lente_id = l.id AND cp.ativo = true
        ) as precos
    FROM lens_catalog.lentes l
    WHERE l.id = p_lente_id
      AND l.tenant_id = meta_system.current_tenant_id()
      AND l.ativo = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNÇÕES DA API - LABORATÓRIOS
-- ============================================

-- Listar laboratórios com scores
CREATE OR REPLACE FUNCTION api.listar_laboratorios(
    p_regiao TEXT DEFAULT NULL,
    p_nivel_min TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    nome TEXT,
    nome_fantasia TEXT,
    cnpj TEXT,
    endereco JSONB,
    contato JSONB,
    atende_regioes TEXT[],
    score_geral NUMERIC,
    ranking_geral INTEGER,
    nivel_qualificacao TEXT,
    badges TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.nome,
        l.nome_fantasia,
        l.cnpj,
        l.endereco,
        l.contato,
        l.atende_regioes,
        COALESCE(s.score_geral, 0) as score_geral,
        s.ranking_geral,
        COALESCE(s.nivel_qualificacao, 'NAO_QUALIFICADO') as nivel_qualificacao,
        CASE s.nivel_qualificacao
            WHEN 'GOLD' THEN ARRAY['🥇 Gold', '⭐ Premium']
            WHEN 'SILVER' THEN ARRAY['🥈 Silver', '✨ Qualificado']
            WHEN 'BRONZE' THEN ARRAY['🥉 Bronze']
            WHEN 'QUALIFICADO' THEN ARRAY['✅ Qualificado']
            ELSE ARRAY['⚪ Básico']
        END as badges
    FROM suppliers.laboratorios l
    LEFT JOIN scoring.scores_laboratorios s ON s.laboratorio_id = l.id 
        AND s.valido_ate >= CURRENT_DATE
        AND s.data_calculo = (
            SELECT MAX(data_calculo) 
            FROM scoring.scores_laboratorios s2 
            WHERE s2.laboratorio_id = l.id
        )
    WHERE l.tenant_id = meta_system.current_tenant_id()
      AND l.ativo = true
      AND (p_regiao IS NULL OR p_regiao = ANY(l.atende_regioes))
      AND (p_nivel_min IS NULL OR 
           COALESCE(s.nivel_qualificacao, 'NAO_QUALIFICADO') >= p_nivel_min)
    ORDER BY s.ranking_geral NULLS LAST, l.nome_fantasia;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Obter detalhes de laboratório com métricas
CREATE OR REPLACE FUNCTION api.obter_laboratorio(p_laboratorio_id UUID)
RETURNS TABLE (
    id UUID,
    dados_gerais JSONB,
    scoring JSONB,
    metricas_entrega JSONB,
    produtos_count INTEGER,
    avaliacoes_recentes JSONB
) AS $$
DECLARE
    v_metricas RECORD;
BEGIN
    -- Busca métricas de entrega
    SELECT * INTO v_metricas
    FROM logistics.calcular_metricas_entrega(p_laboratorio_id);
    
    RETURN QUERY
    SELECT 
        l.id,
        jsonb_build_object(
            'nome', l.nome,
            'nome_fantasia', l.nome_fantasia,
            'cnpj', l.cnpj,
            'endereco', l.endereco,
            'contato', l.contato,
            'atende_regioes', l.atende_regioes,
            'especialidades', l.especialidades,
            'certificacoes', l.certificacoes
        ) as dados_gerais,
        jsonb_build_object(
            'score_geral', s.score_geral,
            'score_qualidade', s.score_qualidade,
            'score_preco', s.score_preco,
            'score_prazo', s.score_prazo,
            'ranking_geral', s.ranking_geral,
            'nivel_qualificacao', s.nivel_qualificacao,
            'data_calculo', s.data_calculo
        ) as scoring,
        jsonb_build_object(
            'total_entregas', v_metricas.total_entregas,
            'percentual_no_prazo', v_metricas.percentual_no_prazo,
            'atraso_medio_dias', v_metricas.atraso_medio_dias,
            'prazo_medio_prometido', v_metricas.prazo_medio_prometido,
            'prazo_medio_real', v_metricas.prazo_medio_real
        ) as metricas_entrega,
        (
            SELECT COUNT(*)::INTEGER
            FROM suppliers.produtos_laboratorio pl
            WHERE pl.laboratorio_id = l.id
        ) as produtos_count,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'criterio', cs.nome,
                    'valor', al.valor_normalizado,
                    'justificativa', al.justificativa,
                    'data', al.data_referencia
                )
            )
            FROM scoring.avaliacoes_laboratorios al
            JOIN scoring.criterios_scoring cs ON cs.id = al.criterio_id
            WHERE al.laboratorio_id = l.id
              AND al.data_referencia >= CURRENT_DATE - INTERVAL '30 days'
            ORDER BY al.data_referencia DESC
            LIMIT 5
        ) as avaliacoes_recentes
    FROM suppliers.laboratorios l
    LEFT JOIN scoring.scores_laboratorios s ON s.laboratorio_id = l.id 
        AND s.valido_ate >= CURRENT_DATE
        AND s.data_calculo = (
            SELECT MAX(data_calculo) 
            FROM scoring.scores_laboratorios s2 
            WHERE s2.laboratorio_id = l.id
        )
    WHERE l.id = p_laboratorio_id
      AND l.tenant_id = meta_system.current_tenant_id()
      AND l.ativo = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNÇÕES DA API - DECISÕES
-- ============================================

-- Criar nova decisão de lente
CREATE OR REPLACE FUNCTION api.criar_decisao_lente(
    p_cliente_nome TEXT,
    p_receita JSONB,
    p_otica_id UUID DEFAULT NULL,
    p_especificacoes JSONB DEFAULT '{}',
    p_prioridades JSONB DEFAULT '{"preco": 1.0, "qualidade": 1.0, "prazo": 1.0}',
    p_regiao_entrega TEXT DEFAULT 'SUDESTE',
    p_observacoes TEXT DEFAULT NULL
)
RETURNS TABLE (
    decisao_id UUID,
    codigo_decisao TEXT,
    alternativas JSONB
) AS $$
DECLARE
    v_decisao_id UUID;
    v_codigo TEXT;
    v_alternativas JSONB;
BEGIN
    -- Cria a decisão
    INSERT INTO orders.decisoes_lentes (
        tenant_id, cliente_nome, otica_id, receita, especificacoes, 
        prioridades, tipo_receita, uso_principal, observacoes
    ) VALUES (
        meta_system.current_tenant_id(),
        p_cliente_nome,
        p_otica_id,
        p_receita,
        p_especificacoes,
        p_prioridades,
        CASE 
            WHEN (p_receita->>'adicao')::NUMERIC > 0 THEN 'PROGRESSIVA'
            WHEN (p_receita->>'cilindrico_od')::NUMERIC != 0 OR (p_receita->>'cilindrico_oe')::NUMERIC != 0 THEN 'MULTIFOCAL'
            ELSE 'VISAO_SIMPLES'
        END,
        COALESCE((p_especificacoes->>'uso_principal')::TEXT, 'GERAL'),
        p_observacoes
    ) RETURNING id, codigo_decisao INTO v_decisao_id, v_codigo;
    
    -- Gera alternativas
    INSERT INTO orders.alternativas_cotacao (
        decisao_id, tenant_id, posicao, tipo_alternativa, lente_id, laboratorio_id,
        percentual_adequacao, preco_base, preco_final, prazo_minimo, prazo_maximo,
        score_geral, recomendada, pontos_fortes
    )
    SELECT 
        v_decisao_id,
        meta_system.current_tenant_id(),
        p.posicao_ranking,
        CASE 
            WHEN p.posicao_ranking = 1 THEN 'RECOMENDACAO'
            WHEN p.posicao_ranking <= 3 THEN 'ALTERNATIVA'
            ELSE 'SEGUNDA_OPCAO'
        END,
        p.lente_id,
        p.laboratorio_id,
        p.adequacao_receita,
        p.preco_final * 0.95,
        p.preco_final,
        GREATEST(1, p.prazo_medio - 1),
        p.prazo_medio + 1,
        p.score_geral,
        p.posicao_ranking = 1,
        CASE 
            WHEN p.posicao_ranking = 1 THEN ARRAY['Melhor adequação técnica', 'Recomendação principal']
            WHEN p.score_geral >= 8 THEN ARRAY['Alta qualidade', 'Boa reputação']
            ELSE ARRAY['Opção viável', 'Custo-benefício']
        END
    FROM orders.processar_decisao_lente(
        meta_system.current_tenant_id(),
        p_receita,
        p_especificacoes,
        p_prioridades,
        p_regiao_entrega
    ) p;
    
    -- Busca alternativas criadas
    SELECT jsonb_agg(
        jsonb_build_object(
            'posicao', a.posicao,
            'tipo', a.tipo_alternativa,
            'lente', jsonb_build_object(
                'id', l.id,
                'nome', l.nome,
                'marca', l.marca,
                'tipo', l.tipo_lente,
                'material', l.material
            ),
            'laboratorio', jsonb_build_object(
                'id', lab.id,
                'nome', lab.nome_fantasia,
                'score', a.score_geral
            ),
            'adequacao', a.percentual_adequacao,
            'preco_final', a.preco_final,
            'prazo', jsonb_build_object(
                'minimo', a.prazo_minimo,
                'maximo', a.prazo_maximo,
                'medio', a.prazo_medio
            ),
            'pontos_fortes', a.pontos_fortes,
            'recomendada', a.recomendada
        ) ORDER BY a.posicao
    ) INTO v_alternativas
    FROM orders.alternativas_cotacao a
    JOIN lens_catalog.lentes l ON l.id = a.lente_id
    JOIN suppliers.laboratorios lab ON lab.id = a.laboratorio_id
    WHERE a.decisao_id = v_decisao_id AND a.ativa = true;
    
    RETURN QUERY SELECT v_decisao_id, v_codigo, v_alternativas;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Obter decisão com alternativas
CREATE OR REPLACE FUNCTION api.obter_decisao(p_decisao_id UUID)
RETURNS TABLE (
    decisao JSONB,
    alternativas JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', d.id,
            'codigo', d.codigo_decisao,
            'cliente', jsonb_build_object(
                'nome', d.cliente_nome,
                'idade', d.cliente_idade
            ),
            'otica', d.nome_otica,
            'receita', d.receita,
            'especificacoes', d.especificacoes,
            'status', d.status,
            'prioridade', d.prioridade,
            'resultado', CASE 
                WHEN d.lente_recomendada_id IS NOT NULL THEN
                    jsonb_build_object(
                        'lente_id', d.lente_recomendada_id,
                        'laboratorio_id', d.laboratorio_escolhido_id,
                        'preco_final', d.preco_final,
                        'prazo_prometido', d.prazo_entrega_prometido,
                        'justificativa', d.justificativa_tecnica
                    )
                ELSE NULL
            END,
            'criado_em', d.criado_em,
            'atualizado_em', d.atualizado_em
        ) as decisao,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', a.id,
                    'posicao', a.posicao,
                    'tipo', a.tipo_alternativa,
                    'recomendada', a.recomendada,
                    'lente', jsonb_build_object(
                        'id', l.id,
                        'nome', l.nome,
                        'marca', l.marca,
                        'tipo', l.tipo_lente,
                        'material', l.material
                    ),
                    'laboratorio', jsonb_build_object(
                        'id', lab.id,
                        'nome', lab.nome_fantasia,
                        'score', a.score_geral
                    ),
                    'adequacao', a.percentual_adequacao,
                    'comercial', jsonb_build_object(
                        'preco_base', a.preco_base,
                        'preco_final', a.preco_final,
                        'desconto', a.desconto_percentual,
                        'custo_frete', a.custo_frete,
                        'preco_total', a.preco_total
                    ),
                    'logistica', jsonb_build_object(
                        'prazo_minimo', a.prazo_minimo,
                        'prazo_maximo', a.prazo_maximo,
                        'prazo_medio', a.prazo_medio,
                        'disponibilidade', a.disponibilidade
                    ),
                    'qualificacao', jsonb_build_object(
                        'pontos_fortes', a.pontos_fortes,
                        'pontos_fracos', a.pontos_fracos,
                        'score_geral', a.score_geral,
                        'score_qualidade', a.score_qualidade,
                        'score_preco', a.score_preco,
                        'score_prazo', a.score_prazo
                    ),
                    'observacoes', a.observacoes
                ) ORDER BY a.posicao
            )
            FROM orders.alternativas_cotacao a
            JOIN lens_catalog.lentes l ON l.id = a.lente_id
            JOIN suppliers.laboratorios lab ON lab.id = a.laboratorio_id
            WHERE a.decisao_id = d.id AND a.ativa = true
        ) as alternativas
    FROM orders.decisoes_lentes d
    WHERE d.id = p_decisao_id
      AND d.tenant_id = meta_system.current_tenant_id();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNÇÕES DA API - ANALYTICS
-- ============================================

-- Dashboard KPIs
CREATE OR REPLACE FUNCTION api.obter_dashboard_kpis()
RETURNS TABLE (
    kpis JSONB,
    resumo JSONB
) AS $$
DECLARE
    v_kpis JSONB;
    v_resumo JSONB;
BEGIN
    -- Busca KPIs atuais
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', k.id,
            'nome', k.nome,
            'valor', k.valor_formatado,
            'variacao', k.variacao_percentual,
            'status', k.status_alerta,
            'meta', k.meta_valor,
            'tendencia', k.tendencia_emoji,
            'categoria', k.categoria,
            'cor', k.cor_display,
            'icone', k.icone
        ) ORDER BY k.ordem_dashboard
    ) INTO v_kpis
    FROM analytics.vw_dashboard_kpis k;
    
    -- Gera resumo
    SELECT jsonb_build_object(
        'total_kpis', COUNT(*),
        'kpis_criticos', COUNT(*) FILTER (WHERE status_alerta = 'CRITICO'),
        'kpis_atencao', COUNT(*) FILTER (WHERE status_alerta = 'ATENCAO'),
        'kpis_ok', COUNT(*) FILTER (WHERE status_alerta = 'OK'),
        'ultima_atualizacao', MAX(data_referencia)
    ) INTO v_resumo
    FROM analytics.vw_dashboard_kpis;
    
    RETURN QUERY SELECT v_kpis, v_resumo;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- VIEWS DA API
-- ============================================

-- View simplificada para ranking de laboratórios
CREATE OR REPLACE VIEW api.vw_ranking_laboratorios AS
SELECT 
    l.id,
    l.nome_fantasia as nome,
    l.atende_regioes,
    s.score_geral,
    s.ranking_geral as ranking,
    s.nivel_qualificacao as nivel,
    CASE s.nivel_qualificacao
        WHEN 'GOLD' THEN '🥇'
        WHEN 'SILVER' THEN '🥈'
        WHEN 'BRONZE' THEN '🥉'
        WHEN 'QUALIFICADO' THEN '✅'
        ELSE '⚪'
    END as badge
FROM suppliers.laboratorios l
LEFT JOIN scoring.vw_ranking_laboratorios s ON s.laboratorio_id = l.id
WHERE l.ativo = true
  AND meta_system.filter_by_current_tenant(l.tenant_id)
ORDER BY s.ranking_geral NULLS LAST;

-- View para estatísticas rápidas
CREATE OR REPLACE VIEW api.vw_estatisticas_gerais AS
SELECT 
    'total_lentes' as metrica,
    COUNT(*) as valor,
    'Total de lentes no catálogo' as descricao
FROM lens_catalog.lentes 
WHERE ativo = true AND meta_system.filter_by_current_tenant(tenant_id)

UNION ALL

SELECT 
    'total_laboratorios',
    COUNT(*),
    'Laboratórios parceiros ativos'
FROM suppliers.laboratorios 
WHERE ativo = true AND meta_system.filter_by_current_tenant(tenant_id)

UNION ALL

SELECT 
    'decisoes_mes',
    COUNT(*),
    'Decisões processadas no mês atual'
FROM orders.decisoes_lentes 
WHERE EXTRACT(MONTH FROM criado_em) = EXTRACT(MONTH FROM CURRENT_DATE)
  AND EXTRACT(YEAR FROM criado_em) = EXTRACT(YEAR FROM CURRENT_DATE)
  AND meta_system.filter_by_current_tenant(tenant_id)

UNION ALL

SELECT 
    'taxa_aprovacao',
    ROUND(
        COUNT(*) FILTER (WHERE status = 'APROVADA') * 100.0 / 
        NULLIF(COUNT(*), 0), 
        1
    ),
    'Taxa de aprovação (%)'
FROM orders.decisoes_lentes 
WHERE criado_em >= CURRENT_DATE - INTERVAL '30 days'
  AND meta_system.filter_by_current_tenant(tenant_id);

-- ============================================
-- PERMISSÕES DA API
-- ============================================

-- Grant acesso às funções da API
GRANT USAGE ON SCHEMA api TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA api TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA api TO authenticated;

-- ============================================
-- DOCUMENTAÇÃO DA API
-- ============================================

COMMENT ON SCHEMA api IS 'Schema público para funções e views da API do BestLens';

COMMENT ON FUNCTION api.buscar_lentes IS 'Busca lentes no catálogo com filtros opcionais';
COMMENT ON FUNCTION api.obter_lente IS 'Retorna detalhes completos de uma lente específica';
COMMENT ON FUNCTION api.listar_laboratorios IS 'Lista laboratórios com scores e rankings';
COMMENT ON FUNCTION api.obter_laboratorio IS 'Detalhes completos de um laboratório com métricas';
COMMENT ON FUNCTION api.criar_decisao_lente IS 'Cria nova decisão e gera alternativas automaticamente';
COMMENT ON FUNCTION api.obter_decisao IS 'Retorna decisão completa com todas as alternativas';
COMMENT ON FUNCTION api.obter_dashboard_kpis IS 'Dashboard com KPIs principais do sistema';

COMMENT ON VIEW api.vw_ranking_laboratorios IS 'Ranking simplificado de laboratórios para exibição';
COMMENT ON VIEW api.vw_estatisticas_gerais IS 'Estatísticas gerais do sistema para dashboard';

-- ============================================
-- EXEMPLOS DE USO
-- ============================================

/*
-- Buscar lentes progressivas
SELECT * FROM api.buscar_lentes(
    p_tipo_lente => 'PROGRESSIVA',
    p_material => 'POLICARBONATO',
    p_limite => 10
);

-- Criar decisão
SELECT * FROM api.criar_decisao_lente(
    p_cliente_nome => 'João Silva',
    p_receita => '{
        "esferico_od": -2.5,
        "cilindrico_od": -1.0,
        "eixo_od": 180,
        "adicao": 1.5
    }'::jsonb,
    p_especificacoes => '{
        "uso_principal": "COMPUTADOR",
        "material_preferido": "POLICARBONATO"
    }'::jsonb
);

-- Dashboard
SELECT * FROM api.obter_dashboard_kpis();
*/