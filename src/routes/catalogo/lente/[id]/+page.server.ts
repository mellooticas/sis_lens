/**
 * 🔍 Detalhes Lente Real - Server Load
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';
import { error } from '@sveltejs/kit';
import type { VCatalogLens } from '$lib/types/database-views';

export const load: PageServerLoad = async ({ params }) => {
  const lensId = params.id;

  if (!lensId) {
    throw error(400, 'ID da lente não encontrado');
  }

  try {
    console.log('🔍 Buscando detalhes da lente real:', lensId);

    // 1) Buscar a lente completa
    const { data: lente, error: erroLente } = await supabase
      .from('v_catalog_lenses')
      .select('*')
      .eq('id', lensId)
      .single();

    if (erroLente || !lente) {
      console.error('❌ Erro ao buscar lente:', erroLente);
      throw error(404, 'Lente não encontrada no catálogo');
    }

    // 2) Buscar alternativas via RPC
    const { data: alternativas, error: erroAlts } = await supabase
      .rpc('rpc_lens_get_alternatives', {
        p_lens_id: lensId,
        p_limit: 4
      });

    // 3) Buscar mapeamento canônico se existir
    const { data: mapping } = await supabase
      .from('v_canonical_lens_options')
      .select('canonical_lens_id, canonical_name, confidence_score, match_method')
      .eq('lens_id', lensId)
      .maybeSingle();

    return {
      lente: lente as VCatalogLens,
      alternativas: alternativas || [],
      mapping: mapping || null,
      sucesso: true
    };
  } catch (err) {
    console.error('❌ Erro ao carregar detalhes da lente:', err);
    throw error(500, 'Erro interno ao carregar detalhes da lente');
  }
};
