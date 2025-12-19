/**
 * Hook para estatísticas do catálogo
 * Usa a view vw_stats_catalogo do banco de dados
 */

import { writable } from 'svelte/store';
import { viewsApi } from '$lib/api/views-client';
import type { VwStatsCatalogo } from '$lib/types/views';

interface StatsCatalogoState {
  stats: VwStatsCatalogo | null;
  loading: boolean;
  error: string | null;
}

export function useStatsCatalogo() {
  const state = writable<StatsCatalogoState>({
    stats: null,
    loading: false,
    error: null
  });

  /**
   * Carregar estatísticas do catálogo
   */
  async function carregarEstatisticas() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.obterEstatisticasCatalogo();

    if (response.success && response.data) {
      state.update(s => ({
        ...s,
        stats: response.data || null,
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao carregar estatísticas'
      }));
    }
  }

  return {
    state,
    carregarEstatisticas
  };
}
