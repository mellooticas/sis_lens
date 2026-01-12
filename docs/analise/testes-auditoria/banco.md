-- Ver todos os schemas
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
ORDER BY schema_name;

| schema_name      |
| ---------------- |
| analytics        |
| api              |
| auth             |
| commercial       |
| extensions       |
| graphql          |
| graphql_public   |
| lens_catalog     |
| logistics        |
| meta_system      |
| orders           |
| pg_temp_0        |
| pg_temp_1        |
| pg_temp_11       |
| pg_temp_13       |
| pg_temp_14       |
| pg_temp_15       |
| pg_temp_16       |
| pg_temp_18       |
| pg_temp_19       |
| pg_temp_2        |
| pg_temp_22       |
| pg_temp_25       |
| pg_temp_26       |
| pg_temp_27       |
| pg_temp_28       |
| pg_temp_29       |
| pg_temp_30       |
| pg_temp_31       |
| pg_temp_32       |
| pg_temp_34       |
| pg_temp_36       |
| pg_temp_37       |
| pg_temp_38       |
| pg_temp_39       |
| pg_temp_42       |
| pg_temp_43       |
| pg_temp_44       |
| pg_temp_45       |
| pg_temp_47       |
| pg_temp_48       |
| pg_temp_49       |
| pg_temp_50       |
| pg_temp_51       |
| pg_temp_52       |
| pg_temp_54       |
| pg_temp_55       |
| pg_temp_56       |
| pg_temp_57       |
| pg_temp_59       |
| pg_temp_6        |
| pg_temp_7        |
| pg_temp_8        |
| pg_temp_9        |
| pg_toast_temp_0  |
| pg_toast_temp_1  |
| pg_toast_temp_11 |
| pg_toast_temp_13 |
| pg_toast_temp_14 |
| pg_toast_temp_15 |
| pg_toast_temp_16 |
| pg_toast_temp_18 |
| pg_toast_temp_19 |
| pg_toast_temp_2  |
| pg_toast_temp_22 |
| pg_toast_temp_25 |
| pg_toast_temp_26 |
| pg_toast_temp_27 |
| pg_toast_temp_28 |
| pg_toast_temp_29 |
| pg_toast_temp_30 |
| pg_toast_temp_31 |
| pg_toast_temp_32 |
| pg_toast_temp_34 |
| pg_toast_temp_36 |
| pg_toast_temp_37 |
| pg_toast_temp_38 |
| pg_toast_temp_39 |
| pg_toast_temp_42 |
| pg_toast_temp_43 |
| pg_toast_temp_44 |
| pg_toast_temp_45 |
| pg_toast_temp_47 |
| pg_toast_temp_48 |
| pg_toast_temp_49 |
| pg_toast_temp_50 |
| pg_toast_temp_51 |
| pg_toast_temp_52 |
| pg_toast_temp_54 |
| pg_toast_temp_55 |
| pg_toast_temp_56 |
| pg_toast_temp_57 |
| pg_toast_temp_59 |
| pg_toast_temp_6  |
| pg_toast_temp_7  |
| pg_toast_temp_8  |
| pg_toast_temp_9  |
| pgbouncer        |
| public           |
| public_api       |
| realtime         |
| scoring          |
| storage          |
| suppliers        |
| vault            |

-- Ver todas as tabelas por schema
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
ORDER BY table_schema, table_name;

| table_schema | table_name                 | table_type |
| ------------ | -------------------------- | ---------- |
| analytics    | alertas_analytics          | BASE TABLE |
| analytics    | execucoes_relatorios       | BASE TABLE |
| analytics    | metricas_kpi               | BASE TABLE |
| analytics    | relatorios_configuracao    | BASE TABLE |
| analytics    | valores_kpi                | BASE TABLE |
| auth         | audit_log_entries          | BASE TABLE |
| auth         | flow_state                 | BASE TABLE |
| auth         | identities                 | BASE TABLE |
| auth         | instances                  | BASE TABLE |
| auth         | mfa_amr_claims             | BASE TABLE |
| auth         | mfa_challenges             | BASE TABLE |
| auth         | mfa_factors                | BASE TABLE |
| auth         | oauth_clients              | BASE TABLE |
| auth         | one_time_tokens            | BASE TABLE |
| auth         | refresh_tokens             | BASE TABLE |
| auth         | saml_providers             | BASE TABLE |
| auth         | saml_relay_states          | BASE TABLE |
| auth         | schema_migrations          | BASE TABLE |
| auth         | sessions                   | BASE TABLE |
| auth         | sso_domains                | BASE TABLE |
| auth         | sso_providers              | BASE TABLE |
| auth         | users                      | BASE TABLE |
| commercial   | descontos                  | BASE TABLE |
| commercial   | historico_precos           | BASE TABLE |
| commercial   | precos_base                | BASE TABLE |
| extensions   | pg_stat_statements         | VIEW       |
| extensions   | pg_stat_statements_info    | VIEW       |
| lens_catalog | lentes                     | BASE TABLE |
| lens_catalog | lentes_canonicas           | BASE TABLE |
| lens_catalog | lentes_premium             | BASE TABLE |
| lens_catalog | marcas                     | BASE TABLE |
| logistics    | historico_entregas         | BASE TABLE |
| logistics    | tabela_prazos              | BASE TABLE |
| logistics    | zonas_entrega              | BASE TABLE |
| meta_system  | feature_flags              | BASE TABLE |
| meta_system  | parametros_tenant          | BASE TABLE |
| meta_system  | tenants                    | BASE TABLE |
| orders       | alternativas_cotacao       | BASE TABLE |
| orders       | criterios_decisao          | BASE TABLE |
| orders       | decisoes_lentes            | BASE TABLE |
| orders       | historico_status           | BASE TABLE |
| public       | clientes                   | BASE TABLE |
| public       | configuracoes              | BASE TABLE |
| public       | consultas_lens_log         | BASE TABLE |
| public       | controle_vouchers_mensal   | BASE TABLE |
| public       | decisoes_compra            | VIEW       |
| public       | logs                       | BASE TABLE |
| public       | lojas                      | BASE TABLE |
| public       | mv_economia_por_fornecedor | VIEW       |
| public       | produtos_laboratorio       | VIEW       |
| public       | ranking_vouchers           | BASE TABLE |
| public       | relatorios                 | BASE TABLE |
| public       | sistema_config_bestlens    | BASE TABLE |
| public       | usuarios                   | BASE TABLE |
| public       | v_configuracoes_sistema    | VIEW       |
| public       | v_dashboard_vouchers       | VIEW       |
| public       | v_historico_consultas      | VIEW       |
| public       | v_ranking_economia         | VIEW       |
| public       | v_user_profile             | VIEW       |
| public       | v_vouchers_disponiveis     | VIEW       |
| public       | vouchers                   | BASE TABLE |
| public       | vouchers_desconto          | BASE TABLE |
| public       | vw_fornecedores            | VIEW       |
| public       | vw_lentes_catalogo         | VIEW       |
| public       | vw_todas_lentes            | VIEW       |
| public       | vw_usuarios                | VIEW       |
| realtime     | messages                   | BASE TABLE |
| realtime     | schema_migrations          | BASE TABLE |
| realtime     | subscription               | BASE TABLE |
| scoring      | avaliacoes_laboratorios    | BASE TABLE |
| scoring      | criterios_scoring          | BASE TABLE |
| scoring      | historico_scores           | BASE TABLE |
| scoring      | scores_laboratorios        | BASE TABLE |
| storage      | buckets                    | BASE TABLE |
| storage      | buckets_analytics          | BASE TABLE |
| storage      | migrations                 | BASE TABLE |
| storage      | objects                    | BASE TABLE |
| storage      | prefixes                   | BASE TABLE |
| storage      | s3_multipart_uploads       | BASE TABLE |
| storage      | s3_multipart_uploads_parts | BASE TABLE |
| suppliers    | historico_produtos         | BASE TABLE |
| suppliers    | laboratorios               | BASE TABLE |
| suppliers    | produtos_laboratorio       | BASE TABLE |
| vault        | decrypted_secrets          | VIEW       |
| vault        | secrets                    | BASE TABLE |


-- Ver todas as views
SELECT 
    table_schema,
    table_name,
    view_definition
FROM information_schema.views 
WHERE table_schema NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
ORDER BY table_schema, table_name;

| table_schema | table_name                 | view_definition                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ------------ | -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| extensions   | pg_stat_statements         |  SELECT userid,
    dbid,
    toplevel,
    queryid,
    query,
    plans,
    total_plan_time,
    min_plan_time,
    max_plan_time,
    mean_plan_time,
    stddev_plan_time,
    calls,
    total_exec_time,
    min_exec_time,
    max_exec_time,
    mean_exec_time,
    stddev_exec_time,
    rows,
    shared_blks_hit,
    shared_blks_read,
    shared_blks_dirtied,
    shared_blks_written,
    local_blks_hit,
    local_blks_read,
    local_blks_dirtied,
    local_blks_written,
    temp_blks_read,
    temp_blks_written,
    shared_blk_read_time,
    shared_blk_write_time,
    local_blk_read_time,
    local_blk_write_time,
    temp_blk_read_time,
    temp_blk_write_time,
    wal_records,
    wal_fpi,
    wal_bytes,
    jit_functions,
    jit_generation_time,
    jit_inlining_count,
    jit_inlining_time,
    jit_optimization_count,
    jit_optimization_time,
    jit_emission_count,
    jit_emission_time,
    jit_deform_count,
    jit_deform_time,
    stats_since,
    minmax_stats_since
   FROM pg_stat_statements(true) pg_stat_statements(userid, dbid, toplevel, queryid, query, plans, total_plan_time, min_plan_time, max_plan_time, mean_plan_time, stddev_plan_time, calls, total_exec_time, min_exec_time, max_exec_time, mean_exec_time, stddev_exec_time, rows, shared_blks_hit, shared_blks_read, shared_blks_dirtied, shared_blks_written, local_blks_hit, local_blks_read, local_blks_dirtied, local_blks_written, temp_blks_read, temp_blks_written, shared_blk_read_time, shared_blk_write_time, local_blk_read_time, local_blk_write_time, temp_blk_read_time, temp_blk_write_time, wal_records, wal_fpi, wal_bytes, jit_functions, jit_generation_time, jit_inlining_count, jit_inlining_time, jit_optimization_count, jit_optimization_time, jit_emission_count, jit_emission_time, jit_deform_count, jit_deform_time, stats_since, minmax_stats_since); |
| extensions   | pg_stat_statements_info    |  SELECT dealloc,
    stats_reset
   FROM pg_stat_statements_info() pg_stat_statements_info(dealloc, stats_reset);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| public       | decisoes_compra            |  SELECT id,
    tenant_id,
    lente_recomendada_id,
    laboratorio_escolhido_id,
    preco_final,
    prazo_estimado_dias,
    score_atribuido,
    criterio_usado,
    decidido_por,
    decidido_em,
    status,
    confirmado_em
   FROM orders.decisoes_lentes "dec";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| public       | mv_economia_por_fornecedor |  SELECT lab.id AS laboratorio_id,
    lab.nome_fantasia AS laboratorio_nome,
    count("dec".id) AS total_decisoes,
    avg("dec".preco_final) AS preco_medio,
    sum("dec".preco_final) AS economia_total,
    avg("dec".score_atribuido) AS score_medio
   FROM (suppliers.laboratorios lab
     LEFT JOIN orders.decisoes_lentes "dec" ON ((lab.id = "dec".laboratorio_escolhido_id)))
  WHERE (lab.ativo = true)
  GROUP BY lab.id, lab.nome_fantasia;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| public       | produtos_laboratorio       |  SELECT prod.id,
    prod.tenant_id,
    prod.laboratorio_id,
    prod.lente_id,
    prod.sku_laboratorio,
    prod.nome_comercial,
    prod.sku_fantasia,
    prod.qualidade_base,
    prod.disponivel,
    prod.descontinuado_em,
    prod.criado_em,
    prod.atualizado_em,
    lab.nome_fantasia AS laboratorio_nome,
    50 AS credibilidade_score,
    lente.sku_canonico AS lente_sku,
    lente.familia AS lente_familia
   FROM ((suppliers.produtos_laboratorio prod
     LEFT JOIN suppliers.laboratorios lab ON ((prod.laboratorio_id = lab.id)))
     LEFT JOIN lens_catalog.lentes lente ON ((prod.lente_id = lente.id)));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| public       | v_configuracoes_sistema    |  SELECT chave,
    valor,
    descricao,
    editavel_por,
    created_at,
    updated_at
   FROM sistema_config_bestlens
  WHERE (EXISTS ( SELECT 1
           FROM usuarios u
          WHERE ((u.auth_user_id = auth.uid()) AND (u.role = ANY (ARRAY['financeiro_supervisor'::user_role_enum, 'admin_junior'::user_role_enum])))));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| public       | v_dashboard_vouchers       |  SELECT periodo,
    total_vouchers_gerados,
    total_vouchers_utilizados,
    valor_total_economia_gerada,
    valor_total_economia_potencial,
    limite_vouchers_periodo,
    limite_valor_periodo,
    round((((total_vouchers_gerados)::numeric * 100.0) / (limite_vouchers_periodo)::numeric), 1) AS pct_vouchers_usado,
    round(((valor_total_economia_potencial * 100.0) / limite_valor_periodo), 1) AS pct_valor_usado,
        CASE
            WHEN ((total_vouchers_gerados)::numeric >= ((limite_vouchers_periodo)::numeric * 0.9)) THEN 'critico'::text
            WHEN ((total_vouchers_gerados)::numeric >= ((limite_vouchers_periodo)::numeric * 0.8)) THEN 'alerta'::text
            ELSE 'normal'::text
        END AS status_quantidade,
        CASE
            WHEN (valor_total_economia_potencial >= (limite_valor_periodo * 0.9)) THEN 'critico'::text
            WHEN (valor_total_economia_potencial >= (limite_valor_periodo * 0.8)) THEN 'alerta'::text
            ELSE 'normal'::text
        END AS status_valor,
    bloqueado,
    motivo_bloqueio
   FROM controle_vouchers_mensal
  WHERE (periodo = (date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone))::date);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| public       | v_historico_consultas      |  SELECT c.id,
    c.tipo_consulta,
    c.parametros_consulta,
    c.resultado_consulta,
    c.economia_gerada,
    c.tempo_execucao_ms,
    c.created_at,
    v.codigo AS voucher_codigo,
    v.percentual_desconto AS voucher_desconto
   FROM (consultas_lens_log c
     LEFT JOIN vouchers_desconto v ON ((c.voucher_gerado_id = v.id)))
  WHERE (c.usuario_id IN ( SELECT usuarios.id
           FROM usuarios
          WHERE (usuarios.auth_user_id = auth.uid())))
  ORDER BY c.created_at DESC;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| public       | v_ranking_economia         |  SELECT row_number() OVER (ORDER BY r.economia_total_gerada DESC) AS posicao,
    u.nome,
    u.email,
    u.role,
    r.vouchers_gerados,
    r.vouchers_utilizados,
    r.economia_total_gerada,
    r.economia_media_por_voucher,
        CASE
            WHEN (r.vouchers_gerados > 0) THEN round((((r.vouchers_utilizados)::numeric / (r.vouchers_gerados)::numeric) * (100)::numeric), 1)
            ELSE (0)::numeric
        END AS taxa_utilizacao,
    r.premiado,
    r.periodo
   FROM (ranking_vouchers r
     JOIN usuarios u ON ((r.usuario_id = u.id)))
  WHERE (r.periodo = (date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone))::date)
  ORDER BY r.economia_total_gerada DESC;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| public       | v_user_profile             |  SELECT u.id,
    u.email,
    u.nome,
    u.role,
    u.permissoes_especiais,
    u.ativo,
    u.ultimo_acesso,
    u.limite_consultas_dia,
    u.vouchers_gerados_mes,
    u.loja_id,
    COALESCE(stats.vouchers_criados_mes, (0)::bigint) AS vouchers_criados_este_mes,
    COALESCE(stats.consultas_hoje, (0)::bigint) AS consultas_realizadas_hoje,
    COALESCE(stats.economia_gerada_mes, (0)::numeric) AS economia_gerada_este_mes
   FROM (usuarios u
     LEFT JOIN ( SELECT consultas_lens_log.usuario_id,
            count(*) FILTER (WHERE (date_trunc('month'::text, consultas_lens_log.created_at) = date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone))) AS vouchers_criados_mes,
            count(*) FILTER (WHERE ((date(consultas_lens_log.created_at) = CURRENT_DATE) AND (consultas_lens_log.tipo_consulta <> 'voucher_generation'::text))) AS consultas_hoje,
            COALESCE(sum(consultas_lens_log.economia_gerada) FILTER (WHERE (date_trunc('month'::text, consultas_lens_log.created_at) = date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone))), (0)::numeric) AS economia_gerada_mes
           FROM consultas_lens_log
          GROUP BY consultas_lens_log.usuario_id) stats ON ((u.id = stats.usuario_id)))
  WHERE (u.auth_user_id = auth.uid());                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| public       | v_vouchers_disponiveis     |  SELECT v.id,
    v.codigo,
    v.percentual_desconto,
    v.valor_minimo_pedido,
    v.valor_maximo_desconto,
    v.valido_ate,
    v.observacoes,
    v.ativo,
    v.usado,
    v.created_at,
    COALESCE(u_criador.nome, 'Sistema'::text) AS criado_por,
    COALESCE(u_criador.role, 'admin_junior'::user_role_enum) AS criador_role,
    EXTRACT(day FROM (v.valido_ate - now())) AS dias_restantes,
        CASE
            WHEN v.usado THEN 'usado'::text
            WHEN (v.valido_ate < now()) THEN 'expirado'::text
            WHEN (NOT v.ativo) THEN 'inativo'::text
            ELSE 'disponivel'::text
        END AS status_voucher
   FROM (vouchers_desconto v
     LEFT JOIN usuarios u_criador ON ((v.usuario_gerador_id = u_criador.auth_user_id)))
  WHERE ((v.ativo = true) AND (v.usado = false) AND (v.valido_ate > now()));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| public       | vw_fornecedores            |  SELECT id,
    tenant_id,
    nome_fantasia AS nome,
    cnpj,
    contato_comercial AS contato,
    ativo,
    50 AS credibilidade_score
   FROM suppliers.laboratorios lab
  WHERE (ativo = true);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| public       | vw_lentes_catalogo         |  SELECT l.id AS lente_id,
    l.tenant_id,
    l.sku_canonico,
    l.familia,
    l.design,
    l.material,
    l.indice_refracao,
    l.tratamentos,
    l.tipo_lente,
    l.ativo,
    m.nome AS marca_nome,
    concat(m.nome, ' ', l.familia, ' ', l.design) AS descricao_completa
   FROM (lens_catalog.lentes l
     LEFT JOIN lens_catalog.marcas m ON ((l.marca_id = m.id)))
  WHERE (l.ativo = true);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| public       | vw_todas_lentes            |  SELECT 'CANONICA'::text AS tipo_lente_sistema,
    c.id,
    c.sku_canonico AS sku_exibicao,
    c.nome_comercial,
    ('Linha '::text || COALESCE(c.linha_produto, 'Standard'::text)) AS marca_exibicao,
    c.linha_produto,
    c.nivel_qualidade,
    c.tipo_lente,
    c.material,
    c.indice_refracao,
    c.categoria,
    c.tem_ar,
    c.tem_blue,
    c.tem_hc,
    c.tem_polarizado,
    c.tem_fotossensivel,
    c.tipo_fotossensivel,
    c.tem_tintavel,
    c.tratamentos_detalhes,
    c.specs_tecnicas,
    c.ativo,
    NULL::integer AS corredor_progressao,
    c.laboratorio_referencia_id
   FROM lens_catalog.lentes_canonicas c
  WHERE (c.ativo = true)
UNION ALL
 SELECT 'PREMIUM'::text AS tipo_lente_sistema,
    p.id,
    p.sku_premium AS sku_exibicao,
    p.nome_comercial,
    m.nome AS marca_exibicao,
    p.linha_completa AS linha_produto,
    p.nivel_qualidade,
    p.tipo_lente,
    p.material,
    p.indice_refracao,
    p.categoria,
    p.tem_ar,
    p.tem_blue,
    p.tem_hc,
    p.tem_polarizado,
    p.tem_fotossensivel,
    p.tipo_fotossensivel,
    p.tem_tintavel,
    p.tratamentos_detalhes,
    p.specs_tecnicas,
    p.ativo,
    p.corredor_progressao,
    NULL::uuid AS laboratorio_referencia_id
   FROM (lens_catalog.lentes_premium p
     JOIN lens_catalog.marcas m ON ((p.marca_id = m.id)))
  WHERE (p.ativo = true);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| public       | vw_usuarios                |  SELECT id,
    email,
    nome,
    tenant_id,
    role,
    loja_id,
    ativo,
    created_at,
    updated_at
   FROM usuarios;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| vault        | decrypted_secrets          | null                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |


-- Ver todas as foreign keys existentes
SELECT
    tc.table_schema,
    tc.table_name,
    kcu.column_name,
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    tc.constraint_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_schema, tc.table_name;

| table_schema | table_name              | column_name               | foreign_table_schema | foreign_table_name      | foreign_column_name | constraint_name                                 |
| ------------ | ----------------------- | ------------------------- | -------------------- | ----------------------- | ------------------- | ----------------------------------------------- |
| analytics    | alertas_analytics       | metrica_id                | analytics            | metricas_kpi            | id                  | alertas_analytics_metrica_id_fkey               |
| analytics    | alertas_analytics       | tenant_id                 | meta_system          | tenants                 | id                  | alertas_analytics_tenant_id_fkey                |
| analytics    | execucoes_relatorios    | tenant_id                 | meta_system          | tenants                 | id                  | execucoes_relatorios_tenant_id_fkey             |
| analytics    | execucoes_relatorios    | relatorio_id              | analytics            | relatorios_configuracao | id                  | execucoes_relatorios_relatorio_id_fkey          |
| analytics    | metricas_kpi            | tenant_id                 | meta_system          | tenants                 | id                  | metricas_kpi_tenant_id_fkey                     |
| analytics    | relatorios_configuracao | tenant_id                 | meta_system          | tenants                 | id                  | relatorios_configuracao_tenant_id_fkey          |
| analytics    | valores_kpi             | metrica_id                | analytics            | metricas_kpi            | id                  | valores_kpi_metrica_id_fkey                     |
| analytics    | valores_kpi             | tenant_id                 | meta_system          | tenants                 | id                  | valores_kpi_tenant_id_fkey                      |
| commercial   | descontos               | tenant_id                 | meta_system          | tenants                 | id                  | descontos_tenant_id_fkey                        |
| commercial   | historico_precos        | tenant_id                 | meta_system          | tenants                 | id                  | historico_precos_tenant_id_fkey                 |
| commercial   | historico_precos        | produto_lab_id            | suppliers            | produtos_laboratorio    | id                  | historico_precos_produto_lab_id_fkey            |
| commercial   | precos_base             | tenant_id                 | meta_system          | tenants                 | id                  | precos_base_tenant_id_fkey                      |
| commercial   | precos_base             | produto_lab_id            | suppliers            | produtos_laboratorio    | id                  | precos_base_produto_lab_id_fkey                 |
| lens_catalog | lentes                  | tenant_id                 | meta_system          | tenants                 | id                  | lentes_tenant_id_fkey                           |
| lens_catalog | lentes                  | marca_id                  | lens_catalog         | marcas                  | id                  | lentes_marca_id_fkey                            |
| lens_catalog | lentes_canonicas        | tenant_id                 | meta_system          | tenants                 | id                  | lentes_canonicas_tenant_id_fkey                 |
| lens_catalog | lentes_canonicas        | laboratorio_referencia_id | suppliers            | laboratorios            | id                  | lentes_canonicas_laboratorio_referencia_id_fkey |
| lens_catalog | lentes_premium          | marca_id                  | lens_catalog         | marcas                  | id                  | lentes_premium_marca_id_fkey                    |
| lens_catalog | lentes_premium          | tenant_id                 | meta_system          | tenants                 | id                  | lentes_premium_tenant_id_fkey                   |
| lens_catalog | marcas                  | tenant_id                 | meta_system          | tenants                 | id                  | marcas_tenant_id_fkey                           |
| logistics    | historico_entregas      | zona_entrega_id           | logistics            | zonas_entrega           | id                  | historico_entregas_zona_entrega_id_fkey         |
| logistics    | historico_entregas      | laboratorio_id            | suppliers            | laboratorios            | id                  | historico_entregas_laboratorio_id_fkey          |
| logistics    | historico_entregas      | tenant_id                 | meta_system          | tenants                 | id                  | historico_entregas_tenant_id_fkey               |
| logistics    | tabela_prazos           | tenant_id                 | meta_system          | tenants                 | id                  | tabela_prazos_tenant_id_fkey                    |
| logistics    | tabela_prazos           | laboratorio_id            | suppliers            | laboratorios            | id                  | tabela_prazos_laboratorio_id_fkey               |
| logistics    | tabela_prazos           | zona_entrega_id           | logistics            | zonas_entrega           | id                  | tabela_prazos_zona_entrega_id_fkey              |
| logistics    | zonas_entrega           | tenant_id                 | meta_system          | tenants                 | id                  | zonas_entrega_tenant_id_fkey                    |
| meta_system  | feature_flags           | tenant_id                 | meta_system          | tenants                 | id                  | feature_flags_tenant_id_fkey                    |
| meta_system  | parametros_tenant       | tenant_id                 | meta_system          | tenants                 | id                  | parametros_tenant_tenant_id_fkey                |
| orders       | alternativas_cotacao    | tenant_id                 | meta_system          | tenants                 | id                  | alternativas_cotacao_tenant_id_fkey             |
| orders       | alternativas_cotacao    | decisao_id                | orders               | decisoes_lentes         | id                  | alternativas_cotacao_decisao_id_fkey            |
| orders       | alternativas_cotacao    | lente_id                  | lens_catalog         | lentes                  | id                  | alternativas_cotacao_lente_id_fkey              |
| orders       | alternativas_cotacao    | laboratorio_id            | suppliers            | laboratorios            | id                  | alternativas_cotacao_laboratorio_id_fkey        |
| orders       | criterios_decisao       | tenant_id                 | meta_system          | tenants                 | id                  | criterios_decisao_tenant_id_fkey                |
| orders       | decisoes_lentes         | tenant_id                 | meta_system          | tenants                 | id                  | decisoes_lentes_tenant_id_fkey                  |
| orders       | decisoes_lentes         | lente_recomendada_id      | lens_catalog         | lentes                  | id                  | decisoes_lentes_lente_recomendada_id_fkey       |
| orders       | decisoes_lentes         | laboratorio_escolhido_id  | suppliers            | laboratorios            | id                  | decisoes_lentes_laboratorio_escolhido_id_fkey   |
| orders       | historico_status        | tenant_id                 | meta_system          | tenants                 | id                  | historico_status_tenant_id_fkey                 |
| orders       | historico_status        | decisao_id                | orders               | decisoes_lentes         | id                  | historico_status_decisao_id_fkey                |
| public       | clientes                | loja_id                   | public               | lojas                   | id                  | clientes_loja_id_fkey                           |
| public       | consultas_lens_log      | voucher_gerado_id         | public               | vouchers_desconto       | id                  | consultas_lens_log_voucher_gerado_id_fkey       |
| public       | consultas_lens_log      | usuario_id                | public               | usuarios                | id                  | consultas_lens_log_usuario_id_fkey              |
| public       | ranking_vouchers        | usuario_id                | public               | usuarios                | id                  | ranking_vouchers_usuario_id_fkey                |
| public       | vouchers                | cliente_id                | public               | clientes                | id                  | vouchers_cliente_id_fkey                        |
| public       | vouchers                | loja_id                   | public               | lojas                   | id                  | vouchers_loja_id_fkey                           |
| public       | vouchers_desconto       | usuario_uso_id            | public               | usuarios                | id                  | vouchers_desconto_usuario_uso_id_fkey           |
| public       | vouchers_desconto       | usuario_gerador_id        | public               | usuarios                | id                  | vouchers_desconto_usuario_gerador_id_fkey       |
| scoring      | avaliacoes_laboratorios | tenant_id                 | meta_system          | tenants                 | id                  | avaliacoes_laboratorios_tenant_id_fkey          |
| scoring      | avaliacoes_laboratorios | laboratorio_id            | suppliers            | laboratorios            | id                  | avaliacoes_laboratorios_laboratorio_id_fkey     |
| scoring      | criterios_scoring       | tenant_id                 | meta_system          | tenants                 | id                  | criterios_scoring_tenant_id_fkey                |
| scoring      | historico_scores        | laboratorio_id            | suppliers            | laboratorios            | id                  | historico_scores_laboratorio_id_fkey            |
| scoring      | historico_scores        | tenant_id                 | meta_system          | tenants                 | id                  | historico_scores_tenant_id_fkey                 |
| scoring      | scores_laboratorios     | tenant_id                 | meta_system          | tenants                 | id                  | scores_laboratorios_tenant_id_fkey              |
| scoring      | scores_laboratorios     | laboratorio_id            | suppliers            | laboratorios            | id                  | scores_laboratorios_laboratorio_id_fkey         |
| suppliers    | historico_produtos      | tenant_id                 | meta_system          | tenants                 | id                  | historico_produtos_tenant_id_fkey               |
| suppliers    | historico_produtos      | produto_lab_id            | suppliers            | produtos_laboratorio    | id                  | historico_produtos_produto_lab_id_fkey          |
| suppliers    | laboratorios            | tenant_id                 | meta_system          | tenants                 | id                  | laboratorios_tenant_id_fkey                     |
| suppliers    | produtos_laboratorio    | lente_id                  | lens_catalog         | lentes                  | id                  | produtos_laboratorio_lente_id_fkey              |
| suppliers    | produtos_laboratorio    | laboratorio_id            | suppliers            | laboratorios            | id                  | produtos_laboratorio_laboratorio_id_fkey        |
| suppliers    | produtos_laboratorio    | tenant_id                 | meta_system          | tenants                 | id                  | produtos_laboratorio_tenant_id_fkey             |


-- Ver estrutura de suppliers.laboratorios
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_schema = 'suppliers' 
  AND table_name = 'laboratorios'
ORDER BY ordinal_position;


| column_name           | data_type                | is_nullable | column_default     | character_maximum_length |
| --------------------- | ------------------------ | ----------- | ------------------ | ------------------------ |
| id                    | uuid                     | NO          | uuid_generate_v4() | null                     |
| tenant_id             | uuid                     | NO          | null               | null                     |
| nome_fantasia         | text                     | NO          | null               | null                     |
| razao_social          | text                     | YES         | null               | null                     |
| cnpj                  | text                     | YES         | null               | null                     |
| contato_comercial     | jsonb                    | YES         | '{}'::jsonb        | null                     |
| lead_time_padrao_dias | integer                  | YES         | 7                  | null                     |
| atende_regioes        | ARRAY                    | YES         | '{}'::text[]       | null                     |
| ativo                 | boolean                  | NO          | true               | null                     |
| criado_em             | timestamp with time zone | NO          | now()              | null                     |
| atualizado_em         | timestamp with time zone | NO          | now()              | null                     |


-- Ver estrutura de suppliers.produtos_laboratorio
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_schema = 'suppliers' 
  AND table_name = 'produtos_laboratorio'
ORDER BY ordinal_position;

| column_name      | data_type                | is_nullable | column_default     | character_maximum_length |
| ---------------- | ------------------------ | ----------- | ------------------ | ------------------------ |
| id               | uuid                     | NO          | uuid_generate_v4() | null                     |
| tenant_id        | uuid                     | NO          | null               | null                     |
| laboratorio_id   | uuid                     | NO          | null               | null                     |
| lente_id         | uuid                     | NO          | null               | null                     |
| sku_laboratorio  | text                     | NO          | null               | null                     |
| nome_comercial   | text                     | NO          | null               | null                     |
| sku_fantasia     | text                     | YES         | null               | null                     |
| qualidade_base   | integer                  | YES         | 3                  | null                     |
| disponivel       | boolean                  | NO          | true               | null                     |
| descontinuado_em | date                     | YES         | null               | null                     |
| criado_em        | timestamp with time zone | NO          | now()              | null                     |
| atualizado_em    | timestamp with time zone | NO          | now()              | null                     |

-- Ver constraints e indexes dessas tabelas
SELECT
    c.conname AS constraint_name,
    c.contype AS constraint_type,
    CASE c.contype
        WHEN 'c' THEN 'CHECK'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 't' THEN 'TRIGGER'
        WHEN 'x' THEN 'EXCLUDE'
    END AS constraint_type_desc,
    pg_get_constraintdef(c.oid) AS constraint_definition
FROM pg_constraint c
JOIN pg_namespace n ON n.oid = c.connamespace
WHERE n.nspname = 'suppliers'
ORDER BY c.conname;

| constraint_name                                                 | constraint_type | constraint_type_desc | constraint_definition                                                                        |
| --------------------------------------------------------------- | --------------- | -------------------- | -------------------------------------------------------------------------------------------- |
| historico_produtos_pkey                                         | p               | PRIMARY KEY          | PRIMARY KEY (id)                                                                             |
| historico_produtos_produto_lab_id_fkey                          | f               | FOREIGN KEY          | FOREIGN KEY (produto_lab_id) REFERENCES suppliers.produtos_laboratorio(id) ON DELETE CASCADE |
| historico_produtos_tenant_id_fkey                               | f               | FOREIGN KEY          | FOREIGN KEY (tenant_id) REFERENCES meta_system.tenants(id) ON DELETE CASCADE                 |
| laboratorios_pkey                                               | p               | PRIMARY KEY          | PRIMARY KEY (id)                                                                             |
| laboratorios_tenant_id_fkey                                     | f               | FOREIGN KEY          | FOREIGN KEY (tenant_id) REFERENCES meta_system.tenants(id) ON DELETE CASCADE                 |
| laboratorios_tenant_id_nome_fantasia_key                        | u               | UNIQUE               | UNIQUE (tenant_id, nome_fantasia)                                                            |
| produtos_laboratorio_laboratorio_id_fkey                        | f               | FOREIGN KEY          | FOREIGN KEY (laboratorio_id) REFERENCES suppliers.laboratorios(id)                           |
| produtos_laboratorio_lente_id_fkey                              | f               | FOREIGN KEY          | FOREIGN KEY (lente_id) REFERENCES lens_catalog.lentes(id)                                    |
| produtos_laboratorio_pkey                                       | p               | PRIMARY KEY          | PRIMARY KEY (id)                                                                             |
| produtos_laboratorio_qualidade_base_check                       | c               | CHECK                | CHECK (((qualidade_base >= 1) AND (qualidade_base <= 5)))                                    |
| produtos_laboratorio_tenant_id_fkey                             | f               | FOREIGN KEY          | FOREIGN KEY (tenant_id) REFERENCES meta_system.tenants(id) ON DELETE CASCADE                 |
| produtos_laboratorio_tenant_id_laboratorio_id_sku_laborator_key | u               | UNIQUE               | UNIQUE (tenant_id, laboratorio_id, sku_laboratorio)                                          |