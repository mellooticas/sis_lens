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

export interface Session {
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

/** @deprecated Use Session */
export interface AppSession extends Session { }


// ============================================================================
// DOMÍNIO: Lentes e Catálogo
// ============================================================================

export interface Lens extends VCatalogLens { }
export interface ContactLens extends VContactLens { }
export interface Brand extends VBrand { }
export interface CanonicalLens extends VCanonicalLens { }

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

// ============================================================================
// TIPOS LEGADOS — mantidos para não quebrar stores/actions enquanto migram
// ============================================================================

/** @deprecated Use RankingCriteria */
export type CriterioDecisao = 'URGENCIA' | 'NORMAL' | 'ESPECIAL';

export type StatusDecisao = 'DECIDIDO' | 'ENVIADO' | 'CONFIRMADO' | 'ENTREGUE';

export interface DecisaoCompra {
  id: UUID;
  tenant_id: UUID;
  lente_id: UUID;
  laboratorio_id: UUID;
  criterio: CriterioDecisao;
  preco_final: number;
  prazo_estimado_dias: number;
  status: StatusDecisao;
  created_at: ISODateString;
  updated_at: ISODateString;
  [key: string]: unknown;
}

export interface FiltrosBusca {
  // Novo banco (LensOracleAPI)
  lens_type?: string;
  material?: string;
  refractive_index?: number;
  brand_name?: string;
  is_premium?: boolean;
  has_ar?: boolean;
  has_blue?: boolean;
  query?: string;
  price_min?: number;
  price_max?: number;
  // Campos legados usados pelo filtros.ts store
  usuario_id?: string | null;
  graduacao_de?: number | null;
  graduacao_ate?: number | null;
  tipo_lente?: string | null;
  tratamentos?: string[];
  faixa_preco_min?: number | null;
  faixa_preco_max?: number | null;
  ordenacao?: string;
}

/** @deprecated */
export interface OpcaoRanking extends RankingOption { }

/** @deprecated */
export interface FiltrosRanking {
  preco_maximo?: number;
  prazo_maximo_dias?: number;
  score_minimo?: number;
}

/** @deprecated */
export interface PayloadDecisao {
  lente_id: UUID;
  laboratorio_id: UUID;
  produto_lab_id: UUID;
  criterio: CriterioDecisao;
  preco_final: number;
  prazo_estimado_dias: number;
  custo_frete: number;
  score_atribuido: number;
  motivo: string;
  alternativas: unknown[];
}

/** @deprecated Use Session */
// export type Session = Session; // Already defined as interface above

