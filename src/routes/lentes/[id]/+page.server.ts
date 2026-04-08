/**
 * Detalhe da Lente Real — Server Load
 *
 * Carrega:
 *   1. Dados completos da lente (public.v_catalog_lenses)
 *   2. Conceitos canônicos aos quais a lente pertence
 *      → via rpc_canonical_for_prescription (mid-point das faixas como receita)
 *      → mesmo is_premium da lente
 */
import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';
import type { VCatalogLens, PrescriptionSearchResult } from '$lib/types/database-views';

function midpoint(min: number | null, max: number | null): number | null {
    if (min == null && max == null) return null;
    if (min == null) return max;
    if (max == null) return min;
    return (min + max) / 2;
}

export const load: PageServerLoad = async ({ params, locals }) => {
    const { supabase } = locals;

    const { data: row, error: lensErr } = await supabase
        .from('v_catalog_lenses')
        .select('*')
        .eq('id', params.id)
        .maybeSingle();

    if (lensErr || !row) {
        throw error(404, lensErr?.message ?? 'Lente não encontrada');
    }

    const lente = row as unknown as VCatalogLens;

    // Conceitos canônicos que cobrem a receita representativa desta lente
    let conceitos: PrescriptionSearchResult[] = [];
    const sph = midpoint(lente.spherical_min, lente.spherical_max);
    if (sph != null && lente.lens_type) {
        const { data: rxData, error: rxErr } = await supabase.rpc(
            'rpc_canonical_for_prescription',
            {
                p_spherical:   sph,
                p_cylindrical: midpoint(lente.cylindrical_min, lente.cylindrical_max),
                p_addition:    midpoint(lente.addition_min, lente.addition_max),
                p_lens_type:   lente.lens_type,
                p_is_premium:  lente.is_premium ?? false,
            }
        );
        if (rxErr) {
            console.error('[lentes/[id]] rpc_canonical_for_prescription error:', rxErr);
        } else {
            conceitos = (rxData as PrescriptionSearchResult[]) ?? [];
        }
    }

    return {
        lente,
        conceitos,
        isPremium: lente.is_premium ?? false,
    };
};
