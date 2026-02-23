/**
 * 🔍 Detalhes Lente Real - Server Load
 */
import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';
import type { VCatalogLens } from '$lib/types/database-views';

export const load: PageServerLoad = async ({ params, locals }) => {
  const lensId = params.id;
  const { supabase } = locals;

  if (!lensId) {
    throw error(400, 'ID da lente não encontrado');
  }

  // 1) Buscar a lente completa
  const { data: lente, error: erroLente } = await supabase
    .from('v_catalog_lenses')
    .select('*')
    .eq('id', lensId)
    .single();

  if (erroLente || !lente) {
    console.error('❌ [Catálogo] Erro ao buscar lente:', erroLente);
    throw error(erroLente?.code === 'PGRST116' ? 404 : 500, 
      erroLente?.message || 'Lente não encontrada no catálogo');
  }

  // 2) Buscar alternativas via RPC
  const { data: alternativas, error: erroAlts } = await supabase
    .rpc('rpc_lens_get_alternatives', {
      p_lens_id: lensId,
      p_limit: 4
    });

  if (erroAlts) {
    console.warn('⚠️ [Catálogo] Erro ao buscar alternativas:', erroAlts);
    // Não paramos o carregamento por erro em alternativas
  }

  // 3) Buscar mapeamento canônico se existir
  const { data: mapping, error: erroMapping } = await supabase
    .from('v_canonical_lens_options')
    .select('canonical_lens_id, canonical_name, confidence_score, match_method')
    .eq('lens_id', lensId)
    .maybeSingle();

  if (erroMapping) {
    console.warn('⚠️ [Catálogo] Erro ao buscar mapeamento canônico:', erroMapping);
  }

  return {
    lente: lente as VCatalogLens,
    alternativas: alternativas || [],
    mapping: mapping || null,
    sucesso: true
  };
};
