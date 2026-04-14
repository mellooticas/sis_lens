/**
 * Detalhe da Lente Real — Server Load
 *
 * Arquitetura N:1 — toda lente real pertence a EXATAMENTE UM conceito canônico.
 * Carrega:
 *   1. Dados completos da lente (public.v_catalog_lenses)
 *   2. O conceito canônico AO QUAL a lente pertence (via public.v_canonical_lens_mapping)
 *   3. Tratamentos vinculados (catalog_lenses.lens_treatment_links)
 *   4. Opções de edição (public.rpc_lens_edit_options)
 */
import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';
import type {
    VCatalogLens,
    VCanonicalLensMapping,
    CanonicalPremiumV3,
    CanonicalStandardV3,
    LensEditOptions,
} from '$lib/types/database-views';

export type ConceitoLente =
    | ({ kind: 'premium' } & CanonicalPremiumV3)
    | ({ kind: 'standard' } & CanonicalStandardV3);

export const load: PageServerLoad = async ({ params, locals }) => {
    const { supabase } = locals;

    // 1) Lente real
    const { data: row, error: lensErr } = await supabase
        .from('v_catalog_lenses')
        .select('*')
        .eq('id', params.id)
        .maybeSingle();

    if (lensErr || !row) {
        throw error(404, lensErr?.message ?? 'Lente não encontrada');
    }
    const lente = row as unknown as VCatalogLens;

    // 2) Mapping N:1
    const { data: mapRow, error: mapErr } = await supabase
        .from('v_canonical_lens_mapping')
        .select('lens_id, canonical_lens_id, is_preferred, confidence_score, match_method, is_premium')
        .eq('lens_id', params.id)
        .maybeSingle();

    if (mapErr) console.error('[lentes/[id]] mapping error:', mapErr);

    const mapping = (mapRow ?? null) as VCanonicalLensMapping | null;

    // 3) Conceito canônico
    let conceito: ConceitoLente | null = null;
    if (mapping) {
        if (mapping.is_premium) {
            const { data: c, error: cErr } = await supabase
                .from('v_canonical_premium')
                .select('*')
                .eq('id', mapping.canonical_lens_id)
                .maybeSingle();
            if (cErr) console.error('[lentes/[id]] canonical_premium error:', cErr);
            if (c) conceito = { kind: 'premium', ...(c as unknown as CanonicalPremiumV3) };
        } else {
            const { data: c, error: cErr } = await supabase
                .from('v_canonical_standard')
                .select('*')
                .eq('id', mapping.canonical_lens_id)
                .maybeSingle();
            if (cErr) console.error('[lentes/[id]] canonical_standard error:', cErr);
            if (c) conceito = { kind: 'standard', ...(c as unknown as CanonicalStandardV3) };
        }
    }

    // 4) Opções de edição
    const { data: optsRaw, error: optsErr } = await supabase.rpc('rpc_lens_edit_options');
    if (optsErr) console.error('[lentes/[id]] edit_options error:', optsErr);
    const editOptions: LensEditOptions = (optsRaw ?? {
        brands: [], materials: [], suppliers: [], treatments: [],
        lens_types: [], statuses: [],
    }) as LensEditOptions;

    return {
        lente,
        conceito,
        mapping,
        editOptions,
        isPremium: lente.is_premium ?? false,
    };
};
