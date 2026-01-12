-- ============================================
-- INVESTIGAÇÃO: COMPARAR VIEWS DE CATÁLOGO
-- Compara v_lentes_catalogo vs vw_lentes_catalogo
-- ============================================

\echo '=========================================='
\echo 'ANÁLISE DAS VIEWS DE CATÁLOGO'
\echo '=========================================='
\echo ''

-- ============================================
-- 1. VERIFICAR EXISTÊNCIA DAS VIEWS
-- ============================================
\echo '1. VERIFICANDO EXISTÊNCIA DAS VIEWS:'
\echo ''

SELECT 
  table_schema,
  table_name,
  CASE 
    WHEN table_type = 'VIEW' THEN '✓ EXISTS'
    ELSE '✗ NOT FOUND'
  END as status
FROM information_schema.tables
WHERE table_schema = 'public' 
  AND table_name IN ('v_lentes_catalogo', 'vw_lentes_catalogo')
ORDER BY table_name;



| table_schema | table_name         | status   |
| ------------ | ------------------ | -------- |
| public       | v_lentes_catalogo  | ✓ EXISTS |
| public       | vw_lentes_catalogo | ✓ EXISTS |


\echo ''

-- ============================================
-- 2. ESTRUTURA: v_lentes_catalogo
-- ============================================
\echo '2. ESTRUTURA DA VIEW: v_lentes_catalogo'
\echo '-------------------------------------------'

SELECT 
  ordinal_position as pos,
  column_name,
  data_type,
  CASE WHEN is_nullable = 'YES' THEN 'NULL' ELSE 'NOT NULL' END as nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'v_lentes_catalogo'
ORDER BY ordinal_position;

| pos | column_name               | data_type                | nullable |
| --- | ------------------------- | ------------------------ | -------- |
| 1   | id                        | uuid                     | NULL     |
| 2   | slug                      | text                     | NULL     |
| 3   | nome_lente                | text                     | NULL     |
| 4   | nome_canonizado           | text                     | NULL     |
| 5   | fornecedor_id             | uuid                     | NULL     |
| 6   | fornecedor_nome           | text                     | NULL     |
| 7   | prazo_visao_simples       | integer                  | NULL     |
| 8   | prazo_multifocal          | integer                  | NULL     |
| 9   | prazo_surfacada           | integer                  | NULL     |
| 10  | prazo_free_form           | integer                  | NULL     |
| 11  | marca_id                  | uuid                     | NULL     |
| 12  | marca_nome                | character varying        | NULL     |
| 13  | marca_slug                | character varying        | NULL     |
| 14  | marca_premium             | boolean                  | NULL     |
| 15  | grupo_id                  | uuid                     | NULL     |
| 16  | nome_grupo                | text                     | NULL     |
| 17  | grupo_slug                | text                     | NULL     |
| 18  | tipo_lente                | USER-DEFINED             | NULL     |
| 19  | material                  | USER-DEFINED             | NULL     |
| 20  | indice_refracao           | USER-DEFINED             | NULL     |
| 21  | categoria                 | USER-DEFINED             | NULL     |
| 22  | tratamento_antirreflexo   | boolean                  | NULL     |
| 23  | tratamento_antirrisco     | boolean                  | NULL     |
| 24  | tratamento_uv             | boolean                  | NULL     |
| 25  | tratamento_blue_light     | boolean                  | NULL     |
| 26  | tratamento_fotossensiveis | USER-DEFINED             | NULL     |
| 27  | diametro_mm               | integer                  | NULL     |
| 28  | curva_base                | numeric                  | NULL     |
| 29  | espessura_centro_mm       | numeric                  | NULL     |
| 30  | grau_esferico_min         | numeric                  | NULL     |
| 31  | grau_esferico_max         | numeric                  | NULL     |
| 32  | grau_cilindrico_min       | numeric                  | NULL     |
| 33  | grau_cilindrico_max       | numeric                  | NULL     |
| 34  | adicao_min                | numeric                  | NULL     |
| 35  | adicao_max                | numeric                  | NULL     |
| 36  | preco_custo               | numeric                  | NULL     |
| 37  | preco_venda_sugerido      | numeric                  | NULL     |
| 38  | margem_lucro              | numeric                  | NULL     |
| 39  | estoque_disponivel        | integer                  | NULL     |
| 40  | estoque_reservado         | integer                  | NULL     |
| 41  | status                    | USER-DEFINED             | NULL     |
| 42  | ativo                     | boolean                  | NULL     |
| 43  | peso                      | integer                  | NULL     |
| 44  | metadata                  | jsonb                    | NULL     |
| 45  | created_at                | timestamp with time zone | NULL     |
| 46  | updated_at                | timestamp with time zone | NULL     |


\echo ''
\echo 'Total de colunas:'
SELECT COUNT(*) as total_colunas
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'v_lentes_catalogo';

\echo ''

| total_colunas |
| ------------- |
| 46            |

-- ============================================
-- 3. ESTRUTURA: vw_lentes_catalogo
-- ============================================
\echo '3. ESTRUTURA DA VIEW: vw_lentes_catalogo'
\echo '-------------------------------------------'

SELECT 
  ordinal_position as pos,
  column_name,
  data_type,
  CASE WHEN is_nullable = 'YES' THEN 'NULL' ELSE 'NOT NULL' END as nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'vw_lentes_catalogo'
ORDER BY ordinal_position;

| pos | column_name            | data_type                | nullable |
| --- | ---------------------- | ------------------------ | -------- |
| 1   | id                     | uuid                     | NULL     |
| 2   | marca_id               | uuid                     | NULL     |
| 3   | fornecedor_id          | uuid                     | NULL     |
| 4   | lente_canonica_id      | uuid                     | NULL     |
| 5   | premium_canonica_id    | uuid                     | NULL     |
| 6   | sku_fornecedor         | character varying        | NULL     |
| 7   | codigo_original        | character varying        | NULL     |
| 8   | nome_comercial         | text                     | NULL     |
| 9   | marca_nome             | character varying        | NULL     |
| 10  | marca_slug             | character varying        | NULL     |
| 11  | marca_premium          | boolean                  | NULL     |
| 12  | tipo_lente             | USER-DEFINED             | NULL     |
| 13  | categoria              | USER-DEFINED             | NULL     |
| 14  | material               | USER-DEFINED             | NULL     |
| 15  | indice_refracao        | USER-DEFINED             | NULL     |
| 16  | linha_produto          | character varying        | NULL     |
| 17  | diametro               | integer                  | NULL     |
| 18  | espessura_central      | numeric                  | NULL     |
| 19  | peso_aproximado        | numeric                  | NULL     |
| 20  | esferico_min           | numeric                  | NULL     |
| 21  | esferico_max           | numeric                  | NULL     |
| 22  | cilindrico_min         | numeric                  | NULL     |
| 23  | cilindrico_max         | numeric                  | NULL     |
| 24  | adicao_min             | numeric                  | NULL     |
| 25  | adicao_max             | numeric                  | NULL     |
| 26  | dnp_min                | integer                  | NULL     |
| 27  | dnp_max                | integer                  | NULL     |
| 28  | ar                     | boolean                  | NULL     |
| 29  | antirrisco             | boolean                  | NULL     |
| 30  | hidrofobico            | boolean                  | NULL     |
| 31  | antiembaçante          | boolean                  | NULL     |
| 32  | blue                   | boolean                  | NULL     |
| 33  | uv400                  | boolean                  | NULL     |
| 34  | fotossensivel          | text                     | NULL     |
| 35  | polarizado             | boolean                  | NULL     |
| 36  | digital                | boolean                  | NULL     |
| 37  | free_form              | boolean                  | NULL     |
| 38  | indoor                 | boolean                  | NULL     |
| 39  | drive                  | boolean                  | NULL     |
| 40  | custo_base             | numeric                  | NULL     |
| 41  | preco_fabricante       | numeric                  | NULL     |
| 42  | preco_tabela           | numeric                  | NULL     |
| 43  | prazo_entrega          | integer                  | NULL     |
| 44  | obs_prazo              | text                     | NULL     |
| 45  | peso_frete             | numeric                  | NULL     |
| 46  | exige_receita_especial | boolean                  | NULL     |
| 47  | descricao_curta        | text                     | NULL     |
| 48  | descricao_completa     | text                     | NULL     |
| 49  | beneficios             | ARRAY                    | NULL     |
| 50  | indicacoes             | ARRAY                    | NULL     |
| 51  | contraindicacoes       | text                     | NULL     |
| 52  | observacoes            | text                     | NULL     |
| 53  | status                 | USER-DEFINED             | NULL     |
| 54  | disponivel             | boolean                  | NULL     |
| 55  | destaque               | boolean                  | NULL     |
| 56  | novidade               | boolean                  | NULL     |
| 57  | data_lancamento        | date                     | NULL     |
| 58  | data_descontinuacao    | date                     | NULL     |
| 59  | created_at             | timestamp with time zone | NULL     |
| 60  | updated_at             | timestamp with time zone | NULL     |


\echo ''
\echo 'Total de colunas:'
SELECT COUNT(*) as total_colunas
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'vw_lentes_catalogo';

\echo ''


| total_colunas |
| ------------- |
| 60            |


-- ============================================
-- 4. COMPARAÇÃO DE CAMPOS
-- ============================================
\echo '4. CAMPOS QUE EXISTEM EM v_lentes_catalogo MAS NÃO EM vw_lentes_catalogo:'
\echo '-----------------------------------------------------------------------------'

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'v_lentes_catalogo'
  AND column_name NOT IN (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'vw_lentes_catalogo'
  )
ORDER BY column_name;


| column_name               | data_type    |
| ------------------------- | ------------ |
| ativo                     | boolean      |
| curva_base                | numeric      |
| diametro_mm               | integer      |
| espessura_centro_mm       | numeric      |
| estoque_disponivel        | integer      |
| estoque_reservado         | integer      |
| fornecedor_nome           | text         |
| grau_cilindrico_max       | numeric      |
| grau_cilindrico_min       | numeric      |
| grau_esferico_max         | numeric      |
| grau_esferico_min         | numeric      |
| grupo_id                  | uuid         |
| grupo_slug                | text         |
| margem_lucro              | numeric      |
| metadata                  | jsonb        |
| nome_canonizado           | text         |
| nome_grupo                | text         |
| nome_lente                | text         |
| peso                      | integer      |
| prazo_free_form           | integer      |
| prazo_multifocal          | integer      |
| prazo_surfacada           | integer      |
| prazo_visao_simples       | integer      |
| preco_custo               | numeric      |
| preco_venda_sugerido      | numeric      |
| slug                      | text         |
| tratamento_antirreflexo   | boolean      |
| tratamento_antirrisco     | boolean      |
| tratamento_blue_light     | boolean      |
| tratamento_fotossensiveis | USER-DEFINED |
| tratamento_uv             | boolean      |


\echo ''
\echo '5. CAMPOS QUE EXISTEM EM vw_lentes_catalogo MAS NÃO EM v_lentes_catalogo:'
\echo '-----------------------------------------------------------------------------'

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'vw_lentes_catalogo'
  AND column_name NOT IN (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'v_lentes_catalogo'
  )
ORDER BY column_name;

\echo ''

| column_name            | data_type         |
| ---------------------- | ----------------- |
| antiembaçante          | boolean           |
| antirrisco             | boolean           |
| ar                     | boolean           |
| beneficios             | ARRAY             |
| blue                   | boolean           |
| cilindrico_max         | numeric           |
| cilindrico_min         | numeric           |
| codigo_original        | character varying |
| contraindicacoes       | text              |
| custo_base             | numeric           |
| data_descontinuacao    | date              |
| data_lancamento        | date              |
| descricao_completa     | text              |
| descricao_curta        | text              |
| destaque               | boolean           |
| diametro               | integer           |
| digital                | boolean           |
| disponivel             | boolean           |
| dnp_max                | integer           |
| dnp_min                | integer           |
| drive                  | boolean           |
| esferico_max           | numeric           |
| esferico_min           | numeric           |
| espessura_central      | numeric           |
| exige_receita_especial | boolean           |
| fotossensivel          | text              |
| free_form              | boolean           |
| hidrofobico            | boolean           |
| indicacoes             | ARRAY             |
| indoor                 | boolean           |
| lente_canonica_id      | uuid              |
| linha_produto          | character varying |
| nome_comercial         | text              |
| novidade               | boolean           |
| obs_prazo              | text              |
| observacoes            | text              |
| peso_aproximado        | numeric           |
| peso_frete             | numeric           |
| polarizado             | boolean           |
| prazo_entrega          | integer           |
| preco_fabricante       | numeric           |
| preco_tabela           | numeric           |
| premium_canonica_id    | uuid              |
| sku_fornecedor         | character varying |
| uv400                  | boolean           |

-- ============================================
-- 6. CONTAGEM DE REGISTROS
-- ============================================
\echo '6. QUANTIDADE DE REGISTROS EM CADA VIEW:'
\echo '-----------------------------------------'

-- v_lentes_catalogo
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'v_lentes_catalogo'
  ) THEN
    RAISE NOTICE 'v_lentes_catalogo: % registros', (SELECT COUNT(*) FROM public.v_lentes_catalogo);
  ELSE
    RAISE NOTICE 'v_lentes_catalogo: VIEW NÃO EXISTE';
  END IF;
END $$;


Success. No rows returned




-- vw_lentes_catalogo
    DO $$
    BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'vw_lentes_catalogo'
    ) THEN
        RAISE NOTICE 'vw_lentes_catalogo: % registros', (SELECT COUNT(*) FROM public.vw_lentes_catalogo);
    ELSE
        RAISE NOTICE 'vw_lentes_catalogo: VIEW NÃO EXISTE';
    END IF;
    END $$;

\echo ''

Success. No rows returned





-- ============================================
-- 7. AMOSTRA DE DADOS: v_lentes_catalogo
-- ============================================
\echo '7. AMOSTRA DE 3 REGISTROS: v_lentes_catalogo'
\echo '---------------------------------------------'

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'v_lentes_catalogo'
  ) THEN
    EXECUTE 'SELECT * FROM public.v_lentes_catalogo LIMIT 3';
  ELSE
    RAISE NOTICE 'VIEW NÃO EXISTE';
  END IF;
END $$;

\echo ''
Success. No rows returned




-- ============================================
-- 8. AMOSTRA DE DADOS: vw_lentes_catalogo
-- ============================================
\echo '8. AMOSTRA DE 3 REGISTROS: vw_lentes_catalogo'
\echo '----------------------------------------------'

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'vw_lentes_catalogo'
  ) THEN
    EXECUTE 'SELECT * FROM public.vw_lentes_catalogo LIMIT 3';
  ELSE
    RAISE NOTICE 'VIEW NÃO EXISTE';
  END IF;
END $$;

\echo ''
Success. No rows returned





-- ============================================
-- 9. ANÁLISE DE TRATAMENTOS
-- ============================================
\echo '9. ANÁLISE DE CAMPOS DE TRATAMENTOS:'
\echo '-------------------------------------'

-- Verificar se v_lentes_catalogo tem tratamento_antirreflexo
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'v_lentes_catalogo'
      AND column_name = 'tratamento_antirreflexo'
  ) THEN
    RAISE NOTICE 'v_lentes_catalogo tem campo: tratamento_antirreflexo';
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'v_lentes_catalogo'
      AND column_name = 'ar'
  ) THEN
    RAISE NOTICE 'v_lentes_catalogo tem campo: ar';
  END IF;
END $$;

Success. No rows returned




-- Verificar se vw_lentes_catalogo tem ar
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'vw_lentes_catalogo'
      AND column_name = 'ar'
  ) THEN
    RAISE NOTICE 'vw_lentes_catalogo tem campo: ar (tipo: %, nullable: %)',
      (SELECT data_type FROM information_schema.columns 
       WHERE table_schema = 'public' AND table_name = 'vw_lentes_catalogo' AND column_name = 'ar'),
      (SELECT is_nullable FROM information_schema.columns 
       WHERE table_schema = 'public' AND table_name = 'vw_lentes_catalogo' AND column_name = 'ar');
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = 'vw_lentes_catalogo'
      AND column_name = 'tratamento_antirreflexo'
  ) THEN
    RAISE NOTICE 'vw_lentes_catalogo tem campo: tratamento_antirreflexo';
  END IF;
END $$;

\echo ''
Success. No rows returned





-- ============================================
-- 10. ANÁLISE DE CAMPOS DE PREÇO
-- ============================================
\echo '10. ANÁLISE DE CAMPOS DE PREÇO:'
\echo '--------------------------------'

-- v_lentes_catalogo
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'v_lentes_catalogo') THEN
    RAISE NOTICE '=== v_lentes_catalogo ===';
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'v_lentes_catalogo' AND column_name = 'preco_venda_sugerido') THEN
      RAISE NOTICE '✓ Tem: preco_venda_sugerido';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'v_lentes_catalogo' AND column_name = 'preco_tabela') THEN
      RAISE NOTICE '✓ Tem: preco_tabela';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'v_lentes_catalogo' AND column_name = 'preco_custo') THEN
      RAISE NOTICE '✓ Tem: preco_custo';
    END IF;
  END IF;
END $$;

-- vw_lentes_catalogo
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'vw_lentes_catalogo') THEN
    RAISE NOTICE '=== vw_lentes_catalogo ===';
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'vw_lentes_catalogo' AND column_name = 'preco_tabela') THEN
      RAISE NOTICE '✓ Tem: preco_tabela';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'vw_lentes_catalogo' AND column_name = 'custo_base') THEN
      RAISE NOTICE '✓ Tem: custo_base';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'vw_lentes_catalogo' AND column_name = 'preco_fabricante') THEN
      RAISE NOTICE '✓ Tem: preco_fabricante';
    END IF;
  END IF;
END $$;

\echo ''
\echo '=========================================='
\echo 'FIM DA ANÁLISE'
\echo '=========================================='
