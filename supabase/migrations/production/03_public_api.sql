-- ============================================================================
-- CAMADA PÚBLICA PARA FRONTEND - BESTLENS
-- Views, Functions e Permissões para acesso do Frontend
-- ============================================================================

-- 1. CRIAR SCHEMA PÚBLICO PARA APIs
CREATE SCHEMA IF NOT EXISTS public_api;

-- ============================================================================
-- VIEWS PÚBLICAS PARA FRONTEND
-- ============================================================================

-- VIEW: Perfil do usuário logado
CREATE OR REPLACE VIEW public.v_user_profile AS
SELECT 
    u.id,
    u.email,
    u.nome,
    u.role,
    u.permissoes_especiais,
    u.ativo,
    u.ultimo_acesso,
    u.limite_consultas_dia,
    u.vouchers_gerados_mes,
    u.loja_id,
    -- Estatísticas do usuário
    COALESCE(stats.vouchers_criados_mes, 0) as vouchers_criados_este_mes,
    COALESCE(stats.consultas_hoje, 0) as consultas_realizadas_hoje,
    COALESCE(stats.economia_gerada_mes, 0) as economia_gerada_este_mes
FROM public.usuarios u
LEFT JOIN (
    SELECT 
        usuario_id,
        COUNT(*) FILTER (WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)) as vouchers_criados_mes,
        COUNT(*) FILTER (WHERE DATE(created_at) = CURRENT_DATE AND tipo_consulta != 'voucher_generation') as consultas_hoje,
        COALESCE(SUM(economia_gerada) FILTER (WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)), 0) as economia_gerada_mes
    FROM public.consultas_lens_log
    GROUP BY usuario_id
) stats ON u.id = stats.usuario_id
WHERE u.auth_user_id = auth.uid();

-- VIEW: Vouchers disponíveis para o usuário
CREATE OR REPLACE VIEW public.v_vouchers_disponiveis AS
SELECT 
    v.id,
    v.codigo,
    v.percentual_desconto,
    v.valor_minimo_pedido,
    v.valor_maximo_desconto,
    v.valido_ate,
    v.observacoes,
    v.ativo,
    v.usado,
    v.created_at,
    -- Informações do criador
    u_criador.nome as criado_por,
    u_criador.role as criador_role,
    -- Calcular dias restantes
    EXTRACT(DAY FROM (v.valido_ate - NOW())) as dias_restantes,
    -- Status do voucher
    CASE 
        WHEN v.usado THEN 'usado'
        WHEN v.valido_ate < NOW() THEN 'expirado'
        WHEN NOT v.ativo THEN 'inativo'
        ELSE 'disponivel'
    END as status_voucher
FROM public.vouchers_desconto v
JOIN public.usuarios u_criador ON v.usuario_gerador_id = u_criador.id
WHERE v.ativo = true
AND v.usado = false
AND v.valido_ate > NOW()
AND (
    -- Lojas podem ver vouchers destinados a elas ou gerais
    (EXISTS (SELECT 1 FROM public.usuarios u WHERE u.auth_user_id = auth.uid() AND u.role = 'loja_consulta' 
             AND (v.loja_destinatario_id IS NULL OR v.loja_destinatario_id = u.loja_id)))
    OR
    -- Outros roles podem ver todos
    (EXISTS (SELECT 1 FROM public.usuarios u WHERE u.auth_user_id = auth.uid() 
             AND u.role IN ('dcl_decisor', 'admin_junior', 'financeiro_supervisor')))
);

-- VIEW: Dashboard de controle de vouchers
CREATE OR REPLACE VIEW public.v_dashboard_vouchers AS
SELECT 
    periodo,
    total_vouchers_gerados,
    total_vouchers_utilizados,
    valor_total_economia_gerada,
    valor_total_economia_potencial,
    limite_vouchers_periodo,
    limite_valor_periodo,
    -- Percentuais utilizados
    ROUND((total_vouchers_gerados * 100.0 / limite_vouchers_periodo), 1) as pct_vouchers_usado,
    ROUND((valor_total_economia_potencial * 100.0 / limite_valor_periodo), 1) as pct_valor_usado,
    -- Status de alertas
    CASE 
        WHEN total_vouchers_gerados >= limite_vouchers_periodo * 0.9 THEN 'critico'
        WHEN total_vouchers_gerados >= limite_vouchers_periodo * 0.8 THEN 'alerta'
        ELSE 'normal'
    END as status_quantidade,
    CASE 
        WHEN valor_total_economia_potencial >= limite_valor_periodo * 0.9 THEN 'critico'
        WHEN valor_total_economia_potencial >= limite_valor_periodo * 0.8 THEN 'alerta'
        ELSE 'normal'
    END as status_valor,
    bloqueado,
    motivo_bloqueio
FROM public.controle_vouchers_mensal
WHERE periodo = DATE_TRUNC('month', CURRENT_DATE)::date;

-- VIEW: Ranking de economia
CREATE OR REPLACE VIEW public.v_ranking_economia AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY r.economia_total_gerada DESC) as posicao,
    u.nome,
    u.email,
    u.role,
    r.vouchers_gerados,
    r.vouchers_utilizados,
    r.economia_total_gerada,
    r.economia_media_por_voucher,
    CASE 
        WHEN r.vouchers_gerados > 0 THEN 
            ROUND((r.vouchers_utilizados::numeric / r.vouchers_gerados::numeric) * 100, 1)
        ELSE 0 
    END as taxa_utilizacao,
    r.premiado,
    r.periodo
FROM public.ranking_vouchers r
JOIN public.usuarios u ON r.usuario_id = u.id
WHERE r.periodo = DATE_TRUNC('month', CURRENT_DATE)::date
ORDER BY r.economia_total_gerada DESC;

-- VIEW: Histórico de consultas do usuário
CREATE OR REPLACE VIEW public.v_historico_consultas AS
SELECT 
    c.id,
    c.tipo_consulta,
    c.parametros_consulta,
    c.resultado_consulta,
    c.economia_gerada,
    c.tempo_execucao_ms,
    c.created_at,
    -- Informações do voucher se aplicável
    v.codigo as voucher_codigo,
    v.percentual_desconto as voucher_desconto
FROM public.consultas_lens_log c
LEFT JOIN public.vouchers_desconto v ON c.voucher_gerado_id = v.id
WHERE c.usuario_id IN (
    SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()
)
ORDER BY c.created_at DESC;

-- VIEW: Configurações do sistema (apenas para admins)
CREATE OR REPLACE VIEW public.v_configuracoes_sistema AS
SELECT 
    chave,
    valor,
    descricao,
    editavel_por,
    created_at,
    updated_at
FROM public.sistema_config_bestlens
WHERE EXISTS (
    SELECT 1 FROM public.usuarios u 
    WHERE u.auth_user_id = auth.uid() 
    AND u.role IN ('financeiro_supervisor', 'admin_junior')
);

-- ============================================================================
-- FUNCTIONS PÚBLICAS PARA FRONTEND
-- ============================================================================

-- Function: Login e autenticação
CREATE OR REPLACE FUNCTION public.api_login_usuario(p_email text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
$$;

-- Function: Obter perfil completo do usuário
CREATE OR REPLACE FUNCTION public.api_perfil_usuario()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_perfil record;
BEGIN
    SELECT * INTO v_perfil FROM public.v_user_profile;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('erro', 'Usuário não encontrado');
    END IF;
    
    RETURN row_to_json(v_perfil)::jsonb;
END;
$$;

-- Function: Listar vouchers com filtros
CREATE OR REPLACE FUNCTION public.api_listar_vouchers(
    p_status text DEFAULT 'disponivel',
    p_limit integer DEFAULT 50
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_vouchers jsonb;
BEGIN
    SELECT jsonb_agg(
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
        )
    ) INTO v_vouchers
    FROM public.v_vouchers_disponiveis
    WHERE (p_status = 'todos' OR status_voucher = p_status)
    ORDER BY created_at DESC
    LIMIT p_limit;
    
    RETURN jsonb_build_object(
        'sucesso', true,
        'vouchers', COALESCE(v_vouchers, '[]'::jsonb),
        'total', jsonb_array_length(COALESCE(v_vouchers, '[]'::jsonb))
    );
END;
$$;

-- Function: Dashboard executivo
CREATE OR REPLACE FUNCTION public.api_dashboard_executivo()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
    
    -- Stats de hoje
    SELECT jsonb_build_object(
        'vouchers_gerados_hoje', COUNT(*) FILTER (WHERE DATE(created_at) = CURRENT_DATE),
        'vouchers_usados_hoje', COUNT(*) FILTER (WHERE DATE(data_uso) = CURRENT_DATE),
        'economia_hoje', COALESCE(SUM(economia_gerada) FILTER (WHERE DATE(created_at) = CURRENT_DATE), 0)
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
$$;

-- Function: Gerar voucher (interface frontend)
CREATE OR REPLACE FUNCTION public.api_frontend_gerar_voucher(
    p_percentual_desconto numeric,
    p_valor_minimo_pedido numeric DEFAULT 0,
    p_valor_maximo_desconto numeric DEFAULT NULL,
    p_validade_dias integer DEFAULT 30,
    p_observacoes text DEFAULT NULL,
    p_confirmar_limite boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
$$;

-- ============================================================================
-- PERMISSÕES E GRANTS
-- ============================================================================

-- Grants para usuários autenticados
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public_api TO authenticated;

-- Grants nas views
GRANT SELECT ON public.v_user_profile TO authenticated;
GRANT SELECT ON public.v_vouchers_disponiveis TO authenticated;
GRANT SELECT ON public.v_dashboard_vouchers TO authenticated;
GRANT SELECT ON public.v_ranking_economia TO authenticated;
GRANT SELECT ON public.v_historico_consultas TO authenticated;
GRANT SELECT ON public.v_configuracoes_sistema TO authenticated;

-- Grants nas functions
GRANT EXECUTE ON FUNCTION public.api_login_usuario(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_perfil_usuario() TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_listar_vouchers(text, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_dashboard_executivo() TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_frontend_gerar_voucher(numeric, numeric, numeric, integer, text, boolean) TO authenticated;

-- Grants para anônimos (apenas login)
GRANT EXECUTE ON FUNCTION public.api_login_usuario(text) TO anon;

-- ============================================================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- ============================================================================

COMMENT ON VIEW public.v_user_profile IS 'Perfil completo do usuário logado com estatísticas';
COMMENT ON VIEW public.v_vouchers_disponiveis IS 'Vouchers disponíveis baseado no role do usuário';
COMMENT ON VIEW public.v_dashboard_vouchers IS 'Dashboard de controle mensal de vouchers';
COMMENT ON VIEW public.v_ranking_economia IS 'Ranking mensal de economia gerada';
COMMENT ON VIEW public.v_historico_consultas IS 'Histórico de consultas do usuário';

COMMENT ON FUNCTION public.api_login_usuario(text) IS 'Autenticação e login do usuário';
COMMENT ON FUNCTION public.api_perfil_usuario() IS 'Obter perfil completo do usuário logado';
COMMENT ON FUNCTION public.api_listar_vouchers(text, integer) IS 'Listar vouchers com filtros';
COMMENT ON FUNCTION public.api_dashboard_executivo() IS 'Dashboard executivo completo';
COMMENT ON FUNCTION public.api_frontend_gerar_voucher(numeric, numeric, numeric, integer, text, boolean) IS 'Gerar voucher pela interface frontend';