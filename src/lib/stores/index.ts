/**
 * Stores Index
 * Ponto central para todos os stores do sistema
 */

// Session & Auth
export { session, setUser, clearSession } from './session';

// Filtros de busca
export { 
  filtros, 
  hasActiveFilters, 
  activeFiltersCount 
} from './filtros';

// Ranking de lentes
export { 
  ranking, 
  selectedLente, 
  hasResults, 
  resultsCount, 
  bestOption, 
  isLoading, 
  hasError 
} from './ranking';

// Decisões/Histórico
export { 
  decisoes, 
  selectedDecisao, 
  hasDecisoes, 
  totalDecisoes, 
  filteredDecisoes, 
  statusStats, 
  isLoadingDecisoes, 
  hasErrorDecisoes 
} from './decisoes';

// Toast notifications
export { toast } from './toast';

// Types
export type { ToastType, ToastMessage } from './toast';
export type { RankingState } from './ranking';
export type { DecisoesState } from './decisoes';