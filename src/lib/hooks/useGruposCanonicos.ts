/**
 * Hook para gerenciar grupos canônicos
 * NOVO BANCO: usa v_catalog_lens_groups (a criar) / fallback via v_catalog_lenses
 */

import { writable, get } from 'svelte/store';
import { viewsApi } from '$lib/api/views-client';
import type { VCatalogLensGroup } from '$lib/types/database-views';
import type { BuscarGruposParams } from '$lib/api/views-client';

interface GruposState {
  gruposGenericos: VCatalogLensGroup[];
  gruposPremium: VCatalogLensGroup[];
  loading: boolean;
  error: string | null;
  totalGenericos: number;
  totalPremium: number;
}

export function useGruposCanonicos() {
  const state = writable<GruposState>({
    gruposGenericos: [],
    gruposPremium: [],
    loading: false,
    error: null,
    totalGenericos: 0,
    totalPremium: 0
  });

  /**
   * Carregar grupos genéricos (is_premium = false)
   */
  async function carregarGruposGenericos(params: BuscarGruposParams = {}) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.buscarGruposGenericos(params);

    if (response.success && response.data) {
      state.update(s => ({
        ...s,
        gruposGenericos: response.data || [],
        totalGenericos: response.total || 0,
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao carregar grupos genéricos'
      }));
    }
  }

  /**
   * Carregar grupos premium (is_premium = true)
   */
  async function carregarGruposPremium(params: BuscarGruposParams = {}) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.buscarGruposPremium(params);

    if (response.success && response.data) {
      state.update(s => ({
        ...s,
        gruposPremium: response.data || [],
        totalPremium: response.total || 0,
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao carregar grupos premium'
      }));
    }
  }

  /**
   * Carregar todos os grupos (genéricos e premium em paralelo)
   */
  async function carregarTodosGrupos(params: BuscarGruposParams = {}) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const [responsePremium, responseGenericos] = await Promise.all([
      viewsApi.buscarGruposPremium(params),
      viewsApi.buscarGruposGenericos(params)
    ]);

    if (responsePremium.success && responseGenericos.success) {
      state.update(s => ({
        ...s,
        gruposPremium: responsePremium.data || [],
        gruposGenericos: responseGenericos.data || [],
        totalPremium: responsePremium.total || 0,
        totalGenericos: responseGenericos.total || 0,
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: 'Erro ao carregar grupos canônicos'
      }));
    }
  }

  /**
   * Obter grupo genérico por ID
   */
  function obterGrupoGenericoPorId(grupoId: string): VCatalogLensGroup | undefined {
    const currentState = get(state);
    return currentState.gruposGenericos.find(g => g.id === grupoId);
  }

  /**
   * Obter grupo premium por ID
   */
  function obterGrupoPremiumPorId(grupoId: string): VCatalogLensGroup | undefined {
    const currentState = get(state);
    return currentState.gruposPremium.find(g => g.id === grupoId);
  }

  return {
    state,
    carregarGruposGenericos,
    carregarGruposPremium,
    carregarTodosGrupos,
    obterGrupoGenericoPorId,
    obterGrupoPremiumPorId
  };
}
