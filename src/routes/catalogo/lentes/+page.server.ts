/**
 * Catálogo de Lentes Reais — Server Load
 * Fonte: public.v_catalog_lenses (tenant-filtered via current_tenant_id())
 * 3.698 lentes ativas | tenant 00000000-0000-0000-0000-000000000000
 *
 * Filtros via URL params:
 *   tipo       → lens_type (single_vision | multifocal | bifocal | occupational)
 *   fornecedor → supplier_id (UUID de sales_finance.suppliers)
 *   material   → material_id (UUID de catalog_lenses.lens_materials)
 *   premium    → is_premium (true | false)
 *   ar         → anti_reflective = true
 *   blue       → blue_light = true
 *   pagina     → página atual (default 1)
 */
import type { PageServerLoad } from './$types';
import { error }               from '@sveltejs/kit';
import type { VCatalogLens }   from '$lib/types/database-views';

const LIMITE = 24;

export interface FiltrosLentes {
    lens_type:   string | null;
    supplier_id: string | null;
    material_id: string | null;
    is_premium:  boolean | null;
    has_ar:      boolean;
    has_blue:    boolean;
}

export interface FornecedorOption { id: string; name: string; }
export interface MaterialOption   { id: string; name: string; refractive_index: number | null; }

export const load: PageServerLoad = async ({ locals, url }) => {
    const { supabase } = locals;

    // ── 1. Parse URL params ────────────────────────────────────────────────
    const lens_type    = url.searchParams.get('tipo')       || null;
    const supplier_id  = url.searchParams.get('fornecedor') || null;
    const material_id  = url.searchParams.get('material')   || null;
    const premiumParam = url.searchParams.get('premium');
    const is_premium   = premiumParam === 'true'  ? true
                       : premiumParam === 'false' ? false
                       : null;
    const has_ar   = url.searchParams.get('ar')   === '1';
    const has_blue = url.searchParams.get('blue') === '1';
    const pagina   = Math.max(1, parseInt(url.searchParams.get('pagina') || '1'));
    const offset   = (pagina - 1) * LIMITE;

    try {
        // ── 2. Opções de filtro (supplier + material) via query leve ───────
        // v_catalog_suppliers_labs está vazia; pegamos direto da view principal
        const { data: opcoesRaw } = await supabase
            .from('v_catalog_lenses')
            .select('supplier_id, supplier_name, material_id, material_name, refractive_index')
            .eq('status', 'active');

        const suppMap = new Map<string, string>();
        const matMap  = new Map<string, { name: string; refractive_index: number | null }>();

        for (const l of opcoesRaw || []) {
            if (l.supplier_id && l.supplier_name)
                suppMap.set(l.supplier_id, l.supplier_name);
            if (l.material_id && l.material_name && !matMap.has(l.material_id))
                matMap.set(l.material_id, { name: l.material_name, refractive_index: l.refractive_index ?? null });
        }

        const fornecedores: FornecedorOption[] = [...suppMap.entries()]
            .map(([id, name]) => ({ id, name }))
            .sort((a, b) => a.name.localeCompare(b.name, 'pt-BR'));

        const materiais: MaterialOption[] = [...matMap.entries()]
            .map(([id, m]) => ({ id, ...m }))
            .sort((a, b) => (a.refractive_index ?? 0) - (b.refractive_index ?? 0));

        // ── 3. Query principal: lentes filtradas + paginação ───────────────
        let query = supabase
            .from('v_catalog_lenses')
            .select('*', { count: 'exact' })
            .eq('status', 'active');

        if (lens_type)           query = query.eq('lens_type',      lens_type);
        if (supplier_id)         query = query.eq('supplier_id',    supplier_id);
        if (material_id)         query = query.eq('material_id',    material_id);
        if (is_premium !== null) query = query.eq('is_premium',     is_premium);
        if (has_ar)              query = query.eq('anti_reflective', true);
        if (has_blue)            query = query.eq('blue_light',      true);

        const { data: lentes, count, error: errLentes } = await query
            .order('supplier_name', { ascending: true, nullsFirst: false })
            .order('material_name', { ascending: true, nullsFirst: false })
            .order('lens_name',     { ascending: true })
            .range(offset, offset + LIMITE - 1);

        if (errLentes) {
            console.error('❌ Erro ao carregar lentes:', errLentes);
            throw error(500, 'Erro ao carregar catálogo de lentes');
        }

        const total         = count ?? 0;
        const total_paginas = Math.ceil(total / LIMITE);

        return {
            lentes:       (lentes || []) as VCatalogLens[],
            total,
            pagina,
            total_paginas,
            fornecedores,
            materiais,
            filtros: {
                lens_type, supplier_id, material_id, is_premium, has_ar, has_blue,
            } satisfies FiltrosLentes,
        };

    } catch (err: unknown) {
        if (err && typeof err === 'object' && 'status' in err) throw err;
        console.error('❌ Erro fatal no load de lentes:', err);
        throw error(500, 'Erro interno ao carregar lentes');
    }
};
