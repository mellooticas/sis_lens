/**
 * Tipos TypeScript para as Views do Banco de Dados
 *
 * ─── NOVO BANCO (migration 111+) ────────────────────────────────────────────
 * Tabela base : catalog_lenses.lenses
 * View leitura: public.v_catalog_lenses
 * View stats  : public.v_catalog_lens_stats
 * RPC busca   : public.rpc_lens_search(...)
 * RPC alts    : public.rpc_lens_get_alternatives(...)
 * Wrappers PT : public.buscar_lentes(...) / public.obter_alternativas_lente(...)
 *
 * ─── LEGADO (deprecated) ────────────────────────────────────────────────────
 * Os tipos abaixo (VLenteCatalogo, VGruposCanonico, StatsCatalogo …) foram
 * baseados no banco antigo e são mantidos apenas para compat. Prefira os tipos
 * novos acima ao criar novas funcionalidades.
 */

// ============================================================================
// NOVO BANCO — ENUMS  (migration 002_types_and_enums.sql)
// ============================================================================

/** Tipos de lente disponíveis no novo banco */
export type LensType =
  | 'single_vision'
  | 'multifocal'
  | 'bifocal'
  | 'reading'
  | 'occupational';

/** Materiais de lente disponíveis no novo banco */
export type LensMaterialType =
  | 'cr39'
  | 'polycarbonate'
  | 'trivex'
  | 'high_index'
  | 'glass'
  | 'acrylic';

/** Status de registro (inventory.record_status) */
export type RecordStatus = 'active' | 'inactive' | 'archived';

// ============================================================================
// NOVO BANCO — VIEW: public.v_catalog_lenses  (migration 111)
// ============================================================================

/**
 * Linha da view pública `public.v_catalog_lenses`.
 * JWT-tenant-filtered; acesso SELECT concedido ao role `authenticated`.
 * Campos `lens_type`, `material` e `status` são TEXT (cast from enums na view).
 */
export interface VCatalogLens {
  // ─── IDs ───────────────────────────────────────────────────────────────────
  id: string;
  tenant_id: string;
  supplier_lab_id: string | null;
  group_id: string | null;

  // ─── Relacionamentos (desnormalizados na view) ──────────────────────────────
  supplier_name: string | null;   // catalog_lenses.suppliers_labs.name
  group_name: string | null;      // catalog_lenses.lens_groups.name

  // ─── Identificação ─────────────────────────────────────────────────────────
  sku: string | null;
  slug: string | null;
  lens_name: string;
  brand_name: string | null;

  // ─── Características técnicas ───────────────────────────────────────────────
  lens_type: string | null;         // TEXT cast de catalog_lenses.lens_type
  material: string | null;          // TEXT cast de catalog_lenses.lens_material_type
  refractive_index: number | null;
  category: string | null;          // 'standard' | 'premium' | …

  // ─── Tratamentos ───────────────────────────────────────────────────────────
  anti_reflective: boolean;
  anti_scratch: boolean;
  uv_filter: boolean;
  blue_light: boolean;
  photochromic: string | null;      // VARCHAR(50): 'nenhum' | 'photo' | 'transitions' | …
  polarized: boolean;

  // ─── Tecnologias ───────────────────────────────────────────────────────────
  digital: boolean;
  free_form: boolean;
  indoor: boolean;
  drive: boolean;

  // ─── Faixas ópticas ────────────────────────────────────────────────────────
  spherical_min: number | null;
  spherical_max: number | null;
  cylindrical_min: number | null;
  cylindrical_max: number | null;
  addition_min: number | null;
  addition_max: number | null;

  // ─── Preços ────────────────────────────────────────────────────────────────
  price_cost: number;
  price_suggested: number;

  // ─── Estoque / Logística ───────────────────────────────────────────────────
  stock_available: number;
  stock_minimum: number;
  lead_time_days: number;

  // ─── Classificação / Status ─────────────────────────────────────────────────
  is_premium: boolean;
  status: string;                   // TEXT cast de inventory.record_status
  attributes: Record<string, unknown>;

  // ─── Metadata ──────────────────────────────────────────────────────────────
  created_at: string;
  updated_at: string;
}

// ============================================================================
// NOVO BANCO — VIEW: public.v_catalog_lens_stats  (migration 111)
// ============================================================================

/**
 * Linha única da view `public.v_catalog_lens_stats`.
 * Agrega contagens e faixas de preço para o catálogo do tenant atual.
 */
export interface VCatalogLensStats {
  total_lenses: number;
  total_active: number;
  total_premium: number;
  total_with_ar: number;
  total_with_blue: number;
  total_photochromic: number;
  price_min: number | null;
  price_max: number | null;
  price_avg: number | null;
  stock_total: number;
}

// ============================================================================
// NOVO BANCO — RPC: public.rpc_lens_search(...)  (migration 111/114)
// ============================================================================

/**
 * Linha retornada por `public.rpc_lens_search(...)`.
 * Subset de campos de `v_catalog_lenses` otimizado para busca.
 */
export interface RpcLensSearchResult {
  id: string;
  slug: string | null;
  lens_name: string;
  supplier_name: string | null;
  brand_name: string | null;
  lens_type: string | null;
  material: string | null;
  refractive_index: number | null;
  price_suggested: number;
  category: string | null;
  has_ar: boolean;
  has_blue: boolean;
  group_name: string | null;
  stock_available: number;
  lead_time_days: number;
  is_premium: boolean;
}

// ============================================================================
// NOVO BANCO — RPC: public.rpc_lens_get_alternatives(...)  (migration 111/114)
// ============================================================================

/**
 * Linha retornada por `public.rpc_lens_get_alternatives(...)`.
 */
export interface RpcLensAlternativeResult {
  id: string;
  slug: string | null;
  lens_name: string;
  supplier_name: string | null;
  price_suggested: number;
  price_diff: number;
  lead_time_days: number;
}

// ============================================================================
// NOVO BANCO — VIEW GROUPS (v_catalog_lens_groups — a criar)
// ============================================================================

/**
 * Linha da view de grupos canônicos do novo banco.
 * A view `public.v_catalog_lens_groups` será criada pelo usuário;
 * enquanto isso, `group_id` / `group_name` estão disponíveis em VCatalogLens.
 */
export interface VCatalogLensGroup {
  id: string;
  tenant_id: string;
  name: string;
  lens_type: string | null;
  material: string | null;
  refractive_index: number | null;
  is_premium: boolean;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

// ============================================================================
// LEGADO — ENUMS DO BANCO ANTIGO  (@deprecated)
// ============================================================================

/** @deprecated Use LensType */
export type TipoLente = 'visao_simples' | 'multifocal' | 'bifocal' | 'leitura' | 'ocupacional';

/** @deprecated Use string (category field in VCatalogLens) */
export type CategoriaLente = 'economica' | 'intermediaria' | 'premium' | 'super_premium';

/** @deprecated Use LensMaterialType */
export type MaterialLente = 'CR39' | 'POLICARBONATO' | 'TRIVEX' | 'HIGH_INDEX' | 'VIDRO' | 'ACRILICO';

/** @deprecated Use number (refractive_index in VCatalogLens) */
export type IndiceRefracao = '1.50' | '1.56' | '1.59' | '1.61' | '1.67' | '1.74' | '1.90';

/** @deprecated Use string (photochromic in VCatalogLens) */
export type TratamentoFoto = 'nenhum' | 'transitions' | 'fotocromático' | 'polarizado';

/** @deprecated Use RecordStatus */
export type StatusLente = 'ativo' | 'inativo' | 'descontinuado' | 'em_falta';

// ============================================================================
// LEGADO — VIEW v_lentes_catalogo  (@deprecated — use VCatalogLens)
// ============================================================================

/**
 * @deprecated Use VCatalogLens (view `public.v_catalog_lenses` do novo banco)
 */
export interface VLenteCatalogo {
  // IDs
  id: string;
  marca_id: string;
  fornecedor_id: string;
  grupo_id: string | null;

  // Códigos e Nomes
  slug: string | null;
  nome_lente: string;
  nome_canonizado: string | null;
  fornecedor_nome: string | null;

  // Marca
  marca_nome: string;
  marca_slug: string;
  marca_premium: boolean;
  nome_grupo: string | null;
  grupo_slug: string | null;

  // Características Técnicas
  tipo_lente: TipoLente;
  categoria: CategoriaLente;
  material: MaterialLente;
  indice_refracao: IndiceRefracao;

  // Especificações Ópticas
  diametro_mm: number | null;
  espessura_centro_mm: number | null;
  curva_base: number | null;
  grau_esferico_min: number | null;
  grau_esferico_max: number | null;
  grau_cilindrico_min: number | null;
  grau_cilindrico_max: number | null;
  adicao_min: number | null;
  adicao_max: number | null;
  peso: number | null;

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
  preco_custo: number;
  preco_venda_sugerido: number;
  margem_lucro: number | null;

  // Logística
  prazo_visao_simples: number | null;
  prazo_multifocal: number | null;
  prazo_surfacada: number | null;
  prazo_free_form: number | null;

  // Estoque
  estoque_disponivel: number | null;
  estoque_reservado: number | null;

  // Status
  status: StatusLente;
  ativo: boolean;

  // Metadata
  metadata: unknown | null;
  created_at: string;
  updated_at: string;
}

/** @deprecated Use VCatalogLens */
export type LenteCatalogo = VLenteCatalogo;

// ============================================================================
// LEGADO — VIEW v_grupos_canonicos  (@deprecated — grupos agora em lens_groups)
// ============================================================================

/**
 * @deprecated Use VCatalogLensGroup (view `v_catalog_lens_groups` a ser criada)
 * Grupos canônicos disponíveis como colunas group_id/group_name em VCatalogLens.
 */
export interface VGruposCanonico {
  id: string;
  slug: string;
  nome_grupo: string;
  tipo_lente: TipoLente;
  material: MaterialLente;
  indice_refracao: IndiceRefracao;
  categoria_predominante: CategoriaLente;
  grau_esferico_min: number | null;
  grau_esferico_max: number | null;
  grau_cilindrico_min: number | null;
  grau_cilindrico_max: number | null;
  adicao_min: number | null;
  adicao_max: number | null;
  descricao_ranges: string | null;
  tem_antirreflexo: boolean;
  tem_antirrisco: boolean;
  tem_uv: boolean;
  tem_blue_light: boolean;
  tratamento_foto: TratamentoFoto;
  preco_minimo: number | null;
  preco_maximo: number | null;
  preco_medio: number | null;
  custo_medio: number | null;
  custo_minimo: number | null;
  custo_maximo: number | null;
  margem_percentual: number | null;
  lucro_unitario: number | null;
  markup: number | null;
  faixa_preco: string | null;
  categoria_preco: string | null;
  total_lentes: number;
  total_marcas: number;
  total_fornecedores: number;
  prazo_medio_dias: number | null;
  peso: number | null;
  fornecedores_disponiveis: unknown;
  marcas_disponiveis: unknown;
  marcas_nomes: string | null;
  is_premium: boolean;
  ativo: boolean;
  created_at: string;
  updated_at: string;
}

/** @deprecated Use VCatalogLensGroup */
export type GrupoCanonico = VGruposCanonico;

// ============================================================================
// LEGADO — vw_stats_catalogo  (@deprecated — use VCatalogLensStats)
// ============================================================================

/**
 * @deprecated Use VCatalogLensStats (view `v_catalog_lens_stats` do novo banco)
 */
export interface StatsCatalogo {
  total_lentes: number;
  total_marcas: number;
  total_tipos: number;
  total_economicas: number;
  total_intermediarias: number;
  total_premium: number;
  total_super_premium: number;
  total_visao_simples: number;
  total_multifocal: number;
  total_bifocal: number;
  total_leitura: number;
  total_ocupacional: number;
  total_cr39: number;
  total_policarbonato: number;
  total_trivex: number;
  total_high_index: number;
  total_vidro: number;
  total_acrilico: number;
  total_com_ar: number;
  total_com_blue: number;
  total_fotossensiveis: number;
  total_polarizados: number;
  total_digitais: number;
  total_free_form: number;
  preco_minimo: number;
  preco_maximo: number;
  preco_medio: number;
  total_disponiveis: number;
  total_destaques: number;
  total_novidades: number;
}

// ============================================================================
// LEGADO — Outros tipos de view  (@deprecated)
// ============================================================================

/** @deprecated */
export interface CanonicaGenerica {
  id: string;
  nome_canonico: string;
  descricao: string | null;
  tipo_lente: TipoLente;
  material: MaterialLente;
  indice_refracao: IndiceRefracao;
  categoria: CategoriaLente;
  ar: boolean;
  blue: boolean;
  fotossensivel: boolean;
  polarizado: boolean;
  esferico_min: number | null;
  esferico_max: number | null;
  cilindrico_min: number | null;
  cilindrico_max: number | null;
  adicao_min: number | null;
  adicao_max: number | null;
  total_lentes: number | null;
  preco_minimo: number | null;
  preco_maximo: number | null;
  preco_medio: number | null;
  lentes_ativas: number;
  total_marcas: number;
  marcas_disponiveis: string[] | null;
  ativo: boolean;
  created_at: string;
  updated_at: string;
}

/** @deprecated */
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
  marca_nome: string;
  marca_slug: string;
  marca_premium: boolean;
  ar: boolean;
  blue: boolean;
  fotossensivel: boolean;
  polarizado: boolean;
  esferico_min: number | null;
  esferico_max: number | null;
  cilindrico_min: number | null;
  cilindrico_max: number | null;
  adicao_min: number | null;
  adicao_max: number | null;
  total_lentes: number | null;
  preco_minimo: number | null;
  preco_maximo: number | null;
  preco_medio: number | null;
  lentes_ativas: number;
  ativo: boolean;
  created_at: string;
  updated_at: string;
}

/** @deprecated */
export interface DetalhePremium {
  canonica_id: string;
  nome_canonico: string;
  canonica_linha: string | null;
  canonica_tipo_lente: TipoLente;
  canonica_material: MaterialLente;
  canonica_indice: IndiceRefracao;
  lente_id: string;
  sku_fornecedor: string;
  codigo_original: string | null;
  nome_comercial: string;
  linha_produto: string | null;
  categoria: CategoriaLente;
  material: MaterialLente;
  indice_refracao: IndiceRefracao;
  marca_id: string;
  marca_nome: string;
  marca_slug: string;
  marca_premium: boolean;
  ar: boolean;
  antirrisco: boolean;
  hidrofobico: boolean;
  antiembaçante: boolean;
  blue: boolean;
  uv400: boolean;
  fotossensivel: TratamentoFoto;
  polarizado: boolean;
  digital: boolean;
  free_form: boolean;
  indoor: boolean;
  drive: boolean;
  esferico_min: number | null;
  esferico_max: number | null;
  cilindrico_min: number | null;
  cilindrico_max: number | null;
  adicao_min: number | null;
  adicao_max: number | null;
  diametro: number | null;
  espessura_central: number | null;
  custo_base: number;
  preco_tabela: number;
  preco_fabricante: number | null;
  disponivel: boolean;
  prazo_entrega: number | null;
  obs_prazo: string | null;
  destaque: boolean | null;
  novidade: boolean | null;
  descricao_curta: string | null;
  beneficios: string[] | null;
}

/** @deprecated */
export interface DetalheGenerico {
  canonica_id: string;
  nome_canonico: string;
  canonica_tipo_lente: TipoLente;
  canonica_material: MaterialLente;
  canonica_indice: IndiceRefracao;
  canonica_categoria: CategoriaLente;
  lente_id: string;
  sku_fornecedor: string;
  codigo_original: string | null;
  nome_comercial: string;
  linha_produto: string | null;
  categoria: CategoriaLente;
  material: MaterialLente;
  indice_refracao: IndiceRefracao;
  marca_id: string;
  marca_nome: string;
  marca_slug: string;
  marca_premium: boolean;
  ar: boolean;
  antirrisco: boolean;
  hidrofobico: boolean;
  antiembaçante: boolean;
  blue: boolean;
  uv400: boolean;
  fotossensivel: TratamentoFoto;
  polarizado: boolean;
  digital: boolean;
  free_form: boolean;
  indoor: boolean;
  drive: boolean;
  esferico_min: number | null;
  esferico_max: number | null;
  cilindrico_min: number | null;
  cilindrico_max: number | null;
  adicao_min: number | null;
  adicao_max: number | null;
  diametro: number | null;
  espessura_central: number | null;
  custo_base: number;
  preco_tabela: number;
  preco_fabricante: number | null;
  disponivel: boolean;
  prazo_entrega: number | null;
  obs_prazo: string | null;
  destaque: boolean | null;
  novidade: boolean | null;
  descricao_curta: string | null;
  beneficios: string[] | null;
}

// ============================================================================
// BUSCA INTELIGENTE — RPC legado
// ============================================================================

/** @deprecated Use RpcLensSearchResult */
export interface ResultadoBuscaInteligente {
  id: string;
  nome_comercial: string;
  tipo_lente: string;
  categoria: string;
  material: string;
  indice_refracao: string;
  preco_tabela: number;
  marca_nome: string;
  ar: boolean;
  blue: boolean;
  fotossensivel: string;
  esferico_min: number;
  esferico_max: number;
  cilindrico_min: number;
  cilindrico_max: number;
  match_score: number;
}

// ============================================================================
// TIPOS AUXILIARES PARA O FRONTEND
// ============================================================================

export interface FiltrosLentes {
  ids?: string[];
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
  fornecedores?: string[];
  marca_premium?: boolean;
  graus?: {
    esferico?: number;
    cilindrico?: number;
    adicao?: number;
  };
  // Filtros de Receita
  receita?: {
    esferico: number;
    cilindrico: number;
    adicao?: number;
    tipo?: TipoLente;
  };
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
