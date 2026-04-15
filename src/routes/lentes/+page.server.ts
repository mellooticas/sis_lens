/**
 * Catálogo de Lentes Reais — Server Load
 *
 * Lista TODAS as 1.525 lentes reais (v_catalog_lenses), com filtros
 * cobrindo 100% do que o banco expõe hoje. Booleans de tratamento
 * vêm da view (populados via lens_treatment_links). Coating, linha
 * de produto e lens design vêm de attributes jsonb.
 *
 * Filter options via RPC pública `rpc_lens_catalog_filter_options`.
 */
import type { PageServerLoad } from './$types';
import type { VCatalogLens } from '$lib/types/database-views';

const PAGE_SIZE = 24;

export type LenteListItem = Pick<
    VCatalogLens,
    | 'id' | 'lens_name' | 'sku' | 'lens_type' | 'is_premium'
    | 'brand_name' | 'supplier_name' | 'material_name' | 'refractive_index'
    | 'price_cost' | 'price_suggested'
    | 'treatment_names' | 'anti_reflective' | 'blue_light' | 'photochromic' | 'polarized' | 'anti_scratch' | 'uv_filter'
    | 'spherical_min' | 'spherical_max' | 'cylindrical_min' | 'cylindrical_max'
    | 'addition_min' | 'addition_max' | 'status'
>;

export interface FilterOption {
    value: string;
    label?: string;
    count: number;
}

export interface FilterOptions {
    laboratorios:  FilterOption[];
    marcas:        FilterOption[];
    tipos:         FilterOption[];
    materiais:     FilterOption[];
    indices:       FilterOption[];
    coatings:      FilterOption[];
    product_lines: FilterOption[];
    lens_designs:  FilterOption[];
    min_heights:   FilterOption[];
    has_blue_cut:     number;
    has_photochromic: number;
    has_hidrofobic:   number;
    price_min:      number;
    price_max:      number;
    total:          number;
    premium_total:  number;
    standard_total: number;
}

export const load: PageServerLoad = async ({ url, locals }) => {
    const { supabase } = locals;

    // ── URL params ───────────────────────────────────────────────────────────
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

    // Novos filtros via attributes
    const coating     = url.searchParams.get('coating')     || null;
    const linha       = url.searchParams.get('linha')       || null;
    const design      = url.searchParams.get('design')      || null;
    const altura      = url.searchParams.get('altura')      || null;

    // Faixa de preço
    const precoMinParam = url.searchParams.get('precoMin');
    const precoMaxParam = url.searchParams.get('precoMax');
    const precoMin = precoMinParam ? parseFloat(precoMinParam) : null;
    const precoMax = precoMaxParam ? parseFloat(precoMaxParam) : null;

    // Toggles de tratamento (view) e attributes
    const ar          = url.searchParams.get('ar')      === 'true';
    const scratch     = url.searchParams.get('scratch') === 'true';
    const uv          = url.searchParams.get('uv')      === 'true';
    const blue        = url.searchParams.get('blue')    === 'true';
    const photo       = url.searchParams.get('photo')   === 'true';
    const pol         = url.searchParams.get('pol')     === 'true';
    const hidro       = url.searchParams.get('hidro')   === 'true';

    const pagina      = Math.max(1, parseInt(url.searchParams.get('pagina') || '1'));

    // ── Query base ────────────────────────────────────────────────────────────
    let query = supabase
        .from('v_catalog_lenses')
        .select(
            'id, lens_name, sku, lens_type, is_premium, brand_name, supplier_name, ' +
            'material_name, refractive_index, price_cost, price_suggested, ' +
            'treatment_names, anti_reflective, blue_light, photochromic, polarized, anti_scratch, uv_filter, ' +
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

    // Tratamentos — booleans da view (populados via lens_treatment_links)
    if (ar)      query = query.eq('anti_reflective', true);
    if (scratch) query = query.eq('anti_scratch',    true);
    if (uv)      query = query.eq('uv_filter',       true);
    if (blue)    query = query.eq('blue_light',      true);
    if (photo)   query = query.eq('photochromic',    true);
    if (pol)     query = query.eq('polarized',       true);

    // Attributes jsonb
    if (coating) query = query.filter('attributes->>coating',        'eq', coating);
    if (linha)   query = query.filter('attributes->>product_line',   'eq', linha);
    if (design)  query = query.filter('attributes->>lens_design',    'eq', design);
    if (altura)  query = query.filter('attributes->>min_height_mm',  'eq', altura);
    if (hidro)   query = query.filter('attributes->>hidrofobic',     'eq', 'true');

    // Faixa de preço
    if (precoMin != null) query = query.gte('price_suggested', precoMin);
    if (precoMax != null) query = query.lte('price_suggested', precoMax);

    if (busca) {
        query = query.or(
            `lens_name.ilike.%${busca}%,brand_name.ilike.%${busca}%,supplier_name.ilike.%${busca}%,sku.ilike.%${busca}%`
        );
    }

    const from = (pagina - 1) * PAGE_SIZE;
    const to   = from + PAGE_SIZE - 1;

    // ── Fetch paralelo ───────────────────────────────────────────────────────
    const [listResult, filterOptionsResult] = await Promise.all([
        query
            .order('is_premium', { ascending: false })
            .order('lens_name',  { ascending: true })
            .range(from, to),
        supabase.rpc('rpc_lens_catalog_filter_options'),
    ]);

    if (listResult.error) {
        console.error('[lentes] list error:', listResult.error);
    }
    if (filterOptionsResult.error) {
        console.error('[lentes] filterOptions error:', filterOptionsResult.error);
    }

    const rawOpts = (filterOptionsResult.data ?? {}) as Record<string, unknown>;
    const filterOptions: FilterOptions = {
        laboratorios:    (rawOpts.laboratorios  as FilterOption[]) ?? [],
        marcas:          (rawOpts.marcas        as FilterOption[]) ?? [],
        tipos:           applyTipoLabels((rawOpts.tipos as FilterOption[]) ?? []),
        materiais:       (rawOpts.materiais     as FilterOption[]) ?? [],
        indices:         toIndicesOptions((rawOpts.indices as FilterOption[]) ?? []),
        coatings:        (rawOpts.coatings      as FilterOption[]) ?? [],
        product_lines:   (rawOpts.product_lines as FilterOption[]) ?? [],
        lens_designs:    (rawOpts.lens_designs  as FilterOption[]) ?? [],
        min_heights:     toHeightOptions((rawOpts.min_heights as FilterOption[]) ?? []),
        has_blue_cut:     Number(rawOpts.has_blue_cut     ?? 0),
        has_photochromic: Number(rawOpts.has_photochromic ?? 0),
        has_hidrofobic:   Number(rawOpts.has_hidrofobic   ?? 0),
        price_min:        Number(rawOpts.price_min ?? 0),
        price_max:        Number(rawOpts.price_max ?? 0),
        total:            Number(rawOpts.total          ?? 0),
        premium_total:    Number(rawOpts.premium_total  ?? 0),
        standard_total:   Number(rawOpts.standard_total ?? 0),
    };

    return {
        lentes: (listResult.data ?? []) as unknown as LenteListItem[],
        total:  listResult.count ?? 0,
        premiumTotal:  filterOptions.premium_total,
        standardTotal: filterOptions.standard_total,
        filtros: {
            busca, tipo, isPremium, fornecedor, marca, material, indice,
            coating, linha, design, altura,
            precoMin, precoMax,
            ar, scratch, uv, blue, photo, pol, hidro,
        },
        filterOptions,
        pagina,
        pageSize: PAGE_SIZE,
    };
};

// ── helpers ──────────────────────────────────────────────────────────────────

const TIPO_LABELS: Record<string, string> = {
    single_vision: 'Visão Simples',
    multifocal:    'Multifocal',
    bifocal:       'Bifocal',
    occupational:  'Ocupacional',
};

function applyTipoLabels(opts: FilterOption[]): FilterOption[] {
    return opts.map(o => ({ ...o, label: TIPO_LABELS[o.value] ?? o.value }));
}

function toIndicesOptions(opts: FilterOption[]): FilterOption[] {
    return opts.map(o => ({ ...o, label: `n = ${o.value}` }));
}

function toHeightOptions(opts: FilterOption[]): FilterOption[] {
    return opts.map(o => ({ ...o, label: `${o.value} mm` }));
}
