// See https://svelte.dev/docs/kit/types#app.d.ts
// Padrão do Ecossistema SIS_DIGIAI — seção 4.4
import type { Session, SupabaseClient, User } from '@supabase/supabase-js';

declare global {
  namespace App {
    interface Locals {
      supabase: SupabaseClient;
      safeGetSession(): Promise<{ session: Session | null; user: User | null }>;
      session: Session | null;
      user: User | null;
    }
    interface PageData {
      /** Sessão ativa do Supabase (fornecida pelo +layout.ts) */
      session?: Session | null;
      /** Usuário autenticado — fornecido pelo +layout.server.ts */
      user?: User | null;
      /** Cliente Supabase (browser ou server) — fornecido pelo +layout.ts */
      supabase?: SupabaseClient;
      /** Cookies do request — passados pelo +layout.server.ts para o +layout.ts */
      cookies?: Array<{ name: string; value: string }>;
    }
    // interface Error {}
    // interface Platform {}
  }
}

export {};
