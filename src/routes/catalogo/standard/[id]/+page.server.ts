/**
 * 📚 Detalhes Conceito Canônico Standard — Server Load
 * Canonical Engine v2: v_canonical_lenses_pricing + rpc_canonical_detail (migration 278).
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
        console.log('🔍 [Oracle v2] Buscando conceito standard:', conceitoId);

        // Buscar conceito canônico (com pricing)
        const { data: conceito, error: erroConceito } = await supabase
            .from('v_canonical_lenses_pricing')
            .select('*')
            .eq('id', conceitoId)
            .single();

        if (erroConceito || !conceito) {
            // Fallback: tenta view sem pricing (conceito pode não ter lentes no pricing_book)
            const { data: conceitoBase, error: erroBase } = await supabase
                .from('v_canonical_lenses')
                .select('*')
                .eq('id', conceitoId)
                .single();

            if (erroBase || !conceitoBase) {
                console.error('❌ Conceito não encontrado:', erroConceito, erroBase);
                throw error(404, 'Conceito ótico não encontrado');
            }

            // Retorna sem pricing
            return {
                conceito: conceitoBase as CanonicalWithPricing,
                lentes: [] as CanonicalDetail[],
                isPremium: false,
                sucesso: true
            };
        }

        // Buscar lentes reais via rpc_canonical_detail
        console.log('🔍 [Oracle v2] Buscando lentes do conceito via rpc_canonical_detail...');
        const { data: lentes, error: erroLentes } = await supabase
            .rpc('rpc_canonical_detail', {
                p_canonical_id: conceitoId,
                p_is_premium: false,
            });

        if (erroLentes) {
            console.error('⚠️ Erro ao buscar lentes do conceito (não fatal):', erroLentes);
        }

        return {
            conceito: conceito as CanonicalWithPricing,
            lentes: (lentes || []) as CanonicalDetail[],
            isPremium: false,
            sucesso: true
        };
    } catch (err: any) {
        if (err.status) throw err; // Re-throw SvelteKit errors
        console.error('❌ Erro fatal no load standard v2:', err);
        throw error(500, 'Erro interno ao carregar detalhes do conceito');
    }
};
