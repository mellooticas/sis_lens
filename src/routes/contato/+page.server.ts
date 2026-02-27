/**
 * Catálogo de Lentes de Contato — Server Load (minimal)
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url }) => {
    const busca      = url.searchParams.get('busca')    || null;
    const lens_type  = url.searchParams.get('tipo')     || null;
    const purpose    = url.searchParams.get('uso')      || null;
    const material   = url.searchParams.get('material') || null;
    const brand      = url.searchParams.get('marca')    || null;
    const is_colored = url.searchParams.get('colorida') === '1' ? true : null;
    const has_uv     = url.searchParams.get('uv')       === '1';
    const pagina     = Math.max(1, parseInt(url.searchParams.get('pagina') || '1'));
    return { busca, lens_type, purpose, material, brand, is_colored, has_uv, pagina };
};
