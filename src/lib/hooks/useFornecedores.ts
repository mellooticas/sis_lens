/**
 * Hook para fornecedores/laboratórios
 * NOVO BANCO: derivado de v_catalog_lenses (supplier_name / supplier_lab_id)
 * Usa LensOracleAPI.searchLenses e agrega por supplier
 */

import { writable, get } from 'svelte/store';
import { LensOracleAPI } from '$lib/api/lens-oracle';

export interface Fornecedor {
  id: string;
  name: string;
  total: number;
  ativo: boolean;
}

interface FornecedoresState {
  fornecedores: Fornecedor[];
  loading: boolean;
  error: string | null;
}

export function useFornecedores() {
  const state = writable<FornecedoresState>({
    fornecedores: [],
    loading: false,
    error: null
  });

  async function carregarFornecedores() {
    state.update(s => ({ ...s, loading: true, error: null }));

    // Busca lentes em lote e agrega por supplier
    const res = await LensOracleAPI.searchLenses({ limit: 200, offset: 0 });

    if (res.data) {
      // Agregar fornecedores únicos
      const map = new Map<string, Fornecedor>();
      for (const lente of res.data) {
        if (!lente.supplier_name) continue;
        const key = lente.supplier_name;
        if (map.has(key)) {
          map.get(key)!.total++;
        } else {
          map.set(key, {
            id:    key,
            name:  key,
            total: 1,
            ativo: true
          });
        }
      }
      state.update(s => ({ ...s, fornecedores: Array.from(map.values()), loading: false }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: res.error?.message || 'Erro ao carregar fornecedores'
      }));
    }
  }

  function obterFornecedorPorId(id: string): Fornecedor | undefined {
    return get(state).fornecedores.find(f => f.id === id);
  }

  function obterFornecedoresPorCatalogo(): Fornecedor[] {
    return [...get(state).fornecedores].sort((a, b) => b.total - a.total);
  }

  function obterFornecedoresOrdenadosPorPreco(): Fornecedor[] {
    return [...get(state).fornecedores].sort((a, b) => a.name.localeCompare(b.name));
  }

  return {
    state,
    carregarFornecedores,
    obterFornecedorPorId,
    obterFornecedoresPorCatalogo,
    obterFornecedoresOrdenadosPorPreco
  };
}
