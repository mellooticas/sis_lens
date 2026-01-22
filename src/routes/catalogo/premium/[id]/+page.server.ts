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
    console.log('🔍 Buscando grupo premium:', grupoId);
    
    // Buscar grupo específico com validação is_premium = true
    const { data: grupo, error: erroGrupo } = await supabase
      .from('v_grupos_canonicos')
      .select('*')
      .eq('id', grupoId)
      .eq('is_premium', true)
      .single();

    if (erroGrupo) {
      console.error('❌ Erro Supabase ao buscar grupo:', erroGrupo);
      throw error(404, `Grupo premium não encontrado: ${erroGrupo.message}`);
    }
    
    if (!grupo) {
      console.error('❌ Grupo não retornado');
      throw error(404, 'Grupo premium não encontrado');
    }
    
    console.log('✅ Grupo encontrado:', grupo.nome_grupo);

    // Buscar lentes do grupo
    console.log('🔍 Buscando lentes do grupo:', grupoId);
    const { data: lentes, error: erroLentes } = await supabase
      .from('v_lentes')
      .select(`
        id,
        slug,
        nome_lente,
        nome_comercial,
        fornecedor_nome,
        marca_nome,
        marca_slug,
        marca_premium,
        grupo_nome,
        grupo_slug,
        tipo_lente,
        categoria,
        material,
        indice_refracao,
        linha_produto,
        diametro,
        espessura_central,
        peso,
        grau_esferico_min,
        grau_esferico_max,
        grau_cilindrico_min,
        grau_cilindrico_max,
        adicao_min,
        adicao_max,
        tem_ar,
        tem_antirrisco,
        tem_blue,
        tem_uv,
        tratamento_foto,
        tem_polarizado,
        tem_hidrofobico,
        preco_custo,
        preco_venda_sugerido,
        preco_fabricante,
        prazo_dias,
        ativo,
        destaque
      `)
      .eq('grupo_canonico_id', grupoId)
      .eq('ativo', true)
      .order('preco_venda_sugerido', { ascending: true });

    if (erroLentes) {
      console.error('❌ Erro Supabase ao buscar lentes:', {
        message: erroLentes.message,
        details: erroLentes.details,
        hint: erroLentes.hint,
        code: erroLentes.code
      });
      throw error(500, `Erro ao buscar lentes: ${erroLentes.message}`);
    }
    
    console.log('✅ Lentes carregadas:', lentes?.length || 0);

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
