/**
 * SIS Lens — authStore (currentUser)
 * Padrão SvelteKit do Ecossistema SIS_DIGIAI (seção 3.2)
 *
 * Derived store que extrai os dados do usuário do page store,
 * lendo JWT claims + user_metadata + fallback para email.
 * Zero queries extras — tudo vem do JWT/session já carregado.
 */

import { derived } from 'svelte/store';
import { page } from '$app/stores';
import { getJwtClaims, buildUserDisplay, ROLE_LABELS } from '$lib/auth/jwt-claims';
import type { UserDisplay } from '$lib/auth/jwt-claims';
import { PUBLIC_SIS_GATEWAY_URL } from '$env/static/public';

// ──────────────────────────────────────────────────────────────────────────────
// Store principal: currentUser
// ──────────────────────────────────────────────────────────────────────────────

export const currentUser = derived(page, ($page): UserDisplay | null => {
  const session = $page.data.session;
  const user    = $page.data.user;

  if (!session || !user) return null;

  return buildUserDisplay(
    session,
    user.user_metadata as Record<string, unknown>,
    user.email
  );
});

// ──────────────────────────────────────────────────────────────────────────────
// Store de loading (não autenticado ainda vs. confirmado)
// ──────────────────────────────────────────────────────────────────────────────

export const isAuthenticated = derived(currentUser, ($user) => $user !== null);

// ──────────────────────────────────────────────────────────────────────────────
// Helpers de autorização (baseados em role_code)
// ──────────────────────────────────────────────────────────────────────────────

export const canViewCosts = derived(currentUser, ($user) => {
  if (!$user) return false;
  const { role_code } = $user.claims;
  return role_code === 'admin' || role_code === 'super_admin';
});

export const canManageCatalog = derived(currentUser, ($user) => {
  if (!$user) return false;
  const { role_code } = $user.claims;
  return role_code !== 'staff';
});

// ──────────────────────────────────────────────────────────────────────────────
// Logout via Gateway (cross-domain)
// ──────────────────────────────────────────────────────────────────────────────

export function logout() {
  window.location.href = `${PUBLIC_SIS_GATEWAY_URL}/logout?app=sis_lens`;
}
