import { supabase } from '$lib/supabase';
import type { LenteContato, FiltrosLentesContato } from '$lib/types/contact-lens';

export class ContactLensAPI {
  
  /**
   * Busca lentes de contato com filtros e paginação
   */
  static async buscarLentes(
    filtros: FiltrosLentesContato,
    pagina: number = 1,
    limite: number = 12
  ) {
    try {
      let query = supabase
        .from('v_lentes_contato') // View pública
        .select('*', { count: 'exact' });

      // Filtros
      if (filtros.busca) {
        query = query.or(`nome_produto.ilike.%${filtros.busca}%,marca_nome.ilike.%${filtros.busca}%`);
      }
      
      if (filtros.tipos && filtros.tipos.length > 0) {
        query = query.in('tipo_lente', filtros.tipos);
      }

      if (filtros.materiais && filtros.materiais.length > 0) {
        query = query.in('material', filtros.materiais);
      }

      if (filtros.finalidades && filtros.finalidades.length > 0) {
        query = query.in('finalidade', filtros.finalidades);
      }

      if (filtros.marcas && filtros.marcas.length > 0) {
        query = query.in('marca_nome', filtros.marcas);
      }

      if (filtros.fabricantes && filtros.fabricantes.length > 0) {
        query = query.in('fabricante_nome', filtros.fabricantes);
      }

      if (filtros.fornecedores && filtros.fornecedores.length > 0) {
        query = query.in('fornecedor_nome', filtros.fornecedores);
      }

      if (filtros.precoMin !== undefined) {
        query = query.gte('preco_tabela', filtros.precoMin);
      }
      
      if (filtros.precoMax !== undefined) {
        query = query.lte('preco_tabela', filtros.precoMax);
      }

      // Paginação
      const de = (pagina - 1) * limite;
      const ate = de + limite - 1;
      
      query = query
        .order('nome_produto', { ascending: true })
        .range(de, ate);

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: (data as LenteContato[]) || [],
        total: count || 0,
        paginas: Math.ceil((count || 0) / limite)
      };

    } catch (error) {
      console.error('Erro ao buscar lentes de contato:', error);
      return { success: false, error: 'Falha ao carregar lentes' };
    }
  }

  /**
   * Busca opções para os filtros (Marcas, Fabricantes, Fornecedores)
   */
  static async buscarOpcoesFiltro() {
    try {
      // Buscar marcas únicas e fornecedores únicos
      const { data } = await supabase
        .from('v_lentes_contato')
        .select('marca_nome, fornecedor_nome');

      const uniqueMarcas = [...new Set(data?.map(m => m.marca_nome))].filter(Boolean).sort();
      const uniqueFornecedores = [...new Set(data?.map(m => m.fornecedor_nome))].filter(Boolean).sort();

      return {
        marcas: uniqueMarcas,
        fornecedores: uniqueFornecedores
      };
    } catch (error) {
      return { marcas: [], fornecedores: [] };
    }
  }
  /**
   * Busca detalhes de uma única lente pelo ID
   */
  static async obterLente(id: string) {
    try {
      const { data, error } = await supabase
        .from('v_lentes_contato')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data as LenteContato
      };
    } catch (error) {
      console.error('Erro ao buscar detalhes da lente:', error);
      return { success: false, error: 'Falha ao carregar detalhes' };
    }
  }
  /**
   * Atualizar preços e status de uma lente de contato
   */
  static async atualizarLente(params: {
    id: string;
    preco_custo: number;
    preco_tabela: number;
    ativo: boolean;
  }): Promise<{ success: boolean; error?: string }> {
    try {
      const { error } = await supabase.rpc('update_lente_contact', {
        p_id: params.id,
        p_preco_custo: params.preco_custo,
        p_preco_tabela: params.preco_tabela,
        p_ativo: params.ativo
      });

      if (error) throw error;

      return { success: true };
    } catch (error) {
      console.error('Erro ao atualizar lente de contato:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }
}
