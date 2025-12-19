/**
 * Hook para gerenciar filtros disponíveis
 * Usa a view vw_filtros_disponiveis do banco de dados
 */

import { writable } from 'svelte/store';
import { viewsApi } from '$lib/api/views-client';
import type { VwFiltrosDisponiveis } from '$lib/types/views';

interface FiltrosState {
  filtros: VwFiltrosDisponiveis | null;
  loading: boolean;
  error: string | null;
}

export function useFiltros() {
  const state = writable<FiltrosState>({
    filtros: null,
    loading: false,
    error: null
  });

  /**
   * Carregar filtros disponíveis
   */
  async function carregarFiltros() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.obterFiltrosDisponiveis();

    if (response.success && response.data) {
      state.update(s => ({
        ...s,
        filtros: response.data || null,
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao carregar filtros'
      }));
    }
  }

  return {
    state,
    carregarFiltros
  };
}
