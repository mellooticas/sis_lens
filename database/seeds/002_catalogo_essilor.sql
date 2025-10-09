-- ============================================
-- SCRIPT 002: CATÁLOGO ESSILOR COMPLETO
-- ============================================
-- Descrição: População completa da linha Essilor (Varilux, Crizal, Transitions)
-- Dependências: 001_dados_basicos.sql
-- Autor: Sistema BestLens
-- Data: 2025-10-04

-- ============================================
-- VARIÁVEIS GLOBAIS
-- ============================================

DO $$
DECLARE
    demo_tenant_id UUID := 'b8f4d2c1-1234-4567-8901-123456789012';
    essilor_marca_id UUID := 'c1a2b3c4-1111-2222-3333-444444444444';
    essilor_lab_id UUID := 'd2b3c4d5-2222-3333-4444-555555555555';
    
    -- IDs das lentes que serão criadas
    varilux_x_150_id UUID := 'f4d5e6f7-4444-5555-6666-777777777771';
    varilux_x_167_id UUID := 'f4d5e6f7-4444-5555-6666-777777777772';
    varilux_comfort_150_id UUID := 'f4d5e6f7-4444-5555-6666-777777777773';
    varilux_liberty_150_id UUID := 'f4d5e6f7-4444-5555-6666-777777777774';
    crizal_sapphire_150_id UUID := 'f4d5e6f7-4444-5555-6666-777777777775';
    transitions_signature_150_id UUID := 'f4d5e6f7-4444-5555-6666-777777777776';
    
BEGIN

-- ============================================
-- 1. LENTES VARILUX (PROGRESSIVAS PREMIUM)
-- ============================================

    -- Varilux X Series 1.50
    INSERT INTO lens_catalog.lentes (
        id, tenant_id, sku_canonico, marca_id, familia, design, 
        material, indice_refracao, tratamentos, tipo_lente, 
        corredor_progressao, specs_tecnicas, ativo
    ) VALUES (
        varilux_x_150_id, demo_tenant_id, 'ESS-VAR-X4D-1.50', essilor_marca_id, 
        'Varilux', 'X Series 4D', 'organico', 1.50, 
        '{"antirreflexo","antirrisco","hidrofobico"}', 'progressiva', 14,
        '{
            "tecnologia": "Varilux 4D Technology",
            "personalizacao": "Behavioral AI",
            "reducao_distorcao": "até 90%",
            "campo_visao": "expandido",
            "adaptacao": "instantânea",
            "indicado_para": ["iniciantes", "usuários exigentes"],
            "diferenciais": ["Eye-Ruler", "4D Technology", "Behavioral AI"]
        }', true
    );

    -- Varilux X Series 1.67 (Alto Índice)
    INSERT INTO lens_catalog.lentes (
        id, tenant_id, sku_canonico, marca_id, familia, design, 
        material, indice_refracao, tratamentos, tipo_lente, 
        corredor_progressao, specs_tecnicas, ativo
    ) VALUES (
        varilux_x_167_id, demo_tenant_id, 'ESS-VAR-X4D-1.67', essilor_marca_id, 
        'Varilux', 'X Series 4D', 'organico', 1.67, 
        '{"antirreflexo","antirrisco","hidrofobico","blue_protect"}', 'progressiva', 14,
        '{
            "tecnologia": "Varilux 4D Technology",
            "personalizacao": "Behavioral AI", 
            "reducao_distorcao": "até 90%",
            "espessura": "reduzida em 20%",
            "peso": "reduzido em 15%",
            "indicado_para": ["graus altos", "armações pequenas"],
            "diferenciais": ["Eye-Ruler", "4D Technology", "Alto Índice"]
        }', true
    );

    -- Varilux Comfort 1.50
    INSERT INTO lens_catalog.lentes (
        id, tenant_id, sku_canonico, marca_id, familia, design, 
        material, indice_refracao, tratamentos, tipo_lente, 
        corredor_progressao, specs_tecnicas, ativo
    ) VALUES (
        varilux_comfort_150_id, demo_tenant_id, 'ESS-VAR-COMFORT-1.50', essilor_marca_id, 
        'Varilux', 'Comfort Max', 'organico', 1.50, 
        '{"antirreflexo","antirrisco"}', 'progressiva', 17,
        '{
            "tecnologia": "Steady Methodology",
            "campo_visao": "amplo e estável",
            "reducao_oscilacao": "máxima",
            "adaptacao": "rápida",
            "indicado_para": ["primeira progressiva", "sensibilidade a movimento"],
            "diferenciais": ["SteadyPlus Technology", "Waves Effect"]
        }', true
    );

    -- Varilux Liberty 1.50 (Custo-Benefício)
    INSERT INTO lens_catalog.lentes (
        id, tenant_id, sku_canonico, marca_id, familia, design, 
        material, indice_refracao, tratamentos, tipo_lente, 
        corredor_progressao, specs_tecnicas, ativo
    ) VALUES (
        varilux_liberty_150_id, demo_tenant_id, 'ESS-VAR-LIBERTY-1.50', essilor_marca_id, 
        'Varilux', 'Liberty 3.0', 'organico', 1.50, 
        '{"antirreflexo_basico"}', 'progressiva', 18,
        '{
            "tecnologia": "Twin RX Technology",
            "campo_visao": "equilibrado",
            "custo_beneficio": "excelente",
            "indicado_para": ["orçamento limitado", "uso casual"],
            "diferenciais": ["Twin RX", "Visual Behavior"]
        }', true
    );

-- ============================================
-- 2. LENTES MONOFOCAIS COM CRIZAL
-- ============================================

    -- Crizal Sapphire UV 1.50
    INSERT INTO lens_catalog.lentes (
        id, tenant_id, sku_canonico, marca_id, familia, design, 
        material, indice_refracao, tratamentos, tipo_lente, 
        corredor_progressao, specs_tecnicas, ativo
    ) VALUES (
        crizal_sapphire_150_id, demo_tenant_id, 'ESS-CRIZAL-SAPPHIRE-1.50', essilor_marca_id, 
        'Crizal', 'Sapphire UV', 'organico', 1.50, 
        '{"antirreflexo_premium","antirrisco","hidrofobico","anti_estatico"}', 'monofocal', NULL,
        '{
            "tratamento": "Crizal Sapphire UV",
            "transmitancia_luz": "99.5%",
            "protecao_uv": "100% UV",
            "resistencia_risco": "superior",
            "facilidade_limpeza": "máxima",
            "durabilidade": "2x maior que tratamentos convencionais",
            "indicado_para": ["usuários exigentes", "uso intenso"],
            "diferenciais": ["Multi-Angular Technology", "Superior Anti-smudge"]
        }', true
    );

-- ============================================
-- 3. LENTES FOTOSSENSÍVEIS TRANSITIONS
-- ============================================

    -- Transitions Signature VIII 1.50
    INSERT INTO lens_catalog.lentes (
        id, tenant_id, sku_canonico, marca_id, familia, design, 
        material, indice_refracao, tratamentos, tipo_lente, 
        corredor_progressao, specs_tecnicas, ativo
    ) VALUES (
        transitions_signature_150_id, demo_tenant_id, 'ESS-TRANS-SIGNATURE-1.50', essilor_marca_id, 
        'Transitions', 'Signature VIII', 'organico', 1.50, 
        '{"antirreflexo","fotossensivel","protecao_uv"}', 'monofocal', NULL,
        '{
            "tecnologia": "Transitions Signature VIII",
            "velocidade_ativacao": "35% mais rápida",
            "velocidade_desativacao": "2x mais rápida",
            "cores_disponiveis": ["cinza", "marrom", "verde"],
            "protecao_uv": "100%",
            "protecao_luz_azul": "filtro seletivo",
            "temperatura_ativacao": "funciona até 35°C",
            "indicado_para": ["uso externo frequente", "sensibilidade à luz"],
            "diferenciais": ["Chromea7 Technology", "Ultra-responsivo"]
        }', true
    );

-- ============================================
-- 4. TABELA DE PREÇOS ESSILOR 2025
-- ============================================

    -- Criar tabela de preços
    INSERT INTO commercial.tabelas_preco (id, laboratorio_id, nome, descricao, vigencia_inicio, vigencia_fim, ativa) VALUES 
    ('t1a2b3c4-1111-2222-3333-444444444441', essilor_lab_id, 'Tabela Essilor 2025', 
     'Preços oficiais Essilor - Válida para todo Brasil', '2025-01-01', '2025-12-31', true);

    -- Preços das lentes Varilux X Series
    INSERT INTO commercial.precos_lentes (
        tabela_id, lente_id, preco_base, preco_esferico, preco_cilindrico, 
        preco_progressivo, desconto_maximo, observacoes
    ) VALUES 
    -- Varilux X 1.50
    ('t1a2b3c4-1111-2222-3333-444444444441', varilux_x_150_id, 
     450.00, 500.00, 550.00, 600.00, 0.15, 'Inclui Crizal Forte UV'),
    
    -- Varilux X 1.67
    ('t1a2b3c4-1111-2222-3333-444444444441', varilux_x_167_id, 
     650.00, 720.00, 780.00, 850.00, 0.12, 'Inclui Crizal Sapphire UV'),
    
    -- Varilux Comfort
    ('t1a2b3c4-1111-2222-3333-444444444441', varilux_comfort_150_id, 
     320.00, 360.00, 400.00, 450.00, 0.18, 'Inclui Crizal Easy UV'),
    
    -- Varilux Liberty
    ('t1a2b3c4-1111-2222-3333-444444444441', varilux_liberty_150_id, 
     180.00, 220.00, 260.00, 300.00, 0.20, 'Antirreflexo básico incluso'),
    
    -- Crizal Sapphire
    ('t1a2b3c4-1111-2222-3333-444444444441', crizal_sapphire_150_id, 
     280.00, 320.00, 360.00, NULL, 0.15, 'Tratamento premium'),
    
    -- Transitions Signature
    ('t1a2b3c4-1111-2222-3333-444444444441', transitions_signature_150_id, 
     350.00, 400.00, 450.00, NULL, 0.12, 'Fotossensível premium');

-- ============================================
-- 5. CONTROLE DE ESTOQUE
-- ============================================

    INSERT INTO logistics.estoque (laboratorio_id, lente_id, quantidade_disponivel, quantidade_minima, prazo_entrega_dias) VALUES 
    (essilor_lab_id, varilux_x_150_id, 120, 20, 3),
    (essilor_lab_id, varilux_x_167_id, 80, 15, 4),
    (essilor_lab_id, varilux_comfort_150_id, 200, 30, 2),
    (essilor_lab_id, varilux_liberty_150_id, 300, 50, 1),
    (essilor_lab_id, crizal_sapphire_150_id, 150, 25, 2),
    (essilor_lab_id, transitions_signature_150_id, 100, 20, 5);

-- ============================================
-- 6. SCORING DAS LENTES ESSILOR
-- ============================================

    -- Varilux X Series - Premium
    INSERT INTO scoring.scores_lentes (lente_id, criterio_nome, pontuacao, observacoes) VALUES 
    (varilux_x_150_id, 'Qualidade da Marca', 10.0, 'Tecnologia líder mundial'),
    (varilux_x_150_id, 'Competitividade de Preço', 7.0, 'Premium pricing'),
    (varilux_x_150_id, 'Prazo de Entrega', 9.0, 'Estoque disponível'),
    (varilux_x_150_id, 'Disponibilidade em Estoque', 9.0, 'Boa disponibilidade'),
    (varilux_x_150_id, 'Margem de Lucro', 8.0, 'Margem interessante'),
    
    -- Varilux Liberty - Custo-Benefício
    (varilux_liberty_150_id, 'Qualidade da Marca', 9.0, 'Marca consolidada'),
    (varilux_liberty_150_id, 'Competitividade de Preço', 9.0, 'Preço competitivo'),
    (varilux_liberty_150_id, 'Prazo de Entrega', 10.0, 'Pronta entrega'),
    (varilux_liberty_150_id, 'Disponibilidade em Estoque', 10.0, 'Alto estoque'),
    (varilux_liberty_150_id, 'Margem de Lucro', 8.5, 'Boa margem');

END $$;

-- ============================================
-- VERIFICAÇÃO DOS DADOS INSERIDOS
-- ============================================

-- Contar lentes Essilor criadas
SELECT 
    'Lentes Essilor criadas:' as info,
    COUNT(*) as quantidade
FROM lens_catalog.lentes l 
JOIN lens_catalog.marcas m ON l.marca_id = m.id 
WHERE m.nome = 'Essilor';

-- Exibir catálogo Essilor
SELECT 
    l.sku_canonico,
    l.familia,
    l.design,
    l.indice_refracao,
    l.tipo_lente,
    l.tratamentos
FROM lens_catalog.lentes l 
JOIN lens_catalog.marcas m ON l.marca_id = m.id 
WHERE m.nome = 'Essilor'
ORDER BY l.familia, l.design;

-- Verificar preços
SELECT 
    l.sku_canonico,
    pl.preco_base,
    pl.preco_esferico,
    pl.preco_cilindrico,
    pl.preco_progressivo
FROM commercial.precos_lentes pl
JOIN lens_catalog.lentes l ON pl.lente_id = l.id
JOIN lens_catalog.marcas m ON l.marca_id = m.id 
WHERE m.nome = 'Essilor'
ORDER BY pl.preco_base;

-- Verificar estoque
SELECT 
    l.sku_canonico,
    e.quantidade_disponivel,
    e.prazo_entrega_dias
FROM logistics.estoque e
JOIN lens_catalog.lentes l ON e.lente_id = l.id
JOIN lens_catalog.marcas m ON l.marca_id = m.id 
WHERE m.nome = 'Essilor'
ORDER BY e.quantidade_disponivel DESC;

COMMIT;