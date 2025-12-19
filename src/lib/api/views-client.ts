/**
 * API Client para Views Públicas do Banco
 * Baseado em povoar_banco/06_PUBLIC_VIEWS.sql
 * 
 * Este client consome as views públicas criadas para o frontend:
 * - vw_buscar_lentes
 * - vw_grupos_genericos
 * - vw_grupos_premium
 * - vw_marcas
 * - vw_fornecedores
 * - vw_filtros_disponiveis
 * - vw_comparar_fornecedores
 * - vw_stats_catalogo
 */

import { supabase } from '$lib/supabase';
import type {
  VwBuscarLentes,
  VwGruposGenericos,
  VwGruposPremium,
  VwMarcas,
  VwFornecedores,
  VwFiltrosDisponiveis,
  VwCompararFornecedores,
  VwStatsCatalogo,
  BuscarLentesParams,
  BuscarGruposParams,
  BuscarLentesResponse,
  GruposGenericosResponse,
  GruposPremiumResponse,
  MarcasResponse,
  FornecedoresResponse,
  FiltrosDisponiveisResponse,
  CompararFornecedoresResponse,
  StatsCatalogoResponse
} from '$lib/types/views';

/**
 * Cliente para consumir as views públicas do banco
 */
export class ViewsApiClient {
  
  // ==========================================================================
  // BUSCAR LENTES (Motor Principal)
  // ==========================================================================
  
  /**
   * Buscar lentes usando a view vw_buscar_lentes
   * Esta é a função principal de busca do sistema
   */
  static async buscarLentes(params: BuscarLentesParams = {}): Promise<BuscarLentesResponse> {
    try {
      let query = supabase
        .from('vw_buscar_lentes')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (params.tipo_lente) {
        query = query.eq('tipo_lente', params.tipo_lente);
      }
      
      if (params.material) {
        query = query.eq('material', params.material);
      }
      
      if (params.indice_refracao) {
        query = query.eq('indice_refracao', params.indice_refracao);
      }
      
      if (params.categoria) {
        query = query.eq('categoria', params.categoria);
      }
      
      if (params.marca_id) {
        query = query.eq('marca_id', params.marca_id);
      }
      
      if (params.fornecedor_id) {
        query = query.eq('fornecedor_id', params.fornecedor_id);
      }
      
      if (params.apenas_premium) {
        query = query.eq('tipo_canonica', 'premium');
      }
      
      // Filtros de tratamentos
      if (params.com_ar !== undefined) {
        query = query.eq('ar', params.com_ar);
      }
      
      if (params.com_blue !== undefined) {
        query = query.eq('blue', params.com_blue);
      }
      
      if (params.com_polarizado !== undefined) {
        query = query.eq('polarizado', params.com_polarizado);
      }
      
      if (params.com_antirrisco !== undefined) {
        query = query.eq('antirrisco', params.com_antirrisco);
      }
      
      if (params.com_uv400 !== undefined) {
        query = query.eq('uv400', params.com_uv400);
      }
      
      if (params.com_fotossensivel !== undefined) {
        query = params.com_fotossensivel
          ? query.neq('fotossensivel', 'nenhum')
          : query.eq('fotossensivel', 'nenhum');
      }
      
      // Filtros de faixas ópticas
      if (params.esferico_min !== undefined) {
        query = query.gte('esferico_max', params.esferico_min);
      }
      
      if (params.esferico_max !== undefined) {
        query = query.lte('esferico_min', params.esferico_max);
      }
      
      if (params.cilindrico_min !== undefined) {
        query = query.gte('cilindrico_max', params.cilindrico_min);
      }
      
      if (params.cilindrico_max !== undefined) {
        query = query.lte('cilindrico_min', params.cilindrico_max);
      }
      
      // Filtros de preço
      if (params.preco_min !== undefined) {
        query = query.gte('preco_tabela', params.preco_min);
      }
      
      if (params.preco_max !== undefined) {
        query = query.lte('preco_tabela', params.preco_max);
      }
      
      // Ordenação
      const ordenarPor = params.ordenar_por || 'nome';
      const ordem = params.ordem || 'asc';
      
      switch (ordenarPor) {
        case 'preco':
          query = query.order('preco_tabela', { ascending: ordem === 'asc' });
          break;
        case 'marca':
          query = query.order('marca', { ascending: ordem === 'asc' });
          break;
        case 'indice':
          query = query.order('indice_refracao', { ascending: ordem === 'desc' });
          break;
        default:
          query = query.order('nome_comercial', { ascending: ordem === 'asc' });
      }
      
      // Paginação
      const limite = params.limite || 50;
      const offset = params.offset || 0;
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: (data as VwBuscarLentes[]) || [],
        total: count || 0,
        metadata: {
          limite,
          offset,
          paginas: count ? Math.ceil(count / limite) : 0
        }
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
   * Obter detalhes de uma lente específica por ID
   */
  static async obterLentePorId(lenteId: string): Promise<BuscarLentesResponse> {
    try {
      const { data, error } = await supabase
        .from('vw_buscar_lentes')
        .select('*')
        .eq('id', lenteId)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data ? [data as VwBuscarLentes] : []
      };
    } catch (error) {
      console.error('Erro ao obter lente:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  // ==========================================================================
  // GRUPOS CANÔNICOS GENÉRICOS
  // ==========================================================================
  
  /**
   * Buscar grupos canônicos genéricos (lentes econômicas/intermediárias)
   */
  static async buscarGruposGenericos(params: BuscarGruposParams = {}): Promise<GruposGenericosResponse> {
    try {
      let query = supabase
        .from('vw_grupos_genericos')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (params.tipo_lente) {
        query = query.eq('tipo_lente', params.tipo_lente);
      }
      
      if (params.material) {
        query = query.eq('material', params.material);
      }
      
      if (params.indice_refracao) {
        query = query.eq('indice_refracao', params.indice_refracao);
      }
      
      // Ordenação
      const ordenarPor = params.ordenar_por || 'nome';
      switch (ordenarPor) {
        case 'preco':
          query = query.order('preco_minimo', { ascending: true });
          break;
        case 'qtd_fornecedores':
          query = query.order('qtd_fornecedores', { ascending: false });
          break;
        default:
          query = query.order('nome_canonico', { ascending: true });
      }
      
      // Paginação
      const limite = params.limite || 50;
      const offset = params.offset || 0;
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: (data as VwGruposGenericos[]) || [],
        total: count || 0
      };
    } catch (error) {
      console.error('Erro ao buscar grupos genéricos:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  // ==========================================================================
  // GRUPOS CANÔNICOS PREMIUM
  // ==========================================================================
  
  /**
   * Buscar grupos canônicos premium (por marca)
   */
  static async buscarGruposPremium(params: BuscarGruposParams = {}): Promise<GruposPremiumResponse> {
    try {
      let query = supabase
        .from('vw_grupos_premium')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (params.tipo_lente) {
        query = query.eq('tipo_lente', params.tipo_lente);
      }
      
      if (params.material) {
        query = query.eq('material', params.material);
      }
      
      if (params.indice_refracao) {
        query = query.eq('indice_refracao', params.indice_refracao);
      }
      
      if (params.marca_id) {
        query = query.eq('marca_id', params.marca_id);
      }
      
      // Ordenação
      const ordenarPor = params.ordenar_por || 'nome';
      switch (ordenarPor) {
        case 'preco':
          query = query.order('preco_minimo', { ascending: true });
          break;
        case 'qtd_fornecedores':
          query = query.order('qtd_fornecedores', { ascending: false });
          break;
        default:
          query = query.order('nome_canonico', { ascending: true });
      }
      
      // Paginação
      const limite = params.limite || 50;
      const offset = params.offset || 0;
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: (data as VwGruposPremium[]) || [],
        total: count || 0
      };
    } catch (error) {
      console.error('Erro ao buscar grupos premium:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  // ==========================================================================
  // MARCAS
  // ==========================================================================
  
  /**
   * Listar todas as marcas disponíveis
   */
  static async listarMarcas(): Promise<MarcasResponse> {
    try {
      const { data, error } = await supabase
        .from('vw_marcas')
        .select('*')
        .order('nome');

      if (error) throw error;

      return {
        success: true,
        data: (data as VwMarcas[]) || []
      };
    } catch (error) {
      console.error('Erro ao listar marcas:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Obter marcas premium
   */
  static async listarMarcasPremium(): Promise<MarcasResponse> {
    try {
      const { data, error } = await supabase
        .from('vw_marcas')
        .select('*')
        .eq('is_premium', true)
        .order('nome');

      if (error) throw error;

      return {
        success: true,
        data: (data as VwMarcas[]) || []
      };
    } catch (error) {
      console.error('Erro ao listar marcas premium:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  // ==========================================================================
  // FORNECEDORES
  // ==========================================================================
  
  /**
   * Listar todos os fornecedores disponíveis
   */
  static async listarFornecedores(): Promise<FornecedoresResponse> {
    try {
      const { data, error } = await supabase
        .from('vw_fornecedores')
        .select('*')
        .order('nome');

      if (error) throw error;

      return {
        success: true,
        data: (data as VwFornecedores[]) || []
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

  // ==========================================================================
  // FILTROS DISPONÍVEIS
  // ==========================================================================
  
  /**
   * Obter todos os valores disponíveis para filtros
   * Útil para popular dropdowns e checkboxes
   */
  static async obterFiltrosDisponiveis(): Promise<FiltrosDisponiveisResponse> {
    try {
      const { data, error } = await supabase
        .from('vw_filtros_disponiveis')
        .select('*')
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data as VwFiltrosDisponiveis
      };
    } catch (error) {
      console.error('Erro ao obter filtros disponíveis:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  // ==========================================================================
  // COMPARAR FORNECEDORES
  // ==========================================================================
  
  /**
   * Comparar preços entre fornecedores para produtos equivalentes
   */
  static async compararFornecedores(
    grupoId?: string,
    tipo?: 'PREMIUM' | 'GENÉRICA'
  ): Promise<CompararFornecedoresResponse> {
    try {
      let query = supabase
        .from('vw_comparar_fornecedores')
        .select('*');

      if (grupoId) {
        query = query.eq('grupo_id', grupoId);
      }
      
      if (tipo) {
        query = query.eq('tipo', tipo);
      }

      const { data, error } = await query;

      if (error) throw error;

      return {
        success: true,
        data: (data as VwCompararFornecedores[]) || []
      };
    } catch (error) {
      console.error('Erro ao comparar fornecedores:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Comparar fornecedores para uma lente específica (por seu grupo canônico)
   */
  static async compararFornecedoresPorLente(lenteId: string): Promise<CompararFornecedoresResponse> {
    try {
      // Primeiro, obter o grupo_id da lente
      const { data: lente } = await supabase
        .from('vw_buscar_lentes')
        .select('canonica_id')
        .eq('id', lenteId)
        .single();

      if (!lente?.canonica_id) {
        return {
          success: false,
          error: 'Lente não encontrada ou não possui grupo canônico',
          data: []
        };
      }

      // Buscar comparação
      return this.compararFornecedores(lente.canonica_id);
    } catch (error) {
      console.error('Erro ao comparar fornecedores por lente:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  // ==========================================================================
  // ESTATÍSTICAS DO CATÁLOGO
  // ==========================================================================
  
  /**
   * Obter estatísticas gerais do catálogo
   */
  static async obterEstatisticasCatalogo(): Promise<StatsCatalogoResponse> {
    try {
      const { data, error } = await supabase
        .from('vw_stats_catalogo')
        .select('*')
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data as VwStatsCatalogo
      };
    } catch (error) {
      console.error('Erro ao obter estatísticas:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }
}

// Exportar instância singleton
export const viewsApi = ViewsApiClient;
