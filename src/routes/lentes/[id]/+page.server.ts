/**
 * Detalhe da Lente Real — Server Load (minimal)
 * Dados buscados client-side via browser supabase (evita 500 SSR).
 * Fonte: public.v_catalog_lenses
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params }) => {
    return { id: params.id };
};
