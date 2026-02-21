/**
 * Database Client - Conexão e Configuração
 * Cliente principal para operações de banco — novo banco (migration 111+)
 *
 * Views disponíveis para o role `authenticated`:
 *   public.v_catalog_lenses      → catálogo de lentes
 *   public.v_catalog_lens_stats  → estatísticas
 *
 * RPCs disponíveis:
 *   public.rpc_lens_search(...)          → busca com filtros
 *   public.rpc_lens_get_alternatives(…)  → alternativas por lente
 *   public.buscar_lentes(...)            → wrapper PT-BR
 *   public.obter_alternativas_lente(...) → wrapper PT-BR
 */

import { supabase } from '$lib/supabase';

// ─── Helper types ─────────────────────────────────────────────────────────────

type DatabaseResponse<T> = {
  data: T[];
  total: number;
  page?: number;
  limit?: number;
  has_more?: boolean;
  verified?: unknown;
};

type SingleDatabaseResponse<T> = {
  data: T | null;
  found: boolean;
};

type ApiResponse<T> = {
  success: boolean;
  data?: T;
  error?: string;
  total?: number;
  metadata?: unknown;
};

export class DatabaseClient {

  // ============================================================================
  // CATÁLOGO DE LENTES — public.v_catalog_lenses  (migration 111)
  // ============================================================================

  /**
   * Busca simples de lentes usando `public.rpc_lens_search`.
   * O antigo `buscar_lentes(p_query, p_filtros, p_limit)` não existe mais;
   * `p_query` é mapeado para `p_brand_name` e os filtros para colunas do novo banco.
   */
  static async buscarLentesPorQuery(
    query: string,
    filtros: Record<string, unknown> = {},
    limit = 20
  ): Promise<ApiResponse<unknown[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_lens_search', {
        p_lens_type: (filtros.tipo_lente as string) ?? null,
        p_material: (filtros.material as string) ?? null,
        p_refractive_index: (filtros.indice_refracao as number) ?? null,
        p_price_min: (filtros.preco_min as number) ?? null,
        p_price_max: (filtros.preco_max as number) ?? null,
        p_has_ar: (filtros.tem_ar as boolean) ?? null,
        p_has_blue: (filtros.tem_blue as boolean) ?? null,
        p_supplier_lab_id: (filtros.fornecedor_id as string) ?? null,
        // p_query → brand_name LIKE (melhor heurística disponível)
        p_brand_name: query && query.trim() ? query.trim() : null,
        p_limit: limit,
        p_offset: 0
      });

      if (error) throw error;
      return { success: true, data: data || [], total: (data || []).length };
    } catch (error) {
      console.error('Erro ao buscar lentes por query:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * Listar lentes do catálogo via `public.v_catalog_lenses`.
   * Filtros mapeados de PT-BR para colunas do novo banco.
   */
  static async listarLentesCatalogo(
    filtros: Record<string, unknown> = {},
    page = 1,
    limit = 20
  ): Promise<DatabaseResponse<unknown>> {
    try {
      let query = supabase
        .from('v_catalog_lenses')
        .select('*', { count: 'exact' })
        .eq('status', 'active');

      // Filtros legados mapeados
      if (filtros.marca && Array.isArray(filtros.marca) && filtros.marca.length) {
        query = query.in('brand_name', filtros.marca as string[]);
      }
      if (filtros.categoria && Array.isArray(filtros.categoria) && filtros.categoria.length) {
        query = query.in('category', filtros.categoria as string[]);
      }
      if (filtros.material && Array.isArray(filtros.material) && filtros.material.length) {
        query = query.in('material', filtros.material as string[]);
      }
      if (filtros.indice_min) {
        query = query.gte('refractive_index', filtros.indice_min as number);
      }
      if (filtros.indice_max) {
        query = query.lte('refractive_index', filtros.indice_max as number);
      }
      if (filtros.status && Array.isArray(filtros.status) && filtros.status.length) {
        query = query.in('status', filtros.status as string[]);
      }

      // Paginação
      const start = (page - 1) * limit;
      query = query
        .range(start, start + limit - 1)
        .order('lens_name', { ascending: true });

      const { data, error, count } = await query;
      if (error) throw error;

      return {
        data: data || [],
        total: count || 0,
        page,
        limit,
        has_more: (count || 0) > start + limit
      };
    } catch (error) {
      console.error('Erro ao listar lentes do catálogo:', error);
      return { data: [], total: 0, page, limit, has_more: false };
    }
  }

  /**
   * Buscar lente por ID via `public.v_catalog_lenses`.
   */
  static async buscarLentePorId(id: string): Promise<SingleDatabaseResponse<unknown>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;
      return { data, found: !!data };
    } catch (error) {
      console.error('Erro ao buscar lente por ID:', error);
      return { data: null, found: false };
    }
  }

  // ============================================================================
  // FORNECEDORES — derivado de v_catalog_lenses  (migration 111)
  // ============================================================================

  /**
   * Listar fornecedores/labs disponíveis (DISTINCT de v_catalog_lenses).
   * A tabela `catalog_lenses.suppliers_labs` não é acessível ao role `authenticated`;
   * a view pública expõe supplier_lab_id e supplier_name.
   */
  static async listarFornecedores(
    filtros: Record<string, unknown> = {}
  ): Promise<DatabaseResponse<unknown>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('supplier_lab_id, supplier_name')
        .eq('status', 'active')
        .not('supplier_lab_id', 'is', null);

      if (error) throw error;

      // Deduplicate
      const seen = new Map<string, { id: string; nome: string; total: number }>();
      (data || []).forEach((row: { supplier_lab_id: string | null; supplier_name: string | null }) => {
        if (!row.supplier_lab_id) return;
        const nm = row.supplier_name || row.supplier_lab_id;
        // Aplicar filtro por nome se fornecido
        if (filtros.nome && typeof filtros.nome === 'string') {
          if (!nm.toLowerCase().includes(filtros.nome.toLowerCase())) return;
        }
        const e = seen.get(row.supplier_lab_id);
        if (e) e.total++;
        else seen.set(row.supplier_lab_id, { id: row.supplier_lab_id, nome: nm, total: 1 });
      });

      const suppliers = Array.from(seen.values()).sort((a, b) => a.nome.localeCompare(b.nome));
      return { data: suppliers, total: suppliers.length };
    } catch (error) {
      console.error('Erro ao listar fornecedores:', error);
      return { data: [], total: 0 };
    }
  }

  /**
   * Buscar fornecedor por ID via v_catalog_lenses (supplier_lab_id).
   */
  static async buscarFornecedorPorId(id: string): Promise<SingleDatabaseResponse<unknown>> {
    try {
      const { data, error } = await supabase
        .from('v_catalog_lenses')
        .select('supplier_lab_id, supplier_name')
        .eq('supplier_lab_id', id)
        .limit(1)
        .single();

      if (error) throw error;

      const supplier = data
        ? { id: (data as { supplier_lab_id: string }).supplier_lab_id, nome: (data as { supplier_name: string | null }).supplier_name || id }
        : null;

      return { data: supplier, found: !!supplier };
    } catch (error) {
      console.error('Erro ao buscar fornecedor por ID:', error);
      return { data: null, found: false };
    }
  }

  // ============================================================================
  // RANKING E ALTERNATIVAS — rpc_lens_get_alternatives  (migration 111)
  // ============================================================================

  /**
   * Gerar "ranking" de opções para uma lente via alternativas do RPC.
   * A view `vw_ranking_atual` não existe no novo banco.
   */
  static async gerarRankingOpcoes(
    lenteId: string,
    criterio: string,
    _filtros: Record<string, unknown> = {}
  ): Promise<ApiResponse<unknown[]>> {
    try {
      const { data, error } = await supabase.rpc('rpc_lens_get_alternatives', {
        p_lens_id: lenteId,
        p_limit: 10
      });

      if (error) throw error;

      return {
        success: true,
        data: data || [],
        metadata: {
          total_opcoes: (data || []).length,
          criterio_usado: criterio
        }
      };
    } catch (error) {
      console.error('Erro ao gerar ranking de opções:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido',
        data: []
      };
    }
  }

  /**
   * @deprecated Use gerarRankingOpcoes() — vw_ranking_opcoes não existe no novo banco.
   */
  static async listarRankingOpcoes(
    lenteId: string,
    _criterio?: string,
    limit = 10
  ): Promise<DatabaseResponse<unknown>> {
    try {
      const { data, error } = await supabase.rpc('rpc_lens_get_alternatives', {
        p_lens_id: lenteId,
        p_limit: limit
      });

      if (error) throw error;

      return {
        data: data || [],
        total: (data || []).length,
        has_more: false
      };
    } catch (error) {
      console.error('Erro ao listar ranking de opções:', error);
      return { data: [], total: 0, has_more: false };
    }
  }

  // ============================================================================
  // DECISÕES DE COMPRA — tabela decisoes_lentes (compat)
  // ============================================================================

  /**
   * Confirmar decisão de compra via RPC legado (se disponível no banco atual).
   */
  static async confirmarDecisaoCompra(
    tenantId: string,
    clienteId: string,
    receita: unknown,
    criterio = 'EQUILIBRADO',
    filtros: unknown = {}
  ): Promise<ApiResponse<unknown>> {
    try {
      const { data, error } = await supabase.rpc('criar_decisao_lente', {
        p_tenant_id: tenantId,
        p_cliente_id: clienteId,
        p_receita: receita,
        p_criterio: criterio,
        p_filtros: filtros
      });

      if (error) throw error;

      return {
        success: true,
        data,
        metadata: { economia_estimada: (data as { economia_estimada?: number })?.economia_estimada || 0 }
      };
    } catch (error) {
      console.error('Erro ao criar decisão:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
    }
  }

  /**
   * Listar decisões de compra.
   */
  static async listarDecisoesCompra(
    filtros: Record<string, unknown> = {},
    page = 1,
    limit = 20
  ): Promise<DatabaseResponse<unknown>> {
    try {
      let query = supabase
        .from('decisoes_lentes')
        .select('*', { count: 'exact' });

      if (filtros.usuario_id) query = query.eq('usuario_id', filtros.usuario_id as string);
      if (filtros.laboratorio_id) query = query.eq('laboratorio_id', filtros.laboratorio_id as string);
      if (filtros.criterio && Array.isArray(filtros.criterio) && filtros.criterio.length)
        query = query.in('criterio_usado', filtros.criterio as string[]);
      if (filtros.status && Array.isArray(filtros.status) && filtros.status.length)
        query = query.in('status', filtros.status as string[]);
      if (filtros.data_inicio) query = query.gte('criado_em', filtros.data_inicio as string);
      if (filtros.data_fim) query = query.lte('criado_em', filtros.data_fim as string);
      if (filtros.valor_min) query = query.gte('preco_final', filtros.valor_min as number);
      if (filtros.valor_max) query = query.lte('preco_final', filtros.valor_max as number);

      const start = (page - 1) * limit;
      query = query.range(start, start + limit - 1).order('criado_em', { ascending: false });

      const { data, error, count } = await query;
      if (error) throw error;

      return {
        data: data || [],
        total: count || 0,
        page,
        limit,
        has_more: (count || 0) > start + limit
      };
    } catch (error) {
      console.error('Erro ao listar decisões:', error);
      return { data: [], total: 0, page, limit, has_more: false };
    }
  }

  // ============================================================================
  // ANALYTICS E MÉTRICAS
  // ============================================================================

  static async buscarEconomiaPorFornecedor(
    _periodo?: string
  ): Promise<DatabaseResponse<unknown>> {
    try {
      // Sem view equivalente no novo banco — retorna vazio com log informativo
      console.info('[DatabaseClient] buscarEconomiaPorFornecedor: sem view equivalente no novo banco');
      return { data: [], total: 0 };
    } catch (error) {
      console.error('Erro ao buscar economia por fornecedor:', error);
      return { data: [], total: 0 };
    }
  }

  static async buscarDashboardExecutivo(): Promise<SingleDatabaseResponse<unknown>> {
    try {
      // Buscar estatísticas do catálogo como proxy do dashboard
      const { data, error } = await supabase
        .from('v_catalog_lens_stats')
        .select('*')
        .single();

      const dashboardData = {
        total_decisoes: 0,
        economia_total: 0,
        fornecedores_ativos: 0,
        tempo_medio_decisao: 0,
        updated_at: new Date().toISOString(),
        // Dados reais do novo banco
        total_lentes: (data as { total_lenses?: number })?.total_lenses || 0,
        total_active: (data as { total_active?: number })?.total_active || 0,
        total_premium: (data as { total_premium?: number })?.total_premium || 0,
        price_avg: (data as { price_avg?: number })?.price_avg || 0
      };

      if (error) console.warn('[DatabaseClient] v_catalog_lens_stats error:', error.message);

      return { data: dashboardData, found: true };
    } catch (error) {
      console.error('Erro ao buscar dashboard executivo:', error);
      return { data: null, found: false };
    }
  }

  // ============================================================================
  // SISTEMA DE VOUCHERS / LOJAS / CLIENTES / USUÁRIOS  (mocks / compat)
  // ============================================================================

  static async listarUsuarios(_filtros: unknown = {}): Promise<ApiResponse<unknown[]>> {
    try {
      const { data, error } = await supabase.auth.admin.listUsers();
      if (error) throw error;
      return { success: true, data: data.users || [], total: data.users?.length || 0 };
    } catch (error) {
      console.error('Erro ao listar usuários:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido', data: [] };
    }
  }

  static async listarLojas(_filtros: unknown = {}): Promise<ApiResponse<unknown[]>> {
    // Lojas disponíveis via IAM após migration 078+
    try {
      const { data, error } = await supabase
        .from('v_stores')
        .select('*');
      if (error) throw error;
      return { success: true, data: data || [], total: (data || []).length };
    } catch {
      // Fallback mock enquanto v_stores não existir neste contexto
      return {
        success: true,
        data: [
          { id: '1', nome: 'Loja Centro', endereco: 'Rua Principal, 123 - Centro', ativa: true },
          { id: '2', nome: 'Loja Shopping', endereco: 'Shopping Center, Loja 45', ativa: true }
        ],
        total: 2
      };
    }
  }

  static async listarClientes(_filtros: unknown = {}): Promise<ApiResponse<unknown[]>> {
    try {
      const { data, error } = await supabase
        .from('v_patients')
        .select('id, full_name, email, phone, status')
        .eq('status', 'active')
        .limit(100);
      if (error) throw error;
      return { success: true, data: data || [], total: (data || []).length };
    } catch {
      return {
        success: true,
        data: [
          { id: '1', nome: 'João Silva', email: 'joao@email.com', telefone: '(11) 99999-9999', ativo: true },
          { id: '2', nome: 'Maria Santos', email: 'maria@email.com', telefone: '(11) 88888-8888', ativo: true }
        ],
        total: 2
      };
    }
  }

  static async listarVouchers(_filtros: unknown = {}): Promise<ApiResponse<unknown[]>> {
    // Vouchers — mock até integração real com módulo de vouchers
    return {
      success: true,
      data: [
        { id: '1', codigo: 'DESC10', descricao: 'Desconto de 10%', tipo: 'percentual', valor: 10, ativo: true, valido_ate: '2026-12-31' },
        { id: '2', codigo: 'FRETE50', descricao: 'Desconto R$ 50 no frete', tipo: 'valor_fixo', valor: 50, ativo: true, valido_ate: '2026-12-31' }
      ],
      total: 2
    };
  }
}
