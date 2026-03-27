/**
 * lib/api/lentes-repository.ts — Data access layer for lens catalog
 *
 * Thin wrapper over unified bank RPCs/views. All logic lives in the DB.
 * No other file should query lens data directly.
 *
 * RPCs: rpc_canonical_for_prescription, rpc_canonical_detail, rpc_lens_search
 * Views: v_canonical_lenses, v_catalog_lenses
 */

import { supabase } from '$lib/supabase'
import type {
  CanonicalForPrescription,
  CanonicalLensOption,
  CanonicalLens,
  CatalogLens,
  CanonicalFilters,
  PrescriptionInput,
  LensSearchFilters,
  LensFilterOptions,
  PremiumFilterOptions,
  StandardFilterOptions,
  CanonicalPremiumV3,
  CanonicalStandardV3,
  CanonicalSearchResultV3,
  PremiumFilterParamsV3,
  PremiumSearchParamsV3,
  StandardFilterParamsV3,
  StandardSearchParamsV3,
} from '$lib/types/lentes'

// ============================================================
// CANONICAL: groups by prescription (main wizard flow)
// ============================================================

/**
 * Find canonical concepts matching a prescription.
 * Calls rpc_canonical_for_prescription — all filtering done in DB.
 */
export async function buscarCanonicosPorReceita(
  rx: PrescriptionInput
): Promise<CanonicalForPrescription[]> {
  const { data, error } = await supabase.rpc('rpc_canonical_for_prescription', {
    p_spherical: rx.spherical ?? null,
    p_cylindrical: rx.cylindrical ?? null,
    p_addition: rx.addition ?? null,
    p_lens_type: rx.lens_type ?? null,
    p_is_premium: rx.is_premium ?? false,
  })

  if (error) {
    console.error('[LENTES] rpc_canonical_for_prescription error:', error)
    throw error
  }

  return (data ?? []) as CanonicalForPrescription[]
}

/**
 * Get real lens options for a canonical concept.
 * Calls rpc_canonical_detail — returns brands/suppliers/prices.
 */
export async function buscarLentesDoCanonical(
  canonicalId: string,
  isPremium: boolean = false
): Promise<CanonicalLensOption[]> {
  const { data, error } = await supabase.rpc('rpc_canonical_detail', {
    p_canonical_id: canonicalId,
    p_is_premium: isPremium,
  })

  if (error) {
    console.error('[LENTES] rpc_canonical_detail error:', error)
    throw error
  }

  return (data ?? []) as CanonicalLensOption[]
}

// ============================================================
// CANONICAL: browse all (filter/list view)
// ============================================================

/**
 * Browse canonical lenses with filters.
 * Queries v_canonical_lenses (or v_canonical_standard / v_canonical_premium).
 */
export async function buscarCanonicos(
  filtros?: CanonicalFilters
): Promise<CanonicalLens[]> {
  const viewName = filtros?.is_premium === true
    ? 'v_canonical_premium'
    : filtros?.is_premium === false
      ? 'v_canonical_standard'
      : 'v_canonical_lenses'

  let query = supabase
    .from(viewName)
    .select('*')
    .order('mapped_lens_count', { ascending: false })

  if (filtros?.lens_type) {
    query = query.eq('lens_type', filtros.lens_type)
  }
  if (filtros?.refractive_index) {
    query = query.eq('refractive_index', filtros.refractive_index)
  }
  if (filtros?.search) {
    query = query.ilike('canonical_name', `%${filtros.search}%`)
  }
  if (filtros?.price_min !== undefined) {
    query = query.gte('tenant_min_price', filtros.price_min)
  }
  if (filtros?.price_max !== undefined) {
    query = query.lte('tenant_max_price', filtros.price_max)
  }

  const { data, error } = await query

  if (error) {
    console.error('[LENTES] v_canonical_lenses error:', error)
    throw error
  }

  return (data ?? []) as CanonicalLens[]
}

// ============================================================
// DIRECT SEARCH: real lenses (bypass canonical)
// ============================================================

/**
 * Search real lenses directly (for "Por Laboratorio" flow).
 * Calls rpc_lens_search — all filtering done in DB.
 */
export async function buscarLentes(
  filtros?: LensSearchFilters
): Promise<CatalogLens[]> {
  const { data, error } = await supabase.rpc('rpc_lens_search', {
    p_lens_type: filtros?.lens_type ?? null,
    p_supplier_id: filtros?.supplier_id ?? null,
    p_brand_name: filtros?.brand_name ?? null,
    p_price_min: filtros?.price_min ?? null,
    p_price_max: filtros?.price_max ?? null,
    p_has_ar: filtros?.has_ar ?? null,
    p_has_blue: filtros?.has_blue ?? null,
    p_limit: filtros?.limit ?? 50,
    p_offset: filtros?.offset ?? 0,
  })

  if (error) {
    console.error('[LENTES] rpc_lens_search error:', error)
    throw error
  }

  return (data ?? []) as CatalogLens[]
}

// ============================================================
// SUPPLIERS: distinct suppliers from catalog
// ============================================================

export interface LensSupplier {
  supplier_id: string
  supplier_name: string
  lens_count: number
}

/**
 * Get distinct lens suppliers from the catalog.
 */
export async function buscarFornecedoresLentes(): Promise<LensSupplier[]> {
  const { data, error } = await supabase
    .from('v_catalog_lenses')
    .select('supplier_id, supplier_name')

  if (error) {
    console.error('[LENTES] supplier query error:', error)
    throw error
  }

  const map = new Map<string, { name: string; count: number }>()
  for (const row of data ?? []) {
    if (!row.supplier_id) continue
    const existing = map.get(row.supplier_id)
    if (existing) {
      existing.count++
    } else {
      map.set(row.supplier_id, { name: row.supplier_name || 'Sem nome', count: 1 })
    }
  }

  return Array.from(map.entries())
    .map(([id, d]) => ({ supplier_id: id, supplier_name: d.name, lens_count: d.count }))
    .sort((a, b) => a.supplier_name.localeCompare(b.supplier_name))
}

// ============================================================
// FILTERS: dynamic filter options from DB
// ============================================================

/**
 * Get available filter options from canonical lenses.
 * Queries DISTINCT values from v_canonical_lenses.
 */
export async function buscarFiltrosDisponiveis(): Promise<LensFilterOptions> {
  const { data, error } = await supabase
    .from('v_canonical_lenses')
    .select('lens_type, material, refractive_index')

  if (error) {
    console.error('[LENTES] filter options error:', error)
    return { lens_types: [], material_classes: [], refractive_indices: [] }
  }

  const rows = data ?? []
  return {
    lens_types: Array.from(new Set(rows.map(r => r.lens_type))).filter(Boolean).sort() as any[],
    material_classes: Array.from(new Set(rows.map(r => r.material))).filter(Boolean).sort() as any[],
    refractive_indices: Array.from(new Set(rows.map(r => r.refractive_index))).filter(Boolean).sort((a: number, b: number) => a - b),
  }
}

// ============================================================================
// CANONICAL ENGINE v3 — Filtros Estruturados
// RPCs para Premium e Standard
// ============================================================================

export async function getPremiumFilterOptionsV3(
  params: PremiumFilterParamsV3 = {}
): Promise<PremiumFilterOptions> {
  const { data, error } = await supabase.rpc('rpc_premium_filter_options', {
    p_brand:        params.brand        ?? null,
    p_product_line: params.product_line ?? null,
    p_lens_type:    params.lens_type    ?? null,
    p_material_id:  params.material_id  ?? null,
    p_coating:      params.coating      ?? null,
    p_photochromic: params.photochromic ?? null,
  })

  if (error) {
    console.error('[LENTES v3] rpc_premium_filter_options error:', error)
    throw error
  }
  return data as PremiumFilterOptions
}

export async function searchPremiumV3(
  params: PremiumSearchParamsV3 = {}
): Promise<CanonicalSearchResultV3<CanonicalPremiumV3>> {
  const { data, error } = await supabase.rpc('rpc_premium_search', {
    p_brand:        params.brand        ?? null,
    p_product_line: params.product_line ?? null,
    p_lens_type:    params.lens_type    ?? null,
    p_material_id:  params.material_id  ?? null,
    p_coating:      params.coating      ?? null,
    p_photochromic: params.photochromic ?? null,
    p_spherical:    params.spherical    ?? null,
    p_cylindrical:  params.cylindrical  ?? null,
    p_addition:     params.addition     ?? null,
    p_limit:        params.limit        ?? 50,
    p_offset:       params.offset       ?? 0,
  })

  if (error) {
    console.error('[LENTES v3] rpc_premium_search error:', error)
    throw error
  }
  return data as CanonicalSearchResultV3<CanonicalPremiumV3>
}

export async function getStandardFilterOptionsV3(
  params: StandardFilterParamsV3 = {}
): Promise<StandardFilterOptions> {
  const { data, error } = await supabase.rpc('rpc_standard_filter_options', {
    p_lens_type:   params.lens_type   ?? null,
    p_material_id: params.material_id ?? null,
    p_treatments:  params.treatments  ?? null,
    p_spherical:   params.spherical   ?? null,
    p_cylindrical: params.cylindrical ?? null,
    p_addition:    params.addition    ?? null,
  })

  if (error) {
    console.error('[LENTES v3] rpc_standard_filter_options error:', error)
    throw error
  }
  return data as StandardFilterOptions
}

export async function searchStandardV3(
  params: StandardSearchParamsV3 = {}
): Promise<CanonicalSearchResultV3<CanonicalStandardV3>> {
  const { data, error } = await supabase.rpc('rpc_standard_search', {
    p_lens_type:   params.lens_type   ?? null,
    p_material_id: params.material_id ?? null,
    p_treatments:  params.treatments  ?? null,
    p_spherical:   params.spherical   ?? null,
    p_cylindrical: params.cylindrical ?? null,
    p_addition:    params.addition    ?? null,
    p_limit:       params.limit       ?? 50,
    p_offset:      params.offset      ?? 0,
  })

  if (error) {
    console.error('[LENTES v3] rpc_standard_search error:', error)
    throw error
  }
  return data as CanonicalSearchResultV3<CanonicalStandardV3>
}

export async function getCatalogSummaryV3(): Promise<any> {
  const { data, error } = await supabase.rpc('rpc_catalog_summary')

  if (error) {
    console.error('[LENTES v3] rpc_catalog_summary error:', error)
    throw error
  }
  return data
}
