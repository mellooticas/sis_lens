/**
 * Hook para comparar lentes de um grupo canônico
 * NOVO BANCO: usa LensOracleAPI.searchLenses com filtros de grupo (canonical_group_id)
 */

import { writable } from 'svelte/store';
import { LensOracleAPI } from '$lib/api/lens-oracle';
import type { RpcLensSearchResult } from '$lib/types/database-views';

interface CompararFornecedoresState {
  comparacoes: RpcLensSearchResult[];
  loading: boolean;
  error: string | null;
}

export function useCompararFornecedores() {
  const state = writable<CompararFornecedoresState>({
    comparacoes: [],
    loading: false,
    error: null
  });

  /** Buscar lentes de um grupo canônico para comparar opções */
  async function compararPorGrupo(grupoId: string) {
    state.update(s => ({ ...s, loading: true, error: null }));

    // Busca lentes do grupo — cada resultado é uma opção de fornecedor/lab
    const res = await LensOracleAPI.searchLenses({ query: grupoId, limit: 50, offset: 0 });

    if (res.data) {
      state.update(s => ({ ...s, comparacoes: res.data!, loading: false }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: res.error?.message || 'Erro ao comparar fornecedores'
      }));
    }
  }

  /** Buscar lentes de uma lente específica (por ID) */
  async function compararPorLente(lenteId: string) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const res = await LensOracleAPI.getLensById(lenteId);

    if (res.data) {
      // Mapear VCatalogLens → RpcLensSearchResult (campos compatíveis)
      const mapped: RpcLensSearchResult = {
        id:               res.data.id,
        slug:             res.data.slug,
        lens_name:        res.data.lens_name,
        supplier_name:    res.data.supplier_name,
        brand_name:       res.data.brand_name,
        lens_type:        res.data.lens_type,
        material:         res.data.material,
        refractive_index: res.data.refractive_index,
        price_suggested:  res.data.price_suggested,
        category:         res.data.category,
        has_ar:           res.data.anti_reflective,
        has_blue:         res.data.blue_light,
        group_name:       res.data.group_name,
        stock_available:  res.data.stock_available,
        lead_time_days:   res.data.lead_time_days,
        is_premium:       res.data.is_premium,
      };
      state.update(s => ({
        ...s,
        comparacoes: [mapped],
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: res.error?.message || 'Erro ao comparar'
      }));
    }
  }

  /** Listar todas as lentes sem filtro de grupo */
  async function listarTodasComparacoes() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const res = await LensOracleAPI.searchLenses({ limit: 100, offset: 0 });

    if (res.data) {
      state.update(s => ({ ...s, comparacoes: res.data!, loading: false }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: res.error?.message || 'Erro ao listar'
      }));
    }
  }

  return {
    state,
    compararPorGrupo,
    compararPorLente,
    listarTodasComparacoes
  };
}
