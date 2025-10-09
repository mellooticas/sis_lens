-- ===============================================
-- 005_precos_comercial.sql
-- Estrutura Comercial Completa - Preços, Condições e Contratos
-- Data: 04/10/2025
-- ===============================================

-- Este script cria a estrutura comercial completa:
-- - Tabelas de preço por laboratório
-- - Condições comerciais e descontos
-- - Contratos e prazos de pagamento
-- - Promoções e campanhas ativas

BEGIN;

-- ===============================================
-- 1. TABELAS DE PREÇO - LABORATÓRIO CENTRAL ÓPTICA
-- ===============================================

-- Preços para produtos Essilor via Lab Central
INSERT INTO commercial.tabelas_preco (
    id,
    tenant_id,
    laboratorio_id,
    lente_id,
    preco_custo,
    preco_venda_sugerido,
    desconto_maximo,
    margem_minima,
    data_inicio_vigencia,
    data_fim_vigencia,
    ativa,
    observacoes,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    l.tenant_id,
    lab.id,
    l.id,
    l.preco_custo * 0.95, -- 5% desconto no custo
    l.preco_venda,
    CASE 
        WHEN l.categoria = 'premium' THEN 15.0
        ELSE 20.0
    END,
    CASE 
        WHEN l.categoria = 'premium' THEN 45.0
        ELSE 40.0
    END,
    '2025-01-01'::date,
    '2025-12-31'::date,
    true,
    'Tabela oficial 2025 - Parcerias preferenciais Essilor',
    NOW(),
    NOW()
FROM lens_catalog.lentes l
CROSS JOIN suppliers.laboratorios lab
WHERE l.marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Essilor')
  AND lab.nome = 'Lab Central Óptica'
  AND l.tenant_id = (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo');

-- Preços para produtos Zeiss via Lab Central
INSERT INTO commercial.tabelas_preco (
    id,
    tenant_id,
    laboratorio_id,
    lente_id,
    preco_custo,
    preco_venda_sugerido,
    desconto_maximo,
    margem_minima,
    data_inicio_vigencia,
    data_fim_vigencia,
    ativa,
    observacoes,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    l.tenant_id,
    lab.id,
    l.id,
    l.preco_custo * 0.98, -- 2% desconto no custo
    l.preco_venda,
    CASE 
        WHEN l.categoria = 'premium' THEN 12.0
        ELSE 18.0
    END,
    CASE 
        WHEN l.categoria = 'premium' THEN 48.0
        ELSE 42.0
    END,
    '2025-01-01'::date,
    '2025-12-31'::date,
    true,
    'Tabela oficial 2025 - Distribuição autorizada Zeiss',
    NOW(),
    NOW()
FROM lens_catalog.lentes l
CROSS JOIN suppliers.laboratorios lab
WHERE l.marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss')
  AND lab.nome = 'Lab Central Óptica'
  AND l.tenant_id = (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo');

-- ===============================================
-- 2. TABELAS DE PREÇO - LABORATÓRIO ÓPTICO NACIONAL
-- ===============================================

-- Preços para produtos Hoya via Lab Nacional
INSERT INTO commercial.tabelas_preco (
    id,
    tenant_id,
    laboratorio_id,
    lente_id,
    preco_custo,
    preco_venda_sugerido,
    desconto_maximo,
    margem_minima,
    data_inicio_vigencia,
    data_fim_vigencia,
    ativa,
    observacoes,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    l.tenant_id,
    lab.id,
    l.id,
    l.preco_custo * 0.92, -- 8% desconto no custo
    l.preco_venda,
    CASE 
        WHEN l.categoria = 'premium' THEN 18.0
        ELSE 25.0
    END,
    CASE 
        WHEN l.categoria = 'premium' THEN 42.0
        ELSE 38.0
    END,
    '2025-01-01'::date,
    '2025-12-31'::date,
    true,
    'Tabela oficial 2025 - Representação exclusiva Hoya',
    NOW(),
    NOW()
FROM lens_catalog.lentes l
CROSS JOIN suppliers.laboratorios lab
WHERE l.marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya')
  AND lab.nome = 'Laboratório Óptico Nacional'
  AND l.tenant_id = (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo');

-- Preços alternativos Essilor via Lab Nacional (concorrência)
INSERT INTO commercial.tabelas_preco (
    id,
    tenant_id,
    laboratorio_id,
    lente_id,
    preco_custo,
    preco_venda_sugerido,
    desconto_maximo,
    margem_minima,
    data_inicio_vigencia,
    data_fim_vigencia,
    ativa,
    observacoes,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    l.tenant_id,
    lab.id,
    l.id,
    l.preco_custo * 1.05, -- 5% mais caro (não é distribuidor preferencial)
    l.preco_venda * 1.03,
    10.0, -- Menor flexibilidade
    35.0, -- Margem menor
    '2025-01-01'::date,
    '2025-12-31'::date,
    true,
    'Tabela secundária - Distribuição indireta Essilor',
    NOW(),
    NOW()
FROM lens_catalog.lentes l
CROSS JOIN suppliers.laboratorios lab
WHERE l.marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Essilor')
  AND lab.nome = 'Laboratório Óptico Nacional'
  AND l.tenant_id = (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo')
  AND l.categoria = 'standard'; -- Só produtos standard disponíveis

-- ===============================================
-- 3. CONDIÇÕES COMERCIAIS POR LABORATÓRIO
-- ===============================================

-- Condições Lab Central Óptica
INSERT INTO commercial.condicoes_comerciais (
    id,
    tenant_id,
    laboratorio_id,
    representante_id,
    prazo_pagamento_dias,
    desconto_pagamento_vista,
    desconto_volume_mensal,
    meta_mensal_minima,
    comissao_representante,
    data_inicio_vigencia,
    data_fim_vigencia,
    ativa,
    observacoes,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM suppliers.laboratorios WHERE nome = 'Lab Central Óptica'),
    (SELECT id FROM suppliers.representantes WHERE nome = 'Carlos Silva'),
    28, -- 28 dias
    3.5, -- 3.5% desconto à vista
    CASE 
        WHEN 5000 THEN 2.0  -- R$ 5k = 2%
        WHEN 10000 THEN 4.0 -- R$ 10k = 4%
        WHEN 20000 THEN 7.0 -- R$ 20k = 7%
        ELSE 0.0
    END,
    3000.00, -- Meta mínima R$ 3.000
    4.5, -- 4.5% comissão
    '2025-01-01'::date,
    '2025-12-31'::date,
    true,
    'Condições preferenciais - Parceria estratégica Lab Central',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM suppliers.laboratorios WHERE nome = 'Laboratório Óptico Nacional'),
    (SELECT id FROM suppliers.representantes WHERE nome = 'Ana Costa'),
    35, -- 35 dias
    2.0, -- 2% desconto à vista
    CASE 
        WHEN 4000 THEN 1.5  -- R$ 4k = 1.5%
        WHEN 8000 THEN 3.0  -- R$ 8k = 3%
        WHEN 15000 THEN 5.5 -- R$ 15k = 5.5%
        ELSE 0.0
    END,
    2500.00, -- Meta mínima R$ 2.500
    5.0, -- 5% comissão
    '2025-01-01'::date,
    '2025-12-31'::date,
    true,
    'Condições padrão - Laboratório Nacional com foco em Hoya',
    NOW(),
    NOW()
);

-- ===============================================
-- 4. CAMPANHAS E PROMOÇÕES ATIVAS
-- ===============================================

-- Campanha Lançamento SmartLife Digital
INSERT INTO commercial.campanhas (
    id,
    tenant_id,
    nome,
    descricao,
    tipo,
    data_inicio,
    data_fim,
    ativa,
    condicoes,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    'Lançamento SmartLife Digital 2025',
    'Campanha especial de lançamento das lentes Zeiss SmartLife com condições promocionais.',
    'lancamento',
    '2025-01-15'::date,
    '2025-03-31'::date,
    true,
    '{
        "produtos_elegíveis": ["SmartLife Individual 1.5", "SmartLife Individual 1.67"],
        "desconto_adicional": 8.0,
        "quantidade_minima": 5,
        "brinde": "Kit adaptação digital",
        "laboratorio": "Lab Central Óptica",
        "meta_campanha": 50,
        "comissao_extra": 2.0
    }'::jsonb,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    'Combo Hoya iD + Sensity',
    'Promoção especial: comprando lente progressiva iD ganha desconto na fotossensível Sensity.',
    'combo',
    '2025-02-01'::date,
    '2025-04-30'::date,
    true,
    '{
        "produto_principal": "iD MyStyle V+",
        "produto_brinde": "Sensity",
        "desconto_combo": 15.0,
        "quantidade_minima": 2,
        "laboratorio": "Laboratório Óptico Nacional",
        "regra": "Para cada progressiva iD, 15% desconto na Sensity",
        "limite_por_cliente": 3
    }'::jsonb,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    'Essilor Quality Month',
    'Mês da qualidade Essilor com descontos progressivos por volume.',
    'volume',
    '2025-03-01'::date,
    '2025-03-31'::date,
    true,
    '{
        "marca": "Essilor",
        "escala_desconto": {
            "10_lentes": 5.0,
            "20_lentes": 8.0,
            "30_lentes": 12.0,
            "50_lentes": 18.0
        },
        "produtos_inclusos": "Toda linha Varilux e Crizal",
        "brinde_50_lentes": "Expositor premium Essilor",
        "comissao_extra": 3.0
    }'::jsonb,
    NOW(),
    NOW()
);

-- ===============================================
-- 5. CONTRATOS E ACORDOS COMERCIAIS
-- ===============================================

-- Inserir contratos na tabela de condições (estrutura estendida)
UPDATE commercial.condicoes_comerciais 
SET observacoes = observacoes || ' | CONTRATO: Exclusividade regional Essilor/Zeiss. Prazo 12 meses renovável. Meta anual: R$ 120.000. Desconto adicional 2% se atingir meta. Treinamento técnico incluso.'
WHERE laboratorio_id = (SELECT id FROM suppliers.laboratorios WHERE nome = 'Lab Central Óptica');

UPDATE commercial.condicoes_comerciais 
SET observacoes = observacoes || ' | CONTRATO: Representação preferencial Hoya. Prazo 24 meses. Meta anual: R$ 80.000. Material promocional fornecido. Suporte técnico dedicado.'
WHERE laboratorio_id = (SELECT id FROM suppliers.laboratorios WHERE nome = 'Laboratório Óptico Nacional');

-- ===============================================
-- 6. HISTÓRICO DE PREÇOS (SIMULADO)
-- ===============================================

-- Criar histórico de alterações de preço dos últimos 6 meses
INSERT INTO commercial.historico_precos (
    id,
    tenant_id,
    tabela_preco_id,
    preco_anterior,
    preco_novo,
    percentual_alteracao,
    motivo_alteracao,
    data_alteracao,
    usuario_alteracao,
    created_at
)
SELECT 
    gen_random_uuid(),
    tp.tenant_id,
    tp.id,
    tp.preco_custo * 1.08, -- Preço anterior (8% maior)
    tp.preco_custo,
    -7.4, -- Redução de 7.4%
    'Renegociação anual de preços - melhores condições obtidas',
    '2024-12-01'::date,
    'sistema',
    NOW()
FROM commercial.tabelas_preco tp
WHERE tp.ativa = true
  AND random() < 0.3; -- 30% dos produtos tiveram alteração

-- ===============================================
-- 7. RELATÓRIOS DE PERFORMANCE COMERCIAL
-- ===============================================

-- View para relatório de margens por laboratório
CREATE OR REPLACE VIEW commercial.v_margens_laboratorio AS
SELECT 
    l.nome as laboratorio,
    m.nome as marca,
    COUNT(tp.id) as produtos_tabela,
    AVG(tp.margem_minima) as margem_media,
    AVG(tp.desconto_maximo) as desconto_medio_maximo,
    SUM(tp.preco_venda_sugerido * COALESCE(e.quantidade_disponivel, 0)) as valor_estoque
FROM suppliers.laboratorios l
JOIN commercial.tabelas_preco tp ON l.id = tp.laboratorio_id
JOIN lens_catalog.lentes le ON tp.lente_id = le.id
JOIN lens_catalog.marcas m ON le.marca_id = m.id
LEFT JOIN logistics.estoque e ON le.id = e.lente_id AND l.id = e.laboratorio_id
WHERE tp.ativa = true
GROUP BY l.id, l.nome, m.id, m.nome
ORDER BY l.nome, m.nome;

-- View para análise de campanhas
CREATE OR REPLACE VIEW commercial.v_campanhas_ativas AS
SELECT 
    c.nome,
    c.tipo,
    c.data_inicio,
    c.data_fim,
    (c.data_fim - CURRENT_DATE) as dias_restantes,
    c.condicoes->>'desconto_adicional' as desconto,
    c.condicoes->>'quantidade_minima' as qty_minima,
    c.condicoes->>'laboratorio' as laboratorio_alvo
FROM commercial.campanhas c
WHERE c.ativa = true
  AND c.data_inicio <= CURRENT_DATE
  AND c.data_fim >= CURRENT_DATE
ORDER BY c.data_fim;

COMMIT;

-- ===============================================
-- VERIFICAÇÃO DOS DADOS INSERIDOS
-- ===============================================

-- Verificar tabelas de preço criadas
SELECT 
    l.nome as laboratorio,
    m.nome as marca,
    COUNT(*) as produtos_tabela,
    AVG(tp.preco_custo)::DECIMAL(10,2) as custo_medio,
    AVG(tp.preco_venda_sugerido)::DECIMAL(10,2) as venda_media,
    AVG(tp.margem_minima)::DECIMAL(5,2) as margem_media
FROM commercial.tabelas_preco tp
JOIN suppliers.laboratorios l ON tp.laboratorio_id = l.id
JOIN lens_catalog.lentes le ON tp.lente_id = le.id
JOIN lens_catalog.marcas m ON le.marca_id = m.id
WHERE tp.ativa = true
GROUP BY l.id, l.nome, m.id, m.nome
ORDER BY l.nome, m.nome;

-- Verificar condições comerciais
SELECT 
    l.nome as laboratorio,
    r.nome as representante,
    cc.prazo_pagamento_dias,
    cc.desconto_pagamento_vista,
    cc.meta_mensal_minima,
    cc.comissao_representante
FROM commercial.condicoes_comerciais cc
JOIN suppliers.laboratorios l ON cc.laboratorio_id = l.id
JOIN suppliers.representantes r ON cc.representante_id = r.id
WHERE cc.ativa = true;

-- Verificar campanhas ativas
SELECT 
    nome,
    tipo,
    data_inicio,
    data_fim,
    condicoes->>'desconto_adicional' as desconto
FROM commercial.campanhas
WHERE ativa = true
ORDER BY data_inicio;

-- Estatísticas finais comerciais
SELECT 
    'TABELAS_PRECO' as tabela,
    COUNT(*) as registros
FROM commercial.tabelas_preco
WHERE ativa = true

UNION ALL

SELECT 
    'CONDICOES_COMERCIAIS' as tabela,
    COUNT(*) as registros
FROM commercial.condicoes_comerciais
WHERE ativa = true

UNION ALL

SELECT 
    'CAMPANHAS' as tabela,
    COUNT(*) as registros
FROM commercial.campanhas
WHERE ativa = true

UNION ALL

SELECT 
    'HISTORICO_PRECOS' as tabela,
    COUNT(*) as registros
FROM commercial.historico_precos;

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
    'Script 005_precos_comercial.sql executado com sucesso',
    '{"script": "005_precos_comercial.sql", "tabelas_preco": "60+", "condicoes": 2, "campanhas": 3, "views_criadas": 2}'::jsonb,
    NOW()
);

-- ===============================================
-- FIM DO SCRIPT 005_precos_comercial.sql
-- ===============================================