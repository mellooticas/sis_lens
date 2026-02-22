/**
 * Hook para filtros disponíveis no catálogo
 * NOVO BANCO: derivado de v_catalog_lens_stats via LensOracleAPI.getCatalogStats()
 * Os filtros estáticos enums estão definidos em FilterPanel.svelte
 */

import { writable } from 'svelte/store';
import { LensOracleAPI } from '$lib/api/lens-oracle';
import type { VCatalogLensStats } from '$lib/types/database-views';

export interface FiltrosDisponiveis {
  tipos_lente: { valor: string; label: string }[];
  materiais:   { valor: string; label: string }[];
  indices_refracao: number[];
  stats: VCatalogLensStats | null;
}

interface FiltrosState {
  filtros: FiltrosDisponiveis | null;
  loading: boolean;
  error: string | null;
}

// Valores estáticos alinhados ao schema do novo banco (enums em inglês)
const TIPOS_LENTE = [
  { valor: 'single_vision',  label: 'Visão Simples' },
  { valor: 'bifocal',        label: 'Bifocal' },
  { valor: 'multifocal',     label: 'Multifocal' },
  { valor: 'office',         label: 'Office/Perto' },
  { valor: 'contact_lens',   label: 'Lente de Contato' },
];

const MATERIAIS = [
  { valor: 'cr39',       label: 'CR-39 (Orgânico)' },
  { valor: 'polycarbonate', label: 'Policarbonato' },
  { valor: 'trivex',     label: 'Trivex' },
  { valor: 'high_index', label: 'Alto Índice' },
  { valor: 'glass',      label: 'Vidro Mineral' },
];

const INDICES = [1.50, 1.53, 1.56, 1.59, 1.60, 1.67, 1.74, 1.90];

export function useFiltros() {
  const state = writable<FiltrosState>({
    filtros: null,
    loading: false,
    error: null
  });

  async function carregarFiltros() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const res = await LensOracleAPI.getCatalogStats();

    state.update(s => ({
      ...s,
      loading: false,
      filtros: {
        tipos_lente:     TIPOS_LENTE,
        materiais:       MATERIAIS,
        indices_refracao: INDICES,
        stats:           res.data ?? null
      },
      error: res.error?.message ?? null
    }));
  }

  return { state, carregarFiltros };
}
