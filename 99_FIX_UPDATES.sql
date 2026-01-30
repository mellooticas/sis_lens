-- 99_FIX_UPDATES.sql (Consolidated Fix)

-- 1. Ensure RPCs exist and are correct
CREATE OR REPLACE FUNCTION public.update_lente_catalog(
    p_id uuid,
    p_preco_custo numeric,
    p_preco_venda numeric,
    p_ativo boolean
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE lens_catalog.lentes
    SET 
        custo_base = p_preco_custo,
        preco_tabela = p_preco_venda,
        ativo = p_ativo,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_lente_catalog(uuid, numeric, numeric, boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_lente_catalog(uuid, numeric, numeric, boolean) TO anon; -- Allow anon for testing if needed

CREATE OR REPLACE FUNCTION public.update_lente_contact(
    p_id uuid,
    p_preco_custo numeric,
    p_preco_tabela numeric,
    p_ativo boolean
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE contact_lens.lentes
    SET 
        preco_custo = p_preco_custo,
        preco_tabela = p_preco_tabela,
        ativo = p_ativo,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_lente_contact(uuid, numeric, numeric, boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_lente_contact(uuid, numeric, numeric, boolean) TO anon; -- Allow anon for testing

-- 2. Update View v_lentes_contato to include 'ativo'
DROP VIEW IF EXISTS public.v_lentes_contato CASCADE;

CREATE OR REPLACE VIEW public.v_lentes_contato AS
SELECT 
    l.id,
    l.nome_produto,
    l.slug,
    l.sku,
    l.marca_id,
    l.fornecedor_id,
    m.nome as marca_nome,
    m.fabricante as fabricante_nome,
    forn.nome as fornecedor_nome,
    l.tipo_lente,
    l.material,
    l.finalidade,
    l.diametro,
    l.curva_base,
    l.dk_t,
    l.conteudo_agua,
    l.esferico_min,
    l.esferico_max,
    l.cilindrico_min,
    l.cilindrico_max,
    l.adicao_min,
    l.adicao_max,
    l.preco_tabela,
    l.preco_custo,
    l.unidades_por_caixa,
    l.dias_uso,
    l.disponivel,
    l.ativo, -- Ensure ATIVO is here
    CASE 
        WHEN l.preco_custo > 0 THEN ((l.preco_tabela - l.preco_custo) / l.preco_custo) * 100 
        ELSE 0 
    END as margem_lucro,
    l.descricao_curta,
    l.metadata,
    l.created_at,
    l.updated_at
FROM contact_lens.lentes l
LEFT JOIN contact_lens.marcas m ON l.marca_id = m.id
LEFT JOIN core.fornecedores forn ON l.fornecedor_id = forn.id; -- REMOVED 'WHERE l.ativo = true' to allow editing inactive lenses in admin view

-- 3. Fix Permissions
GRANT SELECT ON public.v_lentes_contato TO authenticated;
GRANT SELECT ON public.v_lentes_contato TO service_role;
GRANT SELECT ON public.v_lentes_contato TO anon; -- Allow anon for frontend public catalog

-- 4. Ensure v_lentes (ophthalmic) also allows inactive if editing is needed
-- (Not changing v_lentes generic view, but note users might lose visibility if they deactivate)
