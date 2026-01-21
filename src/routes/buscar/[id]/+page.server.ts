/**
 * Página de Detalhes da Lente - Server Load
 * Busca dados completos da view v_lentes
 */
import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';
import { supabase } from '$lib/supabase';
import type { VLente } from '$lib/types/database-views';

export const load: PageServerLoad = async ({ params }) => {
  const { id } = params;

  try {
    // Buscar lente completa da view v_lentes
    const { data: lente, error: lenteError } = await supabase
      .from('v_lentes')
      .select('*')
      .eq('id', id)
      .single();

    if (lenteError || !lente) {
      console.error('Erro ao buscar lente:', lenteError);
      throw error(404, 'Lente não encontrada');
    }

    // Debug: Verificar campos importantes
    console.log('🔍 Lente carregada:', {
      id: lente.id,
      nome: lente.nome_lente,
      diametro: lente.diametro,
      espessura_central: lente.espessura_central,
      peso: lente.peso,
      grau_esferico_min: lente.grau_esferico_min,
      grau_esferico_max: lente.grau_esferico_max,
      grau_cilindrico_min: lente.grau_cilindrico_min,
      grau_cilindrico_max: lente.grau_cilindrico_max,
      adicao_min: lente.adicao_min,
      adicao_max: lente.adicao_max
    });

    return {
      lente: lente as VLente
    };
  } catch (err) {
    console.error('Erro ao carregar detalhes da lente:', err);
    if (err instanceof Error && 'status' in err) {
      throw err; // Re-throw SvelteKit errors
    }
    throw error(500, 'Erro ao carregar dados da lente');
  }
};
