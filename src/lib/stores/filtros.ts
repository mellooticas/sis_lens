/**
 * Filtros Store
 * Store para gerenciar filtros de busca de lentes
 */

import { writable, derived } from 'svelte/store';
import type { FiltrosBusca } from '$lib/types/sistema';

// Estado inicial dos filtros
const initialFilters: FiltrosBusca = {
  usuario_id:       undefined,
  graduacao_de:     undefined,
  graduacao_ate:    undefined,
  tipo_lente:       undefined,
  material:         undefined,
  tratamentos:      [],
  faixa_preco_min:  undefined,
  faixa_preco_max:  undefined,
  ordenacao: 'preco_asc'
};

function createFiltrosStore() {
  const { subscribe, set, update } = writable<FiltrosBusca>(initialFilters);

  return {
    subscribe,
    
    // Atualizar filtro específico
    updateFilter: <K extends keyof FiltrosBusca>(key: K, value: FiltrosBusca[K]) => {
      update(filters => ({ ...filters, [key]: value }));
    },
    
    // Atualizar múltiplos filtros
    updateFilters: (updates: Partial<FiltrosBusca>) => {
      update(filters => ({ ...filters, ...updates }));
    },
    
    // Reset aos valores iniciais
    reset: () => {
      set(initialFilters);
    },
    
    // Set usuário ID
    setUsuario: (usuario_id: string) => {
      update(filters => ({ ...filters, usuario_id }));
    },
    
    // Adicionar/remover tratamento
    toggleTratamento: (tratamento: string) => {
      update(filters => {
        const tratamentos = filters.tratamentos || [];
        const exists = tratamentos.includes(tratamento);
        
        return {
          ...filters,
          tratamentos: exists 
            ? tratamentos.filter((t: string) => t !== tratamento)
            : [...tratamentos, tratamento]
        };
      });
    },
    
    // Limpar todos os tratamentos
    clearTratamentos: () => {
      update(filters => ({ ...filters, tratamentos: [] }));
    }
  };
}

export const filtros = createFiltrosStore();

// Store derivado para verificar se há filtros ativos
export const hasActiveFilters = derived(filtros, ($filtros) => {
  return Object.entries($filtros).some(([key, value]) => {
    if (key === 'usuario_id' || key === 'ordenacao') return false;
    if (Array.isArray(value)) return value.length > 0;
    return value !== null && value !== undefined;
  });
});

// Store derivado para contagem de filtros ativos
export const activeFiltersCount = derived(filtros, ($filtros) => {
  let count = 0;
  
  if ($filtros.graduacao_de !== null) count++;
  if ($filtros.graduacao_ate !== null) count++;
  if ($filtros.tipo_lente) count++;
  if ($filtros.material) count++;
  if ($filtros.tratamentos && $filtros.tratamentos.length > 0) count++;
  if ($filtros.faixa_preco_min !== null) count++;
  if ($filtros.faixa_preco_max !== null) count++;
  
  return count;
});