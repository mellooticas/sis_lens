/**
 * 🏆 Detalhes Grupo Canônico Premium - Server Load
 * Carrega dados do grupo com validação de is_premium = true
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params }) => {
  const grupoId = params.id;

  if (!grupoId) {
    throw error(400, 'ID do grupo não encontrado');
  }

  try {
    // Buscar grupo específico com validação is_premium = true
    const { data: grupo, error: erroGrupo } = await supabase
      .from('v_grupos_canonicos')
      .select('*')
      .eq('id', grupoId)
      .eq('is_premium', true)
      .single();

    if (erroGrupo || !grupo) {
      throw error(404, 'Grupo premium não encontrado');
    }

    // Buscar lentes do grupo
    const { data: lentes, error: erroLentes } = await supabase
      .from('v_lentes')
      .select('*')
      .eq('grupo_id', grupoId)
      .eq('ativo', true)
      .order('preco_venda_sugerido', { ascending: true });

    if (erroLentes) {
      throw error(500, 'Erro ao buscar lentes do grupo');
    }

    console.log('✅ Grupo Premium carregado:', {
      grupoId,
      nome: grupo.nome_grupo,
      total_lentes: lentes?.length || 0
    });

    return {
      grupo,
      lentes: lentes || [],
      sucesso: true
    };
  } catch (err) {
    console.error('❌ Erro ao carregar grupo premium:', err);
    throw error(500, 'Erro ao carregar detalhes do grupo');
  }
};
