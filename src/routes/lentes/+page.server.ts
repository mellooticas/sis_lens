/**
 * Catálogo de Lentes — Server Load (v2)
 * Leve: apenas lê URL params e passa para o cliente.
 * Busca de dados: client-side via browser supabase (evita 500 no SSR).
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url }) => {
    const lens_type    = url.searchParams.get('tipo')       || null;
    const supplier_id  = url.searchParams.get('fornecedor') || null;
    const material_id  = url.searchParams.get('material')   || null;
    const premiumParam = url.searchParams.get('premium');
    const is_premium   = premiumParam === 'true'  ? true
                       : premiumParam === 'false' ? false
                       : null;
    const has_ar   = url.searchParams.get('ar')   === '1';
    const has_blue = url.searchParams.get('blue') === '1';
    const pagina   = Math.max(1, parseInt(url.searchParams.get('pagina') || '1'));

    return { lens_type, supplier_id, material_id, is_premium, has_ar, has_blue, pagina };
};
