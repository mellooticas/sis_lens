/**
 * Decisoes Store
 * Store para gerenciar histórico de decisões
 */

import { writable, derived } from 'svelte/store';
import type { DecisaoCompra, StatusDecisao } from '$lib/types/sistema';

export interface DecisoesState {
  decisoes: DecisaoCompra[];
  loading: boolean;
  error: string | null;
  selectedDecisao: DecisaoCompra | null;
  filtroStatus: StatusDecisao | 'TODAS';
  page: number;
  hasMore: boolean;
}

const initialState: DecisoesState = {
  decisoes: [],
  loading: false,
  error: null,
  selectedDecisao: null,
  filtroStatus: 'TODAS',
  page: 1,
  hasMore: false
};

function createDecisoesStore() {
  const { subscribe, set, update } = writable<DecisoesState>(initialState);

  return {
    subscribe,
    
    // Definir decisões
    setDecisoes: (decisoes: DecisaoCompra[], append = false) => {
      update(state => ({ 
        ...state, 
        decisoes: append ? [...state.decisoes, ...decisoes] : decisoes,
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
    
    // Selecionar decisão
    selectDecisao: (decisao: DecisaoCompra | null) => {
      update(state => ({ ...state, selectedDecisao: decisao }));
    },
    
    // Filtrar por status
    setFiltroStatus: (status: StatusDecisao | 'TODAS') => {
      update(state => ({ 
        ...state, 
        filtroStatus: status,
        page: 1,
        decisoes: [] // Reset lista para refetch
      }));
    },
    
    // Controle de paginação
    setPage: (page: number) => {
      update(state => ({ ...state, page }));
    },
    
    nextPage: () => {
      update(state => ({ ...state, page: state.page + 1 }));
    },
    
    setHasMore: (hasMore: boolean) => {
      update(state => ({ ...state, hasMore }));
    },
    
    // Adicionar nova decisão
    addDecisao: (decisao: DecisaoCompra) => {
      update(state => ({ 
        ...state, 
        decisoes: [decisao, ...state.decisoes]
      }));
    },
    
    // Atualizar decisão existente
    updateDecisao: (decisaoId: string, updates: Partial<DecisaoCompra>) => {
      update(state => ({
        ...state,
        decisoes: state.decisoes.map(d => 
          d.id === decisaoId ? { ...d, ...updates } : d
        )
      }));
    },
    
    // Reset completo
    reset: () => {
      set(initialState);
    }
  };
}

export const decisoes = createDecisoesStore();

// Store derivado - decisão selecionada
export const selectedDecisao = derived(decisoes, ($decisoes) => $decisoes.selectedDecisao);

// Store derivado - se há decisões
export const hasDecisoes = derived(decisoes, ($decisoes) => $decisoes.decisoes.length > 0);

// Store derivado - contagem total
export const totalDecisoes = derived(decisoes, ($decisoes) => $decisoes.decisoes.length);

// Store derivado - decisões filtradas por status
export const filteredDecisoes = derived(decisoes, ($decisoes) => {
  if ($decisoes.filtroStatus === 'TODAS') {
    return $decisoes.decisoes;
  }
  return $decisoes.decisoes.filter(d => d.status === $decisoes.filtroStatus);
});

// Store derivado - estatísticas por status
export const statusStats = derived(decisoes, ($decisoes) => {
  const stats = {
    DECIDIDO: 0,
    ENVIADO: 0,
    CONFIRMADO: 0,
    ENTREGUE: 0,
    TODAS: $decisoes.decisoes.length
  };
  
  $decisoes.decisoes.forEach(decisao => {
    stats[decisao.status]++;
  });
  
  return stats;
});

// Store derivado - está carregando
export const isLoadingDecisoes = derived(decisoes, ($decisoes) => $decisoes.loading);

// Store derivado - tem erro
export const hasErrorDecisoes = derived(decisoes, ($decisoes) => $decisoes.error !== null);