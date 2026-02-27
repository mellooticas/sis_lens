/**
 * Catálogo de Lentes de Contato — Server Load (minimal)
 * Sem queries ao DB. Dados buscados client-side via browser supabase.
 * Fonte: public.v_contact_lenses (migration 281 — COALESCE fix)
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url }) => {
    const busca     = url.searchParams.get('busca')    || null;
    const lens_type = url.searchParams.get('tipo')     || null;
    const purpose   = url.searchParams.get('uso')      || null;
    const material  = url.searchParams.get('material') || null;
    const pagina    = Math.max(1, parseInt(url.searchParams.get('pagina') || '1'));
    return { busca, lens_type, purpose, material, pagina };
};
