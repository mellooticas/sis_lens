// ============================================================================
// SIS_LENS — hooks.server.ts
// Auth via @supabase/ssr + redirect para SIS Gateway SSO
//
// SvelteKit env convention:
//   PUBLIC_*  → $env/static/public  (cliente + servidor)
//   VITE_*    → import.meta.env.*   (build-time, legado)
// ============================================================================

import { createServerClient } from '@supabase/ssr';
import { type Handle, redirect } from '@sveltejs/kit';
import { sequence } from '@sveltejs/kit/hooks';
import {
  PUBLIC_SUPABASE_URL,
  PUBLIC_SUPABASE_ANON_KEY,
  PUBLIC_SIS_GATEWAY_URL
} from '$env/static/public';

// ============================================================================
// Handle 1: Inicializar cliente Supabase com cookies HttpOnly
// ============================================================================
const supabaseHandle: Handle = async ({ event, resolve }) => {
  event.locals.supabase = createServerClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, {
    cookies: {
      getAll() {
        return event.cookies.getAll();
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value, options }) => {
          event.cookies.set(name, value, { ...options, path: '/' });
        });
      }
    }
  });

  /**
   * safeGetSession: valida o token com getUser() (server-side)
   * Não confia apenas em getSession() — pode ser falsificado no cliente.
   */
  event.locals.safeGetSession = async () => {
    const {
      data: { session }
    } = await event.locals.supabase.auth.getSession();

    if (!session) {
      return { session: null, user: null };
    }

    const {
      data: { user },
      error
    } = await event.locals.supabase.auth.getUser();

    if (error) {
      // JWT inválido ou expirado
      return { session: null, user: null };
    }

    return { session, user };
  };

  return resolve(event, {
    filterSerializedResponseHeaders(name) {
      return name === 'content-range' || name === 'x-supabase-api-version';
    }
  });
};

// ============================================================================
// Handle 2: Auth Guard — redireciona para SIS Gateway se não autenticado
//
// ENFORCE_AUTH = false  →  modo soft (dev / staging sem Gateway)
// ENFORCE_AUTH = true   →  produção — requer Gateway a tratar ?returnTo=
//
// ✅  Gateway atualizado — returnTo implementado em middleware + login-form + callback
// ============================================================================
const ENFORCE_AUTH = true;

// Rotas que NÃO precisam de autenticação
// Nota: /login foi removido do app — auth é 100% via SIS Gateway
const PUBLIC_PATHS = ['/auth', '/api/'];

const authGuard: Handle = async ({ event, resolve }) => {
  const { session, user } = await event.locals.safeGetSession();
  event.locals.session = session;
  event.locals.user = user;

  if (ENFORCE_AUTH) {
    const isPublicPath = PUBLIC_PATHS.some((p) => event.url.pathname.startsWith(p));

    if (!session && !isPublicPath) {
      const returnTo = encodeURIComponent(event.url.href);
      throw redirect(303, `${PUBLIC_SIS_GATEWAY_URL}/login?returnTo=${returnTo}&app=sis_lens`);
    }
  }

  return resolve(event);
};

export const handle = sequence(supabaseHandle, authGuard);
