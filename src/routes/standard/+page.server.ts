/**
 * Catálogo Standard — Server Load (minimal v3)
 * Sem queries ao DB. Dados buscados client-side via browser supabase.
 * View: public.v_canonical_lenses_pricing (migration 277)
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url }) => {
    const busca          = url.searchParams.get('busca')    || null;
    const lens_type      = url.searchParams.get('tipo')     || null;
    const material_class = url.searchParams.get('material') || null;
    const pagina         = Math.max(1, parseInt(url.searchParams.get('pagina') || '1'));
    return { busca, lens_type, material_class, pagina };
};
