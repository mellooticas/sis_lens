-- ===============================================
-- 003_catalogo_zeiss.sql
-- Catálogo Técnico Completo - ZEISS
-- Data: 04/10/2025
-- ===============================================

-- Informações sobre a ZEISS:
-- - Líder mundial em óptica premium
-- - Especializada em tecnologia Individual e Digital
-- - SmartLife: Lente para era digital
-- - DuraVision: Tratamentos de última geração

BEGIN;

-- ===============================================
-- 1. PRODUTOS ZEISS - LINHA SMARTLIFE
-- ===============================================

-- SmartLife Individual Digital
INSERT INTO lens_catalog.lentes (
    id,
    tenant_id,
    marca_id,
    nome,
    descricao,
    tipo,
    categoria,
    design,
    material,
    indice_refracao,
    diametro,
    curva_base,
    preco_custo,
    preco_venda,
    ativo,
    especificacoes_tecnicas,
    created_at,
    updated_at
) VALUES 
(
    'c5e7f3a9-8b2d-4c1e-9f6a-5d8b7e3a2f1c',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss'),
    'SmartLife Individual 1.5',
    'Lente progressiva digital personalizada para era digital. Visão nítida em todas as distâncias com foco otimizado para dispositivos.',
    'progressiva',
    'premium',
    'individual',
    'organico',
    1.5,
    75.0,
    6.0,
    285.00,
    570.00,
    true,
    '{
        "corredor": 14,
        "potencia_adicao": "1.00 a 3.50",
        "cilindro_maximo": 6.00,
        "tecnologia": "SmartLife Digital Technology",
        "zona_digital": "Otimizada para 40-60cm",
        "design": "Individual baseado em parâmetros biométricos",
        "tratamento_incluso": "DuraVision BlueProtect",
        "garantia": "24 meses",
        "tempo_adaptacao": "1-3 dias"
    }'::jsonb,
    NOW(),
    NOW()
),
(
    'a9f8e7d6-c5b4-3a2f-1e9d-8c7b6a5f4e3d',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss'),
    'SmartLife Individual 1.67',
    'Versão ultra-fina da SmartLife Individual. Ideal para graduações altas mantendo estética premium.',
    'progressiva',
    'premium',
    'individual',
    'organico',
    1.67,
    70.0,
    6.0,
    385.00,
    770.00,
    true,
    '{
        "corredor": 14,
        "potencia_adicao": "1.00 a 3.50",
        "cilindro_maximo": 6.00,
        "tecnologia": "SmartLife Digital Technology",
        "espessura": "30% mais fina que 1.5",
        "peso": "25% mais leve",
        "design": "Individual baseado em parâmetros biométricos",
        "tratamento_incluso": "DuraVision BlueProtect",
        "garantia": "24 meses",
        "indicacao": "Graduações acima de ±3.00"
    }'::jsonb,
    NOW(),
    NOW()
),
(
    'f2e1d9c8-b7a6-5f4e-3d2c-1b9a8f7e6d5c',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss'),
    'SmartLife Progressive',
    'Lente progressiva com tecnologia SmartLife para excelente visão intermediária e de perto.',
    'progressiva',
    'standard',
    'free-form',
    'organico',
    1.5,
    75.0,
    6.0,
    185.00,
    370.00,
    true,
    '{
        "corredor": 17,
        "potencia_adicao": "0.75 a 3.50",
        "cilindro_maximo": 4.00,
        "tecnologia": "SmartLife Technology",
        "zona_intermediaria": "40% maior que design convencional",
        "design": "Free-form otimizado",
        "tratamento_incluso": "Básico anti-risco",
        "garantia": "12 meses",
        "tempo_adaptacao": "3-7 dias"
    }'::jsonb,
    NOW(),
    NOW()
);

-- ===============================================
-- 2. PRODUTOS ZEISS - LINHA INDIVIDUAL
-- ===============================================

-- Individual Progressive
INSERT INTO lens_catalog.lentes (
    id,
    tenant_id,
    marca_id,
    nome,
    descricao,
    tipo,
    categoria,
    design,
    material,
    indice_refracao,
    diametro,
    curva_base,
    preco_custo,
    preco_venda,
    ativo,
    especificacoes_tecnicas,
    created_at,
    updated_at
) VALUES 
(
    'd8c7b6a5-f4e3-2d1c-9b8a-7f6e5d4c3b2a',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss'),
    'Individual Progressive 1.5',
    'Lente progressiva individual fabricada com parâmetros pessoais únicos para máximo conforto visual.',
    'progressiva',
    'premium',
    'individual',
    'organico',
    1.5,
    75.0,
    6.0,
    265.00,
    530.00,
    true,
    '{
        "corredor": 15,
        "potencia_adicao": "0.75 a 3.50",
        "cilindro_maximo": 6.00,
        "parametros_individuais": ["DNP", "Altura da pupila", "Ângulo pantoscópico", "Distância vértice"],
        "design": "100% personalizado",
        "tecnologia": "Individual Technology",
        "tratamento_incluso": "DuraVision",
        "garantia": "24 meses",
        "tempo_adaptacao": "Imediata"
    }'::jsonb,
    NOW(),
    NOW()
),
(
    'b5a4f3e2-d1c9-8b7a-6f5e-4d3c2b1a9f8e',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss'),
    'Individual Single Vision 1.5',
    'Lente monofocal individual com design otimizado para cada usuário específico.',
    'monofocal',
    'premium',
    'individual',
    'organico',
    1.5,
    75.0,
    6.0,
    125.00,
    250.00,
    true,
    '{
        "potencia_esferica": "-20.00 a +12.00",
        "cilindro_maximo": 6.00,
        "parametros_individuais": ["DNP", "Altura da pupila", "Ângulo pantoscópico", "Distância vértice"],
        "design": "Individual otimizado",
        "tecnologia": "Individual Technology",
        "campo_visual": "30% maior que design esférico",
        "tratamento_incluso": "DuraVision",
        "garantia": "12 meses"
    }'::jsonb,
    NOW(),
    NOW()
);

-- ===============================================
-- 3. TRATAMENTOS ZEISS - DURAVISION
-- ===============================================

-- Inserir tratamentos no catálogo
INSERT INTO lens_catalog.lentes (
    id,
    tenant_id,
    marca_id,
    nome,
    descricao,
    tipo,
    categoria,
    design,
    material,
    indice_refracao,
    diametro,
    curva_base,
    preco_custo,
    preco_venda,
    ativo,
    especificacoes_tecnicas,
    created_at,
    updated_at
) VALUES 
(
    'e7d6c5b4-a3f2-1e9d-8c7b-6a5f4e3d2c1b',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss'),
    'DuraVision Platinum',
    'Tratamento premium anti-reflexo com máxima resistência e facilidade de limpeza.',
    'tratamento',
    'premium',
    'multicamada',
    'coating',
    0.0,
    0.0,
    0.0,
    85.00,
    170.00,
    true,
    '{
        "camadas": 9,
        "resistencia_risco": "Máxima - Ion Shield",
        "facilidade_limpeza": "Efeito escorregadio - LotuTec",
        "anti_reflexo": "99.5% redução de reflexos",
        "durabilidade": "3x mais resistente que AR convencional",
        "aplicacao": "Todas as lentes ZEISS",
        "garantia": "24 meses contra descamação",
        "certificacao": "ZEISS Quality"
    }'::jsonb,
    NOW(),
    NOW()
),
(
    'c1b9a8f7-e6d5-4c3b-2a1f-9e8d7c6b5a4f',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss'),
    'DuraVision BlueProtect',
    'Tratamento que bloqueia luz azul nociva mantendo cores naturais. Ideal para usuários de telas.',
    'tratamento',
    'premium',
    'blue_light',
    'coating',
    0.0,
    0.0,
    0.0,
    95.00,
    190.00,
    true,
    '{
        "bloqueio_luz_azul": "40% (400-440nm)",
        "cores": "Mantém cores naturais",
        "reflexos_residuais": "Azul claro discreto",
        "camadas": 7,
        "anti_reflexo": "Incluído",
        "facilidade_limpeza": "LotuTec",
        "indicacao": "Usuários intensos de telas digitais",
        "garantia": "24 meses",
        "certificacao": "ZEISS BlueGuard Technology"
    }'::jsonb,
    NOW(),
    NOW()
);

-- ===============================================
-- 4. FOTOSSENSÍVEIS ZEISS - PHOTOFUSION
-- ===============================================

INSERT INTO lens_catalog.lentes (
    id,
    tenant_id,
    marca_id,
    nome,
    descricao,
    tipo,
    categoria,
    design,
    material,
    indice_refracao,
    diametro,
    curva_base,
    preco_custo,
    preco_venda,
    ativo,
    especificacoes_tecnicas,
    created_at,
    updated_at
) VALUES 
(
    'a4f3e2d1-c9b8-7a6f-5e4d-3c2b1a9f8e7d',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss'),
    'PhotoFusion Clear 1.5',
    'Lente fotossensível com ativação rápida e retorno ao claro mais veloz do mercado.',
    'fotossensiveis',
    'premium',
    'photofusion',
    'organico',
    1.5,
    75.0,
    6.0,
    165.00,
    330.00,
    true,
    '{
        "ativacao": "15 segundos",
        "desativacao": "90 segundos a 23°C",
        "temperatura_operacao": "-5°C a +45°C",
        "protecao_uv": "100% UV até 400nm",
        "escurecimento_maximo": "85%",
        "cor_ativada": "Cinza neutro",
        "tecnologia": "PhotoFusion Technology",
        "compatibilidade": "Todas as graduações",
        "tratamento_incluso": "DuraVision",
        "garantia": "12 meses"
    }'::jsonb,
    NOW(),
    NOW()
),
(
    'f8e7d6c5-b4a3-2f1e-9d8c-7b6a5f4e3d2c',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss'),
    'PhotoFusion Brown 1.5',
    'Versão marrom da PhotoFusion, oferece maior contraste e é ideal para dirigir.',
    'fotossensiveis',
    'premium',
    'photofusion',
    'organico',
    1.5,
    75.0,
    6.0,
    165.00,
    330.00,
    true,
    '{
        "ativacao": "15 segundos",
        "desativacao": "90 segundos a 23°C",
        "temperatura_operacao": "-5°C a +45°C",
        "protecao_uv": "100% UV até 400nm",
        "escurecimento_maximo": "85%",
        "cor_ativada": "Marrom quente",
        "contraste": "Aumenta contraste para dirigir",
        "tecnologia": "PhotoFusion Technology",
        "compatibilidade": "Todas as graduações",
        "tratamento_incluso": "DuraVision",
        "garantia": "12 meses"
    }'::jsonb,
    NOW(),
    NOW()
);

-- ===============================================
-- 5. CONTROLE DE ESTOQUE - ZEISS
-- ===============================================

-- Inserir estoque para todas as lentes ZEISS
INSERT INTO logistics.estoque (
    id,
    tenant_id,
    lente_id,
    laboratorio_id,
    quantidade_disponivel,
    quantidade_minima,
    quantidade_reservada,
    custo_medio,
    data_ultima_entrada,
    data_ultima_saida,
    localizacao,
    status,
    observacoes,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    l.tenant_id,
    l.id,
    (SELECT id FROM suppliers.laboratorios WHERE nome = 'Lab Central Óptica' LIMIT 1),
    CASE 
        WHEN l.categoria = 'premium' THEN 25
        ELSE 40
    END,
    10,
    0,
    l.preco_custo,
    NOW() - INTERVAL '7 days',
    NOW() - INTERVAL '2 days',
    CASE 
        WHEN l.indice_refracao = 1.5 THEN 'A1-ZEISS-15'
        WHEN l.indice_refracao = 1.67 THEN 'A1-ZEISS-167'
        ELSE 'A1-ZEISS-TRAT'
    END,
    'disponivel',
    'Estoque de lançamento - linha ZEISS completa',
    NOW(),
    NOW()
FROM lens_catalog.lentes l
WHERE l.marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss')
  AND l.id IN (
    'c5e7f3a9-8b2d-4c1e-9f6a-5d8b7e3a2f1c',
    'a9f8e7d6-c5b4-3a2f-1e9d-8c7b6a5f4e3d',
    'f2e1d9c8-b7a6-5f4e-3d2c-1b9a8f7e6d5c',
    'd8c7b6a5-f4e3-2d1c-9b8a-7f6e5d4c3b2a',
    'b5a4f3e2-d1c9-8b7a-6f5e-4d3c2b1a9f8e',
    'e7d6c5b4-a3f2-1e9d-8c7b-6a5f4e3d2c1b',
    'c1b9a8f7-e6d5-4c3b-2a1f-9e8d7c6b5a4f',
    'a4f3e2d1-c9b8-7a6f-5e4d-3c2b1a9f8e7d',
    'f8e7d6c5-b4a3-2f1e-9d8c-7b6a5f4e3d2c'
);

-- ===============================================
-- 6. SCORING ZEISS
-- ===============================================

-- Inserir scores para lentes ZEISS
INSERT INTO scoring.lens_scores (
    id,
    tenant_id,
    lente_id,
    criterio_id,
    score,
    peso,
    justificativa,
    data_avaliacao,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    l.tenant_id,
    l.id,
    c.id,
    CASE 
        WHEN c.nome = 'Qualidade Óptica' THEN 
            CASE WHEN l.categoria = 'premium' THEN 95 ELSE 88 END
        WHEN c.nome = 'Custo-Benefício' THEN 
            CASE WHEN l.categoria = 'premium' THEN 82 ELSE 91 END
        WHEN c.nome = 'Disponibilidade' THEN 88
        WHEN c.nome = 'Tempo de Entrega' THEN 85
        WHEN c.nome = 'Suporte Técnico' THEN 93
    END,
    c.peso,
    CASE 
        WHEN c.nome = 'Qualidade Óptica' THEN 'ZEISS é referência mundial em óptica premium'
        WHEN c.nome = 'Custo-Benefício' THEN 'Preço premium justificado pela tecnologia'
        WHEN c.nome = 'Disponibilidade' THEN 'Boa disponibilidade no Brasil'
        WHEN c.nome = 'Tempo de Entrega' THEN 'Individual leva 7-10 dias'
        WHEN c.nome = 'Suporte Técnico' THEN 'Excelente suporte técnico e treinamento'
    END,
    NOW(),
    NOW(),
    NOW()
FROM lens_catalog.lentes l
CROSS JOIN scoring.criterios_avaliacao c
WHERE l.marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss')
  AND l.id IN (
    'c5e7f3a9-8b2d-4c1e-9f6a-5d8b7e3a2f1c',
    'a9f8e7d6-c5b4-3a2f-1e9d-8c7b6a5f4e3d',
    'f2e1d9c8-b7a6-5f4e-3d2c-1b9a8f7e6d5c',
    'd8c7b6a5-f4e3-2d1c-9b8a-7f6e5d4c3b2a',
    'b5a4f3e2-d1c9-8b7a-6f5e-4d3c2b1a9f8e',
    'e7d6c5b4-a3f2-1e9d-8c7b-6a5f4e3d2c1b',
    'c1b9a8f7-e6d5-4c3b-2a1f-9e8d7c6b5a4f',
    'a4f3e2d1-c9b8-7a6f-5e4d-3c2b1a9f8e7d',
    'f8e7d6c5-b4a3-2f1e-9d8c-7b6a5f4e3d2c'
);

COMMIT;

-- ===============================================
-- VERIFICAÇÃO DOS DADOS INSERIDOS
-- ===============================================

-- Verificar lentes ZEISS inseridas
SELECT 
    nome,
    tipo,
    categoria,
    indice_refracao,
    preco_venda,
    ativo
FROM lens_catalog.lentes 
WHERE marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss')
ORDER BY categoria DESC, tipo, indice_refracao;

-- Verificar estoque ZEISS
SELECT 
    l.nome,
    e.quantidade_disponivel,
    e.localizacao,
    e.status
FROM logistics.estoque e
JOIN lens_catalog.lentes l ON e.lente_id = l.id
WHERE l.marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss')
ORDER BY l.nome;

-- Estatísticas finais ZEISS
SELECT 
    'ZEISS' as marca,
    COUNT(*) as total_produtos,
    COUNT(CASE WHEN tipo = 'progressiva' THEN 1 END) as progressivas,
    COUNT(CASE WHEN tipo = 'monofocal' THEN 1 END) as monofocais,
    COUNT(CASE WHEN tipo = 'fotossensiveis' THEN 1 END) as fotossensiveis,
    COUNT(CASE WHEN tipo = 'tratamento' THEN 1 END) as tratamentos,
    AVG(preco_venda)::DECIMAL(10,2) as preco_medio
FROM lens_catalog.lentes 
WHERE marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Zeiss');

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
    'Script 003_catalogo_zeiss.sql executado com sucesso',
    '{"script": "003_catalogo_zeiss.sql", "produtos_inseridos": 9, "marca": "Zeiss", "tipos": ["progressiva", "monofocal", "tratamento", "fotossensiveis"]}'::jsonb,
    NOW()
);

-- ===============================================
-- FIM DO SCRIPT 003_catalogo_zeiss.sql
-- ===============================================