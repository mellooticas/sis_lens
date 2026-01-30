-- 20260130_create_update_rpcs.sql

-- 1. RPC para atualizar Lentes Oftálmicas (lens_catalog.lentes)
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

-- 2. RPC para atualizar Lentes de Contato (contact_lens.lentes)
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
