/**
 * Tipos para a NOVA ESTRUTURA do Banco (Arquitetura Definitiva)
 * Baseado nas views criadas em PASSO_5_CRIAR_PUBLIC_VIEWS.sql
 */

// ============================================================================
// TYPES PARA AS NOVAS VIEWS PÚBLICAS
// ============================================================================

/**
 * View principal de busca de lentes (vw_buscar_lentes)
 * Motor de busca com agrupamento por canônicas
 */
export interface VwBuscarLentes {
  // IDs
  lente_id: string;
  tenant_id: string;
  
  // SKUs
  sku: string;
  codigo_laboratorio: string | null;
  
  // Informações do Produto
  nome_produto: string;
  linha: string | null;
  nome_comercial: string | null;
  familia: string | null;
  
  // Classificação
  tipo: 'PREMIUM' | 'GENÉRICA';
  nivel_qualidade: number; // 1-5
  
  // Marca e Laboratório
  marca: string;
  marca_id: string;
  laboratorio: string;
  laboratorio_id: string;
  
  // Características Técnicas
  tipo_lente: string;
  material: string;
  indice_refracao: number;
  tratamentos: string[]; // JSON array
  design: string | null;
  corredor_progressao: number | null;
  specs_tecnicas: Record<string, any> | null;
  
  // Agrupamento (para mostrar alternativas)
  grupo_canonico_id: string;
  sku_canonico_grupo: string;
  labs_disponiveis: number;
  rank_lab: number;
  
  // Metadata
  ativo: boolean;
  criado_em: string;
  atualizado_em: string;
}

/**
 * Catálogo de produtos Premium (vw_produtos_premium)
 * Agrupados por premium_canonicas
 */
export interface VwProdutosPremium {
  id: string;
  tenant_id: string;
  sku: string;
  
  // Produto
  linha_produto: string;
  nome: string;
  descricao: string | null;
  
  // Marca
  marca: string;
  marca_id: string;
  pais_origem: string | null;
  
  // Características
  tipo_lente: string;
  material: string;
  indice_refracao: number;
  tratamentos: string[]; // JSON array
  specs_tecnicas: Record<string, any> | null;
  
  // Disponibilidade
  qtd_laboratorios: number;
  laboratorios: Array<{
    laboratorio_id: string;
    laboratorio: string;
    sku_laboratorio: string;
  }>;
  
  ativo: boolean;
  criado_em: string;
}

/**
 * Catálogo de produtos Genéricos (vw_produtos_genericos)
 * Agrupados por lentes_canonicas
 */
export interface VwProdutosGenericos {
  id: string;
  tenant_id: string;
  sku: string;
  
  // Produto
  nome: string;
  descricao: string;
  
  // Características
  tipo_lente: string;
  material: string;
  indice_refracao: number;
  tratamentos: string[];
  tratamentos_detalhes: string | null;
  specs_tecnicas: Record<string, any> | null;
  
  // Disponibilidade
  qtd_laboratorios: number;
  laboratorios: Array<{
    laboratorio_id: string;
    laboratorio: string;
    marca: string;
    sku_laboratorio: string;
  }>;
  
  ativo: boolean;
  criado_em: string;
}

/**
 * Marcas para dropdowns (vw_marcas)
 */
export interface VwMarcas {
  id: string;
  tenant_id: string;
  nome: string;
  pais_origem: string | null;
  
  // Estatísticas
  produtos_premium: number;
  produtos_genericos: number;
  total_produtos: number;
  
  ativo: boolean;
  criado_em: string;
}

/**
 * Laboratórios para dropdowns (vw_laboratorios)
 */
export interface VwLaboratorios {
  id: string;
  tenant_id: string;
  nome: string;
  razao_social: string;
  cnpj: string | null;
  
  // Estatísticas
  total_produtos: number;
  produtos_premium: number;
  
  ativo: boolean;
  criado_em: string;
}

/**
 * Filtros disponíveis no sistema (vw_filtros_disponiveis)
 */
export interface VwFiltrosDisponiveis {
  tenant_id: string;
  tipos_lente: string[];
  materiais: string[];
  indices: number[];
  tratamentos: string[];
  designs: string[];
}

/**
 * Comparação do mesmo produto em labs diferentes (vw_comparar_labs)
 */
export interface VwCompararLabs {
  grupo_id: string;
  tenant_id: string;
  
  // Produto
  produto: string;
  tipo: 'PREMIUM' | 'GENÉRICA';
  marca: string | null;
  
  // Características
  tipo_lente: string;
  material: string;
  indice_refracao: number;
  tratamentos: string[];
  
  // Opções de Labs
  opcoes_labs: Array<{
    lente_id: string;
    sku: string;
    sku_laboratorio: string;
    laboratorio_id: string;
    laboratorio: string;
    disponivel: boolean;
  }>;
  
  qtd_labs: number;
}

// ============================================================================
// TIPOS PARA AS FUNÇÕES DA API
// ============================================================================

/**
 * Parâmetros para fn_api_buscar_lentes
 */
export interface BuscarLentesParams {
  tipo_lente?: string;
  material?: string;
  indice_min?: number;
  indice_max?: number;
  tratamentos?: string[];
  marca_id?: string;
  laboratorio_id?: string;
  apenas_premium?: boolean;
  ordenar_por?: 'nome' | 'marca' | 'tipo';
  limite?: number;
  offset?: number;
}

/**
 * Retorno da função fn_api_buscar_lentes
 */
export interface BuscarLentesResult {
  lente_id: string;
  sku: string;
  nome: string;
  tipo: string;
  marca: string;
  laboratorio: string;
  labs_disponiveis: number;
  caracteristicas: {
    tipo_lente: string;
    material: string;
    indice: number;
    tratamentos: string[];
    design: string | null;
    corredor: number | null;
  };
}

/**
 * Retorno da função fn_api_detalhes_lente
 */
export interface DetalhesLenteResult {
  lente: {
    id: string;
    sku: string;
    nome: string;
    tipo: string;
    nivel_qualidade: number;
  };
  marca: {
    id: string;
    nome: string;
  };
  laboratorio: {
    id: string;
    nome: string;
    codigo_produto: string;
  };
  caracteristicas: {
    tipo_lente: string;
    material: string;
    indice_refracao: number;
    tratamentos: string[];
    design: string | null;
    corredor_progressao: number | null;
  };
  alternativas: Array<{
    lente_id: string;
    laboratorio: string;
    sku_laboratorio: string;
  }> | null;
  metadata: {
    labs_disponiveis: number;
    criado_em: string;
    atualizado_em: string;
  };
}

// ============================================================================
// TIPOS PARA VIEWS EXISTENTES (mantidas por compatibilidade)
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

// ============================================================================
// TIPOS AUXILIARES
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

// Filtros
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
