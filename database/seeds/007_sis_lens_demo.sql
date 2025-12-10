-- SEED: Dados de Demonstração SIS Lens (Marca Própria & Sourcing)
-- Data: 2025-12-09

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

    -- 2. Criar Laboratórios (Fornecedores Reais)
    -- Lab A: O "Rápido"
    INSERT INTO suppliers.laboratorios (tenant_id, nome, nome_fantasia, lead_time_padrao_dias)
    VALUES (v_tenant_id, 'Laboratório Speed', 'Lab Speed', 2)
    ON CONFLICT DO NOTHING;
    SELECT id INTO v_lab_a FROM suppliers.laboratorios WHERE nome_fantasia = 'Lab Speed';

    -- Lab B: O "Barato"
    INSERT INTO suppliers.laboratorios (tenant_id, nome, nome_fantasia, lead_time_padrao_dias)
    VALUES (v_tenant_id, 'Laboratório Economy', 'Lab Eco', 5)
    ON CONFLICT DO NOTHING;
    SELECT id INTO v_lab_b FROM suppliers.laboratorios WHERE nome_fantasia = 'Lab Eco';

    -- Lab C: O "Premium"
    INSERT INTO suppliers.laboratorios (tenant_id, nome, nome_fantasia, lead_time_padrao_dias)
    VALUES (v_tenant_id, 'Laboratório Precision', 'Lab Precision', 4)
    ON CONFLICT DO NOTHING;
    SELECT id INTO v_lab_c FROM suppliers.laboratorios WHERE nome_fantasia = 'Lab Precision';

    -- 3. Criar Marca Própria SIS Lens
    INSERT INTO lens_catalog.marcas (tenant_id, nome, pais_origem, tipo_marca)
    VALUES (v_tenant_id, 'SIS Lens', 'Brasil', 'PROPRIA')
    ON CONFLICT (tenant_id, nome) DO UPDATE SET tipo_marca = 'PROPRIA'
    RETURNING id INTO v_marca_sis;

    -- 4. Criar Lentes Virtuais (Face Cliente)
    
    -- 4.1 SIS Lens Gold (A Top de Linha)
    INSERT INTO lens_catalog.lentes (
        tenant_id, sku_canonico, marca_id, familia, design, material, 
        indice_refracao, tratamentos, tipo_lente, ativo
    ) VALUES (
        v_tenant_id, 'SIS-GOLD-167-DIG', v_marca_sis, 'SIS Gold', 'Digital HD', 'HIGH_INDEX_167',
        1.67, ARRAY['AR_PREMIUM', 'BLUE_CUT', 'UV400'], 'PROGRESSIVA', true
    )
    ON CONFLICT (tenant_id, sku_canonico) DO UPDATE SET ativo = true
    RETURNING id INTO v_lente_gold;

    -- 4.2 SIS Lens Silver (A Custo-Benefício)
    INSERT INTO lens_catalog.lentes (
        tenant_id, sku_canonico, marca_id, familia, design, material, 
        indice_refracao, tratamentos, tipo_lente, ativo
    ) VALUES (
        v_tenant_id, 'SIS-SILV-159-DIG', v_marca_sis, 'SIS Silver', 'Digital Soft', 'POLICARBONATO',
        1.59, ARRAY['AR_STANDARD', 'HARD_COAT'], 'PROGRESSIVA', true
    )
    ON CONFLICT (tenant_id, sku_canonico) DO UPDATE SET ativo = true
    RETURNING id INTO v_lente_silver;

    -- 5. Criar Produtos nos Laboratórios (O que compramos deles)
    
    -- Lab A tem a "Speed 1.67" (que vai virar Gold)
    INSERT INTO suppliers.produtos_laboratorio (
        tenant_id, laboratorio_id, sku_laboratorio, nome_comercial, sku_fantasia, lente_id, disponivel
    ) VALUES (
        v_tenant_id, v_lab_a, 'LABA-167-HD', 'Speed High Index 1.67', 'SPEED-167', v_lente_gold, true
    ) RETURNING id INTO v_prod_a;

    -- Lab B tem a "Eco Digital 1.67" (que também vira Gold)
    INSERT INTO suppliers.produtos_laboratorio (
        tenant_id, laboratorio_id, sku_laboratorio, nome_comercial, sku_fantasia, lente_id, disponivel
    ) VALUES (
        v_tenant_id, v_lab_b, 'LABB-ECO-167', 'EcoView 1.67 Digital', 'ECO-167', v_lente_gold, true
    ) RETURNING id INTO v_prod_b;

    -- 6. Definir Preços de Custo (Aqui mora o lucro!)
    
    -- Lab A (Rápido) custa R$ 300
    INSERT INTO commercial.precos_base (tenant_id, produto_lab_id, preco_tabela, vigencia_inicio, ativo)
    VALUES (v_tenant_id, v_prod_a, 300.00, NOW(), true);

    -- Lab B (Barato) custa R$ 180 (Sourcing preferido!)
    INSERT INTO commercial.precos_base (tenant_id, produto_lab_id, preco_tabela, vigencia_inicio, ativo)
    VALUES (v_tenant_id, v_prod_b, 180.00, NOW(), true);

    -- 7. Homologar Sourcing (Ligar Virtual -> Real)
    
    -- SIS Gold -> Lab A (Prioridade 2, mais caro)
    INSERT INTO lens_catalog.homologacao_marca_propria (
        lente_marca_propria_id, produto_lab_id, prioridade, fator_qualidade
    ) VALUES (v_lente_gold, v_prod_a, 2, 1.0)
    ON CONFLICT DO NOTHING;

    -- SIS Gold -> Lab B (Prioridade 1, mais barato e bom)
    INSERT INTO lens_catalog.homologacao_marca_propria (
        lente_marca_propria_id, produto_lab_id, prioridade, fator_qualidade
    ) VALUES (v_lente_gold, v_prod_b, 1, 0.95)
    ON CONFLICT DO NOTHING;

    -- 8. Grades de Disponibilidade (Exemplo)
    -- SIS Gold vai de -6 a +4
    INSERT INTO lens_catalog.grades_disponibilidade (
        lente_id, esferico_min, esferico_max, cilindrico_min, cilindrico_max, adicao_min, adicao_max
    ) VALUES 
    (v_lente_gold, -6.00, 4.00, 0.00, -4.00, 1.00, 3.50);

END $$;
