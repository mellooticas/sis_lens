/**
 * Hook para buscar lentes do catálogo
 * Usa a view vw_buscar_lentes do banco de dados
 */

import { writable, derived, get } from 'svelte/store';
import { viewsApi } from '$lib/api/views-client';
import type {
  VwBuscarLentes,
  BuscarLentesParams
} from '$lib/types/views';

interface BuscarLentesState {
  lentes: VwBuscarLentes[];
  loading: boolean;
  error: string | null;
  total: number;
  pagina: number;
  totalPaginas: number;
}

export function useBuscarLentes(parametrosIniciais: BuscarLentesParams = {}) {
  const limite = parametrosIniciais.limite || 50;
  
  const state = writable<BuscarLentesState>({
    lentes: [],
    loading: false,
    error: null,
    total: 0,
    pagina: 1,
    totalPaginas: 0
  });

  const parametros = writable<BuscarLentesParams>(parametrosIniciais);

  /**
   * Buscar lentes com os parâmetros atuais
   */
  async function buscar(novosParametros?: Partial<BuscarLentesParams>) {
    state.update(s => ({ ...s, loading: true, error: null }));

    if (novosParametros) {
      parametros.update(p => ({ ...p, ...novosParametros }));
    }

    const params = get(parametros);
    const offset = ((params.offset || 0) / limite);

    const response = await viewsApi.buscarLentes({
      ...params,
      limite,
      offset: offset * limite
    });

    if (response.success && response.data) {
      state.update(s => ({
        ...s,
        lentes: response.data || [],
        loading: false,
        total: response.total || 0,
        totalPaginas: response.metadata?.paginas || 0,
        pagina: offset + 1
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao buscar lentes'
      }));
    }
  }

  /**
   * Ir para uma página específica
   */
  function irParaPagina(pagina: number) {
    const offset = (pagina - 1) * limite;
    buscar({ offset });
  }

  /**
   * Próxima página
   */
  function proximaPagina() {
    const currentState = get(state);
    if (currentState.pagina < currentState.totalPaginas) {
      irParaPagina(currentState.pagina + 1);
    }
  }

  /**
   * Página anterior
   */
  function paginaAnterior() {
    const currentState = get(state);
    if (currentState.pagina > 1) {
      irParaPagina(currentState.pagina - 1);
    }
  }

  /**
   * Atualizar filtros e buscar
   */
  function aplicarFiltros(novosParametros: Partial<BuscarLentesParams>) {
    buscar({ ...novosParametros, offset: 0 });
  }

  /**
   * Limpar filtros
   */
  function limparFiltros() {
    parametros.set({ limite });
    buscar({ offset: 0 });
  }

  /**
   * Recarregar com os mesmos parâmetros
   */
  function recarregar() {
    buscar();
  }

  return {
    state,
    parametros,
    buscar,
    irParaPagina,
    proximaPagina,
    paginaAnterior,
    aplicarFiltros,
    limparFiltros,
    recarregar
  };
}
