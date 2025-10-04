/**
 * Ranking Store
 * Store para gerenciar estado do ranking de lentes
 */

import { writable, derived } from 'svelte/store';
import type { OpcaoRanking, CriterioDecisao } from '$lib/types/sistema';

export interface RankingState {
  lentes: OpcaoRanking[];
  loading: boolean;
  error: string | null;
  selectedLente: OpcaoRanking | null;
  criterio: CriterioDecisao;
  lastSearchParams: any;
}

const initialState: RankingState = {
  lentes: [],
  loading: false,
  error: null,
  selectedLente: null,
  criterio: 'NORMAL',
  lastSearchParams: null
};

function createRankingStore() {
  const { subscribe, set, update } = writable<RankingState>(initialState);

  return {
    subscribe,
    
    // Definir lentes do ranking
    setLentes: (lentes: OpcaoRanking[]) => {
      update(state => ({ 
        ...state, 
        lentes, 
        loading: false, 
        error: null 
      }));
    },
    
    // Definir loading
    setLoading: (loading: boolean) => {
      update(state => ({ ...state, loading }));
    },
    
    // Definir erro
    setError: (error: string | null) => {
      update(state => ({ 
        ...state, 
        error, 
        loading: false 
      }));
    },
    
    // Selecionar lente
    selectLente: (lente: OpcaoRanking | null) => {
      update(state => ({ ...state, selectedLente: lente }));
    },
    
    // Definir critério
    setCriterio: (criterio: CriterioDecisao) => {
      update(state => ({ ...state, criterio }));
    },
    
    // Salvar parâmetros da última busca
    setLastSearchParams: (params: any) => {
      update(state => ({ ...state, lastSearchParams: params }));
    },
    
    // Reset completo
    reset: () => {
      set(initialState);
    },
    
    // Limpar apenas resultados
    clearResults: () => {
      update(state => ({ 
        ...state, 
        lentes: [], 
        selectedLente: null, 
        error: null 
      }));
    }
  };
}

export const ranking = createRankingStore();

// Store derivado - lente selecionada com segurança
export const selectedLente = derived(ranking, ($ranking) => $ranking.selectedLente);

// Store derivado - se há resultados
export const hasResults = derived(ranking, ($ranking) => $ranking.lentes.length > 0);

// Store derivado - contagem de resultados
export const resultsCount = derived(ranking, ($ranking) => $ranking.lentes.length);

// Store derivado - melhor opção (primeira do ranking)
export const bestOption = derived(ranking, ($ranking) => 
  $ranking.lentes.length > 0 ? $ranking.lentes[0] : null
);

// Store derivado - está carregando
export const isLoading = derived(ranking, ($ranking) => $ranking.loading);

// Store derivado - tem erro
export const hasError = derived(ranking, ($ranking) => $ranking.error !== null);