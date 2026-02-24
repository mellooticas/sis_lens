/**
 * 📚 Catálogo Standard — Server Load
 * Usa v_canonical_lenses (migration 212) filtrado por is_premium = false.
 * NOTA: Esta página é client-driven (useBuscarLentes hook).
 *       O server load provê dados para SSR e SEO apenas.
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
    const { supabase } = locals;

    try {
        const busca      = url.searchParams.get('busca')      || '';
        const tipo_lente = url.searchParams.get('tipo_lente') || '';
        const material   = url.searchParams.get('material')   || '';
        const pagina     = parseInt(url.searchParams.get('pagina') || '1');
        const limite     = 20;
        const offset     = (pagina - 1) * limite;

        // Buscar conceitos canônicos STANDARD via v_canonical_lenses (migration 212)
        let query = supabase
            .from('v_canonical_lenses')
            .select('*', { count: 'exact' })
            .eq('is_premium', false);

        if (busca)      query = query.ilike('canonical_name', `%${busca}%`);
        if (tipo_lente) query = query.eq('lens_type', tipo_lente);
        if (material)   query = query.eq('material', material);

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
            filtros: { busca, tipo_lente, material },
            sucesso: true
        };
    } catch (err) {
        console.error('❌ Erro ao carregar catálogo standard:', err);
        return {
            canonicais: [],
            total_resultados: 0,
            pagina_atual: 1,
            total_paginas: 0,
            has_more: false,
            filtros: { busca: '', tipo_lente: '', material: '' },
            sucesso: false,
            erro: 'Erro ao carregar catálogo standard'
        };
    }
};
