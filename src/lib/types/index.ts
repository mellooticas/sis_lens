// ============================================================================
// SIS_LENS — Types Index (barrel)
// Banco: mhgbuplnxtfgipbemchb (SIS_DIGIAI)
// ============================================================================
// REGRA: Importe tipos daqui, nunca diretamente dos sub-arquivos.
//
// Sub-arquivos:
//   ./sistema        → tipos de domínio: Session, Tenant, ApiResponse, etc.
//   ./database-views → tipos das views e RPCs: VCatalogLens, CanonicalLensV2, etc.
// ============================================================================

// Tipos principais do sistema
export * from './sistema';

// Tipos das views e RPCs do banco (Canonical Engine v2 + Catálogo)
export * from './database-views';
