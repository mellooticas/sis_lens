/**
 * ⚖️ Comparar Lentes - Server Load
 * Permite comparação lado a lado de lentes
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';

export const load: PageServerLoad = async ({ url }) => {
  try {
    // IDs das lentes a comparar (máximo 3)
    const lente1 = url.searchParams.get('lente1');
    const lente2 = url.searchParams.get('lente2');
    const lente3 = url.searchParams.get('lente3');
    
    const lenteIds = [lente1, lente2, lente3].filter(Boolean);
    
    console.log('⚖️ Comparação: Carregando lentes:', lenteIds);

    let lentesComparacao: any[] = [];
    
    if (lenteIds.length > 0) {
      // Buscar dados das lentes selecionadas
      const { data: lentes, error } = await supabase
        .from('lentes_catalogo')
        .select(`
          id,
          sku_canonico,
          familia,
          design,
          material,
          indice_refracao,
          tipo_lente,
          marca_nome,
          descricao_completa,
          tratamentos,
          preco_base,
          disponibilidade
        `)
        .in('id', lenteIds);

      if (error) {
        console.error('❌ Erro ao buscar lentes para comparação:', error);
      } else {
        lentesComparacao = lentes || [];
      }
    }

    // Buscar lentes populares para sugestões
    const { data: sugestoes } = await supabase
      .from('lentes_catalogo')
      .select(`
        id,
        familia,
        marca_nome,
        tipo_lente,
        preco_base
      `)
      .order('familia')
      .limit(20);

    return {
      lentes_comparacao: lentesComparacao,
      lentes_sugeridas: sugestoes || [],
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