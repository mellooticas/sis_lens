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
      // Wrap em array para compatibilidade com o template
      state.update(s => ({
        ...s,
        comparacoes: [res.data as RpcLensSearchResult],
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
