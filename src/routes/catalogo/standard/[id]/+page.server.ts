/**
 * 📚 Detalhes Grupo Canônico Standard - Server Load
 * NOVO BANCO: v_canonical_lenses + v_canonical_lens_options
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';
import { error } from '@sveltejs/kit';
import type { VCanonicalLens, VCanonicalLensOption } from '$lib/types/database-views';

export const load: PageServerLoad = async ({ params }) => {
  const grupoId = params.id;

  if (!grupoId) {
    throw error(400, 'ID do grupo não encontrado');
  }

  try {
    console.log('🔍 [Motor Oracle] Buscando conceito standard:', grupoId);

    // Buscar o conceito canônico
    const { data: grupo, error: erroGrupo } = await supabase
      .from('v_canonical_lenses')
      .select('*')
      .eq('canonical_lens_id', grupoId)
      .single();

    if (erroGrupo || !grupo) {
      console.error('❌ Erro ao buscar conceito:', erroGrupo);
      throw error(404, 'Conceito ótico não encontrado');
    }

    // Buscar as lentes reais mapeadas para este conceito
    console.log('🔍 [Motor Oracle] Buscando opções reais para o conceito:', grupoId);
    const { data: options, error: erroOptions } = await supabase
      .from('v_canonical_lens_options')
      .select('*')
      .eq('canonical_lens_id', grupoId)
      .order('final_price', { ascending: true });

    if (erroOptions) {
      console.error('❌ Erro ao buscar opções:', erroOptions);
      throw error(500, `Erro ao carregar opções de lentes: ${erroOptions.message}`);
    }

    // Adaptar para o formato que o componente LenteCard espera se necessário
    const mappedLentes = (options || []).map(opt => ({
      ...opt,
      id: opt.lens_id,
      price_suggested: opt.final_price,
      lens_name: opt.lens_name,
      brand_name: opt.brand_name,
      supplier_name: opt.supplier_name
    }));

    return {
      grupo: {
        ...grupo,
        id: grupo.canonical_lens_id,
        name: grupo.canonical_name
      },
      lentes: mappedLentes,
      sucesso: true
    };
  } catch (err) {
    console.error('❌ Erro fatal no load standard:', err);
    throw error(500, 'Erro interno ao carregar detalhes do conceito');
  }
};
