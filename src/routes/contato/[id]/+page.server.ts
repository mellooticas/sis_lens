/**
 * Detalhe da Lente de Contato — Server Load (minimal)
 * Dados buscados client-side via browser supabase.
 * Fonte: public.v_contact_lenses
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params }) => {
    return { id: params.id };
};
