/**
 * Hook para gerenciar fornecedores
 * Usa a view vw_fornecedores do banco de dados
 */

import { writable, get } from 'svelte/store';
import { viewsApi } from '$lib/api/views-client';
import type { VwFornecedores } from '$lib/types/views';

interface FornecedoresState {
  fornecedores: VwFornecedores[];
  loading: boolean;
  error: string | null;
}

export function useFornecedores() {
  const state = writable<FornecedoresState>({
    fornecedores: [],
    loading: false,
    error: null
  });

  /**
   * Carregar todos os fornecedores
   */
  async function carregarFornecedores() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.listarFornecedores();

    if (response.success && response.data) {
      state.update(s => ({
        ...s,
        fornecedores: response.data || [],
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao carregar fornecedores'
      }));
    }
  }

  /**
   * Obter fornecedor por ID
   */
  function obterFornecedorPorId(fornecedorId: string): VwFornecedores | undefined {
    const currentState = get(state);
    return currentState.fornecedores.find(f => f.id === fornecedorId);
  }

  /**
   * Obter fornecedores ordenados por preço médio
   */
  function obterFornecedoresOrdenadosPorPreco(): VwFornecedores[] {
    const currentState = get(state);
    return [...currentState.fornecedores].sort((a, b) => a.preco_medio - b.preco_medio);
  }

  /**
   * Obter fornecedores com maior catálogo
   */
  function obterFornecedoresPorCatalogo(): VwFornecedores[] {
    const currentState = get(state);
    return [...currentState.fornecedores].sort((a, b) => b.total_lentes - a.total_lentes);
  }

  return {
    state,
    carregarFornecedores,
    obterFornecedorPorId,
    obterFornecedoresOrdenadosPorPreco,
    obterFornecedoresPorCatalogo
  };
}
