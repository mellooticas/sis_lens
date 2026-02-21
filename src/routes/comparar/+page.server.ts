/**
 * ⚖️ Comparar Lentes - Server Load
 * Novo banco: v_catalog_lenses
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';
import type { VCatalogLens } from '$lib/types/database-views';

export const load: PageServerLoad = async ({ url }) => {
  try {
    // IDs das lentes a comparar (máximo 3)
    const lente1 = url.searchParams.get('lente1');
    const lente2 = url.searchParams.get('lente2');
    const lente3 = url.searchParams.get('lente3');

    const lenteIds = [lente1, lente2, lente3].filter(Boolean) as string[];

    console.log('⚖️ Comparação: Carregando lentes:', lenteIds);

    let lentesComparacao: VCatalogLens[] = [];

    if (lenteIds.length > 0) {
      const { data: lentes, error } = await supabase
        .from('v_catalog_lenses')
        .select(`
          id, slug, lens_name, brand_name, supplier_name, supplier_lab_id,
          lens_type, material, refractive_index, category,
          anti_reflective, anti_scratch, uv_filter, blue_light, photochromic, polarized,
          digital, free_form, indoor, drive,
          spherical_min, spherical_max, cylindrical_min, cylindrical_max,
          addition_min, addition_max,
          price_cost, price_suggested,
          stock_available, lead_time_days,
          is_premium, status, group_id, group_name
        `)
        .in('id', lenteIds);

      if (error) {
        console.error('❌ Erro ao buscar lentes para comparação:', error);
      } else {
        lentesComparacao = (lentes || []) as VCatalogLens[];
      }
    }

    // Buscar lentes populares para sugestões
    const { data: sugestoes } = await supabase
      .from('v_catalog_lenses')
      .select('id, slug, lens_name, brand_name, lens_type, price_suggested, is_premium')
      .eq('status', 'active')
      .order('lens_name')
      .limit(20);

    return {
      lentes_comparacao: lentesComparacao,
      lentes_sugeridas: (sugestoes || []) as VCatalogLens[],
      total_selecionadas: lenteIds.length,
      max_comparacao: 3,
      sucesso: true,
      erro: null
    };
  } catch (error) {
    console.error('❌ Erro ao carregar página de comparação:', error);
    return {
      lentes_comparacao: [],
      lentes_sugeridas: [],
      total_selecionadas: 0,
      max_comparacao: 3,
      sucesso: false,
      erro: 'Erro ao carregar dados para comparação'
    };
  }
};
