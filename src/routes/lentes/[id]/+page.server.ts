/**
 * Página de Detalhes da Lente - Server Load
 * Carrega: lente completa (v_lentes) + grupo canônico (v_grupos_canonicos) + alternativas do grupo
 */
import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';
import { supabase } from '$lib/supabase';
import type { VLente, VGrupoCanonicos } from '$lib/types/database-views';

export const load: PageServerLoad = async ({ params }) => {
  const { id } = params;

  try {
    // 1. Buscar dados completos da lente
    const { data: lente, error: lenteError } = await supabase
      .from('v_lentes')
      .select('*')
      .eq('id', id)
      .single();

    if (lenteError || !lente) {
      throw error(404, 'Lente não encontrada');
    }

    // 2. Buscar grupo canônico (se existir)
    let grupoCanonicos: VGrupoCanonicos | null = null;
    if (lente.grupo_canonico_id) {
      const { data: grupo, error: grupoError } = await supabase
        .from('v_grupos_canonicos')
        .select('*')
        .eq('id', lente.grupo_canonico_id)
        .single();

      if (!grupoError && grupo) {
        grupoCanonicos = grupo as VGrupoCanonicos;
      }
    }

    // 3. Buscar lentes alternativas do mesmo grupo canônico
    let alternativas: VLente[] = [];
    if (lente.grupo_canonico_id) {
      const { data: alt, error: altError } = await supabase
        .from('v_lentes')
        .select('*')
        .eq('grupo_canonico_id', lente.grupo_canonico_id)
        .neq('id', id) // Excluir a lente atual
        .order('preco_venda_sugerido', { ascending: true })
        .limit(10);

      if (!altError && alt) {
        alternativas = alt as VLente[];
      }
    }

    return {
      lente: lente as VLente,
      grupoCanonicos,
      alternativas
    };
  } catch (err) {
    console.error('Erro ao carregar detalhes da lente:', err);
    throw error(500, 'Erro ao carregar dados da lente');
  }
};
