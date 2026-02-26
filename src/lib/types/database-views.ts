/**
 * SIS Lens — Tipos TypeScript das Views e RPCs do Banco
 * Banco: mhgbuplnxtfgipbemchb (SIS_DIGIAI)
 *
 * ─── Canonical Engine v2 (migrations 274–278) ───────────────────────────────
 *   CanonicalLensV2          → v_canonical_lenses / v_canonical_lenses_premium
 *   CanonicalWithPricing     → v_canonical_lenses_pricing / _premium_pricing
 *   PrescriptionSearchResult → rpc_canonical_for_prescription (5 params)
 *   CanonicalDetail          → rpc_canonical_detail (2 params)
 *
 * ─── Catálogo (migrations 111, 210, 214) ────────────────────────────────────
 *   VCatalogLens      → public.v_catalog_lenses
 *   VCatalogLensStats → public.v_catalog_lens_stats
 *   VBrand            → public.v_brands (rpc_brands_list)
 *   VContactLens      → public.v_contact_lenses
 *   RpcLensSearchResult     → public.rpc_lens_search
 *   RpcContactLensSearchResult → public.rpc_contact_lens_search
 */

// ============================================================================
// NOVO BANCO — ENUMS  (migration 002_types_and_enums.sql)
// ============================================================================

/** Tipos de lente disponíveis no novo banco */
export type LensType =
  | 'single_vision'
  | 'multifocal'
  | 'bifocal'
  | 'reading'
  | 'occupational';

/** Materiais de lente disponíveis no novo banco */
export type LensMaterialType =
  | 'cr39'
  | 'polycarbonate'
  | 'trivex'
  | 'high_index'
  | 'glass'
  | 'acrylic';

/** Status de registro (inventory.record_status) */
export type RecordStatus = 'active' | 'inactive' | 'archived';

// ============================================================================
// NOVO BANCO — VIEW: public.v_catalog_lenses  (migration 111/212)
// ============================================================================

/**
 * Linha da view pública `public.v_catalog_lenses`.
 * JWT-tenant-filtered; acesso SELECT concedido ao role `authenticated`.
 */
export interface VCatalogLens {
  id: string;
  tenant_id: string;
  supplier_lab_id: string | null;
  brand_id: string | null;
  lens_name: string;
  brand_name: string | null;
  supplier_name: string | null;
  sku: string | null;
  slug: string | null;
  
  group_id: string | null;
  group_name: string | null;
  lens_type: string | null;
  material: string | null;
  refractive_index: number | null;
  category: string | null;
  
  anti_reflective: boolean;
  anti_scratch: boolean;
  uv_filter: boolean;
  blue_light: boolean;
  photochromic: string | null;
  polarized: boolean;
  
  digital: boolean;
  free_form: boolean;
  indoor: boolean;
  drive: boolean;
  
  spherical_min: number | null;
  spherical_max: number | null;
  cylindrical_min: number | null;
  cylindrical_max: number | null;
  addition_min: number | null;
  addition_max: number | null;
  
  price_cost: number;
  price_suggested: number;
  
  stock_available: number;
  lead_time_days: number;
  is_premium: boolean;
  status: string;
  
  created_at: string;
  updated_at: string;
}

// ============================================================================
// NOVO BANCO — VIEW: public.v_catalog_lens_groups (derived)
// ============================================================================

/**
 * Grupo canônico de lentes — view public.v_catalog_lens_groups (migration 076).
 * Campos reais: id, tenant_id, name, lens_type, material, refractive_index,
 *               is_premium, supplier_lab_id, created_at, updated_at
 * NOTA: is_active NÃO existe na view (já filtra deleted_at IS NULL).
 */
export interface VCatalogLensGroup {
  id: string;
  tenant_id: string;
  name: string;
  lens_type: string | null;
  material: string | null;
  refractive_index: number | null;
  is_premium: boolean;
  supplier_lab_id: string | null;
  created_at: string;
  updated_at: string;
}

// ============================================================================
// NOVO BANCO — VIEW: public.v_brands (migration 210)
// ============================================================================

export interface VBrand {
  brand_id: string;
  name: string;
  slug: string;
  logo_url: string | null;
  manufacturer_name: string | null;
  is_premium: boolean;
  brand_scope: 'ophthalmic' | 'contact' | 'both';
  is_active: boolean;
}

// ============================================================================
// NOVO BANCO — VIEW: public.v_contact_lenses (migration 214)
// ============================================================================

export interface VContactLens {
  id: string;
  tenant_id: string;
  brand_id: string;
  brand_name: string;
  manufacturer_name: string | null;
  product_name: string;
  slug: string;
  sku: string | null;
  lens_type: string;
  purpose: string;
  material: string;
  diameter: number | null;
  base_curve: number | null;
  dk_t: number | null;
  water_content: number | null;
  spherical_min: number | null;
  spherical_max: number | null;
  cylindrical_min: number | null;
  cylindrical_max: number | null;
  uv_protection: boolean;
  is_colored: boolean;
  available_colors: string[] | null;
  usage_days: number | null;
  units_per_box: number;
  price_cost: number;
  price_suggested: number;
  stock_available: number;
  lead_time_days: number;
  is_premium: boolean;
  status: string;
  created_at: string;
}

// ============================================================================
// NOVO BANCO — VIEW: public.v_canonical_lenses (migration 212)
// ============================================================================

export interface VCanonicalLens {
  canonical_lens_id: string;
  canonical_name: string;
  fingerprint: string;
  is_premium: boolean;
  slug: string | null;
  lens_type: string;
  material: string;
  refractive_index: number;
  category: string | null;
  anti_reflective: boolean;
  anti_scratch: boolean;
  uv_filter: boolean;
  blue_light: boolean;
  photochromic: string | null;
  spherical_min: number | null;
  spherical_max: number | null;
  cylindrical_min: number | null;
  cylindrical_max: number | null;
  addition_min: number | null;
  addition_max: number | null;
  global_mapped_count: number;
  global_supplier_count: number;
  has_premium_mapping: boolean;
  tenant_mapped_count: number;
  tenant_min_price: number | null;
  tenant_max_price: number | null;
  created_at: string;
}

export interface VCanonicalLensOption {
  canonical_lens_id: string;
  canonical_name: string;
  lens_id: string;
  lens_name: string;
  brand_name: string | null;
  is_premium: boolean;
  supplier_id: string;
  supplier_name: string | null;
  price_cost: number;
  final_price: number;
  lead_time_days: number;
  stock_available: number;
  confidence_score: number;
  match_method: string;
  lens_type: string;
  material: string;
  refractive_index: number;
  anti_reflective: boolean;
  blue_light: boolean;
  photochromic: string | null;
  spherical_min: number | null;
  spherical_max: number | null;
  cylindrical_min: number | null;
  cylindrical_max: number | null;
  addition_min: number | null;
  addition_max: number | null;
  is_preferred: boolean;
  effective_markup: number | null;
  margin_percent: number | null;
  has_discount: boolean;
  mapped_at: string;
}

// ============================================================================
// CANONICAL ENGINE v2 — Views e RPCs (migrations 274–278)
// ============================================================================

/**
 * Linha da view public.v_canonical_lenses ou v_canonical_lenses_premium.
 * Motor Canônico v2 — SKU legível, sem categoria no fingerprint.
 * Standard: CST + 6 dígitos | Premium: CPR + 6 dígitos.
 */
export interface CanonicalLensV2 {
  id: string;
  sku: string;                     // ex: "CST847392" | "CPR319204"
  fingerprint: string;
  canonical_name: string;
  lens_type: string;               // single_vision | multifocal | bifocal | ...
  material_class: string;          // cr39 | polycarbonate | high_index | trivex
  refractive_index: number;        // 1.50 | 1.56 | 1.67 | ...
  material_display: string;        // ex: "CR39 1.50" | "Policarbonato 1.59"
  treatment_codes: string[];       // ex: ["ar", "scratch", "blue"]
  spherical_min: number | null;
  spherical_max: number | null;
  cylindrical_min: number | null;
  cylindrical_max: number | null;
  addition_min: number | null;
  addition_max: number | null;
  mapped_lens_count: number;       // total de lentes mapeadas neste conceito
  mapped_supplier_count: number;
  mapped_brand_count: number;
  created_at: string;
  updated_at: string;
}

/**
 * Views v_canonical_lenses_pricing / v_canonical_lenses_premium_pricing.
 * Junta conceitos canônicos com pricing_book — inclui faixas de preço e markup.
 */
export interface CanonicalWithPricing extends CanonicalLensV2 {
  price_min: number | null;        // menor sell_price entre lentes do conceito
  price_max: number | null;        // maior sell_price
  price_avg: number | null;        // média de sell_price
  cost_min: number | null;         // menor cost_price
  cost_max: number | null;         // maior cost_price
  cost_avg: number | null;         // média de cost_price
  markup_min: number | null;       // menor effective_markup
  markup_max: number | null;       // maior effective_markup
}

/**
 * Resultado de rpc_canonical_for_prescription (migration 278).
 * Conceitos canônicos que cobrem uma determinada receita oftalmológica.
 */
export interface PrescriptionSearchResult {
  id: string;
  sku: string;
  canonical_name: string;
  lens_type: string;
  material_class: string;
  refractive_index: number;
  material_display: string;
  treatment_codes: string[];
  spherical_min: number | null;
  spherical_max: number | null;
  cylindrical_min: number | null;
  cylindrical_max: number | null;
  addition_min: number | null;
  addition_max: number | null;
  tenant_lens_count: number;       // qtd de lentes do tenant neste conceito
  price_min: number | null;
  price_max: number | null;
  price_avg: number | null;
  cost_min: number | null;
  cost_max: number | null;
  markup_min: number | null;
  markup_max: number | null;
}

/**
 * Resultado de rpc_canonical_detail (migration 278).
 * Lentes reais mapeadas para um conceito canônico, com preços do tenant.
 */
export interface CanonicalDetail {
  lens_id: string;
  lens_sku: string | null;
  lens_name: string;
  brand_name: string | null;
  supplier_name: string | null;
  sell_price: number;
  cost_price: number;
  final_price: number;
  effective_markup: number | null;
  is_preferred: boolean;
  match_method: string;
}

// ============================================================================
// NOVO BANCO — RPC: public.rpc_contact_lens_search (migration 214)
// ============================================================================

export interface RpcContactLensSearchResult {
  id: string;
  brand_name: string;
  manufacturer_name: string | null;
  is_premium: boolean;
  product_name: string;
  slug: string;
  lens_type: string;
  purpose: string;
  material: string;
  is_colored: boolean;
  available_colors: string[] | null;
  units_per_box: number;
  price_suggested: number;
  usage_days: number | null;
  dk_t: number | null;
  stock_available: number;
}

// ============================================================================
// NOVO BANCO — VIEW: public.v_catalog_lens_stats  (migration 111)
// ============================================================================

/**
 * Campos reais da view public.v_catalog_lens_stats (migration 111).
 * NOTA: total_brands NÃO existe — removido para não gerar queries erradas.
 */
export interface VCatalogLensStats {
  total_lenses: number;
  total_active: number;
  total_premium: number;
  total_with_ar: number;
  total_with_blue: number;
  total_photochromic: number;
  price_min: number | null;
  price_max: number | null;
  price_avg: number | null;
  stock_total: number;
}

// ============================================================================
// NOVO BANCO — RPC: public.rpc_lens_search (migration 111/114)
// ============================================================================

/**
 * Resultado REAL de public.rpc_lens_search (migration 111).
 * Exatamente os 16 campos que a RPC retorna — não adicione campos que não existem.
 *
 * SELECT id, slug, lens_name, supplier_name, brand_name, lens_type, material,
 *        refractive_index, price_suggested, category, has_ar, has_blue,
 *        group_name, stock_available, lead_time_days, is_premium
 */
export interface RpcLensSearchResult {
  id: string;
  slug: string | null;
  lens_name: string;
  supplier_name: string | null;
  brand_name: string | null;
  lens_type: string | null;
  material: string | null;
  refractive_index: number | null;
  price_suggested: number;
  category: string | null;
  /** Alias para anti_reflective — campo has_ar no retorno da RPC */
  has_ar: boolean;
  /** Alias para blue_light — campo has_blue no retorno da RPC */
  has_blue: boolean;
  group_name: string | null;
  stock_available: number;
  lead_time_days: number;
  is_premium: boolean;
}

