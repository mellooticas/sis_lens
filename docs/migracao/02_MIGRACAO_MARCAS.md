# 📦 MIGRAÇÃO 02: MARCAS DE LENTES

> **Status**: ✅ CONCLUÍDA  
> **Data**: 06/10/2025  
> **Estratégia**: Criar marcas baseadas em laboratórios + marcas próprias conhecidas  
> **Registros criados**: 14 (6 internacionais + 8 brasileiras)

---

## ⚠️ **IMPORTANTE: MUDANÇA DE ESTRATÉGIA**

### **Descoberta:**
- ❌ `produtos.marcas` no Mello = Marcas de **armações** (não serve!)
- ✅ Precisamos criar marcas de **lentes** (Essilor, Zeiss, Hoya, Varilux, etc)

### **Nova Abordagem:**
1. ✅ Usar **nomes dos laboratórios** como marcas base
2. ✅ Adicionar **marcas próprias** conhecidas (Varilux, Crizal, Transitions, etc)
3. ✅ Criar de forma manual e controlada

---

## 📊 SEÇÃO 1: ESTRUTURA DA TABELA DESTINO

### **Tabela DESTINO (BestLens)**
```sql
-- Schema: suppliers
-- Tabela: marcas

CREATE TABLE suppliers.marcas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id),
  nome TEXT NOT NULL,
  descricao TEXT,
  pais_origem TEXT,
  site_oficial TEXT,
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT uk_marca_tenant UNIQUE (tenant_id, nome)
);
```

---

## � SEÇÃO 2: MARCAS A CRIAR

### **Baseadas nos Laboratórios Migrados (11)**

Da Migração 01, temos estes laboratórios que também são marcas:

1. ✅ **Brascor** - Laboratório brasileiro
2. ✅ **Braslentes** - Laboratório brasileiro
3. ✅ **Express** - Laboratório brasileiro
4. ✅ **Polylux** - Laboratório brasileiro
5. ✅ **Sygma** - Laboratório brasileiro
6. ✅ **Galeria Florencio** - Fornecedor
7. ✅ **Kaizi** - Fornecedor de óculos solares
8. ✅ **Navarro** - Fornecedor linha Xclusive
9. ✅ **Sao Paulo Acessorios** - Fornecedor INFINITY
10. ✅ **So Blocos** - Laboratório
11. ✅ **Style** - Laboratório

### **Marcas Próprias Conhecidas (Adicionar)**

Marcas premium/especializadas que devem existir:

12. ✅ **Essilor** - França (marca líder mundial)
13. ✅ **Varilux** - França (progressivas Essilor)
14. ✅ **Crizal** - França (tratamentos Essilor)
15. ✅ **Transitions** - USA (fotossensíveis)
16. ✅ **Zeiss** - Alemanha (óptica premium)
17. ✅ **Hoya** - Japão (lentes premium)

### **Total Proposto: 17 marcas**

---

## ✅ SEÇÃO 3: SQL DE CRIAÇÃO (BESTLENS)

## ✅ SEÇÃO 3: SQL DE CRIAÇÃO (BESTLENS)

### **Status**: ✅ SQL PRONTO - Executar no BestLens!

```sql
-- ========================================
-- CRIAÇÃO DE 17 MARCAS DE LENTES
-- tenant_id: 550e8400-e29b-41d4-a716-446655440000
-- Executar no banco BESTLENS
-- ========================================

BEGIN;

-- ========================================
-- GRUPO 1: MARCAS INTERNACIONAIS PREMIUM
-- ========================================

-- 1. Essilor (França) - Líder mundial
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Essilor',
    'Líder mundial em lentes oftálmicas',
    'França',
    'https://www.essilor.com.br',
    true,
    NOW()
);

-- 2. Varilux (França) - Lentes progressivas Essilor
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Varilux',
    'Lentes progressivas premium (marca Essilor)',
    'França',
    'https://www.varilux.com.br',
    true,
    NOW()
);

-- 3. Crizal (França) - Tratamentos antirreflexo Essilor
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Crizal',
    'Tratamentos antirreflexo premium (marca Essilor)',
    'França',
    'https://www.crizal.com.br',
    true,
    NOW()
);

-- 4. Transitions (USA) - Lentes fotossensíveis
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Transitions',
    'Lentes fotossensíveis que escurecem ao sol',
    'Estados Unidos',
    'https://www.transitions.com',
    true,
    NOW()
);

-- 5. Zeiss (Alemanha) - Óptica premium
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Zeiss',
    'Óptica de precisão alemã',
    'Alemanha',
    'https://www.zeiss.com.br',
    true,
    NOW()
);

-- 6. Hoya (Japão) - Lentes premium
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Hoya',
    'Tecnologia japonesa em lentes oftálmicas',
    'Japão',
    'https://www.hoyavision.com.br',
    true,
    NOW()
);

-- ========================================
-- GRUPO 2: LABORATÓRIOS BRASILEIROS
-- (Baseados nos fornecedores migrados)
-- ========================================

-- 7. Brascor
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Brascor',
    'Laboratório brasileiro distribuidora de lentes',
    'Brasil',
    NULL,
    true,
    NOW()
);

-- 8. Braslentes
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Braslentes',
    'Champ Brasil - Laboratório de lentes',
    'Brasil',
    NULL,
    true,
    NOW()
);

-- 9. Express
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Express',
    'Lentes e Cia Express - Laboratório brasileiro',
    'Brasil',
    NULL,
    true,
    NOW()
);

-- 10. Polylux
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Polylux',
    'Laboratório de produtos ópticos',
    'Brasil',
    NULL,
    true,
    NOW()
);

-- 11. Sygma
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Sygma',
    'Sygma Lentes - Laboratório Óptico',
    'Brasil',
    'https://www.sygmalentes.com.br',
    true,
    NOW()
);

-- 12. Galeria Florencio
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Galeria Florencio',
    'Comércio de produtos ópticos',
    'Brasil',
    NULL,
    true,
    NOW()
);

-- 13. Kaizi
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Kaizi',
    'Importação e exportação de óculos',
    'Brasil',
    NULL,
    true,
    NOW()
);

-- 14. Navarro
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Navarro',
    'Distribuidora linha Xclusive',
    'Brasil',
    NULL,
    true,
    NOW()
);

-- 15. Sao Paulo Acessorios
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Sao Paulo Acessorios',
    'Fornecedor de produtos INFINITY',
    'Brasil',
    NULL,
    true,
    NOW()
);

-- 16. So Blocos
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'So Blocos',
    'Comércio e serviços ópticos',
    'Brasil',
    NULL,
    true,
    NOW()
);

-- 17. Style
INSERT INTO suppliers.marcas (
    id, tenant_id, nome, descricao, pais_origem, site_oficial, ativo, criado_em
) VALUES (
    gen_random_uuid(),
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Style',
    'Style Primer - Lentes oftálmicas',
    'Brasil',
    NULL,
    true,
    NOW()
);

COMMIT;

-- ========================================
-- FIM DA CRIAÇÃO DE MARCAS
-- Registros criados: 17
-- ========================================
```

### **Instruções de Execução**

1. **Copie todo o SQL acima**
2. **Abra o SQL Editor no Supabase BestLens**
3. **Cole e execute**
4. **Verifique o resultado**: deve retornar `COMMIT` sem erros
5. **Prossiga para SEÇÃO 4** para validar os dados

---

## 🔍 SEÇÃO 4: VALIDAÇÃO

_Esta seção será preenchida após você colar os dados exportados e confirmarmos a estrutura._

**O que será gerado:**
1. INSERT statements para as 6 marcas
2. UUID preservado (se possível)
3. tenant_id injetado: `550e8400-e29b-41d4-a716-446655440000`
4. Campos mapeados corretamente

---

## 🔍 SEÇÃO 5: VALIDAÇÃO

## 🔍 SEÇÃO 4: VALIDAÇÃO

### **Pré-requisitos no BestLens**

```sql
-- 1. Verificar se tenant existe
SELECT id, nome, slug 
FROM meta_system.tenants 
WHERE id = '550e8400-e29b-41d4-a716-446655440000'::uuid;

-- ✅ RESULTADO:
-- | id                                   | nome              | slug              |
-- | ------------------------------------ | ----------------- | ----------------- |
-- | 550e8400-e29b-41d4-a716-446655440000 | Óticas Taty Mello | oticas-taty-mello |
```

### **Após Criação**

```sql
-- 1. Conferir contagem
SELECT COUNT(*) as total FROM suppliers.marcas;
-- Esperado: 14

-- ✅ RESULTADO:
-- | total |
-- | ----- |
-- | 14    |
-- ✅ 14 marcas criadas com sucesso!

-- 2. Ver marcas criadas (ordenadas por país e nome)
SELECT 
    nome,
    descricao,
    pais_origem,
    site_oficial,
    ativo
FROM suppliers.marcas
WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid
ORDER BY 
    CASE 
        WHEN pais_origem = 'Brasil' THEN 2
        ELSE 1
    END,
    nome;

-- ✅ RESULTADO:
-- | nome                 | descricao                                        | pais_origem    | site_oficial                   | ativo |
-- | -------------------- | ------------------------------------------------ | -------------- | ------------------------------ | ----- |
-- | Crizal               | Tratamentos antirreflexo premium (marca Essilor) | França         | https://www.crizal.com.br      | true  |
-- | Essilor              | Líder mundial em lentes oftálmicas               | França         | https://www.essilor.com.br     | true  |
-- | Hoya                 | Tecnologia japonesa em lentes oftálmicas         | Japão          | https://www.hoyavision.com.br  | true  |
-- | Transitions          | Lentes fotossensíveis que escurecem ao sol       | Estados Unidos | https://www.transitions.com    | true  |
-- | Varilux              | Lentes progressivas premium (marca Essilor)      | França         | https://www.varilux.com.br     | true  |
-- | Zeiss                | Óptica de precisão alemã                         | Alemanha       | https://www.zeiss.com.br       | true  |
-- | Brascor              | Laboratório brasileiro distribuidora de lentes   | Brasil         | null                           | true  |
-- | Braslentes           | Champ Brasil - Laboratório de lentes             | Brasil         | null                           | true  |
-- | Express              | Lentes e Cia Express - Laboratório brasileiro    | Brasil         | null                           | true  |
-- | Polylux              | Laboratório de produtos ópticos                  | Brasil         | null                           | true  |
-- | Sao Paulo Acessorios | Fornecedor de produtos INFINITY                  | Brasil         | null                           | true  |
-- | So Blocos            | Comércio e serviços ópticos                      | Brasil         | null                           | true  |
-- | Style                | Style Primer - Lentes oftálmicas                 | Brasil         | null                           | true  |
-- | Sygma                | Sygma Lentes - Laboratório Óptico                | Brasil         | https://www.sygmalentes.com.br | true  |
-- ⚠️ Nota: Removidas 3 marcas que eram de armações, não lentes (Galeria Florencio, Kaizi, Navarro)

-- 3. Conferir tenant_id
SELECT 
    COUNT(*) as total,
    COUNT(DISTINCT tenant_id) as tenants_unicos
FROM suppliers.marcas;

-- ✅ RESULTADO:
-- | total | tenants_unicos |
-- | ----- | -------------- |
-- | 14    | 1              |
-- ✅ Todos os registros têm tenant_id correto!

-- Esperado: total=14, tenants_unicos=1

-- 4. Verificar por país de origem
SELECT 
    pais_origem,
    COUNT(*) as qtd_marcas
FROM suppliers.marcas
WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid
GROUP BY pais_origem
ORDER BY qtd_marcas DESC;

-- ✅ RESULTADO:
-- | pais_origem    | qtd_marcas |
-- | -------------- | ---------- |
-- | Brasil         | 8          |
-- | França         | 3          |
-- | Alemanha       | 1          |
-- | Estados Unidos | 1          |
-- | Japão          | 1          |
-- ✅ Distribuição correta: 8 BR + 6 internacionais = 14 total

-- Esperado original: Brasil: 11, França: 3, EUA: 1, Alemanha: 1, Japão: 1
-- Ajustado: Brasil: 8 (removeu 3 de armações)

-- 5. Verificar marcas premium internacionais
SELECT nome, pais_origem, site_oficial
FROM suppliers.marcas
WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid
  AND pais_origem != 'Brasil'
ORDER BY nome;

-- ✅ RESULTADO:
-- | nome        | pais_origem    | site_oficial                  |
-- | ----------- | -------------- | ----------------------------- |
-- | Crizal      | França         | https://www.crizal.com.br     |
-- | Essilor     | França         | https://www.essilor.com.br    |
-- | Hoya        | Japão          | https://www.hoyavision.com.br |
-- | Transitions | Estados Unidos | https://www.transitions.com   |
-- | Varilux     | França         | https://www.varilux.com.br    |
-- | Zeiss       | Alemanha       | https://www.zeiss.com.br      |
-- ✅ 6 marcas premium internacionais perfeitas!

-- Esperado: 6 marcas (Essilor, Varilux, Crizal, Transitions, Zeiss, Hoya)

-- 6. Verificar constraint única (não deve ter duplicatas)
SELECT nome, COUNT(*) as qtd
FROM suppliers.marcas 
WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid
GROUP BY nome 
HAVING COUNT(*) > 1;
-- Esperado: nenhuma linha (sem duplicatas)

-- ✅ RESULTADO: Nenhuma linha retornada
-- ✅ Zero duplicatas! Constraint funcionando perfeitamente!
```

### **✅ VALIDAÇÃO CONCLUÍDA COM SUCESSO!**

**Resumo dos Resultados**:
- ✅ 14/14 marcas criadas (ajustado de 17)
- ✅ 6 marcas internacionais premium
- ✅ 8 marcas brasileiras de lentes
- ✅ tenant_id correto em todas
- ✅ Zero duplicatas
- ✅ Campos obrigatórios preenchidos
- ✅ **Ótima decisão**: Removidas 3 marcas de armações (Galeria Florencio, Kaizi, Navarro)

---

## ✅ CHECKLIST DE MIGRAÇÃO

### **Antes de Começar**
- [x] Banco BestLens criado ✅
- [x] Tenant criado ✅
- [x] Schema `suppliers` existe ✅
- [x] Tabela `marcas` criada ✅
- [x] SQL de criação preparado ✅

### **Criação**
- [ ] SQL executado no BestLens
- [ ] COMMIT bem-sucedido
- [ ] 17 registros criados

### **Validação**
- [ ] Contagem confere (17)
- [ ] tenant_id correto em todos
- [ ] Sem duplicatas
- [ ] 6 marcas internacionais
- [ ] 11 marcas brasileiras
- [ ] Campos obrigatórios preenchidos

---

## 🚨 TROUBLESHOOTING

### **Erro: Foreign Key violada (tenant_id)**
```sql
-- Verificar se tenant existe
SELECT * FROM meta_system.tenants 
WHERE id = '550e8400-e29b-41d4-a716-446655440000'::uuid;
```

### **Erro: Duplicate key (nome)**
```sql
-- Verificar marcas duplicadas
SELECT nome, COUNT(*) 
FROM produtos.marcas 
GROUP BY nome 
HAVING COUNT(*) > 1;

-- Limpar tabela se necessário (CUIDADO!)
TRUNCATE suppliers.marcas CASCADE;
```

---

## 📝 OBSERVAÇÕES

### **Decisões Tomadas**
1. ✅ **Não migrar** do Mello (marcas de armações, não lentes)
2. ✅ **Criar marcas** baseadas em laboratórios migrados
3. ✅ **Adicionar marcas premium** internacionais conhecidas
4. ✅ tenant_id fixo para todas: `550e8400-e29b-41d4-a716-446655440000`
5. ✅ UUIDs gerados automaticamente (não há origem para preservar)

### **Categorias de Marcas**

#### **🌍 Marcas Internacionais Premium (6)**
- **Essilor** (França) - Líder mundial
- **Varilux** (França) - Progressivas
- **Crizal** (França) - Tratamentos
- **Transitions** (USA) - Fotossensíveis
- **Zeiss** (Alemanha) - Óptica de precisão
- **Hoya** (Japão) - Tecnologia japonesa

#### **🇧🇷 Marcas/Laboratórios Brasileiros (11)**
- Brascor, Braslentes, Express
- Polylux, Sygma
- Galeria Florencio, Kaizi, Navarro
- Sao Paulo Acessorios, So Blocos, Style

### **Uso Futuro**
Estas marcas serão referenciadas em:
- ✅ `suppliers.produtos_laboratorio` (FK: marca_id)
- ✅ Filtros no frontend por marca
- ✅ Relatórios de vendas por marca
- ✅ Comparações de preços entre marcas

---

## 📊 RESUMO DA MIGRAÇÃO

| Item | Origem | Destino | Status |
|------|--------|---------|--------|
| **Registros** | N/A (criação manual) | 17 | ⏳ Pronto |
| **Marcas Internacionais** | - | 6 | ✓ Definidas |
| **Marcas Brasileiras** | - | 11 | ✓ Definidas |
| **Campos Preenchidos** | - | 7 | ✓ Mapeados |
| **Validações** | - | 6 queries | ✓ Preparadas |

### **📈 Distribuição**
- 🌍 Internacionais: 35% (6 marcas)
- 🇧🇷 Brasileiras: 65% (11 marcas)
- **Total**: 100% (17 marcas)

---

## 🎯 EXECUTE AGORA

**Copie o SQL da SEÇÃO 3** e execute no Supabase BestLens!

Após execução:
1. ✅ Cole os resultados das validações
2. ✅ Confirme 17 marcas criadas
3. ✅ Partiremos para **Migração 03: Lentes Canônicas** (265 registros)

---

**Status**: ✅ SQL PRONTO - Aguardando execução  
**Última atualização**: 06/10/2025 - 19:00 BRT
