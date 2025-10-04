-- ============================================================================
-- DIAGNÓSTICO: ESTRUTURA REAL DO BANCO vs BACKEND ESPERADO
-- ============================================================================

-- 🔍 ESTRUTURA ATUAL DO BANCO (descoberta):

-- TABELAS EXISTENTES:
-- ├─ consultas_lens_log       (log de consultas)
-- ├─ controle_vouchers_mensal (controle mensal)  
-- ├─ ranking_vouchers         (ranking de vouchers)
-- ├─ sistema_config_bestlens  (configurações)
-- ├─ usuarios                 (usuários)
-- └─ vouchers_desconto        (vouchers)

-- VIEWS EXISTENTES:
-- ├─ v_configuracoes_sistema  (config do sistema)
-- ├─ v_dashboard_vouchers     (dashboard vouchers)
-- ├─ v_historico_consultas    (histórico consultas)
-- ├─ v_ranking_economia       (ranking economia)
-- ├─ v_user_profile          (perfil usuário)
-- └─ v_vouchers_disponiveis   (vouchers disponíveis)

-- ============================================================================
-- CONSULTAS PARA DESCOBRIR A ESTRUTURA REAL
-- ============================================================================

-- 1. VERIFICAR ESTRUTURA DAS TABELAS EXISTENTES
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name IN (
    'consultas_lens_log',
    'controle_vouchers_mensal', 
    'ranking_vouchers',
    'sistema_config_bestlens',
    'usuarios',
    'vouchers_desconto'
  )
ORDER BY table_name, ordinal_position;

| table_name               | column_name                    | data_type                | is_nullable | column_default                                                              |
| ------------------------ | ------------------------------ | ------------------------ | ----------- | --------------------------------------------------------------------------- |
| consultas_lens_log       | id                             | uuid                     | NO          | gen_random_uuid()                                                           |
| consultas_lens_log       | usuario_id                     | uuid                     | NO          | null                                                                        |
| consultas_lens_log       | tipo_consulta                  | text                     | NO          | null                                                                        |
| consultas_lens_log       | parametros_consulta            | jsonb                    | NO          | null                                                                        |
| consultas_lens_log       | resultado_consulta             | jsonb                    | YES         | null                                                                        |
| consultas_lens_log       | tempo_execucao_ms              | integer                  | YES         | null                                                                        |
| consultas_lens_log       | economia_gerada                | numeric                  | YES         | null                                                                        |
| consultas_lens_log       | voucher_gerado_id              | uuid                     | YES         | null                                                                        |
| consultas_lens_log       | ip_origem                      | inet                     | YES         | null                                                                        |
| consultas_lens_log       | user_agent                     | text                     | YES         | null                                                                        |
| consultas_lens_log       | created_at                     | timestamp with time zone | YES         | now()                                                                       |
| controle_vouchers_mensal | id                             | uuid                     | NO          | gen_random_uuid()                                                           |
| controle_vouchers_mensal | periodo                        | date                     | NO          | (date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone))::date |
| controle_vouchers_mensal | total_vouchers_gerados         | integer                  | YES         | 0                                                                           |
| controle_vouchers_mensal | total_vouchers_utilizados      | integer                  | YES         | 0                                                                           |
| controle_vouchers_mensal | valor_total_economia_gerada    | numeric                  | YES         | 0                                                                           |
| controle_vouchers_mensal | valor_total_economia_potencial | numeric                  | YES         | 0                                                                           |
| controle_vouchers_mensal | limite_vouchers_periodo        | integer                  | YES         | 80                                                                          |
| controle_vouchers_mensal | limite_valor_periodo           | numeric                  | YES         | 16000.00                                                                    |
| controle_vouchers_mensal | bloqueado                      | boolean                  | YES         | false                                                                       |
| controle_vouchers_mensal | motivo_bloqueio                | text                     | YES         | null                                                                        |
| controle_vouchers_mensal | bloqueado_em                   | timestamp with time zone | YES         | null                                                                        |
| controle_vouchers_mensal | alerta_80_pct                  | boolean                  | YES         | false                                                                       |
| controle_vouchers_mensal | alerta_90_pct                  | boolean                  | YES         | false                                                                       |
| controle_vouchers_mensal | created_at                     | timestamp with time zone | YES         | now()                                                                       |
| controle_vouchers_mensal | updated_at                     | timestamp with time zone | YES         | now()                                                                       |
| ranking_vouchers         | id                             | uuid                     | NO          | gen_random_uuid()                                                           |
| ranking_vouchers         | usuario_id                     | uuid                     | NO          | null                                                                        |
| ranking_vouchers         | periodo                        | date                     | NO          | CURRENT_DATE                                                                |
| ranking_vouchers         | vouchers_gerados               | integer                  | YES         | 0                                                                           |
| ranking_vouchers         | vouchers_utilizados            | integer                  | YES         | 0                                                                           |
| ranking_vouchers         | economia_total_gerada          | numeric                  | YES         | 0                                                                           |
| ranking_vouchers         | economia_media_por_voucher     | numeric                  | YES         | 0                                                                           |
| ranking_vouchers         | posicao_economia               | integer                  | YES         | null                                                                        |
| ranking_vouchers         | posicao_eficiencia             | integer                  | YES         | null                                                                        |
| ranking_vouchers         | premiado                       | boolean                  | YES         | false                                                                       |
| ranking_vouchers         | tipo_premio                    | text                     | YES         | null                                                                        |
| ranking_vouchers         | valor_premio                   | jsonb                    | YES         | null                                                                        |
| ranking_vouchers         | created_at                     | timestamp with time zone | YES         | now()                                                                       |
| sistema_config_bestlens  | id                             | uuid                     | NO          | gen_random_uuid()                                                           |
| sistema_config_bestlens  | chave                          | text                     | NO          | null                                                                        |
| sistema_config_bestlens  | valor                          | jsonb                    | NO          | null                                                                        |
| sistema_config_bestlens  | descricao                      | text                     | YES         | null                                                                        |
| sistema_config_bestlens  | editavel_por                   | ARRAY                    | YES         | '{admin_junior,financeiro_supervisor}'::user_role_enum[]                    |
| sistema_config_bestlens  | created_at                     | timestamp with time zone | YES         | now()                                                                       |
| sistema_config_bestlens  | updated_at                     | timestamp with time zone | YES         | now()                                                                       |
| usuarios                 | id                             | uuid                     | NO          | gen_random_uuid()                                                           |
| usuarios                 | email                          | text                     | NO          | null                                                                        |
| usuarios                 | nome                           | text                     | NO          | null                                                                        |
| usuarios                 | tenant_id                      | uuid                     | YES         | null                                                                        |
| usuarios                 | role                           | USER-DEFINED             | NO          | 'loja_consulta'::user_role_enum                                             |
| usuarios                 | permissoes_especiais           | ARRAY                    | YES         | '{}'::text[]                                                                |
| usuarios                 | ativo                          | boolean                  | YES         | true                                                                        |
| usuarios                 | ultimo_acesso                  | timestamp with time zone | YES         | null                                                                        |
| usuarios                 | created_at                     | timestamp with time zone | YES         | now()                                                                       |
| usuarios                 | updated_at                     | timestamp with time zone | YES         | now()                                                                       |
| usuarios                 | auth_user_id                   | uuid                     | YES         | null                                                                        |
| usuarios                 | loja_id                        | uuid                     | YES         | null                                                                        |
| usuarios                 | limite_consultas_dia           | integer                  | YES         | 50                                                                          |
| usuarios                 | vouchers_gerados_mes           | integer                  | YES         | 0                                                                           |
| usuarios                 | session_token                  | text                     | YES         | null                                                                        |
| usuarios                 | session_expires_at             | timestamp with time zone | YES         | null                                                                        |
| vouchers_desconto        | id                             | uuid                     | NO          | gen_random_uuid()                                                           |
| vouchers_desconto        | codigo                         | text                     | NO          | null                                                                        |
| vouchers_desconto        | usuario_gerador_id             | uuid                     | NO          | null                                                                        |
| vouchers_desconto        | loja_destinatario_id           | uuid                     | YES         | null                                                                        |
| vouchers_desconto        | percentual_desconto            | numeric                  | NO          | null                                                                        |
| vouchers_desconto        | valor_minimo_pedido            | numeric                  | YES         | 0                                                                           |
| vouchers_desconto        | valor_maximo_desconto          | numeric                  | YES         | null                                                                        |
| vouchers_desconto        | ativo                          | boolean                  | YES         | true                                                                        |
| vouchers_desconto        | usado                          | boolean                  | YES         | false                                                                       |
| vouchers_desconto        | data_uso                       | timestamp with time zone | YES         | null                                                                        |
| vouchers_desconto        | usuario_uso_id                 | uuid                     | YES         | null                                                                        |
| vouchers_desconto        | pedido_id                      | uuid                     | YES         | null                                                                        |
| vouchers_desconto        | valido_de                      | timestamp with time zone | YES         | now()                                                                       |
| vouchers_desconto        | valido_ate                     | timestamp with time zone | NO          | null                                                                        |
| vouchers_desconto        | observacoes                    | text                     | YES         | null                                                                        |
| vouchers_desconto        | metadata                       | jsonb                    | YES         | '{}'::jsonb                                                                 |
| vouchers_desconto        | created_at                     | timestamp with time zone | YES         | now()                                                                       |
| vouchers_desconto        | updated_at                     | timestamp with time zone | YES         | now()                                                                       |


-- ============================================================================

-- 2. VERIFICAR ESTRUTURA DAS VIEWS EXISTENTES
SELECT 
    table_name as view_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name IN (
    'v_configuracoes_sistema',
    'v_dashboard_vouchers',
    'v_historico_consultas', 
    'v_ranking_economia',
    'v_user_profile',
    'v_vouchers_disponiveis'
  )
ORDER BY table_name, ordinal_position;

| view_name               | column_name                    | data_type                | is_nullable |
| ----------------------- | ------------------------------ | ------------------------ | ----------- |
| v_configuracoes_sistema | chave                          | text                     | YES         |
| v_configuracoes_sistema | valor                          | jsonb                    | YES         |
| v_configuracoes_sistema | descricao                      | text                     | YES         |
| v_configuracoes_sistema | editavel_por                   | ARRAY                    | YES         |
| v_configuracoes_sistema | created_at                     | timestamp with time zone | YES         |
| v_configuracoes_sistema | updated_at                     | timestamp with time zone | YES         |
| v_dashboard_vouchers    | periodo                        | date                     | YES         |
| v_dashboard_vouchers    | total_vouchers_gerados         | integer                  | YES         |
| v_dashboard_vouchers    | total_vouchers_utilizados      | integer                  | YES         |
| v_dashboard_vouchers    | valor_total_economia_gerada    | numeric                  | YES         |
| v_dashboard_vouchers    | valor_total_economia_potencial | numeric                  | YES         |
| v_dashboard_vouchers    | limite_vouchers_periodo        | integer                  | YES         |
| v_dashboard_vouchers    | limite_valor_periodo           | numeric                  | YES         |
| v_dashboard_vouchers    | pct_vouchers_usado             | numeric                  | YES         |
| v_dashboard_vouchers    | pct_valor_usado                | numeric                  | YES         |
| v_dashboard_vouchers    | status_quantidade              | text                     | YES         |
| v_dashboard_vouchers    | status_valor                   | text                     | YES         |
| v_dashboard_vouchers    | bloqueado                      | boolean                  | YES         |
| v_dashboard_vouchers    | motivo_bloqueio                | text                     | YES         |
| v_historico_consultas   | id                             | uuid                     | YES         |
| v_historico_consultas   | tipo_consulta                  | text                     | YES         |
| v_historico_consultas   | parametros_consulta            | jsonb                    | YES         |
| v_historico_consultas   | resultado_consulta             | jsonb                    | YES         |
| v_historico_consultas   | economia_gerada                | numeric                  | YES         |
| v_historico_consultas   | tempo_execucao_ms              | integer                  | YES         |
| v_historico_consultas   | created_at                     | timestamp with time zone | YES         |
| v_historico_consultas   | voucher_codigo                 | text                     | YES         |
| v_historico_consultas   | voucher_desconto               | numeric                  | YES         |
| v_ranking_economia      | posicao                        | bigint                   | YES         |
| v_ranking_economia      | nome                           | text                     | YES         |
| v_ranking_economia      | email                          | text                     | YES         |
| v_ranking_economia      | role                           | USER-DEFINED             | YES         |
| v_ranking_economia      | vouchers_gerados               | integer                  | YES         |
| v_ranking_economia      | vouchers_utilizados            | integer                  | YES         |
| v_ranking_economia      | economia_total_gerada          | numeric                  | YES         |
| v_ranking_economia      | economia_media_por_voucher     | numeric                  | YES         |
| v_ranking_economia      | taxa_utilizacao                | numeric                  | YES         |
| v_ranking_economia      | premiado                       | boolean                  | YES         |
| v_ranking_economia      | periodo                        | date                     | YES         |
| v_user_profile          | id                             | uuid                     | YES         |
| v_user_profile          | email                          | text                     | YES         |
| v_user_profile          | nome                           | text                     | YES         |
| v_user_profile          | role                           | USER-DEFINED             | YES         |
| v_user_profile          | permissoes_especiais           | ARRAY                    | YES         |
| v_user_profile          | ativo                          | boolean                  | YES         |
| v_user_profile          | ultimo_acesso                  | timestamp with time zone | YES         |
| v_user_profile          | limite_consultas_dia           | integer                  | YES         |
| v_user_profile          | vouchers_gerados_mes           | integer                  | YES         |
| v_user_profile          | loja_id                        | uuid                     | YES         |
| v_user_profile          | vouchers_criados_este_mes      | bigint                   | YES         |
| v_user_profile          | consultas_realizadas_hoje      | bigint                   | YES         |
| v_user_profile          | economia_gerada_este_mes       | numeric                  | YES         |
| v_vouchers_disponiveis  | id                             | uuid                     | YES         |
| v_vouchers_disponiveis  | codigo                         | text                     | YES         |
| v_vouchers_disponiveis  | percentual_desconto            | numeric                  | YES         |
| v_vouchers_disponiveis  | valor_minimo_pedido            | numeric                  | YES         |
| v_vouchers_disponiveis  | valor_maximo_desconto          | numeric                  | YES         |
| v_vouchers_disponiveis  | valido_ate                     | timestamp with time zone | YES         |
| v_vouchers_disponiveis  | observacoes                    | text                     | YES         |
| v_vouchers_disponiveis  | ativo                          | boolean                  | YES         |
| v_vouchers_disponiveis  | usado                          | boolean                  | YES         |
| v_vouchers_disponiveis  | created_at                     | timestamp with time zone | YES         |
| v_vouchers_disponiveis  | criado_por                     | text                     | YES         |
| v_vouchers_disponiveis  | criador_role                   | USER-DEFINED             | YES         |
| v_vouchers_disponiveis  | dias_restantes                 | numeric                  | YES         |
| v_vouchers_disponiveis  | status_voucher                 | text                     | YES         |



-- ============================================================================

-- 3. VERIFICAR DADOS DE EXEMPLO DAS TABELAS
-- Execute uma por vez para ver o conteúdo

SELECT 'consultas_lens_log' as tabela, COUNT(*) as registros FROM consultas_lens_log;
SELECT 'controle_vouchers_mensal' as tabela, COUNT(*) as registros FROM controle_vouchers_mensal;
SELECT 'ranking_vouchers' as tabela, COUNT(*) as registros FROM ranking_vouchers; 
SELECT 'sistema_config_bestlens' as tabela, COUNT(*) as registros FROM sistema_config_bestlens;
SELECT 'usuarios' as tabela, COUNT(*) as registros FROM usuarios;
SELECT 'vouchers_desconto' as tabela, COUNT(*) as registros FROM vouchers_desconto;

| tabela            | registros |
| ----------------- | --------- |
| vouchers_desconto | 3         |

-- ============================================================================

-- 4. VER DADOS DE EXEMPLO (PRIMEIROS REGISTROS)
-- Execute separadamente para cada tabela

-- Tabela usuarios (pode ter dados de autenticação)
SELECT * FROM usuarios LIMIT 3;

| id                                   | email                         | nome                    | tenant_id | role                  | permissoes_especiais                                                                              | ativo | ultimo_acesso | created_at                    | updated_at                    | auth_user_id | loja_id | limite_consultas_dia | vouchers_gerados_mes | session_token | session_expires_at |
| ------------------------------------ | ----------------------------- | ----------------------- | --------- | --------------------- | ------------------------------------------------------------------------------------------------- | ----- | ------------- | ----------------------------- | ----------------------------- | ------------ | ------- | -------------------- | -------------------- | ------------- | ------------------ |
| b97672f5-35ea-404d-9838-3ca1a98d9851 | dcl@oticastatymello.com.br    | DCL - Decisor de Lentes | null      | dcl_decisor           | ["lens_decision","full_catalog_access","price_comparison","voucher_generation"]                   | true  | null          | 2025-10-03 04:40:40.256119+00 | 2025-10-03 04:40:40.256119+00 | null         | null    | 1000                 | 0                    | null          | null               |
| 46f39ac7-f713-47b6-b6c2-28b3b27cfc54 | financeiroesc@hotmail.com     | Supervisor Financeiro   | null      | financeiro_supervisor | ["full_system_access","user_management","financial_reports","system_config","voucher_management"] | true  | null          | 2025-10-03 04:40:40.256119+00 | 2025-10-03 04:40:40.256119+00 | null         | null    | -1                   | 0                    | null          | null               |
| bece1f77-49a5-4467-918d-f785b92ac49a | junior@oticastatymello.com.br | Administrador Junior    | null      | admin_junior          | ["user_management","system_config","reports","voucher_management"]                                | true  | null          | 2025-10-03 04:40:40.256119+00 | 2025-10-03 04:40:40.256119+00 | null         | null    | 500                  | 0                    | null          | null               |

-- Tabela sistema_config_bestlens (configurações do sistema)
SELECT * FROM sistema_config_bestlens LIMIT 3;

| id                                   | chave              | valor                                                                                                                                                                                                                                                                                   | descricao                                   | editavel_por                         | created_at                    | updated_at                    |
| ------------------------------------ | ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- | ------------------------------------ | ----------------------------- | ----------------------------- |
| f86e09c2-1cc7-4fd2-bd4d-7d5bd1f9acbd | limites_consulta   | {"dcl_decisor":1000,"admin_junior":500,"loja_consulta":100,"financeiro_supervisor":-1}                                                                                                                                                                                                  | Limites de consulta por role                | {admin_junior,financeiro_supervisor} | 2025-10-03 04:40:40.256119+00 | 2025-10-03 04:40:40.256119+00 |
| 67e5f5b2-13f3-4e0a-9e8b-f4820c9d740d | gamificacao_config | {"premio_top_3":true,"ranking_reset_day":1,"meta_mensal_vouchers":20,"bonus_economia_percentual":2.5}                                                                                                                                                                                   | Configurações do sistema de gamificação     | {admin_junior,financeiro_supervisor} | 2025-10-03 04:40:40.256119+00 | 2025-10-03 04:40:40.256119+00 |
| 650277fc-aece-4c95-a0be-53bbd45a9999 | voucher_config     | {"max_desconto":25,"min_desconto":5,"validade_dias":30,"max_desconto_por_role":{"dcl_decisor":20,"admin_junior":15,"financeiro_supervisor":25},"limite_mensal_por_usuario":50,"limite_mensal_valor_total":16000,"economia_minima_para_premio":1000,"limite_mensal_vouchers_sistema":80} | Configurações gerais do sistema de vouchers | {admin_junior,financeiro_supervisor} | 2025-10-03 04:40:40.256119+00 | 2025-10-03 04:50:36.0479+00   |



-- Tabela consultas_lens_log (pode ter dados de lentes!)
SELECT * FROM consultas_lens_log LIMIT 3;
nada 

-- View v_historico_consultas (pode ser nosso histórico!)
SELECT * FROM v_historico_consultas LIMIT 3;

nada

-- View v_ranking_economia (pode ser nosso ranking!)
SELECT * FROM v_ranking_economia LIMIT 3;

nada

-- ============================================================================

-- 5. VERIFICAR FUNÇÕES/RPCs EXISTENTES
SELECT 
    routine_name,
    routine_type,
    external_language,
    routine_definition
FROM information_schema.routines 
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
ORDER BY routine_name;


| routine_name                    | routine_type | external_language | routine_definition                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ------------------------------- | ------------ | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| api_dashboard_controle_vouchers | FUNCTION     | PLPGSQL           | 
DECLARE
    v_periodo date;
    v_controle record;
    v_projecao jsonb;
    v_role user_role_enum;
BEGIN
    -- Verificar permissão
    SELECT role INTO v_role
    FROM public.usuarios
    WHERE auth_user_id = auth.uid() AND ativo = true;
    
    IF v_role NOT IN ('financeiro_supervisor', 'admin_junior', 'dcl_decisor') THEN
        RETURN jsonb_build_object('erro', 'Acesso negado');
    END IF;
    
    v_periodo := date_trunc('month', CURRENT_DATE)::date;
    
    -- Buscar dados do controle atual
    SELECT * INTO v_controle
    FROM public.controle_vouchers_mensal
    WHERE periodo = v_periodo;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'periodo', v_periodo,
            'status', 'sem_atividade',
            'vouchers_gerados', 0,
            'limite_vouchers', 80,
            'economia_potencial', 0,
            'limite_economia', 16000
        );
    END IF;
    
    -- Calcular projeção para fim do mês
    DECLARE
        dias_mes integer;
        dia_atual integer;
        projecao_vouchers numeric;
        projecao_economia numeric;
    BEGIN
        dias_mes := EXTRACT(DAY FROM (date_trunc('month', CURRENT_DATE) + interval '1 month - 1 day'));
        dia_atual := EXTRACT(DAY FROM CURRENT_DATE);
        
        projecao_vouchers := (v_controle.total_vouchers_gerados::numeric / dia_atual) * dias_mes;
        projecao_economia := (v_controle.valor_total_economia_potencial / dia_atual) * dias_mes;
        
        SELECT jsonb_build_object(
            'vouchers_fim_mes', round(projecao_vouchers),
            'economia_fim_mes', round(projecao_economia, 2),
            'risco_limite_vouchers', projecao_vouchers > v_controle.limite_vouchers_periodo * 0.9,
            'risco_limite_economia', projecao_economia > v_controle.limite_valor_periodo * 0.9
        ) INTO v_projecao;
    END;
    
    RETURN jsonb_build_object(
        'periodo', v_periodo,
        'vouchers', jsonb_build_object(
            'gerados', v_controle.total_vouchers_gerados,
            'utilizados', v_controle.total_vouchers_utilizados,
            'limite', v_controle.limite_vouchers_periodo,
            'percentual_usado', round((v_controle.total_vouchers_gerados * 100.0 / v_controle.limite_vouchers_periodo), 1)
        ),
        'economia', jsonb_build_object(
            'potencial', v_controle.valor_total_economia_potencial,
            'realizada', v_controle.valor_total_economia_gerada,
            'limite', v_controle.limite_valor_periodo,
            'percentual_usado', round((v_controle.valor_total_economia_potencial * 100.0 / v_controle.limite_valor_periodo), 1)
        ),
        'status', jsonb_build_object(
            'bloqueado', v_controle.bloqueado,
            'motivo_bloqueio', v_controle.motivo_bloqueio,
            'alerta_80_pct', v_controle.alerta_80_pct,
            'alerta_90_pct', v_controle.alerta_90_pct
        ),
        'projecoes', v_projecao
    );
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| api_dashboard_executivo         | FUNCTION     | PLPGSQL           | 
DECLARE
    v_role user_role_enum;
    v_dashboard record;
    v_ranking jsonb;
    v_hoje_stats jsonb;
BEGIN
    -- Verificar permissão
    SELECT role INTO v_role
    FROM public.usuarios
    WHERE auth_user_id = auth.uid() AND ativo = true;
    
    IF v_role NOT IN ('financeiro_supervisor', 'admin_junior', 'dcl_decisor') THEN
        RETURN jsonb_build_object('erro', 'Acesso negado');
    END IF;
    
    -- Buscar dados do dashboard
    SELECT * INTO v_dashboard FROM public.v_dashboard_vouchers;
    
    -- Buscar ranking
    SELECT jsonb_agg(
        jsonb_build_object(
            'posicao', posicao,
            'nome', nome,
            'economia_total', economia_total_gerada,
            'vouchers_gerados', vouchers_gerados,
            'taxa_utilizacao', taxa_utilizacao
        )
    ) INTO v_ranking
    FROM public.v_ranking_economia
    LIMIT 10;
    
    -- Stats de hoje (CORRIGIDO - especificar tabela no created_at)
    SELECT jsonb_build_object(
        'vouchers_gerados_hoje', COUNT(*) FILTER (WHERE DATE(v.created_at) = CURRENT_DATE),
        'vouchers_usados_hoje', COUNT(*) FILTER (WHERE DATE(v.data_uso) = CURRENT_DATE),
        'economia_hoje', COALESCE(SUM(c.economia_gerada) FILTER (WHERE DATE(c.created_at) = CURRENT_DATE), 0)
    ) INTO v_hoje_stats
    FROM public.vouchers_desconto v
    LEFT JOIN public.consultas_lens_log c ON v.id = c.voucher_gerado_id;
    
    RETURN jsonb_build_object(
        'periodo', COALESCE(v_dashboard.periodo, CURRENT_DATE),
        'vouchers', jsonb_build_object(
            'gerados_mes', COALESCE(v_dashboard.total_vouchers_gerados, 0),
            'utilizados_mes', COALESCE(v_dashboard.total_vouchers_utilizados, 0),
            'limite_mes', COALESCE(v_dashboard.limite_vouchers_periodo, 80),
            'pct_usado', COALESCE(v_dashboard.pct_vouchers_usado, 0),
            'status', COALESCE(v_dashboard.status_quantidade, 'normal')
        ),
        'economia', jsonb_build_object(
            'potencial_mes', COALESCE(v_dashboard.valor_total_economia_potencial, 0),
            'realizada_mes', COALESCE(v_dashboard.valor_total_economia_gerada, 0),
            'limite_mes', COALESCE(v_dashboard.limite_valor_periodo, 16000),
            'pct_usado', COALESCE(v_dashboard.pct_valor_usado, 0),
            'status', COALESCE(v_dashboard.status_valor, 'normal')
        ),
        'hoje', v_hoje_stats,
        'ranking_top10', COALESCE(v_ranking, '[]'::jsonb),
        'sistema', jsonb_build_object(
            'bloqueado', COALESCE(v_dashboard.bloqueado, false),
            'motivo_bloqueio', v_dashboard.motivo_bloqueio
        )
    );
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| api_frontend_gerar_voucher      | FUNCTION     | PLPGSQL           | 
BEGIN
    -- Usar a função existente com controles
    RETURN public.api_gerar_voucher_controlado(
        p_percentual_desconto,
        p_valor_minimo_pedido,
        p_valor_maximo_desconto,
        p_validade_dias,
        NULL, -- loja_destinatario_id
        p_observacoes,
        p_confirmar_limite -- force_admin apenas para supervisor
    );
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| api_gerar_voucher_controlado    | FUNCTION     | PLPGSQL           | 
DECLARE
    v_usuario_id uuid;
    v_role user_role_enum;
    v_verificacao jsonb;
    v_voucher_id uuid;
    v_codigo text;
    v_valido_ate timestamp with time zone;
    v_periodo date;
BEGIN
    -- Verificar autenticação
    IF auth.uid() IS NULL THEN
        RETURN jsonb_build_object('erro', 'Usuário não autenticado');
    END IF;
    
    -- Buscar usuário
    SELECT id, role INTO v_usuario_id, v_role
    FROM public.usuarios
    WHERE auth_user_id = auth.uid() AND ativo = true;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('erro', 'Usuário não encontrado');
    END IF;
    
    -- Verificar permissão básica
    IF v_role NOT IN ('dcl_decisor', 'financeiro_supervisor', 'admin_junior') THEN
        RETURN jsonb_build_object('erro', 'Sem permissão para gerar vouchers');
    END IF;
    
    -- Verificar limites (apenas supervisor pode forçar)
    IF NOT (p_force_admin AND v_role = 'financeiro_supervisor') THEN
        SELECT public.verificar_limites_voucher(p_percentual_desconto, p_valor_maximo_desconto) INTO v_verificacao;
        
        IF NOT (v_verificacao->>'permitido')::boolean THEN
            RETURN jsonb_build_object('erro', v_verificacao->>'motivo');
        END IF;
        
        -- Retornar alerta se estiver próximo dos limites
        IF (v_verificacao->'alertas'->>'critico')::boolean THEN
            RETURN jsonb_build_object(
                'erro', 'Limite crítico atingido',
                'detalhes', v_verificacao->'alertas',
                'requer_confirmacao', true
            );
        END IF;
    END IF;
    
    -- Validar parâmetros
    IF p_percentual_desconto <= 0 OR p_percentual_desconto > 100 THEN
        RETURN jsonb_build_object('erro', 'Percentual inválido');
    END IF;
    
    -- Gerar voucher
    v_codigo := public.gerar_codigo_voucher();
    v_valido_ate := NOW() + (p_validade_dias || ' days')::interval;
    v_periodo := date_trunc('month', CURRENT_DATE)::date;
    
    -- Inserir voucher
    INSERT INTO public.vouchers_desconto (
        codigo, usuario_gerador_id, loja_destinatario_id, percentual_desconto,
        valor_minimo_pedido, valor_maximo_desconto, valido_ate, observacoes
    ) VALUES (
        v_codigo, v_usuario_id, p_loja_destinatario_id, p_percentual_desconto,
        p_valor_minimo_pedido, p_valor_maximo_desconto, v_valido_ate, p_observacoes
    ) RETURNING id INTO v_voucher_id;
    
    -- Atualizar controles mensais
    INSERT INTO public.controle_vouchers_mensal (
        periodo, total_vouchers_gerados, valor_total_economia_potencial
    ) VALUES (
        v_periodo, 1, COALESCE(p_valor_maximo_desconto, 0)
    )
    ON CONFLICT (periodo) DO UPDATE SET
        total_vouchers_gerados = controle_vouchers_mensal.total_vouchers_gerados + 1,
        valor_total_economia_potencial = controle_vouchers_mensal.valor_total_economia_potencial + COALESCE(p_valor_maximo_desconto, 0),
        updated_at = now();
    
    -- Registrar log
    INSERT INTO public.consultas_lens_log (
        usuario_id, tipo_consulta, parametros_consulta, voucher_gerado_id
    ) VALUES (
        v_usuario_id, 'voucher_generation',
        jsonb_build_object(
            'percentual_desconto', p_percentual_desconto,
            'valor_maximo', p_valor_maximo_desconto,
            'validade_dias', p_validade_dias,
            'force_admin', p_force_admin
        ),
        v_voucher_id
    );
    
    RETURN jsonb_build_object(
        'sucesso', true,
        'voucher_id', v_voucher_id,
        'codigo', v_codigo,
        'percentual_desconto', p_percentual_desconto,
        'valido_ate', v_valido_ate,
        'alertas', COALESCE(v_verificacao->'alertas', '{}'::jsonb),
        'limites_restantes', COALESCE(v_verificacao->'limites_restantes', '{}'::jsonb)
    );
END;
                                      |
| api_listar_vouchers             | FUNCTION     | PLPGSQL           | 
DECLARE
    v_vouchers jsonb;
BEGIN
    -- CORREÇÃO: Usar array de objetos em vez de jsonb_agg com ORDER BY
    SELECT jsonb_agg(voucher_obj ORDER BY created_at DESC) INTO v_vouchers
    FROM (
        SELECT 
            jsonb_build_object(
                'id', id,
                'codigo', codigo,
                'percentual_desconto', percentual_desconto,
                'valor_minimo_pedido', valor_minimo_pedido,
                'valor_maximo_desconto', valor_maximo_desconto,
                'valido_ate', valido_ate,
                'observacoes', observacoes,
                'criado_por', criado_por,
                'dias_restantes', dias_restantes,
                'status', status_voucher
            ) as voucher_obj,
            created_at
        FROM public.v_vouchers_disponiveis
        WHERE (p_status = 'todos' OR status_voucher = p_status)
        ORDER BY created_at DESC
        LIMIT p_limit
    ) subquery;
    
    RETURN jsonb_build_object(
        'sucesso', true,
        'vouchers', COALESCE(v_vouchers, '[]'::jsonb),
        'total', jsonb_array_length(COALESCE(v_vouchers, '[]'::jsonb))
    );
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| api_login_usuario               | FUNCTION     | PLPGSQL           | 
DECLARE
    v_usuario record;
    v_auth_user_id uuid;
BEGIN
    -- Buscar usuário pelo email
    SELECT * INTO v_usuario
    FROM public.usuarios
    WHERE email = p_email AND ativo = true;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'sucesso', false,
            'erro', 'Usuário não encontrado ou inativo'
        );
    END IF;
    
    -- Buscar ID do auth.users
    SELECT id INTO v_auth_user_id
    FROM auth.users
    WHERE email = p_email;
    
    -- Atualizar último acesso
    UPDATE public.usuarios
    SET ultimo_acesso = NOW()
    WHERE id = v_usuario.id;
    
    -- Vincular auth_user_id se não estiver vinculado
    IF v_usuario.auth_user_id IS NULL AND v_auth_user_id IS NOT NULL THEN
        UPDATE public.usuarios
        SET auth_user_id = v_auth_user_id
        WHERE id = v_usuario.id;
        
        v_usuario.auth_user_id := v_auth_user_id;
    END IF;
    
    RETURN jsonb_build_object(
        'sucesso', true,
        'usuario', jsonb_build_object(
            'id', v_usuario.id,
            'email', v_usuario.email,
            'nome', v_usuario.nome,
            'role', v_usuario.role,
            'permissoes', v_usuario.permissoes_especiais,
            'limite_consultas_dia', v_usuario.limite_consultas_dia,
            'auth_user_id', v_usuario.auth_user_id
        )
    );
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| api_logout_usuario              | FUNCTION     | PLPGSQL           | 
DECLARE
    v_usuario_id uuid;
BEGIN
    -- Buscar usuário
    SELECT id INTO v_usuario_id
    FROM public.usuarios
    WHERE auth_user_id = auth.uid();
    
    IF FOUND THEN
        -- Registrar logout
        INSERT INTO public.consultas_lens_log (
            usuario_id,
            tipo_consulta,
            parametros_consulta,
            resultado_consulta
        ) VALUES (
            v_usuario_id,
            'user_logout',
            jsonb_build_object('timestamp', NOW()),
            jsonb_build_object('sucesso', true)
        );
        
        -- Limpar token de sessão se houver
        UPDATE public.usuarios
        SET session_token = NULL,
            session_expires_at = NULL
        WHERE id = v_usuario_id;
    END IF;
    
    RETURN jsonb_build_object('sucesso', true, 'mensagem', 'Logout realizado');
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| api_perfil_usuario              | FUNCTION     | PLPGSQL           | 
DECLARE
    v_perfil record;
BEGIN
    SELECT * INTO v_perfil FROM public.v_user_profile;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('erro', 'Usuário não encontrado');
    END IF;
    
    RETURN row_to_json(v_perfil)::jsonb;
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| api_trocar_senha                | FUNCTION     | PLPGSQL           | 
DECLARE
    v_usuario_id uuid;
    v_email text;
BEGIN
    -- Buscar usuário
    SELECT id, email INTO v_usuario_id, v_email
    FROM public.usuarios
    WHERE auth_user_id = auth.uid() AND ativo = true;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('erro', 'Usuário não encontrado');
    END IF;
    
    -- Log da troca de senha
    INSERT INTO public.consultas_lens_log (
        usuario_id,
        tipo_consulta,
        parametros_consulta,
        resultado_consulta
    ) VALUES (
        v_usuario_id,
        'password_change',
        jsonb_build_object('email', v_email),
        jsonb_build_object('sucesso', true, 'timestamp', NOW())
    );
    
    RETURN jsonb_build_object(
        'sucesso', true,
        'mensagem', 'Solicitação registrada',
        'observacao', 'Use o painel do Supabase para alterar a senha efetivamente'
    );
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| api_validar_login               | FUNCTION     | PLPGSQL           | 
DECLARE
    v_usuario record;
    v_config jsonb;
BEGIN
    -- Verificar se usuário está autenticado
    IF auth.uid() IS NULL THEN
        RETURN jsonb_build_object(
            'autenticado', false,
            'erro', 'Token de autenticação inválido'
        );
    END IF;
    
    -- Buscar dados do usuário
    SELECT * INTO v_usuario
    FROM public.usuarios
    WHERE auth_user_id = auth.uid() AND ativo = true;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'autenticado', false,
            'erro', 'Usuário não encontrado ou inativo'
        );
    END IF;
    
    -- Buscar configurações do role
    SELECT valor INTO v_config
    FROM public.sistema_config_bestlens
    WHERE chave = 'limites_consulta';
    
    -- Atualizar último acesso
    UPDATE public.usuarios
    SET ultimo_acesso = NOW()
    WHERE id = v_usuario.id;
    
    RETURN jsonb_build_object(
        'autenticado', true,
        'usuario', jsonb_build_object(
            'id', v_usuario.id,
            'email', v_usuario.email,
            'nome', v_usuario.nome,
            'role', v_usuario.role,
            'permissoes', v_usuario.permissoes_especiais,
            'limite_consultas_dia', v_usuario.limite_consultas_dia,
            'vouchers_gerados_mes', v_usuario.vouchers_gerados_mes
        ),
        'configuracoes', jsonb_build_object(
            'limite_consultas', v_config->v_usuario.role::text,
            'pode_gerar_vouchers', v_usuario.role IN ('dcl_decisor', 'admin_junior', 'financeiro_supervisor'),
            'pode_ver_dashboard', v_usuario.role IN ('dcl_decisor', 'admin_junior', 'financeiro_supervisor'),
            'pode_administrar', v_usuario.role IN ('admin_junior', 'financeiro_supervisor')
        )
    );
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| gerar_codigo_voucher            | FUNCTION     | PLPGSQL           | 
DECLARE
    novo_codigo text;
    existe_codigo boolean;
BEGIN
    LOOP
        novo_codigo := 'LENS' || EXTRACT(YEAR FROM NOW())::text || upper(substring(md5(random()::text) from 1 for 6));
        SELECT EXISTS(SELECT 1 FROM public.vouchers_desconto WHERE codigo = novo_codigo) INTO existe_codigo;
        EXIT WHEN NOT existe_codigo;
    END LOOP;
    RETURN novo_codigo;
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| update_updated_at_column        | FUNCTION     | PLPGSQL           | 
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| usuario_tem_permissao           | FUNCTION     | PLPGSQL           | 
DECLARE
    user_role user_role_enum;
    user_permissions text[];
BEGIN
    SELECT role, permissoes_especiais INTO user_role, user_permissions
    FROM public.usuarios WHERE email = p_email AND ativo = true;
    
    IF NOT FOUND THEN RETURN false; END IF;
    IF user_role = 'financeiro_supervisor' THEN RETURN true; END IF;
    RETURN p_permissao = ANY(user_permissions);
END;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| verificar_limites_voucher       | FUNCTION     | PLPGSQL           | 
DECLARE
    v_periodo date;
    v_controle record;
    v_role user_role_enum;
    v_max_desconto_role numeric;
    v_economia_potencial numeric;
    v_config record;
BEGIN
    v_periodo := date_trunc('month', CURRENT_DATE)::date;
    
    -- Buscar role do usuário
    SELECT role INTO v_role
    FROM public.usuarios
    WHERE auth_user_id = auth.uid() AND ativo = true;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('permitido', false, 'motivo', 'Usuário não encontrado');
    END IF;
    
    -- Buscar configurações
    SELECT 
        (valor->>'limite_mensal_vouchers_sistema')::integer as limite_vouchers,
        (valor->>'limite_mensal_valor_total')::numeric as limite_valor,
        (valor->>'max_desconto_por_role')::jsonb as max_por_role
    INTO v_config
    FROM public.sistema_config_bestlens
    WHERE chave = 'voucher_config';
    
    -- Verificar limite de desconto por role
    v_max_desconto_role := (v_config.max_por_role->>v_role::text)::numeric;
    
    IF p_percentual_desconto > v_max_desconto_role THEN
        RETURN jsonb_build_object(
            'permitido', false, 
            'motivo', 'Desconto máximo para seu perfil é ' || v_max_desconto_role || '%'
        );
    END IF;
    
    -- Buscar ou criar controle mensal
    SELECT * INTO v_controle
    FROM public.controle_vouchers_mensal
    WHERE periodo = v_periodo;
    
    IF NOT FOUND THEN
        INSERT INTO public.controle_vouchers_mensal (
            periodo, limite_vouchers_periodo, limite_valor_periodo
        ) VALUES (
            v_periodo, v_config.limite_vouchers, v_config.limite_valor
        )
        RETURNING * INTO v_controle;
    END IF;
    
    -- Verificar se está bloqueado
    IF v_controle.bloqueado THEN
        RETURN jsonb_build_object(
            'permitido', false,
            'motivo', 'Sistema bloqueado: ' || v_controle.motivo_bloqueio
        );
    END IF;
    
    -- Verificar limite de quantidade
    IF v_controle.total_vouchers_gerados >= v_controle.limite_vouchers_periodo THEN
        RETURN jsonb_build_object(
            'permitido', false,
            'motivo', 'Limite mensal de vouchers atingido (' || v_controle.limite_vouchers_periodo || ')'
        );
    END IF;
    
    -- Calcular economia potencial do voucher
    v_economia_potencial := COALESCE(p_valor_maximo_desconto, 1000.00); -- Assumir R$ 1000 se não informado
    
    -- Verificar limite de valor
    IF (v_controle.valor_total_economia_potencial + v_economia_potencial) > v_controle.limite_valor_periodo THEN
        RETURN jsonb_build_object(
            'permitido', false,
            'motivo', 'Limite mensal de valor atingido (R$ ' || v_controle.limite_valor_periodo || ')'
        );
    END IF;
    
    -- Calcular percentuais para alertas
    DECLARE
        pct_vouchers numeric;
        pct_valor numeric;
    BEGIN
        pct_vouchers := (v_controle.total_vouchers_gerados + 1) * 100.0 / v_controle.limite_vouchers_periodo;
        pct_valor := (v_controle.valor_total_economia_potencial + v_economia_potencial) * 100.0 / v_controle.limite_valor_periodo;
        
        RETURN jsonb_build_object(
            'permitido', true,
            'alertas', jsonb_build_object(
                'percentual_vouchers', round(pct_vouchers, 1),
                'percentual_valor', round(pct_valor, 1),
                'alerta_quantidade', pct_vouchers >= 80,
                'alerta_valor', pct_valor >= 80,
                'critico', pct_vouchers >= 90 OR pct_valor >= 90
            ),
            'limites_restantes', jsonb_build_object(
                'vouchers', v_controle.limite_vouchers_periodo - v_controle.total_vouchers_gerados,
                'valor', v_controle.limite_valor_periodo - v_controle.valor_total_economia_potencial
            )
        );
    END;
END;
 |

-- ============================================================================

-- 6. ANÁLISE: MAPEAMENTO BANCO ATUAL → BACKEND ESPERADO
-- 
-- BACKEND ESPERA          |  BANCO TEM (possível mapping)
-- ======================= | ===============================
-- vw_lentes_catalogo      |  ? (talvez consultas_lens_log)
-- vw_fornecedores        |  ? (talvez ranking_vouchers)  
-- decisoes_compra        |  ? (talvez v_historico_consultas)
-- rpc_buscar_lente       |  ? (função a descobrir)
-- rpc_rank_opcoes        |  ? (talvez v_ranking_economia)
-- 
-- ============================================================================

-- 7. PRÓXIMOS PASSOS APÓS ANÁLISE:
-- 
-- A) Se o banco for de VOUCHERS/DESCONTOS (não lentes):
--    → Adaptar backend para sistema de vouchers
--    → Mudar DatabaseClient para consumir views existentes
-- 
-- B) Se o banco for HÍBRIDO (lentes + vouchers):
--    → Adaptar backend para usar ambos sistemas
--    → Criar mapeamento entre estruturas
-- 
-- C) Se precisar do sistema de LENTES original:
--    → Executar migration adicional
--    → Manter sistema vouchers + adicionar lentes
-- 
-- ============================================================================



📋 Estrutura Completa do Banco Atual
Tabelas Existentes:

consultas_lens_log - Log de consultas
controle_vouchers_mensal - Controle mensal
ranking_vouchers - Ranking de vouchers
sistema_config_bestlens - Configurações
usuarios - Usuários
vouchers_desconto - Vouchers
Views Existentes:

v_configuracoes_sistema - Config do sistema
v_dashboard_vouchers - Dashboard vouchers
v_historico_consultas - Histórico consultas
v_ranking_economia - Ranking economia
v_user_profile - Perfil usuário
v_vouchers_disponiveis - Vouchers disponíveis
🔗 Backend Connection
O backend atual se conecta através do DatabaseClient que usa estas estruturas:

📊 Sistema Híbrido
O sistema atual é híbrido - combina:

✅ Sistema de Vouchers (já implementado no banco)
✅ Sistema de Lentes (backend preparado, aguardando views)