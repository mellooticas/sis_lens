/**
 * Catálogo Standard — Server Load (minimal v4)
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url }) => {
    const busca          = url.searchParams.get('busca')    || null;
    const lens_type      = url.searchParams.get('tipo')     || null;
    const material_class = url.searchParams.get('material') || null;
    const has_ar         = url.searchParams.get('ar')    === '1';
    const has_uv         = url.searchParams.get('uv')    === '1';
    const has_blue       = url.searchParams.get('blue')  === '1';
    const has_photo      = url.searchParams.get('foto')  === '1';
    const pagina         = Math.max(1, parseInt(url.searchParams.get('pagina') || '1'));
    return { busca, lens_type, material_class, has_ar, has_uv, has_blue, has_photo, pagina };
};
