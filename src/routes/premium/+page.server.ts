/**
 * 🏆 Catálogo Premium — Server Load
 * Canonical Engine v2: usa v_canonical_lenses_premium_pricing (migration 277).
 * Conceitos premium com SKU CPR, pricing agregado, sem categoria no fingerprint.
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
    const { supabase } = locals;

    try {
        const busca          = url.searchParams.get('busca')      || '';
        const tipo_lente     = url.searchParams.get('tipo_lente') || '';
        const material_class = url.searchParams.get('material')   || '';
        const pagina         = parseInt(url.searchParams.get('pagina') || '1');
        const limite         = 24;
        const offset         = (pagina - 1) * limite;

        // v_canonical_lenses_premium_pricing: conceitos premium + pricing_book
        let query = supabase
            .from('v_canonical_lenses_premium_pricing')
            .select('*', { count: 'exact' });

        if (busca)           query = query.ilike('canonical_name', `%${busca}%`);
        if (tipo_lente)      query = query.eq('lens_type', tipo_lente);
        if (material_class)  query = query.eq('material_class', material_class);

        const { data: canonicais, count, error } = await query
            .order('canonical_name', { ascending: true })
            .range(offset, offset + limite - 1);

        if (error) throw error;

        const totalPaginas = Math.ceil((count || 0) / limite);

        return {
            canonicais: canonicais || [],
            total_resultados: count || 0,
            pagina_atual: pagina,
            total_paginas: totalPaginas,
            has_more: pagina < totalPaginas,
            filtros: { busca, tipo_lente, material_class },
            sucesso: true
        };
    } catch (err) {
        console.error('❌ Erro ao carregar catálogo premium (v2):', err);
        return {
            canonicais: [],
            total_resultados: 0,
            pagina_atual: 1,
            total_paginas: 0,
            has_more: false,
            filtros: { busca: '', tipo_lente: '', material_class: '' },
            sucesso: false,
            erro: 'Erro ao carregar catálogo premium'
        };
    }
};
