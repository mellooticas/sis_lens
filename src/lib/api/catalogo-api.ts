/**
 * API Client para as Views do Banco de Dados
 *
 * ============================================================================
 * NOVO BANCO (mhgbuplnxtfgipbemchb · migration 111+)
 * ============================================================================
 *  v_lentes                    → public.v_catalog_lenses
 *  v_grupos_canonicos          → public.v_catalog_lens_groups  (a ser criada)
 *  vw_canonicas_genericas      → v_catalog_lens_groups (is_premium = false)
 *  vw_canonicas_premium        → v_catalog_lens_groups (is_premium = true)
 *  vw_detalhes_premium         → v_catalog_lenses (filtro group_id + is_premium)
 *  vw_detalhes_genericas       → v_catalog_lenses (filtro group_id)
 *  vw_stats_catalogo           → public.v_catalog_lens_stats
 *  buscar_lentes_texto         → public.rpc_lens_search(...)
 *  buscar_lentes_por_receita   → filtro direto em v_catalog_lenses
 *  update_lente_catalog        → sem equivalente (futuro: rpc_catalog_upsert_lens)
 *
 * CAMPOS RENOMEADOS
 *  nome_lente / nome_comercial → lens_name
 *  nome_grupo                  → group_name (desnorm. em v_catalog_lenses) / name (groups view)
 *  tipo_lente                  → lens_type  (valores: single_vision, multifocal, …)
 *  indice_refracao             → refractive_index
 *  grau_esferico_min/max       → spherical_min/max
 *  grau_cilindrico_min/max     → cylindrical_min/max
 *  adicao_min/max              → addition_min/max
 *  preco_venda_sugerido        → price_suggested
 *  preco_custo                 → price_cost
 *  marca_nome                  → brand_name
 *  fornecedor_nome             → supplier_name
 *  tem_ar / ar                 → anti_reflective
 *  tem_blue / blue             → blue_light
 *  fotossensivel / tratamento_foto → photochromic
 *  tem_polarizado / polarizado → polarized
 *  tem_digital / digital       → digital  (igual)
 *  tem_free_form / free_form   → free_form (igual)
 *  estoque_disponivel          → stock_available
 *  prazo_visao_simples         → lead_time_days  (único campo no novo banco)
 *  grupo_id                    → group_id  (igual)
 *  ativo                       → is_active (groups) / status='active' (lenses)
 *  marca_premium               → is_premium
 *  policarbonato               → polycarbonate
 *  visao_simples               → single_vision
 */

import { supabase } from '$lib/supabase';
import type {
  VCatalogLens,
  VCatalogLensGroup,
  VCatalogLensStats,
  FiltrosLentes,
  PaginacaoParams,
  RespostaPaginada
} from '$lib/types/database-views';

type ApiResponse<T> = {
  success: boolean;
  data?: T;
  error?: string;
  count?: number;
};

export class CatalogoAPI {

  // ============================================================================
  // MÓDULO: BUSCAR LENTES
  // NOVO BANCO: public.v_catalog_lenses
  // ============================================================================

  /**
   * Buscar lentes completas com filtros.
   * Para o módulo "Buscar Lentes".
   */
  static async buscarLentes(
    filtros: FiltrosLentes = {},
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<VCatalogLens>>> {
    try {
      const { pagina = 1, limite = 50, ordenar = 'created_at', direcao = 'desc' } = paginacao;
      const offset = (pagina - 1) * limite;

      // Se tiver filtro de busca textual, usa a RPC rpc_lens_search
      if (filtros.busca && filtros.busca.length > 2) {
        return this.buscarLentesTexto(filtros.busca, paginacao);
      }

      // Se tiver receita, filtra direto na view
      // (buscarLentesPorReceita retorna formato compatível)

      let query = supabase
        .from('v_catalog_lenses')
        .select('*', { count: 'exact' });

      // ── Filtros por IDs ──────────────────────────────────────────────────────
      if (filtros.ids && filtros.ids.length > 0) {
        query = query.in('id', filtros.ids);
      }

      // ── Filtros técnicos ─────────────────────────────────────────────────────
      if (filtros.tipos && filtros.tipos.length > 0) {
        // FiltrosLentes usa TipoLente (PT), mas novo banco usa lens_type (EN).
        // Mapear valores comuns; não encontrados passam como-estão.
        const mapaLensType: Record<string, string> = {
          visao_simples: 'single_vision',
          multifocal: 'multifocal',
          bifocal: 'bifocal',
          leitura: 'reading',
          ocupacional: 'occupational'
        };
        const lensTypes = filtros.tipos.map(t => mapaLensType[t as string] ?? t);
        query = query.in('lens_type', lensTypes);
      }
      if (filtros.categorias && filtros.categorias.length > 0) {
        query = query.in('category', filtros.categorias);
      }
      if (filtros.materiais && filtros.materiais.length > 0) {
        // Mapear nomes PT → EN
        const mapaMaterial: Record<string, string> = {
          POLICARBONATO: 'polycarbonate',
          CR39: 'cr39',
          TRIVEX: 'trivex',
          HIGH_INDEX: 'high_index',
          VIDRO: 'glass',
          ACRILICO: 'acrylic',
          policarbonato: 'polycarbonate',
          cr39: 'cr39',
          trivex: 'trivex',
          high_index: 'high_index'
        };
        const materials = filtros.materiais.map(m => mapaMaterial[m as string] ?? m);
        query = query.in('material', materials);
      }
      if (filtros.indices && filtros.indices.length > 0) {
        query = query.in('refractive_index', filtros.indices.map(i => parseFloat(i as string)));
      }
      if (filtros.marcas && filtros.marcas.length > 0) {
        query = query.in('brand_name', filtros.marcas);
      }
      if (filtros.fornecedores && filtros.fornecedores.length > 0) {
        query = query.in('supplier_name', filtros.fornecedores);
      }

      // ── Filtros de faixas ópticas ─────────────────────────────────────────────
      if (filtros.graus) {
        if (filtros.graus.esferico !== undefined) {
          query = query
            .lte('spherical_min', filtros.graus.esferico)
            .gte('spherical_max', filtros.graus.esferico);
        }
        if (filtros.graus.cilindrico !== undefined) {
          query = query
            .lte('cylindrical_min', filtros.graus.cilindrico)
            .gte('cylindrical_max', filtros.graus.cilindrico);
        }
        if (filtros.graus.adicao !== undefined) {
          query = query
            .lte('addition_min', filtros.graus.adicao)
            .gte('addition_max', filtros.graus.adicao);
        }
      }

      // ── Filtros de classificação ──────────────────────────────────────────────
      if (filtros.marca_premium !== undefined) {
        query = query.eq('is_premium', filtros.marca_premium);
      }

      // ── Filtros de tratamentos ────────────────────────────────────────────────
      if (filtros.tratamentos) {
        if (filtros.tratamentos.ar === true)          query = query.eq('anti_reflective', true);
        if (filtros.tratamentos.blue === true)         query = query.eq('blue_light', true);
        if (filtros.tratamentos.fotossensivel === true) query = query.neq('photochromic', 'nenhum');
        if (filtros.tratamentos.polarizado === true)   query = query.eq('polarized', true);
        if (filtros.tratamentos.digital === true)      query = query.eq('digital', true);
        if (filtros.tratamentos.free_form === true)    query = query.eq('free_form', true);
      }

      // ── Filtro de preço ───────────────────────────────────────────────────────
      if (filtros.preco) {
        if (filtros.preco.min !== undefined) query = query.gte('price_suggested', filtros.preco.min);
        if (filtros.preco.max !== undefined) query = query.lte('price_suggested', filtros.preco.max);
      }

      // ── Busca textual simples ─────────────────────────────────────────────────
      if (filtros.busca) {
        query = query.ilike('lens_name', `%${filtros.busca}%`);
      }

      // ── Ordenação e paginação ─────────────────────────────────────────────────
      query = query.order(ordenar, { ascending: direcao === 'asc' });
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: {
          dados: (data as VCatalogLens[]) || [],
          paginacao: {
            total: count || 0,
            pagina,
            limite,
            total_paginas: Math.ceil((count || 0) / limite)
          }
        }
      };
    } catch (error) {
      console.error('❌ Erro ao buscar lentes:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * 🌟 Busca por Texto via RPC rpc_lens_search
   * Novo banco: public.rpc_lens_search(p_brand_name, p_lens_type, p_material, …)
   */
  static async buscarLentesTexto(
    busca: string,
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<VCatalogLens>>> {
    try {
      const { pagina = 1, limite = 50 } = paginacao;
      const offset = (pagina - 1) * limite;

      // rpc_lens_search aceita filtros individuais; usar p_brand_name como termo geral
      const { data, error } = await supabase
        .rpc('rpc_lens_search', {
          p_brand_name: busca,
          p_lens_type: null,
          p_material: null,
          p_refractive_index: null,
          p_is_premium: null,
          p_has_ar: null,
          p_has_blue: null
        })
        .range(offset, offset + limite - 1);

      if (error) {
        // Fallback: busca simples por lens_name / brand_name na view
        console.warn('⚠ rpc_lens_search falhou, usando fallback ilike:', error.message);
        const { data: fb, error: fbErr, count } = await supabase
          .from('v_catalog_lenses')
          .select('*', { count: 'exact' })
          .or(`lens_name.ilike.%${busca}%,brand_name.ilike.%${busca}%,supplier_name.ilike.%${busca}%`)
          .range(offset, offset + limite - 1);

        if (fbErr) throw fbErr;

        return {
          success: true,
          data: {
            dados: (fb as VCatalogLens[]) || [],
            paginacao: {
              total: count || 0,
              pagina,
              limite,
              total_paginas: Math.ceil((count || 0) / limite)
            }
          }
        };
      }

      const rows = (data as VCatalogLens[]) || [];
      return {
        success: true,
        data: {
          dados: rows,
          paginacao: {
            total: rows.length + offset,
            pagina,
            limite,
            total_paginas: rows.length < limite ? pagina : pagina + 1
          }
        }
      };
    } catch (error) {
      console.error('❌ Erro ao buscar lentes por texto:', error);
      return { success: false, error: (error as Error).message };
    }
  }

  /**
   * 🌟 Busca por Receita (Prescription Match)
   * Novo banco: filtro direto em v_catalog_lenses usando spherical_min/max, etc.
   */
  static async buscarLentesPorReceita(params: {
    receita: {
      esferico: number;
      cilindrico: number;
      eixo?: number;
      adicao?: number;
    };
    tipo_lente?: string;
    limite?: number;
  }): Promise<ApiResponse<{ dados: VCatalogLens[] }>> {
    try {
      let query = supabase
        .from('v_catalog_lenses')
        .select('*')
        .lte('spherical_min', params.receita.esferico)
        .gte('spherical_max', params.receita.esferico)
        .lte('cylindrical_min', params.receita.cilindrico)
        .gte('cylindrical_max', params.receita.cilindrico);

      if (params.receita.adicao !== undefined && params.receita.adicao !== null) {
        query = query
          .lte('addition_min', params.receita.adicao)
          .gte('addition_max', params.receita.adicao);
      }

      if (params.tipo_lente) {
        // Mapear nome PT para EN se necessário
        const mapaLensType: Record<string, string> = {
          visao_simples: 'single_vision',
          multifocal: 'multifocal',
          bifocal: 'bifocal',
          leitura: 'reading',
          ocupacional: 'occupational'
        };
        const lensType = mapaLensType[params.tipo_lente] ?? params.tipo_lente;
        query = query.eq('lens_type', lensType);
      }

      if (params.limite) {
        query = query.limit(params.limite);
      }

      const { data, error } = await query;

      if (error) throw error;

      return {
        success: true,
        data: { dados: (data as VCatalogLens[]) || [] },
        count: data?.length || 0
      };
    } catch (error) {
      console.error('❌ Erro ao buscar lentes por receita:', error);
      return { success: false, error: (error as Error).message };
    }
  }

  /**
   * Buscar uma lente específica por ID.
   * Novo banco: v_catalog_lenses
   */
  static async obterLente(id: string): Promise<ApiResponse<VCatalogLens>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: (data as VCatalogLens) || undefined
      };
    } catch (error) {
      console.error('Erro ao obter lente:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Atualizar preços e status de uma lente oftálmica.
   * Novo banco: RPC ainda não criada — retorna erro informativo.
   */
  static async atualizarLente(params: {
    id: string;
    price_cost: number;
    price_suggested: number;
    is_active: boolean;
  }): Promise<ApiResponse<void>> {
    // TODO: Criar public.rpc_catalog_upsert_lens(p_id, p_price_cost, p_price_suggested, p_is_active)
    console.warn('⚠ atualizarLente: RPC ainda não disponível no novo banco. Operação ignorada.', params);
    return {
      success: false,
      error: 'Atualização de lente ainda não implementada no novo banco (migration pendente).'
    };
  }

  // ============================================================================
  // MÓDULO: GRUPOS CANÔNICOS
  // NOVO BANCO: public.v_catalog_lens_groups  (a ser criada pelo usuário)
  //   Fallback: derivar grupos de v_catalog_lenses (group_id / group_name)
  // ============================================================================

  /**
   * Buscar grupos canônicos standard com filtros.
   * Novo banco: v_catalog_lens_groups (is_premium = false)
   */
  static async buscarGruposCanonicosStandard(
    filtros: FiltrosLentes = {},
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<VCatalogLensGroup>>> {
    try {
      console.log('🔍 API: buscarGruposCanonicosStandard', { filtros, paginacao });

      const { pagina = 1, limite = 50, ordenar = 'name', direcao = 'asc' } = paginacao;
      const offset = (pagina - 1) * limite;

      let query = supabase
        .from('v_catalog_lens_groups')
        .select('*', { count: 'exact' })
        .eq('is_premium', false);

      // Filtros
      if (filtros.tipos && filtros.tipos.length > 0) {
        const mapaLensType: Record<string, string> = {
          visao_simples: 'single_vision', multifocal: 'multifocal',
          bifocal: 'bifocal', leitura: 'reading', ocupacional: 'occupational'
        };
        query = query.in('lens_type', filtros.tipos.map(t => mapaLensType[t as string] ?? t));
      }
      if (filtros.materiais && filtros.materiais.length > 0) {
        const mapaMaterial: Record<string, string> = {
          POLICARBONATO: 'polycarbonate', CR39: 'cr39', TRIVEX: 'trivex',
          HIGH_INDEX: 'high_index', policarbonato: 'polycarbonate'
        };
        query = query.in('material', filtros.materiais.map(m => mapaMaterial[m as string] ?? m));
      }
      if (filtros.indices && filtros.indices.length > 0) {
        query = query.in('refractive_index', filtros.indices.map(i => parseFloat(i as string)));
      }
      if (filtros.busca) {
        query = query.ilike('name', `%${filtros.busca}%`);
      }

      // Ordenar; se pediu preco_medio ou total_lentes (campos antigos), usa name como fallback
      const colOrdenar = ['preco_medio', 'total_lentes', 'nome_grupo'].includes(ordenar)
        ? 'name'
        : ordenar;
      query = query.order(colOrdenar, { ascending: direcao === 'asc' });
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) {
        // View ainda não criada → fallback: derivar de v_catalog_lenses
        console.warn('⚠ v_catalog_lens_groups não encontrada, usando fallback:', error.message);
        return this._buscarGruposDerivados(false, filtros, pagina, limite, offset);
      }

      console.log('📥 buscarGruposCanonicosStandard:', data?.length ?? 0, 'grupos, total:', count);

      return {
        success: true,
        data: {
          dados: (data as VCatalogLensGroup[]) || [],
          paginacao: { total: count || 0, pagina, limite, total_paginas: Math.ceil((count || 0) / limite) }
        }
      };
    } catch (error) {
      console.error('❌ Erro ao buscar grupos canônicos standard:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Buscar grupos canônicos PREMIUM (is_premium = true).
   * Novo banco: v_catalog_lens_groups (is_premium = true)
   */
  static async buscarGruposCanonicosPremium(
    filtros: FiltrosLentes = {},
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<VCatalogLensGroup>>> {
    try {
      console.log('🔍 API: buscarGruposCanonicosPremium', { filtros, paginacao });

      const { pagina = 1, limite = 50, ordenar = 'name', direcao = 'desc' } = paginacao;
      const offset = (pagina - 1) * limite;

      let query = supabase
        .from('v_catalog_lens_groups')
        .select('*', { count: 'exact' })
        .eq('is_premium', true);

      if (filtros.tipos && filtros.tipos.length > 0) {
        const mapaLensType: Record<string, string> = {
          visao_simples: 'single_vision', multifocal: 'multifocal',
          bifocal: 'bifocal', leitura: 'reading', ocupacional: 'occupational'
        };
        query = query.in('lens_type', filtros.tipos.map(t => mapaLensType[t as string] ?? t));
      }
      if (filtros.materiais && filtros.materiais.length > 0) {
        const mapaMaterial: Record<string, string> = {
          POLICARBONATO: 'polycarbonate', CR39: 'cr39', TRIVEX: 'trivex',
          HIGH_INDEX: 'high_index', policarbonato: 'polycarbonate'
        };
        query = query.in('material', filtros.materiais.map(m => mapaMaterial[m as string] ?? m));
      }
      if (filtros.indices && filtros.indices.length > 0) {
        query = query.in('refractive_index', filtros.indices.map(i => parseFloat(i as string)));
      }
      if (filtros.busca) {
        query = query.ilike('name', `%${filtros.busca}%`);
      }

      const colOrdenar = ['preco_medio', 'total_lentes', 'nome_grupo', 'marca_nome,nome_canonico'].includes(ordenar)
        ? 'name'
        : ordenar;
      query = query.order(colOrdenar, { ascending: direcao === 'asc' });
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) {
        console.warn('⚠ v_catalog_lens_groups não encontrada, usando fallback:', error.message);
        return this._buscarGruposDerivados(true, filtros, pagina, limite, offset);
      }

      console.log('📥 buscarGruposCanonicosPremium:', data?.length ?? 0, 'grupos, total:', count);

      return {
        success: true,
        data: {
          dados: (data as VCatalogLensGroup[]) || [],
          paginacao: { total: count || 0, pagina, limite, total_paginas: Math.ceil((count || 0) / limite) }
        }
      };
    } catch (error) {
      console.error('❌ Erro ao buscar grupos canônicos premium:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Obter um grupo canônico específico por ID.
   * Novo banco: v_catalog_lens_groups
   */
  static async obterGrupoCanonico(id: string, is_premium?: boolean): Promise<ApiResponse<VCatalogLensGroup>> {
    try {
      let query = supabase
        .from('v_catalog_lens_groups')
        .select('*')
        .eq('id', id);

      if (is_premium !== undefined) {
        query = query.eq('is_premium', is_premium);
      }

      const { data, error } = await query.single();

      if (error) throw error;

      return { success: true, data: (data as VCatalogLensGroup) || undefined };
    } catch (error) {
      console.error('Erro ao obter grupo canônico:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  // ── Fallback: derivar grupos de v_catalog_lenses ─────────────────────────────

  private static async _buscarGruposDerivados(
    isPremium: boolean,
    filtros: FiltrosLentes,
    pagina: number,
    limite: number,
    offset: number
  ): Promise<ApiResponse<RespostaPaginada<VCatalogLensGroup>>> {
    const { data, error, count } = await supabase
      .from('v_catalog_lenses')
      .select('group_id, group_name, lens_type, material, refractive_index, is_premium, created_at, updated_at, tenant_id', { count: 'exact' })
      .eq('is_premium', isPremium)
      .not('group_id', 'is', null)
      .range(offset, offset + limite - 1);

    if (error) throw error;

    // Deduplica por group_id
    const seen = new Set<string>();
    const grupos: VCatalogLensGroup[] = [];
    for (const row of (data || [])) {
      if (row.group_id && !seen.has(row.group_id)) {
        seen.add(row.group_id);
        grupos.push({
          id: row.group_id,
          tenant_id: row.tenant_id,
          name: row.group_name ?? row.group_id,
          lens_type: row.lens_type,
          material: row.material,
          refractive_index: row.refractive_index,
          is_premium: row.is_premium,
          is_active: true,
          created_at: row.created_at,
          updated_at: row.updated_at
        });
      }
    }

    return {
      success: true,
      data: {
        dados: grupos,
        paginacao: {
          total: count || 0,
          pagina,
          limite,
          total_paginas: Math.ceil((count || 0) / limite)
        }
      }
    };
  }

  // ============================================================================
  // MÓDULO: RANKING (Top grupos por critérios)
  // ============================================================================

  /**
   * Buscar Top Grupos por Preço (mais caros).
   * Proxy via lentes: ordena por price_suggested DESC.
   */
  static async buscarTopCaros(limite: number = 10): Promise<ApiResponse<VCatalogLensGroup[]>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lens_groups')
        .select('*')
        .eq('is_active', true)
        .order('name', { ascending: false })
        .limit(limite);

      if (error) throw error;

      console.log('✅ Top caros carregados:', data?.length || 0, 'grupos');
      return { success: true, data: (data as VCatalogLensGroup[]) || [] };
    } catch (error) {
      console.error('❌ Erro ao buscar top caros:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Buscar Top Grupos por Popularidade (ordenados por nome como proxy).
   */
  static async buscarTopPopulares(limite: number = 10): Promise<ApiResponse<VCatalogLensGroup[]>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lens_groups')
        .select('*')
        .eq('is_active', true)
        .order('name', { ascending: true })
        .limit(limite);

      if (error) throw error;

      console.log('✅ Top populares carregados:', data?.length || 0, 'grupos');
      return { success: true, data: (data as VCatalogLensGroup[]) || [] };
    } catch (error) {
      console.error('❌ Erro ao buscar top populares:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Buscar Top Premium (grupos premium).
   */
  static async buscarTopPremium(limite: number = 10): Promise<ApiResponse<VCatalogLensGroup[]>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lens_groups')
        .select('*')
        .eq('is_active', true)
        .eq('is_premium', true)
        .order('name', { ascending: true })
        .limit(limite);

      if (error) throw error;

      console.log('✅ Top premium carregados:', data?.length || 0, 'grupos');
      return { success: true, data: (data as VCatalogLensGroup[]) || [] };
    } catch (error) {
      console.error('❌ Erro ao buscar top premium:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Obter distribuição por tipo de lente (lens_type).
   */
  static async obterDistribuicaoPorTipo(): Promise<ApiResponse<Array<{ tipo_lente: string; count: number }>>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lens_groups')
        .select('lens_type');

      if (error) throw error;

      const distribuicao = (data || []).reduce((acc, item) => {
        const tipo = item.lens_type || 'Não especificado';
        acc[tipo] = (acc[tipo] || 0) + 1;
        return acc;
      }, {} as Record<string, number>);

      return {
        success: true,
        data: Object.entries(distribuicao).map(([tipo_lente, count]) => ({ tipo_lente, count }))
      };
    } catch (error) {
      console.error('❌ Erro ao obter distribuição por tipo:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Obter distribuição por material.
   */
  static async obterDistribuicaoPorMaterial(): Promise<ApiResponse<Array<{ material: string; count: number }>>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lens_groups')
        .select('material');

      if (error) throw error;

      const distribuicao = (data || []).reduce((acc, item) => {
        const mat = item.material || 'Não especificado';
        acc[mat] = (acc[mat] || 0) + 1;
        return acc;
      }, {} as Record<string, number>);

      return {
        success: true,
        data: Object.entries(distribuicao).map(([material, count]) => ({ material, count }))
      };
    } catch (error) {
      console.error('❌ Erro ao obter distribuição por material:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Buscar lentes de um grupo canônico específico.
   * Novo banco: v_catalog_lenses com group_id = grupoId
   */
  static async buscarLentesDoGrupo(grupoId: string): Promise<ApiResponse<VCatalogLens[]>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('*')
        .eq('group_id', grupoId)
        .eq('status', 'active')
        .order('price_suggested', { ascending: true });

      if (error) throw error;

      return { success: true, data: (data as VCatalogLens[]) || [], count: data?.length || 0 };
    } catch (error) {
      console.error('Erro ao buscar lentes do grupo:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  // ============================================================================
  // MÓDULO: CATÁLOGO STANDARD (canônicas genéricas)
  // NOVO BANCO: v_catalog_lens_groups (is_premium = false)
  // ============================================================================

  /**
   * Listar lentes canônicas genéricas (standard).
   * Novo banco: v_catalog_lens_groups (is_premium = false)
   */
  static async listarCanonicasGenericas(
    filtros: Partial<FiltrosLentes> = {},
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<VCatalogLensGroup>>> {
    return this.buscarGruposCanonicosStandard(filtros as FiltrosLentes, {
      ...paginacao,
      ordenar: paginacao.ordenar === 'nome_canonico' ? 'name' : (paginacao.ordenar ?? 'name')
    });
  }

  /**
   * Obter uma canônica genérica específica.
   * Novo banco: v_catalog_lens_groups (is_premium = false)
   */
  static async obterCanonicaGenerica(id: string): Promise<ApiResponse<VCatalogLensGroup>> {
    return this.obterGrupoCanonico(id, false);
  }

  // ============================================================================
  // MÓDULO: PREMIUM (canônicas premium)
  // NOVO BANCO: v_catalog_lens_groups (is_premium = true)
  // ============================================================================

  /**
   * Listar lentes canônicas premium.
   * Novo banco: v_catalog_lens_groups (is_premium = true)
   */
  static async listarCanonicasPremium(
    filtros: Partial<FiltrosLentes> = {},
    paginacao: PaginacaoParams = {}
  ): Promise<ApiResponse<RespostaPaginada<VCatalogLensGroup>>> {
    return this.buscarGruposCanonicosPremium(filtros as FiltrosLentes, {
      ...paginacao,
      ordenar: paginacao.ordenar === 'marca_nome,nome_canonico' ? 'name' : (paginacao.ordenar ?? 'name')
    });
  }

  /**
   * Obter uma canônica premium específica.
   */
  static async obterCanonicaPremium(id: string): Promise<ApiResponse<VCatalogLensGroup>> {
    return this.obterGrupoCanonico(id, true);
  }

  // ============================================================================
  // MÓDULO: COMPARAR
  // NOVO BANCO: v_catalog_lenses filtrada por group_id
  // ============================================================================

  /**
   * Listar todas as lentes de uma canônica (para comparação de labs premium).
   * Novo banco: v_catalog_lenses (group_id = canonicaId, is_premium = true)
   */
  static async listarDetalhesPremium(canonicaId: string): Promise<ApiResponse<VCatalogLens[]>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('*')
        .eq('group_id', canonicaId)
        .eq('is_premium', true)
        .order('brand_name')
        .order('price_suggested');

      if (error) throw error;

      return { success: true, data: (data as VCatalogLens[]) || [], count: data?.length || 0 };
    } catch (error) {
      console.error('Erro ao listar detalhes premium:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Comparar lentes de múltiplos laboratórios para uma mesma canônica premium.
   * Agrupa por brand_name.
   */
  static async compararLaboratorios(canonicaId: string): Promise<ApiResponse<Record<string, VCatalogLens[]>>> {
    try {
      const resultado = await this.listarDetalhesPremium(canonicaId);

      if (!resultado.success || !resultado.data) {
        return resultado as unknown as ApiResponse<Record<string, VCatalogLens[]>>;
      }

      const agrupadoPorMarca = resultado.data.reduce((acc, lente) => {
        const marca = lente.brand_name ?? lente.supplier_name ?? 'Sem marca';
        if (!acc[marca]) acc[marca] = [];
        acc[marca].push(lente);
        return acc;
      }, {} as Record<string, VCatalogLens[]>);

      return { success: true, data: agrupadoPorMarca, count: Object.keys(agrupadoPorMarca).length };
    } catch (error) {
      console.error('Erro ao comparar laboratórios:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Listar todas as lentes de uma canônica genérica (para comparação).
   * Novo banco: v_catalog_lenses (group_id = canonicaId)
   */
  static async listarDetalhesGenericas(canonicaId: string): Promise<ApiResponse<VCatalogLens[]>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('*')
        .eq('group_id', canonicaId)
        .order('brand_name')
        .order('price_suggested');

      if (error) throw error;

      return { success: true, data: (data as VCatalogLens[]) || [], count: data?.length || 0 };
    } catch (error) {
      console.error('Erro ao listar detalhes genéricas:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Comparar lentes genéricas de múltiplos laboratórios.
   * Agrupa por brand_name.
   */
  static async compararLaboratoriosGenericas(canonicaId: string): Promise<ApiResponse<Record<string, VCatalogLens[]>>> {
    try {
      const resultado = await this.listarDetalhesGenericas(canonicaId);

      if (!resultado.success || !resultado.data) {
        return resultado as unknown as ApiResponse<Record<string, VCatalogLens[]>>;
      }

      const agrupadoPorMarca = resultado.data.reduce((acc, lente) => {
        const marca = lente.brand_name ?? lente.supplier_name ?? 'Sem marca';
        if (!acc[marca]) acc[marca] = [];
        acc[marca].push(lente);
        return acc;
      }, {} as Record<string, VCatalogLens[]>);

      return { success: true, data: agrupadoPorMarca, count: Object.keys(agrupadoPorMarca).length };
    } catch (error) {
      console.error('Erro ao comparar laboratórios genéricos:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  // ============================================================================
  // ESTATÍSTICAS
  // NOVO BANCO: public.v_catalog_lens_stats
  // ============================================================================

  /**
   * Obter estatísticas gerais do catálogo.
   * Novo banco: v_catalog_lens_stats
   */
  static async obterEstatisticas(): Promise<ApiResponse<VCatalogLensStats>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lens_stats')
        .select('*')
        .single();

      if (error) throw error;

      return { success: true, data: (data as VCatalogLensStats) || undefined };
    } catch (error) {
      console.error('Erro ao obter estatísticas:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Obter estatísticas de tratamentos e tecnologias.
   * Novo banco: v_catalog_lenses (campos booleanos diretos)
   */
  static async obterEstatisticasTratamentos(): Promise<ApiResponse<{
    total_com_ar: number;
    total_com_blue: number;
    total_fotossensiveis: number;
    total_polarizados: number;
    total_free_form: number;
    total_digitais: number;
  }>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('anti_reflective, blue_light, photochromic, polarized, digital, free_form');

      if (error) throw error;

      const rows = data || [];
      const stats = {
        total_com_ar:        rows.filter(r => r.anti_reflective === true).length,
        total_com_blue:      rows.filter(r => r.blue_light === true).length,
        total_fotossensiveis:rows.filter(r => r.photochromic && r.photochromic !== 'nenhum').length,
        total_polarizados:   rows.filter(r => r.polarized === true).length,
        total_free_form:     rows.filter(r => r.free_form === true).length,
        total_digitais:      rows.filter(r => r.digital === true).length
      };

      return { success: true, data: stats };
    } catch (error) {
      console.error('Erro ao obter estatísticas de tratamentos:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Obter estatísticas por tipo de lente (lens_type).
   * Novo banco: v_catalog_lenses
   */
  static async obterEstatisticasTipos(): Promise<ApiResponse<{
    total_visao_simples: number;
    total_multifocal: number;
    total_bifocal: number;
  }>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('lens_type');

      if (error) throw error;

      const rows = data || [];
      const stats = {
        total_visao_simples: rows.filter(r => r.lens_type === 'single_vision').length,
        total_multifocal:    rows.filter(r => r.lens_type === 'multifocal').length,
        total_bifocal:       rows.filter(r => r.lens_type === 'bifocal').length
      };

      return { success: true, data: stats };
    } catch (error) {
      console.error('Erro ao obter estatísticas de tipos:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Obter estatísticas por material.
   * Novo banco: v_catalog_lenses
   */
  static async obterEstatisticasMateriais(): Promise<ApiResponse<{
    total_cr39: number;
    total_policarbonato: number;
    total_trivex: number;
    total_high_index: number;
  }>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('material');

      if (error) throw error;

      const rows = data || [];
      const stats = {
        total_cr39:          rows.filter(r => r.material === 'cr39').length,
        total_policarbonato: rows.filter(r => r.material === 'polycarbonate').length,
        total_trivex:        rows.filter(r => r.material === 'trivex').length,
        total_high_index:    rows.filter(r => r.material === 'high_index').length
      };

      return { success: true, data: stats };
    } catch (error) {
      console.error('Erro ao obter estatísticas de materiais:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Obter faixas de preço.
   * Novo banco: v_catalog_lenses (price_suggested)
   */
  static async obterFaixasPreco(): Promise<ApiResponse<{
    preco_minimo: number;
    preco_medio: number;
    preco_maximo: number;
  }>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('price_suggested');

      if (error) throw error;

      const precos = (data || [])
        .map(item => item.price_suggested)
        .filter((p): p is number => p != null && p > 0);

      if (precos.length === 0) {
        return { success: true, data: { preco_minimo: 0, preco_medio: 0, preco_maximo: 0 } };
      }

      return {
        success: true,
        data: {
          preco_minimo: Math.min(...precos),
          preco_maximo: Math.max(...precos),
          preco_medio: precos.reduce((a, b) => a + b, 0) / precos.length
        }
      };
    } catch (error) {
      console.error('Erro ao obter faixas de preço:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  // ============================================================================
  // UTILITÁRIOS
  // ============================================================================

  /**
   * Obter lista de marcas únicas (brand_name DISTINCT).
   * Novo banco: v_catalog_lenses
   */
  static async listarMarcas(): Promise<ApiResponse<string[]>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('brand_name')
        .order('brand_name');

      if (error) throw error;

      const marcasUnicas = [
        ...new Set((data || []).map(item => item.brand_name).filter(Boolean))
      ] as string[];

      return { success: true, data: marcasUnicas, count: marcasUnicas.length };
    } catch (error) {
      console.error('Erro ao listar marcas:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Obter filtros disponíveis (valores únicos de cada campo).
   * Novo banco: v_catalog_lenses
   */
  static async obterFiltrosDisponiveis(): Promise<ApiResponse<{
    tipos: string[];
    materiais: string[];
    indices: string[];
    categorias: string[];
  }>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('lens_type, material, refractive_index, category');

      if (error) throw error;

      const filtros = {
        tipos:      [...new Set((data || []).map(r => r.lens_type).filter(Boolean))].sort() as string[],
        materiais:  [...new Set((data || []).map(r => r.material).filter(Boolean))].sort() as string[],
        indices:    [...new Set((data || []).map(r => r.refractive_index).filter(Boolean))].sort() as unknown as string[],
        categorias: [...new Set((data || []).map(r => r.category).filter(Boolean))].sort() as string[]
      };

      return { success: true, data: filtros };
    } catch (error) {
      console.error('Erro ao obter filtros disponíveis:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }
}
