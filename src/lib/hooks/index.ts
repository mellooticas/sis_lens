/**
 * Hooks Index
 * Ponto central para todos os hooks personalizados
 */

// Hooks antigos (manter compatibilidade)
export { useLensSearch, useRanking } from './useLensSearch';
export { useDecisions } from './useDecisions';

export type { UseLensSearchOptions } from './useLensSearch';
export type { UseDecisionsOptions } from './useDecisions';

// Novos hooks baseados nas views públicas
export { useBuscarLentes } from './useBuscarLentes';
export { useMarcas } from './useMarcas';
export { useFornecedores } from './useFornecedores';
export { useFiltros } from './useFiltros';
export { useGruposCanonicos } from './useGruposCanonicos';
export { useCompararFornecedores } from './useCompararFornecedores';
export { useStatsCatalogo } from './useStatsCatalogo';