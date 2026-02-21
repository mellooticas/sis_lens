/**
 * Hook para gerenciar fornecedores/labs
 * NOVO BANCO: fornecedores derivados de v_catalog_lenses (supplier_lab_id, supplier_name)
 */

import { writable, get } from 'svelte/store';
import { viewsApi } from '$lib/api/views-client';

// Tipo que corresponde ao retorno de ViewsApiClient.listarFornecedores()
export interface Fornecedor {
  id: string;
  name: string;       // supplier_name do novo banco
  total: number;      // qtd de lentes ativas deste fornecedor
  // Compat legado — preenchidos com valores padrão
  nome?: string;
  razao_social?: string | null;
  cnpj?: string | null;
  prazo_visao_simples?: number | null;
  prazo_multifocal?: number | null;
  ativo?: boolean;
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

  /**
   * Carregar todos os fornecedores (derivado de v_catalog_lenses)
   */
  async function carregarFornecedores() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const response = await viewsApi.listarFornecedores();

    if (response.success && response.data) {
      // Mapear para Fornecedor adicionando campos compat legado
      const fornecedores: Fornecedor[] = response.data.map(f => ({
        ...f,
        nome: f.name,
        razao_social: null,
        cnpj: null,
        prazo_visao_simples: null,
        prazo_multifocal: null,
        ativo: true
      }));

      state.update(s => ({
        ...s,
        fornecedores,
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: response.error || 'Erro ao carregar fornecedores'
      }));
    }
  }

  /**
   * Obter fornecedor por ID
   */
  function obterFornecedorPorId(fornecedorId: string): Fornecedor | undefined {
    const currentState = get(state);
    return currentState.fornecedores.find(f => f.id === fornecedorId);
  }

  /**
   * Obter fornecedores ordenados por total de lentes (descending)
   */
  function obterFornecedoresPorCatalogo(): Fornecedor[] {
    const currentState = get(state);
    return [...currentState.fornecedores].sort((a, b) => (b.total ?? 0) - (a.total ?? 0));
  }

  /**
   * Obter fornecedores ordenados por nome
   */
  function obterFornecedoresOrdenadosPorPreco(): Fornecedor[] {
    // Sem dado de preço por fornecedor; ordenar por nome como fallback
    const currentState = get(state);
    return [...currentState.fornecedores].sort((a, b) => a.name.localeCompare(b.name));
  }

  return {
    state,
    carregarFornecedores,
    obterFornecedorPorId,
    obterFornecedoresOrdenadosPorPreco,
    obterFornecedoresPorCatalogo
  };
}
