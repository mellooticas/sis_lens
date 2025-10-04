/**// ============================================================================

 * Types Index// TYPES - SISTEMA DECISOR DE LENTES COMPLETO

 * Ponto central para todos os tipos TypeScript// Tipos TypeScript derivados do blueprint e schema do banco

 */// ============================================================================



export * from './sistema';// Base types

export * from './database';export type UUID = string;
export type TenantId = UUID;
export type UserId = UUID;

// Enums conforme blueprint
export type TipoLente = 'monofocal' | 'bifocal' | 'progressiva';
export type CriterioDecisao = 'URGENCIA' | 'NORMAL' | 'ESPECIAL';
export type StatusDecisao = 'DECIDIDO' | 'ENVIADO' | 'CONFIRMADO' | 'ENTREGUE';
export type TipoLogistica = 'EXPRESSO' | 'NORMAL' | 'ECONOMICO';

// Legacy support (manter compatibilidade)
export type Criterio = CriterioDecisao;

// ============================================================================
// LENS CATALOG DOMAIN
// ============================================================================

export interface Marca {
  id: UUID;
  nome: string;
  pais_origem: string;
}

export interface Lente {
  id: UUID;
  tenant_id: TenantId;
  sku_canonico: string;
  marca_id: UUID;
  familia: string;
  design: string;
  material: string;
  indice_refracao: number;
  tratamentos: string[];
  tipo_lente: TipoLente;
  corredor_progressao?: number;
  specs_tecnicas: Record<string, any>;
  ativo: boolean;
  
  // Relations (computed)
  marca?: Marca;
  
  // Legacy fields (computed)
  sku_fantasia?: string;
  marca_nome?: string;
  descricao_completa?: string;
}

// ============================================================================
// SUPPLIERS DOMAIN
// ============================================================================

export interface Laboratorio {
  id: UUID;
  tenant_id: TenantId;
  nome: string;
  cnpj: string;
  endereco: Record<string, any>;
  contato: Record<string, any>;
// SUPPLIERS DOMAIN
// ============================================================================

export interface Laboratorio {
  id: UUID;
  tenant_id: TenantId;
  nome: string;
  cnpj: string;
  endereco: Record<string, any>;
  contato: Record<string, any>;
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
  lente?: Lente;
}

// ============================================================================
// API RESPONSE TYPES (conforme blueprint)
// ============================================================================

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

export interface DecisaoCompra {
  id: UUID;
  tenant_id: TenantId;
  lente_id: UUID;
  laboratorio_id: UUID;
  produto_lab_id: UUID;
  criterio: CriterioDecisao;
  preco_final: number;
  prazo_estimado_dias: number;
  custo_frete: number;
  score_atribuido: number;
  motivo: string;
  alternativas_consideradas: AlternativaDecisao[];
  decidido_por: UserId;
  decidido_em: Date;
  status: StatusDecisao;
  payload_decisao: Record<string, any>;
  
  // Relations
  lente?: Lente;
  laboratorio?: Laboratorio;
  produto_lab?: ProdutoLaboratorio;
}

export interface AlternativaDecisao {
  laboratorio_nome: string;
  preco_final: number;
  prazo_dias: number;
  score_atribuido: number;
  motivo_descarte: string;
}

// ============================================================================
// FORM & FILTER TYPES
// ============================================================================

export interface FiltrosRanking {
  preco_maximo?: number;
  prazo_maximo_dias?: number;
  tratamentos_obrigatorios?: string[];
  laboratorios_preferidos?: UUID[];
  score_minimo?: number;
  
  // Legacy support
  regiao?: string;
  prazo_maximo?: number;
}

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

export interface BuscaLenteResult {
  lente_id: UUID;
  label: string; // Ex: "Varilux X Series 1.67 HC+AR+Blue"
  sku_fantasia: string;
}

// ============================================================================
// UTILITY TYPES
// ============================================================================

export interface ApiResponse<T> {
  data?: T;
  error?: string;
  meta?: {
    total?: number;
    page?: number;
    per_page?: number;
  };
}

export interface Session {
  user_id: UserId;
  tenant_id: TenantId;
  tenant_slug: string;
  permissions: string[];
  expires_at: Date;
}

// Legacy types (manter compatibilidade)
export interface Decisao extends DecisaoCompra {
  decidido_em: string; // Legacy format
}
  score_minimo?: number;
}

// Tipos de sessão
export interface SessionUser {
  id: string;
  email: string;
  tenant_id: string;
  tenant_nome: string;
}

export interface AppSession {
  user: SessionUser | null;
  loading: boolean;
}