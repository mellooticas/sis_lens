# 🔧 SETUP INICIAL - BestLens

> **Objetivo**: Preparar o banco BestLens para receber as migrações  
> **Executar**: UMA VEZ, antes de qualquer migração  
> **Data**: 06/10/2025

---

## 📋 ORDEM DE EXECUÇÃO

1. ✅ **Schemas** - Já criados no Supabase
2. ✅ **Tabelas** - Já criadas no Supabase  
3. 🔴 **Tenant** - **FALTA CRIAR** (este documento)
4. ⏳ Migrações de dados

---

## 🎯 SEÇÃO 1: CRIAR TENANT PRINCIPAL

### **Tenant: Óticas Taty Mello**

```sql
-- ========================================
-- CRIAR TENANT PRINCIPAL
-- ID Fixo para todas as migrações
-- ========================================

-- 1. Verificar se já existe
SELECT id, nome, slug, ativo, criado_em
FROM meta_system.tenants;

-- ✅ Resultado atual:
-- | id                                   | nome          | slug | ativo | criado_em                     |
-- | ------------------------------------ | ------------- | ---- | ----- | ----------------------------- |
-- | c6c9818a-0cb8-4bf9-952c-4385c54713a2 | BestLens Demo | demo | true  | 2025-10-03 03:31:18.721122+00 |
-- ⚠️ Tenant de teste existe, vamos criar o tenant de produção

-- 1.1 Verificar estrutura da tabela tenants
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'meta_system' 
  AND table_name = 'tenants'
ORDER BY ordinal_position;

-- ✅ Cole o resultado aqui para confirmarmos os campos:


-- 2. Inserir tenant (se não existir)
INSERT INTO meta_system.tenants (
    id,
    nome,
    slug,
    ativo,
    configuracoes,
    criado_em,
    atualizado_em
) VALUES (
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Óticas Taty Mello',
    'oticas-taty-mello',
    true,
    jsonb_build_object(
        'tipo_negocio', 'optica_varejo',
        'numero_lojas', 1,
        'regiao_atuacao', 'Sudeste',
        'cidade', 'São Paulo',
        'estado', 'SP'
    ),
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    atualizado_em = NOW();

-- ✅ RESULTADO: INSERT 0 1 (Tenant criado com sucesso!)

-- 3. Confirmar criação
SELECT 
    id,
    nome,
    slug,
    ativo,
    configuracoes,
    criado_em
FROM meta_system.tenants
WHERE id = '550e8400-e29b-41d4-a716-446655440000'::uuid;

-- ✅ CONFIRMADO:
-- | id                                   | nome              | slug              | ativo | configuracoes                                                                                                   | criado_em                     |
-- | ------------------------------------ | ----------------- | ----------------- | ----- | --------------------------------------------------------------------------------------------------------------- | ----------------------------- |
-- | 550e8400-e29b-41d4-a716-446655440000 | Óticas Taty Mello | oticas-taty-mello | true  | {"cidade":"São Paulo","estado":"SP","numero_lojas":1,"tipo_negocio":"optica_varejo","regiao_atuacao":"Sudeste"} | 2025-10-06 18:12:49.229712+00 |
```

### **✅ TENANT CRIADO COM SUCESSO!**

O tenant **Óticas Taty Mello** foi criado e está pronto para receber as migrações! 🎉

```
id                                   | nome                 | slug               | ativo
-------------------------------------|----------------------|--------------------|------
550e8400-e29b-41d4-a716-446655440000 | Óticas Taty Mello    | oticas-taty-mello  | t
```

---

## 🔍 SEÇÃO 2: VALIDAR ESTRUTURA DO BANCO

### **2.1 - Verificar Schemas**

```sql
-- Listar todos os schemas
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name IN (
    'meta_system',
    'lens_catalog',
    'suppliers',
    'commercial',
    'logistics',
    'orders',
    'scoring',
    'analytics'
)
ORDER BY schema_name;

-- ✅ RESULTADO: 8 schemas encontrados
-- | schema_name  |
-- | ------------ |
-- | analytics    |
-- | commercial   |
-- | lens_catalog |
-- | logistics    |
-- | meta_system  |
-- | orders       |
-- | scoring      |
-- | suppliers    |
```

### **2.2 - Verificar Tabelas Principais**

```sql
-- Meta System (deve ter 2 tenants agora: Demo + Taty Mello)
SELECT 'tenants' as tabela, COUNT(*) as registros FROM meta_system.tenants
UNION ALL
-- Suppliers (vazias ainda)
SELECT 'laboratorios', COUNT(*) FROM suppliers.laboratorios
UNION ALL
SELECT 'marcas', COUNT(*) FROM suppliers.marcas
UNION ALL
SELECT 'produtos_laboratorio', COUNT(*) FROM suppliers.produtos_laboratorio
UNION ALL
-- Lens Catalog (vazias ainda)
SELECT 'lentes_canonicas', COUNT(*) FROM lens_catalog.lentes_canonicas
UNION ALL
SELECT 'lentes_premium', COUNT(*) FROM lens_catalog.lentes_premium
UNION ALL
-- Commercial (vazias ainda)
SELECT 'tabelas_preco', COUNT(*) FROM commercial.tabelas_preco
UNION ALL
SELECT 'precos_produtos', COUNT(*) FROM commercial.precos_produtos;

-- ✅ Cole o resultado aqui:
```

### **✅ Resultado Esperado (antes das migrações)**

```
tabela              | registros
--------------------|----------
tenants             | 2         ← Demo + Taty Mello ✅
laboratorios        | 0         ← Será migrado
marcas              | 0         ← Será migrado
produtos_laboratorio| 0         ← Será migrado
lentes_canonicas    | 0         ← Será migrado
lentes_premium      | 0         ← Será migrado
tabelas_preco       | 0         ← Será migrado
precos_produtos     | 0         ← Será migrado
```

---

## 🎯 SEÇÃO 3: POLÍTICAS RLS (Row Level Security)

### **⚠️ Importante para Multi-Tenancy**

```sql
-- Verificar se RLS está habilitado nas tabelas principais
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables
WHERE schemaname IN ('suppliers', 'lens_catalog', 'commercial', 'orders')
ORDER BY schemaname, tablename;

-- ✅ RESULTADO: RLS configurado na maioria das tabelas
-- | schemaname   | tablename            | rls_ativo |
-- | ------------ | -------------------- | --------- |
-- | commercial   | descontos            | true      |
-- | commercial   | historico_precos     | true      |
-- | commercial   | precos_base          | true      |
-- | lens_catalog | lentes               | true      |
-- | lens_catalog | lentes_canonicas     | false     | ⚠️ Sem RLS (OK para MVP)
-- | lens_catalog | lentes_premium       | false     | ⚠️ Sem RLS (OK para MVP)
-- | lens_catalog | marcas               | true      |
-- | orders       | alternativas_cotacao | true      |
-- | orders       | criterios_decisao    | true      |
-- | orders       | decisoes_lentes      | true      |
-- | orders       | historico_status     | true      |
-- | suppliers    | historico_produtos   | true      |
-- | suppliers    | laboratorios         | true      | ✅ Protegido por tenant_id
-- | suppliers    | produtos_laboratorio | true      | ✅ Protegido por tenant_id

-- ✅ RLS está ativo nas tabelas críticas (suppliers, commercial, orders)
-- Se RLS não estiver ativo, habilitar:
-- (Executar apenas se necessário)

-- ALTER TABLE suppliers.laboratorios ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE suppliers.marcas ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE suppliers.produtos_laboratorio ENABLE ROW LEVEL SECURITY;
-- ... (repetir para outras tabelas)
```

---

## 📊 SEÇÃO 4: RESUMO DO SETUP

### **✅ Status Atual**

| Item | Status | Observação |
|------|--------|------------|
| Schemas (8) | ✅ Verificado | analytics, commercial, lens_catalog, logistics, meta_system, orders, scoring, suppliers |
| Tabelas | ✅ Criadas | Estrutura completa existente |
| Views | ✅ Criadas | `vw_todas_lentes`, etc |
| Tenant Principal | ✅ **CRIADO** | UUID: `550e8400...` - Óticas Taty Mello |
| RLS Policies | ✅ Ativo | Tabelas críticas protegidas |

### **🎯 PRONTO PARA MIGRAÇÕES!**

Após este setup bem-sucedido, execute as migrações na ordem:

1. ✅ **Migração 01**: Fornecedores → Laboratórios (11 registros)
2. ⏳ **Migração 02**: Marcas (6 registros)
3. ⏳ **Migração 03**: Lentes Canônicas (265 registros)
4. ⏳ **Migração 04**: Lentes Premium Essilor (21 registros)
5. ⏳ **Migração 05**: Produtos de Laboratório (1.411 registros)
6. ⏳ **Migração 06**: Tabelas de Preço e Preços
7. ⏳ **Migração 07**: Prazos de Entrega

---

## 🚨 TROUBLESHOOTING

### **Erro: Schema não existe**
```sql
-- Verificar se migrations do Supabase foram aplicadas
SELECT * FROM supabase_migrations.schema_migrations
ORDER BY version DESC
LIMIT 5;
```

### **Erro: Tabela não existe**
```sql
-- Listar tabelas de um schema específico
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'suppliers';
```

### **Erro: Tenant duplicado**
```sql
-- Atualizar ao invés de inserir
UPDATE meta_system.tenants
SET 
    nome = 'Óticas Taty Mello',
    slug = 'oticas-taty-mello',
    ativo = true,
    atualizado_em = NOW()
WHERE id = '550e8400-e29b-41d4-a716-446655440000'::uuid;
```

---

## 📝 CHECKLIST DE SETUP

- [x] Conectado ao Supabase BestLens
- [x] Schemas verificados (8 existem)
- [x] Tabelas verificadas (principais existem)
- [x] **✅ Tenant criado (Óticas Taty Mello)**
- [x] Validações executadas (schemas, tabelas, RLS)
- [x] **✅ PRONTO PARA MIGRAÇÃO 01!**

---

**Status**: ✅ **SETUP CONCLUÍDO COM SUCESSO!**  
**Tenant criado**: `550e8400-e29b-41d4-a716-446655440000` - Óticas Taty Mello  
**Próximo passo**: Executar `01_MIGRACAO_FORNECEDORES.md`  
**Última atualização**: 06/10/2025 - 18:12 BRT
