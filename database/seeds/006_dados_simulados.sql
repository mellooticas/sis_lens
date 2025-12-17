-- ===============================================
-- 006_dados_simulados.sql
-- Dados Históricos Simulados - 6 Meses de Operação
-- Data: 04/10/2025
-- ===============================================

-- AVISO: Este script requer os schemas 'scoring' e 'analytics'
-- que ainda não foram criados no banco de dados atual.
-- Este script está DESABILITADO até que esses schemas sejam criados.

-- Schemas necessários:
-- - scoring (decisoes, lens_scores, criterios_avaliacao)
-- - analytics (consultas_sistema, metricas_performance, feedback_decisoes, etc)

-- Para habilitar este script, primeiro execute as migrations que criam
-- esses schemas ou crie-os manualmente.

/*
BEGIN;

-- ===============================================
-- SCRIPT DESABILITADO - AGUARDANDO SCHEMAS
-- ===============================================
-- Este script seria executado após criar os schemas necessários

ROLLBACK;
*/

-- ===============================================
-- LOG DE EXECUÇÃO
-- ===============================================

-- Registrar que o script foi pulado
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'meta_system' AND table_name = 'logs_sistema') THEN
        INSERT INTO meta_system.logs_sistema (
            id,
            tenant_id,
            nivel,
            categoria,
            mensagem,
            detalhes,
            created_at
        ) VALUES (
            gen_random_uuid(),
            (SELECT id FROM meta_system.tenants WHERE slug = 'bestlens-demo' LIMIT 1),
            'WARNING',
            'DATABASE_SEED',
            'Script 006_dados_simulados.sql PULADO - schemas scoring e analytics não existem',
            '{"script": "006_dados_simulados.sql", "status": "skipped", "motivo": "schemas_ausentes", "schemas_necessarios": ["scoring", "analytics"]}'::jsonb,
            NOW()
        );
    END IF;
END $$;

-- ===============================================
-- FIM DO SCRIPT 006_dados_simulados.sql
-- ===============================================