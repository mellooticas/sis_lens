/**
 * SIS Lens — /auth/callback
 * Token Relay Receiver — Padrão SSO do Ecossistema SIS_DIGIAI
 *
 * O SIS Gateway envia access_token + refresh_token via query params.
 * Este handler cria a sessão local com cookies HttpOnly e navega
 * para a rota original via HTML 200 (não 303 redirect).
 *
 * ⚠️ Netlify CDN pode remover Set-Cookie de respostas 3xx (redirect).
 * Usar HTML 200 com meta refresh garante que os cookies de sessão
 * sejam preservados. Ref: sso_autenticacao.md seção 10.1
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
      // ── HTML 200 com navegação client-side ──────────────────────────
      // Netlify CDN pode strip Set-Cookie de 3xx redirects.
      // Responder com 200 garante que os cookies de sessão sejam entregues
      // ao browser antes da navegação para a página destino.
      return new Response(
        `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0;url=${next}">
  <title>Autenticando...</title>
</head>
<body>
  <p>Autenticando...</p>
  <script>window.location.href = ${JSON.stringify(next)};</script>
</body>
</html>`,
        {
          status: 200,
          headers: { 'content-type': 'text/html' },
        }
      );
    }

    console.error('[auth/callback] Erro ao estabelecer sessão:', error.message);
  }

  // Tokens inválidos ou ausentes → authGuard redirecionará para Gateway
  throw redirect(303, '/');
};
