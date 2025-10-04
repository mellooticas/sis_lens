-- Migration: 001_create_schemas.sql
-- Cria todos os schemas do sistema conforme Blueprint

-- ============================================
-- SCHEMAS
-- ============================================

-- Schema para metadados do sistema (tenants, auth, feature flags)
CREATE SCHEMA IF NOT EXISTS meta_system;

-- Schema para catálogo canônico de lentes (fonte da verdade)
CREATE SCHEMA IF NOT EXISTS lens_catalog;

-- Schema para fornecedores/laboratórios
CREATE SCHEMA IF NOT EXISTS suppliers;

-- Schema para precificação e descontos
CREATE SCHEMA IF NOT EXISTS commercial;

-- Schema para logística (prazos e fretes)
CREATE SCHEMA IF NOT EXISTS logistics;

-- Schema para scoring e qualidade
CREATE SCHEMA IF NOT EXISTS scoring;

-- Schema para pedidos e decisões
CREATE SCHEMA IF NOT EXISTS orders;

-- Schema para analytics e relatórios
CREATE SCHEMA IF NOT EXISTS analytics;

-- ============================================
-- EXTENSIONS
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- ============================================
-- ENUMS GLOBAIS
-- ============================================

-- Critérios de decisão
CREATE TYPE public.criterio_decisao AS ENUM ('URGENCIA', 'NORMAL', 'ESPECIAL');

-- Tipos de lente
CREATE TYPE public.tipo_lente AS ENUM ('MONOFOCAL', 'BIFOCAL', 'TRIFOCAL', 'PROGRESSIVA', 'OCUPACIONAL');

-- Materiais de lente
CREATE TYPE public.material_lente AS ENUM ('CR39', 'POLICARBONATO', 'TRIVEX', 'HIGH_INDEX_160', 'HIGH_INDEX_167', 'HIGH_INDEX_174');

-- Tratamentos disponíveis
CREATE TYPE public.tratamento_lente AS ENUM ('HC', 'AR', 'BLUE', 'PHOTOCHROMIC', 'POLARIZADO', 'OLEOFOBICO', 'HIDROFOBICO');

-- Status de decisão
CREATE TYPE public.status_decisao AS ENUM ('DECIDIDO', 'ENVIADO', 'CONFIRMADO', 'ENTREGUE', 'CANCELADO');

-- Tipos de desconto
CREATE TYPE public.tipo_desconto AS ENUM ('PERCENTUAL', 'VALOR_FIXO', 'PRECO_TETO');

-- Escopo de desconto
CREATE TYPE public.escopo_desconto AS ENUM ('LABORATORIO', 'MARCA', 'PRODUTO');

COMMENT ON SCHEMA meta_system IS 'Sistema multi-tenant, autenticação e configurações';
COMMENT ON SCHEMA lens_catalog IS 'Catálogo canônico de lentes - fonte da verdade técnica';
COMMENT ON SCHEMA suppliers IS 'Laboratórios e seus catálogos nativos';
COMMENT ON SCHEMA commercial IS 'Preços, tabelas e regras de desconto';
COMMENT ON SCHEMA logistics IS 'Prazos de entrega e custos de frete';
COMMENT ON SCHEMA scoring IS 'Métricas de qualidade e performance dos labs';
COMMENT ON SCHEMA orders IS 'Decisões de compra e histórico';
COMMENT ON SCHEMA analytics IS 'Views materializadas e relatórios';