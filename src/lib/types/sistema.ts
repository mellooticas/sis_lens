// ============================================================================
// SIS_LENS — Tipos do Sistema
// Versão: 2.0 — Reescrita limpa, alinhada com ecossistema SIS_DIGIAI
// Autor: refatoração automática (eliminação de merge collision)
// ============================================================================
//
// REGRA: Este arquivo NÃO redeclara enums do catálogo de lentes.
// Enums do catálogo (TipoLente, CategoriaLente, MaterialLente etc.)
// são a fonte de verdade em: ./database-views.ts
//
// ============================================================================
// MAPA DE MIGRAÇÃO — BANCO LEGADO → NOVO BANCO (mhgbuplnxtfgipbemchb)
// ============================================================================
//
//  LEGADO (ahcikwsoxhmqqteertkx)        NOVO BANCO
//  ─────────────────────────────────────────────────────────────────────────
//  tabela/view legada                   schema.tabela (migration)
//  ─────────────────────────────────────────────────────────────────────────
//  lens_catalog.lentes                → catalog_lenses.lens_matrices      (010)
//  v_lentes (view)                    → public.v_catalog_lens_matrices    (076)
//  v_grupos_canonicos (view)          → public.v_catalog_lens_groups      (076)
//  vw_canonicas_genericas (view)      → public.v_catalog_lens_groups      (076, is_premium=false)
//  vw_canonicas_premium (view)        → public.v_catalog_lens_groups      (076, is_premium=true)
//  laboratorios (tabela)              → catalog_lenses.suppliers_labs     (010)
//  (sem view pública)                 → public.v_catalog_suppliers_labs   (076)
//  enum material_lente                → catalog_lenses.lens_materials     (010/103)
//  enum tratamento_foto               → catalog_lenses.lens_treatments    (010/103)
//  tenants (tabela)                   → iam.tenants                       (010)
//  usuarios (tabela)                  → iam.users                         (010)
//
//  NOMES DE CAMPOS — PRINCIPAIS MUDANÇAS
//  ─────────────────────────────────────────────────────────────────────────
//  Legado                             Novo
//  ─────────────────────────────────────────────────────────────────────────
//  tipo_lente: 'visao_simples'       → lens_type: 'single_vision'
//  tipo_lente: 'multifocal'          → lens_type: 'multifocal' (igual)
//  tipo_lente: 'bifocal'             → lens_type: 'bifocal' (igual)
//  material: 'policarbonato'         → material: 'polycarbonate'
//  material: 'cr39'                  → material: 'cr39' (igual)
//  material: 'high_index'            → material: 'high_index' (igual)
//  grau_esferico_min/max             → spherical_min / spherical_max
//  grau_cilindrico_min/max           → cylindrical_min / cylindrical_max
//  adicao_min/max                    → addition_min / addition_max
//  preco_venda_sugerido              → base_cost (em lens_matrices)
//  nome_lente                        → name (em lens_groups)
//  ativo (boolean)                   → deleted_at IS NULL (soft delete)
//  is_premium (boolean)              → is_premium (igual)
//
//  ZERO TRUST — PADRÃO NO NOVO BANCO
//  ─────────────────────────────────────────────────────────────────────────
//  LEITURA  → sempre via public.v_* (filtra por JWT tenant_id)
//  ESCRITA  → sempre via public.rpc_* (SECURITY DEFINER, valida tenant)
//  NUNCA    → acesso direto a schemas internos (iam.*, catalog_lenses.*, etc.)
// ============================================================================

// ============================================================================
// TIPOS BASE / UTILITÁRIOS
// ============================================================================

export type UUID = string;
export type TenantId = UUID;
export type UserId = UUID;
export type ISODateString = string;

// ============================================================================
// IDENTIDADE / MULTI-TENANT
// ============================================================================

// NOVO BANCO: iam.tenants (migration 010) → leitura via public.v_iam_tenant (073)
// Campos renomeados: nome → business_name, cnpj → document_cnpj
// tipo (MATRIZ/FILIAL) será modelado em iam.tenants.settings JSONB
// ativo → status: iam.tenant_status ('active' | 'suspended' | 'cancelled')
export interface Tenant {
  id: UUID;
  nome: string;
  tipo: 'MATRIZ' | 'FILIAL' | 'PARCEIRO';
  ativo: boolean;
  configuracoes: TenantConfig;
  created_at: ISODateString;
  updated_at: ISODateString;
}

export interface TenantConfig {
  criterio_padrao: CriterioRanking;
  moeda: string;
  timezone: string;
  configuracoes_comerciais: {
    margem_minima: number;
    desconto_maximo: number;
    prazo_maximo_dias: number;
  };
}

// ============================================================================
// SESSÃO / AUTENTICAÇÃO (via SIS Gateway SSO)
// ============================================================================

// NOVO BANCO: JWT claims injetados por custom_access_token_hook (migration 062)
// Hook: auth.custom_access_token_hook → injeta tenant_id + store_id + role_code
// Leitura segura: public.current_tenant_id() extrai tenant_id do JWT (migration 073)
// Nunca confiar em getSession() sem validar com getUser() — ver hooks.server.ts
export interface Session {
  user_id: UserId;
  tenant_id: TenantId;
  tenant_slug: string;
  permissions: string[];
  expires_at: Date;
}

// NOVO BANCO: iam.users (migration 010) → leitura via public.v_iam_users (073)
// Campos renomeados: nome → full_name, email → email (igual), role → role_code
// ativo → status: iam.user_status ('active' | 'inactive' | 'suspended')
// Escrita: public.rpc_gateway_upsert_user() (migration 076)
export interface Usuario {
  id: UUID;
  tenant_id: TenantId;
  email: string;
  nome: string;
  role: RoleUsuario;
  loja_id?: UUID;
  ativo: boolean;
  created_at: ISODateString;
  updated_at: ISODateString;
}

// NOVO BANCO: role_code é string livre em iam.users/roles_permissions
// Valores comuns: 'admin' | 'manager' | 'seller' | 'optometrist'
export type RoleUsuario = 'ADMIN' | 'GERENTE' | 'VENDEDOR' | 'CLIENTE';

// ============================================================================
// CATÁLOGO — TIPOS DE DOMÍNIO
// (enums de banco estão em database-views.ts)
// ============================================================================

// NOVO BANCO: catalog_lenses.lens_treatments (migration 010/103)
// Leitura: public.v_catalog_lens_treatments (migration 076)
// Não é mais enum fixo — é tabela com {id, tenant_id, name, additional_price, is_active}
// ETL: migration 103 migra enums lens_catalog.tratamento_foto para a tabela
export type TipoTratamento =
  | 'ANTIRREFLEXO'
  | 'BLUE_LIGHT'
  | 'FOTOCROMATICO'
  | 'POLARIZADO'
  | 'HIDROFOBICO'
  | 'OLEOFOBICO'
  | 'UV400';

export interface Tratamento {
  tipo: TipoTratamento;
  marca?: string;
  durabilidade_anos?: number;
}

// NOVO BANCO: campos de geometria estão em catalog_lenses.lens_matrices (migration 010)
// Mapeamento: potencia_minima → spherical_min, potencia_maxima → spherical_max
//             cilindro_maximo → cylindrical_max, passo → step (default 0.25)
//             treatments → JSONB {ar: bool, blue: bool, fotossensivel: string, ...}
//             availability_rules → JSONB com regras de disponibilidade por grau
export interface GeometriaLente {
  curva_base: number;
  diametro_mm: number;
  espessura_centro_mm: number;
  potencia_minima: number;
  potencia_maxima: number;
  cilindro_maximo: number;
}

export interface Marca {
  id: UUID;
  nome: string;
  pais_origem: string;
}

// ============================================================================
// FORNECEDORES / LABORATÓRIOS
// ============================================================================

export interface ContatoComercial {
  nome: string;
  email: string;
  telefone: string;
  whatsapp?: string;
  observacoes?: string;
}

// NOVO BANCO: catalog_lenses.suppliers_labs (migration 010)
// Leitura: public.v_catalog_suppliers_labs (migration 076)
// Campos: id, tenant_id, name, api_endpoint, avg_delivery_days, is_active
// Nota: credibilidade_score não existe no novo schema — modelar em settings JSONB do tenant
// Escrita: sem RPC específico ainda — virá em futuras migrations de catalog_lenses
export interface Laboratorio {
  id: UUID;
  tenant_id: TenantId;
  nome: string;
  cnpj: string;
  endereco: Record<string, unknown>;
  contato: ContatoComercial | Record<string, unknown>;
  credibilidade_score: number;
  ativo: boolean;
}

export interface ProdutoLaboratorio {
  id: UUID;
  tenant_id: TenantId;
  laboratorio_id: UUID;
  lente_id: UUID;
  sku_fantasia: string;
  nome_comercial: string;
  disponivel: boolean;
  descontinuado: boolean;
  // Relations
  laboratorio?: Laboratorio;
}

// ============================================================================
// RANKING E DECISÃO DE COMPRA
// ============================================================================

// NOVO BANCO: production.priority_level (migration 002)
// Mapeamento: 'NORMAL' → 'normal', 'URGENCIA' → 'urgent', 'ESPECIAL' → 'high'
// Usado em production.service_orders.priority
export type CriterioRanking = 'NORMAL' | 'URGENCIA' | 'ESPECIAL';

export interface FiltrosRanking {
  preco_maximo?: number;
  prazo_maximo_dias?: number;
  tratamentos_obrigatorios?: string[];
  laboratorios_preferidos?: UUID[];
  score_minimo?: number;
}

export interface OpcaoRanking {
  laboratorio_id: UUID;
  laboratorio_nome: string;
  sku_fantasia: string;
  preco_final: number;
  prazo_dias: number;
  custo_frete: number;
  score_qualidade: number;
  score_ponderado: number;
  rank_posicao: number;
  justificativa: string;
}

export interface AlternativaDecisao {
  laboratorio_nome: string;
  preco_final: number;
  prazo_dias: number;
  score_atribuido: number;
  motivo_descarte: string;
}

// NOVO BANCO: production.kanban_status (migration 002)
// Mapeamento: 'DECIDIDO' → 'registered', 'ENVIADO' → 'dispatched',
//             'CONFIRMADO' → 'production', 'ENTREGUE' → 'delivered'
// Leitura: public.v_production_service_orders (migration 073)
// Escrita: public.rpc_production_update_service_order_stage() (migration 076)
export type StatusDecisao = 'DECIDIDO' | 'ENVIADO' | 'CONFIRMADO' | 'ENTREGUE';

// NOVO BANCO: payload de entrada para public.rpc_production_create_service_order() (migration 076)
// O novo RPC recebe um JSONB consolidado em vez de campos separados
export interface PayloadDecisao {
  lente_id: UUID;
  laboratorio_id: UUID;
  produto_lab_id: UUID;
  criterio: CriterioDecisao;
  preco_final: number;
  prazo_estimado_dias: number;
  custo_frete: number;
  score_atribuido: number;
  motivo: string;
  alternativas: AlternativaDecisao[];
}

export interface DecisaoCompra {
  id: UUID;
  tenant_id: TenantId;
  lente_id: UUID;
  laboratorio_id: UUID;
  produto_lab_id: UUID;
  criterio: CriterioRanking;
  preco_final: number;
  prazo_estimado_dias: number;
  custo_frete: number;
  score_atribuido: number;
  motivo: string;
  alternativas_consideradas: AlternativaDecisao[];
  decidido_por: UserId;
  decidido_em: ISODateString;
  status: StatusDecisao;
  payload_decisao: Record<string, unknown>;
  observacoes?: string;
}

export interface ScoringConfig {
  tenant_id: TenantId;
  criterio: CriterioRanking;
  peso_preco: number;
  peso_prazo: number;
  peso_qualidade: number;
  algoritmo: AlgoritmoScoring;
  parametros: Record<string, unknown>;
  ativo: boolean;
  updated_at: ISODateString;
}

export type AlgoritmoScoring = 'WEIGHTED_SUM' | 'MULTIPLICATIVO' | 'TOPSIS' | 'PERSONALIZADO';

export interface MetricasFornecedor {
  laboratorio_id: UUID;
  periodo: string; // YYYY-MM
  total_decisoes: number;
  valor_total: number;
  economia_gerada: number;
  prazo_medio_cumprido: number;
  taxa_preferencia: number;
  qualidade_media: number;
  reclamacoes: number;
  score_periodo: number;
}

// ============================================================================
// REQUEST / RESPONSE — API
// ============================================================================

export interface BuscaLenteRequest {
  query: string;
  filtros?: FiltrosRanking;
  limit?: number;
}

export interface BuscaLenteResult {
  lente_id: UUID;
  label: string;
  sku_fantasia: string;
}

export interface FiltrosBusca {
  usuario_id?: string | null;
  graduacao_de?: number | null;
  graduacao_ate?: number | null;
  tipo_lente?: string | null;
  material?: string | null;
  tratamentos?: string[];
  faixa_preco_min?: number | null;
  faixa_preco_max?: number | null;
  ordenacao?: 'preco_asc' | 'preco_desc' | 'prazo_asc' | 'score_desc';
}

export interface RankingRequest {
  lente_id: UUID;
  criterio: CriterioRanking;
  filtros?: FiltrosRanking;
}

export interface RankingResponse {
  opcoes: OpcaoRanking[];
  criterio_usado: CriterioRanking;
  filtros_aplicados: FiltrosRanking;
  metadata: {
    total_opcoes: number;
    tempo_processamento_ms: number;
    cache_hit: boolean;
  };
}

export interface ConfirmarDecisaoRequest {
  lente_id: UUID;
  opcao_escolhida_id: UUID;
  criterio: CriterioRanking;
  filtros: FiltrosRanking;
  observacoes?: string;
}

export interface ConfirmarDecisaoResponse {
  decisao: DecisaoCompra;
  economia_estimada: number;
  proximos_passos: string[];
}

// ============================================================================
// DASHBOARD / ANALYTICS
// ============================================================================

export interface DashboardMetrics {
  periodo: string;
  total_decisoes: number;
  economia_total: number;
  economia_media_por_decisao: number;
  laboratorio_mais_escolhido: {
    nome: string;
    percentual: number;
  };
  criterio_mais_usado: CriterioRanking;
  tendencias: {
    decisoes_mes_anterior: number;
    economia_mes_anterior: number;
    crescimento_decisoes: number;
    crescimento_economia: number;
  };
}

// ============================================================================
// ENDEREÇO / LOJA
// ============================================================================

export interface Endereco {
  logradouro: string;
  numero: string;
  complemento?: string;
  bairro: string;
  cidade: string;
  estado: string;
  cep: string;
  pais: string;
}

export interface ContatoLoja {
  telefone: string;
  whatsapp?: string;
  email: string;
  site?: string;
}

export interface ConfiguracaoLoja {
  desconto_maximo_percentual: number;
  valor_maximo_voucher: number;
  permite_voucher_personalizado: boolean;
  tipos_voucher_permitidos: TipoVoucher[];
}

export interface Loja {
  id: UUID;
  tenant_id: TenantId;
  nome: string;
  cnpj: string;
  endereco: Endereco;
  contato: ContatoLoja;
  configuracoes: ConfiguracaoLoja;
  ativa: boolean;
  created_at: ISODateString;
  updated_at: ISODateString;
}

export interface Cliente {
  id: UUID;
  tenant_id: TenantId;
  nome: string;
  cpf: string;
  telefone: string;
  email?: string;
  data_nascimento?: ISODateString;
  endereco?: Endereco;
  loja_preferida_id?: UUID;
  ativo: boolean;
  created_at: ISODateString;
  updated_at: ISODateString;
}

// ============================================================================
// VOUCHERS (mantido para compatibilidade — módulo pausado)
// ============================================================================

export type TipoVoucher = 'FIXO' | 'PERCENTUAL' | 'FRETE_GRATIS' | 'COMBO';

export interface Voucher {
  id: UUID;
  tenant_id: TenantId;
  codigo: string;
  nome: string;
  descricao?: string;
  tipo: TipoVoucher;
  valor_desconto?: number;
  percentual_desconto?: number;
  valor_minimo_compra?: number;
  valor_maximo_desconto?: number;
  data_inicio: ISODateString;
  data_fim: ISODateString;
  limite_uso_total?: number;
  limite_uso_por_cliente?: number;
  usos_realizados: number;
  ativo: boolean;
  created_at: ISODateString;
  updated_at: ISODateString;
}

// ============================================================================
// ERROS / RESPOSTAS GENÉRICAS
// ============================================================================

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
  timestamp: string;
}

export interface DatabaseError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

export interface ValidationError {
  field: string;
  message: string;
  code: string;
}

export interface ApiResponse<T> {
  data?: T;
  error?: ApiError;
  meta?: {
    total?: number;
    page?: number;
    per_page?: number;
  };
}

// ============================================================================
// FORMULÁRIOS
// ============================================================================

export interface FormBuscaLente {
  query: string;
  material?: string;
  indice_refracao?: number;
  tratamentos?: string[];
  tipo_lente?: string;
}

// ============================================================================
// UTILITÁRIOS
// ============================================================================

export type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
export type RequiredFields<T, K extends keyof T> = T & Required<Pick<T, K>>;

export interface PaginationParams {
  page: number;
  limit: number;
  order_by?: string;
  order_direction?: 'asc' | 'desc';
}

export interface SortableColumn {
  key: string;
  label: string;
  sortable: boolean;
  type?: 'string' | 'number' | 'date' | 'currency';
}

// ============================================================================
// ALIASES DE COMPATIBILIDADE LEGADA
// ============================================================================

/** @deprecated Use CriterioRanking */
export type CriterioDecisao = CriterioRanking;
/** @deprecated Use CriterioRanking */
export type Criterio = CriterioRanking;
export type TipoLogistica = 'EXPRESSO' | 'NORMAL' | 'ECONOMICO';
