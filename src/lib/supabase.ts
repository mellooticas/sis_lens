import { createClient } from '@supabase/supabase-js';

// Obter variáveis de ambiente diretamente
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;

// Validação das variáveis de ambiente
if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('Supabase environment variables:', {
    url: SUPABASE_URL ? 'present' : 'missing',
    key: SUPABASE_ANON_KEY ? 'present' : 'missing',
    env: import.meta.env
  });
  throw new Error('Missing Supabase environment variables');
}

// Cliente Supabase singleton
export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true
  }
});

// Helper para verificar se está autenticado
export async function getSession() {
  const { data, error } = await supabase.auth.getSession();
  if (error) {
    console.error('Erro ao buscar sessão:', error);
    return null;
  }
  return data.session;
}

// Helper para pegar dados do tenant do JWT
export function getTenantId(session: any) {
  return session?.user?.user_metadata?.tenant_id || null;
}