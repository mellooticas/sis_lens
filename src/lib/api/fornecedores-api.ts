/**
 * API Client para Fornecedores
 * Acesso aos dados da tabela core.fornecedores
 */

import { supabase } from '$lib/supabase';

type ApiResponse<T> = {
  success: boolean;
  data?: T;
  error?: string;
  count?: number;
};

export type Fornecedor = {
  id: string;
  nome: string;
  codigo?: string;
  ativo: boolean;
  observacoes?: string;
  created_at?: string;
  updated_at?: string;
  // Prazos
  prazo_visao_simples?: number;
  prazo_multifocal?: number;
  prazo_surfacada?: number;
  prazo_free_form?: number;
  // Configurações (JSON)
  config?: Record<string, any>;
  // Estatísticas calculadas
  total_lentes?: number;
  marcas_diferentes_usadas?: number;
};

export type FornecedorComEstatisticas = Fornecedor & {
  total_lentes: number;
  marcas_diferentes_usadas: number;
  marcas_lista?: string[];
};

export class FornecedoresAPI {
  
  /**
   * Buscar todos os fornecedores ativos
   */
  static async buscarFornecedores(): Promise<ApiResponse<FornecedorComEstatisticas[]>> {
    try {
      console.log('🏭 API: buscarFornecedores chamada');
      
      // Usar a view do schema public
      const { data: fornecedores, error: errorFornecedores } = await supabase
        .from('v_fornecedores_catalogo')
        .select('*')
        .eq('ativo', true)
        .order('nome', { ascending: true });

      if (errorFornecedores) throw errorFornecedores;

      if (!fornecedores || fornecedores.length === 0) {
        return {
          success: true,
          data: [],
          count: 0
        };
      }

      // Buscar estatísticas de cada fornecedor
      const fornecedoresComEstatisticas = await Promise.all(
        fornecedores.map(async (fornecedor) => {
          // Contar lentes do fornecedor
          const { count: totalLentes } = await supabase
            .from('v_lentes_catalogo')
            .select('*', { count: 'exact', head: true })
            .eq('fornecedor_id', fornecedor.id);

          // Buscar marcas distintas usadas pelo fornecedor
          const { data: lentesComMarca } = await supabase
            .from('v_lentes_catalogo')
            .select('marca_nome')
            .eq('fornecedor_id', fornecedor.id);

          const marcasUnicas = new Set(
            (lentesComMarca || [])
              .map(l => l.marca_nome)
              .filter(m => m)
          );

          return {
            ...fornecedor,
            total_lentes: totalLentes || 0,
            marcas_diferentes_usadas: marcasUnicas.size,
            marcas_lista: Array.from(marcasUnicas)
          };
        })
      );

      console.log('✅ Fornecedores carregados:', fornecedoresComEstatisticas.length);

      return {
        success: true,
        data: fornecedoresComEstatisticas,
        count: fornecedoresComEstatisticas.length
      };
    } catch (error) {
      console.error('❌ Erro ao buscar fornecedores:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Obter um fornecedor específico por ID
   */
  static async obterFornecedor(id: string): Promise<ApiResponse<FornecedorComEstatisticas>> {
    try {
      const { data: fornecedor, error: errorFornecedor } = await supabase
        .from('v_fornecedores_catalogo')
        .select('*')
        .eq('id', id)
        .single();

      if (errorFornecedor) throw errorFornecedor;
      if (!fornecedor) throw new Error('Fornecedor não encontrado');

      // Buscar estatísticas
      const { count: totalLentes } = await supabase
        .from('v_lentes_catalogo')
        .select('*', { count: 'exact', head: true })
        .eq('fornecedor_id', id);

      const { data: lentesComMarca } = await supabase
        .from('v_lentes_catalogo')
        .select('marca_nome')
        .eq('fornecedor_id', id);

      const marcasUnicas = new Set(
        (lentesComMarca || [])
          .map(l => l.marca_nome)
          .filter(m => m)
      );

      return {
        success: true,
        data: {
          ...fornecedor,
          total_lentes: totalLentes || 0,
          marcas_diferentes_usadas: marcasUnicas.size,
          marcas_lista: Array.from(marcasUnicas)
        }
      };
    } catch (error) {
      console.error('❌ Erro ao obter fornecedor:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Buscar lentes de um fornecedor específico
   */
  static async buscarLentesPorFornecedor(
    fornecedorId: string,
    limite: number = 50
  ): Promise<ApiResponse<any[]>> {
    try {
      const { data, error } = await supabase
        .from('v_lentes_catalogo')
        .select('*')
        .eq('fornecedor_id', fornecedorId)
        .order('created_at', { ascending: false })
        .limit(limite);

      if (error) throw error;

      return {
        success: true,
        data: data || [],
        count: data?.length || 0
      };
    } catch (error) {
      console.error('❌ Erro ao buscar lentes do fornecedor:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }
}
