/**
 * Catálogo de Lentes — Server Load (v3)
 * Leve: apenas lê URL params e passa para o cliente.
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url }) => {
    const busca        = url.searchParams.get('busca')      || null;
    const lens_type    = url.searchParams.get('tipo')       || null;
    const supplier_id  = url.searchParams.get('fornecedor') || null;
    const brand_id     = url.searchParams.get('marca')      || null;
    const material_id  = url.searchParams.get('material')   || null;
    const premiumParam = url.searchParams.get('premium');
    const is_premium   = premiumParam === 'true'  ? true
                       : premiumParam === 'false' ? false
                       : null;
    const has_ar      = url.searchParams.get('ar')      === '1';
    const has_blue    = url.searchParams.get('blue')    === '1';
    const has_scratch = url.searchParams.get('scratch') === '1';
    const has_uv      = url.searchParams.get('uv')      === '1';
    const has_photo   = url.searchParams.get('foto')    === '1';
    const has_polar   = url.searchParams.get('polar')   === '1';
    const pagina      = Math.max(1, parseInt(url.searchParams.get('pagina') || '1'));

    return { busca, lens_type, supplier_id, brand_id, material_id, is_premium,
             has_ar, has_blue, has_scratch, has_uv, has_photo, has_polar, pagina };
};
