-- ============================================
-- SCRIPT 001: DADOS BÁSICOS
-- ============================================
-- Descrição: População inicial com tenants, marcas principais e laboratórios básicos
-- Dependências: Executar após todas as migrations
-- Autor: Sistema BestLens
-- Data: 2025-10-04

-- ============================================
-- 1. TENANTS (Base do sistema)
-- ============================================

INSERT INTO meta_system.tenants (id, nome, slug, configuracoes, ativo) VALUES 
('b8f4d2c1-1234-4567-8901-123456789012', 'BestLens Demo', 'bestlens-demo', '{
    "tema": "azul",
    "moeda": "BRL",
    "timezone": "America/Sao_Paulo",
    "idioma": "pt-BR",
    "configuracoes_sistema": {
        "margem_minima": 0.15,
        "desconto_maximo": 0.25,
        "prazo_entrega_padrao": 7
    }
}', true),
('b8f4d2c1-1234-4567-8901-123456789013', 'Ótica Central', 'otica-central', '{
    "tema": "verde", 
    "moeda": "BRL",
    "timezone": "America/Sao_Paulo",
    "idioma": "pt-BR",
    "configuracoes_sistema": {
        "margem_minima": 0.20,
        "desconto_maximo": 0.20,
        "prazo_entrega_padrao": 5
    }
}', true);

-- ============================================
-- 2. MARCAS PRINCIPAIS (Catálogo técnico)
-- ============================================

-- Definir variável para tenant demo
DO $$
DECLARE
    demo_tenant_id UUID := 'b8f4d2c1-1234-4567-8901-123456789012';
BEGIN

    -- Marcas Internacionais Premium
    INSERT INTO lens_catalog.marcas (id, tenant_id, nome, pais_origem, ativo) VALUES 
    ('c1a2b3c4-1111-2222-3333-444444444444', demo_tenant_id, 'Essilor', 'França', true),
    ('c1a2b3c4-1111-2222-3333-444444444445', demo_tenant_id, 'Carl Zeiss Vision', 'Alemanha', true),
    ('c1a2b3c4-1111-2222-3333-444444444446', demo_tenant_id, 'Hoya', 'Japão', true),
    ('c1a2b3c4-1111-2222-3333-444444444447', demo_tenant_id, 'Rodenstock', 'Alemanha', true),
    ('c1a2b3c4-1111-2222-3333-444444444448', demo_tenant_id, 'Shamir', 'Israel', true);

    -- Marcas Nacionais
    INSERT INTO lens_catalog.marcas (id, tenant_id, nome, pais_origem, ativo) VALUES 
    ('c1a2b3c4-1111-2222-3333-444444444449', demo_tenant_id, 'Orgalent', 'Brasil', true),
    ('c1a2b3c4-1111-2222-3333-44444444444a', demo_tenant_id, 'Cristal', 'Brasil', true),
    ('c1a2b3c4-1111-2222-3333-44444444444b', demo_tenant_id, 'Nova Lente', 'Brasil', true);

END $$;

-- ============================================
-- 3. LABORATÓRIOS PRINCIPAIS 
-- ============================================

DO $$
DECLARE
    demo_tenant_id UUID := 'b8f4d2c1-1234-4567-8901-123456789012';
BEGIN

    INSERT INTO suppliers.laboratorios (id, tenant_id, nome, cnpj, estado, cidade, endereco, telefone, email, ativo) VALUES 
    -- Laboratórios Premium
    ('d2b3c4d5-2222-3333-4444-555555555555', demo_tenant_id, 'Essilor do Brasil Ltda', '01.234.567/0001-89', 'SP', 'São Paulo', 
     'Av. das Nações Unidas, 4777 - Alto da Boa Vista', '(11) 3047-3000', 'contato@essilor.com.br', true),
    
    ('d2b3c4d5-2222-3333-4444-555555555556', demo_tenant_id, 'Carl Zeiss Vision Brasil Ltda', '02.345.678/0001-90', 'SP', 'São Paulo', 
     'Av. Eng. Billings, 1729 - Jaguaré', '(11) 3719-4000', 'info@zeiss.com.br', true),
    
    ('d2b3c4d5-2222-3333-4444-555555555557', demo_tenant_id, 'Hoya Lens Brasil Ltda', '03.456.789/0001-01', 'RJ', 'Rio de Janeiro', 
     'Estrada dos Bandeirantes, 2001 - Curicica', '(21) 3437-7000', 'brasil@hoya.com', true),
    
    -- Laboratórios Nacionais
    ('d2b3c4d5-2222-3333-4444-555555555558', demo_tenant_id, 'Laboratório Orgalent S.A.', '04.567.890/0001-12', 'SP', 'Santo André', 
     'Rua Industrial, 780 - Cidade São Jorge', '(11) 4436-9000', 'vendas@orgalent.com.br', true),
    
    ('d2b3c4d5-2222-3333-4444-555555555559', demo_tenant_id, 'Cristal Óptica Industrial Ltda', '05.678.901/0001-23', 'SP', 'São Paulo', 
     'Av. Presidente Wilson, 231 - Centro', '(11) 3105-4000', 'comercial@cristal.com.br', true);

END $$;

-- ============================================
-- 4. REPRESENTANTES COMERCIAIS
-- ============================================

DO $$
DECLARE
    essilor_lab_id UUID := 'd2b3c4d5-2222-3333-4444-555555555555';
    zeiss_lab_id UUID := 'd2b3c4d5-2222-3333-4444-555555555556';
    hoya_lab_id UUID := 'd2b3c4d5-2222-3333-4444-555555555557';
    orgalent_lab_id UUID := 'd2b3c4d5-2222-3333-4444-555555555558';
BEGIN

    INSERT INTO suppliers.representantes (laboratorio_id, nome, email, telefone, cargo, regioes_atendimento, ativo) VALUES 
    -- Essilor
    (essilor_lab_id, 'João Silva Santos', 'joao.santos@essilor.com.br', '(11) 99999-1111', 'Gerente Regional SP', 
     '["SP-Capital", "SP-Grande ABC", "SP-Interior"]', true),
    (essilor_lab_id, 'Maria Oliveira Costa', 'maria.costa@essilor.com.br', '(21) 99999-2222', 'Gerente Regional RJ/ES', 
     '["RJ", "ES"]', true),
    
    -- Zeiss
    (zeiss_lab_id, 'Carlos Mendes', 'carlos.mendes@zeiss.com.br', '(11) 88888-3333', 'Consultor Técnico SP', 
     '["SP", "MS", "MT"]', true),
    (zeiss_lab_id, 'Ana Paula Lima', 'ana.lima@zeiss.com.br', '(41) 88888-4444', 'Consultora Sul', 
     '["PR", "SC", "RS"]', true),
    
    -- Hoya
    (hoya_lab_id, 'Roberto Ferreira', 'roberto.ferreira@hoya.com', '(21) 77777-5555', 'Diretor Comercial', 
     '["RJ", "SP", "MG", "ES"]', true),
    
    -- Orgalent
    (orgalent_lab_id, 'Patricia Souza', 'patricia.souza@orgalent.com.br', '(11) 66666-6666', 'Gerente de Vendas', 
     '["SP", "PR", "MS"]', true);

END $$;

-- ============================================
-- 5. CRITÉRIOS DE SCORING
-- ============================================

DO $$
DECLARE
    demo_tenant_id UUID := 'b8f4d2c1-1234-4567-8901-123456789012';
BEGIN

    INSERT INTO scoring.criterios (tenant_id, nome, descricao, peso, tipo_criterio, configuracoes, ativo) VALUES 
    (demo_tenant_id, 'Qualidade da Marca', 'Reputação e qualidade técnica da marca', 0.25, 'qualitativo', '{
        "pontuacao_maxima": 10,
        "fatores": ["tecnologia", "durabilidade", "acabamento", "garantia"]
    }', true),
    
    (demo_tenant_id, 'Competitividade de Preço', 'Relação preço vs mercado', 0.30, 'quantitativo', '{
        "referencia": "preco_medio_mercado",
        "formula": "linear_inversa",
        "peso_desconto": 0.3
    }', true),
    
    (demo_tenant_id, 'Prazo de Entrega', 'Velocidade de entrega do laboratório', 0.20, 'quantitativo', '{
        "prazo_ideal": 3,
        "prazo_aceitavel": 7,
        "penalidade_atraso": 0.1
    }', true),
    
    (demo_tenant_id, 'Disponibilidade em Estoque', 'Produto disponível para pronta entrega', 0.15, 'quantitativo', '{
        "estoque_minimo": 10,
        "bonus_disponibilidade": 1.2
    }', true),
    
    (demo_tenant_id, 'Margem de Lucro', 'Rentabilidade para a ótica', 0.10, 'quantitativo', '{
        "margem_minima": 0.15,
        "margem_ideal": 0.25,
        "peso_margem": 0.8
    }', true);

END $$;

-- ============================================
-- 6. USUÁRIOS DEMO
-- ============================================

DO $$
DECLARE
    demo_tenant_id UUID := 'b8f4d2c1-1234-4567-8901-123456789012';
BEGIN

    INSERT INTO orders.usuarios (id, tenant_id, nome, email, tipo_usuario, ativo) VALUES 
    ('e3c4d5e6-3333-4444-5555-666666666666', demo_tenant_id, 'Admin Demo', 'admin@bestlens.demo', 'admin', true),
    ('e3c4d5e6-3333-4444-5555-666666666667', demo_tenant_id, 'Vendedor João', 'joao@bestlens.demo', 'vendedor', true),
    ('e3c4d5e6-3333-4444-5555-666666666668', demo_tenant_id, 'Gerente Maria', 'maria@bestlens.demo', 'gerente', true);

END $$;

-- ============================================
-- VERIFICAÇÃO DOS DADOS INSERIDOS
-- ============================================

-- Contar registros inseridos
SELECT 
    'tenants' as tabela, COUNT(*) as registros 
FROM meta_system.tenants
UNION ALL
SELECT 
    'marcas' as tabela, COUNT(*) as registros 
FROM lens_catalog.marcas
UNION ALL
SELECT 
    'laboratorios' as tabela, COUNT(*) as registros 
FROM suppliers.laboratorios
UNION ALL
SELECT 
    'representantes' as tabela, COUNT(*) as registros 
FROM suppliers.representantes
UNION ALL
SELECT 
    'criterios' as tabela, COUNT(*) as registros 
FROM scoring.criterios
UNION ALL
SELECT 
    'usuarios' as tabela, COUNT(*) as registros 
FROM orders.usuarios;

-- Exibir dados inseridos para verificação
SELECT 'TENANTS CRIADOS:' as info;
SELECT nome, slug, ativo FROM meta_system.tenants;

SELECT 'MARCAS CRIADAS:' as info;
SELECT m.nome, m.pais_origem FROM lens_catalog.marcas m 
JOIN meta_system.tenants t ON m.tenant_id = t.id 
WHERE t.slug = 'bestlens-demo';

SELECT 'LABORATÓRIOS CRIADOS:' as info;
SELECT l.nome, l.cidade, l.estado FROM suppliers.laboratorios l
JOIN meta_system.tenants t ON l.tenant_id = t.id 
WHERE t.slug = 'bestlens-demo';

COMMIT;