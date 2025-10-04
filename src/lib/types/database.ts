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
// VIEWS DO SISTEMA DE VOUCHERS
// ============================================================================

export interface VwUsuarios {
  id: string;
  tenant_id: string;
  email: string;
  nome: string;
  role: string;
  loja_id?: string;
  loja_nome?: string;
  ativo: boolean;
  total_decisoes?: number;
  economia_gerada?: number;
  last_login?: string;
  created_at: string;
  updated_at: string;
}

export interface VwLojas {
  id: string;
  tenant_id: string;
  nome: string;
  cnpj: string;
  telefone: string;
  email: string;
  cidade: string;
  estado: string;
  total_usuarios: number;
  total_clientes: number;
  vouchers_emitidos: number;
  vouchers_utilizados: number;
  economia_vouchers: number;
  ativa: boolean;
  created_at: string;
  updated_at: string;
}

export interface VwClientes {
  id: string;
  tenant_id: string;
  nome: string;
  cpf: string;
  telefone: string;
  email?: string;
  cidade?: string;
  estado?: string;
  loja_preferida_id?: string;
  loja_preferida_nome?: string;
  total_vouchers_usados: number;
  economia_total_vouchers: number;
  ultimo_voucher_usado?: string;
  ativo: boolean;
  created_at: string;
  updated_at: string;
}

export interface VwVouchers {
  id: string;
  tenant_id: string;
  codigo: string;
  nome: string;
  descricao?: string;
  tipo: string;
  valor_desconto?: number;
  percentual_desconto?: number;
  valor_minimo_compra?: number;
  data_inicio: string;
  data_fim: string;
  limite_uso_total?: number;
  limite_uso_por_cliente?: number;
  usos_realizados: number;
  usos_restantes?: number;
  taxa_utilizacao: number;
  economia_gerada: number;
  dias_para_vencer: number;
  status_voucher: 'ATIVO' | 'EXPIRADO' | 'ESGOTADO' | 'INATIVO';
  ativo: boolean;
  created_at: string;
  updated_at: string;
}

export interface VwUsosVoucher {
  id: string;
  tenant_id: string;
  voucher_id: string;
  voucher_codigo: string;
  voucher_nome: string;
  cliente_id: string;
  cliente_nome: string;
  cliente_cpf: string;
  usuario_id: string;
  usuario_nome: string;
  loja_nome?: string;
  valor_original: number;
  valor_desconto: number;
  valor_final: number;
  percentual_desconto_aplicado: number;
  tipo_voucher: string;
  data_uso: string;
  observacoes?: string;
  created_at: string;
}

// ============================================================================
// VIEWS DE DASHBOARD E RELATÓRIOS
// ============================================================================

export interface VwDashboardExecutivo {
  tenant_id: string;
  periodo: string;
  // Métricas de Lentes
  total_decisoes_lentes: number;
  economia_total_lentes: number;
  economia_media_decisao: number;
  crescimento_decisoes: number;
  laboratorio_top_nome: string;
  laboratorio_top_percentual: number;
  // Métricas de Vouchers
  total_vouchers_emitidos: number;
  total_vouchers_utilizados: number;
  taxa_utilizacao_vouchers: number;
  economia_total_vouchers: number;
  crescimento_vouchers: number;
  // Métricas Gerais
  total_usuarios_ativos: number;
  total_lojas_ativas: number;
  total_clientes_cadastrados: number;
  receita_estimada_economia: number;
  updated_at: string;
}

export interface VwRelatorioCompleto {
  tenant_id: string;
  periodo_inicio: string;
  periodo_fim: string;
  // Decisões de Lentes
  decisoes_por_criterio: Record<string, number>;
  economia_por_laboratorio: Record<string, number>;
  prazo_medio_por_laboratorio: Record<string, number>;
  // Vouchers por Tipo
  vouchers_por_tipo: Record<string, number>;
  economia_vouchers_por_tipo: Record<string, number>;
  // Tendências
  tendencia_decisoes: Array<{
    mes: string;
    quantidade: number;
    economia: number;
  }>;
  tendencia_vouchers: Array<{
    mes: string;
    emitidos: number;
    utilizados: number;
    economia: number;
  }>;
  // Resumo
  total_economia_geral: number;
  roi_estimado: number;
  eficiencia_sistema: number;
  generated_at: string;
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