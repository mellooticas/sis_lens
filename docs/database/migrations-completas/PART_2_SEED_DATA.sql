-- PARTE 2: DADOS (SEED)
-- Data: 2025-12-10
-- Este script insere dados de demonstração (SIS Lens, Labs, Lentes).
-- Execute APÓS rodar o PART_1_STRUCTURE.sql

DO $$
DECLARE
    v_tenant_id UUID;
    v_marca_sis UUID;
    v_lente_gold UUID;
    v_lente_silver UUID;
    v_lab_a UUID; 
    v_lab_b UUID;
    v_lab_c UUID;
    v_prod_a UUID;
    v_prod_b UUID;
    v_prod_c UUID;
BEGIN
    -- 1. Obter Tenant Demo
    SELECT id INTO v_tenant_id FROM meta_system.tenants WHERE slug = 'demo';
    
    -- Se não existir tenant, cria
    IF v_tenant_id IS NULL THEN
        INSERT INTO meta_system.tenants (nome, slug) VALUES ('Ótica Demo', 'demo') 
        RETURNING id INTO v_tenant_id;
    END IF;

    -- 2. Criar Laboratórios
    -- INSERTS resilientes usando apenas nome_fantasia (evitando erro de coluna 'nome' inexistente)
    
    INSERT INTO suppliers.laboratorios (tenant_id, nome_fantasia, lead_time_padrao_dias)
    VALUES (v_tenant_id, 'Lab Speed', 2)
    ON CONFLICT DO NOTHING;
    SELECT id INTO v_lab_a FROM suppliers.laboratorios WHERE nome_fantasia = 'Lab Speed';

    INSERT INTO suppliers.laboratorios (tenant_id, nome_fantasia, lead_time_padrao_dias)
    VALUES (v_tenant_id, 'Lab Eco', 5)
    ON CONFLICT DO NOTHING;
    SELECT id INTO v_lab_b FROM suppliers.laboratorios WHERE nome_fantasia = 'Lab Eco';

    INSERT INTO suppliers.laboratorios (tenant_id, nome_fantasia, lead_time_padrao_dias)
    VALUES (v_tenant_id, 'Lab Precision', 4)
    ON CONFLICT DO NOTHING;
    SELECT id INTO v_lab_c FROM suppliers.laboratorios WHERE nome_fantasia = 'Lab Precision';

    -- 3. Criar Marca Própria SIS Lens
    INSERT INTO lens_catalog.marcas (tenant_id, nome, pais_origem, tipo_marca)
    VALUES (v_tenant_id, 'SIS Lens', 'Brasil', 'PROPRIA')
    ON CONFLICT (tenant_id, nome) DO UPDATE SET tipo_marca = 'PROPRIA'
    RETURNING id INTO v_marca_sis;

    -- 4. Criar Lentes Virtuais (Face Cliente)
    -- Atenção: Material usa Enum 'HIGH_INDEX_167'. Se falhar, verifique a Parte 1.
    
    -- 4.1 SIS Lens Gold
    INSERT INTO lens_catalog.lentes (
        tenant_id, sku_canonico, marca_id, familia, design, material, 
        indice_refracao, tratamentos, tipo_lente, corredor_progressao, ativo
    ) VALUES (
        v_tenant_id, 
        'LENS-9001-SIS-GOLD-167', -- SKU ajustado para padrão
        v_marca_sis, 
        'SIS Gold', 
        'Digital HD', 
        'HIGH_INDEX_167', -- Certifique-se que PART_1 adicionou este valor
        1.67, 
        ARRAY['AR_PREMIUM', 'BLUE_CUT', 'UV400']::public.tratamento_lente[], -- Cast explícito
        'PROGRESSIVA', 
        14, -- Corredor de Progressão (Obrigatório para PROGRESSIVA)
        true
    )
    ON CONFLICT (tenant_id, sku_canonico) DO UPDATE SET ativo = true
    RETURNING id INTO v_lente_gold;

    -- 4.2 SIS Lens Silver
    INSERT INTO lens_catalog.lentes (
        tenant_id, sku_canonico, marca_id, familia, design, material, 
        indice_refracao, tratamentos, tipo_lente, corredor_progressao, ativo
    ) VALUES (
        v_tenant_id, 
        'LENS-9002-SIS-SILV-159', -- SKU ajustado para padrão
        v_marca_sis, 
        'SIS Silver', 
        'Digital Soft', 
        'POLICARBONATO',
        1.59, 
        ARRAY['AR_STANDARD']::public.tratamento_lente[],
        'PROGRESSIVA', 
        14, -- Corredor de Progressão (Obrigatório para PROGRESSIVA)
        true
    )
    ON CONFLICT (tenant_id, sku_canonico) DO UPDATE SET ativo = true
    RETURNING id INTO v_lente_silver;

    -- 5. Criar Produtos nos Laboratórios
    INSERT INTO suppliers.produtos_laboratorio (
        tenant_id, laboratorio_id, sku_laboratorio, nome_comercial, sku_fantasia, lente_id, disponivel
    ) VALUES (
        v_tenant_id, v_lab_a, 'LABA-167-HD', 'Speed High Index 1.67', 'SPEED-167', v_lente_gold, true
    ) RETURNING id INTO v_prod_a;

    INSERT INTO suppliers.produtos_laboratorio (
        tenant_id, laboratorio_id, sku_laboratorio, nome_comercial, sku_fantasia, lente_id, disponivel
    ) VALUES (
        v_tenant_id, v_lab_b, 'LABB-ECO-167', 'EcoView 1.67 Digital', 'ECO-167', v_lente_gold, true
    ) RETURNING id INTO v_prod_b;

    -- 6. Definir Preços Base
    INSERT INTO commercial.precos_base (tenant_id, produto_lab_id, preco_tabela, vigencia_inicio, ativo, tabela_referencia)
    VALUES (v_tenant_id, v_prod_a, 300.00, NOW(), true, 'TABELA_PADRAO');

    INSERT INTO commercial.precos_base (tenant_id, produto_lab_id, preco_tabela, vigencia_inicio, ativo, tabela_referencia)
    VALUES (v_tenant_id, v_prod_b, 180.00, NOW(), true, 'TABELA_PADRAO');

    -- 7. Homologar Sourcing
    INSERT INTO lens_catalog.homologacao_marca_propria (
        lente_marca_propria_id, produto_lab_id, prioridade, fator_qualidade
    ) VALUES (v_lente_gold, v_prod_a, 2, 1.0)
    ON CONFLICT DO NOTHING;

    INSERT INTO lens_catalog.homologacao_marca_propria (
        lente_marca_propria_id, produto_lab_id, prioridade, fator_qualidade
    ) VALUES (v_lente_gold, v_prod_b, 1, 0.95)
    ON CONFLICT DO NOTHING;

    -- 8. Grades
    INSERT INTO lens_catalog.grades_disponibilidade (
        lente_id, esferico_min, esferico_max, cilindrico_min, cilindrico_max, adicao_min, adicao_max
    ) VALUES 
    (v_lente_gold, -6.00, 4.00, 0.00, -4.00, 1.00, 3.50);

END $$;
