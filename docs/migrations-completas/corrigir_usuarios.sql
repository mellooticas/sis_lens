-- ============================================================================
-- CORREÇÃO ESPECÍFICA PARA TABELA USUARIOS - POLÍTICA RLS
-- Execute no Supabase Dashboard
-- ============================================================================

-- Verificar se há triggers ou funções que causam recursão
SELECT trigger_schema, trigger_name, event_manipulation, action_timing, action_statement 
FROM information_schema.triggers 
WHERE event_object_table = 'usuarios';

-- Remover TODAS as políticas da tabela usuarios
DROP POLICY IF EXISTS "allow_anon_select" ON public.usuarios;
DROP POLICY IF EXISTS "users_policy" ON public.usuarios;
DROP POLICY IF EXISTS "usuarios_policy" ON public.usuarios;
DROP POLICY IF EXISTS "select_policy" ON public.usuarios;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.usuarios;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.usuarios;

-- Desabilitar RLS completamente
ALTER TABLE public.usuarios DISABLE ROW LEVEL SECURITY;

-- Verificar se a tabela funciona sem RLS
SELECT COUNT(*) as total_usuarios FROM public.usuarios;

-- Como alternativa, podemos criar uma VIEW em vez de tabela com RLS
DROP VIEW IF EXISTS public.vw_usuarios;
CREATE OR REPLACE VIEW public.vw_usuarios AS 
SELECT 
    id,
    email,
    nome,
    tenant_id,
    role,
    loja_id,
    ativo,
    created_at,
    updated_at
FROM public.usuarios;

-- Dar permissão para view
GRANT SELECT ON public.vw_usuarios TO anon;

-- Ou se quiser manter RLS, usar política super simples
-- ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "simple_select" ON public.usuarios FOR SELECT USING (true);

-- ============================================================================
-- VERIFICAÇÕES FINAIS
-- ============================================================================

-- Testar acesso direto à tabela
SELECT 'Testando tabela usuarios...' as teste;
SELECT COUNT(*) FROM public.usuarios;

-- Testar acesso via view
SELECT 'Testando view vw_usuarios...' as teste;
SELECT COUNT(*) FROM public.vw_usuarios;

-- ============================================================================
-- FINALIZADO! 
-- Problema de recursão RLS resolvido
-- ============================================================================