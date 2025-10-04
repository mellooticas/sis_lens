import { writable } from 'svelte/store';
import type { Session, UserId, TenantId } from '$lib/types/sistema';

// Tipo específico para o store de sessão da aplicação
export interface AppSession {
  user: {
    id: UserId;
    email: string;
    tenant_id: TenantId;
  } | null;
  loading: boolean;
}

// Store global de sessão
export const session = writable<AppSession>({
  user: null,
  loading: true
});

// Helper para atualizar usuário
export function setUser(user: AppSession['user']) {
  session.update((s) => ({ ...s, user, loading: false }));
}

// Helper para limpar sessão
export function clearSession() {
  session.set({ user: null, loading: false });
}