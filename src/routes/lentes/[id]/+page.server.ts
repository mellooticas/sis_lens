/**
 * Página de Detalhes da Lente - Server Load
 * Novo banco: v_catalog_lenses + v_catalog_lens_groups + alternativas do mesmo grupo
 */
import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';
import { supabase } from '$lib/supabase';
import type { VCatalogLens, VCatalogLensGroup } from '$lib/types/database-views';

export const load: PageServerLoad = async ({ params }) => {
  const { id } = params;

  try {
    // 1. Buscar dados completos da lente
    const { data: lente, error: lenteError } = await supabase
      .from('v_catalog_lenses')
      .select('*')
      .eq('id', id)
      .single();

    if (lenteError || !lente) {
      throw error(404, 'Lente não encontrada');
    }

    const lenteTyped = lente as VCatalogLens;

    // 2. Buscar grupo canônico (se existir)
    let grupoCanonicos: VCatalogLensGroup | null = null;
    if (lenteTyped.group_id) {
      const { data: grupo, error: grupoError } = await supabase
        .from('v_catalog_lens_groups')
        .select('*')
        .eq('id', lenteTyped.group_id)
        .single();

      if (!grupoError && grupo) {
        grupoCanonicos = grupo as VCatalogLensGroup;
      }
    }

    // 3. Buscar lentes alternativas do mesmo grupo canônico
    let alternativas: VCatalogLens[] = [];
    if (lenteTyped.group_id) {
      const { data: alt, error: altError } = await supabase
        .from('v_catalog_lenses')
        .select('id, slug, lens_name, brand_name, supplier_name, price_suggested, lead_time_days, is_premium, lens_type, material, refractive_index, status')
        .eq('group_id', lenteTyped.group_id)
        .neq('id', id)
        .order('price_suggested', { ascending: true })
        .limit(10);

      if (!altError && alt) {
        alternativas = alt as VCatalogLens[];
      }
    }

    return {
      lente: lenteTyped,
      grupoCanonicos,
      alternativas
    };
  } catch (err) {
    console.error('Erro ao carregar detalhes da lente:', err);
    throw error(500, 'Erro ao carregar dados da lente');
  }
};
