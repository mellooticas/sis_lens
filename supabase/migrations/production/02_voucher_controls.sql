-- ============================================================================
-- SISTEMA DE CONTROLES AVANÇADOS PARA VOUCHERS - BESTLENS
-- ============================================================================

-- 1. ATUALIZAR CONFIGURAÇÕES COM LIMITES RIGOROSOS
UPDATE public.sistema_config_bestlens 
SET valor = jsonb_set(
    valor,
    '{limite_mensal_vouchers_sistema}',
    '80'::jsonb
)
WHERE chave = 'voucher_config';

UPDATE public.sistema_config_bestlens 
SET valor = jsonb_set(
    valor,
    '{limite_mensal_valor_total}',
    '16000.00'::jsonb
)
WHERE chave = 'voucher_config';

UPDATE public.sistema_config_bestlens 
SET valor = jsonb_set(
    valor,
    '{max_desconto_por_role}',
    '{"dcl_decisor": 20.0, "financeiro_supervisor": 25.0, "admin_junior": 15.0}'::jsonb
)
WHERE chave = 'voucher_config';

-- 2. CRIAR TABELA DE CONTROLE MENSAL
CREATE TABLE public.controle_vouchers_mensal (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    periodo date NOT NULL DEFAULT date_trunc('month', CURRENT_DATE)::date,
    
    -- Contadores globais do sistema
    total_vouchers_gerados integer DEFAULT 0,
    total_vouchers_utilizados integer DEFAULT 0,
    valor_total_economia_gerada numeric(10,2) DEFAULT 0,
    valor_total_economia_potencial numeric(10,2) DEFAULT 0,
    
    -- Limites configurados no período
    limite_vouchers_periodo integer DEFAULT 80,
    limite_valor_periodo numeric(10,2) DEFAULT 16000.00,
    
    -- Status do controle
    bloqueado boolean DEFAULT false,
    motivo_bloqueio text,
    bloqueado_em timestamp with time zone,
    
    -- Alertas
    alerta_80_pct boolean DEFAULT false,
    alerta_90_pct boolean DEFAULT false,
    
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    
    UNIQUE(periodo)
);

-- 3. FUNÇÃO PARA VERIFICAR LIMITES ANTES DE GERAR VOUCHER
CREATE OR REPLACE FUNCTION public.verificar_limites_voucher(
    p_percentual_desconto numeric,
    p_valor_maximo_desconto numeric DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
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
$$;

-- 4. ATUALIZAR FUNÇÃO DE GERAR VOUCHER COM CONTROLES
CREATE OR REPLACE FUNCTION public.api_gerar_voucher_controlado(
    p_percentual_desconto numeric,
    p_valor_minimo_pedido numeric DEFAULT 0,
    p_valor_maximo_desconto numeric DEFAULT NULL,
    p_validade_dias integer DEFAULT 30,
    p_loja_destinatario_id uuid DEFAULT NULL,
    p_observacoes text DEFAULT NULL,
    p_force_admin boolean DEFAULT false -- Apenas supervisor financeiro pode forçar
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
$$;

-- 5. FUNÇÃO PARA DASHBOARD DE CONTROLE
CREATE OR REPLACE FUNCTION public.api_dashboard_controle_vouchers()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
$$;