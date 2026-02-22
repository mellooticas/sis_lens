/**
 * Hook para grupos canônicos
 * NOVO BANCO: usa LensOracleAPI.searchLenses com is_premium filter
 * Os "grupos canônicos" são representados pelo conjunto de lentes com mesmo material/tipo/índice
 */

import { writable, get } from 'svelte/store';
import { LensOracleAPI } from '$lib/api/lens-oracle';
import type { RpcLensSearchResult } from '$lib/types/database-views';

// No novo banco grupos são lentes agrupadas — usamos RpcLensSearchResult
export type VCatalogLensGroupNew = RpcLensSearchResult & {
  is_active: boolean;
};

interface GruposState {
  gruposGenericos: RpcLensSearchResult[];
  gruposPremium: RpcLensSearchResult[];
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

  async function carregarGruposGenericos(params: { limit?: number; offset?: number } = {}) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const res = await LensOracleAPI.searchLenses({
      is_premium: false,
      limit: params.limit ?? 50,
      offset: params.offset ?? 0
    });

    if (res.data) {
      state.update(s => ({
        ...s,
        gruposGenericos: res.data!,
        totalGenericos: res.data!.length,
        loading: false
      }));
    } else {
      state.update(s => ({ ...s, loading: false, error: res.error?.message || 'Erro ao carregar grupos genéricos' }));
    }
  }

  async function carregarGruposPremium(params: { limit?: number; offset?: number } = {}) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const res = await LensOracleAPI.searchLenses({
      is_premium: true,
      limit: params.limit ?? 50,
      offset: params.offset ?? 0
    });

    if (res.data) {
      state.update(s => ({
        ...s,
        gruposPremium: res.data!,
        totalPremium: res.data!.length,
        loading: false
      }));
    } else {
      state.update(s => ({ ...s, loading: false, error: res.error?.message || 'Erro ao carregar grupos premium' }));
    }
  }

  async function carregarTodosGrupos(params: { limit?: number; offset?: number } = {}) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const [resPremium, resGenericos] = await Promise.all([
      LensOracleAPI.searchLenses({ is_premium: true,  limit: params.limit ?? 50, offset: 0 }),
      LensOracleAPI.searchLenses({ is_premium: false, limit: params.limit ?? 50, offset: 0 }),
    ]);

    state.update(s => ({
      ...s,
      gruposPremium:   resPremium.data   ?? [],
      gruposGenericos: resGenericos.data ?? [],
      totalPremium:    resPremium.data?.length   ?? 0,
      totalGenericos:  resGenericos.data?.length ?? 0,
      loading: false,
      error: resPremium.error?.message || resGenericos.error?.message || null
    }));
  }

  function obterGrupoGenericoPorId(id: string) {
    return get(state).gruposGenericos.find(g => g.id === id);
  }

  function obterGrupoPremiumPorId(id: string) {
    return get(state).gruposPremium.find(g => g.id === id);
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
