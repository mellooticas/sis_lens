/**
 * API Client para as Views do Banco de Dados
 * Baseado em 14_VIEWS_FINAIS_V3.sql
 * 
 * Módulos:
 * - Buscar Lentes: vw_lentes_catalogo (1.411 lentes)
 * - Catálogo: vw_canonicas_genericas (187 grupos)
 * - Premium: vw_canonicas_premium (250 grupos)
 * - Comparar: vw_detalhes_premium (detalhes por canônica)
 */

import { supabase } from '$lib/supabase';
import type {
  LenteCatalogo,
  CanonicaGenerica,
  CanonicaPremium,
  DetalhePremium,
  StatsCatalogo,
  FiltrosLentes,
  PaginacaoParams,
  RespostaPaginada
} from '$lib/types/database-views';

type ApiResponse<T> = {
  success: boolean;
  data?: T;
  error?: string;
  count?: number;
};

export class CatalogoAPI {
  
  // ============================================================================
  // MÓDULO: BUSCAR LENTES (vw_lentes_catalogo - 1.411 lentes)
  // ============================================================================
  
  /**
   * Buscar lentes completas com filtros
   * Para o módulo "Buscar Lentes"
   */
  static async buscarLentes(
    filtros: FiltrosLentes = {},
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<LenteCatalogo>>> {
    try {
      const { pagina = 1, limite = 50, ordenar = 'created_at', direcao = 'desc' } = paginacao;
      const offset = (pagina - 1) * limite;

      let query = supabase
        .from('vw_lentes_catalogo')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (filtros.tipos && filtros.tipos.length > 0) {
        query = query.in('tipo_lente', filtros.tipos);
      }
      if (filtros.categorias && filtros.categorias.length > 0) {
        query = query.in('categoria', filtros.categorias);
      }
      if (filtros.materiais && filtros.materiais.length > 0) {
        query = query.in('material', filtros.materiais);
      }
      if (filtros.indices && filtros.indices.length > 0) {
        query = query.in('indice_refracao', filtros.indices);
      }
      if (filtros.marcas && filtros.marcas.length > 0) {
        query = query.in('marca_nome', filtros.marcas);
      }

      // Filtros de tratamentos
      if (filtros.tratamentos) {
        if (filtros.tratamentos.ar === true) query = query.eq('ar', true);
        if (filtros.tratamentos.blue === true) query = query.eq('blue', true);
        if (filtros.tratamentos.fotossensivel === true) query = query.neq('fotossensivel', 'nenhum');
        if (filtros.tratamentos.polarizado === true) query = query.eq('polarizado', true);
        if (filtros.tratamentos.digital === true) query = query.eq('digital', true);
        if (filtros.tratamentos.free_form === true) query = query.eq('free_form', true);
      }

      // Filtro de preço
      if (filtros.preco) {
        if (filtros.preco.min !== undefined) query = query.gte('preco_tabela', filtros.preco.min);
        if (filtros.preco.max !== undefined) query = query.lte('preco_tabela', filtros.preco.max);
      }

      // Busca textual
      if (filtros.busca) {
        query = query.ilike('nome_comercial', `%${filtros.busca}%`);
      }

      // Ordenação e paginação
      query = query.order(ordenar, { ascending: direcao === 'asc' });
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: {
          dados: data || [],
          paginacao: {
            total: count || 0,
            pagina,
            limite,
            total_paginas: Math.ceil((count || 0) / limite)
          }
        }
      };
    } catch (error) {
      console.error('Erro ao buscar lentes:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Buscar uma lente específica por ID
   */
  static async obterLente(id: string): Promise<ApiResponse<LenteCatalogo>> {
    try {
      const { data, error } = await supabase
        .from('vw_lentes_catalogo')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data || undefined
      };
    } catch (error) {
      console.error('Erro ao obter lente:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  // ============================================================================
  // MÓDULO: CATÁLOGO (vw_canonicas_genericas - 187 grupos)
  // ============================================================================

  /**
   * Listar lentes canônicas genéricas
   * Para o módulo "Catálogo"
   */
  static async listarCanonicasGenericas(
    filtros: Partial<FiltrosLentes> = {},
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<CanonicaGenerica>>> {
    try {
      const { pagina = 1, limite = 50, ordenar = 'nome_canonico', direcao = 'asc' } = paginacao;
      const offset = (pagina - 1) * limite;

      let query = supabase
        .from('vw_canonicas_genericas')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (filtros.tipos && filtros.tipos.length > 0) {
        query = query.in('tipo_lente', filtros.tipos);
      }
      if (filtros.materiais && filtros.materiais.length > 0) {
        query = query.in('material', filtros.materiais);
      }
      if (filtros.indices && filtros.indices.length > 0) {
        query = query.in('indice_refracao', filtros.indices);
      }
      if (filtros.categorias && filtros.categorias.length > 0) {
        query = query.in('categoria', filtros.categorias);
      }

      // Ordenação e paginação
      query = query.order(ordenar, { ascending: direcao === 'asc' });
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: {
          dados: data || [],
          paginacao: {
            total: count || 0,
            pagina,
            limite,
            total_paginas: Math.ceil((count || 0) / limite)
          }
        }
      };
    } catch (error) {
      console.error('Erro ao listar canônicas genéricas:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Obter uma canônica genérica específica
   */
  static async obterCanonicaGenerica(id: string): Promise<ApiResponse<CanonicaGenerica>> {
    try {
      const { data, error } = await supabase
        .from('vw_canonicas_genericas')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data || undefined
      };
    } catch (error) {
      console.error('Erro ao obter canônica genérica:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  // ============================================================================
  // MÓDULO: PREMIUM (vw_canonicas_premium - 250 grupos)
  // ============================================================================

  /**
   * Listar lentes canônicas premium
   * Para o módulo "Premium"
   */
  static async listarCanonicasPremium(
    filtros: Partial<FiltrosLentes> = {},
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<CanonicaPremium>>> {
    try {
      const { pagina = 1, limite = 50, ordenar = 'marca_nome,nome_canonico', direcao = 'asc' } = paginacao;
      const offset = (pagina - 1) * limite;

      let query = supabase
        .from('vw_canonicas_premium')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (filtros.tipos && filtros.tipos.length > 0) {
        query = query.in('tipo_lente', filtros.tipos);
      }
      if (filtros.materiais && filtros.materiais.length > 0) {
        query = query.in('material', filtros.materiais);
      }
      if (filtros.indices && filtros.indices.length > 0) {
        query = query.in('indice_refracao', filtros.indices);
      }
      if (filtros.categorias && filtros.categorias.length > 0) {
        query = query.in('categoria', filtros.categorias);
      }
      if (filtros.marcas && filtros.marcas.length > 0) {
        query = query.in('marca_nome', filtros.marcas);
      }

      // Ordenação e paginação
      query = query.order(ordenar, { ascending: direcao === 'asc' });
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: {
          dados: data || [],
          paginacao: {
            total: count || 0,
            pagina,
            limite,
            total_paginas: Math.ceil((count || 0) / limite)
          }
        }
      };
    } catch (error) {
      console.error('Erro ao listar canônicas premium:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Obter uma canônica premium específica
   */
  static async obterCanonicaPremium(id: string): Promise<ApiResponse<CanonicaPremium>> {
    try {
      const { data, error } = await supabase
        .from('vw_canonicas_premium')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data || undefined
      };
    } catch (error) {
      console.error('Erro ao obter canônica premium:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  // ============================================================================
  // MÓDULO: COMPARAR (vw_detalhes_premium - comparação por canônica)
  // ============================================================================

  /**
   * Listar todas as lentes reais de uma canônica premium
   * Para o botão "Detalhes/Comparar" no módulo Comparar
   */
  static async listarDetalhesPremium(
    canonicaId: string
  ): Promise<ApiResponse<DetalhePremium[]>> {
    try {
      const { data, error } = await supabase
        .from('vw_detalhes_premium')
        .select('*')
        .eq('canonica_id', canonicaId)
        .order('marca_nome')
        .order('preco_tabela');

      if (error) throw error;

      return {
        success: true,
        data: data || [],
        count: data?.length || 0
      };
    } catch (error) {
      console.error('Erro ao listar detalhes premium:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Comparar lentes de múltiplos laboratórios para uma mesma canônica
   * Agrupa por marca/laboratório
   */
  static async compararLaboratorios(
    canonicaId: string
  ): Promise<ApiResponse<Record<string, DetalhePremium[]>>> {
    try {
      const resultado = await this.listarDetalhesPremium(canonicaId);
      
      if (!resultado.success || !resultado.data) {
        return resultado as any;
      }

      // Agrupar por marca
      const agrupadoPorMarca = resultado.data.reduce((acc, lente) => {
        const marca = lente.marca_nome;
        if (!acc[marca]) {
          acc[marca] = [];
        }
        acc[marca].push(lente);
        return acc;
      }, {} as Record<string, DetalhePremium[]>);

      return {
        success: true,
        data: agrupadoPorMarca,
        count: Object.keys(agrupadoPorMarca).length
      };
    } catch (error) {
      console.error('Erro ao comparar laboratórios:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  // ============================================================================
  // ESTATÍSTICAS (vw_stats_catalogo)
  // ============================================================================

  /**
   * Obter estatísticas gerais do catálogo
   */
  static async obterEstatisticas(): Promise<ApiResponse<StatsCatalogo>> {
    try {
      const { data, error } = await supabase
        .from('vw_stats_catalogo')
        .select('*')
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data || undefined
      };
    } catch (error) {
      console.error('Erro ao obter estatísticas:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  // ============================================================================
  // UTILITÁRIOS
  // ============================================================================

  /**
   * Obter lista de marcas únicas
   */
  static async listarMarcas(): Promise<ApiResponse<string[]>> {
    try {
      const { data, error } = await supabase
        .from('vw_lentes_catalogo')
        .select('marca_nome')
        .order('marca_nome');

      if (error) throw error;

      const marcasUnicas = [...new Set((data || []).map(item => item.marca_nome))];

      return {
        success: true,
        data: marcasUnicas,
        count: marcasUnicas.length
      };
    } catch (error) {
      console.error('Erro ao listar marcas:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Obter filtros disponíveis (valores únicos de cada campo)
   */
  static async obterFiltrosDisponiveis(): Promise<ApiResponse<{
    tipos: string[];
    materiais: string[];
    indices: string[];
    categorias: string[];
  }>> {
    try {
      const { data, error } = await supabase
        .from('vw_lentes_catalogo')
        .select('tipo_lente, material, indice_refracao, categoria');

      if (error) throw error;

      const filtros = {
        tipos: [...new Set((data || []).map(item => item.tipo_lente))].sort(),
        materiais: [...new Set((data || []).map(item => item.material))].sort(),
        indices: [...new Set((data || []).map(item => item.indice_refracao))].sort(),
        categorias: [...new Set((data || []).map(item => item.categoria))].sort()
      };

      return {
        success: true,
        data: filtros
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
