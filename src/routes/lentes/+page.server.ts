/**
 * Catálogo de Lentes Reais — Server Load
 *
 * Mostra TODAS as lentes reais (v_catalog_lenses), divididas em tabs
 * Premium/Standard via flag `is_premium`. Conceitos canônicos só aparecem
 * no detalhe individual da lente.
 *
 * Fonte: public.v_catalog_lenses (3.698 lentes)
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';
import type { VCatalogLens } from '$lib/types/database-views';

const PAGE_SIZE = 24;

export type LenteListItem = Pick<
    VCatalogLens,
    | 'id' | 'lens_name' | 'sku' | 'lens_type' | 'is_premium'
    | 'brand_name' | 'supplier_name' | 'material_name' | 'refractive_index'
    | 'price_cost' | 'price_suggested'
    | 'treatment_names' | 'anti_reflective' | 'blue_light' | 'photochromic' | 'polarized'
    | 'spherical_min' | 'spherical_max' | 'cylindrical_min' | 'cylindrical_max'
    | 'addition_min' | 'addition_max' | 'status'
>;

export const load: PageServerLoad = async ({ url }) => {
    // ── URL params
    const busca       = url.searchParams.get('busca') || '';
    const tipo        = url.searchParams.get('tipo')  || null;
    const premiumPar  = url.searchParams.get('premium');
    const isPremium   = premiumPar === 'true' ? true
                      : premiumPar === 'false' ? false
                      : null;
    const fornecedor  = url.searchParams.get('fornecedor') || null;
    const marca       = url.searchParams.get('marca')      || null;
    const pagina      = Math.max(1, parseInt(url.searchParams.get('pagina') || '1'));

    // ── Query base sobre v_catalog_lenses
    let query = supabase
        .from('v_catalog_lenses')
        .select(
            'id, lens_name, sku, lens_type, is_premium, brand_name, supplier_name, ' +
            'material_name, refractive_index, price_cost, price_suggested, ' +
            'treatment_names, anti_reflective, blue_light, photochromic, polarized, ' +
            'spherical_min, spherical_max, cylindrical_min, cylindrical_max, ' +
            'addition_min, addition_max, status',
            { count: 'exact' }
        )
        .eq('status', 'active');

    if (isPremium !== null)  query = query.eq('is_premium', isPremium);
    if (tipo)                query = query.eq('lens_type', tipo);
    if (fornecedor)          query = query.eq('supplier_id', fornecedor);
    if (marca)               query = query.eq('brand_id', marca);
    if (busca) {
        query = query.or(
            `lens_name.ilike.%${busca}%,brand_name.ilike.%${busca}%,supplier_name.ilike.%${busca}%,sku.ilike.%${busca}%`
        );
    }

    const from = (pagina - 1) * PAGE_SIZE;
    const to   = from + PAGE_SIZE - 1;

    const [
        listResult,
        premiumCountResult,
        standardCountResult,
    ] = await Promise.all([
        query
            .order('is_premium', { ascending: false })
            .order('lens_name',  { ascending: true })
            .range(from, to),
        supabase
            .from('v_catalog_lenses')
            .select('id', { count: 'exact', head: true })
            .eq('status', 'active')
            .eq('is_premium', true),
        supabase
            .from('v_catalog_lenses')
            .select('id', { count: 'exact', head: true })
            .eq('status', 'active')
            .eq('is_premium', false),
    ]);

    if (listResult.error) {
        console.error('[lentes] list error:', listResult.error);
    }

    return {
        lentes: (listResult.data ?? []) as unknown as LenteListItem[],
        total:  listResult.count ?? 0,
        premiumTotal:  premiumCountResult.count ?? 0,
        standardTotal: standardCountResult.count ?? 0,
        filtros: { busca, tipo, isPremium, fornecedor, marca },
        pagina,
        pageSize: PAGE_SIZE,
    };
};
