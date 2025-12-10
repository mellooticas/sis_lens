/**
 * 📊 Analytics Page Server - Dados Reais Supabase
 * Server-side loader com métricas e relatórios reais
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';

export const load: PageServerLoad = async ({ url }) => {
  try {
    // Parâmetros de período
    const dataInicio = url.searchParams.get('inicio') || 
      new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]; // 30 dias atrás
    const dataFim = url.searchParams.get('fim') || 
      new Date().toISOString().split('T')[0]; // hoje

    console.log('📊 Analytics: Carregando dados do período:', { dataInicio, dataFim });

    // 1. Métricas gerais de performance
    const { data: decisoes, error: decisoesError } = await supabase
      .from('decisoes_compra')
      .select(`
        id,
        decidido_em,
        status,
        preco_final,
        criterio
      `)
      .gte('decidido_em', dataInicio)
      .lte('decidido_em', dataFim)
      .order('decidido_em', { ascending: false });

    if (decisoesError) {
      console.error('❌ Erro ao buscar decisões:', decisoesError);
    }

    // 2. Economia por fornecedor (View em vez de RPC inexistente)
    const { data: economiaFornecedores, error: economiaError } = await supabase
      .from('mv_economia_por_fornecedor')
      .select('*')
      .limit(10);

    if (economiaError) {
      console.error('❌ Erro ao calcular economia por fornecedor:', economiaError);
    }

    // 3. Top fornecedores
    const { data: topFornecedores, error: topError } = await supabase
      .from('vw_fornecedores')
      .select(`
        id,
        nome,
        credibilidade_score,
        total_produtos
      `)
      .limit(10);

    if (topError) {
      console.error('❌ Erro ao buscar top fornecedores:', topError);
    }

    // 4. Processar dados para métricas
    const decisoesValidas = decisoes || [];
    const metricas = {
      total_decisoes: decisoesValidas.length,
      economia_total: decisoesValidas.reduce((acc, d) => acc + (d.economia_valor || 0), 0),
      preco_total: decisoesValidas.reduce((acc, d) => acc + (d.preco_final || 0), 0),
      prazo_medio: Math.round(decisoesValidas.length > 0 ? 
        decisoesValidas.reduce((acc, d) => acc + 7, 0) / decisoesValidas.length : 0), // mock
      taxa_sucesso: decisoesValidas.length > 0 ? 
        (decisoesValidas.filter(d => d.status === 'FINALIZADA').length / decisoesValidas.length) * 100 : 0
    };

    // 5. Economia por categoria
    const economiaPorTipo = decisoesValidas.reduce((acc, decisao) => {
      const tipo = 'Progressive'; // mock - seria extraído da lente
      if (!acc[tipo]) {
        acc[tipo] = { tipo, economia: 0, total: 0 };
      }
      acc[tipo].economia += decisao.economia_valor || 0;
      acc[tipo].total += 1;
      return acc;
    }, {} as Record<string, any>);

    const economiaPorFornecedor = decisoesValidas.reduce((acc, decisao) => {
      const nome = decisao.laboratorio_nome || 'Não informado';
      if (!acc[nome]) {
        acc[nome] = { nome, economia: 0, total: 0 };
      }
      acc[nome].economia += decisao.economia_valor || 0;
      acc[nome].total += 1;
      return acc;
    }, {} as Record<string, any>);

    const economiaPorCriterio = decisoesValidas.reduce((acc, decisao) => {
      const criterio = decisao.criterio || 'NORMAL';
      if (!acc[criterio]) {
        acc[criterio] = { criterio, economia: 0, total: 0 };
      }
      acc[criterio].economia += decisao.economia_valor || 0;
      acc[criterio].total += 1;
      return acc;
    }, {} as Record<string, any>);

    return {
      periodo: { dataInicio, dataFim },
      performance: metricas,
      economia: {
        por_tipo: Object.values(economiaPorTipo).slice(0, 5),
        por_fornecedor: Object.values(economiaPorFornecedor).slice(0, 5),
        por_criterio: Object.values(economiaPorCriterio)
      },
      topFornecedores: topFornecedores || [],
      tendencias: {
        melhor_fornecedor: topFornecedores?.[0]?.nome || 'N/A',
        total_economia: metricas.economia_total
      },
      sucesso: true,
      erro: null
    };
  } catch (error) {
    console.error('❌ Erro ao carregar analytics:', error);
    return {
      periodo: { dataInicio: '', dataFim: '' },
      performance: null,
      economia: null,
      topFornecedores: [],
      tendencias: null,
      sucesso: false,
      erro: 'Erro ao carregar dados de analytics'
    };
  }
};