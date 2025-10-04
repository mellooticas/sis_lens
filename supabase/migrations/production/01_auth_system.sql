-- ============================================================================
-- SISTEMA DE AUTENTICAÇÃO BESTLENS - DEPLOY SUPABASE CLOUD
-- ============================================================================

-- 1. CRIAR ENUM PARA OS ROLES ESPECÍFICOS
CREATE TYPE public.user_role_enum AS ENUM (
    'dcl_decisor',           -- dcl@oticastatymello.com.br - Consulta real e escolhe o melhor
    'financeiro_supervisor', -- financeiroesc@hotmail.com - Nível acima do DCL, supervisiona tudo
    'admin_junior',          -- junior@oticastatymello.com.br - Admin geral
    'loja_consulta'          -- lojas@oticastatymello.com.br - Apenas tabela de preços e vouchers
);

-- 2. TABELA DE USUÁRIOS PRINCIPAL
CREATE TABLE public.usuarios (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email text NOT NULL UNIQUE,
    nome text NOT NULL,
    tenant_id uuid,
    role user_role_enum NOT NULL DEFAULT 'loja_consulta',
    permissoes_especiais text[] DEFAULT '{}',
    ativo boolean DEFAULT true,
    ultimo_acesso timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    auth_user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    loja_id uuid,
    limite_consultas_dia integer DEFAULT 50,
    vouchers_gerados_mes integer DEFAULT 0,
    session_token text,
    session_expires_at timestamp with time zone
);

-- 3. TABELA DE VOUCHERS DE DESCONTO
CREATE TABLE public.vouchers_desconto (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo text NOT NULL UNIQUE,
    usuario_gerador_id uuid NOT NULL REFERENCES usuarios(id),
    loja_destinatario_id uuid,
    percentual_desconto numeric(5,2) NOT NULL CHECK (percentual_desconto > 0 AND percentual_desconto <= 100),
    valor_minimo_pedido numeric(10,2) DEFAULT 0,
    valor_maximo_desconto numeric(10,2),
    ativo boolean DEFAULT true,
    usado boolean DEFAULT false,
    data_uso timestamp with time zone,
    usuario_uso_id uuid REFERENCES usuarios(id),
    pedido_id uuid,
    valido_de timestamp with time zone DEFAULT now(),
    valido_ate timestamp with time zone NOT NULL,
    observacoes text,
    metadata jsonb DEFAULT '{}',
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 4. TABELA DE LOG DE CONSULTAS
CREATE TABLE public.consultas_lens_log (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id uuid NOT NULL REFERENCES usuarios(id),
    tipo_consulta text NOT NULL,
    parametros_consulta jsonb NOT NULL,
    resultado_consulta jsonb,
    tempo_execucao_ms integer,
    economia_gerada numeric(10,2),
    voucher_gerado_id uuid REFERENCES vouchers_desconto(id),
    ip_origem inet,
    user_agent text,
    created_at timestamp with time zone DEFAULT now()
);

-- 5. TABELA DE CONFIGURAÇÕES
CREATE TABLE public.sistema_config_bestlens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    chave text NOT NULL UNIQUE,
    valor jsonb NOT NULL,
    descricao text,
    editavel_por user_role_enum[] DEFAULT '{"admin_junior", "financeiro_supervisor"}',
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 6. TABELA DE RANKING
CREATE TABLE public.ranking_vouchers (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id uuid NOT NULL REFERENCES usuarios(id),
    periodo date NOT NULL DEFAULT CURRENT_DATE,
    vouchers_gerados integer DEFAULT 0,
    vouchers_utilizados integer DEFAULT 0,
    economia_total_gerada numeric(10,2) DEFAULT 0,
    economia_media_por_voucher numeric(10,2) DEFAULT 0,
    posicao_economia integer,
    posicao_eficiencia integer,
    premiado boolean DEFAULT false,
    tipo_premio text,
    valor_premio jsonb,
    created_at timestamp with time zone DEFAULT now(),
    UNIQUE(usuario_id, periodo)
);

-- ============================================================================
-- INSERIR USUÁRIOS
-- ============================================================================

INSERT INTO public.usuarios (email, nome, role, permissoes_especiais, limite_consultas_dia) VALUES
('dcl@oticastatymello.com.br', 'DCL - Decisor de Lentes', 'dcl_decisor', '{"lens_decision", "full_catalog_access", "price_comparison", "voucher_generation"}', 1000),
('financeiroesc@hotmail.com', 'Supervisor Financeiro', 'financeiro_supervisor', '{"full_system_access", "user_management", "financial_reports", "system_config", "voucher_management"}', -1),
('junior@oticastatymello.com.br', 'Administrador Junior', 'admin_junior', '{"user_management", "system_config", "reports", "voucher_management"}', 500),
('lojas@oticastatymello.com.br', 'Portal das Lojas', 'loja_consulta', '{"price_table_access", "voucher_usage", "basic_reports"}', 100);

-- ============================================================================
-- CONFIGURAÇÕES INICIAIS
-- ============================================================================

INSERT INTO public.sistema_config_bestlens (chave, valor, descricao) VALUES
('voucher_config', '{"min_desconto": 5.0, "max_desconto": 25.0, "validade_dias": 30, "limite_mensal_por_usuario": 50, "economia_minima_para_premio": 1000.00}', 'Configurações gerais do sistema de vouchers'),
('limites_consulta', '{"dcl_decisor": 1000, "financeiro_supervisor": -1, "admin_junior": 500, "loja_consulta": 100}', 'Limites de consulta por role'),
('gamificacao_config', '{"ranking_reset_day": 1, "premio_top_3": true, "bonus_economia_percentual": 2.5, "meta_mensal_vouchers": 20}', 'Configurações do sistema de gamificação');

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vouchers_desconto ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consultas_lens_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ranking_vouchers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sistema_config_bestlens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "usuarios_self_access" ON public.usuarios FOR ALL USING (
    auth.email() = email OR
    EXISTS (SELECT 1 FROM public.usuarios u WHERE u.auth_user_id = auth.uid() AND u.role IN ('financeiro_supervisor', 'admin_junior'))
);

CREATE POLICY "vouchers_creator_access" ON public.vouchers_desconto FOR ALL USING (
    usuario_gerador_id IN (SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()) OR
    EXISTS (SELECT 1 FROM public.usuarios u WHERE u.auth_user_id = auth.uid() AND u.role IN ('financeiro_supervisor', 'admin_junior'))
);

CREATE POLICY "vouchers_loja_usage" ON public.vouchers_desconto FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.usuarios u WHERE u.auth_user_id = auth.uid() AND u.role = 'loja_consulta' AND (loja_destinatario_id IS NULL OR loja_destinatario_id = u.loja_id))
);

CREATE POLICY "consultas_self_access" ON public.consultas_lens_log FOR ALL USING (
    usuario_id IN (SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()) OR
    EXISTS (SELECT 1 FROM public.usuarios u WHERE u.auth_user_id = auth.uid() AND u.role IN ('financeiro_supervisor', 'admin_junior'))
);

CREATE POLICY "ranking_self_and_supervisors" ON public.ranking_vouchers FOR ALL USING (
    usuario_id IN (SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()) OR
    EXISTS (SELECT 1 FROM public.usuarios u WHERE u.auth_user_id = auth.uid() AND u.role IN ('financeiro_supervisor', 'admin_junior'))
);

CREATE POLICY "config_supervisors_only" ON public.sistema_config_bestlens FOR ALL USING (
    EXISTS (SELECT 1 FROM public.usuarios u WHERE u.auth_user_id = auth.uid() AND u.role IN ('financeiro_supervisor', 'admin_junior'))
);

-- ============================================================================
-- ÍNDICES
-- ============================================================================

CREATE INDEX idx_usuarios_email ON public.usuarios(email);
CREATE INDEX idx_usuarios_role ON public.usuarios(role);
CREATE INDEX idx_usuarios_auth_user_id ON public.usuarios(auth_user_id);
CREATE INDEX idx_vouchers_codigo ON public.vouchers_desconto(codigo);
CREATE INDEX idx_vouchers_usuario_gerador ON public.vouchers_desconto(usuario_gerador_id);
CREATE INDEX idx_vouchers_ativo_valido ON public.vouchers_desconto(ativo, valido_ate) WHERE ativo = true;
CREATE INDEX idx_vouchers_usado ON public.vouchers_desconto(usado, data_uso);
CREATE INDEX idx_consultas_usuario_data ON public.consultas_lens_log(usuario_id, created_at);
CREATE INDEX idx_consultas_tipo ON public.consultas_lens_log(tipo_consulta);
CREATE INDEX idx_ranking_periodo ON public.ranking_vouchers(periodo);
CREATE INDEX idx_ranking_posicoes ON public.ranking_vouchers(posicao_economia, posicao_eficiencia);

-- ============================================================================
-- FUNÇÕES
-- ============================================================================

CREATE OR REPLACE FUNCTION public.gerar_codigo_voucher()
RETURNS text LANGUAGE plpgsql AS $$
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
$$;

CREATE OR REPLACE FUNCTION public.usuario_tem_permissao(p_email text, p_permissao text)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER AS $$
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
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_usuarios_updated_at BEFORE UPDATE ON public.usuarios FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_vouchers_updated_at BEFORE UPDATE ON public.vouchers_desconto FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trigger_config_updated_at BEFORE UPDATE ON public.sistema_config_bestlens FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- GRANTS
-- ============================================================================

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;