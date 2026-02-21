// See https://svelte.dev/docs/kit/types#app.d.ts
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
      // session é fornecido pelo +layout.server.ts e mergeado em todas as páginas
      session?: Session | null;
    }
    // interface Error {}
    // interface Platform {}
  }
}

export {};
