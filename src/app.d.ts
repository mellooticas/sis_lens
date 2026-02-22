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
      /** Sessão ativa do Supabase (fornecida pelo +layout.server.ts) */
      session?: Session | null;
      /** Usuário autenticado — necessário para o authStore (currentUser) */
      user?: User | null;
    }
    // interface Error {}
    // interface Platform {}
  }
}

export {};
