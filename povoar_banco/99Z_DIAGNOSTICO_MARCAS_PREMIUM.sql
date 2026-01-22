
-- ============================================================================
-- 99Z - DIAGNÓSTICO: Marcas Premium
-- ============================================================================
-- Verifica quais marcas existem e se têm is_premium definido
-- ============================================================================

\echo '===================================================================='
\echo '1. TOTAL DE MARCAS E STATUS is_premium'
\echo '===================================================================='

SELECT 
    COUNT(*) as total_marcas,
    COUNT(*) FILTER (WHERE is_premium = true) as marcas_premium,
    COUNT(*) FILTER (WHERE is_premium = false) as marcas_standard,
    COUNT(*) FILTER (WHERE is_premium IS NULL) as marcas_sem_definir
FROM lens_catalog.marcas
WHERE ativo = true;

\echo ''
\echo '===================================================================='
\echo '2. LISTAGEM DE TODAS AS MARCAS'
\echo '===================================================================='

SELECT 
    id,
    nome,
    slug,
    is_premium,
    COUNT(l.id) as total_lentes
FROM lens_catalog.marcas m
LEFT JOIN lens_catalog.lentes l ON l.marca_id = m.id AND l.ativo = true
WHERE m.ativo = true
GROUP BY m.id, m.nome, m.slug, m.is_premium
ORDER BY total_lentes DESC, m.nome;

\echo ''
\echo '===================================================================='
\echo '3. MARCAS QUE DEVERIAM SER PREMIUM (sugestão)'
\echo '===================================================================='
\echo 'Marcas típicas premium: Essilor, Zeiss, Hoya, Varilux, Transitions'
\echo ''

SELECT 
    m.nome,
    m.is_premium,
    COUNT(l.id) as total_lentes,
    CASE 
        WHEN m.is_premium = true THEN '✅ Já é premium'
        WHEN m.is_premium = false THEN '⚠️  Deveria ser premium?'
        ELSE '⚠️  Sem definição'
    END as status
FROM lens_catalog.marcas m
LEFT JOIN lens_catalog.lentes l ON l.marca_id = m.id AND l.ativo = true
WHERE m.ativo = true
  AND UPPER(m.nome) SIMILAR TO '%(ESSILOR|ZEISS|HOYA|VARILUX|TRANSITIONS|CRIZAL|XPERIO)%'
GROUP BY m.id, m.nome, m.is_premium
ORDER BY m.nome;

\echo ''
\echo '===================================================================='
\echo 'AÇÃO NECESSÁRIA'
\echo '===================================================================='
\echo ''
\echo 'Se TODAS as marcas estão com is_premium = false:'
\echo '  → Precisa DEFINIR quais marcas são premium'
\echo '  → Executar UPDATE nas marcas premium antes de rodar 99V/99W'
\echo ''
\echo 'Exemplo:'
\echo '  UPDATE lens_catalog.marcas'
\echo '  SET is_premium = true'
\echo '  WHERE UPPER(nome) SIMILAR TO ''%(ESSILOR|ZEISS|HOYA|VARILUX)%'';'
\echo ''
