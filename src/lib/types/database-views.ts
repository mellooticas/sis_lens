/**
 * Tipos TypeScript para as Views do Banco de Dados
 * Baseado nas views criadas em 14_VIEWS_FINAIS_V3.sql
 * 
 * Arquitetura:
 * - vw_lentes_catalogo: 1.411 lentes completas (Módulo Buscar)
 * - vw_canonicas_genericas: 187 grupos normalizados (Módulo Catálogo)
 * - vw_canonicas_premium: 250 grupos premium (Módulo Premium)
 * - vw_detalhes_premium: Detalhes das lentes de cada canônica (Comparar)
 * - vw_stats_catalogo: Estatísticas gerais
 */

// ============================================================================
// ENUMS DO BANCO
// ============================================================================

export type TipoLente = 'visao_simples' | 'multifocal' | 'bifocal' | 'leitura' | 'ocupacional';

export type CategoriaLente = 'economica' | 'intermediaria' | 'premium' | 'super_premium';

export type MaterialLente = 'CR39' | 'POLICARBONATO' | 'TRIVEX' | 'HIGH_INDEX' | 'VIDRO' | 'ACRILICO';

export type IndiceRefracao = '1.50' | '1.56' | '1.59' | '1.61' | '1.67' | '1.74' | '1.90';

export type TratamentoFoto = 'nenhum' | 'transitions' | 'fotocromático' | 'polarizado';

export type StatusLente = 'ativo' | 'inativo' | 'descontinuado' | 'em_falta';

// ============================================================================
// VIEW 1: vw_lentes_catalogo (BUSCAR LENTES - 1.411 lentes)
// ============================================================================

export interface LenteCatalogo {
  // IDs
  id: string;
  marca_id: string;
  fornecedor_id: string;
  lente_canonica_id: string | null;
  premium_canonica_id: string | null;
  
  // Códigos e Nomes
  sku_fornecedor: string;
  codigo_original: string | null;
  nome_comercial: string;
  
  // Marca
  marca_nome: string;
  marca_slug: string;
  marca_premium: boolean;
  
  // Características Técnicas
  tipo_lente: TipoLente;
  categoria: CategoriaLente;
  material: MaterialLente;
  indice_refracao: IndiceRefracao;
  linha_produto: string | null;
  
  // Especificações Ópticas
  diametro: number | null;
  espessura_central: number | null;
  peso_aproximado: number | null;
  esferico_min: number | null;
  esferico_max: number | null;
  cilindrico_min: number | null;
  cilindrico_max: number | null;
  adicao_min: number | null;
  adicao_max: number | null;
  dnp_min: number | null;
  dnp_max: number | null;
  
  // Tratamentos
  ar: boolean;
  antirrisco: boolean;
  hidrofobico: boolean;
  antiembaçante: boolean;
  blue: boolean;
  uv400: boolean;
  fotossensivel: TratamentoFoto;
  polarizado: boolean;
  
  // Tecnologias
  digital: boolean;
  free_form: boolean;
  indoor: boolean;
  drive: boolean;
  
  // Preços
  custo_base: number;
  preco_fabricante: number | null;
  preco_tabela: number;
  
  // Logística
  prazo_entrega: number | null;
  obs_prazo: string | null;
  peso_frete: number | null;
  exige_receita_especial: boolean | null;
  
  // Descrições
  descricao_curta: string | null;
  descricao_completa: string | null;
  beneficios: string[] | null;
  indicacoes: string[] | null;
  contraindicacoes: string | null;
  observacoes: string | null;
  
  // Status
  status: StatusLente;
  disponivel: boolean;
  destaque: boolean | null;
  novidade: boolean | null;
  data_lancamento: string | null;
  data_descontinuacao: string | null;
  
  // Metadata
  created_at: string;
  updated_at: string;
}

// ============================================================================
// VIEW 2: vw_canonicas_genericas (CATÁLOGO - 187 grupos)
// ============================================================================

export interface CanonicaGenerica {
  id: string;
  nome_canonico: string;
  descricao: string | null;
  tipo_lente: TipoLente;
  material: MaterialLente;
  indice_refracao: IndiceRefracao;
  categoria: CategoriaLente;
  
  // Características Técnicas
  ar: boolean;
  blue: boolean;
  fotossensivel: boolean;
  polarizado: boolean;
  
  // Faixas Ópticas
  esferico_min: number | null;
  esferico_max: number | null;
  cilindrico_min: number | null;
  cilindrico_max: number | null;
  adicao_min: number | null;
  adicao_max: number | null;
  
  // Estatísticas (calculadas)
  total_lentes: number | null;
  preco_minimo: number | null;
  preco_maximo: number | null;
  preco_medio: number | null;
  
  // Agregações
  lentes_ativas: number;
  total_marcas: number;
  marcas_disponiveis: string[] | null;
  
  // Metadata
  ativo: boolean;
  created_at: string;
  updated_at: string;
}

// ============================================================================
// VIEW 3: vw_canonicas_premium (PREMIUM - 250 grupos)
// ============================================================================

export interface CanonicaPremium {
  id: string;
  marca_id: string;
  linha_produto: string | null;
  nome_canonico: string;
  descricao: string | null;
  tipo_lente: TipoLente;
  material: MaterialLente;
  indice_refracao: IndiceRefracao;
  categoria: CategoriaLente;
  
  // Marca
  marca_nome: string;
  marca_slug: string;
  marca_premium: boolean;
  
  // Características Técnicas
  ar: boolean;
  blue: boolean;
  fotossensivel: boolean;
  polarizado: boolean;
  
  // Faixas Ópticas
  esferico_min: number | null;
  esferico_max: number | null;
  cilindrico_min: number | null;
  cilindrico_max: number | null;
  adicao_min: number | null;
  adicao_max: number | null;
  
  // Estatísticas (calculadas)
  total_lentes: number | null;
  preco_minimo: number | null;
  preco_maximo: number | null;
  preco_medio: number | null;
  
  // Agregações
  lentes_ativas: number;
  
  // Metadata
  ativo: boolean;
  created_at: string;
  updated_at: string;
}

// ============================================================================
// VIEW 4: vw_detalhes_premium (COMPARAR - detalhes por canônica)
// ============================================================================

export interface DetalhePremium {
  // Canônica
  canonica_id: string;
  nome_canonico: string;
  canonica_linha: string | null;
  canonica_tipo_lente: TipoLente;
  canonica_material: MaterialLente;
  canonica_indice: IndiceRefracao;
  
  // Lente Real
  lente_id: string;
  sku_fornecedor: string;
  codigo_original: string | null;
  nome_comercial: string;
  linha_produto: string | null;
  categoria: CategoriaLente;
  material: MaterialLente;
  indice_refracao: IndiceRefracao;
  
  // Marca (Laboratório)
  marca_id: string;
  marca_nome: string;
  marca_slug: string;
  marca_premium: boolean;
  
  // Tratamentos
  ar: boolean;
  antirrisco: boolean;
  hidrofobico: boolean;
  antiembaçante: boolean;
  blue: boolean;
  uv400: boolean;
  fotossensivel: TratamentoFoto;
  polarizado: boolean;
  
  // Tecnologias Premium
  digital: boolean;
  free_form: boolean;
  indoor: boolean;
  drive: boolean;
  
  // Especificações Ópticas
  esferico_min: number | null;
  esferico_max: number | null;
  cilindrico_min: number | null;
  cilindrico_max: number | null;
  adicao_min: number | null;
  adicao_max: number | null;
  diametro: number | null;
  espessura_central: number | null;
  
  // Preços
  custo_base: number;
  preco_tabela: number;
  preco_fabricante: number | null;
  
  // Logística
  disponivel: boolean;
  prazo_entrega: number | null;
  obs_prazo: string | null;
  
  // Status
  destaque: boolean | null;
  novidade: boolean | null;
  
  // Descrições
  descricao_curta: string | null;
  beneficios: string[] | null;
}

// ============================================================================
// VIEW 5: vw_stats_catalogo (ESTATÍSTICAS)
// ============================================================================

export interface StatsCatalogo {
  // Totais Gerais
  total_lentes: number;
  total_marcas: number;
  total_tipos: number;
  
  // Por Categoria
  total_economicas: number;
  total_intermediarias: number;
  total_premium: number;
  total_super_premium: number;
  
  // Por Tipo
  total_visao_simples: number;
  total_multifocal: number;
  total_bifocal: number;
  total_leitura: number;
  total_ocupacional: number;
  
  // Por Material
  total_cr39: number;
  total_policarbonato: number;
  total_trivex: number;
  total_high_index: number;
  total_vidro: number;
  total_acrilico: number;
  
  // Tratamentos
  total_com_ar: number;
  total_com_blue: number;
  total_fotossensiveis: number;
  total_polarizados: number;
  total_digitais: number;
  total_free_form: number;
  
  // Preços
  preco_minimo: number;
  preco_maximo: number;
  preco_medio: number;
  
  // Status
  total_disponiveis: number;
  total_destaques: number;
  total_novidades: number;
}

// ============================================================================
// TIPOS AUXILIARES PARA O FRONTEND
// ============================================================================

export interface FiltrosLentes {
  tipos?: TipoLente[];
  categorias?: CategoriaLente[];
  materiais?: MaterialLente[];
  indices?: IndiceRefracao[];
  marcas?: string[];
  tratamentos?: {
    ar?: boolean;
    blue?: boolean;
    fotossensivel?: boolean;
    polarizado?: boolean;
    digital?: boolean;
    free_form?: boolean;
  };
  preco?: {
    min?: number;
    max?: number;
  };
  busca?: string;
}

export interface PaginacaoParams {
  pagina?: number;
  limite?: number;
  ordenar?: string;
  direcao?: 'asc' | 'desc';
}

export interface RespostaPaginada<T> {
  dados: T[];
  paginacao: {
    total: number;
    pagina: number;
    limite: number;
    total_paginas: number;
  };
}
