/**
 * Hook para gerenciar filtros disponíveis
 * NOVO BANCO: usa obterFiltrosDisponiveis() que agrega de v_catalog_lenses
 */

import { writable } from 'svelte/store';
import { viewsApi } from '$lib/api/views-client';

// Tipo que corresponde ao retorno de ViewsApiClient.obterFiltrosDisponiveis()
export interface FiltrosDisponiveis {
  tipos_lente: { valor: string; total: number }[];
  materiais: { valor: string; total: number }[];
  indices_refracao: { valor: string; total: number }[];
  categorias: { valor: string; total: number }[];
  marcas: { nome: string; count: number }[];
  fornecedores: { id: string; nome: string; count: number }[];
}

interface FiltrosState {
  filtros: FiltrosDisponiveis | null;
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
   * Carregar filtros disponíveis agregados de v_catalog_lenses
   */
  async function carregarFiltros() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.obterFiltrosDisponiveis();

    if (response.success && response.data) {
      state.update(s => ({
        ...s,
        filtros: response.data as FiltrosDisponiveis,
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
