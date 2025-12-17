# 📋 RESUMO EXECUTIVO - Migração de Lentes

## 🎯 Objetivo Geral
Implementar a **arquitetura definitiva** com separação clara entre:
- **Lentes Genéricas** (laboratórios) → Competem por preço/prazo
- **Lentes Premium** (marcas valorizadas) → Competem por qualidade/tecnologia

## 📊 Status Atual

### ✅ Passos Implementados (Prontos para Executar)

| Passo | Arquivo | Status | O que faz |
|-------|---------|--------|-----------|
| **1** | `PASSO_1_CRIAR_ESTRUTURA.sql` | ✅ Pronto | Cria premium_canonicas + colunas em lentes + triggers |
| **2** | `PASSO_2_MIGRAR_DADOS.sql` | ✅ Pronto | Migra 515 lentes com dados de lab |
| **3** | `PASSO_3_CORRIGIR_LENTES_ORFAS.sql` | ⚠️ Decisão | Resolver 896 lentes sem laboratório |
| **4** | `PASSO_4_CRIAR_MOTOR_BUSCA.sql` | ✅ Pronto | Cria view v_motor_lentes + fn_buscar_lentes |
| **5** | `PASSO_5_CRIAR_PUBLIC_VIEWS.sql` | ✅ Pronto | 7 views públicas para frontend |
| **6** | `PASSO_6_SEPARAR_CANONICAS_PREMIUM.sql` | ✅ **NOVO** | **Separa canônicas de premium** |

### 🔴 Próximos Passos (A Criar)

| Passo | Arquivo | Quando | O que fará |
|-------|---------|--------|------------|
| **7** | `PASSO_7_MIGRAR_LENTES_CANONICAS.sql` | Após 6 | Migrar 265 SKUs do catálogo_mello para lentes_canonicas_labs |
| **8** | `PASSO_8_MIGRAR_PRODUTOS_LABORATORIO.sql` | Após 7 | Mapear 1.411 produtos → FK correto (canônica OU premium) |
| **9** | `PASSO_9_POVOAR_NIVEIS_LINHAS.sql` | Após 8 | Script auxiliar para preencher níveis/linhas manualmente |
| **10** | `PASSO_10_VALIDACAO_FINAL.sql` | Final | Verificar integridade completa |

---

## 🏗️ Arquitetura Final

```
┌─────────────────────────────────────────────────────────┐
│                  FRONTEND (public.vw_todas_lentes)      │
│  Une ambos mundos em uma única view para consumo       │
└──────────────┬─────────────────────────┬────────────────┘
               │                         │
    ┌──────────▼───────────┐  ┌─────────▼──────────────┐
    │ Lentes Canônicas     │  │ Lentes Premium         │
    │ (Laboratórios)       │  │ (Marcas Valorizadas)   │
    │                      │  │                        │
    │ • LVN000001          │  │ • ESS-VLX-167          │
    │ • Linha: Standard    │  │ • Marca: Essilor       │
    │ • Nível: 1-5         │  │ • Linha: Varilux X     │
    │ • Sem marca          │  │ • Nível: 4-5           │
    └──────────┬───────────┘  └─────────┬──────────────┘
               │                        │
               └────────┬───────────────┘
                        │
          ┌─────────────▼─────────────────┐
          │  produtos_laboratorio         │
          │  (FK polimórfico)             │
          │                               │
          │  • lente_canonica_lab_id OU   │
          │  • lente_premium_marca_id     │
          │                               │
          │  Regra: UMA e APENAS UMA FK   │
          └───────────────────────────────┘
```

---

## 🔑 Decisões Implementadas no PASSO 6

### 1. ✅ Duas Tabelas Separadas
- `lentes_canonicas_labs` → Genéricas (265 base → ~400 com expansão)
- `lentes_premium_marcas` → Premium (21 Essilor + outras)

### 2. ✅ Diferenciação de Fotocromático
- Campo: `tipo_fotossensivel`
- Valores: `TRANSITIONS`, `SENSITY`, `XTRACTIVE`, `SUNSYNC`, `GENERICO`
- Permite comparar "Transitions" vs "fotocromático genérico"

### 3. ✅ Níveis de Qualidade
- 1 = Entrada básica
- 2 = Entrada com qualidade
- 3 = Intermediária (Prodige, Premium)
- 4 = Alta (Prestige, Top)
- 5 = Luxo (importadas, especiais)
- **Povoamento manual** após migração

### 4. ✅ Linhas de Produto
- Campo: `linha_produto`
- Exemplos: "Standard", "Prodige Extra", "Prestige"
- **Povoamento manual** após migração
- Permite comparar linhas equivalentes entre labs

### 5. ✅ Prazos Detalhados
- Campos: `tipo_lente_prazo` + `categoria_prazo`
- Permite prazos específicos por tipo (MONOFOCAL/PROGRESSIVA)
- E por categoria (ACABADA/SURFACADA)
- NULL = prazo genérico

### 6. ✅ View Unificada
- `public.vw_todas_lentes`
- Une canônicas + premium
- Frontend consome ÚNICA view
- Campo `tipo_lente_sistema` diferencia origem

---

## 🚀 Como Executar (Ordem Correta)

### Preparação
```sql
-- 1. BACKUP COMPLETO
pg_dump seu_banco > backup_antes_migracao.sql

-- 2. Confirmar tenant_id
SELECT id, nome FROM meta_system.tenants;
-- Copiar UUID para usar nas queries
```

### Execução em Ordem

```bash
# 1. Criar estrutura base
psql -f PASSO_1_CRIAR_ESTRUTURA.sql

# 2. Migrar dados existentes
psql -f PASSO_2_MIGRAR_DADOS.sql

# 3. Decidir sobre lentes órfãs (ATENÇÃO!)
#    Opção A: Importar CSV completo
#    Opção B: Remover órfãs
psql -f PASSO_3_CORRIGIR_LENTES_ORFAS.sql

# 4. Criar motor de busca
psql -f PASSO_4_CRIAR_MOTOR_BUSCA.sql

# 5. Criar views públicas
psql -f PASSO_5_CRIAR_PUBLIC_VIEWS.sql

# 6. Separar canônicas de premium (NOVO!)
psql -f PASSO_6_SEPARAR_CANONICAS_PREMIUM.sql

# 7. TODO: Migrar lentes canônicas
# psql -f PASSO_7_MIGRAR_LENTES_CANONICAS.sql

# 8. TODO: Mapear produtos_laboratorio
# psql -f PASSO_8_MIGRAR_PRODUTOS_LABORATORIO.sql
```

### Verificação Após Cada Passo

```sql
-- Ver mensagens de sucesso (RAISE NOTICE)
-- Cada script mostra resumo ao final

-- Verificar estrutura criada
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'lens_catalog' 
  AND table_name LIKE '%canonica%';

-- Ver view unificada
SELECT * FROM public.vw_todas_lentes LIMIT 5;
```

---

## ⚠️ Atenções Críticas

### 1. PASSO 3 - Decisão Obrigatória
- **896 lentes órfãs** detectadas
- Precisa decidir ANTES de continuar:
  - Importar CSV completo? OU
  - Remover lentes sem laboratório?

### 2. Níveis e Linhas
- Campos criados mas **NULL inicialmente**
- Povoar DEPOIS da migração
- Use interface ou script manual

### 3. FK Polimórfico
- `produtos_laboratorio` DEVE ter:
  - `lente_canonica_lab_id` OU
  - `lente_premium_marca_id`
- **NUNCA ambos** (constraint garante)

### 4. View Unificada
- Frontend SEMPRE consome `vw_todas_lentes`
- Não acessar tabelas internas diretamente
- Campo `tipo_lente_sistema` indica origem

---

## 📈 Resultado Esperado

### Antes
```
❌ 1 tabela misturando tudo (lentes)
❌ Sem diferenciação premium
❌ Sem agrupamento por linha
❌ Sem comparação de níveis
```

### Depois
```
✅ Canônicas separadas de premium
✅ Agrupamento por linha/nível
✅ Comparação inteligente cross-lab
✅ Diferenciação de fotocromático
✅ View unificada para frontend
✅ FK polimórfico garantido
```

---

## 🔧 Troubleshooting

### Erro: "operator does not exist: text = tipo_lente"
→ Execute `CORRECAO_TRIGGERS_ENUM.sql`

### Erro: "column already exists"
→ Normal, script tem proteção `IF NOT EXISTS`

### Erro: "constraint violated"
→ Verificar se produto tem AMBAS FKs (canônica E premium)
→ Deve ter apenas UMA

### View vazia
→ Verificar se `ativo = true` nas tabelas
→ Verificar se migração rodou

---

## 📞 Próximos Passos

1. **Executar Passos 1-6** na ordem
2. **Decidir sobre órfãs** (Passo 3)
3. **Aguardar criação** dos Passos 7-10
4. **Popular níveis/linhas** manualmente
5. **Testar view unificada** no frontend

---

**Última Atualização:** 17/12/2025  
**Responsável:** Migração para Arquitetura Definitiva
