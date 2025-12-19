-- ============================================
-- LIMPEZA DE VIEWS ANTIGAS
-- Remove views criadas incorretamente
-- ============================================

-- Remover views antigas que não fazem sentido na arquitetura
DROP VIEW IF EXISTS public.vw_comparativo_canonicas_genericas CASCADE;
DROP VIEW IF EXISTS public.vw_comparativo_canonicas_premium CASCADE;

-- Remover outras views que possam existir e serão recriadas
DROP VIEW IF EXISTS public.vw_lentes_catalogo CASCADE;
DROP VIEW IF EXISTS public.vw_canonicas_genericas CASCADE;
DROP VIEW IF EXISTS public.vw_canonicas_premium CASCADE;
DROP VIEW IF EXISTS public.vw_stats_catalogo CASCADE;

-- Mensagem de confirmação
SELECT 'Views antigas removidas com sucesso!' as status;
