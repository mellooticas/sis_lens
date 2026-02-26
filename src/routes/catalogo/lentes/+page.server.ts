/**
 * Catálogo de Lentes Individuais — Server Load
 * Todas as lentes ativas do tenant ordenadas por fornecedor → marca → nome.
 * Sem filtros. Usa v_catalog_lenses (tenant-filtered pelo JWT).
 */
import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';
import type { VCatalogLens } from '$lib/types/database-views';

export const load: PageServerLoad = async ({ locals }) => {
    const { supabase } = locals;

    try {
        const { data, error: err } = await supabase
            .from('v_catalog_lenses')
            .select('*')
            .eq('status', 'active')
            .order('supplier_name', { ascending: true, nullsFirst: false })
            .order('brand_name',    { ascending: true, nullsFirst: false })
            .order('lens_name',     { ascending: true });

        if (err) {
            console.error('❌ Erro ao carregar lentes:', err);
            throw error(500, 'Erro ao carregar catálogo de lentes');
        }

        const lentes = (data || []) as VCatalogLens[];

        return { lentes, total: lentes.length };
    } catch (err: any) {
        if (err.status) throw err;
        throw error(500, 'Erro interno ao carregar lentes');
    }
};
