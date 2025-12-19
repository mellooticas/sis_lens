/**
 * Types TypeScript para as Views Públicas do Banco
 * Baseado em povoar_banco/06_PUBLIC_VIEWS.sql
 * 
 * Views disponíveis:
 * - vw_buscar_lentes: Motor de busca principal
 * - vw_grupos_genericos: Grupos canônicos genéricos
 * - vw_grupos_premium: Grupos canônicos premium
 * - vw_marcas: Lista de marcas
 * - vw_fornecedores: Lista de fornecedores
 * - vw_filtros_disponiveis: Valores para filtros
 * - vw_comparar_fornecedores: Comparação de preços
 * - vw_stats_catalogo: Estatísticas gerais
 */

// ============================================================================
// ENUMS E TIPOS AUXILIARES
// ============================================================================

export type TipoLente = 'visao_simples' | 'multifocal' | 'bifocal';
export type Material = 'CR39' | 'POLICARBONATO' | 'TRIVEX';
export type IndiceRefracao = '1.50' | '1.56' | '1.59' | '1.61' | '1.67' | '1.74';
export type Categoria = 'economica' | 'intermediaria' | 'premium' | 'super_premium';
export type TipoFotossensivel = 'transitions' | 'fotocromático' | 'nenhum';
export type TipoCanonica = 'premium' | 'generica';
export type StatusLente = 'ativo' | 'inativo' | 'descontinuado';

// ============================================================================
// VIEW 1: vw_buscar_lentes (Motor de Busca Principal)
// ============================================================================

export interface VwBuscarLentes {
  // IDs
  id: string;
  sku: string;
  
  // Produto
  nome_comercial: string;
  tipo_lente: TipoLente;
  material: Material;
  indice_refracao: IndiceRefracao;
  categoria: Categoria;
  
  // Marca e Fornecedor
  marca: string;
  marca_id: string;
  marca_premium: boolean;
  fornecedor: string;
  fornecedor_id: string;
  
  // Tratamentos
  ar: boolean;
  blue: boolean;
  fotossensivel: TipoFotossensivel;
  polarizado: boolean;
  antirrisco: boolean;
  uv400: boolean;
  
  // Faixas Ópticas
  esferico_min: number;
  esferico_max: number;
  cilindrico_min: number;
  cilindrico_max: number;
  adicao_min: number | null;
  adicao_max: number | null;
  
  // Especificações
  diametro: number | null;
  espessura_central: number | null;
  peso_aproximado: number | null;
  
  // Preços
  custo_base: number;
  preco_tabela: number;
  
  // Canônica
  tipo_canonica: TipoCanonica;
  grupo_canonico: string;
  canonica_id: string;
  
  // Estatísticas do Grupo Canônico
  alternativas_disponiveis: number;
  preco_min_grupo: number;
  preco_max_grupo: number;
  preco_medio_grupo: number;
  
  // Metadata
  status: StatusLente;
  created_at: string;
  updated_at: string;
}

// ============================================================================
// VIEW 2: vw_grupos_genericos (Grupos Canônicos Genéricos)
// ============================================================================

export interface OpcaoFornecedor {
  fornecedor_id: string;
  fornecedor: string;
  marca: string;
  preco: number;
}

export interface VwGruposGenericos {
  id: string;
  nome_canonico: string;
  
  // Características
  tipo_lente: TipoLente;
  material: Material;
  indice_refracao: IndiceRefracao;
  categoria: Categoria;
  
  // Tratamentos
  ar: boolean;
  blue: boolean;
  fotossensivel: boolean;
  polarizado: boolean;
  
  // Faixas Ópticas
  esferico_min: number;
  esferico_max: number;
  cilindrico_min: number;
  cilindrico_max: number;
  adicao_min: number | null;
  adicao_max: number | null;
  
  // Estatísticas
  total_lentes: number;
  preco_minimo: number;
  preco_maximo: number;
  preco_medio: number;
  
  // Fornecedores
  qtd_fornecedores: number;
  opcoes_fornecedores: OpcaoFornecedor[];
  
  ativo: boolean;
  created_at: string;
}

// ============================================================================
// VIEW 3: vw_grupos_premium (Grupos Canônicos Premium)
// ============================================================================

export interface VwGruposPremium {
  id: string;
  nome_canonico: string;
  
  // Marca (sempre presente em premium)
  marca: string;
  marca_id: string;
  
  // Características
  tipo_lente: TipoLente;
  material: Material;
  indice_refracao: IndiceRefracao;
  categoria: Categoria;
  
  // Tratamentos
  ar: boolean;
  blue: boolean;
  fotossensivel: boolean;
  polarizado: boolean;
  
  // Faixas Ópticas
  esferico_min: number;
  esferico_max: number;
  cilindrico_min: number;
  cilindrico_max: number;
  adicao_min: number | null;
  adicao_max: number | null;
  
  // Estatísticas
  total_lentes: number;
  preco_minimo: number;
  preco_maximo: number;
  preco_medio: number;
  
  // Fornecedores
  qtd_fornecedores: number;
  opcoes_fornecedores: OpcaoFornecedor[];
  
  ativo: boolean;
  created_at: string;
}

// ============================================================================
// VIEW 4: vw_marcas (Marcas para Dropdown)
// ============================================================================

export interface VwMarcas {
  id: string;
  nome: string;
  slug: string;
  is_premium: boolean;
  descricao: string | null;
  
  // Estatísticas
  lentes_premium: number;
  lentes_genericas: number;
  total_lentes: number;
  
  ativo: boolean;
  created_at: string;
}

// ============================================================================
// VIEW 5: vw_fornecedores (Fornecedores para Dropdown)
// ============================================================================

export interface VwFornecedores {
  id: string;
  nome: string;
  razao_social: string | null;
  cnpj: string | null;
  
  // Estatísticas
  total_lentes: number;
  qtd_marcas: number;
  preco_minimo: number;
  preco_maximo: number;
  preco_medio: number;
  
  ativo: boolean;
  created_at: string;
}

// ============================================================================
// VIEW 6: vw_filtros_disponiveis (Valores para Filtros)
// ============================================================================

export interface TratamentosDisponiveis {
  ar: boolean;
  blue: boolean;
  polarizado: boolean;
  antirrisco: boolean;
  uv400: boolean;
}

export interface VwFiltrosDisponiveis {
  tipos_lente: TipoLente[];
  materiais: Material[];
  indices_refracao: IndiceRefracao[];
  categorias: Categoria[];
  tipos_fotossensiveis: TipoFotossensivel[];
  tratamentos_disponiveis: TratamentosDisponiveis;
}

// ============================================================================
// VIEW 7: vw_comparar_fornecedores (Comparação de Preços)
// ============================================================================

export interface OpcaoComparacao {
  lente_id: string;
  sku: string;
  fornecedor_id: string;
  fornecedor: string;
  marca: string;
  preco_tabela: number;
  custo_base: number;
  nome_comercial: string;
}

export interface VwCompararFornecedores {
  grupo_id: string;
  produto: string;
  tipo: 'PREMIUM' | 'GENÉRICA';
  marca: string | null;
  
  // Características do grupo
  tipo_lente: TipoLente;
  material: Material;
  indice_refracao: IndiceRefracao;
  categoria: Categoria;
  
  // Array de fornecedores (ordenado por preço)
  opcoes: OpcaoComparacao[];
}

// ============================================================================
// VIEW 8: vw_stats_catalogo (Estatísticas Gerais)
// ============================================================================

export interface VwStatsCatalogo {
  // Totais gerais
  total_lentes: number;
  lentes_genericas: number;
  lentes_premium: number;
  
  // Grupos canônicos
  grupos_genericos: number;
  grupos_premium: number;
  
  // Marcas e Fornecedores
  total_marcas: number;
  marcas_premium: number;
  total_fornecedores: number;
  
  // Faixas de preço
  preco_minimo_catalogo: number;
  preco_maximo_catalogo: number;
  preco_medio_catalogo: number;
}

// ============================================================================
// TIPOS PARA PARÂMETROS DE BUSCA
// ============================================================================

export interface BuscarLentesParams {
  // Filtros básicos
  tipo_lente?: TipoLente;
  material?: Material;
  indice_refracao?: IndiceRefracao;
  categoria?: Categoria;
  
  // Filtros de marca/fornecedor
  marca_id?: string;
  fornecedor_id?: string;
  apenas_premium?: boolean;
  
  // Tratamentos
  com_ar?: boolean;
  com_blue?: boolean;
  com_fotossensivel?: boolean;
  com_polarizado?: boolean;
  com_antirrisco?: boolean;
  com_uv400?: boolean;
  
  // Faixas ópticas
  esferico_min?: number;
  esferico_max?: number;
  cilindrico_min?: number;
  cilindrico_max?: number;
  adicao_min?: number;
  adicao_max?: number;
  
  // Faixa de preço
  preco_min?: number;
  preco_max?: number;
  
  // Ordenação e paginação
  ordenar_por?: 'nome' | 'preco' | 'marca' | 'indice';
  ordem?: 'asc' | 'desc';
  limite?: number;
  offset?: number;
}

export interface BuscarGruposParams {
  tipo_lente?: TipoLente;
  material?: Material;
  indice_refracao?: IndiceRefracao;
  apenas_premium?: boolean;
  marca_id?: string;
  ordenar_por?: 'nome' | 'preco' | 'qtd_fornecedores';
  limite?: number;
  offset?: number;
}

// ============================================================================
// TIPOS PARA RESPOSTAS DA API
// ============================================================================

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  total?: number;
  metadata?: Record<string, any>;
}

export type BuscarLentesResponse = ApiResponse<VwBuscarLentes[]>;
export type GruposGenericosResponse = ApiResponse<VwGruposGenericos[]>;
export type GruposPremiumResponse = ApiResponse<VwGruposPremium[]>;
export type MarcasResponse = ApiResponse<VwMarcas[]>;
export type FornecedoresResponse = ApiResponse<VwFornecedores[]>;
export type FiltrosDisponiveisResponse = ApiResponse<VwFiltrosDisponiveis>;
export type CompararFornecedoresResponse = ApiResponse<VwCompararFornecedores[]>;
export type StatsCatalogoResponse = ApiResponse<VwStatsCatalogo>;
