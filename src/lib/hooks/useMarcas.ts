/**
 * Hook para gerenciar marcas
 * Usa a view vw_marcas do banco de dados
 */

import { writable, get } from 'svelte/store';
import { viewsApi } from '$lib/api/views-client';
import type { VwMarcas } from '$lib/types/views';

interface MarcasState {
  marcas: VwMarcas[];
  marcasPremium: VwMarcas[];
  loading: boolean;
  error: string | null;
}

export function useMarcas() {
  const state = writable<MarcasState>({
    marcas: [],
    marcasPremium: [],
    loading: false,
    error: null
  });

  /**
   * Carregar todas as marcas
   */
  async function carregarMarcas() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.listarMarcas();

    if (response.success && response.data) {
      const marcas = response.data;
      const marcasPremium = marcas.filter(m => m.is_premium);

      state.update(s => ({
        ...s,
        marcas,
        marcasPremium,
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao carregar marcas'
      }));
    }
  }

  /**
   * Obter marca por ID
   */
  function obterMarcaPorId(marcaId: string): VwMarcas | undefined {
    const currentState = get(state);
    return currentState.marcas.find(m => m.id === marcaId);
  }

  /**
   * Obter marca por slug
   */
  function obterMarcaPorSlug(slug: string): VwMarcas | undefined {
    const currentState = get(state);
    return currentState.marcas.find(m => m.slug === slug);
  }

  return {
    state,
    carregarMarcas,
    obterMarcaPorId,
    obterMarcaPorSlug
  };
}
