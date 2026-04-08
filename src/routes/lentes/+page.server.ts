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

export interface FilterOption {
    value: string;
    label: string;
    count: number;
}

export interface FilterOptions {
    laboratorios: FilterOption[];
    tipos:        FilterOption[];
    materiais:    FilterOption[];
    indices:      FilterOption[];
}

export const load: PageServerLoad = async ({ url, locals }) => {
    const { supabase } = locals;

    // ── URL params
    const busca       = url.searchParams.get('busca') || '';
    const tipo        = url.searchParams.get('tipo')  || null;
    const premiumPar  = url.searchParams.get('premium');
    const isPremium   = premiumPar === 'true' ? true
                      : premiumPar === 'false' ? false
                      : null;
    const fornecedor  = url.searchParams.get('fornecedor') || null;
    const marca       = url.searchParams.get('marca')      || null;
    const material    = url.searchParams.get('material')   || null;
    const indiceParam = url.searchParams.get('indice');
    const indice      = indiceParam ? parseFloat(indiceParam) : null;
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
    if (material)            query = query.eq('material_id', material);
    if (indice != null)      query = query.eq('refractive_index', indice);
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
        filterOptionsResult,
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
        // Single sweep — pega só as colunas necessárias para montar dropdowns
        supabase
            .from('v_catalog_lenses')
            .select('supplier_id, supplier_name, lens_type, material_id, material_name, refractive_index')
            .eq('status', 'active'),
    ]);

    if (listResult.error) {
        console.error('[lentes] list error:', listResult.error);
    }

    // ── Construir opções de filtro a partir do sweep
    const filterOptions = buildFilterOptions(filterOptionsResult.data ?? []);

    return {
        lentes: (listResult.data ?? []) as unknown as LenteListItem[],
        total:  listResult.count ?? 0,
        premiumTotal:  premiumCountResult.count ?? 0,
        standardTotal: standardCountResult.count ?? 0,
        filtros: { busca, tipo, isPremium, fornecedor, marca, material, indice },
        filterOptions,
        pagina,
        pageSize: PAGE_SIZE,
    };
};

const TIPO_LABELS: Record<string, string> = {
    single_vision: 'Visão Simples',
    multifocal:    'Multifocal',
    bifocal:       'Bifocal',
    occupational:  'Ocupacional',
};

interface SweepRow {
    supplier_id: string | null;
    supplier_name: string | null;
    lens_type: string | null;
    material_id: string | null;
    material_name: string | null;
    refractive_index: number | null;
}

function buildFilterOptions(rows: unknown[]): FilterOptions {
    const labs   = new Map<string, { label: string; count: number }>();
    const tipos  = new Map<string, { label: string; count: number }>();
    const mats   = new Map<string, { label: string; count: number }>();
    const idxs   = new Map<string, { label: string; count: number }>();

    for (const r of rows as SweepRow[]) {
        if (r.supplier_id && r.supplier_name) {
            const e = labs.get(r.supplier_id);
            if (e) e.count++;
            else labs.set(r.supplier_id, { label: r.supplier_name, count: 1 });
        }
        if (r.lens_type) {
            const e = tipos.get(r.lens_type);
            if (e) e.count++;
            else tipos.set(r.lens_type, { label: TIPO_LABELS[r.lens_type] ?? r.lens_type, count: 1 });
        }
        if (r.material_id && r.material_name) {
            const e = mats.get(r.material_id);
            if (e) e.count++;
            else mats.set(r.material_id, { label: r.material_name, count: 1 });
        }
        if (r.refractive_index != null) {
            const key = String(r.refractive_index);
            const e = idxs.get(key);
            if (e) e.count++;
            else idxs.set(key, { label: `n = ${r.refractive_index}`, count: 1 });
        }
    }

    const toSorted = (m: Map<string, { label: string; count: number }>): FilterOption[] =>
        Array.from(m.entries())
            .map(([value, { label, count }]) => ({ value, label, count }))
            .sort((a, b) => a.label.localeCompare(b.label));

    return {
        laboratorios: toSorted(labs),
        tipos:        toSorted(tipos),
        materiais:    toSorted(mats),
        indices:      Array.from(idxs.entries())
            .map(([value, { label, count }]) => ({ value, label, count }))
            .sort((a, b) => parseFloat(a.value) - parseFloat(b.value)),
    };
}
