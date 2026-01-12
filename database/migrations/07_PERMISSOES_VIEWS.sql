-- ============================================
-- 07_PERMISSOES_VIEWS.sql
-- Conceder permissões públicas para as views
-- ============================================

-- Garantir acesso ao schema public
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Conceder SELECT em TODAS as views do schema public
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;

-- Permissões específicas para cada view (garantia extra)
GRANT SELECT ON public.vw_buscar_lentes TO anon, authenticated;
GRANT SELECT ON public.vw_grupos_genericos TO anon, authenticated;
GRANT SELECT ON public.vw_grupos_premium TO anon, authenticated;
GRANT SELECT ON public.vw_marcas TO anon, authenticated;
GRANT SELECT ON public.vw_fornecedores TO anon, authenticated;
GRANT SELECT ON public.vw_filtros_disponiveis TO anon, authenticated;
GRANT SELECT ON public.vw_comparar_fornecedores TO anon, authenticated;
GRANT SELECT ON public.vw_stats_catalogo TO anon, authenticated;

-- Garantir que futuras tabelas/views também tenham permissão
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon, authenticated;

-- Recarregar o schema cache do PostgREST
NOTIFY pgrst, 'reload schema';

-- Verificar permissões concedidas
SELECT 
    schemaname,
    tablename,
    CASE 
        WHEN has_table_privilege('anon', schemaname||'.'||tablename, 'SELECT') 
        THEN '✅ Permitido'
        ELSE '❌ Negado'
    END as acesso_anon
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename LIKE 'vw_%'
ORDER BY tablename;
