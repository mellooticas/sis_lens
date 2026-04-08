/**
 * lib/hooks/useLentesCatalogo.ts — Svelte stores para lens catalog
 *
 * Thin wrappers over lentes-repository.ts.
 * All logic lives in the DB RPCs — these stores just cache & manage state.
 */

import { writable, derived, get } from 'svelte/store'
import {
  buscarCanonicosPorReceita,
  buscarLentesDoCanonical,
  buscarLentes,
  buscarFiltrosDisponiveis,
  buscarFornecedoresLentes,
  getPremiumFilterOptionsV3,
  searchPremiumV3,
  getStandardFilterOptionsV3,
  searchStandardV3,
  type LensSupplier,
} from '$lib/api/lentes-repository'
import type {
  PrescriptionInput,
  LensSearchFilters,
  PremiumFilterOptions,
  StandardFilterOptions,
  CanonicalPremiumV3,
  CanonicalStandardV3,
  CanonicalSearchResultV3,
  PremiumFilterParamsV3,
  PremiumSearchParamsV3,
  StandardFilterParamsV3,
  StandardSearchParamsV3,
  CanonicalForPrescription,
  CanonicalLensOption,
  CatalogLens,
  LensFilterOptions,
} from '$lib/types/lentes'

// Re-export types for components
export type {
  PrescriptionInput,
  CanonicalForPrescription,
  CanonicalLensOption,
  CatalogLens,
  LensFilterOptions,
  LensSearchFilters,
}

// ============================================================
// CANONICAL: browse & filter
// ============================================================

/**
 * Find canonical concepts matching a prescription.
 */
export function useCanonicalForPrescription(rx: PrescriptionInput) {
  const loading = writable(false)
  const data = writable<CanonicalForPrescription[]>([])
  const error = writable<string | null>(null)

  async function fetch() {
    loading.set(true)
    error.set(null)
    try {
      const result = await buscarCanonicosPorReceita(rx)
      data.set(result)
    } catch (err: any) {
      error.set(err.message ?? 'Erro ao buscar por receita')
    } finally {
      loading.set(false)
    }
  }

  return { loading, data, error, fetch }
}

// ============================================================
// REAL LENSES: per canonical concept
// ============================================================

/**
 * Get real lens options for a canonical concept (brands, suppliers, prices).
 */
export function useCanonicalDetail(canonicalId: string | null, isPremium: boolean = false) {
  const loading = writable(false)
  const data = writable<CanonicalLensOption[]>([])
  const error = writable<string | null>(null)

  async function fetch() {
    if (!canonicalId) {
      data.set([])
      return
    }
    loading.set(true)
    error.set(null)
    try {
      const result = await buscarLentesDoCanonical(canonicalId, isPremium)
      data.set(result)
    } catch (err: any) {
      error.set(err.message ?? 'Erro ao buscar detalhes da lente')
    } finally {
      loading.set(false)
    }
  }

  return { loading, data, error, fetch }
}

// ============================================================
// DIRECT SEARCH: bypass canonical
// ============================================================

/**
 * Search real lenses directly with filters.
 */
export function useLensSearch(filtros?: LensSearchFilters) {
  const loading = writable(true)
  const data = writable<CatalogLens[]>([])
  const error = writable<string | null>(null)

  async function fetch() {
    loading.set(true)
    error.set(null)
    try {
      const result = await buscarLentes(filtros)
      data.set(result)
    } catch (err: any) {
      error.set(err.message ?? 'Erro ao buscar lentes')
    } finally {
      loading.set(false)
    }
  }

  return { loading, data, error, fetch }
}

/**
 * Get distinct suppliers from catalog.
 */
export function useLensSuppliers() {
  const loading = writable(true)
  const data = writable<LensSupplier[]>([])
  const error = writable<string | null>(null)

  async function fetch() {
    loading.set(true)
    error.set(null)
    try {
      const result = await buscarFornecedoresLentes()
      data.set(result)
    } catch (err: any) {
      error.set(err.message ?? 'Erro ao buscar fornecedores')
    } finally {
      loading.set(false)
    }
  }

  return { loading, data, error, fetch }
}

// ============================================================
// FILTERS: dynamic options
// ============================================================

/**
 * Get available filter options from DB.
 */
export function useLensFilters() {
  const loading = writable(true)
  const data = writable<LensFilterOptions | null>(null)
  const error = writable<string | null>(null)

  async function fetch() {
    loading.set(true)
    error.set(null)
    try {
      const result = await buscarFiltrosDisponiveis()
      data.set(result)
    } catch (err: any) {
      error.set(err.message ?? 'Erro ao buscar filtros')
    } finally {
      loading.set(false)
    }
  }

  return { loading, data, error, fetch }
}

// ============================================================================
// CANONICAL ENGINE v3 — Stores para Filtros Estruturados Premium
// ============================================================================

export function usePremiumFilterOptionsV3(params: PremiumFilterParamsV3 = {}) {
  const loading = writable(true)
  const data = writable<PremiumFilterOptions | null>(null)
  const error = writable<string | null>(null)

  const store = derived([loading, data, error], ([$loading, $data, $error]) => ({
    loading: $loading,
    data: $data,
    error: $error,
  }))

  async function fetch() {
    loading.set(true)
    error.set(null)
    try {
      const result = await getPremiumFilterOptionsV3(params)
      data.set(result)
    } catch (err: any) {
      error.set(err.message ?? 'Erro ao buscar filtros premium')
    } finally {
      loading.set(false)
    }
  }

  fetch() // Carrega inicial
  return { subscribe: store.subscribe, fetch }
}

export function usePremiumSearchV3(params: PremiumSearchParamsV3 = {}) {
  const loading = writable(true)
  const data = writable<CanonicalSearchResultV3<CanonicalPremiumV3> | null>(null)
  const error = writable<string | null>(null)

  const store = derived([loading, data, error], ([$loading, $data, $error]) => ({
    loading: $loading,
    data: $data,
    error: $error,
  }))

  async function fetch() {
    loading.set(true)
    error.set(null)
    try {
      const result = await searchPremiumV3(params)
      data.set(result)
    } catch (err: any) {
      error.set(err.message ?? 'Erro ao buscar premium')
    } finally {
      loading.set(false)
    }
  }

  fetch() // Carrega inicial
  return { subscribe: store.subscribe, fetch }
}

// ============================================================================
// CANONICAL ENGINE v3 — Stores para Filtros Estruturados Standard
// ============================================================================

export function useStandardFilterOptionsV3(params: StandardFilterParamsV3 = {}) {
  const loading = writable(true)
  const data = writable<StandardFilterOptions | null>(null)
  const error = writable<string | null>(null)

  const store = derived([loading, data, error], ([$loading, $data, $error]) => ({
    loading: $loading,
    data: $data,
    error: $error,
  }))

  async function fetch() {
    loading.set(true)
    error.set(null)
    try {
      const result = await getStandardFilterOptionsV3(params)
      data.set(result)
    } catch (err: any) {
      error.set(err.message ?? 'Erro ao buscar filtros standard')
    } finally {
      loading.set(false)
    }
  }

  fetch() // Carrega inicial
  return { subscribe: store.subscribe, fetch }
}

export function useStandardSearchV3(params: StandardSearchParamsV3 = {}) {
  const loading = writable(true)
  const data = writable<CanonicalSearchResultV3<CanonicalStandardV3> | null>(null)
  const error = writable<string | null>(null)

  const store = derived([loading, data, error], ([$loading, $data, $error]) => ({
    loading: $loading,
    data: $data,
    error: $error,
  }))

  async function fetch() {
    loading.set(true)
    error.set(null)
    try {
      const result = await searchStandardV3(params)
      data.set(result)
    } catch (err: any) {
      error.set(err.message ?? 'Erro ao buscar standard')
    } finally {
      loading.set(false)
    }
  }

  fetch() // Carrega inicial
  return { subscribe: store.subscribe, fetch }
}
