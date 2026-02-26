-- ══════════════════════════════════════════════════════════════════════════════
-- Migration 278 — RPCs do Canonical Engine v2
-- Banco: mhgbuplnxtfgipbemchb (banco_novo)
-- Data: 2026-02-26
--
-- Cria:
--   1. public.rpc_canonical_for_prescription  — busca conceitos por receita
--   2. public.rpc_canonical_detail            — lentes reais de um conceito
--
-- Estrutura confirmada:
--   canonical_lens_mappings.canonical_lens_id  (FK, não canonical_id)
--   canonical_lens_mappings.tenant_id          (mappings são por tenant)
--   canonical_lens_mappings.deleted_at         (soft delete)
--   lenses.lens_name                           (não .name)
--   lenses.tenant_id
--   brands.name                                (global, sem tenant_id)
--   suppliers_labs.name + .tenant_id
--   pricing_book: sell_price, cost_price, final_price, tenant_id, lens_id
-- ══════════════════════════════════════════════════════════════════════════════


-- ─────────────────────────────────────────────────────────────────────────────
-- 1. rpc_canonical_for_prescription
--    Busca conceitos canônicos Standard ou Premium que cobrem uma receita.
--    LEFT JOIN com pricing_book → retorna conceitos mesmo sem preço cadastrado.
--    Tenant-isolated: apenas lentes e preços do tenant logado.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.rpc_canonical_for_prescription(
    p_spherical    NUMERIC,
    p_cylindrical  NUMERIC  DEFAULT NULL,
    p_addition     NUMERIC  DEFAULT NULL,
    p_lens_type    TEXT     DEFAULT NULL,
    p_is_premium   BOOLEAN  DEFAULT FALSE,
    p_limit        INTEGER  DEFAULT 20
)
RETURNS TABLE (
    id                UUID,
    sku               TEXT,
    canonical_name    TEXT,
    lens_type         TEXT,
    material_class    TEXT,
    refractive_index  NUMERIC,
    material_display  TEXT,
    treatment_codes   TEXT[],
    spherical_min     NUMERIC,
    spherical_max     NUMERIC,
    cylindrical_min   NUMERIC,
    cylindrical_max   NUMERIC,
    addition_min      NUMERIC,
    addition_max      NUMERIC,
    tenant_lens_count BIGINT,
    price_min         NUMERIC,
    price_max         NUMERIC,
    price_avg         NUMERIC,
    cost_min          NUMERIC,
    cost_max          NUMERIC,
    markup_min        NUMERIC,
    markup_max        NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, catalog_lenses
AS $$
DECLARE
    v_tenant UUID;
BEGIN
    v_tenant := require_tenant_id();

    -- ── PREMIUM ──────────────────────────────────────────────────────────────
    IF p_is_premium THEN
        RETURN QUERY
        SELECT
            cl.id,
            cl.sku,
            cl.canonical_name,
            cl.lens_type::TEXT,
            clmat.material_class,
            clmat.refractive_index,
            clmat.display_name                                                    AS material_display,
            cl.treatment_codes,
            cl.spherical_min,
            cl.spherical_max,
            cl.cylindrical_min,
            cl.cylindrical_max,
            cl.addition_min,
            cl.addition_max,
            COUNT(DISTINCT clm.lens_id)::BIGINT                                   AS tenant_lens_count,
            MIN(pb.sell_price)                                                    AS price_min,
            MAX(pb.sell_price)                                                    AS price_max,
            AVG(pb.sell_price)                                                    AS price_avg,
            MIN(pb.cost_price)                                                    AS cost_min,
            MAX(pb.cost_price)                                                    AS cost_max,
            MIN(CASE WHEN pb.cost_price > 0 THEN pb.sell_price / pb.cost_price END) AS markup_min,
            MAX(CASE WHEN pb.cost_price > 0 THEN pb.sell_price / pb.cost_price END) AS markup_max
        FROM catalog_lenses.canonical_lenses_premium cl
        JOIN catalog_lenses.canonical_lens_materials clmat
            ON  clmat.id = cl.canonical_material_id
        LEFT JOIN catalog_lenses.canonical_lens_mappings_premium clm
            ON  clm.canonical_lens_id = cl.id
            AND clm.tenant_id         = v_tenant
            AND clm.deleted_at        IS NULL
        LEFT JOIN catalog_lenses.pricing_book pb
            ON  pb.lens_id   = clm.lens_id
            AND pb.tenant_id = v_tenant
        WHERE cl.deleted_at IS NULL
          AND cl.spherical_min  <= p_spherical
          AND cl.spherical_max  >= p_spherical
          AND (p_cylindrical IS NULL OR (
                  cl.cylindrical_min <= p_cylindrical
              AND cl.cylindrical_max >= p_cylindrical
          ))
          AND (p_addition IS NULL OR (
                  cl.addition_min <= p_addition
              AND cl.addition_max >= p_addition
          ))
          AND (p_lens_type IS NULL OR cl.lens_type::TEXT = p_lens_type)
        GROUP BY
            cl.id, cl.sku, cl.canonical_name, cl.lens_type,
            clmat.material_class, clmat.refractive_index, clmat.display_name,
            cl.treatment_codes,
            cl.spherical_min, cl.spherical_max,
            cl.cylindrical_min, cl.cylindrical_max,
            cl.addition_min, cl.addition_max
        ORDER BY tenant_lens_count DESC, cl.canonical_name
        LIMIT p_limit;

    -- ── STANDARD ─────────────────────────────────────────────────────────────
    ELSE
        RETURN QUERY
        SELECT
            cl.id,
            cl.sku,
            cl.canonical_name,
            cl.lens_type::TEXT,
            clmat.material_class,
            clmat.refractive_index,
            clmat.display_name                                                    AS material_display,
            cl.treatment_codes,
            cl.spherical_min,
            cl.spherical_max,
            cl.cylindrical_min,
            cl.cylindrical_max,
            cl.addition_min,
            cl.addition_max,
            COUNT(DISTINCT clm.lens_id)::BIGINT                                   AS tenant_lens_count,
            MIN(pb.sell_price)                                                    AS price_min,
            MAX(pb.sell_price)                                                    AS price_max,
            AVG(pb.sell_price)                                                    AS price_avg,
            MIN(pb.cost_price)                                                    AS cost_min,
            MAX(pb.cost_price)                                                    AS cost_max,
            MIN(CASE WHEN pb.cost_price > 0 THEN pb.sell_price / pb.cost_price END) AS markup_min,
            MAX(CASE WHEN pb.cost_price > 0 THEN pb.sell_price / pb.cost_price END) AS markup_max
        FROM catalog_lenses.canonical_lenses cl
        JOIN catalog_lenses.canonical_lens_materials clmat
            ON  clmat.id = cl.canonical_material_id
        LEFT JOIN catalog_lenses.canonical_lens_mappings clm
            ON  clm.canonical_lens_id = cl.id
            AND clm.tenant_id         = v_tenant
            AND clm.deleted_at        IS NULL
        LEFT JOIN catalog_lenses.pricing_book pb
            ON  pb.lens_id   = clm.lens_id
            AND pb.tenant_id = v_tenant
        WHERE cl.deleted_at IS NULL
          AND cl.spherical_min  <= p_spherical
          AND cl.spherical_max  >= p_spherical
          AND (p_cylindrical IS NULL OR (
                  cl.cylindrical_min <= p_cylindrical
              AND cl.cylindrical_max >= p_cylindrical
          ))
          AND (p_addition IS NULL OR (
                  cl.addition_min <= p_addition
              AND cl.addition_max >= p_addition
          ))
          AND (p_lens_type IS NULL OR cl.lens_type::TEXT = p_lens_type)
        GROUP BY
            cl.id, cl.sku, cl.canonical_name, cl.lens_type,
            clmat.material_class, clmat.refractive_index, clmat.display_name,
            cl.treatment_codes,
            cl.spherical_min, cl.spherical_max,
            cl.cylindrical_min, cl.cylindrical_max,
            cl.addition_min, cl.addition_max
        ORDER BY tenant_lens_count DESC, cl.canonical_name
        LIMIT p_limit;
    END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.rpc_canonical_for_prescription(
    NUMERIC, NUMERIC, NUMERIC, TEXT, BOOLEAN, INTEGER
) TO authenticated;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2. rpc_canonical_detail
--    Retorna as lentes reais mapeadas a um conceito canônico, com preços.
--    Standard: usa canonical_lens_mappings
--    Premium:  usa canonical_lens_mappings_premium
--    Ordenadas: is_preferred DESC, sell_price ASC
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.rpc_canonical_detail(
    p_canonical_id UUID,
    p_is_premium   BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    lens_id          UUID,
    lens_sku         TEXT,
    lens_name        TEXT,
    brand_name       TEXT,
    supplier_name    TEXT,
    sell_price       NUMERIC,
    cost_price       NUMERIC,
    final_price      NUMERIC,
    effective_markup NUMERIC,
    is_preferred     BOOLEAN,
    match_method     TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, catalog_lenses
AS $$
DECLARE
    v_tenant UUID;
BEGIN
    v_tenant := require_tenant_id();

    -- ── PREMIUM ──────────────────────────────────────────────────────────────
    IF p_is_premium THEN
        RETURN QUERY
        SELECT
            l.id                                                       AS lens_id,
            l.sku::TEXT                                                AS lens_sku,
            l.lens_name                                                AS lens_name,
            b.name::TEXT                                               AS brand_name,
            sl.name::TEXT                                              AS supplier_name,
            COALESCE(pb.sell_price,  0)                               AS sell_price,
            COALESCE(pb.cost_price,  0)                               AS cost_price,
            COALESCE(pb.final_price, pb.sell_price, 0)                AS final_price,
            CASE
                WHEN COALESCE(pb.cost_price, 0) > 0
                THEN ROUND(pb.sell_price / pb.cost_price, 2)
            END                                                        AS effective_markup,
            COALESCE(clm.is_preferred, FALSE)                         AS is_preferred,
            clm.match_method::TEXT                                    AS match_method
        FROM catalog_lenses.canonical_lens_mappings_premium clm
        JOIN catalog_lenses.lenses l
            ON  l.id         = clm.lens_id
            AND l.tenant_id  = v_tenant
            AND l.deleted_at IS NULL
        LEFT JOIN catalog_lenses.brands b
            ON  b.id = l.brand_id
        LEFT JOIN catalog_lenses.suppliers_labs sl
            ON  sl.id        = l.supplier_id
            AND sl.tenant_id = v_tenant
        LEFT JOIN catalog_lenses.pricing_book pb
            ON  pb.lens_id   = l.id
            AND pb.tenant_id = v_tenant
        WHERE clm.canonical_lens_id = p_canonical_id
          AND clm.tenant_id         = v_tenant
          AND clm.deleted_at        IS NULL
        ORDER BY
            COALESCE(clm.is_preferred, FALSE) DESC,
            COALESCE(pb.sell_price, 999999)   ASC;

    -- ── STANDARD ─────────────────────────────────────────────────────────────
    ELSE
        RETURN QUERY
        SELECT
            l.id                                                       AS lens_id,
            l.sku::TEXT                                                AS lens_sku,
            l.lens_name                                                AS lens_name,
            b.name::TEXT                                               AS brand_name,
            sl.name::TEXT                                              AS supplier_name,
            COALESCE(pb.sell_price,  0)                               AS sell_price,
            COALESCE(pb.cost_price,  0)                               AS cost_price,
            COALESCE(pb.final_price, pb.sell_price, 0)                AS final_price,
            CASE
                WHEN COALESCE(pb.cost_price, 0) > 0
                THEN ROUND(pb.sell_price / pb.cost_price, 2)
            END                                                        AS effective_markup,
            COALESCE(clm.is_preferred, FALSE)                         AS is_preferred,
            clm.match_method::TEXT                                    AS match_method
        FROM catalog_lenses.canonical_lens_mappings clm
        JOIN catalog_lenses.lenses l
            ON  l.id         = clm.lens_id
            AND l.tenant_id  = v_tenant
            AND l.deleted_at IS NULL
        LEFT JOIN catalog_lenses.brands b
            ON  b.id = l.brand_id
        LEFT JOIN catalog_lenses.suppliers_labs sl
            ON  sl.id        = l.supplier_id
            AND sl.tenant_id = v_tenant
        LEFT JOIN catalog_lenses.pricing_book pb
            ON  pb.lens_id   = l.id
            AND pb.tenant_id = v_tenant
        WHERE clm.canonical_lens_id = p_canonical_id
          AND clm.tenant_id         = v_tenant
          AND clm.deleted_at        IS NULL
        ORDER BY
            COALESCE(clm.is_preferred, FALSE) DESC,
            COALESCE(pb.sell_price, 999999)   ASC;
    END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.rpc_canonical_detail(UUID, BOOLEAN)
    TO authenticated;


-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Verificação final — deve retornar 2 linhas
-- ─────────────────────────────────────────────────────────────────────────────
SELECT routine_name, routine_schema
FROM information_schema.routines
WHERE routine_name IN ('rpc_canonical_for_prescription', 'rpc_canonical_detail')
ORDER BY routine_name;
