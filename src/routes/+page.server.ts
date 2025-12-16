/**
 * Página Principal - Server Load
 * Dashboard usando dados reais do banco
 */

import { createClient } from '@supabase/supabase-js';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async () => {
  try {
    const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
    const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Missing Supabase environment variables');
    }

    const supabase = createClient(supabaseUrl, supabaseKey);
    
    // Buscar dados reais usando funções públicas
    const [kpisResult, labsResult, decisoesResult] = await Promise.all([
      supabase.rpc('obter_dashboard_kpis'),
      supabase.from('vw_laboratorios_completo').select('*').limit(5),
      supabase.from('vw_historico_decisoes').select('*').limit(5)
    ]);

    const kpis = kpisResult.data || { total_decisoes: 0, economia_total: 0, decisoes_mes: 0, labs_ativos: 0 };
    const labs = labsResult.data || [];
    const decisoes = decisoesResult.data || [];
    
    return { 
      dashboard: {
        total_decisoes_lentes: kpis.total_decisoes || 0,
        economia_total_lentes: kpis.economia_total || 0,
        total_vouchers_emitidos: 0,
        total_usuarios_ativos: 1,
        laboratorio_top_nome: labs[0]?.nome_fantasia || 'N/A',
        economia_media_decisao: kpis.total_decisoes > 0 ? Math.round(kpis.economia_total / kpis.total_decisoes) : 0
      },
      decisoes_recentes: decisoes,
      lentes_populares: [],
      economia_fornecedores: labs.map(lab => ({
        nome: lab.nome_fantasia,
        economia: 0,
        score: lab.score_geral || 0
      })),
      metricas_resumo: {
        total_decisoes: kpis.total_decisoes || 0,
        economia_mes: kpis.economia_total || 0,
        fornecedores_ativos: labs.length
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