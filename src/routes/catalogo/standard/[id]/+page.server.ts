/**
 * 📚 Detalhes Conceito Canônico Standard — Server Load
 * Canonical Engine v2: v_canonical_lenses_pricing + rpc_canonical_detail (migration 278).
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
                lentes: [] as CanonicalDetailEnriched[],
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

        const lentesBase = (lentes || []) as CanonicalDetail[];

        // Enriquecer com dados técnicos reais de v_catalog_lenses
        let lentesEnriquecidas: CanonicalDetailEnriched[] = lentesBase;
        const lensIds = lentesBase.map((l) => l.lens_id).filter(Boolean);

        if (lensIds.length > 0) {
            const { data: detalhes } = await supabase
                .from('v_catalog_lenses')
                .select('id, sku, anti_reflective, anti_scratch, uv_filter, blue_light, photochromic, polarized, refractive_index, material_name')
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
                    photochromic: d.photochromic as boolean | undefined,
                    polarized: d.polarized as boolean | undefined,
                    refractive_index: d.refractive_index as number | null | undefined,
                    material_name: d.material_name as string | null | undefined,
                };
            });
        }

        return {
            conceito: conceito as CanonicalWithPricing,
            lentes: lentesEnriquecidas,
            isPremium: false,
            sucesso: true
        };
    } catch (err: any) {
        if (err.status) throw err; // Re-throw SvelteKit errors
        console.error('❌ Erro fatal no load standard v2:', err);
        throw error(500, 'Erro interno ao carregar detalhes do conceito');
    }
};
