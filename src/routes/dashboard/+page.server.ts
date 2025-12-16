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
    
    // === USAR FUNÇÕES E VIEWS PÚBLICAS ===
    const [kpisResult, labsResult, decisoesResult, rankingResult] = await Promise.all([
      // 1. KPIs do dashboard
      supabase.rpc('obter_dashboard_kpis'),
      
      // 2. Laboratórios ativos com scores
      supabase.from('vw_laboratorios_completo').select('*').limit(10),
      
      // 3. Histórico de decisões
      supabase.from('vw_historico_decisoes').select('*').limit(10),
      
      // 4. Ranking de alternativas
      supabase.from('vw_ranking_atual').select('*').limit(20)
    ]);

    const kpis = kpisResult.data || { total_decisoes: 0, economia_total: 0, decisoes_mes: 0, labs_ativos: 0 };
    const labs = labsResult.data || [];
    const decisoes = decisoesResult.data || [];
    const ranking = rankingResult.data || [];

    return {
      estatisticas: {
        total_decisoes: kpis.total_decisoes || 0,
        economia_total: kpis.economia_total || 0,
        decisoes_mes: kpis.decisoes_mes || 0,
        labs_ativos: labs.length,
        confianca_media: 0
      },
      laboratorios: labs,
      decisoes_recentes: decisoes,
      ranking_alternativas: ranking,
      atividade_recente: {
        decisoes_hoje: 0,
        economia_hoje: 0,
        lentes_consultadas: 0,
        fornecedores_ativos: labs.length
      },
      alertas: []
    };

  } catch (error) {
    console.error('Erro ao carregar dados do dashboard:', error);
    
    return {
      estatisticas: {
        total_decisoes: 0,
        economia_total: 0,
        decisoes_mes: 0,
        labs_ativos: 0,
        confianca_media: 0
      },
      laboratorios: [],
      decisoes_recentes: [],
      ranking_alternativas: [],
      atividade_recente: {
        decisoes_hoje: 0,
        economia_hoje: 0,
        lentes_consultadas: 0,
        fornecedores_ativos: 0
      },
      alertas: []
    };
  }
};
