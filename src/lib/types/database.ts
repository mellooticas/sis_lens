/**
 * Tipos para Views Públicas do Banco
 * Baseado nas views criadas no sistema
 */

// ============================================================================
// VIEWS PRINCIPAIS DO CATÁLOGO
// ============================================================================

export interface VwLentesCatalogo {
  id: string;
  tenant_id: string;
  sku_canonico: string;
  nome_comercial: string;
  marca: string;
  categoria: string;
  material: string;
  indice_refracao: number;
  tratamentos: string[];
  diametro: number;
  curva_base: number;
  status: string;
  disponivel: boolean;
  preco_referencia?: number;
  created_at: string;
  updated_at: string;
}

export interface VwFornecedores {
  id: string;
  tenant_id: string;
  nome: string;
  nome_fantasia: string;
  cnpj?: string;
  telefone?: string;
  email?: string;
  lead_time_padrao: number;
  qualidade_base: number;
  regioes_atendidas: string[];
  total_produtos: number;
  ativo: boolean;
  created_at: string;
  updated_at: string;
}

export interface VwProdutosLaboratorio {
  id: string;
  tenant_id: string;
  laboratorio_id: string;
  laboratorio_nome: string;
  lente_id: string;
  lente_nome: string;
  sku_laboratorio: string;
  sku_fantasia: string;
  nome_comercial: string;
  preco_atual?: number;
  prazo_dias: number;
  disponivel: boolean;
  qualidade: number;
  descontinuado: boolean;
  created_at: string;
  updated_at: string;
}

// ============================================================================
// VIEWS DE DECISÕES E RANKING
// ============================================================================

export interface VwDecisoesCompra {
  id: string;
  tenant_id: string;
  usuario_id: string;
  usuario_nome: string;
  lente_id: string;
  lente_nome: string;
  laboratorio_id: string;
  laboratorio_nome: string;
  sku_fantasia: string;
  criterio_usado: string;
  preco_final: number;
  prazo_dias: number;
  economia_estimada: number;
  score_total: number;
  status: string;
  observacoes?: string;
  data_decisao: string;
  created_at: string;
  updated_at: string;
}

export interface VwRankingOpcoes {
  ranking_id: string;
  lente_id: string;
  lente_nome: string;
  posicao: number;
  laboratorio_id: string;
  laboratorio_nome: string;
  produto_laboratorio_id: string;
  sku_fantasia: string;
  preco_final: number;
  prazo_dias: number;
  score_total: number;
  score_preco: number;
  score_prazo: number;
  score_qualidade: number;
  economia_estimada: number;
  percentual_economia: number;
  criterio_usado: string;
  disponivel: boolean;
  observacoes?: string;
  created_at: string;
}

// ============================================================================
// VIEWS DE ANALYTICS E MÉTRICAS
// ============================================================================

export interface MvEconomia {
  id: string;
  tenant_id: string;
  periodo_ano: number;
  periodo_mes: number;
  laboratorio_id: string;
  laboratorio_nome: string;
  total_decisoes: number;
  valor_total_decisoes: number;
  economia_total_gerada: number;
  economia_media_decisao: number;
  percentual_economia: number;
  prazo_medio_entrega: number;
  score_medio_qualidade: number;
  taxa_preferencia: number;
  posicao_ranking: number;
  updated_at: string;
}

export interface VwMetricasFornecedor {
  laboratorio_id: string;
  laboratorio_nome: string;
  tenant_id: string;
  periodo: string;
  total_decisoes: number;
  valor_total: number;
  economia_gerada: number;
  economia_media: number;
  prazo_medio: number;
  score_medio: number;
  taxa_crescimento: number;
  posicao_atual: number;
  posicao_anterior: number;
  tendencia: 'SUBINDO' | 'DESCENDO' | 'ESTAVEL';
}

// ============================================================================
// TIPOS PARA RESPONSES DAS VIEWS
// ============================================================================

export interface ViewResponse<T> {
  data: T[];
  total: number;
  page?: number;
  limit?: number;
  has_more?: boolean;
  filters_applied?: Record<string, any>;
  cache_hit?: boolean;
  query_time_ms?: number;
}

export interface SingleViewResponse<T> {
  data: T | null;
  found: boolean;
  cache_hit?: boolean;
  query_time_ms?: number;
}

// ============================================================================
// FILTROS PARA VIEWS
// ============================================================================

export interface FiltrosLentesCatalogo {
  marca?: string[];
  categoria?: string[];
  material?: string[];
  indice_min?: number;
  indice_max?: number;
  tratamentos?: string[];
  disponivel?: boolean;
  status?: string[];
  preco_min?: number;
  preco_max?: number;
}

export interface FiltrosFornecedores {
  nome?: string;
  regioes?: string[];
  qualidade_min?: number;
  lead_time_max?: number;
  ativo?: boolean;
  total_produtos_min?: number;
}

export interface FiltrosDecisoes {
  usuario_id?: string;
  laboratorio_id?: string;
  criterio?: string[];
  status?: string[];
  data_inicio?: string;
  data_fim?: string;
  valor_min?: number;
  valor_max?: number;
  economia_min?: number;
}

export interface FiltrosVouchers {
  tipo?: string[];
  status?: string[];
  data_inicio?: string;
  data_fim?: string;
  valor_min?: number;
  valor_max?: number;
  ativo?: boolean;
  loja_id?: string;
}

export interface FiltrosPeriodo {
  ano?: number;
  mes?: number;
  data_inicio?: string;
  data_fim?: string;
  periodo_comparacao?: string;
}