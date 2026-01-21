/**
 * API Client para Views Consolidadas do Banco
 * Baseado na reestruturação do banco de dados
 * 
 * Este client consome as views consolidadas:
 * - v_lentes (substitui: v_lentes_busca, v_lentes_cotacao_compra, vw_lentes_catalogo)
 * - v_grupos_canonicos (substitui: 6 views de grupos)
 * - vw_stats_catalogo (mantida)
 */

import { supabase } from '$lib/supabase';
import type {
  VLente,
  VGrupoCanonicos,
  StatsCatalogo,
  TipoLente,
  CategoriaLente,
  MaterialLente,
  IndiceRefracao
} from '$lib/types/database-views';

// Tipos de parâmetros de busca
export interface BuscarLentesParams {
  tipo_lente?: TipoLente;
  material?: MaterialLente;
  indice_refracao?: IndiceRefracao;
  categoria?: CategoriaLente;
  marca_id?: string;
  fornecedor_id?: string;
  grupo_canonico_id?: string;
  
  // Filtros de tratamentos
  com_ar?: boolean;
  com_blue?: boolean;
  com_polarizado?: boolean;
  com_antirrisco?: boolean;
  com_uv?: boolean;
  com_fotossensivel?: boolean;
  
  // Filtros de faixas ópticas
  grau_esferico_min?: number;
  grau_esferico_max?: number;
  grau_cilindrico_min?: number;
  grau_cilindrico_max?: number;
  
  // Filtros de preço
  preco_min?: number;
  preco_max?: number;
  
  // Ordenação e paginação
  ordenar_por?: 'nome' | 'preco' | 'marca' | 'indice' | 'prazo';
  ordem?: 'asc' | 'desc';
  limite?: number;
  offset?: number;
}

export interface BuscarLentesParams {
  tipo_lente?: TipoLente;
  material?: MaterialLente;
  indice_refracao?: IndiceRefracao;
  categoria?: CategoriaLente;
  marca_id?: string;
  fornecedor_id?: string;
  grupo_canonico_id?: string;
  
  // Filtros de tratamentos
  com_ar?: boolean;
  com_blue?: boolean;
  com_polarizado?: boolean;
  com_antirrisco?: boolean;
  com_uv?: boolean;
  com_fotossensivel?: boolean;
  
  // Filtros de faixas ópticas
  grau_esferico_min?: number;
  grau_esferico_max?: number;
  grau_cilindrico_min?: number;
  grau_cilindrico_max?: number;
  
  // Filtros de preço
  preco_min?: number;
  preco_max?: number;
  
  // Ordenação e paginação
  ordenar_por?: 'nome' | 'preco' | 'marca' | 'indice' | 'prazo';
  ordem?: 'asc' | 'desc';
  limite?: number;
  offset?: number;
}

export interface BuscarGruposParams {
  tipo_lente?: TipoLente;
  material?: MaterialLente;
  indice_refracao?: IndiceRefracao;
  categoria_predominante?: CategoriaLente;
  is_premium?: boolean;
  
  // Filtros de preço
  preco_min?: number;
  preco_max?: number;
  
  // Ordenação e paginação
  ordenar_por?: 'nome' | 'preco' | 'total_lentes' | 'total_fornecedores';
  ordem?: 'asc' | 'desc';
  limite?: number;
  offset?: number;
}

// Tipos de resposta
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

/**
 * Cliente para consumir as views consolidadas do banco
 */
export class ViewsApiClient {
  
  // ==========================================================================
  // BUSCAR LENTES (View Consolidada: v_lentes)
  // ==========================================================================
  
  /**
   * Buscar lentes usando a view consolidada v_lentes
   * Esta é a função principal de busca do sistema
   */
  static async buscarLentes(params: BuscarLentesParams = {}): Promise<ApiResponse<VLente>> {
    try {
      let query = supabase
        .from('v_lentes')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (params.tipo_lente) {
        query = query.eq('tipo_lente', params.tipo_lente);
      }
      
      if (params.material) {
        query = query.eq('material', params.material);
      }
      
      if (params.indice_refracao) {
        query = query.eq('indice_refracao', params.indice_refracao);
      }
      
      if (params.categoria) {
        query = query.eq('categoria', params.categoria);
      }
      
      if (params.marca_id) {
        query = query.eq('marca_id', params.marca_id);
      }
      
      if (params.fornecedor_id) {
        query = query.eq('fornecedor_id', params.fornecedor_id);
      }
      
      if (params.grupo_canonico_id) {
        query = query.eq('grupo_canonico_id', params.grupo_canonico_id);
      }
      
      // Filtros de tratamentos
      if (params.com_ar !== undefined) {
        query = query.eq('tem_ar', params.com_ar);
      }
      
      if (params.com_blue !== undefined) {
        query = query.eq('tem_blue', params.com_blue);
      }
      
      if (params.com_polarizado !== undefined) {
        query = query.eq('tem_polarizado', params.com_polarizado);
      }
      
      if (params.com_antirrisco !== undefined) {
        query = query.eq('tem_antirrisco', params.com_antirrisco);
      }
      
      if (params.com_uv !== undefined) {
        query = query.eq('tem_uv', params.com_uv);
      }
      
      if (params.com_fotossensivel !== undefined) {
        query = params.com_fotossensivel
          ? query.neq('tratamento_foto', 'nenhum')
          : query.eq('tratamento_foto', 'nenhum');
      }
      
      // Filtros de faixas ópticas
      if (params.grau_esferico_min !== undefined) {
        query = query.gte('grau_esferico_max', params.grau_esferico_min);
      }
      
      if (params.grau_esferico_max !== undefined) {
        query = query.lte('grau_esferico_min', params.grau_esferico_max);
      }
      
      if (params.grau_cilindrico_min !== undefined) {
        query = query.gte('grau_cilindrico_max', params.grau_cilindrico_min);
      }
      
      if (params.grau_cilindrico_max !== undefined) {
        query = query.lte('grau_cilindrico_min', params.grau_cilindrico_max);
      }
      
      // Filtros de preço
      if (params.preco_min !== undefined) {
        query = query.gte('preco_venda_sugerido', params.preco_min);
      }
      
      if (params.preco_max !== undefined) {
        query = query.lte('preco_venda_sugerido', params.preco_max);
      }
      
      // Ordenação
      const ordenarPor = params.ordenar_por || 'nome';
      const ordem = params.ordem || 'asc';
      
      switch (ordenarPor) {
        case 'preco':
          query = query.order('preco_venda_sugerido', { ascending: ordem === 'asc' });
          break;
        case 'marca':
          query = query.order('marca_nome', { ascending: ordem === 'asc' });
          break;
        case 'indice':
          query = query.order('indice_refracao', { ascending: ordem === 'desc' });
          break;
        case 'prazo':
          query = query.order('prazo_dias', { ascending: ordem === 'asc' });
          break;
        default:
          query = query.order('nome_lente', { ascending: ordem === 'asc' });
      }
      
      // Paginação
      const limite = params.limite || 50;
      const offset = params.offset || 0;
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: (data as VLente[]) || [],
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
   * Obter detalhes de uma lente específica por ID
   */
  static async obterLentePorId(lenteId: string): Promise<SingleApiResponse<VLente>> {
    try {
      const { data, error } = await supabase
        .from('v_lentes')
        .select('*')
        .eq('id', lenteId)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data as VLente
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
  // GRUPOS CANÔNICOS (View Consolidada: v_grupos_canonicos)
  // ==========================================================================
  
  /**
   * Buscar grupos canônicos usando a view consolidada
   */
  static async buscarGruposCanonicos(params: BuscarGruposParams = {}): Promise<ApiResponse<VGrupoCanonicos>> {
    try {
      let query = supabase
        .from('v_grupos_canonicos')
        .select('*', { count: 'exact' });

      // Aplicar filtros
      if (params.tipo_lente) {
        query = query.eq('tipo_lente', params.tipo_lente);
      }
      
      if (params.material) {
        query = query.eq('material', params.material);
      }
      
      if (params.indice_refracao) {
        query = query.eq('indice_refracao', params.indice_refracao);
      }
      
      if (params.categoria_predominante) {
        query = query.eq('categoria_predominante', params.categoria_predominante);
      }
      
      if (params.is_premium !== undefined) {
        query = query.eq('is_premium', params.is_premium);
      }
      
      // Filtros de preço
      if (params.preco_min !== undefined) {
        query = query.gte('preco_medio', params.preco_min);
      }
      
      if (params.preco_max !== undefined) {
        query = query.lte('preco_medio', params.preco_max);
      }
      
      // Ordenação
      const ordenarPor = params.ordenar_por || 'nome';
      const ordem = params.ordem || 'asc';
      
      switch (ordenarPor) {
        case 'preco':
          query = query.order('preco_medio', { ascending: ordem === 'asc' });
          break;
        case 'total_lentes':
          query = query.order('total_lentes', { ascending: ordem === 'desc' });
          break;
        case 'total_fornecedores':
          query = query.order('total_fornecedores', { ascending: ordem === 'desc' });
          break;
        default:
          query = query.order('nome_grupo', { ascending: ordem === 'asc' });
      }
      
      // Paginação
      const limite = params.limite || 50;
      const offset = params.offset || 0;
      query = query.range(offset, offset + limite - 1);

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        success: true,
        data: (data as VGrupoCanonicos[]) || [],
        total: count || 0,
        metadata: {
          limite,
          offset,
          paginas: count ? Math.ceil(count / limite) : 0
        }
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
   * Obter um grupo canônico específico por ID
   */
  static async obterGrupoPorId(grupoId: string): Promise<SingleApiResponse<VGrupoCanonicos>> {
    try {
      const { data, error } = await supabase
        .from('v_grupos_canonicos')
        .select('*')
        .eq('id', grupoId)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data as VGrupoCanonicos
      };
    } catch (error) {
      console.error('Erro ao obter grupo canônico:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      };
    }
  }

  /**
   * Obter lentes de um grupo canônico específico
   */
  static async obterLentesDoGrupo(grupoId: string): Promise<ApiResponse<VLente>> {
    return this.buscarLentes({ grupo_canonico_id: grupoId });
  }

  // ==========================================================================
  // MARCAS E FORNECEDORES (Queries diretas das tabelas)
  // ==========================================================================
  
  /**
   * Listar todas as marcas disponíveis
   */
  static async listarMarcas(): Promise<ApiResponse<any>> {
    try {
      const { data, error } = await supabase
        .from('lens_catalog.marcas')
        .select('id, nome, slug, is_premium, ativo')
        .eq('ativo', true)
        .order('nome');

      if (error) throw error;

      return {
        success: true,
        data: data || []
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
   * Listar marcas premium
   */
  static async listarMarcasPremium(): Promise<ApiResponse<any>> {
    try {
      const { data, error } = await supabase
        .from('lens_catalog.marcas')
        .select('id, nome, slug, is_premium, ativo')
        .eq('ativo', true)
        .eq('is_premium', true)
        .order('nome');

      if (error) throw error;

      return {
        success: true,
        data: data || []
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
   * Listar todos os fornecedores disponíveis
   */
  static async listarFornecedores(): Promise<ApiResponse<any>> {
    try {
      const { data, error } = await supabase
        .from('core.fornecedores')
        .select('id, nome, razao_social, cnpj, prazo_visao_simples, prazo_multifocal, ativo')
        .eq('ativo', true)
        .order('nome');

      if (error) throw error;

      return {
        success: true,
        data: data || []
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

  /**
   * Obter filtros disponíveis usando SELECT DISTINCT na v_lentes
   * Baseado em 09_LIMPAR_VIEWS_REDUNDANTES.sql - alternativas às views de filtros
   * Retorna tipos, materiais, índices, marcas e fornecedores com contagens
   */
  static async obterFiltrosDisponiveis(): Promise<SingleApiResponse<any>> {
    try {
      // Query SQL real conforme documentação:
      // SELECT DISTINCT tipo_lente, COUNT(*) AS total FROM v_lentes GROUP BY tipo_lente
      
      const { data: lentes, error } = await supabase
        .from('v_lentes')
        .select('tipo_lente, material, indice_refracao, categoria, marca_nome, marca_id, fornecedor_nome, fornecedor_id');

      if (error) throw error;

      // Agregar dados com contagens (simulando GROUP BY no client)
      const tiposMap = new Map<string, number>();
      const materiaisMap = new Map<string, number>();
      const indicesMap = new Map<string, number>();
      const categoriasMap = new Map<string, number>();
      const marcasMap = new Map<string, {id: string, nome: string, count: number}>();
      const fornecedoresMap = new Map<string, {id: string, nome: string, count: number}>();

      lentes?.forEach((lente: any) => {
        // Tipos
        tiposMap.set(lente.tipo_lente, (tiposMap.get(lente.tipo_lente) || 0) + 1);
        
        // Materiais
        materiaisMap.set(lente.material, (materiaisMap.get(lente.material) || 0) + 1);
        
        // Índices
        indicesMap.set(lente.indice_refracao, (indicesMap.get(lente.indice_refracao) || 0) + 1);
        
        // Categorias
        categoriasMap.set(lente.categoria, (categoriasMap.get(lente.categoria) || 0) + 1);
        
        // Marcas
        if (lente.marca_nome && lente.marca_id) {
          const existing = marcasMap.get(lente.marca_id);
          if (existing) {
            existing.count++;
          } else {
            marcasMap.set(lente.marca_id, { id: lente.marca_id, nome: lente.marca_nome, count: 1 });
          }
        }
        
        // Fornecedores
        if (lente.fornecedor_nome && lente.fornecedor_id) {
          const existing = fornecedoresMap.get(lente.fornecedor_id);
          if (existing) {
            existing.count++;
          } else {
            fornecedoresMap.set(lente.fornecedor_id, { id: lente.fornecedor_id, nome: lente.fornecedor_nome, count: 1 });
          }
        }
      });

      return {
        success: true,
        data: {
          tipos_lente: Array.from(tiposMap.entries())
            .map(([tipo, total]) => ({ valor: tipo, total }))
            .sort((a, b) => b.total - a.total),
          
          materiais: Array.from(materiaisMap.entries())
            .map(([material, total]) => ({ valor: material, total }))
            .sort((a, b) => b.total - a.total),
          
          indices_refracao: Array.from(indicesMap.entries())
            .map(([indice, total]) => ({ valor: indice, total }))
            .sort((a, b) => parseFloat(a.valor) - parseFloat(b.valor)),
          
          categorias: Array.from(categoriasMap.entries())
            .map(([categoria, total]) => ({ valor: categoria, total }))
            .sort((a, b) => b.total - a.total),
          
          marcas: Array.from(marcasMap.values())
            .sort((a, b) => a.nome.localeCompare(b.nome)),
          
          fornecedores: Array.from(fornecedoresMap.values())
            .sort((a, b) => a.nome.localeCompare(b.nome))
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
  // ESTATÍSTICAS DO CATÁLOGO
  // ==========================================================================
  
  /**
   * Obter estatísticas gerais do catálogo
   */
  static async obterEstatisticasCatalogo(): Promise<SingleApiResponse<StatsCatalogo>> {
    try {
      const { data, error } = await supabase
        .from('vw_stats_catalogo')
        .select('*')
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data as StatsCatalogo
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
  // MÉTODOS DE COMPATIBILIDADE (para código legado)
  // ==========================================================================
  
  /**
   * Buscar grupos genéricos (não-premium)
   * @deprecated Use buscarGruposCanonicos com is_premium: false
   */
  static async buscarGruposGenericos(params: BuscarGruposParams = {}) {
    return this.buscarGruposCanonicos({ ...params, is_premium: false });
  }

  /**
   * Buscar grupos premium
   * @deprecated Use buscarGruposCanonicos com is_premium: true
   */
  static async buscarGruposPremium(params: BuscarGruposParams = {}) {
    return this.buscarGruposCanonicos({ ...params, is_premium: true });
  }
}

// Exportar instância singleton
export const viewsApi = ViewsApiClient;
