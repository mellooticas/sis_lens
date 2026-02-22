/**
 * Hook para gerenciar marcas
 * Atualizado para Migration 210 (Tabela catalog_lenses.brands global + per-tenant)
 */

import { writable, get } from 'svelte/store';
import { LensOracleAPI } from '$lib/api/lens-oracle';
import type { VBrand } from '$lib/types/database-views';

interface MarcasState {
  marcas: VBrand[];
  marcasPremium: VBrand[];
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

  async function carregarMarcas() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const res = await LensOracleAPI.getBrands({ scope: 'both' });

    if (res.data) {
      const marcas = res.data;
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
        error: res.error?.message || 'Erro ao carregar marcas'
      }));
    }
  }

  function obterMarcaPorId(brandId: string): VBrand | undefined {
    return get(state).marcas.find(m => m.brand_id === brandId);
  }

  function obterMarcaPorSlug(slug: string): VBrand | undefined {
    return get(state).marcas.find(m => m.slug === slug);
  }

  return {
    state,
    carregarMarcas,
    obterMarcaPorId,
    obterMarcaPorSlug
  };
}
