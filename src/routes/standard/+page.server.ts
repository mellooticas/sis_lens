/**
 * Standard Collection — Server Load v3
 * Filtros técnicos: tipo + material + tratamentos (sem marca!)
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url }) => {
    const lens_type   = url.searchParams.get('tipo')     || null;
    const material_id = url.searchParams.get('material') || null;
    const treatments  = url.searchParams.get('trat')?.split(',').filter(Boolean) ?? null;
    const pagina      = Math.max(1, parseInt(url.searchParams.get('pagina') || '1'));
    return { lens_type, material_id, treatments, pagina };
};
