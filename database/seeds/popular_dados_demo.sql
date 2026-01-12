-- Script Rápido de População para Demo
-- Executa via Supabase SQL Editor

BEGIN;

-- 1. Criar tenant demo se não existir
INSERT INTO meta_system.tenants (nome, slug, ativo)
VALUES ('Ótica Demo', 'demo', true)
ON CONFLICT (slug) DO NOTHING;

-- 2. Criar 3 Laboratórios de Teste
DO $$
DECLARE
    v_tenant_id UUID;
BEGIN
    SELECT id INTO v_tenant_id FROM meta_system.tenants WHERE slug = 'demo';
    
    -- Lab 1: SIS Lens (O Rápido)
    INSERT INTO suppliers.laboratorios (
        tenant_id, nome, nome_fantasia, cnpj, 
        lead_time_padrao_dias, ativo, contato_comercial
    )
    VALUES (
        v_tenant_id, 'SIS Lens Laboratório', 'SIS Lens', '12.345.678/0001-90',
        3, true, jsonb_build_object('email', 'comercial@sislens.com.br', 'telefone', '(11) 3456-7890')
    )
    ON CONFLICT DO NOTHING;
    
    -- Lab 2: Essilor (O Premium)
    INSERT INTO suppliers.laboratorios (
        tenant_id, nome, nome_fantasia, cnpj,
        lead_time_padrao_dias, ativo, contato_comercial
    )
    VALUES (
        v_tenant_id, 'Essilor do Brasil', 'Essilor', '23.456.789/0001-01',
        5, true, jsonb_build_object('email', 'comercial@essilor.com.br', 'telefone', '(11) 4567-8901')
    )
    ON CONFLICT DO NOTHING;
    
    -- Lab 3: Zeiss (O Equilibrado)
    INSERT INTO suppliers.laboratorios (
        tenant_id, nome, nome_fantasia, cnpj,
        lead_time_padrao_dias, ativo, contato_comercial
    )
    VALUES (
        v_tenant_id, 'Carl Zeiss Vision', 'Zeiss', '34.567.890/0001-12',
        4, true, jsonb_build_object('email', 'comercial@zeiss.com.br', 'telefone', '(11) 5678-9012')
    )
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE '✓ 3 Laboratórios criados';
END $$;

-- 3. Criar Scores para os Laboratórios
DO $$
DECLARE
    v_lab_id UUID;
BEGIN
    -- SIS Lens: Melhor prazo
    SELECT id INTO v_lab_id FROM suppliers.laboratorios WHERE nome_fantasia = 'SIS Lens';
    IF v_lab_id IS NOT NULL THEN
        INSERT INTO scoring.scores_laboratorios (
            laboratorio_id, score_geral, score_qualidade, score_preco, score_prazo
        )
        VALUES (v_lab_id, 85.5, 80.0, 90.0, 95.0)
        ON CONFLICT (laboratorio_id) DO UPDATE 
        SET score_geral = 85.5, score_qualidade = 80.0, score_preco = 90.0, score_prazo = 95.0;
    END IF;
    
    -- Essilor: Melhor qualidade
    SELECT id INTO v_lab_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Essilor';
    IF v_lab_id IS NOT NULL THEN
        INSERT INTO scoring.scores_laboratorios (
            laboratorio_id, score_geral, score_qualidade, score_preco, score_prazo
        )
        VALUES (v_lab_id, 92.0, 98.0, 75.0, 85.0)
        ON CONFLICT (laboratorio_id) DO UPDATE 
        SET score_geral = 92.0, score_qualidade = 98.0, score_preco = 75.0, score_prazo = 85.0;
    END IF;
    
    -- Zeiss: Equilibrado
    SELECT id INTO v_lab_id FROM suppliers.laboratorios WHERE nome_fantasia = 'Zeiss';
    IF v_lab_id IS NOT NULL THEN
        INSERT INTO scoring.scores_laboratorios (
            laboratorio_id, score_geral, score_qualidade, score_preco, score_prazo
        )
        VALUES (v_lab_id, 88.0, 90.0, 82.0, 88.0)
        ON CONFLICT (laboratorio_id) DO UPDATE 
        SET score_geral = 88.0, score_qualidade = 90.0, score_preco = 82.0, score_prazo = 88.0;
    END IF;
    
    RAISE NOTICE '✓ Scores criados para os laboratórios';
END $$;

-- 4. Criar algumas lentes de exemplo
DO $$
DECLARE
    v_tenant_id UUID;
    v_marca_sis UUID;
    v_marca_essilor UUID;
    v_marca_zeiss UUID;
BEGIN
    SELECT id INTO v_tenant_id FROM meta_system.tenants WHERE slug = 'demo';
    
    -- Criar marcas se não existirem
    INSERT INTO lens_catalog.marcas (tenant_id, nome, pais_origem, tipo_marca)
    VALUES (v_tenant_id, 'SIS Lens', 'Brasil', 'PROPRIA')
    ON CONFLICT (tenant_id, nome) DO UPDATE SET tipo_marca = 'PROPRIA'
    RETURNING id INTO v_marca_sis;
    
    INSERT INTO lens_catalog.marcas (tenant_id, nome, pais_origem, tipo_marca)
    VALUES (v_tenant_id, 'Essilor', 'França', 'TERCEIROS')
    ON CONFLICT (tenant_id, nome) DO UPDATE SET tipo_marca = 'TERCEIROS'
    RETURNING id INTO v_marca_essilor;
    
    INSERT INTO lens_catalog.marcas (tenant_id, nome, pais_origem, tipo_marca)
    VALUES (v_tenant_id, 'Zeiss', 'Alemanha', 'TERCEIROS')
    ON CONFLICT (tenant_id, nome) DO UPDATE SET tipo_marca = 'TERCEIROS'
    RETURNING id INTO v_marca_zeiss;
    
    -- Criar 5 lentes de exemplo
    INSERT INTO lens_catalog.lentes (
        tenant_id, marca_id, familia, design, material, 
        indice_refracao, categoria, disponivel
    )
    VALUES 
        (v_tenant_id, v_marca_sis, 'Visão Digital', 'Monofocal', 'Resina', 1.56, 'DIGITAL', true),
        (v_tenant_id, v_marca_sis, 'Confort Plus', 'Progressiva', 'Resina', 1.67, 'PROGRESSIVA', true),
        (v_tenant_id, v_marca_essilor, 'Varilux Comfort', 'Progressiva', 'Policarbonato', 1.59, 'PREMIUM', true),
        (v_tenant_id, v_marca_zeiss, 'Single Vision', 'Monofocal', 'Resina', 1.60, 'STANDARD', true),
        (v_tenant_id, v_marca_zeiss, 'Progressive Individual', 'Progressiva', 'Resina', 1.74, 'PREMIUM', true)
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE '✓ 5 Lentes criadas';
END $$;

COMMIT;

-- Verificar resultados
SELECT 'LABORATÓRIOS' as tipo, COUNT(*) as total FROM suppliers.laboratorios;
SELECT 'SCORES' as tipo, COUNT(*) as total FROM scoring.scores_laboratorios;
SELECT 'MARCAS' as tipo, COUNT(*) as total FROM lens_catalog.marcas;
SELECT 'LENTES' as tipo, COUNT(*) as total FROM lens_catalog.lentes;

-- Testar view pública
SELECT 'VIEW LABS COMPLETO' as tipo, COUNT(*) as total FROM public.vw_laboratorios_completo;
SELECT * FROM public.vw_laboratorios_completo;

-- Testar dashboard KPIs
SELECT 'DASHBOARD KPIS' as tipo;
SELECT public.obter_dashboard_kpis();
