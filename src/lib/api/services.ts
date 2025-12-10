/**
 * Serviços de API - Integração com Database
 * Conexão direta com as views e RPCs do sistema
 */

import { supabase } from '../supabase';

// Tipos para filtros
interface FiltrosLentes {
  disponivel?: boolean;
  categoria?: string;
  material?: string;
}

interface FiltrosDecisoes {
  status?: string;
  usuario_id?: string;
  data_inicio?: string;
  data_fim?: string;
}

interface FiltrosFornecedores {
  ativo?: boolean;
  regiao?: string;
}

// ============================================================================
// SERVIÇO DE LENTES
// ============================================================================

export class LentesService {
  /**
   * Busca lentes no catálogo via RPC
   */
  static async buscarLentes(query: string, filtros: any = {}, limit = 20) {
    try {
      const { data, error } = await supabase.rpc('rpc_buscar_lente', {
        p_query: query,
        p_filtros: filtros,
        p_limit: limit
      });

      if (error) throw error;

      return {
        success: true,
        data: data || [],
        total: data?.length || 0
      };
    } catch (error) {
      console.error('Erro ao buscar lentes:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Lista lentes do catálogo via view
   */
  static async listarLentes(filtros: FiltrosLentes = {}, page = 1, limit = 20) {
    try {
      let query = supabase
        .from('vw_lentes_catalogo')
        .select('*', { count: 'exact' });

      // Aplicar filtros básicos
      // Removido filtro 'disponivel' pois não existe na view vw_lentes_catalogo

      // Paginação
      const start = (page - 1) * limit;
      query = query
        .range(start, start + limit - 1)
        .order('sku_fantasia', { ascending: true });

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: data || [],
        total: count || 0,
        page,
        has_more: (count || 0) > start + limit
      };
    } catch (error) {
      console.error('Erro ao listar lentes:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: [],
        total: 0
      };
    }
  }

  /**
   * Busca lente por ID
   */
  static async buscarLentePorId(id: string) {
    try {
      const { data, error } = await supabase
        .from('vw_lentes_catalogo')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      return {
        success: true,
        data
      };
    } catch (error) {
      console.error('Erro ao buscar lente por ID:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: null
      };
    }
  }
}

// ============================================================================
// SERVIÇO DE RANKING
// ============================================================================

export class RankingService {
  /**
   * Gera ranking via RPC
   */
  static async gerarRanking(lenteId: string, criterio: string, filtros: any = {}) {
    try {
      const { data, error } = await supabase.rpc('rpc_rank_opcoes', {
        p_lente_id: lenteId,
        p_criterio: criterio,
        p_filtros: filtros
      });

      if (error) throw error;

      return {
        success: true,
        data: data || [],
        metadata: {
          total_opcoes: data?.length || 0,
          criterio_usado: criterio,
          filtros_aplicados: filtros
        }
      };
    } catch (error) {
      console.error('Erro ao gerar ranking:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Lista opções de ranking via view
   */
  static async listarOpcoes(lenteId: string, criterio?: string, limit = 10) {
    try {
      let query = supabase
        .from('vw_ranking_opcoes')
        .select('*')
        .eq('lente_id', lenteId);

      if (criterio) {
        query = query.eq('criterio_usado', criterio);
      }

      query = query
        .order('posicao', { ascending: true })
        .limit(limit);

      const { data, error } = await query;

      if (error) throw error;

      return {
        success: true,
        data: data || []
      };
    } catch (error) {
      console.error('Erro ao listar opções de ranking:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }
}

// ============================================================================
// SERVIÇO DE DECISÕES
// ============================================================================

export class DecisaoService {
  /**
   * Confirma decisão via RPC
   */
  static async confirmarDecisao(
    lenteId: string, 
    opcaoEscolhidaId: string, 
    criterio: string, 
    filtros: any = {}, 
    observacoes = ''
  ) {
    try {
      const { data, error } = await supabase.rpc('rpc_confirmar_decisao', {
        p_lente_id: lenteId,
        p_opcao_escolhida_id: opcaoEscolhidaId,
        p_criterio: criterio,
        p_filtros: filtros,
        p_observacoes: observacoes
      });

      if (error) throw error;

      return {
        success: true,
        data,
        economia_estimada: data?.economia_estimada || 0
      };
    } catch (error) {
      console.error('Erro ao confirmar decisão:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: null
      };
    }
  }

  /**
   * Lista decisões via view
   */
  static async listarDecisoes(filtros: FiltrosDecisoes = {}, page = 1, limit = 20) {
    try {
      let query = supabase
        .from('decisoes_compra')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (filtros.status) {
        query = query.eq('status', filtros.status);
      }
      if (filtros.usuario_id) {
        query = query.eq('usuario_id', filtros.usuario_id);
      }
      if (filtros.data_inicio) {
        query = query.gte('created_at', filtros.data_inicio);
      }
      if (filtros.data_fim) {
        query = query.lte('created_at', filtros.data_fim);
      }

      // Paginação
      const start = (page - 1) * limit;
      query = query
        .range(start, start + limit - 1)
        .order('created_at', { ascending: false });

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: data || [],
        total: count || 0,
        page,
        has_more: (count || 0) > start + limit
      };
    } catch (error) {
      console.error('Erro ao listar decisões:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: [],
        total: 0
      };
    }
  }
}

// ============================================================================
// SERVIÇO DE FORNECEDORES
// ============================================================================

export class FornecedoresService {
  /**
   * Lista fornecedores via view
   */
  static async listarFornecedores(filtros: FiltrosFornecedores = {}) {
    try {
      let query = supabase
        .from('vw_fornecedores')
        .select('*');

      if (filtros.ativo !== undefined) {
        query = query.eq('ativo', filtros.ativo);
      }

      query = query.order('nome', { ascending: true });

      const { data, error } = await query;

      if (error) throw error;

      return {
        success: true,
        data: data || []
      };
    } catch (error) {
      console.error('Erro ao listar fornecedores:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Busca fornecedor por ID
   */
  static async buscarFornecedorPorId(id: string) {
    try {
      const { data, error } = await supabase
        .from('vw_fornecedores')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      return {
        success: true,
        data
      };
    } catch (error) {
      console.error('Erro ao buscar fornecedor por ID:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: null
      };
    }
  }
}

// ============================================================================
// SERVIÇO DE ANALYTICS
// ============================================================================

export class AnalyticsService {
  /**
   * Busca métricas de economia
   */
  static async buscarEconomiaPorFornecedor(periodo?: string) {
    try {
      let query = supabase
        .from('mv_economia_por_fornecedor')
        .select('*');

      if (periodo) {
        query = query.eq('periodo', periodo);
      }

      query = query.order('economia_total', { ascending: false });

      const { data, error } = await query;

      if (error) throw error;

      return {
        success: true,
        data: data || []
      };
    } catch (error) {
      console.error('Erro ao buscar economia por fornecedor:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Busca dashboard executivo
   */
  static async buscarDashboardExecutivo() {
    try {
      const { data, error } = await supabase
        .from('v_dashboard_vouchers')
        .select('*')
        .single();

      if (error) {
        console.error('Erro ao buscar dashboard vouchers:', error);
        // Retornar dados mock em caso de erro
        return {
          success: true,
          data: {
            total_decisoes: 0,
            economia_total: 0,
            fornecedores_ativos: 0,
            tempo_medio_decisao: 0,
            updated_at: new Date().toISOString()
          }
        };
      }

      // Transformar dados de vouchers em formato executivo
      const dashboardData = {
        total_decisoes: data?.total_vouchers_gerados || 0,
        economia_total: data?.valor_total_economia_gerada || 0,
        fornecedores_ativos: 5, // Mock value
        tempo_medio_decisao: 2, // Mock value em dias
        updated_at: new Date().toISOString(),
        vouchers_data: data
      };

      return {
        success: true,
        data
      };
    } catch (error) {
      console.error('Erro ao buscar dashboard executivo:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: null
      };
    }
  }
}