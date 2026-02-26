/**
 * 🏆 Detalhes Conceito Canônico Premium — Server Load
 * Canonical Engine v2: v_canonical_lenses_premium_pricing + rpc_canonical_detail (migration 278).
 * Enriquece cada lente com dados técnicos reais de v_catalog_lenses.
 */
import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';
import type { CanonicalWithPricing, CanonicalDetail, CanonicalDetailEnriched } from '$lib/types/database-views';

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
                lentes: [] as CanonicalDetailEnriched[],
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

        const lentesBase = (lentes || []) as CanonicalDetail[];

        // Enriquecer com dados técnicos reais de v_catalog_lenses
        let lentesEnriquecidas: CanonicalDetailEnriched[] = lentesBase;
        const lensIds = lentesBase.map((l) => l.lens_id).filter(Boolean);

        if (lensIds.length > 0) {
            const { data: detalhes } = await supabase
                .from('v_catalog_lenses')
                .select('id, sku, anti_reflective, anti_scratch, uv_filter, blue_light, photochromic, polarized, digital, free_form, refractive_index, material')
                .in('id', lensIds);

            const mapaDetalhe = new Map<string, Record<string, unknown>>(
                (detalhes || []).map((d: Record<string, unknown>) => [d.id as string, d])
            );

            lentesEnriquecidas = lentesBase.map((l) => {
                const d = mapaDetalhe.get(l.lens_id);
                if (!d) return l;
                return {
                    ...l,
                    lens_sku: l.lens_sku ?? (d.sku as string | null) ?? null,
                    anti_reflective: d.anti_reflective as boolean | undefined,
                    anti_scratch: d.anti_scratch as boolean | undefined,
                    uv_filter: d.uv_filter as boolean | undefined,
                    blue_light: d.blue_light as boolean | undefined,
                    photochromic: d.photochromic as string | null | undefined,
                    polarized: d.polarized as boolean | undefined,
                    digital: d.digital as boolean | undefined,
                    free_form: d.free_form as boolean | undefined,
                    refractive_index: d.refractive_index as number | null | undefined,
                    material: d.material as string | null | undefined,
                };
            });
        }

        return {
            conceito: conceito as CanonicalWithPricing,
            lentes: lentesEnriquecidas,
            isPremium: true,
            sucesso: true
        };
    } catch (err: any) {
        if (err.status) throw err;
        console.error('❌ Erro fatal no load premium v2:', err);
        throw error(500, 'Erro interno ao carregar detalhes do conceito premium');
    }
};
