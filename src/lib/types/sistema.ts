// ============================================================================
// SIS_LENS — Tipos do Sistema
// Versão: 3.0 — Alinhada com SIS_DIGIAI Ecosystem (Migrations 208-221)
// ============================================================================

import type { VCatalogLens, VContactLens, VBrand, VCanonicalLens } from './database-views';

export type UUID = string;
export type TenantId = UUID;
export type UserId = UUID;
export type ISODateString = string;

// ============================================================================
// SESSÃO / IDENTIDADE (JWT Gateway)
// ============================================================================

export interface AppSession {
  user: {
    id: UserId;
    email: string;
    full_name: string;
    role: string;
    tenant_id: TenantId;
    store_id?: UUID;
  } | null;
  loading: boolean;
}

// ============================================================================
// DOMÍNIO: Lentes e Catálogo
// ============================================================================

export interface Lens extends VCatalogLens {}
export interface ContactLens extends VContactLens {}
export interface Brand extends VBrand {}
export interface CanonicalLens extends VCanonicalLens {}

// Rank criteria according to SIS Lens logic
export type RankingCriteria = 'normal' | 'urgent' | 'special';

export interface RankingOption {
  lens_id: UUID;
  lens_name: string;
  brand_name: string;
  is_premium: boolean;
  supplier_id: UUID;
  supplier_name: string;
  price_cost: number;
  price_final: number;
  lead_time_days: number;
  total_score: number;
  score_breakdown: {
    price: number;
    delivery: number;
    quality: number;
    preference: number;
  };
}

// ============================================================================
// RESPOSTAS API
// ============================================================================

export interface ApiResponse<T> {
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: any;
  };
}

/** @deprecated Mantido para não quebrar referências imediatas, mas deve ser trocado por RankingCriteria */
export type CriterioRanking = RankingCriteria;
