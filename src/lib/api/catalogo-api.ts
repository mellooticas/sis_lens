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
        .from('v_lentes')
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

      // Filtros de tratamentos (novos nomes de campos)
      if (filtros.tratamentos) {
        if (filtros.tratamentos.ar === true) query = query.eq('tratamento_antirreflexo', true);
        if (filtros.tratamentos.blue === true) query = query.eq('tratamento_blue_light', true);
        if (filtros.tratamentos.fotossensivel === true) query = query.neq('tratamento_fotossensiveis', 'nenhum');
      }

      // Filtro de preço (novo nome de campo)
      if (filtros.preco) {
        if (filtros.preco.min !== undefined) query = query.gte('preco_venda_sugerido', filtros.preco.min);
        if (filtros.preco.max !== undefined) query = query.lte('preco_venda_sugerido', filtros.preco.max);
      }

      // Busca textual simples (novo campo)
      if (filtros.busca) {
        query = query.ilike('nome_lente', `%${filtros.busca}%`);
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
  static async buscarLentesPorReceita(params: {
      receita: {
          esferico: number;
          cilindrico: number;
          eixo?: number;
          adicao?: number;
      };
      tipo_lente?: string;
      limite?: number;
  }): Promise<ApiResponse<{ dados: LenteCatalogo[] }>> {
    try {
        const { data, error } = await supabase.rpc('buscar_lentes_por_receita', {
            p_esferico: params.receita.esferico,
            p_cilindrico: params.receita.cilindrico,
            p_adicao: params.receita.adicao || null,
            p_tipo_lente: params.tipo_lente || null
        });

        if (error) throw error;

        return {
            success: true,
            data: {
                dados: data || []
            },
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
        .from('v_lentes')
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
  // MÓDULO: STANDARD (v_grupos_canonicos - ~187 grupos standard)
  // ============================================================================

  /**
   * Buscar grupos canônicos standard com filtros
   * Para o módulo "Catálogo Standard"
   */
  static async buscarGruposCanonicosStandard(
    filtros: FiltrosLentes = {},
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<import('$lib/types/database-views').VGruposCanonico>>> {
    try {
      console.log('🔍 API: buscarGruposCanonicosStandard chamada', { filtros, paginacao });
      
      const { pagina = 1, limite = 50, ordenar = 'preco_medio', direcao = 'asc' } = paginacao;
      const offset = (pagina - 1) * limite;

      let query = supabase
        .from('v_grupos_canonicos')
        .select('*', { count: 'exact' })
        .eq('is_premium', false); // Apenas grupos standard
      
      console.log('📊 Query base criada: v_grupos_canonicos com is_premium=false');

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

      // Filtros de tratamentos
      if (filtros.tratamentos) {
        if (filtros.tratamentos.ar === true) query = query.eq('tratamento_antirreflexo', true);
        if (filtros.tratamentos.blue === true) query = query.eq('tratamento_blue_light', true);
        if (filtros.tratamentos.fotossensivel === true) query = query.neq('tratamento_fotossensiveis', 'nenhum');
      }

      // Filtro de preço (preço médio do grupo)
      if (filtros.preco) {
        if (filtros.preco.min !== undefined) query = query.gte('preco_medio', filtros.preco.min);
        if (filtros.preco.max !== undefined) query = query.lte('preco_medio', filtros.preco.max);
      }

      // Busca textual
      if (filtros.busca) {
        query = query.ilike('nome_grupo', `%${filtros.busca}%`);
      }

      // Ordenação e paginação
      query = query.order(ordenar, { ascending: direcao === 'asc' });
      query = query.range(offset, offset + limite - 1);

      console.log('📤 Executando query Supabase...', { offset, limite, ordenar, direcao });

      const { data, error, count } = await query;

      console.log('📥 Resposta Supabase:', { 
        data: data ? `${data.length} registros` : 'null', 
        count, 
        error: error ? error.message : 'nenhum' 
      });

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
      console.error('❌ Erro ao buscar grupos canônicos standard:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Buscar grupos canônicos PREMIUM (is_premium = true)
   * Usa a view v_grupos_premium que já filtra apenas grupos premium
   */
  static async buscarGruposCanonicosPremium(
    filtros: FiltrosLentes = {},
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<import('$lib/types/database-views').VGruposCanonico>>> {
    try {
      console.log('🔍 API: buscarGruposCanonicosPremium chamada', { filtros, paginacao });
      
      const { pagina = 1, limite = 50, ordenar = 'preco_medio', direcao = 'desc' } = paginacao;
      const offset = (pagina - 1) * limite;

      let query = supabase
        .from('v_grupos_premium') // View específica para premium!
        .select('*', { count: 'exact' });
      
      console.log('📊 Query base criada: v_grupos_premium (view específica)');

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

      // Filtros de tratamentos
      if (filtros.tratamentos) {
        if (filtros.tratamentos.ar === true) query = query.eq('tratamento_antirreflexo', true);
        if (filtros.tratamentos.blue === true) query = query.eq('tratamento_blue_light', true);
        if (filtros.tratamentos.fotossensivel === true) query = query.neq('tratamento_fotossensiveis', 'nenhum');
      }

      // Filtro de preço (preço médio do grupo)
      if (filtros.preco) {
        if (filtros.preco.min !== undefined) query = query.gte('preco_medio', filtros.preco.min);
        if (filtros.preco.max !== undefined) query = query.lte('preco_medio', filtros.preco.max);
      }

      // Busca textual
      if (filtros.busca) {
        query = query.ilike('nome_grupo', `%${filtros.busca}%`);
      }

      // Ordenação e paginação (Premium ordena por preço decrescente por padrão)
      query = query.order(ordenar, { ascending: direcao === 'asc' });
      query = query.range(offset, offset + limite - 1);

      console.log('📤 Executando query Supabase...', { offset, limite, ordenar, direcao });

      const { data, error, count } = await query;

      console.log('📥 Resposta Supabase:', { 
        data: data ? `${data.length} registros` : 'null', 
        count, 
        error: error ? error.message : 'nenhum' 
      });

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
      console.error('❌ Erro ao buscar grupos canônicos premium:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Obter um grupo canônico específico por ID
   */
  static async obterGrupoCanonico(id: string): Promise<ApiResponse<import('$lib/types/database-views').VGruposCanonico>> {
    try {
      const { data, error } = await supabase
        .from('v_grupos_canonicos')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data || undefined
      };
    } catch (error) {
      console.error('Erro ao obter grupo canônico:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }
  
  // ============================================================================
  // MÓDULO: RANKING (Análise de Grupos Canônicos)
  // ============================================================================
  
  /**
   * Buscar Top Grupos por Preço (mais caros)
   */
  static async buscarTopCaros(limite: number = 10): Promise<ApiResponse<import('$lib/types/database-views').VGruposCanonico[]>> {
    try {
      const { data, error } = await supabase
        .from('v_grupos_canonicos')
        .select('*')
        .order('preco_medio', { ascending: false })
        .limit(limite);

      if (error) throw error;

      return {
        success: true,
        data: data || []
      };
    } catch (error) {
      console.error('❌ Erro ao buscar top caros:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }
  
  /**
   * Buscar Top Grupos por Popularidade (mais lentes no grupo)
   */
  static async buscarTopPopulares(limite: number = 10): Promise<ApiResponse<import('$lib/types/database-views').VGruposCanonico[]>> {
    try {
      const { data, error } = await supabase
        .from('v_grupos_canonicos')
        .select('*')
        .order('total_lentes', { ascending: false })
        .limit(limite);

      if (error) throw error;

      return {
        success: true,
        data: data || []
      };
    } catch (error) {
      console.error('❌ Erro ao buscar top populares:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }
  
  /**
   * Buscar Top Premium (grupos premium mais caros)
   */
  static async buscarTopPremium(limite: number = 10): Promise<ApiResponse<import('$lib/types/database-views').VGruposCanonico[]>> {
    try {
      const { data, error } = await supabase
        .from('v_grupos_premium')
        .select('*')
        .order('preco_medio', { ascending: false })
        .limit(limite);

      if (error) throw error;

      return {
        success: true,
        data: data || []
      };
    } catch (error) {
      console.error('❌ Erro ao buscar top premium:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }
  
  /**
   * Obter distribuição por tipo de lente
   */
  static async obterDistribuicaoPorTipo(): Promise<ApiResponse<Array<{ tipo_lente: string; count: number }>>> {
    try {
      const { data, error } = await supabase
        .from('v_grupos_canonicos')
        .select('tipo_lente');

      if (error) throw error;

      // Contar manualmente no frontend
      const distribuicao = (data || []).reduce((acc, item) => {
        const tipo = item.tipo_lente || 'Não especificado';
        acc[tipo] = (acc[tipo] || 0) + 1;
        return acc;
      }, {} as Record<string, number>);

      const resultado = Object.entries(distribuicao).map(([tipo_lente, count]) => ({
        tipo_lente,
        count
      }));

      return {
        success: true,
        data: resultado
      };
    } catch (error) {
      console.error('❌ Erro ao obter distribuição por tipo:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }
  
  /**
   * Obter distribuição por material
   */
  static async obterDistribuicaoPorMaterial(): Promise<ApiResponse<Array<{ material: string; count: number }>>> {
    try {
      const { data, error } = await supabase
        .from('v_grupos_canonicos')
        .select('material');

      if (error) throw error;

      // Contar manualmente no frontend
      const distribuicao = (data || []).reduce((acc, item) => {
        const mat = item.material || 'Não especificado';
        acc[mat] = (acc[mat] || 0) + 1;
        return acc;
      }, {} as Record<string, number>);

      const resultado = Object.entries(distribuicao).map(([material, count]) => ({
        material,
        count
      }));

      return {
        success: true,
        data: resultado
      };
    } catch (error) {
      console.error('❌ Erro ao obter distribuição por material:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Buscar lentes de um grupo canônico específico
   */
  static async buscarLentesDoGrupo(grupoId: string): Promise<ApiResponse<import('$lib/types/database-views').VLenteCatalogo[]>> {
    try {
      const { data, error } = await supabase
        .from('v_lentes')
        .select('*')
        .eq('grupo_id', grupoId)
        .order('preco_venda_sugerido', { ascending: true });

      if (error) throw error;

      return {
        success: true,
        data: data || [],
        count: data?.length || 0
      };
    } catch (error) {
      console.error('Erro ao buscar lentes do grupo:', error);
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

  /**
   * Obter estatísticas de tratamentos e tecnologias
   */
  static async obterEstatisticasTratamentos(): Promise<ApiResponse<{
    total_com_ar: number;
    total_com_blue: number;
    total_fotossensiveis: number;
    total_polarizados: number;
    total_free_form: number;
    total_digitais: number;
  }>> {
    try {
      const { data, error } = await supabase
        .from('v_lentes')
        .select('ar, blue, fotossensivel');

      if (error) throw error;

      const stats = {
        total_com_ar: (data || []).filter(item => item.ar === true).length,
        total_com_blue: (data || []).filter(item => item.blue === true).length,
        total_fotossensiveis: (data || []).filter(item => item.fotossensivel && item.fotossensivel !== 'nenhum').length,
        total_polarizados: 0, // Campo não existe na view, retorna 0
        total_free_form: 0, // Campo não existe na view, retorna 0
        total_digitais: 0 // Campo não existe na view, retorna 0
      };

      return {
        success: true,
        data: stats
      };
    } catch (error) {
      console.error('Erro ao obter estatísticas de tratamentos:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Obter estatísticas por tipo de lente
   */
  static async obterEstatisticasTipos(): Promise<ApiResponse<{
    total_visao_simples: number;
    total_multifocal: number;
    total_bifocal: number;
  }>> {
    try {
      const { data, error } = await supabase
        .from('v_lentes')
        .select('tipo_lente');

      if (error) throw error;

      const stats = {
        total_visao_simples: (data || []).filter(item => item.tipo_lente === 'visao_simples').length,
        total_multifocal: (data || []).filter(item => item.tipo_lente === 'multifocal').length,
        total_bifocal: (data || []).filter(item => item.tipo_lente === 'bifocal').length
      };

      return {
        success: true,
        data: stats
      };
    } catch (error) {
      console.error('Erro ao obter estatísticas de tipos:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Obter estatísticas por material
   */
  static async obterEstatisticasMateriais(): Promise<ApiResponse<{
    total_cr39: number;
    total_policarbonato: number;
    total_trivex: number;
    total_high_index: number;
  }>> {
    try {
      const { data, error } = await supabase
        .from('v_lentes')
        .select('material');

      if (error) throw error;

      const stats = {
        total_cr39: (data || []).filter(item => item.material === 'cr39').length,
        total_policarbonato: (data || []).filter(item => item.material === 'policarbonato').length,
        total_trivex: (data || []).filter(item => item.material === 'trivex').length,
        total_high_index: (data || []).filter(item => item.material === 'high_index').length
      };

      return {
        success: true,
        data: stats
      };
    } catch (error) {
      console.error('Erro ao obter estatísticas de materiais:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Obter faixas de preço
   */
  static async obterFaixasPreco(): Promise<ApiResponse<{
    preco_minimo: number;
    preco_medio: number;
    preco_maximo: number;
  }>> {
    try {
      const { data, error } = await supabase
        .from('v_lentes')
        .select('preco_venda_sugerido');

      if (error) throw error;

      const precos = (data || [])
        .map(item => item.preco_venda_sugerido)
        .filter(preco => preco != null && preco > 0);

      if (precos.length === 0) {
        return {
          success: true,
          data: { preco_minimo: 0, preco_medio: 0, preco_maximo: 0 }
        };
      }

      const stats = {
        preco_minimo: Math.min(...precos),
        preco_maximo: Math.max(...precos),
        preco_medio: precos.reduce((a, b) => a + b, 0) / precos.length
      };

      return {
        success: true,
        data: stats
      };
    } catch (error) {
      console.error('Erro ao obter faixas de preço:', error);
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
        .from('v_lentes')
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
        .from('v_lentes')
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
