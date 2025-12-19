-- ============================================
-- 09_CORRIGIR_PERMISSOES_E_CACHE.sql
-- Aplicar permissões e recarregar cache
-- ============================================

-- 1. Garantir acesso ao schema public
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- 2. Conceder SELECT em TODAS as views
GRANT SELECT ON public.vw_buscar_lentes TO anon, authenticated;
GRANT SELECT ON public.vw_comparar_fornecedores TO anon, authenticated;
GRANT SELECT ON public.vw_filtros_disponiveis TO anon, authenticated;
GRANT SELECT ON public.vw_fornecedores TO anon, authenticated;
GRANT SELECT ON public.vw_grupos_genericos TO anon, authenticated;
GRANT SELECT ON public.vw_grupos_premium TO anon, authenticated;
GRANT SELECT ON public.vw_marcas TO anon, authenticated;
GRANT SELECT ON public.vw_stats_catalogo TO anon, authenticated;

-- 3. Garantir futuras views também tenham permissão
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon, authenticated;

-- 4. CRÍTICO: Recarregar o schema cache do PostgREST
NOTIFY pgrst, 'reload schema';

-- 5. Verificar as permissões (deve mostrar "true" para todas)
SELECT 
    tablename,
    has_table_privilege('anon', 'public.' || tablename, 'SELECT') as anon_pode_ler,
    has_table_privilege('authenticated', 'public.' || tablename, 'SELECT') as authenticated_pode_ler
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename LIKE 'vw_%'
ORDER BY tablename;
