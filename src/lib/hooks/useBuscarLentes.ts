/**
 * Hook para buscar lentes do catálogo (SIS Lens Oracle)
 * Usa a nova API consolidada LensOracleAPI
 */

import { writable, get } from 'svelte/store';
import { LensOracleAPI } from '$lib/api/lens-oracle';
import type { RpcLensSearchResult } from '$lib/types/database-views';

interface BuscarLentesState {
  lentes: RpcLensSearchResult[];
  loading: boolean;
  error: string | null;
  total: number;
  pagina: number;
}

export interface BuscarLentesParams {
  query?: string;
  lens_type?: string;
  material?: string;
  refractive_index?: number;
  is_premium?: boolean;
  limit?: number;
  offset?: number;
}

export function useBuscarLentes(parametrosIniciais: BuscarLentesParams = {}) {
  const limite = parametrosIniciais.limit || 50;
  
  const state = writable<BuscarLentesState>({
    lentes: [],
    loading: false,
    error: null,
    total: 0,
    pagina: 1
  });

  const parametros = writable<BuscarLentesParams>(parametrosIniciais);

  async function buscar(novosParametros?: Partial<BuscarLentesParams>) {
    state.update(s => ({ ...s, loading: true, error: null }));

    if (novosParametros) {
      parametros.update(p => ({ ...p, ...novosParametros }));
    }

    const params = get(parametros);
    const res = await LensOracleAPI.searchLenses({
      ...params,
      limit: limite,
      offset: params.offset || 0
    });

    if (res.data) {
      state.update(s => ({
        ...s,
        lentes: res.data || [],
        loading: false,
        pagina: Math.floor((params.offset || 0) / limite) + 1
      }));
      
      // Busca total se necessário
      if (get(state).total === 0) {
        const stats = await LensOracleAPI.getCatalogStats();
        if (stats?.data) {
          state.update(s => ({ ...s, total: stats.data!.total }));
        }
      }
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: res.error?.message || 'Erro ao buscar lentes'
      }));
    }
  }

  function irParaPagina(pagina: number) {
    const offset = (pagina - 1) * limite;
    buscar({ offset });
  }

  function aplicarFiltros(novosParametros: Partial<BuscarLentesParams>) {
    buscar({ ...novosParametros, offset: 0 });
  }

  function limparFiltros() {
    parametros.set({ limit: limite });
    buscar({ offset: 0 });
  }

  return {
    state,
    parametros,
    buscar,
    irParaPagina,
    aplicarFiltros,
    limparFiltros
  };
}
