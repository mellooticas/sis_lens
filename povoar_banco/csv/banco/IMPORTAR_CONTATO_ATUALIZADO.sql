-- SCRIPT GERADO AUTOMATICAMENTE
BEGIN;

-- 1. FORNECEDORES
-- Solótica (Loja Oficial)

INSERT INTO core.fornecedores (id, nome, razao_social, ativo)
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'Solótica Oficial', 'Solótica Indústria e Comércio Ltda', true)
ON CONFLICT (id) DO NOTHING;

-- 2. MARCAS
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Acuvue', 'acuvue', 'Johnson & Johnson', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('40c1743c-b750-5ca6-a6cb-af5c613f82b0', 'Precision', 'precision', 'Alcon', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Bausch', 'bausch', 'Bausch & Lomb', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Clariti', 'clariti', 'CooperVision', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('03d9f1ed-fbe2-559a-b250-f42a86b69f1d', 'Proclear', 'proclear', 'CooperVision', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('b2c6b318-0842-4cea-9871-8f949445dede', 'Air Optix', 'air-optix', 'Alcon', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('1bd570cc-f5c5-594e-8a20-6d42d034e57f', 'Avaira', 'avaira', 'CooperVision', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Biofinity', 'biofinity', 'CooperVision', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('fd2bdef3-7a99-5766-b01d-67beb5b8767d', 'Biomedics', 'biomedics', 'CooperVision', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('03c77e05-0dc2-55e3-be9e-b9c3c5b8cdc1', 'Hidroblue', 'hidroblue', 'Solótica', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('a16aa23b-815c-421c-96e6-c652fc239d94', 'Hidrocor', 'hidrocor', 'Solótica', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('ecb32bbd-6796-52bb-88e3-3d6ec42c7302', 'Magic Top', 'magic-top', 'Optolentes', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('d7869a46-4b3e-599b-b89b-7a4adfde54ea', 'Natural Colors', 'natural-colors', 'Solótica', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('7cf574e1-e92f-5069-8dd6-3cb97299974f', 'Natural Vision', 'natural-vision', 'Natural Vision', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('965510a3-b51b-5bc2-b45f-63ad3b8b7bb7', 'Solflex', 'solflex', 'Solótica', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('38d91af6-0fed-43bc-97e8-1cab30a9631d', 'Soflens', 'soflens', 'Bausch & Lomb', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('371c7019-a93d-52f6-8156-28a26cd0f6f7', 'Ultra', 'ultra', 'Bausch & Lomb', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('0ae666e8-464c-56cd-bf6c-03cb002dd5b7', 'Biotrue', 'biotrue', 'Bausch & Lomb', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('cfc8bcfc-9061-582c-a352-6df31ebc46ed', 'Aveo', 'aveo', 'Aveo', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('4fcb3afe-be54-49bf-973e-d627090b0e2b', 'Dailies', 'dailies', 'Alcon', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('faf38bd7-f82d-56c6-9354-f67cbafce7f1', 'Bioblue', 'bioblue', 'Central Oftálmica', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('58dacfaf-b712-4fca-b972-0cd5a89008f1', 'Biosoft', 'biosoft', 'Central Oftálmica', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('ce8760b2-0bbf-5bdd-9246-f88b502b30c1', 'Purevision', 'purevision', 'Bausch & Lomb', True, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('200d0b79-bd91-51f9-9874-dd6bc9f906f6', 'Lunare', 'lunare', 'Bausch & Lomb', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('60050830-8a53-5132-968f-e25046572985', 'Optima', 'optima', 'Bausch & Lomb', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('f5441db3-c98a-585a-8299-07c7bdd17a6a', 'Hidrosoft', 'hidrosoft', 'Solótica', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('cdadf450-9406-5325-aa8e-c84458e0fc70', 'Optogel', 'optogel', 'Optolentes', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('f83cad32-5932-5c6a-98c9-2830c5ae8b16', 'Bioview', 'bioview', 'Central Oftálmica', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;
INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('b1194c29-cb97-5fc2-a5d6-74428c976147', 'Silidrogel', 'silidrogel', 'Central Oftálmica', False, True) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;

-- 3. LENTES
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', '1-Day Acuvue Moist | Conforto Diário | Lentes de Contato Descartáveis – Lentenet', '1-day-acuvue-moist-conforto-diario-lentes-de-contato-descartaveis-lentenet', '6', '6', 'diaria', 'silicone_hidrogel', 'visao_simples', 0.0, 266.0, 1, 30, '🎁 Aproveitem o Combo 4 Caixas!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/1-day-acuvue-moist/", "categorias_originais": "Acuvue; Diárias; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T04:59:30.494Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', '1-Day Acuvue Moist Astigmatismo', '1-day-acuvue-moist-astigmatismo', '10', '10', 'diaria', 'silicone_hidrogel', 'torica', 0.0, 300.0, 1, 30, '🎁 Aproveitem o Combo 4 Caixas!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/1-day-acuvue-moist-astigmatismo/", "categorias_originais": "Acuvue; Astigmatismo / Tórica; Diárias; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T04:59:35.834Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', '1 Day Acuvue Moist Multifocal', '1-day-acuvue-moist-multifocal', '68', '68', 'diaria', 'silicone_hidrogel', 'multifocal', 0.0, 333.0, 1, 30, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/1-day-acuvue-moist-multifocal/", "categorias_originais": "Acuvue; Diárias; Fabricantes; Lentes de contato; Multifocais; Multifocais", "scraping_at": "2026-01-28T04:59:42.862Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Acuvue Oasys 1-Day Com Hydraluxe', 'acuvue-oasys-1-day-com-hydraluxe', '4', '4', 'diaria', 'silicone_hidrogel', 'visao_simples', 0.0, 245.0, 1, 30, '🎁 Aproveitem o Combo 4 Caixas!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/acuvue-oasys-1-day-com-hydraluxe/", "categorias_originais": "Acuvue; Diárias; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T04:59:48.207Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '40c1743c-b750-5ca6-a6cb-af5c613f82b0', 'Precision 1 Day', 'precision-1-day', '79', '79', 'diaria', 'silicone_hidrogel', 'visao_simples', 0.0, 139.0, 1, 30, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/precision-1-day/", "categorias_originais": "Alcon; Diárias; Lentes de contato", "scraping_at": "2026-01-28T04:59:55.610Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Ultra One Day', 'ultra-one-day', '76', '76', 'diaria', 'silicone_hidrogel', 'visao_simples', 0.0, 225.0, 1, 30, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/ultra-one-day/", "categorias_originais": "Bausch & Lomb; Black Friday; Diárias; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:00:03.473Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Biotrue Oneday', 'biotrue-oneday', '28', '28', 'diaria', 'silicone_hidrogel', 'visao_simples', 0.0, 180.0, 1, 30, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/biotrue-oneday/", "categorias_originais": "Bausch & Lomb; Diárias; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:00:11.523Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Clariti 1 Day', 'clariti-1-day', '46', '46', 'diaria', 'silicone_hidrogel', 'visao_simples', 0.0, 154.4, 1, 30, '🎁 Aproveitem o Combo 4 Caixas!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/clariti-1-day/", "categorias_originais": "Black Friday; CooperVision; Diárias; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:00:16.573Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Clariti 1 Day Astigmatismo', 'clariti-1-day-astigmatismo', '48', '48', 'diaria', 'silicone_hidrogel', 'torica', 0.0, 200.0, 1, 30, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/clariti-1-day-astigmatismo/", "categorias_originais": "Astigmatismo / Tórica; Black Friday; CooperVision; Diárias; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:00:21.645Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Clariti 1 Day Multifocal', 'clariti-1-day-multifocal', '49', '49', 'diaria', 'silicone_hidrogel', 'multifocal', 0.0, 245.0, 1, 30, '🎁 Na compra de 3 caixas, a 4ª é por nossa conta!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/clariti-1-day-multifocal/", "categorias_originais": "CooperVision; Diárias; Fabricantes; Lentes de contato; Multifocais", "scraping_at": "2026-01-28T05:00:29.672Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '03d9f1ed-fbe2-559a-b250-f42a86b69f1d', 'Proclear 1 Day', 'proclear-1-day', '50', '50', 'diaria', 'silicone_hidrogel', 'visao_simples', 0.0, 143.0, 1, 30, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/proclear-1-day/", "categorias_originais": "CooperVision; Diárias; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:00:35.441Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Soflens Daily', 'soflens-daily', '29', '29', 'diaria', 'silicone_hidrogel', 'visao_simples', 0.0, 150.0, 1, 30, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/soflens-daily/", "categorias_originais": "Bausch & Lomb; Diárias; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:00:42.877Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Acuvue Oasys – 10% Off na segunda caixa', 'acuvue-oasys-10-off-na-segunda-caixa', '2', '2', 'quinzenal', 'silicone_hidrogel', 'visao_simples', 0.0, 234.66, 15, 1, '🎁 10% de Desconto na Segunda Caixa! 🎁 Aproveitem o Combo 4 Caixas! Experimente o conforto superior das lentes Acuvue Oasys. Com tecnologia Hydraclear e proteção UV, ideais para olhos secos e ambientes desafiadores. Compre na Lentenet!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/acuvue-oasys/", "categorias_originais": "Acuvue; Fabricantes; Lentes de contato; Quinzenais", "scraping_at": "2026-01-28T05:00:50.272Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Acuvue 2', 'acuvue-2', '8', '8', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 210.0, 30, 6, '🎁 Aproveitem o Combo 4 Caixas!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/acuvue-2/", "categorias_originais": "Acuvue; Fabricantes; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:00:55.595Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Air Optix Plus Hydraglyde', 'air-optix-plus-hydraglyde', '11', '11', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 300.0, 30, 6, '🎁 Aproveitem o Combo 4 Caixas!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/air-optix-aqua-plus-hydraglyde/", "categorias_originais": "Alcon; Black Friday; Fabricantes; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:01:00.659Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '1bd570cc-f5c5-594e-8a20-6d42d034e57f', 'Avaira', 'avaira', '43', '43', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 170.9, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/avaira/", "categorias_originais": "Black Friday; CooperVision; Fabricantes; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:01:05.770Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Soflens 59', 'soflens-59', '18', '18', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 170.0, 30, 6, '🎁 Na compra de 3 caixas, a 4ª é por nossa conta!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/soflens-59/", "categorias_originais": "Bausch & Lomb; Black Friday; Fabricantes; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:01:13.190Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Purevision 2', 'purevision-2', '24', '24', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 190.0, 30, 6, '🎁 Na compra de 3 caixas, a 4ª é por nossa conta!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/purevision-2/", "categorias_originais": "Bausch & Lomb; Black Friday; Fabricantes; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:01:18.271Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Bausch + Lomb Ultra With Moisture Seal', 'bausch-lomb-ultra-with-moisture-seal', '19', '19', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 300.0, 30, 6, '🎁 Na compra de 3 caixas, a 4ª é por nossa conta!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/bausch-lomb-ultra-with-moisture-seal/", "categorias_originais": "Bausch & Lomb; Fabricantes; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:01:25.440Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Biofinity', 'biofinity', '37', '37', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 210.0, 30, 6, '🎁 Aproveitem o Combo 4 Caixas Biofinity! #sb-shield { position: fixed; background: url(https://seal.siteblindado.com/lentedecontato.lentenet.com.br/seal.png) no-repeat; width: 50px; height: 50px; left: 0; bottom: 20px; cursor: pointer; display: block; text-decoration: none; } #sb-shield, #sb-shield:hover { width:170px; } #sb-shield:hover #sb-banner { opacity:1; }#sb-shield-2 { background: url(https://seal.siteblindado.com/lentedecontato.lentenet.com.br/seal.png) no-repeat; width: 100%; height:', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/biofinity/", "categorias_originais": "Black Friday; CooperVision; Fabricantes; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:01:34.637Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Biofinity XR – Graus Altos', 'biofinity-xr-graus-altos', '41', '41', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 300.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/biofinity-xr/", "categorias_originais": "CooperVision; Fabricantes; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:01:42.373Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '03d9f1ed-fbe2-559a-b250-f42a86b69f1d', 'Proclear XR – Graus Altos', 'proclear-xr-graus-altos', '94', '94', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 170.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/proclear-xr/", "categorias_originais": "CooperVision; Fabricantes; Lentes de contato; Mensais; Coopervision", "scraping_at": "2026-01-28T05:01:49.611Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'fd2bdef3-7a99-5766-b01d-67beb5b8767d', 'Biomedics 55 Evolution', 'biomedics-55-evolution', '45', '45', 'mensal', 'hidrogel', 'visao_simples', 0.0, 175.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/biomedics-55-evolution/", "categorias_originais": "Black Friday; CooperVision; Fabricantes; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:01:56.561Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '03d9f1ed-fbe2-559a-b250-f42a86b69f1d', 'Proclear', 'proclear', '44', '44', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 150.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/proclear/", "categorias_originais": "CooperVision; Fabricantes; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:02:02.019Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '03c77e05-0dc2-55e3-be9e-b9c3c5b8cdc1', 'Hidroblue (unidade)', 'hidroblue-unidade', '53', '53', 'anual', 'hidrogel', 'visao_simples', 0.0, 120.0, 365, 1, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/hidroblue/", "categorias_originais": "Anuais; Fabricantes; Lentes de contato; Solótica", "scraping_at": "2026-01-28T05:02:09.674Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Optima 38', 'optima-38', '27', '27', 'anual', 'silicone_hidrogel', 'visao_simples', 0.0, 130.0, 365, 1, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/optima-38/", "categorias_originais": "Anuais; Bausch & Lomb; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:02:14.896Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Optima FW', 'optima-fw', '26', '26', 'anual', 'silicone_hidrogel', 'visao_simples', 0.0, 130.0, 365, 1, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/optima-fw/", "categorias_originais": "Anuais; Bausch & Lomb; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:02:19.921Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Acuvue Oasys Astigmatismo', 'acuvue-oasys-astigmatismo', '9', '9', 'mensal', 'silicone_hidrogel', 'torica', 0.0, 420.0, 30, 6, '🎁 Aproveitem o Combo 4 Caixas!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/acuvue-oasys-astigmatismo/", "categorias_originais": "Acuvue; Astigmatismo / Tórica; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:02:27.493Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Air Optix Plus Hydraglyde para Astigmatismo', 'air-optix-plus-hydraglyde-para-astigmatismo', '12', '12', 'mensal', 'silicone_hidrogel', 'torica', 0.0, 440.0, 30, 6, '🎁 Aproveitem o Combo 4 Caixas!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/air-optix-plus-hydraglyde-para-astigmatismo/", "categorias_originais": "Alcon; Astigmatismo / Tórica; Black Friday; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:02:34.328Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Soflens Torica/Astigmatismo', 'soflens-torica-astigmatismo', '25', '25', 'mensal', 'silicone_hidrogel', 'torica', 0.0, 350.0, 30, 6, '🎁 Na compra de 3 caixas, a 4ª é por nossa conta!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/soflens-para-astigmatismo/", "categorias_originais": "Astigmatismo / Tórica; Bausch & Lomb; Black Friday; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:02:39.660Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Bausch + Lomb Ultra para Astigmatismo', 'bausch-lomb-ultra-para-astigmatismo', '20', '20', 'mensal', 'silicone_hidrogel', 'torica', 0.0, 430.0, 30, 6, '🎁 Na compra de 3 caixas, a 4ª é por nossa conta!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/bausch-lomb-ultra-para-astigmatismo/", "categorias_originais": "Astigmatismo / Tórica; Bausch & Lomb; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:02:47.534Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Biofinity Toric', 'biofinity-toric', '39', '39', 'mensal', 'silicone_hidrogel', 'torica', 0.0, 350.0, 30, 6, '🎁 Na compra de 3 caixas, a 4ª é por nossa conta!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/biofinity-toric/", "categorias_originais": "Astigmatismo / Tórica; Black Friday; CooperVision; Fabricantes; Lentes de contato", "scraping_at": "2026-01-28T05:02:54.579Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Air Optix Plus Hydraglyde Multifocal', 'air-optix-plus-hydraglyde-multifocal', '14', '14', 'mensal', 'silicone_hidrogel', 'multifocal', 0.0, 560.0, 30, 6, '🎁 Aproveitem o Combo 4 Caixas!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/air-optix-aqua-multifocal/", "categorias_originais": "Alcon; Black Friday; Fabricantes; Lentes de contato; Multifocais", "scraping_at": "2026-01-28T05:02:59.739Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Purevision 2 Multifocal', 'purevision-2-multifocal', '23', '23', 'mensal', 'silicone_hidrogel', 'multifocal', 0.0, 400.0, 30, 6, '🎁 Na compra de 3 caixas, a 4ª é por nossa conta!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/purevision-2-multifocal/", "categorias_originais": "Bausch & Lomb; Black Friday; Fabricantes; Lentes de contato; Multifocais", "scraping_at": "2026-01-28T05:03:06.838Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Soflens Multifocal', 'soflens-multifocal', '22', '22', 'mensal', 'silicone_hidrogel', 'multifocal', 0.0, 339.0, 30, 6, '🎁 Na compra de 3 caixas, a 4ª é por nossa conta!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/soflens-multifocal/", "categorias_originais": "Bausch & Lomb; Black Friday; Fabricantes; Lentes de contato; Multifocais", "scraping_at": "2026-01-28T05:03:13.907Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Bausch+Lomb Ultra Multifocal', 'bausch-lomb-ultra-multifocal', '21', '21', 'mensal', 'silicone_hidrogel', 'multifocal', 0.0, 420.0, 30, 6, '🎁 Na compra de 3 caixas, a 4ª é por nossa conta!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/bausch-lomb-ultra-multifocal/", "categorias_originais": "Bausch & Lomb; Fabricantes; Lentes de contato; Multifocais", "scraping_at": "2026-01-28T05:03:19.562Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Biofinity Multifocal', 'biofinity-multifocal', '40', '40', 'mensal', 'silicone_hidrogel', 'multifocal', 0.0, 380.0, 30, 6, '🎁 Na compra de 3 caixas, a 4ª é por nossa conta!', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/biofinity-multifocal/", "categorias_originais": "Black Friday; CooperVision; Fabricantes; Lentes de contato; Multifocais", "scraping_at": "2026-01-28T05:03:27.191Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'Hidrocor (unidade)', 'hidrocor-unidade', '57', '57', 'anual', 'hidrogel', 'cosmetica', 0.0, 130.0, 365, 1, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/hidrocor-unidade/", "categorias_originais": "Anuais; Coloridas; Fabricantes; Solótica", "scraping_at": "2026-01-28T05:03:32.592Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Lunare Tri-Kolor Anual Graduada (Unidade)', 'lunare-tri-kolor-anual-graduada-unidade', '31', '31', 'anual', 'silicone_hidrogel', 'cosmetica', 0.0, 120.0, 365, 1, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/lunare-tri-kolor-anual-graduada-unidade/", "categorias_originais": "Anuais; Bausch & Lomb; Coloridas; Fabricantes", "scraping_at": "2026-01-28T05:03:39.778Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Lunare Tri-Kolor Anual Sem Grau (o par)', 'lunare-tri-kolor-anual-sem-grau-o-par', '32', '32', 'anual', 'silicone_hidrogel', 'cosmetica', 0.0, 220.0, 365, 1, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/lunare-tri-kolor-anual-graduada-o-par/", "categorias_originais": "Anuais; Bausch & Lomb; Coloridas; Fabricantes", "scraping_at": "2026-01-28T05:03:47.536Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'ecb32bbd-6796-52bb-88e3-3d6ec42c7302', 'Magic Top (Unidade)', 'magic-top-unidade', '52', '52', 'anual', 'hidrogel', 'cosmetica', 0.0, 130.0, 365, 1, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/magic-top-unidade/", "categorias_originais": "Anuais; Coloridas; Fabricantes; Optolentes", "scraping_at": "2026-01-28T05:03:55.711Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'Natural Colors (unidade)', 'natural-colors-unidade', '56', '56', 'anual', 'hidrogel', 'cosmetica', 0.0, 130.0, 365, 1, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/natural-colors-unidade/", "categorias_originais": "Anuais; Coloridas; Fabricantes; Solótica", "scraping_at": "2026-01-28T05:04:03.397Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Air Optix Colors', 'air-optix-colors', '15', '15', 'mensal', 'silicone_hidrogel', 'cosmetica', 0.0, 130.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/air-optix-colors/", "categorias_originais": "Alcon; Coloridas; Fabricantes; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:04:11.316Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Air Optix Colors Combo 4 Caixas', 'air-optix-colors-combo-4-caixas', '92', '92', 'mensal', 'silicone_hidrogel', 'cosmetica', 0.0, 660.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/air-optix-colors-combo-4-caixas/", "categorias_originais": "Alcon; Coloridas; Lentes de contato; Mensais", "scraping_at": "2026-01-28T05:04:17.115Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '7cf574e1-e92f-5069-8dd6-3cb97299974f', 'Fantasy (o par)', 'fantasy-o-par', '51', '51', 'mensal', 'hidrogel', 'cosmetica', 0.0, 120.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/fantasy-o-par/", "categorias_originais": "Coloridas; Fabricantes; Mensais; Natural Vision", "scraping_at": "2026-01-28T05:04:22.823Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'Hidrocor Mensal', 'hidrocor-mensal', '58', '58', 'mensal', 'hidrogel', 'cosmetica', 0.0, 130.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/hidrocor-mensal/", "categorias_originais": "Coloridas; Fabricantes; Mensais; Solótica", "scraping_at": "2026-01-28T05:04:30.236Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Lunare Tri-Kolor Mensal Graduada (Unidade)', 'lunare-tri-kolor-mensal-graduada-unidade', '62', '62', 'mensal', 'silicone_hidrogel', 'cosmetica', 0.0, 70.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/lunare-tri-kolor-mensal-graduada-unidade/", "categorias_originais": "Bausch & Lomb; Coloridas; Fabricantes; Mensais", "scraping_at": "2026-01-28T05:04:38.661Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Lunare Tri-Kolor Mensal Sem Grau (o par)', 'lunare-tri-kolor-mensal-sem-grau-o-par', '33', '33', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 120.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/lunare-tri-kolor-mensal-sem-grau-o-par/", "categorias_originais": "Bausch & Lomb; Fabricantes; Mensais", "scraping_at": "2026-01-28T05:04:45.773Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Soflens Starcolors II (O par)', 'soflens-starcolors-ii-o-par', '30', '30', 'mensal', 'silicone_hidrogel', 'cosmetica', 0.0, 60.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/soflens-starcolors-ii-o-par/", "categorias_originais": "Bausch & Lomb; Coloridas; Fabricantes; Mensais", "scraping_at": "2026-01-28T05:04:52.914Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '965510a3-b51b-5bc2-b45f-63ad3b8b7bb7', 'Solflex Color Hype', 'solflex-color-hype', '54', '54', 'mensal', 'hidrogel', 'cosmetica', 0.0, 99.99, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/solflex-color-hype/", "categorias_originais": "Coloridas; Fabricantes; Mensais; Solótica", "scraping_at": "2026-01-28T05:05:00.489Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'Solflex Natural Colors', 'solflex-natural-colors', '55', '55', 'mensal', 'hidrogel', 'cosmetica', 0.0, 99.99, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/solflex-natural-colors/", "categorias_originais": "Coloridas; Fabricantes; Mensais; Solótica", "scraping_at": "2026-01-28T05:05:06.128Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', '1-Day Acuvue Moist Astigmatismo Combo 4 Caixas', '1-day-acuvue-moist-astigmatismo-combo-4-caixas', '65', '65', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 1.12304, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/1-day-acuvue-moist-astigmatismo-combo/", "categorias_originais": "Acuvue; Combos promocionais", "scraping_at": "2026-01-28T05:05:11.275Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', '1-Day Acuvue Moist combo 4 caixas', '1-day-acuvue-moist-combo-4-caixas', '5', '5', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 886.68, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/1-day-acuvue-moist-combo-4-caixas/", "categorias_originais": "Acuvue; Combos promocionais", "scraping_at": "2026-01-28T05:05:19.402Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Acuvue 2 – Combo com 4 Caixas | Lentes com Desconto | LenteNet', 'acuvue-2-combo-com-4-caixas-lentes-com-desconto-lentenet', '7', '7', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 758.24, 30, 6, 'Leve 4 caixas de Acuvue 2 com preço reduzido! Lentes confortáveis, seguras e originais. Frete grátis e desconto no PIX.', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/acuvue-2-combo-4-caixas/", "categorias_originais": "Acuvue; Combos promocionais", "scraping_at": "2026-01-28T05:05:24.536Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Acuvue Oasys 1-Day Com Hydraluxe combo 4 caixas', 'acuvue-oasys-1-day-com-hydraluxe-combo-4-caixas', '3', '3', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 800.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/acuvue-oasys-1-day-com-hydraluxe-combo-4-caixas/", "categorias_originais": "Acuvue; Combos promocionais", "scraping_at": "2026-01-28T05:05:30.054Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Acuvue Oasys Astigmatismo Combo 4 Caixas', 'acuvue-oasys-astigmatismo-combo-4-caixas', '60', '60', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 1.12, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/acuvue-oasys-astigmatismo-combo-4-caixas/", "categorias_originais": "Acuvue; Combos promocionais", "scraping_at": "2026-01-28T05:05:35.487Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Acuvue Oasys – Combo com 4 Caixas | Lentes de Contato – Lentenet', 'acuvue-oasys-combo-com-4-caixas-lentes-de-contato-lentenet', '1', '1', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 988.04, 30, 6, 'Combo 4 caixas Acuvue Oasys com tecnologia Hydraclear Plus – conforto duradouro para miopia/hipermetropia. Entrega rápida na Lentenet.', True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/acuvue-oasys-combo-4-caixas/", "categorias_originais": "Acuvue; Combos; Combos promocionais", "scraping_at": "2026-01-28T05:05:42.918Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Air Optix Plus Hydraglyde Multifocal Combo 4 Caixas', 'air-optix-plus-hydraglyde-multifocal-combo-4-caixas', '83', '83', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 1.68, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/air-opaqua-multifocal-combo-4-caixas/", "categorias_originais": "Combos promocionais; Alcon; Black Friday", "scraping_at": "2026-01-28T05:05:48.348Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Air Optix Plus Hydraglyde combo 4 caixas', 'air-optix-plus-hydraglyde-combo-4-caixas', '84', '84', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 680.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/air-optix-aqua-plus-hydraglyde-combo-4-caixas/", "categorias_originais": "Alcon; Black Friday; Combos; Combos promocionais", "scraping_at": "2026-01-28T05:05:54.599Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Air Optix Plus Hydraglyde para Astigmatismo Combo 4 caixas', 'air-optix-plus-hydraglyde-para-astigmatismo-combo-4-caixas', '86', '86', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 1.02, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/air-optix-plus-hydraglyde-para-astigmatismo-combo-4-caixas/", "categorias_originais": "Alcon; Black Friday; Combos promocionais", "scraping_at": "2026-01-28T05:06:02.332Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '40c1743c-b750-5ca6-a6cb-af5c613f82b0', 'Precision 1 Day combo 4 caixas', 'precision-1-day-combo-4-caixas', '91', '91', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 820.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/precision-1-day-combo-4-caixas/", "categorias_originais": "Alcon; Black Friday", "scraping_at": "2026-01-28T05:06:09.193Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Bausch + Lomb Ultra combo 4 caixas', 'bausch-lomb-ultra-combo-4-caixas', '34', '34', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 800.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/bausch-lomb-ultra-combo-4-caixas/", "categorias_originais": "Bausch & Lomb; Black Friday; Combos promocionais", "scraping_at": "2026-01-28T05:06:14.316Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Purevision 2 Combo 4 caixas', 'purevision-2-combo-4-caixas', '36', '36', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 680.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/purevision-2-combo-4-caixas/", "categorias_originais": "Bausch & Lomb; Black Friday; Combos promocionais", "scraping_at": "2026-01-28T05:06:19.575Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Purevision 2 Multifocal Combo 4 Caixas', 'purevision-2-multifocal-combo-4-caixas', '67', '67', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 1.4, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/purevision-2-multifocal-combo/", "categorias_originais": "Bausch & Lomb; Black Friday; Combos promocionais", "scraping_at": "2026-01-28T05:06:24.611Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Soflens 59 Comfort combo 4 caixas', 'soflens-59-comfort-combo-4-caixas', '35', '35', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 580.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/soflens-59-comfort-combo-4-caixas/", "categorias_originais": "Bausch & Lomb; Black Friday; Combos promocionais", "scraping_at": "2026-01-28T05:06:32.081Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Soflens Multifocal Combo 4 Caixas', 'soflens-multifocal-combo-4-caixas', '66', '66', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 1.2, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/soflens-multifocal-combo/", "categorias_originais": "Bausch & Lomb; Black Friday; Combos promocionais", "scraping_at": "2026-01-28T05:06:40.155Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Soflens para Astigmatismo Combo 4 Caixas', 'soflens-para-astigmatismo-combo-4-caixas', '63', '63', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 990.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/soflens-para-astigmatismo-combo/", "categorias_originais": "Bausch & Lomb; Black Friday; Combos promocionais", "scraping_at": "2026-01-28T05:06:45.383Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'bdc5b2b2-b84c-5881-9cdd-c1b8aaf48b3a', 'Ultra One Day combo 4 caixas', 'ultra-one-day-combo-4-caixas', '82', '82', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 680.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/ultra-one-day-combo-4-caixas/", "categorias_originais": "Bausch & Lomb; Black Friday; Combos promocionais", "scraping_at": "2026-01-28T05:06:50.642Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '1bd570cc-f5c5-594e-8a20-6d42d034e57f', 'Avaira Combo 4 Caixas', 'avaira-combo-4-caixas', '42', '42', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 648.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/avaira-combo-4-caixas/", "categorias_originais": "Black Friday; Combos promocionais; CooperVision", "scraping_at": "2026-01-28T05:06:55.721Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Biofinity Combo 4 Caixas', 'biofinity-combo-4-caixas', '38', '38', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 840.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/biofinity-combo-4-caixas/", "categorias_originais": "Black Friday; Combos promocionais; CooperVision; Coopervision", "scraping_at": "2026-01-28T05:07:00.816Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Biofinity Combo 6 Caixas e ganhe 2 caixas de brinde', 'biofinity-combo-6-caixas-e-ganhe-2-caixas-de-brinde', '93', '93', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 1.68, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/biofinity-combo-6-caixas/", "categorias_originais": "Black Friday; Combos promocionais; CooperVision; Coopervision", "scraping_at": "2026-01-28T05:07:08.537Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Biofinity Toric Combo 4 caixas', 'biofinity-toric-combo-4-caixas', '61', '61', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 1.196, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/biofinity-toric-combo-4-caixas/", "categorias_originais": "Black Friday; Combos promocionais; CooperVision", "scraping_at": "2026-01-28T05:07:15.721Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Clariti 1 Day Combo 4 Caixas', 'clariti-1-day-combo-4-caixas', '47', '47', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 460.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/clariti-1-day-combo-4-caixas/", "categorias_originais": "Black Friday; Combos promocionais; CooperVision", "scraping_at": "2026-01-28T05:07:20.971Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('b01bd4fe-a383-4006-b4ec-1d397ba2c0c1', '7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Clariti 1 Day para Astigmatismo combo 4 caixas', 'clariti-1-day-para-astigmatismo-combo-4-caixas', '64', '64', 'mensal', 'silicone_hidrogel', 'visao_simples', 0.0, 720.0, 30, 6, NULL, True, True, '{"url_original": "https://lentedecontato.lentenet.com.br/produto/clariti-1-day-para-astigmatismo-combo/", "categorias_originais": "Black Friday; Combos promocionais; CooperVision", "scraping_at": "2026-01-28T05:07:26.013Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Lentes de Contato Acuvue Oasys 1-Day com Hydraluxe', 'lentes-de-contato-acuvue-oasys-1-day-com-hydraluxe', '130111', '130111', 'mensal', 'silicone_hidrogel', 'visao_simples', 175.04, 225.54, 30, 6, 'Acuvue Oasys 1-Day com Hydraluxe é desenvolvida para quem faz uso frequente de aparelhos digitais e não abre mão de conforto e saúde ocular.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-acuvue-oasys-1-day-com-hydraluxe-130111", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:45:21.989Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Lentes de Contato 1-Day Acuvue Moist', 'lentes-de-contato-1-day-acuvue-moist', '71294', '71294', 'mensal', 'silicone_hidrogel', 'visao_simples', 197.18, 287.89, 30, 6, 'Compre lentes Acuvue 1-Day Moist da Johnson & Johnson aqui na Newlentes. Compra segura com Frete Grátis e Desconto no pagamento á vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-1-day-acuvue-moist-71294", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:45:30.824Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Lentes de Contato Clariti 1 Day', 'lentes-de-contato-clariti-1-day', '130011', '130011', 'mensal', 'silicone_hidrogel', 'visao_simples', 197.18, 266.72, 30, 6, 'Compre as Lentes de Contato Clariti 1 Day da CooperVision aqui na NewLentes com frete grátis* e parcelado sem juros. Lentes novas todos os dias!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-clariti-1-day-130011", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:45:38.990Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Lentes de contato Acuvue Oasys 1-Day com Hydraluxe para astigmatismo', 'lentes-de-contato-acuvue-oasys-1-day-com-hydraluxe-para-astigmatismo', '134500', '134500', 'mensal', 'silicone_hidrogel', 'visao_simples', 227.69, 316.99, 30, 6, 'Compre Lentes de contato Acuvue Oasys 1-Day com Hydraluxe para astigmatismo do fabricante Acuvue por apenas R$ 283,46 aqui na Newlentes. Somos revendedor autorizado Acuvue', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-acuvue-oasys-1-day-com-hydraluxe-para-astigmatismo-134500", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:46:20.036Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Lentes de Contato 1-Day Acuvue Moist Multifocal', 'lentes-de-contato-1-day-acuvue-moist-multifocal', '130062', '130062', 'mensal', 'silicone_hidrogel', 'visao_simples', 207.56, 303.36, 30, 6, 'Compre as Lentes 1-Day Acuvue Moist Multifocal aqui na NewLentes com as melhores vantagens. Aproveite!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-1-day-acuvue-moist-multifocal-130062", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:46:29.645Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '38d91af6-0fed-43bc-97e8-1cab30a9631d', 'Lentes de contato Soflens Daily', 'lentes-de-contato-soflens-daily', '129924', '129924', 'mensal', 'silicone_hidrogel', 'visao_simples', 220.99, 266.72, 30, 6, 'Lentes de contato Soflens Daily da Bausch Lomb você encontra aqui na NewLentes. Compra Segura com Frete Grátis e Desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-soflens-daily-129924", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:46:39.909Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '371c7019-a93d-52f6-8156-28a26cd0f6f7', 'Lentes de Contato Ultra One Day', 'lentes-de-contato-ultra-one-day', '136766', '136766', 'mensal', 'silicone_hidrogel', 'visao_simples', 273.64, 316.99, 30, 6, 'Compre Lentes de Contato Ultra One Day do fabricante Bausch Lomb por apenas R$ 206,36 aqui na Newlentes. Somos revendedor autorizado Bausch Lomb', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-ultra-one-day-136766", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:46:49.692Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Lentes de Contato Clariti 1 Day Tórica', 'lentes-de-contato-clariti-1-day-torica', '130012', '130012', 'mensal', 'silicone_hidrogel', 'visao_simples', 284.05, 359.1, 30, 6, 'Compre as Lentes de Contato Clariti 1 Day Tórica com frete gratis*, desconto à vista ou parcelamento sem juros. Aproveite!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-clariti-1-day-torica-130012", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:46:57.285Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '40c1743c-b750-5ca6-a6cb-af5c613f82b0', 'Lentes de contato Precision 1 Day', 'lentes-de-contato-precision-1-day', '135836', '135836', 'mensal', 'silicone_hidrogel', 'visao_simples', 187.13, 270.0, 30, 6, 'Compre Lentes de contato Precision 1 Day do fabricante Alcon por apenas R$ 215,79 aqui na Newlentes. Somos revendedor autorizado Alcon', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-precision-1-day-135836", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:47:05.727Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '03d9f1ed-fbe2-559a-b250-f42a86b69f1d', 'Lentes de Contato Proclear 1 Day', 'lentes-de-contato-proclear-1-day', '129805', '129805', 'mensal', 'silicone_hidrogel', 'visao_simples', 197.18, 287.89, 30, 6, 'Lentes de Contato Proclear 1 Day', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-proclear-1-day-129805", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:47:17.130Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '0ae666e8-464c-56cd-bf6c-03cb002dd5b7', 'Lentes de contato Biotrue ONEDay', 'lentes-de-contato-biotrue-oneday', '129925', '129925', 'mensal', 'silicone_hidrogel', 'visao_simples', 197.18, 287.89, 30, 6, 'Compre lentes de contato Biotrue ONEday da Bausch Lomb aqui na NewLentes. Compra Segura com Frete Grátis e Desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-biotrue-oneday-129925", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:47:26.872Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'cfc8bcfc-9061-582c-a352-6df31ebc46ed', 'Lentes de contato Aveo Hello - Descarte diário', 'lentes-de-contato-aveo-hello-descarte-diario', '130228', '130228', 'mensal', 'hidrogel', 'visao_simples', 197.18, 287.89, 30, 6, 'As lentes Aveo Hello se tornou uma marca exclusiva na NewLentes. Compre com segurança, frete grátis* e desconto no pagamento à vista!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-aveo-hello-descarte-diario-130228", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:47:35.598Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Lentes de Contato Clariti 1 Day Multifocal', 'lentes-de-contato-clariti-1-day-multifocal', '130013', '130013', 'mensal', 'silicone_hidrogel', 'visao_simples', 273.64, 420.0, 30, 6, 'Compre as Lentes de Contato Clariti 1 Day Multifocal aqui na NewLentes com frete grátis*. Aproveite nosso desconto à vista. Confira!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-clariti-1-day-multifocal-130013", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:47:44.374Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '4fcb3afe-be54-49bf-973e-d627090b0e2b', 'Lentes de Contato Dailies AquaComfort Plus Multifocal', 'lentes-de-contato-dailies-aquacomfort-plus-multifocal', '129832', '129832', 'mensal', 'silicone_hidrogel', 'visao_simples', 273.64, 420.0, 30, 6, 'Lentes de Contato Dailies AquaComfort Plus Multifocal', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-dailies-aquacomfort-plus-multifocal-129832", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:47:54.816Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'faf38bd7-f82d-56c6-9354-f67cbafce7f1', 'Lentes de contato coloridas Bioblue Color 1-Day - Sem grau', 'lentes-de-contato-coloridas-bioblue-color-1-day-sem-grau', '134493', '134493', 'mensal', 'hidrogel', 'visao_simples', 129.99, 186.2, 30, 6, 'Compre Lentes de contato coloridas Bioblue Color 1-Day - Sem grau do fabricante Central Oftálmica por apenas R$ 148,00 aqui na Newlentes. Somos revendedor autorizado Central Oftálmica', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-bioblue-color-1-day-sem-grau-134493", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:48:03.622Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '58dacfaf-b712-4fca-b972-0cd5a89008f1', 'Lentes de Contato BioSoft One Day', 'lentes-de-contato-biosoft-one-day', '130897', '130897', 'mensal', 'hidrogel', 'visao_simples', 96.85, 123.5, 30, 6, 'Compre lentes de contato Biosoft 1-Day aqui na NewLentes com entrega garantida para todo Brasil, aproveite nossa promoção de frete grátis*', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-biosoft-one-day-130897", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:48:12.539Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Lentes de Contato Acuvue Oasys', 'lentes-de-contato-acuvue-oasys', '71298', '71298', 'mensal', 'silicone_hidrogel', 'visao_simples', 160.56, 234.66, 30, 6, 'Precisando de lentes Acuvue Oasys? Temos a pronta entrega e você ainda ganha Frete Grátis* para todo Brasil.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-acuvue-oasys-71298", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:48:21.010Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Lentes de Contato Acuvue Oasys Astigmatismo', 'lentes-de-contato-acuvue-oasys-astigmatismo', '71326', '71326', 'mensal', 'silicone_hidrogel', 'visao_simples', 227.69, 316.99, 30, 6, 'Lentes Oasys para Astigmatismo com frete grátis* para todo Brasil. Compra segura e menor prazo de entrega. Confira!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-acuvue-oasys-astigmatismo-71326", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:48:30.985Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Lentes de Contato Acuvue 2', 'lentes-de-contato-acuvue-2', '71290', '71290', 'mensal', 'silicone_hidrogel', 'visao_simples', 123.21, 180.08, 30, 6, 'Compre lentes Acuvue 2 com frete grátis* para todo Brasil. Compra segura com menor prazo de entrega. Confira!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-acuvue-2-71290", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:48:40.242Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Lentes de Contato Acuvue Oasys Transitions', 'lentes-de-contato-acuvue-oasys-transitions', '130908', '130908', 'mensal', 'silicone_hidrogel', 'visao_simples', 227.69, 303.36, 30, 6, 'A tecnologia Transitions agora em lentes de contato! Confira as lentes Acuvue Oasys Transitions, o último lançamento da Johnson & Johnson.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-acuvue-oasys-transitions-130908", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:48:51.378Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '38d91af6-0fed-43bc-97e8-1cab30a9631d', 'Lentes de Contato Soflens 59', 'lentes-de-contato-soflens-59', '71259', '71259', 'mensal', 'silicone_hidrogel', 'visao_simples', 103.29, 150.96, 30, 6, 'Compre lentes de contato Soflens 59 da Bausch Lomb aqui na NewLentes. Loja referência em lentes de contato desde 2010. Aproveite o Frete Grátis*.gamento á vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-soflens-59-71259", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:49:00.913Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Lentes de contato Biofinity', 'lentes-de-contato-biofinity', '71305', '71305', 'mensal', 'silicone_hidrogel', 'visao_simples', 153.95, 225.0, 30, 6, 'Compre lente de contato Biofinity com um clique e ainda ganha Frete Grátis* para todo Brasil. Aproveite também nosso desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-biofinity-71305", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:49:09.366Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '38d91af6-0fed-43bc-97e8-1cab30a9631d', 'Lentes de Contato Soflens Toric', 'lentes-de-contato-soflens-toric', '71245', '71245', 'mensal', 'silicone_hidrogel', 'visao_simples', 370.5, 350.0, 30, 6, 'Lentes Soflens Toric para cuidar do seu astigmatismo, você encontra aqui na NewLentes. Aproveite nosso frete grátis* e preço baixo. Confira!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-soflens-toric-71245", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:49:18.691Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Lentes de Contato Biofinity Toric', 'lentes-de-contato-biofinity-toric', '71301', '71301', 'mensal', 'silicone_hidrogel', 'visao_simples', 370.5, 368.42, 30, 6, 'Compre lentes de contato Biofinity Toric da Coopervision aqui na NewLentes. Aproveite hoje nosso Frete Grátis* para todo Brasil e desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-biofinity-toric-71301", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:49:27.992Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Lentes de Contato Air Optix Plus Hydraglyde', 'lentes-de-contato-air-optix-plus-hydraglyde', '130040', '130040', 'mensal', 'silicone_hidrogel', 'visao_simples', 153.95, 225.0, 30, 6, 'Compre lentes de contato Air Optix Hydraglyde da Alcon aqui na NewLentes. Compre com Frete Grátis e Desconto no pagamento à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-air-optix-plus-hydraglyde-130040", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:49:35.553Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '1bd570cc-f5c5-594e-8a20-6d42d034e57f', 'Lentes de Contato Avaira Vitality', 'lentes-de-contato-avaira-vitality', '130118', '130118', 'mensal', 'silicone_hidrogel', 'visao_simples', 197.18, 266.72, 30, 6, 'As lentes Avaira agora são Avaira Vitality. O fabricante CooperVision inovou no produto trazendo um upgrade sem esforço para você que usa lentes Avaira. Saiba mais!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-avaira-vitality-130118", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:49:45.059Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Lentes de contato Air Optix Colors - COM GRAU', 'lentes-de-contato-air-optix-colors-com-grau', '129774', '129774', 'mensal', 'silicone_hidrogel', 'visao_simples', 112.89, 165.0, 30, 6, 'Lentes de contato Air Optix Colors', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-air-optix-colors-com-grau-129774", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:49:54.885Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Lentes de Contato Air Optix Plus Hydraglyde Astigmatism', 'lentes-de-contato-air-optix-plus-hydraglyde-astigmatism', '130906', '130906', 'mensal', 'silicone_hidrogel', 'visao_simples', 273.0, 350.0, 30, 6, 'Compre as lentes de contato Air Optix Plus Hydraglyde para Astigmatism com frete grátis* para todo Brasil. E ainda ganha desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-air-optix-plus-hydraglyde-astigmatism-130906", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:50:04.211Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'ce8760b2-0bbf-5bdd-9246-f88b502b30c1', 'Lentes de Contato Purevision 2', 'lentes-de-contato-purevision-2', '71261', '71261', 'mensal', 'silicone_hidrogel', 'visao_simples', 251.54, 303.36, 30, 6, 'Compre lentes de contato Purevision 2 da Bausch Lomb aqui na NewLentes. Compra segura com frete grátis* para todo Brasil e desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-purevision-2-71261", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:50:46.956Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '965510a3-b51b-5bc2-b45f-63ad3b8b7bb7', 'Lentes de Contato Solflex CL', 'lentes-de-contato-solflex-cl', '71315', '71315', 'mensal', 'hidrogel', 'visao_simples', 173.37, 217.55, 30, 6, 'Compre lentes de contato com grau Solflex CL da Solótica aqui na NewLentes. Compra segura com frete grátis* e desconto no pagamento à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-solflex-cl-71315", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:50:55.954Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '371c7019-a93d-52f6-8156-28a26cd0f6f7', 'Lentes de contato Ultra com MoistureSeal', 'lentes-de-contato-ultra-com-moistureseal', '130119', '130119', 'mensal', 'silicone_hidrogel', 'visao_simples', 273.64, 316.99, 30, 6, 'Compre aqui as lentes Ultra da Bausch Lomb. Aproveite nossa promoção de frete grátis* e desconto no pagamento à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-ultra-com-moistureseal-130119", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:51:06.876Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '03d9f1ed-fbe2-559a-b250-f42a86b69f1d', 'Lentes de Contato Proclear', 'lentes-de-contato-proclear', '71306', '71306', 'mensal', 'silicone_hidrogel', 'visao_simples', 197.18, 266.72, 30, 6, 'Compre lentes de contato Proclear da Coopervision aqui na NewLentes. Compra Segura com Frete Grátis para todo Brasil e Desconto no pagamento à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-proclear-71306", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:51:17.337Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'fd2bdef3-7a99-5766-b01d-67beb5b8767d', 'Lentes de Contato Biomedics 55 Evolution', 'lentes-de-contato-biomedics-55-evolution', '71308', '71308', 'mensal', 'hidrogel', 'visao_simples', 197.18, 269.29, 30, 6, 'Compre lentes de contato Biomedics 55 Evolution da Coopervision aqui na NewLentes. Compra Segura com Frete Grátis e Desconto no pagamento à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-biomedics-55-evolution-71308", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:51:26.426Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '38d91af6-0fed-43bc-97e8-1cab30a9631d', 'Lentes de Contato Soflens Multi-Focal', 'lentes-de-contato-soflens-multi-focal', '71258', '71258', 'mensal', 'silicone_hidrogel', 'visao_simples', 232.62, 339.99, 30, 6, 'Compre lentes de contato Soflens Multifocal da Bausch Lomb aqui na NewLentes. Compra segura com frete grátis* e desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-soflens-multi-focal-71258", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:51:34.158Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Lentes de Contato Biofinity Multifocal', 'lentes-de-contato-biofinity-multifocal', '71297', '71297', 'mensal', 'silicone_hidrogel', 'visao_simples', 247.0, 361.0, 30, 6, 'Compre lentes de contato Biofinity Multifocal da Coopervision aqui na NewLentes. Compra Segura com Frete Grátis e Desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-biofinity-multifocal-71297", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:51:42.515Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'Lentes de contato coloridas Solflex Natural Colors - Sem grau', 'lentes-de-contato-coloridas-solflex-natural-colors-sem-grau', '129789', '129789', 'mensal', 'hidrogel', 'visao_simples', 121.03, 165.0, 30, 6, 'Compre Lentes de contato coloridas Solflex Natural Colors - Sem grau do fabricante Solótica por apenas R$ 107,00 aqui na Newlentes. Somos revendedor autorizado Solótica', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-solflex-natural-colors-sem-grau-129789", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:51:51.665Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Lentes de Contato Air Optix Plus Hydraglyde Multifocal', 'lentes-de-contato-air-optix-plus-hydraglyde-multifocal', '133478', '133478', 'mensal', 'silicone_hidrogel', 'visao_simples', 287.37, 420.0, 30, 6, 'Compre Lentes de Contato Air Optix Plus Hydraglyde Multifocal do fabricante Alcon por apenas R$ 442,10 aqui na Newlentes. Somos revendedor autorizado Alcon', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-air-optix-plus-hydraglyde-multifocal-133478", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:51:59.671Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'Lentes de contato coloridas Hidrocor mensal - Sem grau', 'lentes-de-contato-coloridas-hidrocor-mensal-sem-grau', '130318', '130318', 'mensal', 'hidrogel', 'visao_simples', 121.03, 165.0, 30, 6, 'Lentes de Contato Coloridas Hidrocor disponíveis em 5 cores.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-hidrocor-mensal-sem-grau-130318", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:52:09.541Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'b2c6b318-0842-4cea-9871-8f949445dede', 'Lentes de contato coloridas Air Optix Colors - Sem grau', 'lentes-de-contato-coloridas-air-optix-colors-sem-grau', '129762', '129762', 'mensal', 'silicone_hidrogel', 'visao_simples', 121.03, 173.68, 30, 6, 'Lentes de contato Air Optix Colors', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-air-optix-colors-sem-grau-129762", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:52:20.117Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Lentes de contato Biofinity Energys', 'lentes-de-contato-biofinity-energys', '134364', '134364', 'mensal', 'silicone_hidrogel', 'visao_simples', 197.18, 266.72, 30, 6, 'As lentes Biofinity Energys é o produto premium da marca CooperVision. Compre sem sair de casa com frete grátis. Aproveite!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-biofinity-energys-134364", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:52:29.147Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '200d0b79-bd91-51f9-9874-dd6bc9f906f6', 'Lentes de Contato Colorida Lunare Tri-Kolor Mensal - COM GRAU', 'lentes-de-contato-colorida-lunare-tri-kolor-mensal-com-grau', '129698', '129698', 'mensal', 'hidrogel', 'visao_simples', 96.85, 133.0, 30, 6, 'Lentes de Contato Colorida Lunare Tri-Kolor Mensal', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-colorida-lunare-tri-kolor-mensal-com-grau-129698", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:52:39.393Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '38d91af6-0fed-43bc-97e8-1cab30a9631d', 'Lentes de contato coloridas Soflens StarColors II - Sem grau', 'lentes-de-contato-coloridas-soflens-starcolors-ii-sem-grau', '129784', '129784', 'mensal', 'silicone_hidrogel', 'visao_simples', 129.99, 186.2, 30, 6, 'Lentes de Contato Colorida SOFLENS STARCOLORS II', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-soflens-starcolors-ii-sem-grau-129784", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:52:48.207Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7cf574e1-e92f-5069-8dd6-3cb97299974f', 'Lentes de contato coloridas Natural Vision mensal - Sem grau', 'lentes-de-contato-coloridas-natural-vision-mensal-sem-grau', '130227', '130227', 'mensal', 'hidrogel', 'visao_simples', 121.03, 149.0, 30, 6, 'Novidade no mundo de lentes de contato, as lentes Natural Vision vieram com mais de 15 cores disponíveis. Aproveite nosso frete grátis* e desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-natural-vision-mensal-sem-grau-130227", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:52:58.011Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7cf574e1-e92f-5069-8dd6-3cb97299974f', 'Lentes de Contato Natural Vision Mensal', 'lentes-de-contato-natural-vision-mensal', '130206', '130206', 'mensal', 'hidrogel', 'visao_simples', 96.85, 146.3, 30, 6, 'Lentes Natural Vision você encontra aqui na NewLentes. Receba no seu endereço com Frete Grátis* e desconto no pagamento à vista. Aproveite!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-natural-vision-mensal-130206", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:53:09.472Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Lentes de Contato Biofinity XR Toric - Graus Altos', 'lentes-de-contato-biofinity-xr-toric-graus-altos', '130121', '130121', 'mensal', 'silicone_hidrogel', 'visao_simples', 390.0, 570.0, 30, 6, 'Tem grau alto e com astigmatismo? As lentes de contato Biofinity XR Toric atendem sua necessidade. Aproveite nosso frete grátis e desconto à vista. Confira!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-biofinity-xr-toric-graus-altos-130121", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:53:19.589Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88', 'Lentes de Contato Biofinity XR - Graus Altos', 'lentes-de-contato-biofinity-xr-graus-altos', '130120', '130120', 'mensal', 'silicone_hidrogel', 'visao_simples', 370.5, 361.0, 30, 6, 'Lentes Biofinity XR para graus altos de miopia ou hipermetropia, você encontra aqui na NewLentes. Aproveite nosso frete grátis* para todo Brasil.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-biofinity-xr-graus-altos-130120", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:53:28.644Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'Lentes de Contato Colorida Hidrocor - COM GRAU', 'lentes-de-contato-colorida-hidrocor-com-grau', '71322', '71322', 'mensal', 'hidrogel', 'visao_simples', 96.85, 133.0, 30, 6, 'Compre lentes de contato colorida Hidrocor da Solótica aqui na NewLentes. São diversas cores e você ainda ganha frete grátis* para todo Brasil.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-colorida-hidrocor-com-grau-71322", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:54:12.111Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'Lentes de Contato Colorida Natural Colors - COM GRAU', 'lentes-de-contato-colorida-natural-colors-com-grau', '71324', '71324', 'mensal', 'hidrogel', 'visao_simples', 96.85, 97.0, 30, 6, 'Compre lentes de contato colorida Natural Colors da Solótica aqui na NewLentes. São diversas cores e você ainda ganha frete grátis* para todo Brasil.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-colorida-natural-colors-com-grau-71324", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:54:22.831Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'Lentes de contato coloridas Hidrocor - Kit sem grau', 'lentes-de-contato-coloridas-hidrocor-kit-sem-grau', '129782', '129782', 'mensal', 'hidrogel', 'visao_simples', 129.99, 196.0, 30, 6, 'Compre Lentes de contato coloridas Hidrocor - Kit sem grau do fabricante Solótica por apenas R$ 196,00 aqui na Newlentes. Somos revendedor autorizado Solótica', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-hidrocor-kit-sem-grau-129782", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:55:05.733Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', NULL, 'Lentes de Contato SoftFlex 55w', 'lentes-de-contato-softflex-55w', '129735', '129735', 'mensal', 'hidrogel', 'visao_simples', 187.13, 269.29, 30, 6, 'Compre lentes de contato Softflex 55w aqui na NewLentes. Compra Segura com Frete Grátis para todo Brasil e Desconto no pagamento à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-softflex-55w-129735", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:55:13.816Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '200d0b79-bd91-51f9-9874-dd6bc9f906f6', 'Lentes de Contato Colorida Lunare Tri-Kolor Anual - COM GRAU', 'lentes-de-contato-colorida-lunare-tri-kolor-anual-com-grau', '129699', '129699', 'mensal', 'hidrogel', 'visao_simples', 96.85, 105.25, 30, 6, 'Compre lentes de contato colorida Lunare da Bausch Lomb aqui na Newlentes. Compra segura com frete grátis* e desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-colorida-lunare-tri-kolor-anual-com-grau-129699", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:55:24.480Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'ecb32bbd-6796-52bb-88e3-3d6ec42c7302', 'Lentes de Contato Colorida Magic Top - COM GRAU', 'lentes-de-contato-colorida-magic-top-com-grau', '71299', '71299', 'mensal', 'hidrogel', 'visao_simples', 96.85, 140.0, 30, 6, 'Compre lentes de contato colorida Optycolor Magic Top aqui na NewLentes. Compra Segura com Frete Grátis para todo Brasil e Desconto no pagamento à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-colorida-magic-top-com-grau-71299", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:55:35.058Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '60050830-8a53-5132-968f-e25046572985', 'Lentes de Contato Optima 38', 'lentes-de-contato-optima-38', '71260', '71260', 'mensal', 'hidrogel', 'visao_simples', 175.04, 234.66, 30, 6, 'Lentes Optima 38 da Bausch Lomb com Frete Grátis* para todo Brasil. Compre com segurança em clique. Confira!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-optima-38-71260", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:55:43.522Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'f5441db3-c98a-585a-8299-07c7bdd17a6a', 'Lentes de Contato Hidrosoft', 'lentes-de-contato-hidrosoft', '71320', '71320', 'mensal', 'hidrogel', 'visao_simples', 136.88, 149.0, 30, 6, 'Compre lentes de contato com grau Hidrosoft da Solótica aqui na NewLentes. Compra segura e desconto no pagamento à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-hidrosoft-71320", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:55:51.648Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '60050830-8a53-5132-968f-e25046572985', 'Lentes de Contato Optima FW', 'lentes-de-contato-optima-fw', '71285', '71285', 'mensal', 'hidrogel', 'visao_simples', 197.18, 269.29, 30, 6, 'Compre lentes de contato Optima FW da Bausch Lomb aqui na Newlentes, referênciua em lentes desde 2010. Aproveite nosso Frete Grátis*', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-optima-fw-71285", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:56:00.762Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7cf574e1-e92f-5069-8dd6-3cb97299974f', 'Lente de contato colorida Natural Vision anual - Com grau', 'lente-de-contato-colorida-natural-vision-anual-com-grau', '130224', '130224', 'mensal', 'hidrogel', 'visao_simples', 96.85, 90.7, 30, 6, 'Confira as lentes de contato Natural Vision aqui na NewLentes. São diversas cores e de descarte mensal ou anual. Aproveite nosso frete grátis*.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lente-de-contato-colorida-natural-vision-anual-com-grau-130224", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:56:09.672Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'Lentes de contato coloridas Natural Colors - Kit sem grau', 'lentes-de-contato-coloridas-natural-colors-kit-sem-grau', '129788', '129788', 'mensal', 'hidrogel', 'visao_simples', 127.4, 186.2, 30, 6, NULL, True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-natural-colors-kit-sem-grau-129788", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:56:20.897Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '03c77e05-0dc2-55e3-be9e-b9c3c5b8cdc1', 'Lente de contato Hidroblue Toric', 'lente-de-contato-hidroblue-toric', '71281', '71281', 'mensal', 'hidrogel', 'visao_simples', 220.28, 321.96, 30, 6, 'Compre lentes de contato com grau Hidroblue Toric da Solótica aqui na NewLentes. Compra segura com frete grátis e desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lente-de-contato-hidroblue-toric-71281", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:56:30.321Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'cdadf450-9406-5325-aa8e-c84458e0fc70', 'Lentes de Contato Optogel Op 60', 'lentes-de-contato-optogel-op-60', '71278', '71278', 'mensal', 'hidrogel', 'visao_simples', 142.03, 149.0, 30, 6, 'Compre lentes de contato com grau OP 60 Optolentes aqui na NewLentes. Compra Segura com Frete Grátis para todo Brasil e Desconto no pagamento á vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-optogel-op-60-71278", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:56:39.187Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7cf574e1-e92f-5069-8dd6-3cb97299974f', 'Lentes de contato Natural Vision anual', 'lentes-de-contato-natural-vision-anual', '130207', '130207', 'mensal', 'hidrogel', 'visao_simples', 96.85, 146.3, 30, 6, 'As lentes de contato Natural Vision são para correção de miopia ou hipermetropia. Aproveite nosso frete grátis* para todo Brasil e desconto à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-natural-vision-anual-130207", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:56:47.494Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', NULL, 'Lentes de contato coloridas Natural Look - Sem grau', 'lentes-de-contato-coloridas-natural-look-sem-grau', '129785', '129785', 'mensal', 'hidrogel', 'visao_simples', 121.03, 165.0, 30, 6, 'Lentes de Contato Colorida Natural Look', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-natural-look-sem-grau-129785", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:56:58.365Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7cf574e1-e92f-5069-8dd6-3cb97299974f', 'Lentes de contato coloridas Natural Vision anual - Sem grau', 'lentes-de-contato-coloridas-natural-vision-anual-sem-grau', '130225', '130225', 'mensal', 'hidrogel', 'visao_simples', 129.99, 186.2, 30, 6, 'Mude o visual com as lentes de contato Natural Vision. Compre com frete grátis* para todo Brasil. Aproveite.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-natural-vision-anual-sem-grau-130225", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:58:13.928Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'Lente de contato colorida Hidrocor Tórica', 'lente-de-contato-colorida-hidrocor-torica', '82602', '82602', 'mensal', 'hidrogel', 'visao_simples', 299.0, 437.0, 30, 6, 'Compre lentes de contato colorida Hidrocor Tórica da Solótica aqui na NewLentes, com frete grátis e desconto no pagamento à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lente-de-contato-colorida-hidrocor-torica-82602", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:58:24.965Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'Lente de contato colorida Natural Colors Tórica', 'lente-de-contato-colorida-natural-colors-torica', '82603', '82603', 'mensal', 'hidrogel', 'visao_simples', 390.0, 460.0, 30, 6, 'Lentes de Contato Colorida NATURAL COLORS TÓRICA', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lente-de-contato-colorida-natural-colors-torica-82603", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:58:35.622Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'ecb32bbd-6796-52bb-88e3-3d6ec42c7302', 'Lente de contato colorida Optycolor Magic Top HD', 'lente-de-contato-colorida-optycolor-magic-top-hd', '134173', '134173', 'mensal', 'hidrogel', 'visao_simples', 96.85, 99.0, 30, 6, 'Compre Lente de contato colorida Optycolor Magic Top HD do fabricante Optolentes por apenas R$ 99,00 aqui na Newlentes. Somos revendedor autorizado Optolentes', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lente-de-contato-colorida-optycolor-magic-top-hd-134173", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:58:46.377Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'ecb32bbd-6796-52bb-88e3-3d6ec42c7302', 'Lentes de Contato Coloridas Magic Top - Graus Altos', 'lentes-de-contato-coloridas-magic-top-graus-altos', '130126', '130126', 'mensal', 'hidrogel', 'visao_simples', 370.5, 320.0, 30, 6, 'Compre lentes de contato coloridas Magic Top com graus altos aqui na NewLentes. Aproveite nossa promoção de frete grátis para todo Brasil.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-magic-top-graus-altos-130126", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:58:56.605Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'cdadf450-9406-5325-aa8e-c84458e0fc70', 'Lentes de Contato Optogel Op 42', 'lentes-de-contato-optogel-op-42', '71277', '71277', 'mensal', 'hidrogel', 'visao_simples', 197.18, 266.72, 30, 6, 'Compre lentes de contato com grau OP 42 Optolentes aqui na NewLentes. Compra Segura com Frete Grátis para todo Brasil e Desconto no pagamento á vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-optogel-op-42-71277", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:59:05.987Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'cdadf450-9406-5325-aa8e-c84458e0fc70', 'Lentes de Contato Optogel Op 60 - GRAUS ALTOS', 'lentes-de-contato-optogel-op-60-graus-altos', '130124', '130124', 'mensal', 'hidrogel', 'visao_simples', 370.5, 304.0, 30, 6, 'Compre as lentes de contato OP 60 com graus altos aqui na NewLentes. Parcelamento sem juros ou desconto no pagamento à vista. Confira!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-optogel-op-60-graus-altos-130124", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:59:17.053Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'cdadf450-9406-5325-aa8e-c84458e0fc70', 'Lentes de Contato Optogel Op 42 - GRAUS ALTOS', 'lentes-de-contato-optogel-op-42-graus-altos', '130134', '130134', 'mensal', 'hidrogel', 'visao_simples', 370.5, 304.0, 30, 6, 'Compre as lentes de contato Optogel OP 42 para graus altos aqui na NewLentes com facilidade e segurança. Aproveite nossa promoção de frete grátis*.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-optogel-op-42-graus-altos-130134", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:59:26.350Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '58dacfaf-b712-4fca-b972-0cd5a89008f1', 'Lentes de contato Biosoft Tórica HD', 'lentes-de-contato-biosoft-torica-hd', '135013', '135013', 'mensal', 'hidrogel', 'visao_simples', 284.05, 359.1, 30, 6, 'Compre Lentes de contato Biosoft Tórica HD do fabricante Central Oftálmica por apenas R$ 130,00 aqui na Newlentes. Somos revendedor autorizado Central Oftálmica', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-biosoft-torica-hd-135013", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:59:35.507Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '371c7019-a93d-52f6-8156-28a26cd0f6f7', 'Lentes de contato Ultra para Astigmatismo', 'lentes-de-contato-ultra-para-astigmatismo', '134562', '134562', 'mensal', 'silicone_hidrogel', 'visao_simples', 273.64, 333.67, 30, 6, 'Compre Lentes de contato Ultra para Astigmatismo do fabricante Bausch Lomb por apenas R$ 333,67 aqui na Newlentes. Somos revendedor autorizado Bausch Lomb', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-ultra-para-astigmatismo-134562", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:59:44.791Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'ce8760b2-0bbf-5bdd-9246-f88b502b30c1', 'Lentes de Contato Purevision 2 para Astigmatismo', 'lentes-de-contato-purevision-2-para-astigmatismo', '130320', '130320', 'mensal', 'silicone_hidrogel', 'visao_simples', 251.54, 316.99, 30, 6, 'Compre Lentes de Contato Purevision 2 para Astigmatismo aqui na NewLentes com garantia e segurança. Aproveite nosso frete grátis* e desconto à vista', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-purevision-2-para-astigmatismo-130320", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T15:59:53.565Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '965510a3-b51b-5bc2-b45f-63ad3b8b7bb7', 'Lentes de Contato Solflex Toric', 'lentes-de-contato-solflex-toric', '71319', '71319', 'mensal', 'hidrogel', 'visao_simples', 370.5, 350.0, 30, 6, 'Compre lentes de contato com grau Solflex Tóric Solótica aqui na NewLentes. Compra Segura com Frete Grátis para todo Brasil e Desconto no pagamento à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-solflex-toric-71319", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:00:04.036Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'f83cad32-5932-5c6a-98c9-2830c5ae8b16', 'Lentes de contato Bioview 55 Torica', 'lentes-de-contato-bioview-55-torica', '136721', '136721', 'mensal', 'hidrogel', 'visao_simples', 215.51, 303.36, 30, 6, 'Compre Lentes de contato Bioview 55 Torica do fabricante Central Oftálmica por apenas R$ 290,00 aqui na Newlentes. Somos revendedor autorizado Central Oftálmica', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-bioview-55-torica-136721", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:00:13.599Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '40c1743c-b750-5ca6-a6cb-af5c613f82b0', 'Lentes de contato precision 1 day tórica', 'lentes-de-contato-precision-1-day-torica', '137056', '137056', 'mensal', 'silicone_hidrogel', 'visao_simples', 284.05, 359.1, 30, 6, 'Compre Lentes de contato precision 1 day tórica do fabricante Alcon por apenas R$ 284,21 aqui na Newlentes. Somos revendedor autorizado Alcon', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-precision-1-day-torica-137056", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:00:23.887Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'b1194c29-cb97-5fc2-a5d6-74428c976147', 'Lentes de contato Silidrogel Sihy 45 Tórica', 'lentes-de-contato-silidrogel-sihy-45-torica', '131326', '131326', 'mensal', 'hidrogel', 'visao_simples', 284.05, 378.0, 30, 6, 'Compre Lentes de contato Silidrogel Sihy 45 Tórica do fabricante Central Oftálmica por apenas R$ 378,00 aqui na Newlentes. Somos revendedor autorizado Central Oftálmica', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-silidrogel-sihy-45-torica-131326", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:00:32.622Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'cdadf450-9406-5325-aa8e-c84458e0fc70', 'Lentes de Contato Optogel Tórica', 'lentes-de-contato-optogel-torica', '71276', '71276', 'mensal', 'hidrogel', 'visao_simples', 520.0, 760.0, 30, 6, 'Compre lentes de contato com grau Optogel Toric Optolentes aqui na NewLentes. Compra Segura com Frete Grátis e Desconto no pagamento à vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-optogel-torica-71276", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:00:41.930Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'f83cad32-5932-5c6a-98c9-2830c5ae8b16', 'Lentes de contato Bioview Tórica', 'lentes-de-contato-bioview-torica', '131323', '131323', 'mensal', 'hidrogel', 'visao_simples', 233.42, 331.55, 30, 6, 'Compre as Lentes de contato Bioview Tórica aqui na NewLentes com Frete Grátis e entrega rápida para todo Brasil, aproveite!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-bioview-torica-131323", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:00:51.408Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Lentes de Contato Clariti 1 Day Tórica', 'lentes-de-contato-clariti-1-day-torica', '137556', '137556', 'mensal', 'silicone_hidrogel', 'visao_simples', 284.05, 359.1, 30, 6, 'Compre Lentes de Contato Clariti 1 Day Tórica do fabricante CooperVision por apenas R$ 212,90 aqui na Newlentes. Somos revendedor autorizado CooperVision', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-clariti-1-day-torica-137556", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:01:02.943Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Lentes de Contato Clariti 1 Day Tórica', 'lentes-de-contato-clariti-1-day-torica', '137555', '137555', 'mensal', 'silicone_hidrogel', 'visao_simples', 284.05, 359.1, 30, 6, 'Compre Lentes de Contato Clariti 1 Day Tórica do fabricante CooperVision por apenas R$ 212,90 aqui na Newlentes. Somos revendedor autorizado CooperVision', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-clariti-1-day-torica-137555", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:01:15.025Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'ce8760b2-0bbf-5bdd-9246-f88b502b30c1', 'Lentes de Contato Purevision 2 MultiFocal', 'lentes-de-contato-purevision-2-multifocal', '130321', '130321', 'mensal', 'silicone_hidrogel', 'visao_simples', 273.64, 407.36, 30, 6, 'Compre Lentes de Contato Purevision 2 MultiFocal aqui na NewLentes com garantia e entrega rápida. Aproveite nossa promoção de frete grátis*', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-purevision-2-multifocal-130321", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:01:24.302Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4', 'Lentes de contato Acuvue Oasys Multifocal', 'lentes-de-contato-acuvue-oasys-multifocal', '137015', '137015', 'mensal', 'silicone_hidrogel', 'visao_simples', 239.67, 350.29, 30, 6, 'Compre Lentes de contato Acuvue Oasys Multifocal do fabricante Acuvue por apenas R$ 368,73 aqui na Newlentes. Somos revendedor autorizado Acuvue', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-acuvue-oasys-multifocal-137015", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:01:33.952Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '371c7019-a93d-52f6-8156-28a26cd0f6f7', 'Lentes de contato Ultra Multifocal', 'lentes-de-contato-ultra-multifocal', '134561', '134561', 'mensal', 'silicone_hidrogel', 'visao_simples', 288.05, 420.99, 30, 6, 'Compre Lentes de contato Ultra Multifocal do fabricante Bausch Lomb por apenas R$ 443,15 aqui na Newlentes. Somos revendedor autorizado Bausch Lomb', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-ultra-multifocal-134561", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:01:57.108Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'f83cad32-5932-5c6a-98c9-2830c5ae8b16', 'Lentes de Contato Bioview Multifocal', 'lentes-de-contato-bioview-multifocal', '134278', '134278', 'mensal', 'hidrogel', 'visao_simples', 273.64, 420.0, 30, 6, 'Compre Lentes de Contato Bioview Multifocal do fabricante Central Oftálmica por apenas R$ 349,00 aqui na Newlentes. Somos revendedor autorizado Central Oftálmica', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-bioview-multifocal-134278", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:02:07.435Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7a86c3fe-4a5e-59db-86d3-cd62c10a4e20', 'Lentes de Contato Clariti 1 Day Multifocal 3 ADD', 'lentes-de-contato-clariti-1-day-multifocal-3-add', '137380', '137380', 'mensal', 'silicone_hidrogel', 'visao_simples', 273.64, 420.0, 30, 6, 'Compre Lentes de Contato Clariti 1 Day Multifocal 3 ADD do fabricante CooperVision por apenas R$ 257,89 aqui na Newlentes. Somos revendedor autorizado CooperVision', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-clariti-1-day-multifocal-3-add-137380", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:02:18.468Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '7cf574e1-e92f-5069-8dd6-3cb97299974f', 'Lentes de Contato Coloridas Natural Vision Mensal - Com Grau', 'lentes-de-contato-coloridas-natural-vision-mensal-com-grau', '130226', '130226', 'mensal', 'hidrogel', 'visao_simples', 96.85, 146.3, 30, 6, 'Mude a cor dos olhos com as lentes coloridas Natural Vision. São mais de 15 cores disponíveis e você ainda ganha frete grátis*. Aproveite!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-coloridas-natural-vision-mensal-com-grau-130226", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:02:28.050Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'Lentes de Contato Colorida Solflex Natural Colors - COM GRAU', 'lentes-de-contato-colorida-solflex-natural-colors-com-grau', '71314', '71314', 'mensal', 'hidrogel', 'visao_simples', 284.05, 186.2, 30, 6, 'Lentes de Contato Colorida Solflex Natural Colors', True, True, '{"url_original": "https://www.newlentes.com.br/produto/lentes-de-contato-colorida-solflex-natural-colors-com-grau-71314", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:02:38.497Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'Lentes de Contato Colorida Natural Colors - COM GRAU', 'lentes-de-contato-colorida-natural-colors-com-grau', '71324', '71324', 'mensal', 'hidrogel', 'visao_simples', 96.85, 97.0, 30, 6, 'Compre lentes de contato colorida Natural Colors da Solótica aqui na NewLentes. São diversas cores e você ainda ganha frete grátis* para todo Brasil.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/Lentes-de-Contato-Natural-Colors-71324", "categorias_originais": "Lentes de contato", "scraping_at": "2026-01-28T16:03:07.406Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', NULL, 'Renu Fresh 475 ml - Solução para lentes de contato', 'renu-fresh-475-ml-solucao-para-lentes-de-contato', '82579', '82579', 'mensal', 'hidrogel', 'visao_simples', 96.85, 79.8, 30, 6, 'Compre solução para Lentes de Contato Renu Fresh 475ml aqui na NewLentes. Compra Segura com Frete Grátis e Desconto no pagamento á vista.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/renu-fresh-475-ml-solucao-para-lentes-de-contato-82579", "categorias_originais": "Solução para lentes de contato", "scraping_at": "2026-01-28T16:03:24.558Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', '0ae666e8-464c-56cd-bf6c-03cb002dd5b7', 'Biotrue 420 ml - Solução para lentes de contato', 'biotrue-420-ml-solucao-para-lentes-de-contato', '129987', '129987', 'mensal', 'silicone_hidrogel', 'visao_simples', 206.04, 299.99, 30, 6, 'Solução para lentes de contato Biotrue da Bausch Lomb com ótimos preços e as melhores condições. Aproveite!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/biotrue-420-ml-solucao-para-lentes-de-contato-129987", "categorias_originais": "Solução para lentes de contato", "scraping_at": "2026-01-28T16:03:33.746Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', NULL, 'Renu Fresh 120 ml - Solução para lentes de contato', 'renu-fresh-120-ml-solucao-para-lentes-de-contato', '129984', '129984', 'mensal', 'hidrogel', 'visao_simples', 206.04, 299.99, 30, 6, 'Na NewLentes você encontra solução para lentes de contato Renu de diversos tamanhos, com ótimo preço e as melhores condições. Aproveite!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/renu-fresh-120-ml-solucao-para-lentes-de-contato-129984", "categorias_originais": "Solução para lentes de contato", "scraping_at": "2026-01-28T16:03:42.508Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', NULL, 'Renu Fresh 60 ml - Solução para lentes de contato', 'renu-fresh-60-ml-solucao-para-lentes-de-contato', '129982', '129982', 'mensal', 'hidrogel', 'visao_simples', 175.04, 149.0, 30, 6, 'Compre Renu Fresh 60 ml - Solução para lentes de contato do fabricante Bausch Lomb por apenas R$ 27,00 aqui na Newlentes. Somos revendedor autorizado Bausch Lomb', True, True, '{"url_original": "https://www.newlentes.com.br/produto/renu-fresh-60-ml-solucao-para-lentes-de-contato-129982", "categorias_originais": "Solução para lentes de contato", "scraping_at": "2026-01-28T16:03:56.087Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', NULL, 'Renu gotas umidificantes 15 ml', 'renu-gotas-umidificantes-15-ml', '129981', '129981', 'mensal', 'hidrogel', 'visao_simples', 96.85, 55.1, 30, 6, 'Aproveite Renu Plus Gotas Umidificantes de 15ml com ótimo preço. E confira mais itens de cuidado com os olhos aqui na NewLentes.', True, True, '{"url_original": "https://www.newlentes.com.br/produto/renu-gotas-umidificantes-15-ml-129981", "categorias_originais": "Solução para lentes de contato", "scraping_at": "2026-01-28T16:04:05.010Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('4f4dc190-4e26-4352-a7e9-a748880d9365', NULL, 'Renu Advanced 475 ml - Solução multiuso para lentes de contato', 'renu-advanced-475-ml-solucao-multiuso-para-lentes-de-contato', '134142', '134142', 'mensal', 'hidrogel', 'visao_simples', 194.99, 269.29, 30, 6, 'Compre solução multiuso para lentes de contato aqui na NewLentes com praticidade e segurança. Aproveite nossas ofertas!', True, True, '{"url_original": "https://www.newlentes.com.br/produto/renu-advanced-475-ml-solucao-multiuso-para-lentes-de-contato-134142", "categorias_originais": "Solução para lentes de contato", "scraping_at": "2026-01-28T16:04:14.222Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Ocre', 'natural-colors-ocre', 'natural-colors-ocre', 'natural-colors-ocre', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.196Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Mel', 'natural-colors-mel', 'natural-colors-mel', 'natural-colors-mel', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.196Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Avelã', 'natural-colors-avela', 'natural-colors-avelã', 'natural-colors-avelã', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.196Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Âmbar', 'natural-colors-ambar', 'natural-colors-âmbar', 'natural-colors-âmbar', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.196Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Quartzo', 'natural-colors-quartzo', 'natural-colors-quartzo', 'natural-colors-quartzo', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.197Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Ice', 'natural-colors-ice', 'natural-colors-ice', 'natural-colors-ice', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.197Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Cristal', 'natural-colors-cristal', 'natural-colors-cristal', 'natural-colors-cristal', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.197Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Grafite', 'natural-colors-grafite', 'natural-colors-grafite', 'natural-colors-grafite', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.197Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Topázio', 'natural-colors-topazio', 'natural-colors-topázio', 'natural-colors-topázio', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.197Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Búzios', 'natural-colors-buzios', 'natural-colors-búzios', 'natural-colors-búzios', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.197Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Cielo', 'natural-colors-cielo', 'natural-colors-cielo', 'natural-colors-cielo', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.197Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Ipanema', 'natural-colors-ipanema', 'natural-colors-ipanema', 'natural-colors-ipanema', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.197Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Jade', 'natural-colors-jade', 'natural-colors-jade', 'natural-colors-jade', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.197Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Safira', 'natural-colors-safira', 'natural-colors-safira', 'natural-colors-safira', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.197Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'NATURAL COLORS - Ágata', 'natural-colors-agata', 'natural-colors-ágata', 'natural-colors-ágata', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes coloridas Natural Colors são lentes de acabamento primoroso e efeito altamente natural. Com suas 15 cores suaves e delicado aro ao redor da área externa da íris, Natural Colors é a lente que oferece beleza e ampla opção de graus, além de lentes tóricas fabricadas sob encomenda para o paciente, disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Ipanema; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:30.197Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Ambar', 'hidrocor-ambar', 'hidrocor-ambar', 'hidrocor-ambar', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Avelã', 'hidrocor-avela', 'hidrocor-avelã', 'hidrocor-avelã', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Cristal', 'hidrocor-cristal', 'hidrocor-cristal', 'hidrocor-cristal', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Grafite', 'hidrocor-grafite', 'hidrocor-grafite', 'hidrocor-grafite', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Mel', 'hidrocor-mel', 'hidrocor-mel', 'hidrocor-mel', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Ocre', 'hidrocor-ocre', 'hidrocor-ocre', 'hidrocor-ocre', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Quartzo', 'hidrocor-quartzo', 'hidrocor-quartzo', 'hidrocor-quartzo', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Topázio', 'hidrocor-topazio', 'hidrocor-topázio', 'hidrocor-topázio', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Ice', 'hidrocor-ice', 'hidrocor-ice', 'hidrocor-ice', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Safira', 'hidrocor-safira', 'hidrocor-safira', 'hidrocor-safira', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Aquamarine', 'hidrocor-aquamarine', 'hidrocor-aquamarine', 'hidrocor-aquamarine', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Jade', 'hidrocor-jade', 'hidrocor-jade', 'hidrocor-jade', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Copacabana', 'hidrocor-copacabana', 'hidrocor-copacabana', 'hidrocor-copacabana', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Parati', 'hidrocor-parati', 'hidrocor-parati', 'hidrocor-parati', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Ipanema', 'hidrocor-ipanema', 'hidrocor-ipanema', 'hidrocor-ipanema', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Búzios', 'hidrocor-buzios', 'hidrocor-búzios', 'hidrocor-búzios', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Ágata', 'hidrocor-agata', 'hidrocor-ágata', 'hidrocor-ágata', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR - Cielo', 'hidrocor-cielo', 'hidrocor-cielo', 'hidrocor-cielo', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Hidrocor apresentam cores muito suaves e que se mesclam com a cor natural dos olhos, causando efeitos impressionantes.Muitas opções de cores e graus, além da opção de lentes tóricas, para atender pacientes que necessitam correção visual Lentes disponíveis nestas cores: Mel; Ocre; Grafite; Ice; Topázio; Aquamarine; Quartzo; Cristal; Âmbar; Avelã; Jade; Safira; Búzios; Copacabana; Ipanema; Parati; Cielo; Ágata. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:33.722Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR MENSAL - Âmbar', 'hidrocor-mensal-ambar', 'hidrocor-mensal-âmbar', 'hidrocor-mensal-âmbar', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Hidrocor Mensal é a nova geração das lentes Hidrocor, agora disponíveis em troca mensal: Âmbar; Cristal; Ocre; Quartzo; Topázio. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor-mensal/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:36.718Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR MENSAL - Cristal', 'hidrocor-mensal-cristal', 'hidrocor-mensal-cristal', 'hidrocor-mensal-cristal', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Hidrocor Mensal é a nova geração das lentes Hidrocor, agora disponíveis em troca mensal: Âmbar; Cristal; Ocre; Quartzo; Topázio. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor-mensal/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:36.718Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR MENSAL - Ocre', 'hidrocor-mensal-ocre', 'hidrocor-mensal-ocre', 'hidrocor-mensal-ocre', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Hidrocor Mensal é a nova geração das lentes Hidrocor, agora disponíveis em troca mensal: Âmbar; Cristal; Ocre; Quartzo; Topázio. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor-mensal/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:36.718Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR MENSAL - Quartzo', 'hidrocor-mensal-quartzo', 'hidrocor-mensal-quartzo', 'hidrocor-mensal-quartzo', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Hidrocor Mensal é a nova geração das lentes Hidrocor, agora disponíveis em troca mensal: Âmbar; Cristal; Ocre; Quartzo; Topázio. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor-mensal/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:36.719Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'a16aa23b-815c-421c-96e6-c652fc239d94', 'HIDROCOR MENSAL - Topázio', 'hidrocor-mensal-topazio', 'hidrocor-mensal-topázio', 'hidrocor-mensal-topázio', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Hidrocor Mensal é a nova geração das lentes Hidrocor, agora disponíveis em troca mensal: Âmbar; Cristal; Ocre; Quartzo; Topázio. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrocor-mensal/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:36.719Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'SOLFLEX NATURAL COLORS - Mel', 'solflex-natural-colors-mel', 'solflex-natural-colors-mel', 'solflex-natural-colors-mel', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lentes coloridas mensais (troca programada) em sete cores fantásticas: Mel; Ocre; Quartzo; Esmeralda; Cristal; Topázio; Verde. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/solflex-natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:39.901Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'SOLFLEX NATURAL COLORS - Esmeralda', 'solflex-natural-colors-esmeralda', 'solflex-natural-colors-esmeralda', 'solflex-natural-colors-esmeralda', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lentes coloridas mensais (troca programada) em sete cores fantásticas: Mel; Ocre; Quartzo; Esmeralda; Cristal; Topázio; Verde. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/solflex-natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:39.901Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'SOLFLEX NATURAL COLORS - Topázio', 'solflex-natural-colors-topazio', 'solflex-natural-colors-topázio', 'solflex-natural-colors-topázio', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lentes coloridas mensais (troca programada) em sete cores fantásticas: Mel; Ocre; Quartzo; Esmeralda; Cristal; Topázio; Verde. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/solflex-natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:39.901Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'SOLFLEX NATURAL COLORS - Verde', 'solflex-natural-colors-verde', 'solflex-natural-colors-verde', 'solflex-natural-colors-verde', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lentes coloridas mensais (troca programada) em sete cores fantásticas: Mel; Ocre; Quartzo; Esmeralda; Cristal; Topázio; Verde. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/solflex-natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:39.901Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'SOLFLEX NATURAL COLORS - Cristal', 'solflex-natural-colors-cristal', 'solflex-natural-colors-cristal', 'solflex-natural-colors-cristal', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lentes coloridas mensais (troca programada) em sete cores fantásticas: Mel; Ocre; Quartzo; Esmeralda; Cristal; Topázio; Verde. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/solflex-natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:39.901Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'SOLFLEX NATURAL COLORS - Ocre', 'solflex-natural-colors-ocre', 'solflex-natural-colors-ocre', 'solflex-natural-colors-ocre', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lentes coloridas mensais (troca programada) em sete cores fantásticas: Mel; Ocre; Quartzo; Esmeralda; Cristal; Topázio; Verde. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/solflex-natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:39.901Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'd7869a46-4b3e-599b-b89b-7a4adfde54ea', 'SOLFLEX NATURAL COLORS - Quartzo', 'solflex-natural-colors-quartzo', 'solflex-natural-colors-quartzo', 'solflex-natural-colors-quartzo', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lentes coloridas mensais (troca programada) em sete cores fantásticas: Mel; Ocre; Quartzo; Esmeralda; Cristal; Topázio; Verde. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/solflex-natural-colors/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:39.901Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', '965510a3-b51b-5bc2-b45f-63ad3b8b7bb7', 'SOLFLEX COLOR HYPE', 'solflex-color-hype', 'solflex-color-hype', 'solflex-color-hype', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lentes de troca programada em cores impactantes para efeitos teatrais e ocasiões especiais. Disponível nas cores amarela, branca e vermelha. As imagens do teste virtual são meramente ilustrativas - as cores podem variar de acordo com a cor original da íris do usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/solflex-color-hype/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:42.986Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'BEST FIT FULL', 'best-fit-full', 'best-fit-full', 'best-fit-full', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Materiais • Optimum Extra (DK FATT 100) • Boston XO™ (DK FATT 100) Graus -25,00 a +25,00D Diâmetro 9,2 a 10,6mm K 37,50 a 50,50', True, True, '{"url_original": "https://solotica.com.br/produto/best-fit-full/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:46.225Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'BEST FIT', 'best-fit', 'asferica-best-fit', 'asferica-best-fit', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lente de contato rígida com desenho multicurva, que proporciona maior estabilidade em córneas irregulares, em função do desenho da lente acompanhar a anatomia da córnea. Desenho personalizado, onde a face posterior da lente é desenvolvida com anatomia multicurva, e a face anterior da lente com desenho cilíndrico. Indicada para portadores de astigmatismo residual, permitindo assim melhor acuidade visual ao usuário. Desenho personalizado cuja face posterior da lente é desenvolvida com duas curvaturas asféricas, projetadas para equilibrar a diferença dos meridianos da córnea. Indicada para portadores de alto Astigmatismo corneano, não adaptados com lentes esféricas.', True, True, '{"url_original": "https://solotica.com.br/produto/asferica-best-fit/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:49.419Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'BEST FIT K', 'best-fit-k', 'best-fit-k', 'best-fit-k', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Nova opção para adaptação de lentes de contato em pacientes com ectasias corneanas como Ceratocone (desde os iniciais até os mais avançados), ectasia pós LASIK, etc. A Best Fit K proporciona um padrão excelente de adaptação, com livramento do ápice do cone, apoio da lente na média periferia e ótimo levantamento de borda.', True, True, '{"url_original": "https://solotica.com.br/produto/best-fit-k/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:52.453Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'BEST FIT K MAX', 'best-fit-k-max', 'best-fit-k-max', 'best-fit-k-max', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Best Fit K Max são um avanço no desenho, já consagrado, das lentes asféricas da Solótica e trazem novas características que apresentam desempenho ainda melhor na correção da visão de pacientes portadores de ceratocone, desde a fase inicial até a fase mais severa da doença.', True, True, '{"url_original": "https://solotica.com.br/produto/best-fit-k-max/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:55.532Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'BEST FIT K MAX TÓRICA', 'best-fit-k-max-torica', 'best-fit-k-max-torica', 'best-fit-k-max-torica', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'A lente Best Fit K Max Tórica foi concebida para pacientes com ectasia que apresentem astigmatismo corneano elevado. Seu desenho totalmente tórico possibilita um encaixe de melhor qualidade nessas córneas, proporcionando uma excelente adaptação, com conforto e estabilidade.', True, True, '{"url_original": "https://solotica.com.br/produto/best-fit-k-max-torica/", "categorias_originais": "", "scraping_at": "2026-01-30T20:00:58.440Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'BEST FIT SMART LENS', 'best-fit-smart-lens', 'best-fit-smart-lens', 'best-fit-smart-lens', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Best Fit Smart Lens foram desenvolvidas para atender casos especiais de pacientes com córneas oblatas, oblatas com elevado astigmatismo e córneas irregulares com curvaturas baixas. Best Fit Smart Lens M (BFM) – Curva Reversa São projetadas com suave curva reversa proporcionando centralização, conforto e melhor troca lacrimal para córneas com centro oblato por tratamento miópico ou outra causa. Best Fit Smart Lens X (BFX) – Curva Reversa Tórica São projetadas com duas curvas reversas e uma curva intermediária asférica, para uma suave adaptação em córneas ablatas e com astigmatismo elevado, como é frequente no pós- transplante, principalmente após ectasias. Outras indicações são degeneração marginal pelúcida, pós anel em cones centrais, após hidrópsia e outras situações que a córnea se apresente com esta configuração. Best Fit Smart Lens H (BFH) – Ectasias com baixa curvatura​ Estas lentes foram projetadas para olhos com córneas de configuração prolada, porém com curvaturas', True, True, '{"url_original": "https://solotica.com.br/produto/best-fit-smart-lens/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:02.009Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'ESFÉRICA', 'esferica', 'esferica-2', 'esferica-2', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Possui desenho com anatomia monocurva, com o diferencial do acabamento de bordo multicurva. Indicada para a correçăo de miopia e hipermetropia, combinadas ou năo com astigmatismos relativos (até -3,00 Rx / 3,00 córnea)', True, True, '{"url_original": "https://solotica.com.br/produto/esferica-2/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:05.025Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'SOPER', 'soper', 'soper', 'soper', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Possui desenho com anatomia bicurva, indicada aos portadores de Ceratocone central. O desenho oferece uma curva constante e a outra variável, de acordo com o ápice do cone, proporcionando maior resultado na adaptação.', True, True, '{"url_original": "https://solotica.com.br/produto/soper/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:08.109Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'TÓRICA FACE ANTERIOR', 'torica-face-anterior', 'torica-de-face-anterior', 'torica-de-face-anterior', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Especialmente desenvolvida para portadores de Astigmatismo residual, permitindo assim melhor acuidade visual ao usuário.', True, True, '{"url_original": "https://solotica.com.br/produto/torica-de-face-anterior/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:11.364Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'TÓRICA FACE POSTERIOR', 'torica-face-posterior', 'torica-de-face-posterior', 'torica-de-face-posterior', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Desenho personalizado onde a face posterior da lente é desenvolvida de acordo com a irregularidade da córnea provocada por alto astigmatismo corneano. Indicada para portadores de astigmatismo corneano maiores que 3,00 (córnea irregular).', True, True, '{"url_original": "https://solotica.com.br/produto/torica-de-face-posterior/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:14.682Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'EXPERT PROGRESSIVE', 'expert-progressive', 'expert-progressive', 'expert-progressive', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'As lentes Solótica Expert Progressive são indicadas para correção da visão em pacientes com córneas regulares: présbitas, emétropes, astigmatas (na regra), hipermetropes e míopes. Desempenho Visual Inigualável O corredor progressivo proporciona visão excelente em longas, médias e curtas distâncias com transição suave e sem sobreposição de imagem.', True, True, '{"url_original": "https://solotica.com.br/produto/expert-progressive/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:18.217Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'ZENLENS', 'zenlens', 'zenlens', 'zenlens', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Apresentamos a mais nova lente de contato especial fabricada pela Solótica: ZENLENS™, uma lente mini-escleral com livramento total da córnea, desenvolvida pela Alden Optical nos Estados Unidos e desenhada em conjunto com Jason Jedlicka, a ZENLENS permite adaptação em uma ampla gama de formatos e tamanhos de córnea utilizando um único conjunto de lentes de teste e uma única filosofia de adaptação.', True, True, '{"url_original": "https://solotica.com.br/produto/zenlens/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:21.421Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'ZEN RC', 'zen-rc', 'zenrc', 'zenrc', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Desenhada especialmente para a córnea normal que não necessita de diâmetro e curvatura maiores, Zen™ RC possui diâmetro reduzido, facilitando a inserção e remoção para o paciente. Embora a lente escleral Zen™ RC possa ser personalizada com relação a qualquer parâmetro, a adaptação com parâmetros padrão quase sempre é adequada à grande maioria dos pacientes. Curvas periféricas tóricas, com espessura central personalizada, perfis de controle de flexão e lentes tóricas frontais podem também ser encomendadas, se necessário. A lente também conta, agora, com apoio tórico, trazendo mais um parâmetro para uma excelente adaptação da lente.', True, True, '{"url_original": "https://solotica.com.br/produto/zenrc/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:24.462Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', '03c77e05-0dc2-55e3-be9e-b9c3c5b8cdc1', 'HIDROBLUE K (CERATOGEL) TORIC', 'hidroblue-k-ceratogel-toric', 'hidroblue-k-torica', 'hidroblue-k-torica', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Desenvolvidas para atender casos de ceratocone com astigmatismo residual ou corneano não corrigidos com lentes esféricas. Trata-se de opção diferenciada para pacientes portadores de ceratocone, principalmente para aqueles com intolerância aos materiais das lentes RGP.', True, True, '{"url_original": "https://solotica.com.br/produto/hidroblue-k-torica/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:27.802Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', '03c77e05-0dc2-55e3-be9e-b9c3c5b8cdc1', 'HIDROBLUE K (CERATOGEL)', 'hidroblue-k-ceratogel', 'hidroblue-k', 'hidroblue-k', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lente de contato gelatinosa, com filtro UV e alto grau de hidratação, especialmente desenvolvida para atender aos usuários portadores de Ceratocone central, sobretudo, aqueles com intolerância às Lentes de Contato Rígidas Gás Permeáveis.', True, True, '{"url_original": "https://solotica.com.br/produto/hidroblue-k/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:31.095Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', '03c77e05-0dc2-55e3-be9e-b9c3c5b8cdc1', 'HIDROBLUE UV AFACIA PEDIÁTRICA', 'hidroblue-uv-afacia-pediatrica', 'hidroblue-uv-afacia-pediatrica', 'hidroblue-uv-afacia-pediatrica', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lente de contato gelatinosa especial, com filtro UV e alto grau de hidratação, desenvolvida para auxiliar no tratamento de bebês e crianças portadoras de Catarata Congênita, e adultos portadores de Microcornea (Microftalmia).', True, True, '{"url_original": "https://solotica.com.br/produto/hidroblue-uv-afacia-pediatrica/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:34.290Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', '03c77e05-0dc2-55e3-be9e-b9c3c5b8cdc1', 'HIDROBLUE UV ESFÉRICA', 'hidroblue-uv-esferica', 'hidroblue-uv-esferica', 'hidroblue-uv-esferica', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lente de contato gelatinosa, com filtro UV e alto grau de hidratação, ideal para usuários com Miopia, Hipermetropia, Baixo Astigmatismo (equivalente esférico) e Presbiopia (monovisão).', True, True, '{"url_original": "https://solotica.com.br/produto/hidroblue-uv-esferica/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:37.226Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', '03c77e05-0dc2-55e3-be9e-b9c3c5b8cdc1', 'HIDROBLUE UV TORIC', 'hidroblue-uv-toric', 'hidroblue-uv-torica', 'hidroblue-uv-torica', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lente de contato gelatinosa, com filtro UV e alto grau de hidratação, indicada aos usuários portadores de Astigmatismo, associado ou não à Miopia ou Hipermetropia.', True, True, '{"url_original": "https://solotica.com.br/produto/hidroblue-uv-torica/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:40.380Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', 'f5441db3-c98a-585a-8299-07c7bdd17a6a', 'HIDROSOFT', 'hidrosoft', 'hidrosoft', 'hidrosoft', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lente de contato gelatinosa, de fácil manuseio, indicada nas correções de Miopia, Hipermetropia, Baixo Astigmatismo (equivalente esférico) e Presbiopia (monovisão), com excelente relação custo x benefício.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrosoft/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:43.377Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'HIDROSOL', 'hidrosol', 'hidrosol', 'hidrosol', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lente de contato corretiva gelatinosa, com grande versatilidade de curvas e diâmetros, o que assegura o sucesso de adaptação a praticamente 100% dos usuários. É indicada nas correções de Miopia, Hipermetropia, Baixo Astigmatismo (equivalente esféricos) e Presbiopia (monovisão). A opção com menor diâmetro é indicada para usuários com pequenas fendas palpebrais e pequenos diâmetros de córnea (crianças).', True, True, '{"url_original": "https://solotica.com.br/produto/hidrosol/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:46.415Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', NULL, 'HIDROSOL FILTRANTE', 'hidrosol-filtrante', 'hidrosol-filtrante', 'hidrosol-filtrante', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Portadores de leucoma, associado ou não à miopia, hipermetropia e/ou baixo astigmatismo, aniridia parcial, miose unilateral, halo senil, etc. Íris: azul, verde, marrom e transparente Tonalidade da Íris: clara, média e escura Pupila: preta e transparente Portadores de Daltonismo relativo, associado ou não a miopia, hipermetropia e/ou astigmatismo. Nas cores vermelha, amarela e laranja. Portadores de Fotofobia, associada ou não à miopia, hipermetropia e/ou baixo astigmatismo, casos de albinismo ou baixo índice de melanina. Nas cores azul, verde e marrom, que filtram os raios luminosos, minimizando a sensibilidade à luz.', True, True, '{"url_original": "https://solotica.com.br/produto/hidrosol-filtrante/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:49.750Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', '965510a3-b51b-5bc2-b45f-63ad3b8b7bb7', 'SOLFLEX CL', 'solflex-cl', 'solflex-cl', 'solflex-cl', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lente de contato gelatinosa de descarte mensal, com proteção contra os raios UVA e UVB, indicada nas correções de Miopia e Hipermetropia. Excelente opção para usuários que buscam correção visual sem deixar de lado o conforto e a praticidade.', True, True, '{"url_original": "https://solotica.com.br/produto/solflex-cl/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:53.068Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;
INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ('189e3428-1b20-4246-86d3-25501e51147a', '965510a3-b51b-5bc2-b45f-63ad3b8b7bb7', 'SOLFLEX TORIC', 'solflex-toric', 'solflex-toric', 'solflex-toric', 'mensal', 'hidrogel', 'visao_simples', 0.0, 0.0, 30, 6, 'Lente de contato gelatinosa de descarte mensal, com proteção contra os raios UVA e UVB, indicada na correção de Astigmatismo associado ou não à Miopia e Hipermetropia. Excelente opção para usuários que buscam correção visual sem deixar de lado conforto e praticidade.', True, True, '{"url_original": "https://solotica.com.br/produto/solflex-toric/", "categorias_originais": "", "scraping_at": "2026-01-30T20:01:56.165Z"}') 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;

COMMIT;
