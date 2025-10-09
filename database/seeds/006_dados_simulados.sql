-- ===============================================
-- 006_dados_simulados.sql
-- Dados Históricos Simulados - 6 Meses de Operação
-- Data: 04/10/2025
-- ===============================================

-- Este script cria um histórico realista de 6 meses:
-- - Decisões de lentes e justificativas
-- - Métricas de performance do sistema
-- - Dados de analytics e uso
-- - Simulação de padrões reais de uma ótica

BEGIN;

-- ===============================================
-- 1. PERFIS DE PACIENTES SIMULADOS
-- ===============================================

-- Criar uma tabela temporária de pacientes para simular decisões
CREATE TEMP TABLE temp_pacientes AS
SELECT 
    gen_random_uuid() as id,
    'Paciente ' || generate_series as nome,
    CASE 
        WHEN random() < 0.3 THEN 'primeira_vez'
        WHEN random() < 0.6 THEN 'retorno'
        ELSE 'referenciado'
    END as tipo_cliente,
    CASE 
        WHEN random() < 0.2 THEN 'baixa'
        WHEN random() < 0.6 THEN 'media'
        ELSE 'alta'
    END as faixa_renda,
    CASE 
        WHEN random() < 0.3 THEN 'jovem'
        WHEN random() < 0.5 THEN 'adulto'
        ELSE 'idoso'
    END as perfil_idade,
    CASE 
        WHEN random() < 0.4 THEN 'escritorio'
        WHEN random() < 0.3 THEN 'dirigir'
        WHEN random() < 0.2 THEN 'leitura'
        ELSE 'digital'
    END as atividade_principal
FROM generate_series(1, 200);

-- ===============================================
-- 2. DECISÕES HISTÓRICAS SIMULADAS (6 MESES)
-- ===============================================

-- Função para gerar data aleatória nos últimos 6 meses
CREATE OR REPLACE FUNCTION random_date_last_6_months()
RETURNS DATE AS $$
BEGIN
    RETURN CURRENT_DATE - (random() * 180)::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- Inserir decisões simuladas
INSERT INTO scoring.decisoes (
    id,
    tenant_id,
    lente_recomendada_id,
    lente_alternativa_id,
    score_recomendada,
    score_alternativa,
    diferenca_score,
    criterios_decisivos,
    justificativa,
    confianca_decisao,
    data_decisao,
    contexto_decisao,
    feedback_usuario,
    resultado_real,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    l1.id,
    l2.id,
    85 + (random() * 10)::INTEGER, -- Score entre 85-95
    70 + (random() * 10)::INTEGER, -- Score entre 70-80
    15 + (random() * 5)::INTEGER,  -- Diferença 15-20
    CASE 
        WHEN tp.perfil_idade = 'jovem' THEN '["Qualidade Óptica", "Custo-Benefício"]'
        WHEN tp.perfil_idade = 'adulto' THEN '["Disponibilidade", "Tempo de Entrega"]'
        ELSE '["Qualidade Óptica", "Suporte Técnico"]'
    END::jsonb,
    CASE 
        WHEN tp.atividade_principal = 'digital' THEN 'Recomendada para uso intenso de telas com proteção luz azul'
        WHEN tp.atividade_principal = 'dirigir' THEN 'Óptica superior para direção, especialmente noturna'
        WHEN tp.atividade_principal = 'leitura' THEN 'Zona de perto otimizada para leitura prolongada'
        ELSE 'Melhor equilíbrio entre qualidade e preço para uso geral'
    END,
    0.85 + (random() * 0.12), -- Confiança entre 85% e 97%
    random_date_last_6_months(),
    CASE 
        WHEN tp.tipo_cliente = 'primeira_vez' THEN 'primeira_prescricao'
        WHEN tp.faixa_renda = 'alta' THEN 'upgrade_premium'
        ELSE 'renovacao_receita'
    END,
    CASE 
        WHEN random() < 0.8 THEN 'positivo'
        WHEN random() < 0.9 THEN 'neutro'
        ELSE 'negativo'
    END,
    CASE 
        WHEN random() < 0.85 THEN 'decisao_aceita'
        WHEN random() < 0.95 THEN 'decisao_parcial'
        ELSE 'decisao_rejeitada'
    END,
    random_date_last_6_months(),
    random_date_last_6_months()
FROM temp_pacientes tp
CROSS JOIN LATERAL (
    SELECT l.id, ROW_NUMBER() OVER (ORDER BY random()) as rn
    FROM lens_catalog.lentes l 
    WHERE l.ativo = true 
    AND l.tenant_id = (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo')
) l1
CROSS JOIN LATERAL (
    SELECT l.id
    FROM lens_catalog.lentes l 
    WHERE l.ativo = true 
    AND l.id != l1.id
    AND l.tenant_id = (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo')
    ORDER BY random() 
    LIMIT 1
) l2
WHERE l1.rn <= 3 -- Cada paciente tem até 3 decisões
  AND random() < CASE tp.tipo_cliente 
    WHEN 'primeira_vez' THEN 0.4 
    WHEN 'retorno' THEN 0.8 
    ELSE 0.6 
  END;

-- ===============================================
-- 3. HISTÓRICO DE CONSULTAS E BUSCAS
-- ===============================================

-- Inserir logs de consultas do sistema
INSERT INTO analytics.consultas_sistema (
    id,
    tenant_id,
    usuario_id,
    tipo_consulta,
    parametros_busca,
    resultados_encontrados,
    tempo_resposta_ms,
    filtros_aplicados,
    ordenacao_utilizada,
    data_consulta,
    ip_origem,
    user_agent,
    created_at
)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    u.id,
    CASE 
        WHEN random() < 0.4 THEN 'busca_lente'
        WHEN random() < 0.7 THEN 'comparacao'
        WHEN random() < 0.9 THEN 'catalogo'
        ELSE 'relatorio'
    END,
    CASE 
        WHEN random() < 0.3 THEN '{"graduacao": "moderada", "tipo": "progressiva"}'
        WHEN random() < 0.6 THEN '{"marca": "Essilor", "categoria": "premium"}'
        ELSE '{"atividade": "digital", "orcamento": "medio"}'
    END::jsonb,
    (5 + random() * 25)::INTEGER, -- 5-30 resultados
    (50 + random() * 500)::INTEGER, -- 50-550ms
    CASE 
        WHEN random() < 0.5 THEN '["disponibilidade", "preco"]'
        ELSE '["marca", "categoria"]'
    END::jsonb,
    CASE 
        WHEN random() < 0.6 THEN 'score_desc'
        WHEN random() < 0.8 THEN 'preco_asc'
        ELSE 'nome_asc'
    END,
    NOW() - (random() * INTERVAL '180 days'),
    CASE 
        WHEN random() < 0.7 THEN '192.168.1.' || (1 + random() * 254)::INTEGER
        ELSE '10.0.0.' || (1 + random() * 254)::INTEGER
    END,
    CASE 
        WHEN random() < 0.6 THEN 'Mozilla/5.0 Chrome/91.0'
        WHEN random() < 0.8 THEN 'Mozilla/5.0 Firefox/89.0'
        ELSE 'Mozilla/5.0 Safari/14.1'
    END,
    NOW() - (random() * INTERVAL '180 days')
FROM meta_system.users u
WHERE u.tenant_id = (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo')
  AND u.ativo = true
CROSS JOIN generate_series(1, 150); -- 150 consultas por usuário

-- ===============================================
-- 4. MÉTRICAS DE PERFORMANCE DO SISTEMA
-- ===============================================

-- Inserir métricas diárias dos últimos 6 meses
INSERT INTO analytics.metricas_performance (
    id,
    tenant_id,
    data_metrica,
    total_consultas,
    tempo_medio_resposta,
    pico_consultas_hora,
    usuarios_ativos,
    decisoes_geradas,
    taxa_aceitacao_decisao,
    score_medio_confianca,
    tempo_medio_sessao,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    data_serie,
    -- Simular padrão realista: mais consultas em dias úteis
    CASE 
        WHEN EXTRACT(dow FROM data_serie) IN (0, 6) THEN 15 + (random() * 25)::INTEGER
        ELSE 40 + (random() * 60)::INTEGER
    END,
    180 + (random() * 120)::INTEGER, -- 180-300ms
    CASE 
        WHEN EXTRACT(dow FROM data_serie) IN (0, 6) THEN 8 + (random() * 10)::INTEGER
        ELSE 25 + (random() * 35)::INTEGER
    END,
    CASE 
        WHEN EXTRACT(dow FROM data_serie) IN (0, 6) THEN 2 + (random() * 3)::INTEGER
        ELSE 5 + (random() * 8)::INTEGER
    END,
    CASE 
        WHEN EXTRACT(dow FROM data_serie) IN (0, 6) THEN 3 + (random() * 8)::INTEGER
        ELSE 12 + (random() * 18)::INTEGER
    END,
    0.75 + (random() * 0.2), -- 75% a 95% de aceitação
    0.82 + (random() * 0.15), -- 82% a 97% de confiança
    (8 + random() * 12) * 60, -- 8-20 minutos em segundos
    data_serie,
    data_serie
FROM generate_series(
    CURRENT_DATE - INTERVAL '180 days',
    CURRENT_DATE - INTERVAL '1 day',
    INTERVAL '1 day'
) AS data_serie;

-- ===============================================
-- 5. PADRÕES DE USO E PREFERÊNCIAS
-- ===============================================

-- Inserir dados de uso por categoria de lente
INSERT INTO analytics.uso_categorias (
    id,
    tenant_id,
    categoria_lente,
    total_consultas,
    total_decisoes,
    taxa_conversao,
    ticket_medio,
    marca_mais_escolhida,
    mes_referencia,
    created_at
)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    categoria,
    consultas,
    decisoes,
    (decisoes::FLOAT / consultas * 100)::DECIMAL(5,2),
    ticket_medio,
    marca_preferida,
    mes_ref,
    mes_ref
FROM (
    SELECT 
        unnest(ARRAY['progressiva', 'monofocal', 'fotossensiveis', 'tratamento']) as categoria,
        (50 + random() * 200)::INTEGER as consultas,
        (15 + random() * 60)::INTEGER as decisoes,
        (300 + random() * 400)::DECIMAL(10,2) as ticket_medio,
        (ARRAY['Essilor', 'Zeiss', 'Hoya'])[ceil(random() * 3)] as marca_preferida,
        generate_series(
            DATE_TRUNC('month', CURRENT_DATE - INTERVAL '6 months'),
            DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month'),
            INTERVAL '1 month'
        ) as mes_ref
) dados;

-- ===============================================
-- 6. FEEDBACK E AVALIAÇÕES
-- ===============================================

-- Inserir feedback real de usuários sobre as decisões
INSERT INTO analytics.feedback_decisoes (
    id,
    tenant_id,
    decisao_id,
    usuario_id,
    nota_qualidade,
    nota_precisao,
    nota_utilidade,
    comentario,
    sugestao_melhoria,
    tempo_para_feedback,
    data_feedback,
    created_at
)
SELECT 
    gen_random_uuid(),
    d.tenant_id,
    d.id,
    u.id,
    7 + (random() * 3)::INTEGER, -- Nota 7-10
    7 + (random() * 3)::INTEGER,
    7 + (random() * 3)::INTEGER,
    CASE 
        WHEN random() < 0.3 THEN 'Sistema muito preciso, recomendação certeira!'
        WHEN random() < 0.6 THEN 'Boa análise, mas poderia considerar mais opções.'
        WHEN random() < 0.8 THEN 'Excelente para tomada de decisão rápida.'
        ELSE 'Muito útil, principalmente os critérios técnicos.'
    END,
    CASE 
        WHEN random() < 0.4 THEN 'Incluir mais informações sobre adaptação'
        WHEN random() < 0.7 THEN 'Melhorar interface de comparação'
        ELSE 'Adicionar histórico do paciente na análise'
    END,
    (1 + random() * 7)::INTEGER, -- 1-7 dias para dar feedback
    d.data_decisao + (1 + random() * 7)::INTEGER,
    NOW()
FROM scoring.decisoes d
JOIN meta_system.users u ON d.tenant_id = u.tenant_id
WHERE random() < 0.6 -- 60% das decisões recebem feedback
  AND u.ativo = true
LIMIT 100;

-- ===============================================
-- 7. EVOLUÇÃO DE SCORES E CALIBRAÇÃO
-- ===============================================

-- Histórico de evolução dos scores ao longo do tempo
INSERT INTO analytics.evolucao_scores (
    id,
    tenant_id,
    lente_id,
    score_anterior,
    score_atual,
    criterio_alterado,
    motivo_alteracao,
    impacto_decisoes,
    data_alteracao,
    usuario_alteracao,
    created_at
)
SELECT 
    gen_random_uuid(),
    l.tenant_id,
    l.id,
    ls.score - (5 + random() * 10), -- Score anterior (5-15 pontos menor)
    ls.score,
    c.nome,
    CASE 
        WHEN random() < 0.3 THEN 'Feedback dos usuários'
        WHEN random() < 0.6 THEN 'Atualização de dados do fornecedor'
        WHEN random() < 0.8 THEN 'Análise de performance'
        ELSE 'Calibração automática do sistema'
    END,
    (random() * 20)::INTEGER, -- Impacto em 0-20 decisões
    NOW() - (random() * INTERVAL '120 days'),
    'sistema',
    NOW() - (random() * INTERVAL '120 days')
FROM lens_catalog.lentes l
JOIN scoring.lens_scores ls ON l.id = ls.lente_id
JOIN scoring.criterios_avaliacao c ON ls.criterio_id = c.id
WHERE random() < 0.2; -- 20% dos scores tiveram alteração

-- ===============================================
-- 8. RELATÓRIOS CONSOLIDADOS
-- ===============================================

-- View para dashboard executivo
CREATE OR REPLACE VIEW analytics.v_dashboard_executivo AS
SELECT 
    DATE_TRUNC('month', mp.data_metrica) as mes,
    SUM(mp.total_consultas) as consultas_mes,
    SUM(mp.decisoes_geradas) as decisoes_mes,
    AVG(mp.taxa_aceitacao_decisao)::DECIMAL(5,2) as taxa_aceitacao_media,
    AVG(mp.score_medio_confianca)::DECIMAL(5,2) as confianca_media,
    AVG(mp.tempo_medio_resposta)::INTEGER as tempo_resposta_medio
FROM analytics.metricas_performance mp
WHERE mp.data_metrica >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY DATE_TRUNC('month', mp.data_metrica)
ORDER BY mes DESC;

-- View para análise de ROI
CREATE OR REPLACE VIEW analytics.v_roi_sistema AS
SELECT 
    m.nome as marca,
    COUNT(d.id) as decisoes_geradas,
    COUNT(CASE WHEN d.resultado_real = 'decisao_aceita' THEN 1 END) as decisoes_aceitas,
    AVG(l.preco_venda) as ticket_medio,
    SUM(CASE WHEN d.resultado_real = 'decisao_aceita' THEN l.preco_venda ELSE 0 END) as receita_gerada,
    AVG(d.confianca_decisao)::DECIMAL(5,2) as confianca_media
FROM scoring.decisoes d
JOIN lens_catalog.lentes l ON d.lente_recomendada_id = l.id
JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE d.data_decisao >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY m.id, m.nome
ORDER BY receita_gerada DESC;

COMMIT;

-- Remover função temporária
DROP FUNCTION random_date_last_6_months();

-- ===============================================
-- VERIFICAÇÃO DOS DADOS INSERIDOS
-- ===============================================

-- Verificar decisões por mês
SELECT 
    DATE_TRUNC('month', data_decisao) as mes,
    COUNT(*) as decisoes,
    AVG(score_recomendada)::DECIMAL(5,2) as score_medio,
    COUNT(CASE WHEN resultado_real = 'decisao_aceita' THEN 1 END) as aceitas
FROM scoring.decisoes
WHERE data_decisao >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY DATE_TRUNC('month', data_decisao)
ORDER BY mes;

-- Verificar métricas de performance
SELECT 
    COUNT(*) as dias_com_metricas,
    AVG(total_consultas)::INTEGER as consultas_media_dia,
    AVG(decisoes_geradas)::INTEGER as decisoes_media_dia,
    AVG(taxa_aceitacao_decisao)::DECIMAL(5,2) as taxa_aceitacao_media
FROM analytics.metricas_performance
WHERE data_metrica >= CURRENT_DATE - INTERVAL '6 months';

-- Verificar feedback
SELECT 
    AVG(nota_qualidade)::DECIMAL(3,1) as nota_qualidade_media,
    AVG(nota_precisao)::DECIMAL(3,1) as nota_precisao_media,
    AVG(nota_utilidade)::DECIMAL(3,1) as nota_utilidade_media,
    COUNT(*) as total_feedbacks
FROM analytics.feedback_decisoes;

-- Estatísticas finais simulação
SELECT 
    'DECISOES_HISTORICAS' as tipo_dado,
    COUNT(*) as registros
FROM scoring.decisoes
WHERE data_decisao >= CURRENT_DATE - INTERVAL '6 months'

UNION ALL

SELECT 
    'METRICAS_PERFORMANCE' as tipo_dado,
    COUNT(*) as registros
FROM analytics.metricas_performance

UNION ALL

SELECT 
    'CONSULTAS_SISTEMA' as tipo_dado,
    COUNT(*) as registros
FROM analytics.consultas_sistema

UNION ALL

SELECT 
    'FEEDBACK_DECISOES' as tipo_dado,
    COUNT(*) as registros
FROM analytics.feedback_decisoes;

-- ===============================================
-- LOG DE EXECUÇÃO
-- ===============================================

-- Registrar execução do script
INSERT INTO meta_system.logs_sistema (
    id,
    tenant_id,
    nivel,
    categoria,
    mensagem,
    detalhes,
    created_at
) VALUES (
    gen_random_uuid(),
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    'INFO',
    'DATABASE_SEED',
    'Script 006_dados_simulados.sql executado com sucesso',
    '{"script": "006_dados_simulados.sql", "periodo_simulado": "6_meses", "decisoes_geradas": "400+", "metricas_dias": 180, "views_criadas": 2}'::jsonb,
    NOW()
);

-- ===============================================
-- FIM DO SCRIPT 006_dados_simulados.sql
-- ===============================================