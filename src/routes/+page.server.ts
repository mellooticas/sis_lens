/**
 * Página Principal - Server Load
 * Dashboard com dados mock temporários
 */

import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async () => {
  try {
    // Retorna dados mock para evitar erros de banco
    return { 
      dashboard: {
        total_decisoes_lentes: 0,
        economia_total_lentes: 0,
        total_vouchers_emitidos: 0,
        total_usuarios_ativos: 1,
        laboratorio_top_nome: 'BestLens Demo',
        economia_media_decisao: 0
      },
      decisoes_recentes: [],
      lentes_populares: [],
      economia_fornecedores: [],
      metricas_resumo: {
        total_decisoes: 0,
        economia_mes: 0,
        fornecedores_ativos: 3
      },
      sucesso: true,
      erro: null
    };
  } catch (error) {
    console.error('Erro no load da página principal:', error);
    return {
      dashboard: {
        total_decisoes_lentes: 0,
        economia_total_lentes: 0,
        total_vouchers_emitidos: 0,
        total_usuarios_ativos: 0,
        laboratorio_top_nome: 'N/A',
        economia_media_decisao: 0
      },
      decisoes_recentes: [],
      lentes_populares: [],
      economia_fornecedores: [],
      metricas_resumo: {
        total_decisoes: 0,
        economia_mes: 0,
        fornecedores_ativos: 0
      },
      sucesso: false,
      erro: 'Erro interno do servidor'
    };
  }
};