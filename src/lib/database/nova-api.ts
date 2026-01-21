/**
 * Nova API Client - Funções para Nova Estrutura do Banco
 * Baseado nas views criadas em PASSO_5_CRIAR_PUBLIC_VIEWS.sql
 */

import { supabase } from '$lib/supabase';
import type {
  VwBuscarLentes,
  VwProdutosPremium,
  VwProdutosGenericos,
  VwMarcas,
  VwLaboratorios,
  VwFiltrosDisponiveis,
  VwCompararLabs,
  BuscarLentesParams,
  BuscarLentesResult,
  DetalhesLenteResult
} from '$lib/types/new-database';

type ApiResponse<T> = {
  success: boolean;
  data?: T;
  error?: string;
  total?: number;
  metadata?: any;
};

export class NovaApiClient {
  
  // ============================================================================
  // BUSCAR LENTES (Motor Principal)
  // ============================================================================
  
  /**
   * Buscar lentes usando a view consolidada v_lentes
   * Com agrupamento por grupos canônicos e suporte a múltiplos fornecedores
   */
  static async buscarLentes(
    tenantId: string,
    params: BuscarLentesParams = {}
  ): Promise<ApiResponse<BuscarLentesResult[]>> {
    try {
      const { data, error } = await supabase.rpc('fn_api_buscar_lentes', {
        p_tenant_id: tenantId,
        p_tipo_lente: params.tipo_lente || null,
        p_material: params.material || null,
        p_indice_min: params.indice_min || null,
        p_indice_max: params.indice_max || null,
        p_tratamentos: params.tratamentos || null,
        p_marca_id: params.marca_id || null,
        p_laboratorio_id: params.laboratorio_id || null,
        p_apenas_premium: params.apenas_premium || false,
        p_ordenar_por: params.ordenar_por || 'nome',
        p_limite: params.limite || 50,
        p_offset: params.offset || 0
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
   * Buscar lentes diretamente da view (sem função, para filtros customizados)
   */
  static async buscarLentesView(
    tenantId: string,
    filtros: {
      tipo?: string;
      material?: string;
      marca_id?: string;
      laboratorio_id?: string;
      apenas_premium?: boolean;
      limite?: number;
    } = {}
  ): Promise<ApiResponse<VwBuscarLentes[]>> {
    try {
      let query = supabase
        .from('v_lentes')
        .select('*')
        .eq('tenant_id', tenantId);

      if (filtros.tipo) {
        query = query.eq('tipo_lente', filtros.tipo);
      }
      if (filtros.material) {
        query = query.eq('material', filtros.material);
      }
      if (filtros.marca_id) {
        query = query.eq('marca_id', filtros.marca_id);
      }
      if (filtros.laboratorio_id) {
        query = query.eq('fornecedor_id', filtros.laboratorio_id);
      }
      if (filtros.apenas_premium) {
        query = query.eq('is_premium', true);
      }

      query = query
        .limit(filtros.limite || 50)
        .order('nome_lente');

      const { data, error } = await query;
      if (error) throw error;

      return {
        success: true,
        data: data || [],
        total: data?.length || 0
      };
    } catch (error) {
      console.error('Erro ao buscar lentes da view:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Detalhes completos de uma lente (incluindo alternativas de labs)
   */
  static async obterDetalhesLente(
    tenantId: string,
    lenteId: string
  ): Promise<ApiResponse<DetalhesLenteResult>> {
    try {
      const { data, error } = await supabase.rpc('fn_api_detalhes_lente', {
        p_lente_id: lenteId,
        p_tenant_id: tenantId
      });

      if (error) throw error;

      return {
        success: true,
        data
      };
    } catch (error) {
      console.error('Erro ao obter detalhes da lente:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  // ============================================================================
  // CATÁLOGOS PREMIUM E GENÉRICOS
  // ============================================================================
  
  /**
   * Listar produtos Premium agrupados
   */
  static async listarProdutosPremium(
    tenantId: string,
    filtros: {
      marca_id?: string;
      tipo_lente?: string;
      limite?: number;
    } = {}
  ): Promise<ApiResponse<VwProdutosPremium[]>> {
    try {
      let query = supabase
        .from('vw_produtos_premium')
        .select('*')
        .eq('tenant_id', tenantId);

      if (filtros.marca_id) {
        query = query.eq('marca_id', filtros.marca_id);
      }
      if (filtros.tipo_lente) {
        query = query.eq('tipo_lente', filtros.tipo_lente);
      }

      query = query
        .limit(filtros.limite || 100)
        .order('nome');

      const { data, error } = await query;
      if (error) throw error;

      return {
        success: true,
        data: data || [],
        total: data?.length || 0
      };
    } catch (error) {
      console.error('Erro ao listar produtos premium:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Listar produtos Genéricos agrupados
   */
  static async listarProdutosGenericos(
    tenantId: string,
    filtros: {
      tipo_lente?: string;
      material?: string;
      limite?: number;
    } = {}
  ): Promise<ApiResponse<VwProdutosGenericos[]>> {
    try {
      let query = supabase
        .from('vw_produtos_genericos')
        .select('*')
        .eq('tenant_id', tenantId);

      if (filtros.tipo_lente) {
        query = query.eq('tipo_lente', filtros.tipo_lente);
      }
      if (filtros.material) {
        query = query.eq('material', filtros.material);
      }

      query = query
        .limit(filtros.limite || 100)
        .order('nome');

      const { data, error } = await query;
      if (error) throw error;

      return {
        success: true,
        data: data || [],
        total: data?.length || 0
      };
    } catch (error) {
      console.error('Erro ao listar produtos genéricos:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  // ============================================================================
  // COMPARAÇÃO DE LABS
  // ============================================================================
  
  /**
   * Comparar mesmo produto em diferentes labs
   */
  static async compararLabs(
    tenantId: string,
    grupoId: string
  ): Promise<ApiResponse<VwCompararLabs>> {
    try {
      const { data, error } = await supabase
        .from('vw_comparar_labs')
        .select('*')
        .eq('tenant_id', tenantId)
        .eq('grupo_id', grupoId)
        .single();

      if (error) throw error;

      return {
        success: true,
        data
      };
    } catch (error) {
      console.error('Erro ao comparar labs:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Listar produtos disponíveis em múltiplos labs
   */
  static async listarProdutosMultiLab(
    tenantId: string,
    minLabs: number = 2
  ): Promise<ApiResponse<VwCompararLabs[]>> {
    try {
      const { data, error } = await supabase
        .from('vw_comparar_labs')
        .select('*')
        .eq('tenant_id', tenantId)
        .gte('qtd_labs', minLabs)
        .order('qtd_labs', { ascending: false });

      if (error) throw error;

      return {
        success: true,
        data: data || [],
        total: data?.length || 0
      };
    } catch (error) {
      console.error('Erro ao listar produtos multi-lab:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  // ============================================================================
  // DROPDOWNS E FILTROS
  // ============================================================================
  
  /**
   * Listar marcas para dropdown
   */
  static async listarMarcas(
    tenantId: string
  ): Promise<ApiResponse<VwMarcas[]>> {
    try {
      const { data, error } = await supabase
        .from('vw_marcas')
        .select('*')
        .eq('tenant_id', tenantId)
        .order('nome');

      if (error) throw error;

      return {
        success: true,
        data: data || [],
        total: data?.length || 0
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
   * Listar laboratórios para dropdown
   */
  static async listarLaboratorios(
    tenantId: string
  ): Promise<ApiResponse<VwLaboratorios[]>> {
    try {
      const { data, error } = await supabase
        .from('vw_laboratorios')
        .select('*')
        .eq('tenant_id', tenantId)
        .order('nome');

      if (error) throw error;

      return {
        success: true,
        data: data || [],
        total: data?.length || 0
      };
    } catch (error) {
      console.error('Erro ao listar laboratórios:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Obter filtros disponíveis no sistema
   */
  static async obterFiltrosDisponiveis(
    tenantId: string
  ): Promise<ApiResponse<VwFiltrosDisponiveis>> {
    try {
      const { data, error } = await supabase
        .from('vw_filtros_disponiveis')
        .select('*')
        .eq('tenant_id', tenantId)
        .single();

      if (error) throw error;

      return {
        success: true,
        data
      };
    } catch (error) {
      console.error('Erro ao obter filtros disponíveis:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }
}
