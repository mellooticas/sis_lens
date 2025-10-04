/**
 * Lens Search Hook
 * Hook para integrar busca de lentes com stores
 */

import { ranking, filtros, toast } from '$lib/stores';
import { get } from 'svelte/store';
import type { ActionResult } from '@sveltejs/kit';
import type { FiltrosBusca, CriterioDecisao } from '$lib/types/sistema';

export interface UseLensSearchOptions {
  autoToast?: boolean;
  onSuccess?: (lentes: any[]) => void;
  onError?: (error: string) => void;
}

export function useLensSearch(options: UseLensSearchOptions = {}) {
  const { autoToast = true, onSuccess, onError } = options;

  /**
   * Executar busca de lentes
   */
  async function searchLentes(
    searchParams?: Partial<FiltrosBusca>,
    criterio: CriterioDecisao = 'NORMAL'
  ) {
    try {
      ranking.setLoading(true);
      ranking.setError(null);
      
      // Merge com filtros atuais se não fornecidos
      const currentFilters = get(filtros);
      const finalParams = { ...currentFilters, ...searchParams };
      
      // Atualizar critério
      ranking.setCriterio(criterio);
      
      // Salvar parâmetros da busca
      ranking.setLastSearchParams(finalParams);
      
      // Fazer a busca via fetch para o server action
      const formData = new FormData();
      
      // Adicionar parâmetros do filtro
      Object.entries(finalParams).forEach(([key, value]) => {
        if (value !== null && value !== undefined) {
          if (Array.isArray(value)) {
            value.forEach(item => formData.append(`${key}[]`, item));
          } else {
            formData.append(key, value.toString());
          }
        }
      });
      
      formData.append('criterio', criterio);
      
      const response = await fetch('/actions/buscar-lentes', {
        method: 'POST',
        body: formData
      });
      
      const result: ActionResult = await response.json();
      
      if (result.type === 'success' && result.data) {
        const lentes = result.data.lentes || [];
        ranking.setLentes(lentes);
        
        if (autoToast && lentes.length === 0) {
          toast.show('Nenhuma lente encontrada com os filtros aplicados', 'warning');
        } else if (autoToast && lentes.length > 0) {
          toast.show(`${lentes.length} opções encontradas`, 'success');
        }
        
        onSuccess?.(lentes);
      } else if (result.type === 'failure') {
        const errorMsg = (result.data?.message as string) || 'Erro ao buscar lentes';
        ranking.setError(errorMsg);
        
        if (autoToast) {
          toast.show(errorMsg, 'error');
        }
        
        onError?.(errorMsg);
      }
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Erro inesperado';
      ranking.setError(errorMsg);
      
      if (autoToast) {
        toast.show(errorMsg, 'error');
      }
      
      onError?.(errorMsg);
    }
  }

  /**
   * Refazer última busca
   */
  async function retryLastSearch() {
    const state = get(ranking);
    if (state.lastSearchParams) {
      await searchLentes(state.lastSearchParams, state.criterio);
    }
  }

  /**
   * Limpar resultados
   */
  function clearResults() {
    ranking.clearResults();
  }

  return {
    searchLentes,
    retryLastSearch,
    clearResults
  };
}

/**
 * Hook para gerar ranking
 */
export function useRanking(options: UseLensSearchOptions = {}) {
  const { autoToast = true, onSuccess, onError } = options;

  async function generateRanking(
    lente_id: string,
    laboratorios_ids: string[],
    criterio: CriterioDecisao = 'NORMAL'
  ) {
    try {
      ranking.setLoading(true);
      ranking.setError(null);
      ranking.setCriterio(criterio);
      
      const formData = new FormData();
      formData.append('lente_id', lente_id);
      laboratorios_ids.forEach(id => formData.append('laboratorios_ids[]', id));
      formData.append('criterio', criterio);
      
      const response = await fetch('/actions/gerar-ranking', {
        method: 'POST',
        body: formData
      });
      
      const result: ActionResult = await response.json();
      
      if (result.type === 'success' && result.data) {
        const opcoes = result.data.opcoes || [];
        ranking.setLentes(opcoes);
        
        if (autoToast) {
          toast.show(`Ranking gerado com ${opcoes.length} opções`, 'success');
        }
        
        onSuccess?.(opcoes);
      } else if (result.type === 'failure') {
        const errorMsg = (result.data?.message as string) || 'Erro ao gerar ranking';
        ranking.setError(errorMsg);
        
        if (autoToast) {
          toast.show(errorMsg, 'error');
        }
        
        onError?.(errorMsg);
      }
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Erro inesperado';
      ranking.setError(errorMsg);
      
      if (autoToast) {
        toast.show(errorMsg, 'error');
      }
      
      onError?.(errorMsg);
    }
  }

  return {
    generateRanking
  };
}