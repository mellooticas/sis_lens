/**
 * 🔄 Comparar Labs - Server Load
 * Mostra produtos disponíveis em múltiplos labs
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';

const TENANT_ID = 'cd311ba0-9e20-46c4-a65f-9b48fb4b36ec';

export const load: PageServerLoad = async ({ url }) => {
  try {
    const min_labs = parseInt(url.searchParams.get('min_labs') || '2');
    const tipo = url.searchParams.get('tipo') || ''; // PREMIUM ou GENÉRICA

    console.log('🔄 Comparar: Carregando produtos multi-lab');

    // 1. Buscar produtos disponíveis em múltiplos labs (vw_comparar_labs)
    let query = supabase
      .from('vw_comparar_labs')
      .select('*')
      .eq('tenant_id', TENANT_ID)
      .gte('qtd_labs', min_labs);

    if (tipo) {
      query = query.eq('tipo', tipo);
    }

    query = query.order('qtd_labs', { ascending: false });

    const { data: produtos, error } = await query;

    if (error) {
      console.error('❌ Erro ao buscar produtos para comparação:', error);
      throw error;
    }

    // 2. Estatísticas
    const totalPremium = produtos?.filter(p => p.tipo === 'PREMIUM').length || 0;
    const totalGenerica = produtos?.filter(p => p.tipo === 'GENÉRICA').length || 0;
    const maxLabs = produtos?.length > 0 
      ? Math.max(...produtos.map(p => p.qtd_labs)) 
      : 0;

    return {
      produtos: produtos || [],
      total: produtos?.length || 0,
      
      filtros: {
        min_labs,
        tipo,
        opcoes: {
          min_labs: [
            { value: '2', label: '2+ Labs' },
            { value: '3', label: '3+ Labs' },
            { value: '4', label: '4+ Labs' },
            { value: '5', label: '5+ Labs' }
          ],
          tipos: [
            { value: '', label: 'Todos' },
            { value: 'PREMIUM', label: 'Premium' },
            { value: 'GENÉRICA', label: 'Genérica' }
          ]
        }
      },
      
      estatisticas: {
        total_produtos: produtos?.length || 0,
        total_premium: totalPremium,
        total_generica: totalGenerica,
        max_labs_por_produto: maxLabs
      },
      
      sucesso: true
    };
  } catch (error) {
    console.error('❌ Erro ao carregar comparação:', error);
    return {
      produtos: [],
      total: 0,
      filtros: {
        min_labs: 2,
        tipo: '',
        opcoes: { min_labs: [], tipos: [] }
      },
      estatisticas: {
        total_produtos: 0,
        total_premium: 0,
        total_generica: 0,
        max_labs_por_produto: 0
      },
      sucesso: false,
      erro: 'Erro ao carregar comparação de labs'
    };
  }
};
