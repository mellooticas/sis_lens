import { createClient } from '@supabase/supabase-js';

// Obter variáveis de ambiente diretamente
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://placeholder.supabase.co';
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY || 'placeholder-key';

// Durante o build, usar valores placeholder se as variáveis não estiverem definidas
const isDevelopment = import.meta.env.DEV;
const isProduction = import.meta.env.PROD;

// Validação das variáveis de ambiente apenas em desenvolvimento
if (isDevelopment && (!import.meta.env.VITE_SUPABASE_URL || !import.meta.env.VITE_SUPABASE_ANON_KEY)) {
  console.warn('⚠️ Supabase environment variables missing - using placeholders for build');
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