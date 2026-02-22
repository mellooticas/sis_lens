/**
 * SIS Lens — JWT Claims Helper
 * Padrão do Ecossistema SIS_DIGIAI (seção 5.5c)
 *
 * Decodifica o access_token do Supabase para extrair claims customizadas:
 * tenant_id, role_code, full_name, tenant_name
 * (disponíveis quando o custom_access_token_hook estiver enriquecido — Opção A)
 */

import type { Session } from '@supabase/supabase-js';

// ──────────────────────────────────────────────────────────────────────────────
// Tipos
// ──────────────────────────────────────────────────────────────────────────────

export interface JwtClaims {
  sub: string;
  email: string;
  tenant_id: string | null;
  store_id: string | null;
  role_code: 'staff' | 'manager' | 'admin' | 'super_admin';
  /** Disponível quando hook enriquecido (Opção A) estiver ativo */
  full_name: string | null;
  /** Disponível quando hook enriquecido (Opção A) estiver ativo */
  tenant_name: string | null;
}

export const ROLE_LABELS: Record<JwtClaims['role_code'], string> = {
  staff:       'Vendedor',
  manager:     'Gerente',
  admin:       'Administrador',
  super_admin: 'Super Admin',
};

// ──────────────────────────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────────────────────────

function decodeJwtPayload(token: string): Record<string, unknown> | null {
  try {
    const base64Payload = token.split('.')[1];
    if (!base64Payload) return null;
    const jsonStr = atob(base64Payload);
    return JSON.parse(jsonStr);
  } catch {
    return null;
  }
}

const VALID_ROLES = ['staff', 'manager', 'admin', 'super_admin'] as const;

function isValidRole(v: unknown): v is JwtClaims['role_code'] {
  return typeof v === 'string' && (VALID_ROLES as readonly string[]).includes(v);
}

// ──────────────────────────────────────────────────────────────────────────────
// Função principal
// ──────────────────────────────────────────────────────────────────────────────

export function getJwtClaims(session: Session | null): JwtClaims {
  const defaults: JwtClaims = {
    sub: '', email: '',
    tenant_id: null, store_id: null,
    role_code: 'staff',
    full_name: null, tenant_name: null,
  };

  if (!session?.access_token) return defaults;

  const payload = decodeJwtPayload(session.access_token);
  if (!payload) return defaults;

  return {
    sub:         (payload.sub         as string) ?? '',
    email:       (payload.email       as string) ?? '',
    tenant_id:   (payload.tenant_id   as string) ?? null,
    store_id:    (payload.store_id    as string) ?? null,
    role_code:   isValidRole(payload.role_code) ? payload.role_code : 'staff',
    full_name:   (payload.full_name   as string) ?? null,
    tenant_name: (payload.tenant_name as string) ?? null,
  };
}

// ──────────────────────────────────────────────────────────────────────────────
// Helper de exibição do usuário (reutilizável em qualquer componente)
// ──────────────────────────────────────────────────────────────────────────────

export interface UserDisplay {
  name: string;
  firstName: string;
  initials: string;
  roleLabel: string;
  tenantName: string;
  email: string;
  claims: JwtClaims;
}

export function buildUserDisplay(
  session: Session | null,
  userMetadata?: Record<string, unknown>,
  email?: string
): UserDisplay {
  const claims = getJwtClaims(session);

  // Prioridade: JWT claims → user_metadata → email prefix
  const fullName: string =
    claims.full_name ||
    (userMetadata?.full_name as string) ||
    (userMetadata?.name     as string) ||
    email?.split('@')[0]               ||
    '';

  const parts     = fullName.trim().split(/\s+/);
  const firstName = parts[0] || '';
  const initials  = parts.length >= 2
    ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
    : parts[0]?.substring(0, 2).toUpperCase() || '?';

  return {
    name:       fullName,
    firstName,
    initials,
    roleLabel:  ROLE_LABELS[claims.role_code] ?? 'Vendedor',
    tenantName: claims.tenant_name || (userMetadata?.tenant_name as string) || 'SIS Lens',
    email:      email || '',
    claims,
  };
}
