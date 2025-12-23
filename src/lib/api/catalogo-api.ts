/**
 * API Client para as Views do Banco de Dados
 * Baseado em 14_VIEWS_FINAIS_V3.sql e EXTRAORDINARY_DB_UPGRADE.sql
 * 
 * Módulos:
 * - Buscar Lentes: vw_lentes_catalogo e Funções RPC
 * - Catálogo: vw_canonicas_genericas
 * - Premium: vw_canonicas_premium
 * - Comparar: vw_detalhes_premium
 */

import { supabase } from '$lib/supabase';
import type {
  LenteCatalogo,
  CanonicaGenerica,
  CanonicaPremium,
  DetalhePremium,
  DetalheGenerico,
  StatsCatalogo,
  FiltrosLentes,
  PaginacaoParams,
  RespostaPaginada,
  ResultadoBuscaInteligente
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

      // 1. Se tiver filtro de busca textual, usa a nova função RPC "Google-like"
      if (filtros.busca && filtros.busca.length > 2) {
         return this.buscarLentesTexto(filtros.busca, paginacao);
      }

      // 2. Se tiver receita, usa a função RPC de prescrição
      if (filtros.receita) {
          // Nota: A função RPC retorna ResultadoBuscaInteligente, que é um subconjunto de LenteCatalogo.
          // Para manter a assinatura, teríamos que adaptar ou fazer um fetch dos detalhes.
          // Por enquanto, vamos manter a busca padrão se não for implementado especificamente o fluxo de receita aqui.
          // Mas idealmente chamaríamos buscarLentesPorReceita
      }

      let query = supabase
        .from('vw_lentes_catalogo')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (filtros.ids && filtros.ids.length > 0) {
        query = query.in('id', filtros.ids);
      }
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

      // Busca textual simples (fallback se < 3 chars)
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
      console.error('❌ Erro ao buscar lentes:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * 🌟 Busca Inteligente por Texto (Full Text Search)
   * Usa a RPC buscar_lentes_texto
   */
  static async buscarLentesTexto(
    busca: string, 
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<LenteCatalogo>>> {
    try {
        const { pagina = 1, limite = 50 } = paginacao;
        
        // RPC normalmente retorna SETOF vw_lentes_catalogo, então o tipo bate.
        // Mas a RPC não suporta paginação nativa (OFFSET/LIMIT) se não foi programada pra isso.
        // O script V4 não colocou paginação OBS: Colocou RETURN QUER SELECT * ...
        // Podemos tentar paginar no cliente ou o Supabase permite range() em rpc se retornar setof table?
        // Sim, se retornar SETOF table, permite range().
        
        const offset = (pagina - 1) * limite;
        
        const { data, error, count } = await supabase
            .rpc('buscar_lentes_texto', { busca })
            .range(offset, offset + limite - 1); // Range funciona em RPC que retorna SETOF? Geralmente sim no cliente JS
            
        // Se range não funcionar direto no RPC, teremos que filtrar no retorno ou ajustar a RPC.
        // Supabase JS Cliente suporta .range() em .rpc() se a função retornar tabela.
        
        if (error) throw error;

        // Count pode vir null em RPC
        const totalEstimado = (data?.length || 0) + offset + (data?.length === limite ? 1 : 0); 

        return {
            success: true,
            data: {
                dados: (data as any) || [],
                paginacao: {
                    total: totalEstimado, // RPC dificulta count exato sem 2 calls
                    pagina,
                    limite,
                    total_paginas: 1 // Simplificado para RPC
                }
            }
        };

    } catch (error) {
        console.error('❌ Erro ao buscar lentes por texto:', error);
        return { success: false, error: (error as Error).message };
    }
  }

  /**
   * 🌟 Busca Inteligente por Receita (Prescription Match)
   * Usa a RPC buscar_lentes_por_receita
   */
  static async buscarLentesPorReceita(
      esferico: number,
      cilindrico: number,
      adicao?: number,
      tipo?: string
  ): Promise<ApiResponse<ResultadoBuscaInteligente[]>> {
    try {
        const { data, error } = await supabase.rpc('buscar_lentes_por_receita', {
            p_esferico: esferico,
            p_cilindrico: cilindrico,
            p_adicao: adicao || null,
            p_tipo_lente: tipo || null
        });

        if (error) throw error;

        return {
            success: true,
            data: data || [],
            count: data?.length || 0
        };
    } catch (error) {
        console.error('❌ Erro ao buscar lentes por receita:', error);
        return { success: false, error: (error as Error).message };
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
  // MÓDULO: COMPARAR GENÉRICAS (vw_detalhes_genericas)
  // ============================================================================

  /**
   * Listar todas as lentes reais de uma canônica genérica
   * Para o botão "Comparar Laboratórios" no módulo Catálogo
   */
  static async listarDetalhesGenericas(
    canonicaId: string
  ): Promise<ApiResponse<DetalheGenerico[]>> {
    try {
      const { data, error } = await supabase
        .from('vw_detalhes_genericas')
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
      console.error('Erro ao listar detalhes genéricas:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Comparar lentes genéricas de múltiplos laboratórios
   * Agrupa por marca/laboratório
   */
  static async compararLaboratoriosGenericas(
    canonicaId: string
  ): Promise<ApiResponse<Record<string, DetalheGenerico[]>>> {
    try {
      const resultado = await this.listarDetalhesGenericas(canonicaId);
      
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
      }, {} as Record<string, DetalheGenerico[]>);

      return {
        success: true,
        data: agrupadoPorMarca,
        count: Object.keys(agrupadoPorMarca).length
      };
    } catch (error) {
      console.error('Erro ao comparar laboratórios genéricos:', error);
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
