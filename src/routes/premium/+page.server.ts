/**
 * Premium Collection — Server Load v3
 * Filtros por marca/linha/coating/fotossensível
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url }) => {
    const brand        = url.searchParams.get('marca')    || null;
    const product_line = url.searchParams.get('linha')    || null;
    const lens_type    = url.searchParams.get('tipo')     || null;
    const coating      = url.searchParams.get('coating')  || null;
    const photochromic = url.searchParams.get('foto')     || null;
    const material_id  = url.searchParams.get('material') || null;
    const pagina       = Math.max(1, parseInt(url.searchParams.get('pagina') || '1'));
    return { brand, product_line, lens_type, coating, photochromic, material_id, pagina };
};
