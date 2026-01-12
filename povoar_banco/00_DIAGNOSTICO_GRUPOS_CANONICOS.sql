-- ============================================================================
-- DIAGNÓSTICO: Investigação da Estrutura de Grupos Canônicos
-- Data: 2026-01-11
-- Objetivo: Descobrir estado real do banco para implementar módulo standard
-- ============================================================================

-- ===========================================================================
-- SEÇÃO 1: VERIFICAR SE TABELA GRUPOS_CANONICOS EXISTE
-- ===========================================================================

-- Query 1.1: Buscar tabela em todos os schemas
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE tablename LIKE '%grupos%' OR tablename LIKE '%canonico%'
ORDER BY schemaname, tablename;

| schemaname   | tablename                   | tableowner |
| ------------ | --------------------------- | ---------- |
| lens_catalog | grupos_canonicos            | postgres   |
| lens_catalog | grupos_canonicos_backup_old | postgres   |
| lens_catalog | grupos_canonicos_log        | postgres   |
| lens_catalog | lentes_grupos_backup_old    | postgres   |


-- Query 1.2: Buscar especificamente a tabela grupos_canonicos
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_name = 'grupos_canonicos';

| table_schema | table_name       | table_type |
| ------------ | ---------------- | ---------- |
| lens_catalog | grupos_canonicos | BASE TABLE |


-- ===========================================================================
-- SEÇÃO 2: VERIFICAR ESTRUTURA DA TABELA LENTES
-- ===========================================================================

-- Query 2.1: Listar colunas da tabela lentes (schema lens_catalog)
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'lens_catalog' 
  AND table_name = 'lentes'
ORDER BY ordinal_position;

| column_name               | data_type                | is_nullable | column_default                         |
| ------------------------- | ------------------------ | ----------- | -------------------------------------- |
| id                        | uuid                     | NO          | gen_random_uuid()                      |
| fornecedor_id             | uuid                     | NO          | null                                   |
| marca_id                  | uuid                     | YES         | null                                   |
| grupo_canonico_id         | uuid                     | YES         | null                                   |
| nome_lente                | text                     | NO          | null                                   |
| nome_canonizado           | text                     | YES         | null                                   |
| slug                      | text                     | YES         | null                                   |
| sku                       | character varying        | YES         | null                                   |
| codigo_fornecedor         | character varying        | YES         | null                                   |
| tipo_lente                | USER-DEFINED             | NO          | null                                   |
| material                  | USER-DEFINED             | NO          | null                                   |
| indice_refracao           | USER-DEFINED             | NO          | null                                   |
| categoria                 | USER-DEFINED             | NO          | null                                   |
| tratamento_antirreflexo   | boolean                  | NO          | false                                  |
| tratamento_antirrisco     | boolean                  | NO          | false                                  |
| tratamento_uv             | boolean                  | NO          | false                                  |
| tratamento_blue_light     | boolean                  | NO          | false                                  |
| tratamento_fotossensiveis | USER-DEFINED             | YES         | 'nenhum'::lens_catalog.tratamento_foto |
| diametro_mm               | integer                  | YES         | null                                   |
| curva_base                | numeric                  | YES         | null                                   |
| espessura_centro_mm       | numeric                  | YES         | null                                   |
| eixo_optico               | character varying        | YES         | null                                   |
| grau_esferico_min         | numeric                  | YES         | null                                   |
| grau_esferico_max         | numeric                  | YES         | null                                   |
| grau_cilindrico_min       | numeric                  | YES         | null                                   |
| grau_cilindrico_max       | numeric                  | YES         | null                                   |
| adicao_min                | numeric                  | YES         | null                                   |
| adicao_max                | numeric                  | YES         | null                                   |
| preco_custo               | numeric                  | NO          | 0                                      |
| preco_venda_sugerido      | numeric                  | NO          | 0                                      |
| margem_lucro              | numeric                  | YES         | null                                   |
| estoque_disponivel        | integer                  | YES         | 0                                      |
| estoque_minimo            | integer                  | YES         | 0                                      |
| lead_time_dias            | integer                  | YES         | null                                   |
| status                    | USER-DEFINED             | NO          | 'ativo'::lens_catalog.status_lente     |
| ativo                     | boolean                  | NO          | true                                   |
| peso                      | integer                  | YES         | 50                                     |
| metadata                  | jsonb                    | YES         | '{}'::jsonb                            |
| created_at                | timestamp with time zone | NO          | now()                                  |
| updated_at                | timestamp with time zone | NO          | now()                                  |
| deleted_at                | timestamp with time zone | YES         | null                                   |
| sku_fornecedor            | character varying        | YES         | null                                   |
| codigo_original           | character varying        | YES         | null                                   |
| nome_comercial            | text                     | YES         | null                                   |
| descricao_curta           | text                     | YES         | null                                   |
| linha_produto             | character varying        | YES         | null                                   |
| custo_base                | numeric                  | YES         | 0                                      |
| preco_tabela              | numeric                  | YES         | 0                                      |
| preco_fabricante          | numeric                  | YES         | null                                   |
| esferico_min              | numeric                  | YES         | null                                   |
| esferico_max              | numeric                  | YES         | null                                   |
| cilindrico_min            | numeric                  | YES         | null                                   |
| cilindrico_max            | numeric                  | YES         | null                                   |
| dnp_min                   | integer                  | YES         | null                                   |
| dnp_max                   | integer                  | YES         | null                                   |
| prazo_entrega             | integer                  | YES         | 7                                      |
| obs_prazo                 | text                     | YES         | null                                   |
| peso_frete                | numeric                  | YES         | 50.0                                   |
| exige_receita_especial    | boolean                  | YES         | false                                  |
| disponivel                | boolean                  | YES         | true                                   |
| lente_canonica_id         | uuid                     | YES         | null                                   |
| premium_canonica_id       | uuid                     | YES         | null                                   |
| diametro                  | integer                  | YES         | null                                   |
| espessura_central         | numeric                  | YES         | null                                   |
| peso_aproximado           | numeric                  | YES         | null                                   |
| ar                        | boolean                  | YES         | false                                  |
| antirrisco                | boolean                  | YES         | false                                  |
| hidrofobico               | boolean                  | YES         | false                                  |
| antiembaçante             | boolean                  | YES         | false                                  |
| blue                      | boolean                  | YES         | false                                  |
| uv400                     | boolean                  | YES         | false                                  |
| polarizado                | boolean                  | YES         | false                                  |
| digital                   | boolean                  | YES         | false                                  |
| free_form                 | boolean                  | YES         | false                                  |
| indoor                    | boolean                  | YES         | false                                  |
| drive                     | boolean                  | YES         | false                                  |
| fotossensivel             | text                     | YES         | 'nenhum'::text                         |
| destaque                  | boolean                  | YES         | false                                  |
| novidade                  | boolean                  | YES         | false                                  |
| data_lancamento           | date                     | YES         | null                                   |
| data_descontinuacao       | date                     | YES         | null                                   |
| descricao_completa        | text                     | YES         | null                                   |
| contraindicacoes          | text                     | YES         | null                                   |
| observacoes               | text                     | YES         | null                                   |
| beneficios                | ARRAY                    | YES         | null                                   |
| indicacoes                | ARRAY                    | YES         | null                                   |


-- Query 2.2: Verificar se existe coluna grupo_canonico_id
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'lens_catalog' 
  AND table_name = 'lentes'
  AND column_name LIKE '%grupo%';

| column_name       | data_type | is_nullable |
| ----------------- | --------- | ----------- |
| grupo_canonico_id | uuid      | YES         |

-- ===========================================================================
-- SEÇÃO 3: VERIFICAR VIEWS EXISTENTES
-- ===========================================================================

-- Query 3.1: Listar todas as views no schema public
SELECT 
    table_schema,
    table_name,
    view_definition
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE '%grupo%' OR table_name LIKE '%canonico%'
ORDER BY table_name;

| table_schema | table_name                       | view_definition                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ------------ | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| public       | v_filtros_grupos_canonicos       |  SELECT filtro_categoria,
    filtro_valor,
    count(*) AS total_grupos,
    min(preco_minimo) AS preco_min,
    max(preco_maximo) AS preco_max,
    (avg(preco_medio))::numeric(10,2) AS preco_medio_geral,
    sum(total_lentes) AS total_lentes_agregado
   FROM ( SELECT 'tipo_lente'::text AS filtro_categoria,
            (grupos_canonicos.tipo_lente)::text AS filtro_valor,
            grupos_canonicos.preco_minimo,
            grupos_canonicos.preco_maximo,
            grupos_canonicos.preco_medio,
            grupos_canonicos.total_lentes
           FROM lens_catalog.grupos_canonicos
          WHERE (grupos_canonicos.total_lentes > 0)
        UNION ALL
         SELECT 'material'::text AS filtro_categoria,
            (grupos_canonicos.material)::text AS filtro_valor,
            grupos_canonicos.preco_minimo,
            grupos_canonicos.preco_maximo,
            grupos_canonicos.preco_medio,
            grupos_canonicos.total_lentes
           FROM lens_catalog.grupos_canonicos
          WHERE (grupos_canonicos.total_lentes > 0)
        UNION ALL
         SELECT 'indice_refracao'::text AS filtro_categoria,
            (grupos_canonicos.indice_refracao)::text AS filtro_valor,
            grupos_canonicos.preco_minimo,
            grupos_canonicos.preco_maximo,
            grupos_canonicos.preco_medio,
            grupos_canonicos.total_lentes
           FROM lens_catalog.grupos_canonicos
          WHERE (grupos_canonicos.total_lentes > 0)
        UNION ALL
         SELECT 'categoria'::text AS filtro_categoria,
            (grupos_canonicos.categoria_predominante)::text AS filtro_valor,
            grupos_canonicos.preco_minimo,
            grupos_canonicos.preco_maximo,
            grupos_canonicos.preco_medio,
            grupos_canonicos.total_lentes
           FROM lens_catalog.grupos_canonicos
          WHERE (grupos_canonicos.total_lentes > 0)
        UNION ALL
         SELECT 'is_premium'::text AS filtro_categoria,
                CASE
                    WHEN grupos_canonicos.is_premium THEN 'premium'::text
                    ELSE 'generico'::text
                END AS filtro_valor,
            grupos_canonicos.preco_minimo,
            grupos_canonicos.preco_maximo,
            grupos_canonicos.preco_medio,
            grupos_canonicos.total_lentes
           FROM lens_catalog.grupos_canonicos
          WHERE (grupos_canonicos.total_lentes > 0)
        UNION ALL
         SELECT 'antirreflexo'::text AS filtro_categoria,
                CASE
                    WHEN grupos_canonicos.tem_antirreflexo THEN 'sim'::text
                    ELSE 'nao'::text
                END AS filtro_valor,
            grupos_canonicos.preco_minimo,
            grupos_canonicos.preco_maximo,
            grupos_canonicos.preco_medio,
            grupos_canonicos.total_lentes
           FROM lens_catalog.grupos_canonicos
          WHERE (grupos_canonicos.total_lentes > 0)
        UNION ALL
         SELECT 'blue_light'::text AS filtro_categoria,
                CASE
                    WHEN grupos_canonicos.tem_blue_light THEN 'sim'::text
                    ELSE 'nao'::text
                END AS filtro_valor,
            grupos_canonicos.preco_minimo,
            grupos_canonicos.preco_maximo,
            grupos_canonicos.preco_medio,
            grupos_canonicos.total_lentes
           FROM lens_catalog.grupos_canonicos
          WHERE (grupos_canonicos.total_lentes > 0)
        UNION ALL
         SELECT 'fotossensiveis'::text AS filtro_categoria,
            (grupos_canonicos.tratamento_foto)::text AS filtro_valor,
            grupos_canonicos.preco_minimo,
            grupos_canonicos.preco_maximo,
            grupos_canonicos.preco_medio,
            grupos_canonicos.total_lentes
           FROM lens_catalog.grupos_canonicos
          WHERE ((grupos_canonicos.total_lentes > 0) AND (grupos_canonicos.tratamento_foto IS NOT NULL) AND ((grupos_canonicos.tratamento_foto)::text <> 'nenhum'::text))) filtros_agregados
  GROUP BY filtro_categoria, filtro_valor
  ORDER BY filtro_categoria, (count(*)) DESC; |
| public       | v_grupos_canonicos               |  SELECT id,
    slug,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    categoria_predominante,
    grau_esferico_min,
    grau_esferico_max,
    grau_cilindrico_min,
    grau_cilindrico_max,
    adicao_min,
    adicao_max,
    descricao_ranges,
    tratamento_antirreflexo,
    tratamento_antirrisco,
    tratamento_uv,
    tratamento_blue_light,
    tratamento_fotossensiveis,
    preco_minimo,
    preco_maximo,
    preco_medio,
    total_lentes,
    total_marcas,
    peso,
    is_premium
   FROM lens_catalog.grupos_canonicos gc
  WHERE ((ativo = true) AND (is_premium = false))
  ORDER BY preco_medio;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| public       | v_grupos_canonicos_completos     |  SELECT id,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    preco_medio,
    ( SELECT jsonb_agg(jsonb_build_object('id', l.id, 'nome', f.nome, 'prazo_visao_simples', COALESCE(f.prazo_visao_simples, 0), 'prazo_multifocal', COALESCE(f.prazo_multifocal, 2))) AS jsonb_agg
           FROM (lens_catalog.lentes l
             JOIN core.fornecedores f ON ((l.fornecedor_id = f.id)))
          WHERE (l.grupo_canonico_id = gc.id)) AS fornecedores_disponiveis,
    ( SELECT count(*) AS count
           FROM lens_catalog.lentes l
          WHERE (l.grupo_canonico_id = gc.id)) AS total_lentes,
    false AS is_premium
   FROM lens_catalog.grupos_canonicos gc;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| lens_catalog | v_grupos_canonicos_detalhados    |  SELECT gc.id,
    gc.nome_grupo,
    gc.tipo_lente,
    gc.material,
    gc.indice_refracao,
    gc.grau_esferico_min,
    gc.grau_esferico_max,
    gc.grau_cilindrico_min,
    gc.grau_cilindrico_max,
    gc.adicao_min,
    gc.adicao_max,
    gc.descricao_ranges,
    gc.is_premium,
    gc.total_lentes,
    gc.total_marcas,
    gc.preco_minimo,
    gc.preco_maximo,
    gc.preco_medio,
    (gc.preco_maximo - gc.preco_minimo) AS variacao_preco,
        CASE
            WHEN ((gc.grau_esferico_max - gc.grau_esferico_min) >= (10)::numeric) THEN 'AMPLO'::text
            WHEN ((gc.grau_esferico_max - gc.grau_esferico_min) >= (5)::numeric) THEN 'MÉDIO'::text
            ELSE 'RESTRITO'::text
        END AS amplitude_esferico,
    array_agg(DISTINCT m.nome ORDER BY m.nome) AS marcas_disponiveis,
    ( SELECT l2.nome_lente
           FROM lens_catalog.lentes l2
          WHERE ((l2.grupo_canonico_id = gc.id) AND (l2.ativo = true))
          ORDER BY l2.preco_custo
         LIMIT 1) AS lente_mais_barata,
    ( SELECT l2.nome_lente
           FROM lens_catalog.lentes l2
          WHERE ((l2.grupo_canonico_id = gc.id) AND (l2.ativo = true))
          ORDER BY l2.preco_custo DESC
         LIMIT 1) AS lente_mais_cara
   FROM ((lens_catalog.grupos_canonicos gc
     LEFT JOIN lens_catalog.lentes l ON (((l.grupo_canonico_id = gc.id) AND (l.ativo = true))))
     LEFT JOIN lens_catalog.marcas m ON ((l.marca_id = m.id)))
  GROUP BY gc.id, gc.nome_grupo, gc.tipo_lente, gc.material, gc.indice_refracao, gc.grau_esferico_min, gc.grau_esferico_max, gc.grau_cilindrico_min, gc.grau_cilindrico_max, gc.adicao_min, gc.adicao_max, gc.descricao_ranges, gc.is_premium, gc.total_lentes, gc.total_marcas, gc.preco_minimo, gc.preco_maximo, gc.preco_medio;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| lens_catalog | v_grupos_canonicos_detalhados_v5 |  SELECT gc.id,
    gc.nome_grupo,
    gc.tipo_lente,
    gc.material,
    gc.indice_refracao,
    gc.grau_esferico_min,
    gc.grau_esferico_max,
    gc.grau_cilindrico_min,
    gc.grau_cilindrico_max,
    gc.adicao_min,
    gc.adicao_max,
    gc.descricao_ranges,
    gc.tratamento_antirreflexo,
    gc.tratamento_antirrisco,
    gc.tratamento_uv,
    gc.tratamento_blue_light,
    gc.tratamento_fotossensiveis,
    gc.is_premium,
    gc.total_lentes,
    gc.total_marcas,
    gc.preco_minimo,
    gc.preco_maximo,
    gc.preco_medio,
    (gc.preco_maximo - gc.preco_minimo) AS variacao_preco,
        CASE
            WHEN ((gc.total_lentes >= 5) AND (gc.total_marcas >= 3)) THEN 'EXCELENTE'::text
            WHEN ((gc.total_lentes >= 3) AND (gc.total_marcas >= 2)) THEN 'ÓTIMO'::text
            WHEN (gc.total_lentes >= 2) THEN 'BOM'::text
            ELSE 'LIMITADO'::text
        END AS nivel_comparabilidade,
    array_agg(DISTINCT m.nome ORDER BY m.nome) AS marcas_disponiveis,
    ( SELECT l2.nome_lente
           FROM lens_catalog.lentes l2
          WHERE ((l2.grupo_canonico_id = gc.id) AND (l2.ativo = true))
          ORDER BY l2.preco_custo
         LIMIT 1) AS lente_mais_barata,
    ( SELECT l2.nome_lente
           FROM lens_catalog.lentes l2
          WHERE ((l2.grupo_canonico_id = gc.id) AND (l2.ativo = true))
          ORDER BY l2.preco_custo DESC
         LIMIT 1) AS lente_mais_cara
   FROM ((lens_catalog.grupos_canonicos gc
     LEFT JOIN lens_catalog.lentes l ON (((l.grupo_canonico_id = gc.id) AND (l.ativo = true))))
     LEFT JOIN lens_catalog.marcas m ON ((l.marca_id = m.id)))
  GROUP BY gc.id, gc.nome_grupo, gc.tipo_lente, gc.material, gc.indice_refracao, gc.grau_esferico_min, gc.grau_esferico_max, gc.grau_cilindrico_min, gc.grau_cilindrico_max, gc.adicao_min, gc.adicao_max, gc.descricao_ranges, gc.tratamento_antirreflexo, gc.tratamento_antirrisco, gc.tratamento_uv, gc.tratamento_blue_light, gc.tratamento_fotossensiveis, gc.is_premium, gc.total_lentes, gc.total_marcas, gc.preco_minimo, gc.preco_maximo, gc.preco_medio;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| public       | v_grupos_com_lentes              |  SELECT id AS grupo_id,
    slug AS grupo_slug,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    preco_medio,
    preco_minimo,
    preco_maximo,
    ( SELECT jsonb_agg(jsonb_build_object('id', l.id, 'slug', l.slug, 'nome', l.nome_canonizado, 'fornecedor_id', f.id, 'fornecedor_nome', f.nome, 'marca', m.nome, 'preco', l.preco_venda_sugerido, 'prazo_dias', f.prazo_visao_simples, 'estoque', COALESCE(es.quantidade_disponivel, 0), 'tratamentos', jsonb_build_object('ar', l.tratamento_antirreflexo, 'antirrisco', l.tratamento_antirrisco, 'uv', l.tratamento_uv, 'blue_light', l.tratamento_blue_light, 'foto', l.tratamento_fotossensiveis)) ORDER BY l.preco_venda_sugerido) AS jsonb_agg
           FROM (((lens_catalog.lentes l
             JOIN core.fornecedores f ON ((l.fornecedor_id = f.id)))
             LEFT JOIN lens_catalog.marcas m ON ((l.marca_id = m.id)))
             LEFT JOIN compras.estoque_saldo es ON ((l.id = es.lente_id)))
          WHERE ((l.grupo_canonico_id = gc.id) AND (l.ativo = true) AND (l.status = 'ativo'::lens_catalog.status_lente))) AS lentes
   FROM lens_catalog.grupos_canonicos gc
  WHERE (EXISTS ( SELECT 1
           FROM lens_catalog.lentes l
          WHERE ((l.grupo_canonico_id = gc.id) AND (l.ativo = true))))
  ORDER BY is_premium DESC, preco_medio;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| public       | v_grupos_melhor_margem           |  WITH margem_calculada AS (
         SELECT gc.id AS grupo_id,
            gc.slug AS grupo_slug,
            gc.nome_grupo,
            gc.tipo_lente,
            gc.material,
            gc.indice_refracao,
            gc.tratamento_antirreflexo,
            gc.tratamento_antirrisco,
            gc.tratamento_uv,
            gc.tratamento_blue_light,
            gc.tratamento_fotossensiveis,
            gc.preco_minimo,
            gc.preco_medio,
            gc.preco_maximo,
            avg(l.preco_custo) AS custo_medio,
            min(l.preco_custo) AS custo_minimo,
            max(l.preco_custo) AS custo_maximo,
                CASE
                    WHEN (avg(l.preco_custo) > (0)::numeric) THEN ((((gc.preco_medio - avg(l.preco_custo)) / avg(l.preco_custo)) * (100)::numeric))::numeric(8,2)
                    ELSE (0)::numeric
                END AS margem_percentual,
            ((gc.preco_medio - avg(l.preco_custo)))::numeric(10,2) AS lucro_unitario,
                CASE
                    WHEN (avg(l.preco_custo) > (0)::numeric) THEN ((gc.preco_medio / avg(l.preco_custo)))::numeric(6,2)
                    ELSE NULL::numeric
                END AS markup,
            gc.total_lentes,
            gc.is_premium,
            count(DISTINCT l.marca_id) AS total_marcas,
            count(DISTINCT l.fornecedor_id) AS total_fornecedores
           FROM (lens_catalog.grupos_canonicos gc
             JOIN lens_catalog.lentes l ON (((l.grupo_canonico_id = gc.id) AND (l.ativo = true))))
          GROUP BY gc.id, gc.slug, gc.nome_grupo, gc.tipo_lente, gc.material, gc.indice_refracao, gc.tratamento_antirreflexo, gc.tratamento_antirrisco, gc.tratamento_uv, gc.tratamento_blue_light, gc.tratamento_fotossensiveis, gc.preco_minimo, gc.preco_medio, gc.preco_maximo, gc.total_lentes, gc.is_premium
        )
 SELECT grupo_id,
    grupo_slug,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    tratamento_antirreflexo,
    tratamento_antirrisco,
    tratamento_uv,
    tratamento_blue_light,
    tratamento_fotossensiveis,
    preco_minimo,
    preco_medio,
    preco_maximo,
    custo_medio,
    custo_minimo,
    custo_maximo,
    margem_percentual,
    lucro_unitario,
    markup,
    total_lentes,
    is_premium,
    total_marcas,
    total_fornecedores,
    row_number() OVER (ORDER BY margem_percentual DESC) AS ranking_margem,
    row_number() OVER (PARTITION BY tipo_lente ORDER BY margem_percentual DESC) AS ranking_por_tipo,
        CASE
            WHEN (margem_percentual >= (400)::numeric) THEN 'Excelente'::text
            WHEN (margem_percentual >= (350)::numeric) THEN 'Ótima'::text
            WHEN (margem_percentual >= (300)::numeric) THEN 'Boa'::text
            ELSE 'Regular'::text
        END AS classificacao_margem,
        CASE
            WHEN (markup >= 4.0) THEN true
            ELSE false
        END AS acima_markup_padrao
   FROM margem_calculada
  ORDER BY margem_percentual DESC;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| public       | v_grupos_por_faixa_preco         |  SELECT id AS grupo_id,
    slug AS grupo_slug,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    tratamento_antirreflexo,
    tratamento_antirrisco,
    tratamento_uv,
    tratamento_blue_light,
    tratamento_fotossensiveis,
    preco_minimo,
    preco_medio,
    preco_maximo,
        CASE
            WHEN (preco_medio < (150)::numeric) THEN '< R$150'::text
            WHEN ((preco_medio >= (150)::numeric) AND (preco_medio < (300)::numeric)) THEN 'R$150-300'::text
            WHEN ((preco_medio >= (300)::numeric) AND (preco_medio < (500)::numeric)) THEN 'R$300-500'::text
            WHEN ((preco_medio >= (500)::numeric) AND (preco_medio < (800)::numeric)) THEN 'R$500-800'::text
            ELSE 'R$800+'::text
        END AS faixa_preco,
        CASE
            WHEN (preco_medio < (150)::numeric) THEN 1
            WHEN ((preco_medio >= (150)::numeric) AND (preco_medio < (300)::numeric)) THEN 2
            WHEN ((preco_medio >= (300)::numeric) AND (preco_medio < (500)::numeric)) THEN 3
            WHEN ((preco_medio >= (500)::numeric) AND (preco_medio < (800)::numeric)) THEN 4
            ELSE 5
        END AS faixa_ordem,
        CASE
            WHEN (preco_medio < (150)::numeric) THEN 'R$150-300'::text
            WHEN ((preco_medio >= (150)::numeric) AND (preco_medio < (300)::numeric)) THEN 'R$300-500'::text
            WHEN ((preco_medio >= (300)::numeric) AND (preco_medio < (500)::numeric)) THEN 'R$500-800'::text
            WHEN ((preco_medio >= (500)::numeric) AND (preco_medio < (800)::numeric)) THEN 'R$800+'::text
            ELSE NULL::text
        END AS proxima_faixa,
        CASE
            WHEN (preco_medio < (150)::numeric) THEN 'Entrada'::text
            WHEN ((preco_medio >= (150)::numeric) AND (preco_medio < (300)::numeric)) THEN 'Básico'::text
            WHEN ((preco_medio >= (300)::numeric) AND (preco_medio < (500)::numeric)) THEN 'Intermediário'::text
            WHEN ((preco_medio >= (500)::numeric) AND (preco_medio < (800)::numeric)) THEN 'Premium'::text
            ELSE 'Super Premium'::text
        END AS descricao_faixa,
    total_lentes,
    is_premium,
    ( SELECT count(DISTINCT lentes.marca_id) AS count
           FROM lens_catalog.lentes
          WHERE ((lentes.grupo_canonico_id = gc.id) AND (lentes.ativo = true))) AS total_marcas,
    ( SELECT count(DISTINCT lentes.fornecedor_id) AS count
           FROM lens_catalog.lentes
          WHERE ((lentes.grupo_canonico_id = gc.id) AND (lentes.ativo = true))) AS total_fornecedores
   FROM lens_catalog.grupos_canonicos gc
  ORDER BY preco_medio;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| public       | v_grupos_por_receita_cliente     |  SELECT gc.id AS grupo_id,
    gc.slug AS grupo_slug,
    gc.nome_grupo,
    gc.tipo_lente,
    gc.material,
    gc.indice_refracao,
    min(l.grau_esferico_min) AS grau_esferico_min,
    max(l.grau_esferico_max) AS grau_esferico_max,
    min(l.grau_cilindrico_min) AS grau_cilindrico_min,
    max(l.grau_cilindrico_max) AS grau_cilindrico_max,
    min(l.adicao_min) AS adicao_min,
    max(l.adicao_max) AS adicao_max,
    gc.tratamento_antirreflexo,
    gc.tratamento_antirrisco,
    gc.tratamento_uv,
    gc.tratamento_blue_light,
    gc.tratamento_fotossensiveis,
    gc.preco_minimo,
    gc.preco_medio,
    gc.preco_maximo,
    avg(l.preco_custo) AS custo_medio,
        CASE
            WHEN (avg(l.preco_custo) > (0)::numeric) THEN ((gc.preco_medio / avg(l.preco_custo)))::numeric(5,2)
            ELSE NULL::numeric
        END AS margem_media,
        CASE
            WHEN (gc.preco_medio < (150)::numeric) THEN 'economica'::text
            WHEN ((gc.preco_medio >= (150)::numeric) AND (gc.preco_medio <= (400)::numeric)) THEN 'intermediaria'::text
            ELSE 'premium'::text
        END AS categoria_sugerida,
    gc.total_lentes,
    count(DISTINCT l.fornecedor_id) AS total_fornecedores,
    count(DISTINCT l.marca_id) AS total_marcas,
    gc.is_premium,
    (avg(
        CASE gc.tipo_lente
            WHEN 'visao_simples'::lens_catalog.tipo_lente THEN COALESCE(f.prazo_visao_simples, 7)
            WHEN 'multifocal'::lens_catalog.tipo_lente THEN COALESCE(f.prazo_multifocal, 10)
            WHEN 'bifocal'::lens_catalog.tipo_lente THEN COALESCE(f.prazo_multifocal, 10)
            WHEN 'leitura'::lens_catalog.tipo_lente THEN COALESCE(f.prazo_visao_simples, 7)
            WHEN 'ocupacional'::lens_catalog.tipo_lente THEN COALESCE(f.prazo_multifocal, 10)
            ELSE 10
        END))::integer AS prazo_medio_dias
   FROM ((lens_catalog.grupos_canonicos gc
     JOIN lens_catalog.lentes l ON (((l.grupo_canonico_id = gc.id) AND (l.ativo = true))))
     LEFT JOIN core.fornecedores f ON ((f.id = l.fornecedor_id)))
  GROUP BY gc.id, gc.slug, gc.nome_grupo, gc.tipo_lente, gc.material, gc.indice_refracao, gc.tratamento_antirreflexo, gc.tratamento_antirrisco, gc.tratamento_uv, gc.tratamento_blue_light, gc.tratamento_fotossensiveis, gc.preco_minimo, gc.preco_medio, gc.preco_maximo, gc.total_lentes, gc.is_premium
  ORDER BY gc.preco_medio;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| public       | v_grupos_premium                 |  SELECT id,
    slug,
    nome_grupo,
    tipo_lente,
    material,
    indice_refracao,
    categoria_predominante,
    grau_esferico_min,
    grau_esferico_max,
    grau_cilindrico_min,
    grau_cilindrico_max,
    adicao_min,
    adicao_max,
    descricao_ranges,
    tratamento_antirreflexo,
    tratamento_antirrisco,
    tratamento_uv,
    tratamento_blue_light,
    tratamento_fotossensiveis,
    preco_minimo,
    preco_maximo,
    preco_medio,
    total_lentes,
    total_marcas,
    peso,
    is_premium,
    COALESCE(( SELECT jsonb_agg(DISTINCT jsonb_build_object('marca_id', m.id, 'marca_nome', m.nome, 'marca_slug', m.slug, 'is_premium', m.is_premium)) AS jsonb_agg
           FROM (lens_catalog.lentes l
             JOIN lens_catalog.marcas m ON ((m.id = l.marca_id)))
          WHERE ((l.grupo_canonico_id = gc.id) AND (l.ativo = true) AND (m.ativo = true))), '[]'::jsonb) AS marcas_disponiveis,
    COALESCE(( SELECT string_agg(DISTINCT (m.nome)::text, ', '::text ORDER BY (m.nome)::text) AS string_agg
           FROM (lens_catalog.lentes l
             JOIN lens_catalog.marcas m ON ((m.id = l.marca_id)))
          WHERE ((l.grupo_canonico_id = gc.id) AND (l.ativo = true) AND (m.ativo = true))), ''::text) AS marcas_nomes
   FROM lens_catalog.grupos_canonicos gc
  WHERE ((ativo = true) AND (is_premium = true))
  ORDER BY preco_medio;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |

-- Query 3.2: Verificar se v_grupos_canonicos existe
SELECT 
    schemaname,
    viewname,
    viewowner
FROM pg_views
WHERE viewname = 'v_grupos_canonicos';

| schemaname | viewname           | viewowner |
| ---------- | ------------------ | --------- |
| public     | v_grupos_canonicos | postgres  |

-- Query 3.3: Verificar se vw_canonicas_genericas existe
SELECT 
    schemaname,
    viewname,
    viewowner
FROM pg_views
WHERE viewname = 'vw_canonicas_genericas';

| schemaname | viewname               | viewowner |
| ---------- | ---------------------- | --------- |
| public     | vw_canonicas_genericas | postgres  |


-- ===========================================================================
-- SEÇÃO 4: ANALISAR DADOS EXISTENTES (SE TABELA/VIEW EXISTIR)
-- ===========================================================================

-- Query 4.1: Contar registros em grupos_canonicos (SE EXISTIR)
-- Descomente após confirmar que existe:
-- SELECT COUNT(*) as total_grupos
-- FROM lens_catalog.grupos_canonicos;

-- Query 4.2: Ver amostra de dados (SE EXISTIR)
-- Descomente após confirmar que existe:
-- SELECT * FROM lens_catalog.grupos_canonicos LIMIT 5;


-- ===========================================================================
-- SEÇÃO 5: ANALISAR LENTES E SEUS AGRUPAMENTOS
-- ===========================================================================

-- Query 5.1: Ver campos de agrupamento nas lentes
SELECT 
    material,
    indice_refracao,
    tipo_lente,
    COUNT(*) as quantidade_lentes
FROM lens_catalog.lentes
WHERE ativo = true
GROUP BY material, indice_refracao, tipo_lente
ORDER BY quantidade_lentes DESC
LIMIT 20;


| material      | indice_refracao | tipo_lente    | quantidade_lentes |
| ------------- | --------------- | ------------- | ----------------- |
| POLICARBONATO | 1.59            | multifocal    | 253               |
| CR39          | 1.50            | multifocal    | 251               |
| CR39          | 1.67            | multifocal    | 203               |
| CR39          | 1.74            | multifocal    | 157               |
| POLICARBONATO | 1.59            | visao_simples | 101               |
| CR39          | 1.56            | visao_simples | 93                |
| CR39          | 1.56            | multifocal    | 89                |
| CR39          | 1.67            | visao_simples | 83                |
| CR39          | 1.50            | visao_simples | 82                |
| CR39          | 1.74            | visao_simples | 73                |
| CR39          | 1.61            | visao_simples | 20                |
| CR39          | 1.59            | multifocal    | 4                 |
| CR39          | 1.50            | bifocal       | 2                 |

-- Query 5.2: Verificar se lentes têm is_premium
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'lens_catalog' 
  AND table_name = 'lentes'
  AND column_name IN ('is_premium', 'categoria', 'grupo_canonico_id', 'grupo_id');

| column_name       | data_type    |
| ----------------- | ------------ |
| grupo_canonico_id | uuid         |
| categoria         | USER-DEFINED |



-- Query 5.3: Ver distribuição por categoria (se existir)
-- Descomente após confirmar campo:
-- SELECT 
--     categoria,
--     COUNT(*) as total
-- FROM lens_catalog.lentes
-- WHERE ativo = true
-- GROUP BY categoria;


-- ===========================================================================
-- SEÇÃO 6: VERIFICAR SCHEMAS DO PROJETO
-- ===========================================================================

-- Query 6.1: Listar todos os schemas
SELECT 
    schema_name
FROM information_schema.schemata
WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
ORDER BY schema_name;

| schema_name      |
| ---------------- |
| auth             |
| compras          |
| contact_lens     |
| core             |
| extensions       |
| graphql          |
| graphql_public   |
| lens_catalog     |
| pg_temp_0        |
| pg_temp_1        |
| pg_temp_10       |
| pg_temp_11       |
| pg_temp_12       |
| pg_temp_13       |
| pg_temp_14       |
| pg_temp_15       |
| pg_temp_16       |
| pg_temp_17       |
| pg_temp_18       |
| pg_temp_19       |
| pg_temp_2        |
| pg_temp_20       |
| pg_temp_21       |
| pg_temp_22       |
| pg_temp_23       |
| pg_temp_24       |
| pg_temp_25       |
| pg_temp_26       |
| pg_temp_27       |
| pg_temp_28       |
| pg_temp_29       |
| pg_temp_3        |
| pg_temp_30       |
| pg_temp_31       |
| pg_temp_32       |
| pg_temp_33       |
| pg_temp_34       |
| pg_temp_35       |
| pg_temp_36       |
| pg_temp_37       |
| pg_temp_38       |
| pg_temp_39       |
| pg_temp_4        |
| pg_temp_40       |
| pg_temp_41       |
| pg_temp_42       |
| pg_temp_43       |
| pg_temp_44       |
| pg_temp_45       |
| pg_temp_46       |
| pg_temp_47       |
| pg_temp_48       |
| pg_temp_49       |
| pg_temp_5        |
| pg_temp_50       |
| pg_temp_51       |
| pg_temp_52       |
| pg_temp_53       |
| pg_temp_54       |
| pg_temp_55       |
| pg_temp_56       |
| pg_temp_57       |
| pg_temp_58       |
| pg_temp_59       |
| pg_temp_6        |
| pg_temp_7        |
| pg_temp_8        |
| pg_temp_9        |
| pg_toast_temp_0  |
| pg_toast_temp_1  |
| pg_toast_temp_10 |
| pg_toast_temp_11 |
| pg_toast_temp_12 |
| pg_toast_temp_13 |
| pg_toast_temp_14 |
| pg_toast_temp_15 |
| pg_toast_temp_16 |
| pg_toast_temp_17 |
| pg_toast_temp_18 |
| pg_toast_temp_19 |
| pg_toast_temp_2  |
| pg_toast_temp_20 |
| pg_toast_temp_21 |
| pg_toast_temp_22 |
| pg_toast_temp_23 |
| pg_toast_temp_24 |
| pg_toast_temp_25 |
| pg_toast_temp_26 |
| pg_toast_temp_27 |
| pg_toast_temp_28 |
| pg_toast_temp_29 |
| pg_toast_temp_3  |
| pg_toast_temp_30 |
| pg_toast_temp_31 |
| pg_toast_temp_32 |
| pg_toast_temp_33 |
| pg_toast_temp_34 |
| pg_toast_temp_35 |
| pg_toast_temp_36 |
| pg_toast_temp_37 |
| pg_toast_temp_38 |
| pg_toast_temp_39 |
| pg_toast_temp_4  |
| pg_toast_temp_40 |
| pg_toast_temp_41 |
| pg_toast_temp_42 |
| pg_toast_temp_43 |
| pg_toast_temp_44 |
| pg_toast_temp_45 |
| pg_toast_temp_46 |
| pg_toast_temp_47 |
| pg_toast_temp_48 |
| pg_toast_temp_49 |
| pg_toast_temp_5  |
| pg_toast_temp_50 |
| pg_toast_temp_51 |
| pg_toast_temp_52 |
| pg_toast_temp_53 |
| pg_toast_temp_54 |
| pg_toast_temp_55 |
| pg_toast_temp_56 |
| pg_toast_temp_57 |
| pg_toast_temp_58 |
| pg_toast_temp_59 |
| pg_toast_temp_6  |
| pg_toast_temp_7  |
| pg_toast_temp_8  |
| pg_toast_temp_9  |
| pgbouncer        |
| public           |
| public_api       |
| realtime         |
| storage          |
| vault            |



-- Query 6.2: Ver tabelas por schema relevante
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema IN ('public', 'lens_catalog', 'core', 'suppliers')
  AND table_type = 'BASE TABLE'
ORDER BY table_schema, table_name;

| table_schema | table_name                  | table_type |
| ------------ | --------------------------- | ---------- |
| core         | fornecedores                | BASE TABLE |
| lens_catalog | grupos_canonicos            | BASE TABLE |
| lens_catalog | grupos_canonicos_backup_old | BASE TABLE |
| lens_catalog | grupos_canonicos_log        | BASE TABLE |
| lens_catalog | lentes                      | BASE TABLE |
| lens_catalog | lentes_canonicas            | BASE TABLE |
| lens_catalog | lentes_grupos_backup_old    | BASE TABLE |
| lens_catalog | marcas                      | BASE TABLE |
| lens_catalog | premium_canonicas           | BASE TABLE |
| lens_catalog | stg_lentes_import           | BASE TABLE |


-- ===========================================================================
-- SEÇÃO 7: VERIFICAR FOREIGN KEYS E RELACIONAMENTOS
-- ===========================================================================

-- Query 7.1: Ver foreign keys da tabela lentes
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'lens_catalog'
  AND tc.table_name = 'lentes';

| constraint_name               | table_name | column_name       | foreign_table_schema | foreign_table_name | foreign_column_name |
| ----------------------------- | ---------- | ----------------- | -------------------- | ------------------ | ------------------- |
| lentes_grupo_canonico_id_fkey | lentes     | grupo_canonico_id | lens_catalog         | grupos_canonicos   | id                  |
| lentes_marca_id_fkey          | lentes     | marca_id          | lens_catalog         | marcas             | id                  |


-- ===========================================================================
-- INSTRUÇÕES DE USO
-- ===========================================================================
/*

COMO USAR ESTE ARQUIVO:

1. Abra o Supabase SQL Editor
2. Execute CADA SEÇÃO separadamente
3. Copie os resultados e cole aqui como comentários

EXEMPLO:
-- RESULTADO Query 1.1:
-- | schemaname | tablename | tableowner |
-- |------------|-----------|------------|
-- | public     | lentes    | postgres   |

4. Depois de todas as respostas, saberemos:
   - Se grupos_canonicos existe
   - Estrutura real da tabela lentes
   - Quais views estão criadas
   - Como devemos proceder

*/
