import { supabase } from '$lib/supabase';
import type { 
  VCatalogLens, 
  VContactLens, 
  VBrand, 
  VCatalogLensStats,
  RpcLensSearchResult,
  RpcContactLensSearchResult,
  VCanonicalLens
} from '$lib/types/database-views';
import type { ApiResponse, RankingCriteria, RankingOption } from '$lib/types/sistema';

/**
 * LensOracleAPI — O Cérebro Clínico e Comercial do Ecossistema SIS
 * 
 * Centraliza todas as interações com o motor de lentes e catálogo.
 * Utiliza exclusivamente as Views e RPCs do novo banco (Migration 208+).
 */
export class LensOracleAPI {
  
  // ==========================================================================
  // LENTES OFTÁLMICAS (Óculos)
  // ==========================================================================

  /**
   * Busca lentes oftálmicas com suporte a filtros técnicos e busca textual.
   */
  static async searchLenses(params: {
    query?: string;
    lens_type?: string;
    material?: string;
    refractive_index?: number;
    is_premium?: boolean;
    has_ar?: boolean;
    has_blue?: boolean;
    limit?: number;
    offset?: number;
  }): Promise<ApiResponse<RpcLensSearchResult[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_lens_search', {
        p_search: params.query || null,
        p_lens_type: params.lens_type || null,
        p_material: params.material || null,
        p_refractive_index: params.refractive_index || null,
        p_has_ar: params.has_ar ?? null,
        p_has_blue: params.has_blue ?? null,
        p_limit: params.limit || 50,
        p_offset: params.offset || 0
      });

      if (error) throw error;
      return { data: data as RpcLensSearchResult[] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Busca lentes compatíveis com uma prescrição (receita).
   */
  static async searchByPrescription(params: {
    sphere: number;
    cylinder: number;
    addition?: number;
    lens_type?: string;
    limit?: number;
  }): Promise<ApiResponse<RpcLensSearchResult[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_lens_search', {
        p_sphere: params.sphere,
        p_cylinder: params.cylinder,
        p_addition: params.addition || null,
        p_lens_type: params.lens_type || null,
        p_limit: params.limit || 50
      });

      if (error) throw error;
      return { data: data as RpcLensSearchResult[] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Obtém detalhes completos de uma lente oftálmica.
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

  // ==========================================================================
  // LENTES DE CONTATO
  // ==========================================================================

  /**
   * Busca lentes de contato usando o novo motor (Migration 214).
   */
  static async searchContactLenses(params: {
    query?: string;
    brand_id?: string;
    lens_type?: string;
    purpose?: string;
    material?: string;
    is_colored?: boolean;
    premium_only?: boolean;
    limit?: number;
    offset?: number;
  }): Promise<ApiResponse<RpcContactLensSearchResult[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_contact_lens_search', {
        p_search: params.query || null,
        p_brand_id: params.brand_id || null,
        p_lens_type: params.lens_type || null,
        p_purpose: params.purpose || null,
        p_material: params.material || null,
        p_is_colored: params.is_colored ?? null,
        p_premium_only: params.premium_only ?? false,
        p_limit: params.limit || 50,
        p_offset: params.offset || 0
      });

      if (error) throw error;
      return { data: data as RpcContactLensSearchResult[] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  // ==========================================================================
  // CANONICALIZAÇÃO & RANKING (O "Cérebro")
  // ==========================================================================

  /**
   * Busca conceitos canônicos únicos (Migration 212).
   */
  static async getCanonicalLenses(params: {
    lens_type?: string;
    material?: string;
    refractive_index?: number;
  }): Promise<ApiResponse<VCanonicalLens[]>> {
    try {
      let query = supabase.from('v_canonical_lenses').select('*');
      
      if (params.lens_type) query = query.eq('lens_type', params.lens_type);
      if (params.material) query = query.eq('material', params.material);
      if (params.refractive_index) query = query.eq('refractive_index', params.refractive_index);

      const { data, error } = await query;
      if (error) throw error;
      return { data: data as VCanonicalLens[] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * RPC: Melhor opção de compra baseada em algoritmos de ranking.
   */
  static async getBestPurchaseOptions(canonicalId: string, limit: number = 5): Promise<ApiResponse<RankingOption[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_canonical_best_purchase', {
        p_canonical_lens_id: canonicalId,
        p_limit: limit
      });

      if (error) throw error;
      return { data: data as RankingOption[] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  // ==========================================================================
  // MARCAS & ESTATÍSTICAS
  // ==========================================================================

  /**
   * Lista marcas disponíveis no catálogo (Migration 210).
   */
  static async getBrands(params: {
    scope?: 'ophthalmic' | 'contact' | 'both';
    premium_only?: boolean;
    search?: string;
  }): Promise<ApiResponse<VBrand[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_brands_list', {
        p_scope: params.scope || null,
        p_premium_only: params.premium_only ?? false,
        p_search: params.search || null
      });

      if (error) throw error;
      return { data: data as VBrand[] };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Obtém estatísticas rápidas do catálogo.
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
   * Obtém rankings de lentes (mais caras, mais populares, premium).
   */
  static async getRankings(params: { category?: 'expensive' | 'popular' | 'premium', limit?: number }): Promise<ApiResponse<RpcLensSearchResult[]>> {
    try {
      // Por enquanto simulamos via search com sorting (ou RPC dedicada se existir)
      const { data, error } = await supabase.rpc('rpc_lens_search', {
        p_search: null,
        p_is_premium: params.category === 'premium' ? true : null,
        p_limit: params.limit || 10,
        // O banco novo pode não ter p_sort, então ordenamos no JS se necessário
      });

      if (error) throw error;
      
      let results = data as RpcLensSearchResult[];
      if (params.category === 'expensive') {
        results.sort((a, b) => b.price_suggested - a.price_suggested);
      }
      
      return { data: results };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }

  /**
   * Obtém distribuição por tipo ou material.
   */
  static async getDistribution(by: 'type' | 'material'): Promise<ApiResponse<any[]>> {
    try {
      const { data, error } = await supabase.from('v_catalog_lens_stats').select('*').single();
      if (error) throw error;
      
      // Mapeamento das estatísticas para o formato esperado pelos gráficos
      // Nota: v_catalog_lens_stats do banco novo contém contadores globais
      // Simulamos a distribuição baseada nesses contadores
      const dist = by === 'type' 
        ? [
            { tipo_lente: 'single_vision', count: data.total_visao_simples || 0 },
            { tipo_lente: 'multifocal', count: data.total_multifocal || 0 },
            { tipo_lente: 'bifocal', count: data.total_bifocal || 0 }
          ]
        : [
            { material: 'cr39', count: data.total_cr39 || 0 },
            { material: 'polycarbonate', count: data.total_policarbonato || 0 },
            { material: 'high_index', count: data.total_high_index || 0 }
          ];

      return { data: dist };
    } catch (error: any) {
      return { error: { code: error.code, message: error.message } };
    }
  }
}
