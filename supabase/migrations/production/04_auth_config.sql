-- ============================================================================
-- CONFIGURAÇÃO DE AUTENTICAÇÃO - BESTLENS (VERSÃO CORRIGIDA)
-- Sistema simplificado de login e permissões para Supabase
-- ============================================================================

-- ============================================================================
-- 1. FUNCTION PARA VALIDAR LOGIN (FRONTEND)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.api_validar_login()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
$$;

-- ============================================================================
-- 2. FUNCTION PARA LOGOUT
-- ============================================================================

CREATE OR REPLACE FUNCTION public.api_logout_usuario()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
$$;

-- ============================================================================
-- 3. FUNCTION PARA TROCAR SENHA (PLACEHOLDER)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.api_trocar_senha(
    p_senha_atual text,
    p_senha_nova text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
$$;

-- ============================================================================
-- 4. CONFIGURAÇÕES DE SEGURANÇA
-- ============================================================================

-- RLS para controle_vouchers_mensal
ALTER TABLE public.controle_vouchers_mensal ENABLE ROW LEVEL SECURITY;

CREATE POLICY "controle_vouchers_supervisors" ON public.controle_vouchers_mensal
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.usuarios u 
        WHERE u.auth_user_id = auth.uid() 
        AND u.role IN ('financeiro_supervisor', 'admin_junior', 'dcl_decisor')
    )
);

-- ============================================================================
-- 5. GRANTS DE PERMISSÕES
-- ============================================================================

-- Functions de autenticação
GRANT EXECUTE ON FUNCTION public.api_validar_login() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.api_logout_usuario() TO authenticated;
GRANT EXECUTE ON FUNCTION public.api_trocar_senha(text, text) TO authenticated;

-- Permitir inserção de logs para autenticados
GRANT INSERT ON public.consultas_lens_log TO authenticated;

-- ============================================================================
-- 6. DADOS INICIAIS PARA TESTE
-- ============================================================================

-- Inserir período atual no controle de vouchers se não existir
INSERT INTO public.controle_vouchers_mensal (periodo)
SELECT DATE_TRUNC('month', CURRENT_DATE)::date
WHERE NOT EXISTS (
    SELECT 1 FROM public.controle_vouchers_mensal 
    WHERE periodo = DATE_TRUNC('month', CURRENT_DATE)::date
);

-- ============================================================================
-- 7. COMENTÁRIOS E DOCUMENTAÇÃO
-- ============================================================================

COMMENT ON FUNCTION public.api_validar_login() IS 'Validar login e retornar dados do usuário';
COMMENT ON FUNCTION public.api_logout_usuario() IS 'Registrar logout do usuário';
COMMENT ON FUNCTION public.api_trocar_senha(text, text) IS 'Trocar senha do usuário logado';

-- ============================================================================
-- TESTE FINAL
-- ============================================================================

-- Verificar se tudo foi criado corretamente
SELECT 
    'Configuração de autenticação concluída' as status,
    COUNT(*) as usuarios_cadastrados
FROM public.usuarios;

SELECT 
    'Functions de autenticação criadas' as status,
    routine_name
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('api_validar_login', 'api_logout_usuario', 'api_trocar_senha')
ORDER BY routine_name;