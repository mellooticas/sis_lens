/**
 * Página de Histórico - Server Load
 * Lista histórico de decisões
 */

import { DecisaoService, AnalyticsService } from '$lib/api';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url }) => {
  const page = parseInt(url.searchParams.get('page') || '1');
  const limite = parseInt(url.searchParams.get('limite') || '20');
  const status = url.searchParams.get('status') || '';
  const dataInicio = url.searchParams.get('data_inicio') || '';
  const dataFim = url.searchParams.get('data_fim') || '';
  
  try {
    // Buscar decisões com filtros
    const decisoesResult = await DecisaoService.listarDecisoes({
      status: status || undefined,
      data_inicio: dataInicio || undefined,
      data_fim: dataFim || undefined
    }, page, limite);

    // Buscar métricas de economia
    const economiaResult = await AnalyticsService.buscarEconomiaPorFornecedor();
    
    // Buscar dashboard executivo para estatísticas
    const dashboardResult = await AnalyticsService.buscarDashboardExecutivo();

    return {
      decisoes: decisoesResult.data || [],
      total_decisoes: decisoesResult.total || 0,
      pagina_atual: page,
      total_paginas: Math.ceil((decisoesResult.total || 0) / limite),
      has_more: decisoesResult.has_more || false,
      economia_fornecedores: economiaResult.data || [],
      dashboard: dashboardResult.data || null,
      filtros: {
        status,
        data_inicio: dataInicio,
        data_fim: dataFim
      },
      sucesso: decisoesResult.success,
      erro: decisoesResult.success ? null : decisoesResult.error
    };
  } catch (error) {
    console.error('Erro no load da página de histórico:', error);
    return {
      decisoes: [],
      total_decisoes: 0,
      pagina_atual: 1,
      total_paginas: 0,
      has_more: false,
      economia_fornecedores: [],
      dashboard: null,
      filtros: { status, data_inicio: dataInicio, data_fim: dataFim },
      sucesso: false,
      erro: 'Erro interno do servidor'
    };
  }
};