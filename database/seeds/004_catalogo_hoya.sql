-- ===============================================
-- 004_catalogo_hoya.sql
-- Catálogo Técnico Completo - HOYA
-- Data: 04/10/2025
-- ===============================================

-- Informações sobre a HOYA:
-- - Pioneira em lentes progressivas no Japão
-- - Tecnologia iD (individual Design)
-- - Hi-Vision: tratamentos premium
-- - Sensity: fotossensíveis de nova geração

BEGIN;

-- ===============================================
-- 1. PRODUTOS HOYA - LINHA iD MyStyle
-- ===============================================

-- iD MyStyle V+ (Lifestyle)
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
    '9a8b7c6d-5e4f-3a2b-1c9d-8e7f6a5b4c3d',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya'),
    'iD MyStyle V+ Lifestyle 1.5',
    'Lente progressiva individual otimizada para estilo de vida ativo e uso equilibrado de longe e perto.',
    'progressiva',
    'premium',
    'individual',
    'organico',
    1.5,
    75.0,
    6.0,
    275.00,
    550.00,
    true,
    '{
        "corredor": 14,
        "potencia_adicao": "0.75 a 3.50",
        "cilindro_maximo": 6.00,
        "tecnologia": "iD Technology + BinocularEye Model",
        "design": "Individual baseado em estilo de vida",
        "otimizacao": "Visão dinâmica e atividades ao ar livre",
        "binocularity": "Processamento binocular simultâneo",
        "treatment_incluso": "Hi-Vision LongLife BlueControl",
        "garantia": "24 meses",
        "tempo_adaptacao": "Imediata"
    }'::jsonb,
    NOW(),
    NOW()
),
(
    '8f7e6d5c-4b3a-2f1e-9d8c-7b6a5f4e3d2c',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya'),
    'iD MyStyle V+ WorkStyle 1.5',
    'Lente progressiva individual otimizada para trabalho intenso de perto e uso de dispositivos digitais.',
    'progressiva',
    'premium',
    'individual',
    'organico',
    1.5,
    75.0,
    6.0,
    275.00,
    550.00,
    true,
    '{
        "corredor": 15,
        "potencia_adicao": "0.75 a 3.50",
        "cilindro_maximo": 6.00,
        "tecnologia": "iD Technology + BinocularEye Model",
        "design": "Individual otimizado para trabalho",
        "otimizacao": "Visão de perto estendida (40-80cm)",
        "zona_intermediaria": "50% maior para trabalho digital",
        "binocularity": "Processamento binocular simultâneo",
        "treatment_incluso": "Hi-Vision LongLife BlueControl",
        "garantia": "24 meses",
        "tempo_adaptacao": "Imediata"
    }'::jsonb,
    NOW(),
    NOW()
),
(
    'e2d1c9b8-a7f6-5e4d-3c2b-1a9f8e7d6c5b',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya'),
    'iD MyStyle V+ Lifestyle 1.67',
    'Versão ultra-fina da iD MyStyle Lifestyle para graduações altas mantendo conforto e estética.',
    'progressiva',
    'premium',
    'individual',
    'organico',
    1.67,
    70.0,
    6.0,
    375.00,
    750.00,
    true,
    '{
        "corredor": 14,
        "potencia_adicao": "0.75 a 3.50",
        "cilindro_maximo": 6.00,
        "tecnologia": "iD Technology + BinocularEye Model",
        "espessura": "35% mais fina que 1.5",
        "peso": "28% mais leve",
        "design": "Individual baseado em estilo de vida",
        "otimizacao": "Visão dinâmica e atividades ao ar livre",
        "binocularity": "Processamento binocular simultâneo",
        "treatment_incluso": "Hi-Vision LongLife BlueControl",
        "garantia": "24 meses",
        "indicacao": "Graduações acima de ±3.50"
    }'::jsonb,
    NOW(),
    NOW()
);

-- ===============================================
-- 2. PRODUTOS HOYA - LINHA iD HARMONY
-- ===============================================

-- iD Harmony (Progressiva Standard)
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
    'c5b4a3f2-e1d9-8c7b-6a5f-4e3d2c1b9a8f',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya'),
    'iD Harmony 1.5',
    'Lente progressiva com tecnologia iD oferecendo visão natural e confortável para uso geral.',
    'progressiva',
    'standard',
    'free-form',
    'organico',
    1.5,
    75.0,
    6.0,
    175.00,
    350.00,
    true,
    '{
        "corredor": 17,
        "potencia_adicao": "0.75 a 3.50",
        "cilindro_maximo": 4.00,
        "tecnologia": "iD Technology",
        "design": "Free-form otimizado",
        "zona_longe": "Ampla e natural",
        "zona_perto": "Confortável para leitura",
        "treatment_incluso": "Hi-Vision",
        "garantia": "12 meses",
        "tempo_adaptacao": "3-7 dias"
    }'::jsonb,
    NOW(),
    NOW()
);

-- ===============================================
-- 3. MONOFOCAIS HOYA - LINHA iD
-- ===============================================

-- iD Single Vision
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
    'a9f8e7d6-c5b4-3a2f-1e9d-8c7b6a5f4e3d',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya'),
    'iD Single Vision 1.5',
    'Lente monofocal com tecnologia iD proporcionando campo visual mais amplo e visão periférica otimizada.',
    'monofocal',
    'premium',
    'individual',
    'organico',
    1.5,
    75.0,
    6.0,
    115.00,
    230.00,
    true,
    '{
        "potencia_esferica": "-20.00 a +12.00",
        "cilindro_maximo": 6.00,
        "tecnologia": "iD Technology",
        "design": "Asférico otimizado individualmente",
        "campo_visual": "25% maior que design esférico",
        "aberracoes": "Minimizadas em toda superfície",
        "treatment_incluso": "Hi-Vision",
        "garantia": "12 meses",
        "indicacao": "Todas as graduações"
    }'::jsonb,
    NOW(),
    NOW()
),
(
    'f7e6d5c4-b3a2-1f9e-8d7c-6b5a4f3e2d1c',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya'),
    'iD Single Vision 1.67',
    'Versão ultra-fina da iD Single Vision para graduações altas com máximo conforto estético.',
    'monofocal',
    'premium',
    'individual',
    'organico',
    1.67,
    70.0,
    6.0,
    175.00,
    350.00,
    true,
    '{
        "potencia_esferica": "-15.00 a +10.00",
        "cilindro_maximo": 6.00,
        "tecnologia": "iD Technology",
        "espessura": "40% mais fina que 1.5",
        "peso": "30% mais leve",
        "design": "Asférico otimizado individualmente",
        "campo_visual": "25% maior que design esférico",
        "aberracoes": "Minimizadas em toda superfície",
        "treatment_incluso": "Hi-Vision",
        "garantia": "12 meses",
        "indicacao": "Graduações altas ±4.00+"
    }'::jsonb,
    NOW(),
    NOW()
);

-- ===============================================
-- 4. TRATAMENTOS HOYA - Hi-Vision
-- ===============================================

-- Hi-Vision LongLife BlueControl
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
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya'),
    'Hi-Vision LongLife BlueControl',
    'Tratamento premium anti-reflexo com proteção contra luz azul e máxima durabilidade.',
    'tratamento',
    'premium',
    'blue_light',
    'coating',
    0.0,
    0.0,
    0.0,
    90.00,
    180.00,
    true,
    '{
        "camadas": 8,
        "bloqueio_luz_azul": "35% (415-455nm)",
        "cores": "Mínima alteração de cor",
        "reflexos_residuais": "Azul suave",
        "resistencia_risco": "Super resistente",
        "facilidade_limpeza": "Revestimento hidrofóbico",
        "anti_reflexo": "99.4% redução reflexos",
        "durabilidade": "2x mais resistente que AR padrão",
        "garantia": "24 meses contra descamação",
        "certificacao": "HOYA BlueControl Technology"
    }'::jsonb,
    NOW(),
    NOW()
),
(
    'b2a1f9e8-d7c6-5b4a-3f2e-1d9c8b7a6f5e',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya'),
    'Hi-Vision LongLife',
    'Tratamento anti-reflexo premium com máxima resistência e facilidade de limpeza.',
    'tratamento',
    'premium',
    'multicamada',
    'coating',
    0.0,
    0.0,
    0.0,
    75.00,
    150.00,
    true,
    '{
        "camadas": 7,
        "resistencia_risco": "Máxima durabilidade",
        "facilidade_limpeza": "Revestimento hidrofóbico",
        "anti_reflexo": "99.3% redução reflexos",
        "cores": "Totalmente neutro",
        "reflexos_residuais": "Verde claro discreto",
        "durabilidade": "2x mais resistente",
        "aplicacao": "Todas as lentes HOYA",
        "garantia": "24 meses",
        "certificacao": "HOYA LongLife Technology"
    }'::jsonb,
    NOW(),
    NOW()
);

-- ===============================================
-- 5. FOTOSSENSÍVEIS HOYA - SENSITY
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
    'e6d5c4b3-a2f1-9e8d-7c6b-5a4f3e2d1c9b',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya'),
    'Sensity Dark 1.5',
    'Lente fotossensível com escurecimento intenso, ideal para alta sensibilidade à luz.',
    'fotossensiveis',
    'premium',
    'sensity',
    'organico',
    1.5,
    75.0,
    6.0,
    155.00,
    310.00,
    true,
    '{
        "ativacao": "20 segundos",
        "desativacao": "2 minutos a 23°C",
        "temperatura_operacao": "-10°C a +50°C",
        "protecao_uv": "100% UV até 400nm",
        "escurecimento_maximo": "90%",
        "cor_ativada": "Cinza escuro",
        "tecnologia": "Sensity Technology",
        "performance_carro": "Ativação parcial no carro",
        "compatibilidade": "Todas as graduações",
        "treatment_incluso": "Hi-Vision",
        "garantia": "12 meses",
        "indicacao": "Alta sensibilidade à luz"
    }'::jsonb,
    NOW(),
    NOW()
),
(
    'c9b8a7f6-e5d4-3c2b-1a9f-8e7d6c5b4a3f',
    (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo'),
    (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya'),
    'Sensity Light 1.5',
    'Lente fotossensível com escurecimento suave, ideal para uso diário confortável.',
    'fotossensiveis',
    'standard',
    'sensity',
    'organico',
    1.5,
    75.0,
    6.0,
    145.00,
    290.00,
    true,
    '{
        "ativacao": "25 segundos",
        "desativacao": "3 minutos a 23°C",
        "temperatura_operacao": "-10°C a +50°C",
        "protecao_uv": "100% UV até 400nm",
        "escurecimento_maximo": "75%",
        "cor_ativada": "Cinza claro",
        "tecnologia": "Sensity Technology",
        "performance_carro": "Escurecimento mínimo",
        "compatibilidade": "Todas as graduações",
        "treatment_incluso": "Hi-Vision",
        "garantia": "12 meses",
        "indicacao": "Uso diário confortável"
    }'::jsonb,
    NOW(),
    NOW()
);

-- ===============================================
-- 6. CONTROLE DE ESTOQUE - HOYA
-- ===============================================

-- Inserir estoque para todas as lentes HOYA
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
    (SELECT id FROM suppliers.laboratorios WHERE nome = 'Laboratório Óptico Nacional' LIMIT 1),
    CASE 
        WHEN l.categoria = 'premium' THEN 30
        ELSE 45
    END,
    15,
    0,
    l.preco_custo,
    NOW() - INTERVAL '5 days',
    NOW() - INTERVAL '1 day',
    CASE 
        WHEN l.indice_refracao = 1.5 THEN 'B2-HOYA-15'
        WHEN l.indice_refracao = 1.67 THEN 'B2-HOYA-167'
        ELSE 'B2-HOYA-TRAT'
    END,
    'disponivel',
    'Estoque HOYA - linha iD completa disponível',
    NOW(),
    NOW()
FROM lens_catalog.lentes l
WHERE l.marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya')
  AND l.id IN (
    '9a8b7c6d-5e4f-3a2b-1c9d-8e7f6a5b4c3d',
    '8f7e6d5c-4b3a-2f1e-9d8c-7b6a5f4e3d2c',
    'e2d1c9b8-a7f6-5e4d-3c2b-1a9f8e7d6c5b',
    'c5b4a3f2-e1d9-8c7b-6a5f-4e3d2c1b9a8f',
    'a9f8e7d6-c5b4-3a2f-1e9d-8c7b6a5f4e3d',
    'f7e6d5c4-b3a2-1f9e-8d7c-6b5a4f3e2d1c',
    'd8c7b6a5-f4e3-2d1c-9b8a-7f6e5d4c3b2a',
    'b2a1f9e8-d7c6-5b4a-3f2e-1d9c8b7a6f5e',
    'e6d5c4b3-a2f1-9e8d-7c6b-5a4f3e2d1c9b',
    'c9b8a7f6-e5d4-3c2b-1a9f-8e7d6c5b4a3f'
);

-- ===============================================
-- 7. SCORING HOYA
-- ===============================================

-- Inserir scores para lentes HOYA
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
            CASE WHEN l.categoria = 'premium' THEN 92 ELSE 85 END
        WHEN c.nome = 'Custo-Benefício' THEN 
            CASE WHEN l.categoria = 'premium' THEN 88 ELSE 93 END
        WHEN c.nome = 'Disponibilidade' THEN 92
        WHEN c.nome = 'Tempo de Entrega' THEN 90
        WHEN c.nome = 'Suporte Técnico' THEN 89
    END,
    c.peso,
    CASE 
        WHEN c.nome = 'Qualidade Óptica' THEN 'HOYA iD Technology oferece excelente qualidade'
        WHEN c.nome = 'Custo-Benefício' THEN 'Ótima relação custo-benefício no mercado'
        WHEN c.nome = 'Disponibilidade' THEN 'Excelente disponibilidade no Brasil'
        WHEN c.nome = 'Tempo de Entrega' THEN 'Entrega rápida - 5-7 dias'
        WHEN c.nome = 'Suporte Técnico' THEN 'Bom suporte técnico e material educativo'
    END,
    NOW(),
    NOW(),
    NOW()
FROM lens_catalog.lentes l
CROSS JOIN scoring.criterios_avaliacao c
WHERE l.marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya')
  AND l.id IN (
    '9a8b7c6d-5e4f-3a2b-1c9d-8e7f6a5b4c3d',
    '8f7e6d5c-4b3a-2f1e-9d8c-7b6a5f4e3d2c',
    'e2d1c9b8-a7f6-5e4d-3c2b-1a9f8e7d6c5b',
    'c5b4a3f2-e1d9-8c7b-6a5f-4e3d2c1b9a8f',
    'a9f8e7d6-c5b4-3a2f-1e9d-8c7b6a5f4e3d',
    'f7e6d5c4-b3a2-1f9e-8d7c-6b5a4f3e2d1c',
    'd8c7b6a5-f4e3-2d1c-9b8a-7f6e5d4c3b2a',
    'b2a1f9e8-d7c6-5b4a-3f2e-1d9c8b7a6f5e',
    'e6d5c4b3-a2f1-9e8d-7c6b-5a4f3e2d1c9b',
    'c9b8a7f6-e5d4-3c2b-1a9f-8e7d6c5b4a3f'
);

COMMIT;

-- ===============================================
-- VERIFICAÇÃO DOS DADOS INSERIDOS
-- ===============================================

-- Verificar lentes HOYA inseridas
SELECT 
    nome,
    tipo,
    categoria,
    indice_refracao,
    preco_venda,
    ativo
FROM lens_catalog.lentes 
WHERE marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya')
ORDER BY categoria DESC, tipo, indice_refracao;

-- Verificar estoque HOYA
SELECT 
    l.nome,
    e.quantidade_disponivel,
    e.localizacao,
    e.status
FROM logistics.estoque e
JOIN lens_catalog.lentes l ON e.lente_id = l.id
WHERE l.marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya')
ORDER BY l.nome;

-- Estatísticas finais HOYA
SELECT 
    'HOYA' as marca,
    COUNT(*) as total_produtos,
    COUNT(CASE WHEN tipo = 'progressiva' THEN 1 END) as progressivas,
    COUNT(CASE WHEN tipo = 'monofocal' THEN 1 END) as monofocais,
    COUNT(CASE WHEN tipo = 'fotossensiveis' THEN 1 END) as fotossensiveis,
    COUNT(CASE WHEN tipo = 'tratamento' THEN 1 END) as tratamentos,
    AVG(preco_venda)::DECIMAL(10,2) as preco_medio
FROM lens_catalog.lentes 
WHERE marca_id = (SELECT id FROM lens_catalog.marcas WHERE nome = 'Hoya');

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
    'Script 004_catalogo_hoya.sql executado com sucesso',
    '{"script": "004_catalogo_hoya.sql", "produtos_inseridos": 10, "marca": "Hoya", "tipos": ["progressiva", "monofocal", "tratamento", "fotossensiveis"]}'::jsonb,
    NOW()
);

-- ===============================================
-- FIM DO SCRIPT 004_catalogo_hoya.sql
-- ===============================================