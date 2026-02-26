/**
 * 🏆 Detalhes Conceito Canônico Premium — Server Load
 * Canonical Engine v2: v_canonical_lenses_premium_pricing + rpc_canonical_detail (migration 278).
 */
import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';
import type { CanonicalWithPricing, CanonicalDetail } from '$lib/types/database-views';

export const load: PageServerLoad = async ({ params, locals }) => {
    const conceitoId = params.id;
    const { supabase } = locals;

    if (!conceitoId) {
        throw error(400, 'ID do conceito não encontrado');
    }

    try {
        console.log('🔍 [Oracle v2] Buscando conceito premium:', conceitoId);

        // Buscar conceito canônico premium (com pricing)
        const { data: conceito, error: erroConceito } = await supabase
            .from('v_canonical_lenses_premium_pricing')
            .select('*')
            .eq('id', conceitoId)
            .single();

        if (erroConceito || !conceito) {
            // Fallback: tenta view sem pricing
            const { data: conceitoBase, error: erroBase } = await supabase
                .from('v_canonical_lenses_premium')
                .select('*')
                .eq('id', conceitoId)
                .single();

            if (erroBase || !conceitoBase) {
                console.error('❌ Conceito premium não encontrado:', erroConceito, erroBase);
                throw error(404, 'Conceito premium não encontrado');
            }

            return {
                conceito: conceitoBase as CanonicalWithPricing,
                lentes: [] as CanonicalDetail[],
                isPremium: true,
                sucesso: true
            };
        }

        // Buscar lentes reais via rpc_canonical_detail (is_premium = true)
        console.log('🔍 [Oracle v2] Buscando lentes do conceito premium via rpc_canonical_detail...');
        const { data: lentes, error: erroLentes } = await supabase
            .rpc('rpc_canonical_detail', {
                p_canonical_id: conceitoId,
                p_is_premium: true,
            });

        if (erroLentes) {
            console.error('⚠️ Erro ao buscar lentes do conceito premium (não fatal):', erroLentes);
        }

        return {
            conceito: conceito as CanonicalWithPricing,
            lentes: (lentes || []) as CanonicalDetail[],
            isPremium: true,
            sucesso: true
        };
    } catch (err: any) {
        if (err.status) throw err;
        console.error('❌ Erro fatal no load premium v2:', err);
        throw error(500, 'Erro interno ao carregar detalhes do conceito premium');
    }
};
