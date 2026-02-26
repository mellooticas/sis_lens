/**
 * Hook para grupos canônicos — Canonical Engine v2
 * Usa v_canonical_lenses_pricing e v_canonical_lenses_premium_pricing (migrations 274–277)
 * Tipos: CanonicalWithPricing (inclui SKU, pricing, treatment_codes)
 */

import { writable, get } from 'svelte/store';
import { LensOracleAPI } from '$lib/api/lens-oracle';
import type { CanonicalWithPricing } from '$lib/types/database-views';

export type { CanonicalWithPricing };

interface GruposState {
  gruposGenericos: CanonicalWithPricing[];
  gruposPremium: CanonicalWithPricing[];
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

  async function carregarGruposGenericos(params: {
    limit?: number;
    offset?: number;
    lens_type?: string;
    search?: string;
  } = {}) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const res = await LensOracleAPI.getCanonicalStandardWithPricing({
      limit:      params.limit    ?? 100,
      offset:     params.offset   ?? 0,
      lens_type:  params.lens_type,
      search:     params.search,
    });

    if (res.data) {
      state.update(s => ({
        ...s,
        gruposGenericos: res.data!,
        totalGenericos: res.data!.length,
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: res.error?.message || 'Erro ao carregar conceitos standard'
      }));
    }
  }

  async function carregarGruposPremium(params: {
    limit?: number;
    offset?: number;
    lens_type?: string;
    search?: string;
  } = {}) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const res = await LensOracleAPI.getCanonicalPremiumWithPricing({
      limit:      params.limit    ?? 100,
      offset:     params.offset   ?? 0,
      lens_type:  params.lens_type,
      search:     params.search,
    });

    if (res.data) {
      state.update(s => ({
        ...s,
        gruposPremium: res.data!,
        totalPremium: res.data!.length,
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: res.error?.message || 'Erro ao carregar conceitos premium'
      }));
    }
  }

  async function carregarTodosGrupos(params: {
    limit?: number;
    offset?: number;
  } = {}) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const [resPremium, resGenericos] = await Promise.all([
      LensOracleAPI.getCanonicalPremiumWithPricing({ limit: params.limit ?? 100 }),
      LensOracleAPI.getCanonicalStandardWithPricing({ limit: params.limit ?? 100 }),
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
