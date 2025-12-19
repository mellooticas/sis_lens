-- ═════════════════════════════════════════════════════════════════════════════
-- 📦 IMPORTAÇÃO DE LENTES - POPULANDO BANCO DE DADOS
-- ═════════════════════════════════════════════════════════════════════════════
-- Este script importa as lentes do CSV gerado para a tabela lens_catalog.lentes
-- 
-- PRÉ-REQUISITOS:
--   ✅ Tabela lens_catalog.lentes criada (04_ESTRUTURA_FINAL_LENTES.sql)
--   ✅ Fornecedores já importados (fornecedores_rows.csv)
--   ✅ Marcas já importadas (marcas_rows.csv)
--   ✅ Empresa padrão criada (ID: 00000000-0000-0000-0000-000000000001)
--
-- EXECUÇÃO:
--   1. Certifique-se que o arquivo lentes_rows.csv está acessível
--   2. Execute este script no Supabase SQL Editor ou via psql
--
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═════════════════════════════════════════════════════════════════════════════
-- 🧹 LIMPEZA (OPCIONAL - DESCOMENTE SE QUISER LIMPAR ANTES)
-- ═════════════════════════════════════════════════════════════════════════════
-- TRUNCATE TABLE lens_catalog.lentes CASCADE;
-- SELECT setval(pg_get_serial_sequence('lens_catalog.lentes', 'id'), 1, false);

-- ═════════════════════════════════════════════════════════════════════════════
-- 📊 CRIAR TABELA TEMPORÁRIA PARA IMPORTAÇÃO
-- ═════════════════════════════════════════════════════════════════════════════
CREATE TEMPORARY TABLE temp_lentes_import (
    id UUID,
    sku_fornecedor VARCHAR(10),
    codigo_fornecedor TEXT,
    empresa_id UUID,
    visibilidade TEXT,
    marca_id UUID,
    nome_lente TEXT,
    tipo_lente TEXT,
    material TEXT,
    indice_refracao TEXT,
    categoria TEXT,
    pode_grau TEXT,
    esferico_min TEXT,
    esferico_max TEXT,
    cilindrico_min TEXT,
    cilindrico_max TEXT,
    adicao_min TEXT,
    adicao_max TEXT,
    ar TEXT,
    blue TEXT,
    fotossensivel TEXT,
    polarizado TEXT,
    tintavel TEXT,
    tratamento_foto TEXT,
    diametro_min TEXT,
    diametro_max TEXT,
    altura_min TEXT,
    altura_max TEXT,
    preco_custo TEXT,
    faixa_custo TEXT,
    fornecedor_id UUID,
    frete_estimado TEXT,
    classificacao_fiscal TEXT,
    status TEXT,
    created_at TEXT
);

-- ═════════════════════════════════════════════════════════════════════════════
-- 📥 IMPORTAR CSV PARA TABELA TEMPORÁRIA
-- ═════════════════════════════════════════════════════════════════════════════
-- NOTA: Ajuste o caminho do arquivo conforme necessário
-- Para Supabase, você precisará copiar o conteúdo do CSV manualmente ou usar a interface

\echo '📥 Importando CSV...'

-- OPÇÃO 1: Via COPY (local)
-- \copy temp_lentes_import FROM 'D:/projetos/best_lens/database/migrations/solucoes_finais/popularbanco/csvs/lentes_rows.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- OPÇÃO 2: Via SQL INSERT (para Supabase - será gerado separadamente)
-- Ver arquivo: 06_POPULAR_LENTES_DATA.sql

-- ═════════════════════════════════════════════════════════════════════════════
-- 🔄 INSERIR DADOS NA TABELA FINAL
-- ═════════════════════════════════════════════════════════════════════════════
\echo '🔄 Processando e inserindo lentes...'

INSERT INTO lens_catalog.lentes (
    id,
    sku_fornecedor,
    codigo_fornecedor,
    empresa_id,
    visibilidade,
    marca_id,
    nome_lente,
    tipo_lente,
    material,
    indice_refracao,
    categoria,
    pode_grau,
    esferico_min,
    esferico_max,
    cilindrico_min,
    cilindrico_max,
    adicao_min,
    adicao_max,
    ar,
    blue,
    fotossensivel,
    polarizado,
    tintavel,
    tratamento_foto,
    diametro_min,
    diametro_max,
    altura_min,
    altura_max,
    preco_custo,
    faixa_custo,
    fornecedor_id,
    frete_estimado,
    classificacao_fiscal,
    status,
    created_at
)
SELECT
    t.id::UUID,
    t.sku_fornecedor,
    NULLIF(t.codigo_fornecedor, ''),
    t.empresa_id::UUID,
    t.visibilidade::lens_catalog.visibilidade_lente,
    t.marca_id::UUID,
    t.nome_lente,
    t.tipo_lente::lens_catalog.tipo_lente,
    t.material::lens_catalog.material_lente,
    t.indice_refracao::lens_catalog.indice_refracao,
    t.categoria::lens_catalog.categoria_lente,
    t.pode_grau::BOOLEAN,
    COALESCE(NULLIF(t.esferico_min, '')::DECIMAL(4,2), 0.00),
    COALESCE(NULLIF(t.esferico_max, '')::DECIMAL(4,2), 0.00),
    COALESCE(NULLIF(t.cilindrico_min, '')::DECIMAL(4,2), 0.00),
    COALESCE(NULLIF(t.cilindrico_max, '')::DECIMAL(4,2), 0.00),
    NULLIF(t.adicao_min, '')::DECIMAL(3,2),
    NULLIF(t.adicao_max, '')::DECIMAL(3,2),
    t.ar::BOOLEAN,
    t.blue::BOOLEAN,
    t.fotossensivel::BOOLEAN,
    t.polarizado::BOOLEAN,
    t.tintavel::BOOLEAN,
    t.tratamento_foto::lens_catalog.tratamento_foto,
    NULLIF(t.diametro_min, '')::INTEGER,
    NULLIF(t.diametro_max, '')::INTEGER,
    NULLIF(t.altura_min, '')::INTEGER,
    NULLIF(t.altura_max, '')::INTEGER,
    COALESCE(NULLIF(t.preco_custo, '')::DECIMAL(10,2), 0.00),
    COALESCE(NULLIF(t.faixa_custo, '')::INTEGER, 1),
    t.fornecedor_id::UUID,
    COALESCE(NULLIF(t.frete_estimado, '')::DECIMAL(8,2), 0.00),
    NULLIF(t.classificacao_fiscal, ''),
    t.status::lens_catalog.status_lente,
    COALESCE(NULLIF(t.created_at, '')::TIMESTAMP WITH TIME ZONE, NOW())
FROM temp_lentes_import t
ON CONFLICT (id) DO UPDATE SET
    sku_fornecedor = EXCLUDED.sku_fornecedor,
    codigo_fornecedor = EXCLUDED.codigo_fornecedor,
    nome_lente = EXCLUDED.nome_lente,
    preco_custo = EXCLUDED.preco_custo,
    status = EXCLUDED.status,
    updated_at = NOW();

-- ═════════════════════════════════════════════════════════════════════════════
-- 📊 ESTATÍSTICAS DA IMPORTAÇÃO
-- ═════════════════════════════════════════════════════════════════════════════
\echo ''
\echo '═══════════════════════════════════════════════════════════════'
\echo '📊 ESTATÍSTICAS DA IMPORTAÇÃO DE LENTES'
\echo '═══════════════════════════════════════════════════════════════'

SELECT 
    'Total de Lentes Importadas' as metrica,
    COUNT(*) as valor
FROM lens_catalog.lentes;

SELECT 
    'Lentes por Tipo' as metrica,
    tipo_lente,
    COUNT(*) as quantidade
FROM lens_catalog.lentes
GROUP BY tipo_lente
ORDER BY quantidade DESC;

SELECT 
    'Lentes por Material' as metrica,
    material,
    COUNT(*) as quantidade
FROM lens_catalog.lentes
GROUP BY material
ORDER BY quantidade DESC;

SELECT 
    'Lentes por Marca' as metrica,
    m.nome as marca,
    COUNT(l.id) as quantidade
FROM lens_catalog.lentes l
JOIN lens_catalog.marcas m ON l.marca_id = m.id
GROUP BY m.nome
ORDER BY quantidade DESC;

SELECT 
    'Lentes por Fornecedor' as metrica,
    f.nome as fornecedor,
    COUNT(l.id) as quantidade
FROM lens_catalog.lentes l
JOIN pessoas.fornecedores f ON l.fornecedor_id = f.id
GROUP BY f.nome
ORDER BY quantidade DESC;

SELECT 
    'Lentes por Faixa de Custo' as metrica,
    faixa_custo,
    COUNT(*) as quantidade,
    ROUND(AVG(preco_custo), 2) as preco_medio
FROM lens_catalog.lentes
GROUP BY faixa_custo
ORDER BY faixa_custo;

SELECT 
    'Lentes com Tratamentos' as metrica,
    CASE 
        WHEN ar THEN 'Anti-Reflexo' 
        WHEN blue THEN 'Blue Light' 
        WHEN fotossensivel THEN 'Fotossensível'
        WHEN polarizado THEN 'Polarizado'
        ELSE 'Sem Tratamento'
    END as tratamento,
    COUNT(*) as quantidade
FROM lens_catalog.lentes
GROUP BY ROLLUP(ar, blue, fotossensivel, polarizado)
ORDER BY quantidade DESC
LIMIT 10;

\echo ''
\echo '═══════════════════════════════════════════════════════════════'
\echo '✅ IMPORTAÇÃO CONCLUÍDA COM SUCESSO!'
\echo '═══════════════════════════════════════════════════════════════'

-- ═════════════════════════════════════════════════════════════════════════════
-- 🧹 LIMPAR TABELA TEMPORÁRIA
-- ═════════════════════════════════════════════════════════════════════════════
DROP TABLE IF EXISTS temp_lentes_import;

COMMIT;

-- ═════════════════════════════════════════════════════════════════════════════
-- 📝 PRÓXIMOS PASSOS
-- ═════════════════════════════════════════════════════════════════════════════
-- 
-- 1. Verificar se todas as lentes foram importadas corretamente
-- 2. Executar gatilhos/triggers para cálculos automáticos (se houver)
-- 3. Validar relacionamentos com fornecedores e marcas
-- 4. Configurar políticas RLS se necessário
-- 5. Popular tabelas canônicas (lentes_canonicas e premium_canonicas)
--
-- ═════════════════════════════════════════════════════════════════════════════
