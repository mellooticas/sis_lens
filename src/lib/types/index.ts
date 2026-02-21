// ============================================================================
// SIS_LENS — Types Index (barrel)
// Versão: 2.0 — Ponto central de exportação de tipos
// ============================================================================
//
// REGRA: Importe tipos daqui, nunca diretamente dos sub-arquivos.
//
// Sub-arquivos:
//   ./sistema          → tipos de domínio do SIS_Lens (Session, Tenant, DecisaoCompra, etc.)
//   ./database-views   → tipos gerados das views legadas (LenteCatalogo, VGruposCanonico, etc.)
//   ./database         → tipos auxiliares de views legadas (VwLentesCatalogo, VwFornecedores)
//   ./contact-lens     → tipos para lentes de contato
//   ./new-database     → tipos para o novo schema SIS_DIGIAI (iam, catalog_lenses, etc.)
//
// NOVO BANCO: quando migrar para mhgbuplnxtfgipbemchb, importar de ./new-database
// ============================================================================

// Tipos principais do sistema (Session, Tenant, DecisaoCompra, CriterioRanking, etc.)
export * from './sistema';

// Tipos das views legadas do catálogo (LenteCatalogo, VGruposCanonico, FiltrosLentes, etc.)
export * from './database-views';

// Tipos auxiliares de views legadas — não re-exportar pois conflitam com database-views.
// Importe diretamente de '$lib/types/database' se precisar de VwLentesCatalogo, etc.
// export * from './database'; // desabilitado: tipos conflitantes com database-views
