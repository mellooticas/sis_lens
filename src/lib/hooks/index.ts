/**
 * SIS Lens — Hooks Index
 * Novo padrão: todos os hooks usam LensOracleAPI (banco mhgbuplnxtfgipbemchb)
 */

// Busca principal e stats
export { useBuscarLentes } from './useBuscarLentes';
export { useStatsCatalogo } from './useStatsCatalogo';

// Catálogo e filtros
export { useMarcas } from './useMarcas';
export { useFornecedores } from './useFornecedores';
export { useFiltros } from './useFiltros';
export { useGruposCanonicos } from './useGruposCanonicos';
export { useCompararFornecedores } from './useCompararFornecedores';