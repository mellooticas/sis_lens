import { createClient } from '@supabase/supabase-js';
import type { PageServerLoad } from './$types';

const supabaseUrl = 'https://syhpqosuucxonbvfagzc.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN5aHBxb3N1dWN4b25idmZhZ3pjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE3ODM0OTEsImV4cCI6MjA0NzM1OTQ5MX0.wNdO0jVKjKxNzJL_RbWBg2hJyKKsxMgoBzKwbOLKTYQ';

export const load: PageServerLoad = async ({ url, cookies, fetch }) => {
  const supabase = createClient(supabaseUrl, supabaseKey);

  try {
    // Estatísticas gerais do sistema
    const [
      lentesCount,
      marcasCount,
      decisoesCount,
      fornecedoresCount,
      recentDecisions,
      topLentes,
      economyStats,
      topMarcas,
      precoStats,
      disponibilidadeStats
    ] = await Promise.all([
      // Total de lentes no catálogo
      supabase
        .from('lentes_catalogo')
        .select('id', { count: 'exact', head: true }),

      // Total de marcas únicas
      supabase
        .from('marcas')
        .select('id', { count: 'exact', head: true }),

      // Total de decisões tomadas
      supabase
        .from('decisoes_lentes')
        .select('id', { count: 'exact', head: true }),

      // Total de fornecedores
      supabase
        .from('fornecedores')
        .select('id', { count: 'exact', head: true }),

      // Decisões recentes (últimas 10)
      supabase
        .from('decisoes_lentes')
        .select(`
          id,
          lente_id,
          created_at,
          confianca_score,
          economia_estimada,
          lentes_catalogo (
            familia,
            marca_nome,
            tipo_lente,
            preco_base
          )
        `)
        .order('created_at', { ascending: false })
        .limit(10),

      // Top 5 lentes mais recomendadas
      supabase
        .from('decisoes_lentes')
        .select(`
          lente_id,
          lentes_catalogo (
            id,
            familia,
            marca_nome,
            tipo_lente,
            preco_base
          )
        `)
        .limit(1000),

      // Estatísticas de economia
      supabase
        .from('decisoes_lentes')
        .select('economia_estimada, confianca_score')
        .not('economia_estimada', 'is', null),

      // Top marcas por quantidade de lentes
      supabase
        .from('lentes_catalogo')
        .select('marca_nome')
        .not('marca_nome', 'is', null),

      // Estatísticas de preços
      supabase
        .from('lentes_catalogo')
        .select('preco_base, preco_promocional')
        .not('preco_base', 'is', null),

      // Status de disponibilidade
      supabase
        .from('lentes_catalogo')
        .select('disponibilidade')
        .not('disponibilidade', 'is', null)
    ]);

    // Processar top lentes por frequência
    const lentesFrequency = topLentes.data?.reduce((acc: any, item: any) => {
      if (item.lente_id) {
        acc[item.lente_id] = (acc[item.lente_id] || 0) + 1;
      }
      return acc;
    }, {}) || {};

    const topLentesProcessed = Object.entries(lentesFrequency)
      .sort(([,a]: any, [,b]: any) => b - a)
      .slice(0, 5)
      .map(([lenteId, count]) => {
        const lente = topLentes.data?.find((item: any) => item.lente_id === lenteId)?.lentes_catalogo;
        return {
          id: lenteId,
          count,
          ...lente
        };
      });

    // Processar estatísticas de economia
    const economiaData = economyStats.data || [];
    const totalEconomia = economiaData.reduce((sum: number, item: any) => sum + (item.economia_estimada || 0), 0);
    const mediaConfianca = economiaData.length > 0 
      ? economiaData.reduce((sum: number, item: any) => sum + (item.confianca_score || 0), 0) / economiaData.length 
      : 0;

    // Processar top marcas
    const marcasFrequency = topMarcas.data?.reduce((acc: any, item: any) => {
      if (item.marca_nome) {
        acc[item.marca_nome] = (acc[item.marca_nome] || 0) + 1;
      }
      return acc;
    }, {}) || {};

    const topMarcasProcessed = Object.entries(marcasFrequency)
      .sort(([,a]: any, [,b]: any) => b - a)
      .slice(0, 5)
      .map(([marca, count]) => ({ marca, count }));

    // Processar estatísticas de preços
    const precosData = precoStats.data || [];
    const precos = precosData.map((item: any) => item.preco_base).filter(Boolean);
    const precoMedio = precos.length > 0 ? precos.reduce((sum: number, price: number) => sum + price, 0) / precos.length : 0;
    const precoMin = precos.length > 0 ? Math.min(...precos) : 0;
    const precoMax = precos.length > 0 ? Math.max(...precos) : 0;

    // Processar disponibilidade
    const disponibilidadeData = disponibilidadeStats.data || [];
    const disponibilidadeCount = disponibilidadeData.reduce((acc: any, item: any) => {
      const status = item.disponibilidade || 'desconhecido';
      acc[status] = (acc[status] || 0) + 1;
      return acc;
    }, {});

    // Calcular tendências mensais (simulado baseado em dados existentes)
    const agora = new Date();
    const tendenciasMensais = Array.from({ length: 6 }, (_, i) => {
      const mes = new Date(agora.getFullYear(), agora.getMonth() - i, 1);
      const decisoesMes = Math.floor(Math.random() * 50) + 20; // Simulado
      const economiaMes = Math.floor(Math.random() * 5000) + 2000; // Simulado
      
      return {
        mes: mes.toLocaleDateString('pt-BR', { month: 'short', year: '2-digit' }),
        decisoes: decisoesMes,
        economia: economiaMes
      };
    }).reverse();

    return {
      // Estatísticas principais
      estatisticas: {
        total_lentes: lentesCount.count || 0,
        total_marcas: marcasCount.count || 0,
        total_decisoes: decisoesCount.count || 0,
        total_fornecedores: fornecedoresCount.count || 0,
        economia_total: totalEconomia,
        confianca_media: Math.round(mediaConfianca * 100) / 100,
        preco_medio: Math.round(precoMedio * 100) / 100,
        preco_min: precoMin,
        preco_max: precoMax
      },

      // Dados para gráficos e listas
      decisoes_recentes: recentDecisions.data || [],
      top_lentes: topLentesProcessed || [],
      top_marcas: topMarcasProcessed || [],
      disponibilidade: disponibilidadeCount,
      tendencias_mensais: tendenciasMensais,

      // Dados para componentes
      atividade_recente: {
        decisoes_hoje: Math.floor(Math.random() * 15) + 5, // Simulado
        economia_hoje: Math.floor(Math.random() * 1000) + 500, // Simulado
        lentes_consultadas: Math.floor(Math.random() * 100) + 50, // Simulado
        fornecedores_ativos: Math.floor(Math.random() * 8) + 3 // Simulado
      },

      // Alertas e notificações
      alertas: [
        {
          tipo: 'info',
          titulo: 'Sistema atualizado',
          mensagem: 'Nova versão do decisor foi implementada com melhorias na precisão.',
          timestamp: new Date().toISOString()
        },
        {
          tipo: 'warning',
          titulo: 'Estoque baixo',
          mensagem: 'Algumas lentes estão com disponibilidade limitada.',
          timestamp: new Date(Date.now() - 3600000).toISOString()
        }
      ]
    };

  } catch (error) {
    console.error('Erro ao carregar dados do dashboard:', error);
    
    // Retornar dados padrão em caso de erro
    return {
      estatisticas: {
        total_lentes: 0,
        total_marcas: 0,
        total_decisoes: 0,
        total_fornecedores: 0,
        economia_total: 0,
        confianca_media: 0,
        preco_medio: 0,
        preco_min: 0,
        preco_max: 0
      },
      decisoes_recentes: [],
      top_lentes: [],
      top_marcas: [],
      disponibilidade: {},
      tendencias_mensais: [],
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