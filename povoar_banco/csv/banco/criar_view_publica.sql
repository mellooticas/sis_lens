-- ============================================================================
-- VIEW PÚBLICA PARA O FRONTEND (LENTES DE CONTATO)
-- ============================================================================
-- Objetivo: Expor os dados do schema contact_lens para o frontend
-- Data: 30/01/2026
-- ============================================================================

DROP VIEW IF EXISTS public.v_lentes_contato CASCADE;

CREATE OR REPLACE VIEW public.v_lentes_contato AS
SELECT 
    l.id,
    l.nome_produto,
    l.slug,
    l.sku,
    
    -- IDs de relacionamento
    l.marca_id,
    l.fornecedor_id,

    -- Nomes amigáveis (Joins)
    m.nome as marca_nome,
    m.fabricante as fabricante_nome, -- O nome textual que está na tabela marcas
    forn.nome as fornecedor_nome,    -- Quem vende (Distribuidor/Laboratório)

    -- Classificação
    l.tipo_lente,   -- diaria, quinzenal, etc
    l.material,     -- hidrogel, silicone_hidrogel
    l.finalidade,   -- visao_simples, torica, etc

    -- Especificações Técnicas
    l.diametro,
    l.curva_base,
    l.dk_t,
    l.conteudo_agua,

    -- Grade (Ranges)
    l.esferico_min,
    l.esferico_max,
    l.cilindrico_min,
    l.cilindrico_max,
    l.adicao_min,
    l.adicao_max,

    -- Comercial
    l.preco_tabela,        -- Preço de Venda
    l.preco_custo,         -- Preço de Custo
    l.unidades_por_caixa,
    l.dias_uso,            -- Ex: 30 para mensal
    l.disponivel,
    
    -- Cálculos (On-the-fly)
    CASE 
        WHEN l.preco_custo > 0 THEN ((l.preco_tabela - l.preco_custo) / l.preco_custo) * 100 
        ELSE 0 
    END as margem_lucro,
    
    -- Descrição/Metadata
    l.descricao_curta,
    l.metadata,
    
    -- Controle
    l.created_at,
    l.updated_at

FROM contact_lens.lentes l
LEFT JOIN contact_lens.marcas m ON l.marca_id = m.id
LEFT JOIN core.fornecedores forn ON l.fornecedor_id = forn.id
WHERE l.ativo = true;

-- Permissões (Garantir que o usuario anon/authenticated possa ler se necessário)
GRANT SELECT ON public.v_lentes_contato TO authenticated;
GRANT SELECT ON public.v_lentes_contato TO service_role;
