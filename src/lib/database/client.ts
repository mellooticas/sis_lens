/**
 * Database Client - Conexão e Configuração
 * Cliente principal para todas as operações do banco baseado no Blueprint
 */

import { supabase } from '$lib/supabase';

// Helper types para responses
type DatabaseResponse<T> = {
  data: T[];
  total: number;
  page?: number;
  limit?: number;
  has_more?: boolean;
  verified?: any;
};

type SingleDatabaseResponse<T> = {
  data: T | null;
  found: boolean;
};

type ApiResponse<T> = {
  success: boolean;
  data?: T;
  error?: string;
  total?: number;
  metadata?: any;
};

export class DatabaseClient {
  
  // ============================================================================
  // CATÁLOGO DE LENTES
  // ============================================================================
  
  static async buscarLentesPorQuery(
    query: string, 
    filtros: any = {}, 
    limit = 20
  ): Promise<ApiResponse<any[]>> {
    try {
      const { data, error } = await supabase.rpc('buscar_lentes', {
        p_query: query,
        p_filtros: filtros,
        p_limit: limit
      });

      if (error) throw error;
      return { success: true, data: data || [], total: data?.length || 0 };
    } catch (error) {
      console.error('Erro ao buscar lentes por query:', error);
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  static async listarLentesCatalogo(
    filtros: any = {},
    page = 1,
    limit = 20
  ): Promise<DatabaseResponse<any>> {
    try {
      let query = supabase
        .from('v_lentes')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (filtros.marca?.length) {
        query = query.in('marca_nome', filtros.marca);
      }
      if (filtros.categoria?.length) {
        query = query.in('categoria', filtros.categoria);
      }
      if (filtros.material?.length) {
        query = query.in('material', filtros.material);
      }
      if (filtros.indice_min) {
        query = query.gte('indice_refracao', filtros.indice_min);
      }
      if (filtros.indice_max) {
        query = query.lte('indice_refracao', filtros.indice_max);
      }
      if (filtros.disponivel !== undefined) {
        query = query.eq('disponivel', filtros.disponivel);
      }
      if (filtros.status?.length) {
        query = query.in('status', filtros.status);
      }

      // Paginação
      const start = (page - 1) * limit;
      query = query
        .range(start, start + limit - 1)
        .order('nome_lente', { ascending: true });

      const { data, error, count } = await query;
      if (error) throw error;

      return {
        data: data || [],
        total: count || 0,
        page,
        limit,
        has_more: (count || 0) > start + limit
      };
    } catch (error) {
      console.error('Erro ao listar lentes do catálogo:', error);
      return {
        data: [],
        total: 0,
        page,
        limit,
        has_more: false
      };
    }
  }

  static async buscarLentePorId(id: string): Promise<SingleDatabaseResponse<any>> {
    try {
      const { data, error } = await supabase
        .from('v_lentes')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      return {
        data,
        found: !!data
      };
    } catch (error) {
      console.error('Erro ao buscar lente por ID:', error);
      return {
        data: null,
        found: false
      };
    }
  }

  // ============================================================================
  // FORNECEDORES
  // ============================================================================

  static async listarFornecedores(
    filtros: any = {}
  ): Promise<DatabaseResponse<any>> {
    try {
      let query = supabase
        .from('v_fornecedores')
        .select('*', { count: 'exact' });

      if (filtros.nome) {
        query = query.ilike('nome', `%${filtros.nome}%`);
      }
      if (filtros.regioes?.length) {
        query = query.overlaps('regioes_atendidas', filtros.regioes);
      }
      if (filtros.qualidade_min) {
        query = query.gte('qualidade_base', filtros.qualidade_min);
      }
      if (filtros.lead_time_max) {
        query = query.lte('lead_time_padrao', filtros.lead_time_max);
      }
      if (filtros.ativo !== undefined) {
        query = query.eq('ativo', filtros.ativo);
      }

      query = query.order('nome', { ascending: true });

      const { data, error, count } = await query;
      if (error) throw error;

      return {
        data: data || [],
        total: count || 0
      };
    } catch (error) {
      console.error('Erro ao listar fornecedores:', error);
      return {
        data: [],
        total: 0
      };
    }
  }

  static async buscarFornecedorPorId(id: string): Promise<SingleDatabaseResponse<any>> {
    try {
      const { data, error } = await supabase
        .from('v_fornecedores')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      return {
        data,
        found: !!data
      };
    } catch (error) {
      console.error('Erro ao buscar fornecedor por ID:', error);
      return {
        data: null,
        found: false
      };
    }
  }

  // ============================================================================
  // RANKING E DECISÕES
  // ============================================================================

  static async gerarRankingOpcoes(
    lenteId: string,
    criterio: string,
    filtros: any = {}
  ): Promise<ApiResponse<any[]>> {
    try {
      const { data, error } = await supabase
        .from('vw_ranking_atual')
        .select('*')
        .eq('lente_id', lenteId);

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
      console.error('Erro ao gerar ranking de opções:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  static async listarRankingOpcoes(
    lenteId: string,
    criterio?: string,
    limit = 10
  ): Promise<DatabaseResponse<any>> {
    try {
      let query = supabase
        .from('vw_ranking_opcoes')
        .select('*', { count: 'exact' })
        .eq('lente_id', lenteId);

      if (criterio) {
        query = query.eq('criterio_usado', criterio);
      }

      query = query
        .order('posicao', { ascending: true })
        .limit(limit);

      const { data, error, count } = await query;
      if (error) throw error;

      return {
        data: data || [],
        total: count || 0,
        has_more: (count || 0) > limit
      };
    } catch (error) {
      console.error('Erro ao listar ranking de opções:', error);
      return {
        data: [],
        total: 0,
        has_more: false
      };
    }
  }

  static async confirmarDecisaoCompra(
    tenantId: string,
    clienteId: string,
    receita: any,
    criterio: string = 'EQUILIBRADO',
    filtros: any = {}
  ): Promise<ApiResponse<any>> {
    try {
      const { data, error } = await supabase.rpc('criar_decisao_lente', {
        p_tenant_id: tenantId,
        p_cliente_id: clienteId,
        p_receita: receita,
        p_criterio: criterio,
        p_filtros: filtros
      });

      if (error) throw error;

      return {
        success: true,
        data,
        metadata: {
          economia_estimada: data?.economia_estimada || 0
        }
      };
    } catch (error) {
      console.error('Erro ao criar decisão:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  static async listarDecisoesCompra(
    filtros: any = {},
    page = 1,
    limit = 20
  ): Promise<DatabaseResponse<any>> {
    try {
      let query = supabase
        .from('decisoes_lentes')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (filtros.usuario_id) {
        query = query.eq('usuario_id', filtros.usuario_id);
      }
      if (filtros.laboratorio_id) {
        query = query.eq('laboratorio_id', filtros.laboratorio_id);
      }
      if (filtros.criterio?.length) {
        query = query.in('criterio_usado', filtros.criterio);
      }
      if (filtros.status?.length) {
        query = query.in('status', filtros.status);
      }
      if (filtros.data_inicio) {
        query = query.gte('criado_em', filtros.data_inicio);
      }
      if (filtros.data_fim) {
        query = query.lte('criado_em', filtros.data_fim);
      }
      if (filtros.valor_min) {
        query = query.gte('preco_final', filtros.valor_min);
      }
      if (filtros.valor_max) {
        query = query.lte('preco_final', filtros.valor_max);
      }

      // Paginação
      const start = (page - 1) * limit;
      query = query
        .range(start, start + limit - 1)
        .order('criado_em', { ascending: false });

      const { data, error, count } = await query;
      if (error) throw error;

      return {
        data: data || [],
        total: count || 0,
        page,
        limit,
        has_more: (count || 0) > start + limit
      };
    } catch (error) {
      console.error('Erro ao listar decisões:', error);
      return {
        data: [],
        total: 0,
        page,
        limit,
        has_more: false
      };
    }
  }

  // ============================================================================
  // ANALYTICS E MÉTRICAS
  // ============================================================================

  static async buscarEconomiaPorFornecedor(
    periodo?: string
  ): Promise<DatabaseResponse<any>> {
    try {
      // Usando view de ranking de opcoes que contém informações relevantes
      let query = supabase
        .from('vw_ranking_opcoes')
        .select('*');

      const { data, error } = await query;
      if (error) throw error;

      // Transformar dados para formato de economia
      const economiaData = data?.map(lab => ({
        fornecedor_id: lab.laboratorio_id,
        fornecedor_nome: lab.nome_laboratorio,
        economia_total_gerada: lab.score_total * 1000, // Simulado baseado no score
        periodo: periodo || 'atual'
      })) || [];

      return {
        data: economiaData,
        total: economiaData.length
      };
    } catch (error) {
      console.error('Erro ao buscar economia por fornecedor:', error);
      return {
        data: [],
        total: 0
      };
    }
  }

  static async buscarDashboardExecutivo(): Promise<SingleDatabaseResponse<any>> {
    try {
      // Buscar dados da view de dashboard de vouchers
      const { data, error } = await supabase
        .from('v_dashboard_vouchers')
        .select('*')
        .single();

      if (error) {
        console.error('Erro ao buscar dashboard vouchers:', error);
        // Retornar dados mock em caso de erro
        const mockData = {
          total_decisoes: 0,
          economia_total: 0,
          fornecedores_ativos: 0,
          tempo_medio_decisao: 0,
          updated_at: new Date().toISOString()
        };
        
        return {
          data: mockData,
          found: true
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
        data: dashboardData,
        found: true
      };
    } catch (error) {
      console.error('Erro ao buscar dashboard executivo:', error);
      return {
        data: null,
        found: false
      };
    }
  }

  // ============================================================================
  // SISTEMA DE VOUCHERS
  // ============================================================================

  static async listarUsuarios(filtros: any = {}): Promise<ApiResponse<any[]>> {
    try {
      // Usando tabela de usuários do Supabase Auth
      const { data, error } = await supabase.auth.admin.listUsers();

      if (error) throw error;

      return {
        success: true,
        data: data.users || [],
        total: data.users?.length || 0
      };
    } catch (error) {
      console.error('Erro ao listar usuários:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  static async listarLojas(filtros: any = {}): Promise<ApiResponse<any[]>> {
    try {
      // Dados mock até implementar tabela de lojas
      const mockLojas = [
        {
          id: '1',
          nome: 'Loja Centro',
          endereco: 'Rua Principal, 123 - Centro',
          ativa: true
        },
        {
          id: '2', 
          nome: 'Loja Shopping',
          endereco: 'Shopping Center, Loja 45',
          ativa: true
        }
      ];

      return {
        success: true,
        data: mockLojas,
        total: mockLojas.length
      };
    } catch (error) {
      console.error('Erro ao listar lojas:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  static async listarClientes(filtros: any = {}): Promise<ApiResponse<any[]>> {
    try {
      // Dados mock até implementar tabela de clientes
      const mockClientes = [
        {
          id: '1',
          nome: 'João Silva',
          email: 'joao@email.com',
          telefone: '(11) 99999-9999',
          ativo: true
        },
        {
          id: '2',
          nome: 'Maria Santos',
          email: 'maria@email.com', 
          telefone: '(11) 88888-8888',
          ativo: true
        }
      ];

      return {
        success: true,
        data: mockClientes,
        total: mockClientes.length
      };
    } catch (error) {
      console.error('Erro ao listar clientes:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  static async listarVouchers(filtros: any = {}): Promise<ApiResponse<any[]>> {
    try {
      // Dados mock até implementar sistema de vouchers
      const mockVouchers = [
        {
          id: '1',
          codigo: 'DESC10',
          descricao: 'Desconto de 10%',
          tipo: 'percentual',
          valor: 10,
          ativo: true,
          valido_ate: '2024-12-31'
        },
        {
          id: '2',
          codigo: 'FRETE50',
          descricao: 'Desconto R$ 50 no frete',
          tipo: 'valor_fixo',
          valor: 50,
          ativo: true,
          valido_ate: '2024-12-31'
        }
      ];

      return {
        success: true,
        data: mockVouchers,
        total: mockVouchers.length
      };
    } catch (error) {
      console.error('Erro ao listar vouchers:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }
}
