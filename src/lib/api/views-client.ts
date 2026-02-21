/**
 * API Client para Views Consolidadas do Banco
 *
 * ─── NOVO BANCO (migration 111+) ─────────────────────────────────────────────
 * Surface de leitura:
 *   public.v_catalog_lenses      → buscarLentes() / obterLentePorId()
 *   public.v_catalog_lens_stats  → obterEstatisticasCatalogo()
 * Surface de busca (SECURITY DEFINER RPCs):
 *   public.rpc_lens_search(...)          → buscarLentesRpc()
 *   public.rpc_lens_get_alternatives(…)  → obterAlternativasLente()
 * Wrappers PT-BR (compat):
 *   public.buscar_lentes(...)            → buscarLentesLegado()
 *   public.obter_alternativas_lente(...) → obterAlternativasLenteLegado()
 *
 * Grupos canônicos: enquanto `public.v_catalog_lens_groups` não existir,
 * buscarGruposCanonicos() deriva grupos de v_catalog_lenses (SELECT DISTINCT).
 */

import { supabase } from '$lib/supabase';
import type {
  VCatalogLens,
  VCatalogLensStats,
  VCatalogLensGroup,
  RpcLensSearchResult,
  RpcLensAlternativeResult,
  // Legado (compat)
  VLenteCatalogo,
  VGruposCanonico,
  StatsCatalogo,
  TipoLente,
  CategoriaLente,
  MaterialLente,
  IndiceRefracao
} from '$lib/types/database-views';

// ─── Aliases para compat com código que usa nomes antigos ─────────────────────
/** @deprecated Use VCatalogLens */
type VLente = VCatalogLens;
/** @deprecated Use VCatalogLensGroup */
type VGrupoCanonicos = VGruposCanonico;

// ============================================================================
// PARÂMETROS DE BUSCA
// ============================================================================

/**
 * Parâmetros para busca de lentes na view `v_catalog_lenses`.
 * Campos novos (EN) têm prioridade; campos legados (PT) são mantidos por compat.
 */
export interface BuscarLentesParams {
  // ─── Novo banco (preferir) ─────────────────────────────────────────────────
  /** 'single_vision' | 'multifocal' | … */
  lens_type?: string;
  /** ID UUID do fornecedor/lab */
  supplier_lab_id?: string;
  /** ID UUID do grupo canônico */
  group_id?: string;
  /** Busca por nome da marca (LIKE) */
  brand_name?: string;

  // ─── Legado PT-BR (mapeados internamente) ──────────────────────────────────
  /** @deprecated Usar lens_type */
  tipo_lente?: TipoLente;
  material?: MaterialLente;
  /** @deprecated Usar refractive_index numérico */
  indice_refracao?: IndiceRefracao;
  /** @deprecated Usar category */
  categoria?: CategoriaLente;
  /** @deprecated Sem equivalente direto no novo banco (use brand_name) */
  marca_id?: string;
  /** @deprecated Usar supplier_lab_id */
  fornecedor_id?: string;
  /** @deprecated Usar group_id */
  grupo_canonico_id?: string;

  // ─── Filtros de tratamentos ────────────────────────────────────────────────
  com_ar?: boolean;
  com_blue?: boolean;
  com_polarizado?: boolean;
  com_antirrisco?: boolean;
  com_uv?: boolean;
  com_fotossensivel?: boolean;

  // ─── Faixas ópticas ────────────────────────────────────────────────────────
  grau_esferico_min?: number;
  grau_esferico_max?: number;
  grau_cilindrico_min?: number;
  grau_cilindrico_max?: number;

  // ─── Preço ─────────────────────────────────────────────────────────────────
  preco_min?: number;
  preco_max?: number;

  // ─── Ordenação / Paginação ─────────────────────────────────────────────────
  ordenar_por?: 'nome' | 'preco' | 'marca' | 'indice' | 'prazo';
  ordem?: 'asc' | 'desc';
  limite?: number;
  offset?: number;
}

/**
 * Parâmetros para busca de grupos canônicos.
 * Enquanto `v_catalog_lens_groups` não existir, usa `v_catalog_lenses`.
 */
export interface BuscarGruposParams {
  tipo_lente?: TipoLente;
  material?: MaterialLente;
  indice_refracao?: IndiceRefracao;
  categoria_predominante?: CategoriaLente;
  is_premium?: boolean;
  preco_min?: number;
  preco_max?: number;
  ordenar_por?: 'nome' | 'preco' | 'total_lentes' | 'total_fornecedores';
  ordem?: 'asc' | 'desc';
  limite?: number;
  offset?: number;
}

// ============================================================================
// TIPOS DE RESPOSTA
// ============================================================================

export interface ApiResponse<T> {
  success: boolean;
  data: T[];
  total?: number;
  error?: string;
  metadata?: {
    limite: number;
    offset: number;
    paginas: number;
  };
}

export interface SingleApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}

// ============================================================================
// CLIENTE PRINCIPAL
// ============================================================================

export class ViewsApiClient {

  // ==========================================================================
  // LENTES — view: public.v_catalog_lenses  (migration 111)
  // ==========================================================================

  /**
   * Buscar lentes usando a view consolidada `public.v_catalog_lenses`.
   * Suporta filtros legados (PT-BR) mapeados para colunas do novo banco.
   */
  static async buscarLentes(params: BuscarLentesParams = {}): Promise<ApiResponse<VCatalogLens>> {
    try {
      let query = supabase
        .from('v_catalog_lenses')
        .select('*', { count: 'exact' });

      // ─── Tipo de lente ────────────────────────────────────────────────────
      const lensType = params.lens_type || params.tipo_lente;
      if (lensType) {
        query = query.eq('lens_type', lensType);
      }

      // ─── Material ─────────────────────────────────────────────────────────
      if (params.material) {
        query = query.eq('material', params.material);
      }

      // ─── Índice de refração ───────────────────────────────────────────────
      if (params.indice_refracao) {
        query = query.eq('refractive_index', parseFloat(params.indice_refracao));
      }

      // ─── Categoria ────────────────────────────────────────────────────────
      if (params.categoria) {
        query = query.eq('category', params.categoria);
      }

      // ─── Marca (nome, LIKE) ───────────────────────────────────────────────
      if (params.brand_name) {
        query = query.ilike('brand_name', `%${params.brand_name}%`);
      }
      // marca_id legado não tem equivalente direto; ignorado com aviso
      if (params.marca_id) {
        console.warn('[ViewsApiClient] marca_id não é suportado no novo banco. Use brand_name.');
      }

      // ─── Fornecedor ───────────────────────────────────────────────────────
      const supplierId = params.supplier_lab_id || params.fornecedor_id;
      if (supplierId) {
        query = query.eq('supplier_lab_id', supplierId);
      }

      // ─── Grupo canônico ───────────────────────────────────────────────────
      const groupId = params.group_id || params.grupo_canonico_id;
      if (groupId) {
        query = query.eq('group_id', groupId);
      }

      // ─── Tratamentos ──────────────────────────────────────────────────────
      if (params.com_ar !== undefined) {
        query = query.eq('anti_reflective', params.com_ar);
      }
      if (params.com_blue !== undefined) {
        query = query.eq('blue_light', params.com_blue);
      }
      if (params.com_polarizado !== undefined) {
        query = query.eq('polarized', params.com_polarizado);
      }
      if (params.com_antirrisco !== undefined) {
        query = query.eq('anti_scratch', params.com_antirrisco);
      }
      if (params.com_uv !== undefined) {
        query = query.eq('uv_filter', params.com_uv);
      }
      if (params.com_fotossensivel !== undefined) {
        query = params.com_fotossensivel
          ? query.not('photochromic', 'is', null).neq('photochromic', 'nenhum')
          : query.or('photochromic.is.null,photochromic.eq.nenhum');
      }

      // ─── Faixas ópticas ───────────────────────────────────────────────────
      // Lente compatível se range da lente "cobre" o grau do paciente:
      //   spherical_max >= grau_min  &&  spherical_min <= grau_max
      if (params.grau_esferico_min !== undefined) {
        query = query.gte('spherical_max', params.grau_esferico_min);
      }
      if (params.grau_esferico_max !== undefined) {
        query = query.lte('spherical_min', params.grau_esferico_max);
      }
      if (params.grau_cilindrico_min !== undefined) {
        query = query.gte('cylindrical_max', params.grau_cilindrico_min);
      }
      if (params.grau_cilindrico_max !== undefined) {
        query = query.lte('cylindrical_min', params.grau_cilindrico_max);
      }

      // ─── Preço ────────────────────────────────────────────────────────────
      if (params.preco_min !== undefined) {
        query = query.gte('price_suggested', params.preco_min);
      }
      if (params.preco_max !== undefined) {
        query = query.lte('price_suggested', params.preco_max);
      }

      // ─── Apenas ativos ────────────────────────────────────────────────────
      query = query.eq('status', 'active');

      // ─── Ordenação ────────────────────────────────────────────────────────
      const ordenarPor = params.ordenar_por || 'nome';
      const ordem = params.ordem || 'asc';

      switch (ordenarPor) {
        case 'preco':
          query = query.order('price_suggested', { ascending: ordem === 'asc' });
          break;
        case 'marca':
          query = query.order('brand_name', { ascending: ordem === 'asc' });
          break;
        case 'indice':
          query = query.order('refractive_index', { ascending: ordem === 'desc' });
          break;
        case 'prazo':
          query = query.order('lead_time_days', { ascending: ordem === 'asc' });
          break;
        default:
          query = query.order('lens_name', { ascending: ordem === 'asc' });
      }

      // ─── Paginação ────────────────────────────────────────────────────────
      const limite = params.limite || 50;
      const offset = params.offset || 0;
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: (data as VCatalogLens[]) || [],
        total: count || 0,
        metadata: {
          limite,
          offset,
          paginas: count ? Math.ceil(count / limite) : 0
        }
      };
    } catch (error) {
      console.error('Erro ao buscar lentes:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Obter detalhes de uma lente específica por ID.
   */
  static async obterLentePorId(lenteId: string): Promise<SingleApiResponse<VCatalogLens>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('*')
        .eq('id', lenteId)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data as VCatalogLens
      };
    } catch (error) {
      console.error('Erro ao obter lente:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  // ==========================================================================
  // BUSCA VIA RPC — public.rpc_lens_search(...)  (migration 111/114)
  // ==========================================================================

  /**
   * Buscar lentes usando o RPC `public.rpc_lens_search`.
   * SECURITY DEFINER — não requer acesso direto à tabela.
   */
  static async buscarLentesRpc(params: {
    lens_type?: string;
    material?: string;
    refractive_index?: number;
    price_min?: number;
    price_max?: number;
    has_ar?: boolean;
    has_blue?: boolean;
    supplier_lab_id?: string;
    brand_name?: string;
    limit?: number;
    offset?: number;
  } = {}): Promise<ApiResponse<RpcLensSearchResult>> {
    try {
      const { data, error } = await supabase.rpc('rpc_lens_search', {
        p_lens_type: params.lens_type ?? null,
        p_material: params.material ?? null,
        p_refractive_index: params.refractive_index ?? null,
        p_price_min: params.price_min ?? null,
        p_price_max: params.price_max ?? null,
        p_has_ar: params.has_ar ?? null,
        p_has_blue: params.has_blue ?? null,
        p_supplier_lab_id: params.supplier_lab_id ?? null,
        p_brand_name: params.brand_name ?? null,
        p_limit: params.limit ?? 50,
        p_offset: params.offset ?? 0
      });

      if (error) throw error;

      return {
        success: true,
        data: (data as RpcLensSearchResult[]) || [],
        total: (data as RpcLensSearchResult[])?.length || 0
      };
    } catch (error) {
      console.error('Erro em rpc_lens_search:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  // ==========================================================================
  // ALTERNATIVAS — public.rpc_lens_get_alternatives(...)  (migration 111/114)
  // ==========================================================================

  /**
   * Obter lentes alternativas para uma lente via mesmo grupo ou tipo/material.
   */
  static async obterAlternativasLente(
    lenteId: string,
    limit = 5
  ): Promise<ApiResponse<RpcLensAlternativeResult>> {
    try {
      const { data, error } = await supabase.rpc('rpc_lens_get_alternatives', {
        p_lens_id: lenteId,
        p_limit: limit
      });

      if (error) throw error;

      return {
        success: true,
        data: (data as RpcLensAlternativeResult[]) || [],
        total: (data as RpcLensAlternativeResult[])?.length || 0
      };
    } catch (error) {
      console.error('Erro em rpc_lens_get_alternatives:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  // ==========================================================================
  // GRUPOS CANÔNICOS — v_catalog_lens_groups (a criar) / fallback v_catalog_lenses
  // ==========================================================================

  /**
   * Buscar grupos canônicos.
   * Tenta `public.v_catalog_lens_groups` (migration pendente do usuário);
   * se não existir, deriva grupos distintos de `v_catalog_lenses`.
   */
  static async buscarGruposCanonicos(params: BuscarGruposParams = {}): Promise<ApiResponse<VCatalogLensGroup>> {
    // ─── Tentativa 1: view dedicada (será criada pelo usuário) ─────────────
    try {
      let query = supabase
        .from('v_catalog_lens_groups')
        .select('*', { count: 'exact' });

      if (params.is_premium !== undefined) {
        query = query.eq('is_premium', params.is_premium);
      }
      if (params.tipo_lente) {
        query = query.eq('lens_type', params.tipo_lente);
      }
      if (params.material) {
        query = query.eq('material', params.material);
      }

      const ordenarPor = params.ordenar_por || 'nome';
      const ordem = params.ordem || 'asc';
      query = query.order(ordenarPor === 'nome' ? 'name' : 'name', { ascending: ordem === 'asc' });

      const limite = params.limite || 100;
      const offset = params.offset || 0;
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) throw error; // se não existir, cai no fallback

      return {
        success: true,
        data: (data as VCatalogLensGroup[]) || [],
        total: count || 0,
        metadata: { limite, offset, paginas: count ? Math.ceil(count / limite) : 0 }
      };
    } catch {
      // ─── Fallback: derivar grupos de v_catalog_lenses ───────────────────
      console.info('[ViewsApiClient] v_catalog_lens_groups não encontrada — derivando de v_catalog_lenses');
    }

    try {
      let query = supabase
        .from('v_catalog_lenses')
        .select('group_id, group_name, lens_type, material, refractive_index, is_premium')
        .not('group_id', 'is', null);

      if (params.is_premium !== undefined) {
        query = query.eq('is_premium', params.is_premium);
      }
      if (params.tipo_lente) {
        query = query.eq('lens_type', params.tipo_lente);
      }
      if (params.material) {
        query = query.eq('material', params.material);
      }

      const { data, error } = await query;
      if (error) throw error;

      // Deduplicate by group_id
      const seen = new Set<string>();
      const groups: VCatalogLensGroup[] = (data || [])
        .filter((row: { group_id?: string }) => {
          if (!row.group_id || seen.has(row.group_id)) return false;
          seen.add(row.group_id);
          return true;
        })
        .map((row: {
          group_id: string;
          group_name: string | null;
          lens_type: string | null;
          material: string | null;
          refractive_index: number | null;
          is_premium: boolean;
        }) => ({
          id: row.group_id,
          tenant_id: '',
          name: row.group_name || row.group_id,
          lens_type: row.lens_type,
          material: row.material,
          refractive_index: row.refractive_index,
          is_premium: row.is_premium ?? false,
          is_active: true,
          created_at: '',
          updated_at: ''
        }));

      return {
        success: true,
        data: groups,
        total: groups.length
      };
    } catch (error) {
      console.error('Erro ao buscar grupos canônicos:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Obter um grupo canônico específico por ID.
   */
  static async obterGrupoPorId(grupoId: string): Promise<SingleApiResponse<VCatalogLensGroup>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lens_groups')
        .select('*')
        .eq('id', grupoId)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data as VCatalogLensGroup
      };
    } catch {
      // Fallback: buscar de v_catalog_lenses
      const result = await this.buscarGruposCanonicos({});
      const group = result.data.find((g) => g.id === grupoId);
      if (group) return { success: true, data: group };
      return { success: false, error: 'Grupo não encontrado' };
    }
  }

  /**
   * Obter lentes de um grupo canônico específico.
   */
  static async obterLentesDoGrupo(grupoId: string): Promise<ApiResponse<VCatalogLens>> {
    return this.buscarLentes({ group_id: grupoId });
  }

  // ==========================================================================
  // MARCAS — derivado de v_catalog_lenses (novo banco não tem tabela de marcas)
  // ==========================================================================

  /**
   * Listar marcas disponíveis (DISTINCT brand_name de v_catalog_lenses).
   * O novo banco não possui tabela separada de marcas — brand_name é TEXT.
   */
  static async listarMarcas(): Promise<ApiResponse<{ brand_name: string; total: number }>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('brand_name')
        .eq('status', 'active')
        .not('brand_name', 'is', null);

      if (error) throw error;

      // Agregar contagem por marca
      const countMap = new Map<string, number>();
      (data || []).forEach((row: { brand_name: string | null }) => {
        if (row.brand_name) {
          countMap.set(row.brand_name, (countMap.get(row.brand_name) || 0) + 1);
        }
      });

      const brands = Array.from(countMap.entries())
        .map(([brand_name, total]) => ({ brand_name, total }))
        .sort((a, b) => a.brand_name.localeCompare(b.brand_name));

      return {
        success: true,
        data: brands,
        total: brands.length
      };
    } catch (error) {
      console.error('Erro ao listar marcas:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Listar marcas premium (is_premium = true em v_catalog_lenses).
   */
  static async listarMarcasPremium(): Promise<ApiResponse<{ brand_name: string; total: number }>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('brand_name')
        .eq('status', 'active')
        .eq('is_premium', true)
        .not('brand_name', 'is', null);

      if (error) throw error;

      const countMap = new Map<string, number>();
      (data || []).forEach((row: { brand_name: string | null }) => {
        if (row.brand_name) {
          countMap.set(row.brand_name, (countMap.get(row.brand_name) || 0) + 1);
        }
      });

      const brands = Array.from(countMap.entries())
        .map(([brand_name, total]) => ({ brand_name, total }))
        .sort((a, b) => a.brand_name.localeCompare(b.brand_name));

      return {
        success: true,
        data: brands,
        total: brands.length
      };
    } catch (error) {
      console.error('Erro ao listar marcas premium:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Listar fornecedores/labs disponíveis (DISTINCT de v_catalog_lenses).
   * O novo banco não permite acesso direto a suppliers_labs; usa a view pública.
   */
  static async listarFornecedores(): Promise<ApiResponse<{ id: string; name: string; total: number }>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('supplier_lab_id, supplier_name')
        .eq('status', 'active')
        .not('supplier_lab_id', 'is', null);

      if (error) throw error;

      const seen = new Map<string, { id: string; name: string; total: number }>();
      (data || []).forEach((row: { supplier_lab_id: string | null; supplier_name: string | null }) => {
        if (!row.supplier_lab_id) return;
        const existing = seen.get(row.supplier_lab_id);
        if (existing) {
          existing.total++;
        } else {
          seen.set(row.supplier_lab_id, {
            id: row.supplier_lab_id,
            name: row.supplier_name || row.supplier_lab_id,
            total: 1
          });
        }
      });

      const suppliers = Array.from(seen.values())
        .sort((a, b) => a.name.localeCompare(b.name));

      return {
        success: true,
        data: suppliers,
        total: suppliers.length
      };
    } catch (error) {
      console.error('Erro ao listar fornecedores:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  // ==========================================================================
  // FILTROS — derivado de v_catalog_lenses
  // ==========================================================================

  /**
   * Obter filtros disponíveis para o catálogo via SELECT de v_catalog_lenses.
   */
  static async obterFiltrosDisponiveis(): Promise<SingleApiResponse<unknown>> {
    try {
      const { data: lentes, error } = await supabase
        .from('v_catalog_lenses')
        .select(
          'lens_type, material, refractive_index, category, brand_name, supplier_lab_id, supplier_name, is_premium'
        )
        .eq('status', 'active');

      if (error) throw error;

      const tiposMap = new Map<string, number>();
      const materiaisMap = new Map<string, number>();
      const indicesMap = new Map<string, number>();
      const categoriasMap = new Map<string, number>();
      const marcasMap = new Map<string, { nome: string; count: number }>();
      const fornecedoresMap = new Map<string, { id: string; nome: string; count: number }>();

      (lentes || []).forEach((l: {
        lens_type: string | null;
        material: string | null;
        refractive_index: number | null;
        category: string | null;
        brand_name: string | null;
        supplier_lab_id: string | null;
        supplier_name: string | null;
      }) => {
        if (l.lens_type) tiposMap.set(l.lens_type, (tiposMap.get(l.lens_type) || 0) + 1);
        if (l.material) materiaisMap.set(l.material, (materiaisMap.get(l.material) || 0) + 1);
        if (l.refractive_index !== null) {
          const k = String(l.refractive_index);
          indicesMap.set(k, (indicesMap.get(k) || 0) + 1);
        }
        if (l.category) categoriasMap.set(l.category, (categoriasMap.get(l.category) || 0) + 1);
        if (l.brand_name) {
          const e = marcasMap.get(l.brand_name);
          if (e) e.count++; else marcasMap.set(l.brand_name, { nome: l.brand_name, count: 1 });
        }
        if (l.supplier_lab_id) {
          const e = fornecedoresMap.get(l.supplier_lab_id);
          if (e) e.count++;
          else fornecedoresMap.set(l.supplier_lab_id, { id: l.supplier_lab_id, nome: l.supplier_name || l.supplier_lab_id, count: 1 });
        }
      });

      return {
        success: true,
        data: {
          tipos_lente: Array.from(tiposMap.entries())
            .map(([valor, total]) => ({ valor, total }))
            .sort((a, b) => b.total - a.total),
          materiais: Array.from(materiaisMap.entries())
            .map(([valor, total]) => ({ valor, total }))
            .sort((a, b) => b.total - a.total),
          indices_refracao: Array.from(indicesMap.entries())
            .map(([valor, total]) => ({ valor, total }))
            .sort((a, b) => parseFloat(a.valor) - parseFloat(b.valor)),
          categorias: Array.from(categoriasMap.entries())
            .map(([valor, total]) => ({ valor, total }))
            .sort((a, b) => b.total - a.total),
          marcas: Array.from(marcasMap.values()).sort((a, b) => a.nome.localeCompare(b.nome)),
          fornecedores: Array.from(fornecedoresMap.values()).sort((a, b) => a.nome.localeCompare(b.nome))
        }
      };
    } catch (error) {
      console.error('Erro ao obter filtros disponíveis:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  // ==========================================================================
  // ESTATÍSTICAS — view: public.v_catalog_lens_stats  (migration 111)
  // ==========================================================================

  /**
   * Obter estatísticas gerais do catálogo via `public.v_catalog_lens_stats`.
   */
  static async obterEstatisticasCatalogo(): Promise<SingleApiResponse<VCatalogLensStats>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lens_stats')
        .select('*')
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data as VCatalogLensStats
      };
    } catch (error) {
      console.error('Erro ao obter estatísticas:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  // ==========================================================================
  // COMPARAÇÃO DE FORNECEDORES
  // ==========================================================================

  /**
   * Comparar fornecedores para grupos canônicos.
   * @param grupoId - filtrar por grupo específico (opcional)
   * @param tipo    - 'PREMIUM' | 'GENÉRICA' (opcional)
   */
  static async compararFornecedores(
    grupoId?: string,
    tipo?: 'PREMIUM' | 'GENÉRICA'
  ): Promise<ApiResponse<VCatalogLensGroup>> {
    const params: BuscarGruposParams = {};
    if (tipo === 'PREMIUM') params.is_premium = true;
    if (tipo === 'GENÉRICA') params.is_premium = false;

    const base = await this.buscarGruposCanonicos(params);
    if (!base.success) return base;

    const data = grupoId
      ? base.data.filter((g) => g.id === grupoId)
      : base.data;

    return { ...base, data };
  }

  /**
   * Comparar fornecedores via grupo canônico de uma lente específica.
   * @param lenteId - ID da lente
   */
  static async compararFornecedoresPorLente(lenteId: string): Promise<ApiResponse<VCatalogLensGroup>> {
    const lente = await this.obterLentePorId(lenteId);
    if (!lente.success || !lente.data) {
      return { success: false, error: 'Lente não encontrada', data: [] };
    }
    const grupoId = lente.data.group_id ?? undefined;
    return this.compararFornecedores(grupoId);
  }

  // ==========================================================================
  // COMPAT — métodos legados (delegam para métodos novos)
  // ==========================================================================

  /**
   * @deprecated Use buscarGruposCanonicos({ is_premium: false })
   */
  static async buscarGruposGenericos(params: BuscarGruposParams = {}) {
    return this.buscarGruposCanonicos({ ...params, is_premium: false });
  }

  /**
   * @deprecated Use buscarGruposCanonicos({ is_premium: true })
   */
  static async buscarGruposPremium(params: BuscarGruposParams = {}) {
    return this.buscarGruposCanonicos({ ...params, is_premium: true });
  }

  /**
   * @deprecated Use buscarLentesRpc() com parâmetros EN.
   * Wrapper PT-BR que chama `public.buscar_lentes(...)`.
   */
  static async buscarLentesLegado(params: {
    tipo_lente?: string;
    material?: string;
    indice?: number;
    preco_min?: number;
    preco_max?: number;
    tem_ar?: boolean;
    tem_blue?: boolean;
    fornecedor_id?: string;
    marca?: string;
    limit?: number;
    offset?: number;
  } = {}): Promise<ApiResponse<{
    id: string; slug: string | null; nome: string; fornecedor: string | null;
    marca: string | null; tipo_lente: string | null; material: string | null;
    indice_refracao: number | null; preco: number; categoria: string | null;
    tem_ar: boolean; tem_blue: boolean; grupo_nome: string | null; estoque_disponivel: number;
  }>> {
    try {
      const { data, error } = await supabase.rpc('buscar_lentes', {
        p_tipo_lente: params.tipo_lente ?? null,
        p_material: params.material ?? null,
        p_indice: params.indice ?? null,
        p_preco_min: params.preco_min ?? null,
        p_preco_max: params.preco_max ?? null,
        p_tem_ar: params.tem_ar ?? null,
        p_tem_blue: params.tem_blue ?? null,
        p_fornecedor_id: params.fornecedor_id ?? null,
        p_marca: params.marca ?? null,
        p_limit: params.limit ?? 50,
        p_offset: params.offset ?? 0
      });

      if (error) throw error;

      return { success: true, data: data || [], total: (data || []).length };
    } catch (error) {
      console.error('Erro em buscar_lentes (legado):', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido', data: [] };
    }
  }

  /**
   * @deprecated Use obterAlternativasLente().
   * Wrapper PT-BR que chama `public.obter_alternativas_lente(...)`.
   */
  static async obterAlternativasLenteLegado(
    lenteId: string,
    limit = 5
  ): Promise<ApiResponse<{
    id: string; slug: string | null; nome: string; fornecedor: string | null;
    preco: number; diferenca_preco: number; prazo_dias: number;
  }>> {
    try {
      const { data, error } = await supabase.rpc('obter_alternativas_lente', {
        p_lente_id: lenteId,
        p_limit: limit
      });

      if (error) throw error;

      return { success: true, data: data || [], total: (data || []).length };
    } catch (error) {
      console.error('Erro em obter_alternativas_lente (legado):', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido', data: [] };
    }
  }
}

// ─── Singleton export ─────────────────────────────────────────────────────────
export const viewsApi = ViewsApiClient;
