/**
 * SIS Lens — LensOracleAPI
 * O Cérebro Clínico e Comercial do Ecossistema SIS_DIGIAI
 *
 * Banco: mhgbuplnxtfgipbemchb
 * Alinhado com as assinaturas REAIS das RPCs (migrations 111, 208, 210, 212, 214)
 * Verificado via Migration 219 (audit) e 220 (data verification)
 *
 * RPCs disponíveis (public schema):
 *   rpc_lens_search(p_lens_type, p_material, p_refractive_index, p_price_min, p_price_max,
 *                   p_has_ar, p_has_blue, p_supplier_id, p_brand_name, p_limit, p_offset, p_tenant_id)
 *   rpc_lens_get_alternatives(p_lens_id, p_limit, p_tenant_id)
 *   rpc_canonical_search(p_lens_type, p_material, p_refractive_index, p_anti_reflective,
 *                        p_photochromic, p_spherical_needed, p_cylindrical_needed,
 *                        p_addition_needed, p_limit, p_offset)
 *   rpc_canonical_best_purchase(p_canonical_lens_id, p_limit)
 *   rpc_contact_lens_search(p_brand_id, p_lens_type, p_purpose, p_material,
 *                           p_is_colored, p_can_sleep_with, p_premium_only,
 *                           p_spherical_needed, p_cylindrical_needed, p_search, p_limit, p_offset)
 *   rpc_brands_list(p_scope, p_premium_only, p_visible_only, p_search, p_limit, p_offset)
 *   rpc_pricing_simulate(p_cost, p_supplier_id, p_category)
 *
 * Views disponíveis (public schema):
 *   v_catalog_lenses, v_catalog_lens_stats, v_brands, v_brands_by_manufacturer
 *   v_canonical_lenses, v_canonical_lens_options, v_canonicalization_coverage
 *   v_contact_lenses, v_contact_lens_brand_stats, v_pricing_profiles, v_pricing_book
 *   v_system_health_audit, v_pricing_organism_health, v_contact_pricing_health, v_global_catalog_summary
 *   v_technical_commercial_catalog
 */

import { supabase } from '$lib/supabase';
import type {
  VCatalogLens,
  VContactLens,
  VBrand,
  VCatalogLensStats,
  RpcLensSearchResult,
  RpcContactLensSearchResult,
  VCanonicalLens,
} from '$lib/types/database-views';
import type { ApiResponse, RankingOption } from '$lib/types/sistema';

// ──────────────────────────────────────────────────────────────
// Tipos internos alinhados ao banco novo
// ──────────────────────────────────────────────────────────────

export interface LensSearchParams {
  /** Busca livre por texto (brand_name / lens_name) — filtrada no JS */
  query?: string;
  /** Enum: 'single_vision' | 'multifocal' | 'bifocal' | 'office' | 'contact_lens' */
  lens_type?: string;
  /** Enum: 'cr39' | 'polycarbonate' | 'trivex' | 'high_index' | 'glass' */
  material?: string;
  refractive_index?: number;
  price_min?: number;
  price_max?: number;
  has_ar?: boolean;
  has_blue?: boolean;
  /** UUID do supplier (sales_finance.suppliers.id) */
  supplier_id?: string;
  brand_name?: string;
  /** Filtrar por is_premium — feito via brand check no JS (banco não tem parâmetro direto) */
  is_premium?: boolean;
  limit?: number;
  offset?: number;
}

export interface CanonicalSearchParams {
  lens_type?: string;
  material?: string;
  refractive_index?: number;
  anti_reflective?: boolean;
  photochromic?: string;
  /** Grau esférico da receita */
  spherical_needed?: number;
  /** Grau cilíndrico da receita */
  cylindrical_needed?: number;
  addition_needed?: number;
  limit?: number;
  offset?: number;
}

export interface ContactLensSearchParams {
  query?: string;
  brand_id?: string;
  /** Enum: 'diaria' | 'quinzenal' | 'mensal' */
  lens_type?: string;
  /** Enum: 'visao_simples' | 'torica' | 'multifocal' | 'colorida' */
  purpose?: string;
  material?: string;
  is_colored?: boolean;
  can_sleep_with?: boolean;
  premium_only?: boolean;
  spherical_needed?: number;
  cylindrical_needed?: number;
  limit?: number;
  offset?: number;
}

// ──────────────────────────────────────────────────────────────
// LensOracleAPI
// ──────────────────────────────────────────────────────────────

export class LensOracleAPI {

  // ════════════════════════════════════════════════════════════
  // LENTES OFTÁLMICAS (Óculos)
  // ════════════════════════════════════════════════════════════

  /**
   * Busca lentes oftálmicas usando rpc_lens_search.
   * Parâmetros alinhados com a assinatura REAL da migration 118 (Unified Suppliers).
   */
  static async searchLenses(params: LensSearchParams): Promise<ApiResponse<RpcLensSearchResult[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_lens_search', {
        p_lens_type:        params.lens_type        ?? null,
        p_material:         params.material          ?? null,
        p_refractive_index: params.refractive_index  ?? null,
        p_price_min:        params.price_min         ?? null,
        p_price_max:        params.price_max         ?? null,
        p_has_ar:           params.has_ar            ?? null,
        p_has_blue:         params.has_blue          ?? null,
        p_supplier_id:      params.supplier_id       ?? null,
        p_brand_name:       params.brand_name        ?? null,
        p_limit:            params.limit             ?? 50,
        p_offset:           params.offset            ?? 0,
        p_tenant_id:        null,  // resolvido pelo JWT via current_tenant_id()
      });

      if (error) throw error;

      let results = (data as RpcLensSearchResult[]) ?? [];

      // Filtros pós-banco (banco não suporta esses parâmetros diretamente)
      if (params.is_premium !== undefined) {
        // is_premium vem do campo is_premium no resultado
        results = results.filter(r => r.is_premium === params.is_premium);
      }
      if (params.query) {
        const q = params.query.toLowerCase();
        results = results.filter(r =>
          r.lens_name?.toLowerCase().includes(q) ||
          r.brand_name?.toLowerCase().includes(q) ||
          r.supplier_name?.toLowerCase().includes(q)
        );
      }

      return { data: results };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Busca por prescrição/receita usando rpc_canonical_search (Migration 212).
   * Este é o "motor clínico" — encontra conceitos canônicos que cobrem a receita.
   */
  static async searchByPrescription(params: CanonicalSearchParams): Promise<ApiResponse<VCanonicalLens[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_canonical_search', {
        p_lens_type:          params.lens_type          ?? null,
        p_material:           params.material           ?? null,
        p_refractive_index:   params.refractive_index   ?? null,
        p_anti_reflective:    params.anti_reflective    ?? null,
        p_photochromic:       params.photochromic       ?? null,
        p_spherical_needed:   params.spherical_needed   ?? null,
        p_cylindrical_needed: params.cylindrical_needed ?? null,
        p_addition_needed:    params.addition_needed    ?? null,
        p_limit:              params.limit              ?? 20,
        p_offset:             params.offset             ?? 0,
      });

      if (error) throw error;
      return { data: (data as VCanonicalLens[]) ?? [] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Detalhes completos de uma lente oftálmica (via view v_catalog_lenses).
   */
  static async getLensById(id: string): Promise<ApiResponse<VCatalogLens>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;
      return { data: data as VCatalogLens };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Alternativas para uma lente (mesmos parâmetros, outros fornecedores).
   */
  static async getAlternatives(lensId: string, limit = 5): Promise<ApiResponse<RpcLensSearchResult[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_lens_get_alternatives', {
        p_lens_id:   lensId,
        p_limit:     limit,
        p_tenant_id: null,
      });

      if (error) throw error;
      return { data: (data as RpcLensSearchResult[]) ?? [] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  // ════════════════════════════════════════════════════════════
  // CANONICALIZAÇÃO & RANKING (O "Cérebro")
  // ════════════════════════════════════════════════════════════

  /**
   * Busca conceitos canônicos únicos (view v_canonical_lenses).
   */
  static async getCanonicalLenses(params: {
    lens_type?: string;
    material?: string;
    refractive_index?: number;
    limit?: number;
    is_premium?: boolean;
  }): Promise<ApiResponse<VCanonicalLens[]>> {
    try {
      // Usa as novas views limpas criadas para separar Standard de Premium
      let view = 'v_canonical_lenses'; // fallback
      if (params.is_premium === true) view = 'v_premium_catalog';
      else if (params.is_premium === false) view = 'v_standard_catalog';

      let query = supabase.from(view).select('*');

      if (params.lens_type)        query = query.eq('lens_type', params.lens_type);
      if (params.material)         query = query.eq('material', params.material);
      if (params.refractive_index) query = query.eq('refractive_index', params.refractive_index);
      if (params.limit)            query = query.limit(params.limit);

      const { data, error } = await query;
      if (error) throw error;
      
      // Mapeia os nomes das colunas se as views usarem nomes amigáveis
      return { data: (data as any[]) ?? [] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Atalho para buscar apenas canônicas Premium.
   */
  static async getCanonicalPremium(params: {
    lens_type?: string;
    material?: string;
    refractive_index?: number;
    limit?: number;
  }): Promise<ApiResponse<VCanonicalLens[]>> {
    return LensOracleAPI.getCanonicalLenses({ ...params, is_premium: true });
  }

  /**
   * Atalho para buscar apenas canônicas Standard.
   */
  static async getCanonicalStandard(params: {
    lens_type?: string;
    material?: string;
    refractive_index?: number;
    limit?: number;
  }): Promise<ApiResponse<VCanonicalLens[]>> {
    return LensOracleAPI.getCanonicalLenses({ ...params, is_premium: false });
  }

  /**
   * Melhor opção de compra para um conceito canônico (ranking de fornecedores).
   */
  static async getBestPurchaseOptions(canonicalId: string, limit = 5): Promise<ApiResponse<RankingOption[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_canonical_best_purchase', {
        p_canonical_lens_id: canonicalId,
        p_limit:             limit,
      });

      if (error) throw error;
      return { data: (data as RankingOption[]) ?? [] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  // ════════════════════════════════════════════════════════════
  // LENTES DE CONTATO
  // ════════════════════════════════════════════════════════════

  /**
   * Busca lentes de contato (rpc_contact_lens_search — Migration 214).
   * Parâmetros alinhados com a assinatura REAL verificada na Migration 219.
   */
  static async searchContactLenses(params: ContactLensSearchParams): Promise<ApiResponse<RpcContactLensSearchResult[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_contact_lens_search', {
        p_brand_id:           params.brand_id           ?? null,
        p_lens_type:          params.lens_type          ?? null,
        p_purpose:            params.purpose            ?? null,
        p_material:           params.material           ?? null,
        p_is_colored:         params.is_colored         ?? null,
        p_can_sleep_with:     params.can_sleep_with     ?? null,
        p_premium_only:       params.premium_only       ?? false,
        p_spherical_needed:   params.spherical_needed   ?? null,
        p_cylindrical_needed: params.cylindrical_needed ?? null,
        p_search:             params.query              ?? null,
        p_limit:              params.limit              ?? 50,
        p_offset:             params.offset             ?? 0,
      });

      if (error) throw error;
      return { data: (data as RpcContactLensSearchResult[]) ?? [] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Detalhes de uma lente de contato específica.
   */
  static async getContactLensById(id: string): Promise<ApiResponse<VContactLens>> {
    try {
      const { data, error } = await supabase
        .from('v_contact_lenses')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;
      return { data: data as VContactLens };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  // ════════════════════════════════════════════════════════════
  // MARCAS & ESTATÍSTICAS
  // ════════════════════════════════════════════════════════════

  /**
   * Lista marcas (rpc_brands_list — Migration 210).
   * Parâmetros alinhados com a assinatura REAL verificada na Migration 219.
   */
  static async getBrands(params: {
    scope?: 'ophthalmic' | 'contact' | 'both';
    premium_only?: boolean;
    visible_only?: boolean;
    search?: string;
    limit?: number;
    offset?: number;
  }): Promise<ApiResponse<VBrand[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_brands_list', {
        p_scope:        params.scope        ?? null,
        p_premium_only: params.premium_only ?? false,
        p_visible_only: params.visible_only ?? true,
        p_search:       params.search       ?? null,
        p_limit:        params.limit        ?? 100,
        p_offset:       params.offset       ?? 0,
      });

      if (error) throw error;
      return { data: (data as VBrand[]) ?? [] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Estatísticas globais do catálogo (view v_catalog_lens_stats).
   * tenant_id é resolvido via current_tenant_id() pelo JWT.
   */
  static async getCatalogStats(): Promise<ApiResponse<VCatalogLensStats>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lens_stats')
        .select('*')
        .single();

      if (error) throw error;
      return { data: data as VCatalogLensStats };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Simula precificação dinâmica para um custo de lente.
   * Usa rpc_pricing_simulate (Migration 208).
   */
  static async simulatePricing(params: {
    cost: number;
    supplier_id?: string;
    category?: string;
  }): Promise<ApiResponse<{ sell_price: number; effective_markup: number }>> {
    try {
      const { data, error } = await supabase.rpc('rpc_pricing_simulate', {
        p_cost:        params.cost,
        p_supplier_id: params.supplier_id ?? null,
        p_category:    params.category    ?? null,
      });

      if (error) throw error;
      return { data: data as { sell_price: number; effective_markup: number } };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Lentes mais caras ou premium para listagens rápidas.
   * Nota: banco não tem p_sort — ordenação feita client-side.
   */
  static async getRankings(params: {
    category?: 'expensive' | 'popular' | 'premium';
    limit?: number;
  }): Promise<ApiResponse<RpcLensSearchResult[]>> {
    try {
      const isPremiumFilter = params.category === 'premium' ? true : undefined;

      const res = await LensOracleAPI.searchLenses({
        is_premium: isPremiumFilter,
        limit: params.limit ?? 10,
      });

      if (res.error) return res;

      let results = res.data ?? [];
      if (params.category === 'expensive') {
        results = [...results].sort((a, b) => (b.price_suggested ?? 0) - (a.price_suggested ?? 0));
      }

      return { data: results };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  // ════════════════════════════════════════════════════════════
  // SAÚDE DO SISTEMA & ORGANISMO VIVO
  // ════════════════════════════════════════════════════════════

  /**
   * Auditoria de saúde vital do sistema (Migration 238).
   */
  static async getSystemHealthAudit(): Promise<ApiResponse<any[]>> {
    try {
      const { data, error } = await supabase
        .from('v_system_health_audit')
        .select('*');
      if (error) throw error;
      return { data: data ?? [] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Resumo global do catálogo (Oftálmicas vs Contato) (Migration 241).
   */
  static async getGlobalCatalogSummary(): Promise<ApiResponse<any[]>> {
    try {
      const { data, error } = await supabase
        .from('v_global_catalog_summary')
        .select('*');
      if (error) throw error;
      return { data: data ?? [] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Saúde do Organismo de Precificação (Migration 240).
   */
  static async getPricingOrganismHealth(): Promise<ApiResponse<any[]>> {
    try {
      const { data, error } = await supabase
        .from('v_pricing_organism_health')
        .select('*');
      if (error) throw error;
      return { data: data ?? [] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Calibra o Organismo Vivo de Precificação (Migration 240).
   */
  static async autotunePricing(targetFloor = 250, targetCeilingFactor = 4.0): Promise<ApiResponse<any>> {
    try {
      const { data, error } = await supabase.rpc('fn_autotune_pricing', {
        p_target_floor: targetFloor,
        p_target_ceiling_factor: targetCeilingFactor
      });
      if (error) throw error;
      return { data };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Catálogo de Lentes com Abstração Comercial (Migration 237).
   */
  static async getTechnicalCommercialCatalog(params: { limit?: number; offset?: number }): Promise<ApiResponse<any[]>> {
    try {
      let query = supabase.from('v_technical_commercial_catalog').select('*');
      if (params.limit) query = query.limit(params.limit);
      if (params.offset) query = query.range(params.offset, params.offset + (params.limit ?? 10) - 1);

      const { data, error } = await query;
      if (error) throw error;
      return { data: data ?? [] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }
}
