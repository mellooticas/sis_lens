/**/**// ============================================================================

 * Tipos do Sistema Decisor de Lentes

 * Baseado no Blueprint Completo * Tipos do Sistema Decisor de Lentes// TYPES - SISTEMA DECISOR DE LENTES COMPLETO

 */

 * Baseado no Blueprint Completo// Tipos TypeScript derivados do blueprint e schema do banco

// ============================================================================

// TIPOS BASE DO SISTEMA */// ============================================================================

// ============================================================================



export interface Tenant {

  id: string;// ============================================================================// Base types

  nome: string;

  tipo: 'MATRIZ' | 'FILIAL' | 'PARCEIRO';// TIPOS BASE DO SISTEMAexport type UUID = string;

  ativo: boolean;

  configuracoes: TenantConfig;// ============================================================================export type TenantId = UUID;

  created_at: string;

  updated_at: string;export type UserId = UUID;

}

export interface Tenant {

export interface TenantConfig {

  criterio_padrao: CriterioRanking;  id: string;// Enums conforme blueprint

  moeda: string;

  timezone: string;  nome: string;export type TipoLente = 'monofocal' | 'bifocal' | 'progressiva';

  configuracoes_comerciais: {

    margem_minima: number;  tipo: 'MATRIZ' | 'FILIAL' | 'PARCEIRO';export type CriterioDecisao = 'URGENCIA' | 'NORMAL' | 'ESPECIAL';

    desconto_maximo: number;

    prazo_maximo_dias: number;  ativo: boolean;export type StatusDecisao = 'DECIDIDO' | 'ENVIADO' | 'CONFIRMADO' | 'ENTREGUE';

  };

}  configuracoes: TenantConfig;export type TipoLogistica = 'EXPRESSO' | 'NORMAL' | 'ECONOMICO';



// ============================================================================  created_at: string;

// CATÁLOGO DE LENTES (CANÔNICO)

// ============================================================================  updated_at: string;// Legacy support (manter compatibilidade)



export interface LenteCanonica {}export type Criterio = CriterioDecisao;

  id: string;

  tenant_id: string;

  sku_canonico: string;

  nome_comercial: string;export interface TenantConfig {// ============================================================================

  marca_id: string;

  categoria: CategoriaLente;  criterio_padrao: CriterioRanking;// LENS CATALOG DOMAIN

  material: MaterialLente;

  indice_refracao: number;  moeda: string;// ============================================================================

  tratamentos: Tratamento[];

  geometria: GeometriaLente;  timezone: string;

  status: StatusLente;

  created_at: string;  configuracoes_comerciais: {export interface Marca {

  updated_at: string;

}    margem_minima: number;  id: UUID;



export type CategoriaLente =     desconto_maximo: number;  nome: string;

  | 'MONOFOCAL' 

  | 'BIFOCAL'     prazo_maximo_dias: number;  pais_origem: string;

  | 'MULTIFOCAL' 

  | 'PROGRESSIVA'   };}

  | 'OCUPACIONAL';

}

export type MaterialLente = 

  | 'POLICARBONATO' export interface Lente {

  | 'TRIVEX' 

  | 'CR39' // ============================================================================  id: UUID;

  | 'ALTO_INDICE' 

  | 'VIDRO';// CATÁLOGO DE LENTES (CANÔNICO)  tenant_id: TenantId;



export interface Tratamento {// ============================================================================  sku_canonico: string;

  tipo: TipoTratamento;

  marca?: string;  marca_id: UUID;

  durabilidade_anos?: number;

}export interface LenteCanonica {  familia: string;



export type TipoTratamento =   id: string;  design: string;

  | 'ANTIRREFLEXO' 

  | 'BLUE_LIGHT'   tenant_id: string;  material: string;

  | 'FOTOCROMATICO' 

  | 'POLARIZADO'   sku_canonico: string;  indice_refracao: number;

  | 'HIDROFOBICO' 

  | 'OLEOFOBICO'   nome_comercial: string;  tratamentos: string[];

  | 'UV400';

  marca_id: string;  tipo_lente: TipoLente;

export interface GeometriaLente {

  curva_base: number;  categoria: CategoriaLente;  corredor_progressao?: number;

  diametro_mm: number;

  espessura_centro_mm: number;  material: MaterialLente;  specs_tecnicas: Record<string, any>;

  potencia_minima: number;

  potencia_maxima: number;  indice_refracao: number;  ativo: boolean;

  cilindro_maximo: number;

}  tratamentos: Tratamento[];  



export type StatusLente = 'ATIVO' | 'DESCONTINUADO' | 'EM_DESENVOLVIMENTO';  geometria: GeometriaLente;  // Relations (computed)



// ============================================================================  status: StatusLente;  marca?: Marca;

// FORNECEDORES E LABORATÓRIOS

// ============================================================================  created_at: string;  



export interface Laboratorio {  updated_at: string;  // Legacy fields (computed)

  id: string;

  tenant_id: string;}  sku_fantasia?: string;

  nome: string;

  nome_fantasia: string;  marca_nome?: string;

  cnpj?: string;

  contato_comercial: ContatoComercial;export type CategoriaLente =   descricao_completa?: string;

  lead_time_padrao_dias: number;

  atende_regioes: string[];  | 'MONOFOCAL' }

  qualidade_base: number; // 1-5

  ativo: boolean;  | 'BIFOCAL' 

  created_at: string;

  updated_at: string;  | 'MULTIFOCAL' // ============================================================================

}

  | 'PROGRESSIVA' // SUPPLIERS DOMAIN

export interface ContatoComercial {

  nome: string;  | 'OCUPACIONAL';// ============================================================================

  email: string;

  telefone: string;

  whatsapp?: string;

  observacoes?: string;export type MaterialLente = export interface Laboratorio {

}

  | 'POLICARBONATO'   id: UUID;

export interface ProdutoLaboratorio {

  id: string;  | 'TRIVEX'   tenant_id: TenantId;

  tenant_id: string;

  laboratorio_id: string;  | 'CR39'   nome: string;

  sku_laboratorio: string;

  nome_comercial: string;  | 'ALTO_INDICE'   cnpj: string;

  sku_fantasia: string;

  lente_id: string; // FK para LenteCanonica  | 'VIDRO';  endereco: Record<string, any>;

  qualidade_base: number;

  disponivel: boolean;  contato: Record<string, any>;

  descontinuado_em?: string;

  created_at: string;export interface Tratamento {  credibilidade_score: number;

  updated_at: string;

}  tipo: TipoTratamento;  ativo: boolean;



// ============================================================================  marca?: string;}

// SISTEMA COMERCIAL E PREÇOS

// ============================================================================  durabilidade_anos?: number;



export interface TabelaPreco {}export interface ProdutoLaboratorio {

  id: string;

  tenant_id: string;  id: UUID;

  laboratorio_id: string;

  nome: string;export type TipoTratamento =   tenant_id: TenantId;

  vigencia_inicio: string;

  vigencia_fim?: string;  | 'ANTIRREFLEXO'   laboratorio_id: UUID;

  ativa: boolean;

  observacoes?: string;  | 'BLUE_LIGHT'   lente_id: UUID;

  created_at: string;

  updated_at: string;  | 'FOTOCROMATICO'   sku_fantasia: string;

}

  | 'POLARIZADO'   nome_comercial: string;

export interface PrecoLente {

  id: string;  | 'HIDROFOBICO'   disponivel: boolean;

  tenant_id: string;

  tabela_preco_id: string;  | 'OLEOFOBICO'   descontinuado: boolean;

  produto_laboratorio_id: string;

  preco_base: number;  | 'UV400';  

  moeda: string;

  unidade: string;  // Relations

  margem_sugerida?: number;

  observacoes?: string;export interface GeometriaLente {  laboratorio?: Laboratorio;

  created_at: string;

  updated_at: string;  curva_base: number;  lente?: Lente;

}

  diametro_mm: number;}

export interface RegraDesconto {

  id: string;  espessura_centro_mm: number;

  tenant_id: string;

  nome: string;  potencia_minima: number;// ============================================================================

  tipo: TipoDesconto;

  escopo: EscopoDesconto;  potencia_maxima: number;// API RESPONSE TYPES (conforme blueprint)

  escopo_id?: string;

  desconto_percentual?: number;  cilindro_maximo: number;// ============================================================================

  desconto_fixo?: number;

  vigencia_inicio: string;}

  vigencia_fim?: string;

  ativa: boolean;export interface OpcaoRanking {

  prioridade: number;

  created_at: string;export type StatusLente = 'ATIVO' | 'DESCONTINUADO' | 'EM_DESENVOLVIMENTO';  laboratorio_id: UUID;

  updated_at: string;

}  laboratorio_nome: string;



export type TipoDesconto = 'PERCENTUAL' | 'FIXO' | 'ESCALONADO';// ============================================================================  sku_fantasia: string;

export type EscopoDesconto = 'LABORATORIO' | 'MARCA' | 'PRODUTO';

// FORNECEDORES E LABORATÓRIOS  preco_final: number;

// ============================================================================

// SISTEMA DE RANKING E DECISÕES// ============================================================================  prazo_dias: number;

// ============================================================================

  custo_frete: number;

export type CriterioRanking = 'NORMAL' | 'URGENCIA' | 'ESPECIAL';

export interface Laboratorio {  score_qualidade: number;

export interface FiltrosRanking {

  indice_refracao?: number[];  id: string;  score_ponderado: number;

  tratamentos?: TipoTratamento[];

  categoria?: CategoriaLente[];  tenant_id: string;  rank_posicao: number;

  material?: MaterialLente[];

  faixa_preco?: {  nome: string;  justificativa: string;

    min: number;

    max: number;  nome_fantasia: string;}

  };

  prazo_maximo_dias?: number;  cnpj?: string;

  laboratorios_preferidos?: string[];

  laboratorios_excluidos?: string[];  contato_comercial: ContatoComercial;export interface AlternativaDecisao {

  regioes?: string[];

}  lead_time_padrao_dias: number;  laboratorio_nome: string;



export interface OpcaoRanking {  atende_regioes: string[];  preco_final: number;

  id: string;

  lente_id: string;  qualidade_base: number; // 1-5  prazo_dias: number;

  laboratorio_id: string;

  produto_laboratorio_id: string;  ativo: boolean;  score_atribuido: number;

  score_total: number;

  score_preco: number;  created_at: string;  motivo_descarte: string;

  score_prazo: number;

  score_qualidade: number;  updated_at: string;}

  preco_final: number;

  prazo_dias: number;}

  economia_estimada: number;

  percentual_economia: number;export interface DecisaoCompra {

  observacoes?: string;

  // Dados denormalizados para UIexport interface ContatoComercial {  id: UUID;

  lente_nome: string;

  laboratorio_nome: string;  nome: string;  tenant_id: TenantId;

  sku_fantasia: string;

}  email: string;  lente_id: UUID;



export interface DecisaoCompra {  telefone: string;  laboratorio_id: UUID;

  id: string;

  tenant_id: string;  whatsapp?: string;  produto_lab_id: UUID;

  usuario_id: string;

  lente_id: string;  observacoes?: string;  criterio: CriterioDecisao;

  opcao_escolhida_id: string;

  criterio_usado: CriterioRanking;}  preco_final: number;

  filtros_aplicados: FiltrosRanking;

  observacoes?: string;  prazo_estimado_dias: number;

  status: StatusDecisao;

  created_at: string;export interface ProdutoLaboratorio {  custo_frete: number;

  updated_at: string;

  // Relacionamentos  id: string;  score_atribuido: number;

  opcao_escolhida: OpcaoRanking;

  alternativas_consideradas: OpcaoRanking[];  tenant_id: string;  motivo: string;

}

  laboratorio_id: string;  alternativas_consideradas: AlternativaDecisao[];

export type StatusDecisao = 'PENDENTE' | 'CONFIRMADA' | 'CANCELADA' | 'EM_PRODUCAO' | 'ENTREGUE';

  sku_laboratorio: string;  decidido_por: UserId;

// ============================================================================

// SISTEMA DE VOUCHERS (HÍBRIDO)  nome_comercial: string;  decidido_em: Date;

// ============================================================================

  sku_fantasia: string;  status: StatusDecisao;

export interface Usuario {

  id: string;  lente_id: string; // FK para LenteCanonica  payload_decisao: Record<string, any>;

  tenant_id: string;

  email: string;  qualidade_base: number;  

  nome: string;

  role: RoleUsuario;  disponivel: boolean;  // Relations

  loja_id?: string;

  ativo: boolean;  descontinuado_em?: string;  lente?: Lente;

  created_at: string;

  updated_at: string;  created_at: string;  laboratorio?: Laboratorio;

}

  updated_at: string;  produto_lab?: ProdutoLaboratorio;

export type RoleUsuario = 'ADMIN' | 'GERENTE' | 'VENDEDOR' | 'CLIENTE';

}}

export interface Loja {

  id: string;

  tenant_id: string;

  nome: string;// ============================================================================// ============================================================================

  cnpj: string;

  endereco: Endereco;// SISTEMA COMERCIAL E PREÇOS// FORM & FILTER TYPES

  contato: ContatoLoja;

  configuracoes: ConfiguracaoLoja;// ============================================================================// ============================================================================

  ativa: boolean;

  created_at: string;

  updated_at: string;

}export interface TabelaPreco {export interface FiltrosRanking {



export interface Endereco {  id: string;  preco_maximo?: number;

  logradouro: string;

  numero: string;  tenant_id: string;  prazo_maximo_dias?: number;

  complemento?: string;

  bairro: string;  laboratorio_id: string;  tratamentos_obrigatorios?: string[];

  cidade: string;

  estado: string;  nome: string;  laboratorios_preferidos?: UUID[];

  cep: string;

  pais: string;  vigencia_inicio: string;  score_minimo?: number;

}

  vigencia_fim?: string;  

export interface ContatoLoja {

  telefone: string;  ativa: boolean;  // Legacy support

  whatsapp?: string;

  email: string;  observacoes?: string;  regiao?: string;

  site?: string;

}  created_at: string;  prazo_maximo?: number;



export interface ConfiguracaoLoja {  updated_at: string;}

  desconto_maximo_percentual: number;

  valor_maximo_voucher: number;}

  permite_voucher_personalizado: boolean;

  tipos_voucher_permitidos: TipoVoucher[];export interface PayloadDecisao {

}

export interface PrecoLente {  lente_id: UUID;

export interface Cliente {

  id: string;  id: string;  laboratorio_id: UUID;

  tenant_id: string;

  nome: string;  tenant_id: string;  produto_lab_id: UUID;

  cpf: string;

  telefone: string;  tabela_preco_id: string;  criterio: CriterioDecisao;

  email?: string;

  data_nascimento?: string;  produto_laboratorio_id: string;  preco_final: number;

  endereco?: Endereco;

  loja_preferida_id?: string;  preco_base: number;  prazo_estimado_dias: number;

  ativo: boolean;

  created_at: string;  moeda: string;  custo_frete: number;

  updated_at: string;

}  unidade: string;  score_atribuido: number;



export interface Voucher {  margem_sugerida?: number;  motivo: string;

  id: string;

  tenant_id: string;  observacoes?: string;  alternativas: AlternativaDecisao[];

  codigo: string;

  nome: string;  created_at: string;}

  descricao?: string;

  tipo: TipoVoucher;  updated_at: string;

  valor_desconto?: number;

  percentual_desconto?: number;}export interface BuscaLenteResult {

  valor_minimo_compra?: number;

  valor_maximo_desconto?: number;  lente_id: UUID;

  data_inicio: string;

  data_fim: string;export interface RegraDesconto {  label: string; // Ex: "Varilux X Series 1.67 HC+AR+Blue"

  limite_uso_total?: number;

  limite_uso_por_cliente?: number;  id: string;  sku_fantasia: string;

  usos_realizados: number;

  ativo: boolean;  tenant_id: string;}

  created_at: string;

  updated_at: string;  nome: string;

}

  tipo: TipoDesconto;export interface FormBuscaLente {

export type TipoVoucher = 'FIXO' | 'PERCENTUAL' | 'FRETE_GRATIS' | 'COMBO';

  escopo: EscopoDesconto;  query: string;

export interface UsoVoucher {

  id: string;  escopo_id?: string;  material?: string;

  tenant_id: string;

  voucher_id: string;  desconto_percentual?: number;  indice_refracao?: number;

  cliente_id: string;

  usuario_id: string; // quem aplicou  desconto_fixo?: number;  tratamentos?: string[];

  valor_original: number;

  valor_desconto: number;  vigencia_inicio: string;  tipo_lente?: TipoLente;

  valor_final: number;

  data_uso: string;  vigencia_fim?: string;}

  observacoes?: string;

  created_at: string;  ativa: boolean;

}

  prioridade: number;// ============================================================================

// ============================================================================

// TIPOS PARA API E FRONTEND  created_at: string;// UTILITY TYPES

// ============================================================================

  updated_at: string;// ============================================================================

export interface BuscaLenteRequest {

  query: string;}

  filtros?: FiltrosRanking;

  limit?: number;export interface ApiResponse<T> {

}

export type TipoDesconto = 'PERCENTUAL' | 'FIXO' | 'ESCALONADO';  data?: T;

export interface BuscaLenteResponse {

  lentes: LenteCanonica[];export type EscopoDesconto = 'LABORATORIO' | 'MARCA' | 'PRODUTO';  error?: string;

  total: number;

  sugestoes?: string[];  meta?: {

}

// ============================================================================    total?: number;

export interface RankingRequest {

  lente_id: string;// SISTEMA DE RANKING E DECISÕES    page?: number;

  criterio: CriterioRanking;

  filtros?: FiltrosRanking;// ============================================================================    per_page?: number;

}

  };

export interface RankingResponse {

  lente: LenteCanonica;export type CriterioRanking = 'NORMAL' | 'URGENCIA' | 'ESPECIAL';}

  opcoes: OpcaoRanking[];

  criterio_usado: CriterioRanking;

  filtros_aplicados: FiltrosRanking;

  metadata: {export interface FiltrosRanking {export interface Session {

    total_opcoes: number;

    tempo_processamento_ms: number;  indice_refracao?: number[];  user_id: UserId;

    cache_hit: boolean;

  };  tratamentos?: TipoTratamento[];  tenant_id: TenantId;

}

  categoria?: CategoriaLente[];  tenant_slug: string;

export interface ConfirmarDecisaoRequest {

  lente_id: string;  material?: MaterialLente[];  permissions: string[];

  opcao_escolhida_id: string;

  criterio: CriterioRanking;  faixa_preco?: {  expires_at: Date;

  filtros: FiltrosRanking;

  observacoes?: string;    min: number;}

}

    max: number;

export interface ConfirmarDecisaoResponse {

  decisao: DecisaoCompra;  };export interface DatabaseError {

  economia_estimada: number;

  proximos_passos: string[];  prazo_maximo_dias?: number;  code: string;

}

  laboratorios_preferidos?: string[];  message: string;

// ============================================================================

// TIPOS PARA ERROS E RESPOSTAS API  laboratorios_excluidos?: string[];  details?: Record<string, any>;

// ============================================================================

  regioes?: string[];}

export interface ApiError {

  code: string;}

  message: string;

  details?: Record<string, any>;export interface ValidationError {

  timestamp: string;

}export interface OpcaoRanking {  field: string;



export interface ApiResponse<T> {  id: string;  message: string;

  data?: T;

  error?: ApiError;  lente_id: string;  code: string;

  metadata?: {

    total?: number;  laboratorio_id: string;}

    page?: number;

    limit?: number;  produto_laboratorio_id: string;

    has_more?: boolean;

  };  score_total: number;// ============================================================================

}

  score_preco: number;// FORM TYPES

// ============================================================================

// TIPOS PARA FORMULÁRIOS E VALIDAÇÃO  score_prazo: number;// ============================================================================

// ============================================================================

  score_qualidade: number;

export interface FormBuscaLente {

  query: string;  preco_final: number;export interface FiltrosBusca {

  indice_refracao?: number;

  categoria?: CategoriaLente;  prazo_dias: number;  usuario_id?: string | null;

  tratamentos?: TipoTratamento[];

  preco_maximo?: number;  economia_estimada: number;  graduacao_de?: number | null;

  prazo_maximo?: number;

}  percentual_economia: number;  graduacao_ate?: number | null;



export interface FormCriarVoucher {  observacoes?: string;  tipo_lente?: TipoLente | null;

  nome: string;

  descricao?: string;  // Dados denormalizados para UI  material?: string | null;

  tipo: TipoVoucher;

  valor_desconto?: number;  lente_nome: string;  tratamentos?: string[];

  percentual_desconto?: number;

  data_inicio: string;  laboratorio_nome: string;  faixa_preco_min?: number | null;

  data_fim: string;

  limite_uso_total?: number;  sku_fantasia: string;  faixa_preco_max?: number | null;

  ativo: boolean;

}}  ordenacao?: 'preco_asc' | 'preco_desc' | 'prazo_asc' | 'score_desc';



// ============================================================================}

// TIPOS UTILITÁRIOS

// ============================================================================export interface DecisaoCompra {



export type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;  id: string;// ============================================================================

export type RequiredFields<T, K extends keyof T> = T & Required<Pick<T, K>>;

  tenant_id: string;// LEGACY COMPATIBILITY

export interface PaginationParams {

  page: number;  usuario_id: string;// ============================================================================

  limit: number;

  order_by?: string;  lente_id: string;

  order_direction?: 'asc' | 'desc';

}  opcao_escolhida_id: string;export interface Decisao {



export interface SortableColumn {  criterio_usado: CriterioRanking;  id: string;

  key: string;

  label: string;  filtros_aplicados: FiltrosRanking;  lente_id: string;

  sortable: boolean;

  type?: 'string' | 'number' | 'date' | 'currency';  observacoes?: string;  laboratorio_id: string;

}

  status: StatusDecisao;  criterio: Criterio;

// ============================================================================

// TIPOS LEGADOS (COMPATIBILIDADE)  created_at: string;  preco_final: number;

// ============================================================================

  updated_at: string;  prazo_estimado_dias: number;

// Manter compatibilidade com código existente

export type UUID = string;  // Relacionamentos  custo_frete: number;

export type TenantId = UUID;

export type UserId = UUID;  opcao_escolhida: OpcaoRanking;  score_atribuido: number;

export type TipoLente = CategoriaLente;

export type CriterioDecisao = CriterioRanking;  alternativas_consideradas: OpcaoRanking[];  motivo: string;

export type Criterio = CriterioRanking;

export type TipoLogistica = 'EXPRESSO' | 'NORMAL' | 'ECONOMICO';}  decidido_em: string; // Legacy format as string

  status: string;

export type StatusDecisao = 'PENDENTE' | 'CONFIRMADA' | 'CANCELADA' | 'EM_PRODUCAO' | 'ENTREGUE';}

// ============================================================================
// SISTEMA DE SCORING E ANALYTICS
// ============================================================================

export interface ScoringConfig {
  tenant_id: string;
  criterio: CriterioRanking;
  peso_preco: number;
  peso_prazo: number;
  peso_qualidade: number;
  algoritmo: AlgoritmoScoring;
  parametros: Record<string, any>;
  ativo: boolean;
  updated_at: string;
}

export type AlgoritmoScoring = 'WEIGHTED_SUM' | 'MULTIPLICATIVO' | 'TOPSIS' | 'PERSONALIZADO';

export interface MetricasFornecedor {
  laboratorio_id: string;
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
// SISTEMA DE VOUCHERS (HÍBRIDO)
// ============================================================================

export interface Usuario {
  id: string;
  tenant_id: string;
  email: string;
  nome: string;
  role: RoleUsuario;
  loja_id?: string;
  ativo: boolean;
  created_at: string;
  updated_at: string;
}

export type RoleUsuario = 'ADMIN' | 'GERENTE' | 'VENDEDOR' | 'CLIENTE';

export interface Loja {
  id: string;
  tenant_id: string;
  nome: string;
  cnpj: string;
  endereco: Endereco;
  contato: ContatoLoja;
  configuracoes: ConfiguracaoLoja;
  ativa: boolean;
  created_at: string;
  updated_at: string;
}

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

export interface Cliente {
  id: string;
  tenant_id: string;
  nome: string;
  cpf: string;
  telefone: string;
  email?: string;
  data_nascimento?: string;
  endereco?: Endereco;
  loja_preferida_id?: string;
  ativo: boolean;
  created_at: string;
  updated_at: string;
}

export interface Voucher {
  id: string;
  tenant_id: string;
  codigo: string;
  nome: string;
  descricao?: string;
  tipo: TipoVoucher;
  valor_desconto?: number;
  percentual_desconto?: number;
  valor_minimo_compra?: number;
  valor_maximo_desconto?: number;
  data_inicio: string;
  data_fim: string;
  limite_uso_total?: number;
  limite_uso_por_cliente?: number;
  usos_realizados: number;
  ativo: boolean;
  created_at: string;
  updated_at: string;
}

export type TipoVoucher = 'FIXO' | 'PERCENTUAL' | 'FRETE_GRATIS' | 'COMBO';

export interface UsoVoucher {
  id: string;
  tenant_id: string;
  voucher_id: string;
  cliente_id: string;
  usuario_id: string; // quem aplicou
  valor_original: number;
  valor_desconto: number;
  valor_final: number;
  data_uso: string;
  observacoes?: string;
  created_at: string;
}

// ============================================================================
// TIPOS PARA API E FRONTEND
// ============================================================================

export interface BuscaLenteRequest {
  query: string;
  filtros?: FiltrosRanking;
  limit?: number;
}

export interface BuscaLenteResponse {
  lentes: LenteCanonica[];
  total: number;
  sugestoes?: string[];
}

export interface RankingRequest {
  lente_id: string;
  criterio: CriterioRanking;
  filtros?: FiltrosRanking;
}

export interface RankingResponse {
  lente: LenteCanonica;
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
  lente_id: string;
  opcao_escolhida_id: string;
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
// TIPOS PARA DASHBOARD E ANALYTICS
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

export interface RelatorioVouchers {
  periodo: string;
  total_vouchers_emitidos: number;
  total_vouchers_utilizados: number;
  taxa_utilizacao: number;
  economia_gerada_vouchers: number;
  valor_medio_voucher: number;
  top_tipos_voucher: Array<{
    tipo: TipoVoucher;
    quantidade: number;
    percentual: number;
  }>;
}

// ============================================================================
// TIPOS PARA FORMULÁRIOS E VALIDAÇÃO
// ============================================================================

export interface FormBuscaLente {
  query: string;
  indice_refracao?: number;
  categoria?: CategoriaLente;
  tratamentos?: TipoTratamento[];
  preco_maximo?: number;
  prazo_maximo?: number;
}

export interface FormCriarVoucher {
  nome: string;
  descricao?: string;
  tipo: TipoVoucher;
  valor_desconto?: number;
  percentual_desconto?: number;
  data_inicio: string;
  data_fim: string;
  limite_uso_total?: number;
  ativo: boolean;
}

// ============================================================================
// TIPOS PARA ERROS E RESPOSTAS API
// ============================================================================

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
  timestamp: string;
}

export interface ApiResponse<T> {
  data?: T;
  error?: ApiError;
  metadata?: {
    total?: number;
    page?: number;
    limit?: number;
    has_more?: boolean;
  };
}

// ============================================================================
// TIPOS UTILITÁRIOS
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
// TIPOS LEGADOS (COMPATIBILIDADE)
// ============================================================================

// Manter compatibilidade com código existente
export type UUID = string;
export type TenantId = UUID;
export type UserId = UUID;
export type TipoLente = CategoriaLente;
export type CriterioDecisao = CriterioRanking;
export type Criterio = CriterioRanking;
export type TipoLogistica = 'EXPRESSO' | 'NORMAL' | 'ECONOMICO';