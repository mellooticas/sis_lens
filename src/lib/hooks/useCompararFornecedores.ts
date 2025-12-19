/**
 * Hook para comparar fornecedores
 * Usa a view vw_comparar_fornecedores do banco de dados
 */

import { writable } from 'svelte/store';
import { viewsApi } from '$lib/api/views-client';
import type { VwCompararFornecedores } from '$lib/types/views';

interface CompararFornecedoresState {
  comparacoes: VwCompararFornecedores[];
  loading: boolean;
  error: string | null;
}

export function useCompararFornecedores() {
  const state = writable<CompararFornecedoresState>({
    comparacoes: [],
    loading: false,
    error: null
  });

  /**
   * Comparar fornecedores para um grupo canônico específico
   */
  async function compararPorGrupo(grupoId: string) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.compararFornecedores(grupoId);

    if (response.success && response.data) {
      state.update(s => ({
        ...s,
        comparacoes: response.data || [],
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao comparar fornecedores'
      }));
    }
  }

  /**
   * Comparar fornecedores para uma lente específica
   */
  async function compararPorLente(lenteId: string) {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.compararFornecedoresPorLente(lenteId);

    if (response.success && response.data) {
      state.update(s => ({
        ...s,
        comparacoes: response.data || [],
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao comparar fornecedores'
      }));
    }
  }

  /**
   * Listar todas as comparações (sem filtro)
   */
  async function listarTodasComparacoes() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.compararFornecedores();

    if (response.success && response.data) {
      state.update(s => ({
        ...s,
        comparacoes: response.data || [],
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao comparar fornecedores'
      }));
    }
  }

  /**
   * Filtrar comparações por tipo (PREMIUM ou GENÉRICA)
   */
  async function compararPorTipo(tipo: 'PREMIUM' | 'GENÉRICA') {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.compararFornecedores(undefined, tipo);

    if (response.success && response.data) {
      state.update(s => ({
        ...s,
        comparacoes: response.data || [],
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao comparar fornecedores'
      }));
    }
  }

  return {
    state,
    compararPorGrupo,
    compararPorLente,
    listarTodasComparacoes,
    compararPorTipo
  };
}
