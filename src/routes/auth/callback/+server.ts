/**
 * SIS Lens — /auth/callback
 * Token Relay Receiver — Padrão SSO do Ecossistema SIS_DIGIAI
 *
 * O SIS Gateway envia access_token + refresh_token via query params.
 * Este handler cria a sessão local com cookies HttpOnly e redireciona
 * para a rota original.
 *
 * Fluxo: Gateway → /auth/callback?access_token=X&refresh_token=Y&next=/catalog
 */

import { createServerClient } from '@supabase/ssr';
import { redirect } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public';

export const GET: RequestHandler = async ({ url, cookies }) => {
  const access_token  = url.searchParams.get('access_token');
  const refresh_token = url.searchParams.get('refresh_token');
  const next          = url.searchParams.get('next') ?? '/';

  if (access_token && refresh_token) {
    const supabase = createServerClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, {
      cookies: {
        getAll()  { return cookies.getAll(); },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookies.set(name, value, { ...options, path: '/' })
          );
        }
      }
    });

    const { error } = await supabase.auth.setSession({ access_token, refresh_token });

    if (!error) {
      // Sessão estabelecida com sucesso → redireciona para destino original
      throw redirect(303, next);
    }

    console.error('[auth/callback] Erro ao estabelecer sessão:', error.message);
  }

  // Tokens inválidos ou ausentes → authGuard redirecionará para Gateway
  throw redirect(303, '/');
};
