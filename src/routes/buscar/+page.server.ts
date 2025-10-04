/**
 * Página de Busca de Lentes - Server Load e Actions
 * Integrado com RPCs reais do banco: rpc_buscar_lente
 */

import { error, fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';
import { supabase } from '$lib/supabase';

// ============================================================================
// LOAD - Dados Iniciais
// ============================================================================
export const load: PageServerLoad = async ({ url }) => {
  // Parâmetros de busca da URL
  const query = url.searchParams.get('q') || '';
  const categoria = url.searchParams.get('categoria') || '';
  const material = url.searchParams.get('material') || '';
  const preco_min = parseFloat(url.searchParams.get('preco_min') || '0');
  const preco_max = parseFloat(url.searchParams.get('preco_max') || '999999');

  try {
    // 1. Estatísticas gerais (sempre carregar)
    const { data: stats, error: statsError } = await supabase
      .rpc('get_busca_stats');

    if (statsError) {
      console.error('Erro ao buscar estatísticas:', statsError);
    }

    // 2. Se tem query, buscar lentes via RPC
    let lentesData: any[] = [];
    let totalLentes = 0;

    if (query.trim()) {
      const { data: lentes, error: lentesError } = await supabase
        .rpc('rpc_buscar_lente', {
          p_query: query,
          p_limit: 50
        });

      if (lentesError) {
        console.error('Erro ao buscar lentes:', lentesError);
        throw error(500, 'Erro ao buscar lentes');
      }

      lentesData = lentes || [];
      totalLentes = lentesData.length;
      
      // NOTA: Filtros avançados serão aplicados na v2
      // Por enquanto, apenas busca textual funciona
    }

    // 3. Buscar fornecedores para estatísticas
    const { data: fornecedores, error: fornError } = await supabase
      .from('vw_fornecedores')
      .select('*')
      .eq('ativo', true);

    if (fornError) {
      console.error('Erro ao buscar fornecedores:', fornError);
    }

    return {
      lentes: lentesData,
      fornecedores: fornecedores || [],
      estatisticas: {
        total_lentes: stats?.total_lentes || 0,
        total_fornecedores: fornecedores?.length || 0,
        preco_medio: stats?.preco_medio || 0
      },
      filtros_ativos: {
        query,
        categoria,
        material,
        preco_min,
        preco_max
      },
      total_resultados: totalLentes
    };
  } catch (err) {
    console.error('Erro crítico no load:', err);
    throw error(500, 'Erro ao carregar dados da busca');
  }
};

// ============================================================================
// ACTIONS - Formulário de Busca
// ============================================================================
export const actions: Actions = {
  buscar: async ({ request }) => {
    const formData = await request.formData();
    
    const query = formData.get('query')?.toString().trim() || '';
    const categoria = formData.get('categoria')?.toString() || '';
    const material = formData.get('material')?.toString() || '';
    const preco_min = parseFloat(formData.get('preco_min')?.toString() || '0');
    const preco_max = parseFloat(formData.get('preco_max')?.toString() || '999999');

    // Validação
    if (!query) {
      return fail(400, {
        erro: 'Digite um termo de busca',
        valores: { query, categoria, material, preco_min, preco_max }
      });
    }

    if (query.length < 2) {
      return fail(400, {
        erro: 'A busca deve ter pelo menos 2 caracteres',
        valores: { query, categoria, material, preco_min, preco_max }
      });
    }

    try {
      // Chamar RPC de busca
      const { data: lentes, error: searchError } = await supabase
        .rpc('rpc_buscar_lente', {
          p_query: query,
          p_limit: 50
        });

      if (searchError) {
        console.error('Erro no RPC buscar_lente:', searchError);
        return fail(500, {
          erro: 'Erro ao realizar busca',
          valores: { query, categoria, material, preco_min, preco_max }
        });
      }

      const resultados = lentes || [];

      return {
        sucesso: true,
        lentes: resultados,
        total: resultados.length,
        mensagem: `${resultados.length} lentes encontradas`
      };
    } catch (err) {
      console.error('Erro na action buscar:', err);
      return fail(500, {
        erro: 'Erro interno do servidor',
        valores: { query, categoria, material, preco_min, preco_max }
      });
    }
  }
};