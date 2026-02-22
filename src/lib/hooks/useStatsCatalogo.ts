/**
 * Hook para estatísticas do catálogo
 * Usa a nova API consolidada LensOracleAPI
 */

import { writable } from 'svelte/store';
import { LensOracleAPI } from '$lib/api/lens-oracle';
import type { VCatalogLensStats } from '$lib/types/database-views';

interface StatsCatalogoState {
  stats: VCatalogLensStats | null;
  loading: boolean;
  error: string | null;
}

export function useStatsCatalogo() {
  const state = writable<StatsCatalogoState>({
    stats: null,
    loading: false,
    error: null
  });

  async function carregarEstatisticas() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const res = await LensOracleAPI.getCatalogStats();

    if (res.data) {
      state.update(s => ({
        ...s,
        stats: res.data || null,
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: res.error?.message || 'Erro ao carregar estatísticas'
      }));
    }
  }

  return {
    state,
    carregarEstatisticas
  };
}
