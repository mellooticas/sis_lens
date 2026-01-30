-- ============================================================================
-- SCRIPT DE CORREÇÃO DE PERMISSÕES (401 Unauthorized Fix)
-- ============================================================================
-- O erro 401/403 muitas vezes ocorre porque o role 'authenticated' ou 'anon'
-- não tem permissão de USAGE no schema 'contact_lens' ou SELECT nas tabelas,
-- mesmo que tenha permissão na View pública.
-- ============================================================================

BEGIN;

-- 1. Garantir acesso ao Schema contact_lens
GRANT USAGE ON SCHEMA contact_lens TO anon, authenticated, service_role;

-- 2. Garantir SELECT nas tabelas base (Necessário se a View for Security Invoker ou para RLS)
GRANT SELECT ON ALL TABLES IN SCHEMA contact_lens TO anon, authenticated, service_role;

-- 3. Garantir acesso à View Pública especificamente
GRANT SELECT ON public.v_lentes_contato TO anon, authenticated, service_role;

-- 4. Opcional: Se houver RLS habilitado futuramente, criar políticas básicas
-- Por enquanto, apenas permissão de nível de tabela deve resolver se RLS estiver desativado.
-- (Se RLS estiver ativado e sem policies, retorna vazio, não 401, mas vamos garantir)

-- Se precisarmos garantir que RLS não bloqueie (caso tenha sido ativado):
-- ALTER TABLE contact_lens.lentes DISABLE ROW LEVEL SECURITY; -- Descomentar se necessário radicalizar
-- Ou criar policy de leitura:
-- CREATE POLICY "Leitura pública" ON contact_lens.lentes FOR SELECT USING (true);

COMMIT;
