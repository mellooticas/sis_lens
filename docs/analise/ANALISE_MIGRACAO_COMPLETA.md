# 📊 ANÁLISE COMPLETA - MIGRAÇÃO MELLO → BESTLENS

> **Documento de trabalho**: Mapeamento detalhado da estrutura atual vs nova, decisões de arquitetura e estratégia de migração.

---

## 🎯 DECISÕES FUNDAMENTAIS

### ✅ Confirmações Principais

1. **Sistema Destino**: SEMPRE SIS Lens (novo projeto Supabase)
2. **Sistema Origem**: Mello (apenas leitura para migração)
3. **Estratégia de Lentes**: Duas tabelas separadas
   - `lens_catalog.lentes_canonicas` (laboratórios genéricos)
   - `lens_catalog.lentes_premium` (Essilor, Zeiss, Hoya)
4. **View Unificada**: `public.vw_todas_lentes` (frontend consome aqui)
5. **Tratamentos**: Boolean simplificado (tem/não tem)
6. **Fotocromático**: Campo diferenciado (`TRANSITIONS` vs `ACCLIMATES` vs `GENERICO`)

---

## 📋 INVENTÁRIO DO SISTEMA ATUAL (MELLO)

### 1. FORNECEDORES
**Tabela**: `pessoas.fornecedores`  
**Quantidade**: 11 registros

#### Campos Existentes
```
✓ id (UUID)
✓ nome
✓ razao_social
✓ cnpj
✓ email, telefone, contato
✓ representante, contato_representante
✓ whatsapp_atendimento, whatsapp_financeiro, whatsapp_comercial
✓ site, cep, endereco, pessoa_contato
✓ codigo_cliente
✓ condicoes_pagamento
✓ prazo_entrega_dias (maioria = 7)
✓ ativo
✓ created_at
```

#### Fornecedores Ativos
1. Brascor (Brascor Distribuidora de Lentes)
2. Polylux (Polylux Comercio de Produtos Opticos LTDA)
3. Sygma (Sygma Lentes Laboratório Óptico)
4. So Blocos (Só blocos Comercio e Serviços Oticos LTDA)
5. Kaizi (Kaizi Importação e Exportação LTDA)
6. Express
7. ... (11 total)

---

### 2. CATÁLOGO DE LENTES (PRODUTOS POR FORNECEDOR)
**Tabela**: `lente.fornecedores_lentes`  
**Quantidade**: 1.411 registros

#### Estrutura Completa
```
Identificação:
├─ id (UUID)
├─ fornecedor_id (FK → pessoas.fornecedores)
├─ codigo_fornecedor
├─ sku_geral (9 chars, ex: "MLT3V0QZ2")
├─ sku (texto, ex: "LVN000001")
├─ nome_lente
└─ marca_lente (SOBLOCOS, ESSILOR, POLYLUX, etc.)

Características técnicas:
├─ tipo_lente (VISAO SIMPLES | MULTIFOCAL | FREE FORM | BIFOCAL)
├─ material (CR-39, POLICARBONATO, etc.)
├─ indice_refracao (1.49, 1.56, 1.67, etc.)
├─ categoria (ACABADA | SURFACADA)
└─ classificacao_fiscal

Tratamentos (booleans):
├─ ar (anti-reflexo)
├─ blue (blue light)
├─ fotossensivel
├─ polarizado
└─ tintavel

Tratamentos (texto):
├─ tratamento_foto
└─ tratamentos (agregado)

Especificações óticas:
├─ esferico_min / esferico_max
├─ cilindrico_min / cilindrico_max
├─ adicao_min / adicao_max
├─ altura_min / altura_max
├─ diametro1 / diametro2
└─ pode_grau (boolean)

Precificação:
├─ preco_custo
├─ preco_venda_calculado
├─ markup_estimado
├─ frete_estimado
└─ faixa (1-5)

Metadata:
├─ status ('ATIVO')
└─ created_at
```

#### Distribuição por Marca
```
SOBLOCOS:  1.097 produtos (77.7%) - R$ 202-1.947
POLYLUX:     137 produtos -         R$ 107-729
EXPRESS:      84 produtos -         R$ 77-1.200
BRASCOR:      58 produtos -         R$ 70-343
ESSILOR:      21 produtos -         R$ 82-1.560 ⭐ PREMIUM
SYGMA:        14 produtos -         R$ 29-62
```

#### Tipos de Lente
```
FREE FORM:     733 (52%)
  ├─ Progressivas: 633 (86%) - R$ 100-2.410
  └─ Monofocais:   100 (14%) - R$ 450-2.370

VISAO SIMPLES: 452 (32%)
MULTIFOCAL:    224 (16%)
BIFOCAL:         2 (<1%)
```

---

### 3. CATÁLOGO NORMALIZADO
**Tabela**: `lente.catalogo_mello_lentes`  
**Quantidade**: 265 registros (redução de 1.411 → 265)

#### Lógica de Agrupamento
Agrupa por:
- tipo_lente
- material
- indice_refracao
- categoria
- ar, blue, fotossensivel, polarizado, tintavel (booleans)

#### Campos Calculados
```
sku_normalizado         (VARCHAR, ex: "LVN000002")
nome_comercial          (humanizado)
marca_normalizada       ("GENERICA" sempre)
quantidade_lentes       (quantos produtos agrupados)
preco_minimo, preco_maximo, preco_medio
lente_representante_id  (FK → fornecedores_lentes)
lente_representante_sku_geral
```

**Regra do Representante**: SEMPRE o produto de MENOR PREÇO do grupo

---

### 4. FAIXAS DE CUSTO
**Tabela**: `lente.faixas_custo`  
**Quantidade**: 5 níveis

| ID | Nome | Range | Uso |
|----|------|-------|-----|
| 1 | Entrada | R$ 0-250 | Lentes básicas |
| 2 | Intermediária | R$ 251-600 | Mainstream |
| 3 | Premium | R$ 601-1.000 | Alta qualidade |
| 4 | Alto valor | R$ 1.001-1.500 | Técnicas |
| 5 | Luxo | R$ 1.501+ | Sob demanda |

---

### 5. PRAZOS DETALHADOS
**Tabela**: `pessoas.fornecedores_prazos_lentes`  
**Quantidade**: 5 registros (2 fornecedores)

#### Exemplo Real (Brascor)
```
Visão Simples Pronta:      3 dias
Visão Simples Surfaçada:   8 dias
Multifocal Pronta:         4 dias
Multifocal Surfaçada:     12 dias
```

#### Exemplo Real (Polylux)
```
Visão Simples Pronta:      2 dias
```

---

## 🆕 ESTRUTURA DO BESTLENS (NOVO SISTEMA)

### SCHEMAS
```sql
CREATE SCHEMA lens_catalog;   -- Catálogo de lentes
CREATE SCHEMA suppliers;      -- Fornecedores e produtos
CREATE SCHEMA commercial;     -- Preços e descontos
CREATE SCHEMA logistics;      -- Prazos e entregas
CREATE SCHEMA orders;         -- Decisões de compra
CREATE SCHEMA scoring;        -- Avaliações
CREATE SCHEMA meta_system;    -- Multi-tenancy
CREATE SCHEMA analytics;      -- Relatórios
```

---

### TABELA 1: lens_catalog.marcas
```sql
CREATE TABLE lens_catalog.marcas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id),
    nome TEXT NOT NULL,
    pais_origem TEXT,
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT uk_marca_tenant UNIQUE (nome, tenant_id)
);
```

#### Marcas a Criar
```
1. SOBLOCOS   - Brasil
2. POLYLUX    - Brasil
3. EXPRESS    - Brasil
4. BRASCOR    - Brasil
5. ESSILOR    - França  ⭐ PREMIUM
6. SYGMA      - Brasil
7. ZEISS      - Alemanha ⭐ PREMIUM (adicionar depois)
8. HOYA       - Japão ⭐ PREMIUM (adicionar depois)
```

---

### TABELA 2: lens_catalog.lentes_canonicas
**Propósito**: Lentes genéricas de laboratórios (sem marca específica)

```sql
CREATE TABLE lens_catalog.lentes_canonicas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id),
    
    -- Identificação
    sku_canonico VARCHAR(50) NOT NULL UNIQUE,  -- LVN000001
    nome_comercial TEXT NOT NULL,
    
    -- Linha e Nível (povoar DEPOIS manualmente)
    linha_produto TEXT,                        -- "Standard", "Prodige Extra", "Prestige"
    nivel_qualidade INTEGER CHECK (nivel_qualidade BETWEEN 1 AND 5),
    laboratorio_referencia_id UUID REFERENCES suppliers.laboratorios(id),
    
    -- Características técnicas
    tipo_lente TEXT NOT NULL,                  -- MONOFOCAL | PROGRESSIVA | BIFOCAL
    material TEXT NOT NULL,                    -- CR-39, POLICARBONATO, TRIVEX
    indice_refracao NUMERIC(3,2) NOT NULL,     -- 1.49, 1.56, 1.67
    categoria TEXT NOT NULL,                   -- ACABADA | SURFACADA
    
    -- Tratamentos (boolean simplificado)
    tem_ar BOOLEAN DEFAULT false,
    tem_blue BOOLEAN DEFAULT false,
    tem_hc BOOLEAN DEFAULT false,              -- Hardcoat/Antirrisco
    tem_polarizado BOOLEAN DEFAULT false,
    
    -- Fotocromático (DIFERENCIADO)
    tem_fotossensivel BOOLEAN DEFAULT false,
    tipo_fotossensivel TEXT,                   -- 'TRANSITIONS' | 'ACCLIMATES' | 'SENSITY' | 'GENERICO'
    
    tem_tintavel BOOLEAN DEFAULT false,
    
    -- Detalhes (texto livre)
    tratamentos_detalhes TEXT,                 -- "AR Verde", "Blue Fast"
    
    -- Especificações óticas (JSONB)
    specs_tecnicas JSONB,
    
    -- Metadata
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT uk_canonico_tenant UNIQUE (sku_canonico, tenant_id)
);

CREATE INDEX idx_canonicas_tipo_material ON lens_catalog.lentes_canonicas(tipo_lente, material, indice_refracao);
CREATE INDEX idx_canonicas_nivel ON lens_catalog.lentes_canonicas(nivel_qualidade) WHERE nivel_qualidade IS NOT NULL;
CREATE INDEX idx_canonicas_linha ON lens_catalog.lentes_canonicas(linha_produto) WHERE linha_produto IS NOT NULL;
```

#### specs_tecnicas (JSONB)
```json
{
  "categoria": "ACABADA",
  "classificacao_fiscal": "90015172",
  "pode_grau": true,
  "fabricacao": "FREE_FORM",
  "esferico_range": [-7.00, 6.00],
  "cilindrico_range": [-5.00, 0.00],
  "adicao_range": [0.75, 3.50],
  "diametros": ["70", "80"],
  "altura_range": [16, 18]
}
```

---

### TABELA 3: lens_catalog.lentes_premium
**Propósito**: Lentes de marcas valorizadas (Essilor, Zeiss, Hoya)

```sql
CREATE TABLE lens_catalog.lentes_premium (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id),
    
    -- Identificação
    sku_premium VARCHAR(50) NOT NULL UNIQUE,   -- ESS-VLX-167-AR
    marca_id UUID NOT NULL REFERENCES lens_catalog.marcas(id),
    
    -- Nome completo da linha premium
    linha_completa TEXT NOT NULL,              -- "Varilux X Series"
    nome_comercial TEXT NOT NULL,
    design TEXT,                               -- "X Series", "SmartLife"
    
    -- Nível sempre alto (4-5)
    nivel_qualidade INTEGER NOT NULL CHECK (nivel_qualidade BETWEEN 4 AND 5),
    
    -- Características técnicas (IDÊNTICAS às canônicas)
    tipo_lente TEXT NOT NULL,
    material TEXT NOT NULL,
    indice_refracao NUMERIC(3,2) NOT NULL,
    categoria TEXT NOT NULL,
    
    -- Tratamentos (MESMA estrutura)
    tem_ar BOOLEAN DEFAULT false,
    tem_blue BOOLEAN DEFAULT false,
    tem_hc BOOLEAN DEFAULT false,
    tem_polarizado BOOLEAN DEFAULT false,
    
    tem_fotossensivel BOOLEAN DEFAULT false,
    tipo_fotossensivel TEXT,
    
    tem_tintavel BOOLEAN DEFAULT false,
    tratamentos_detalhes TEXT,
    
    -- Especificações óticas
    specs_tecnicas JSONB,
    corredor_progressao INTEGER,               -- Para progressivas premium
    
    -- Metadata
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT uk_premium_tenant UNIQUE (sku_premium, tenant_id)
);

CREATE INDEX idx_premium_marca ON lens_catalog.lentes_premium(marca_id);
CREATE INDEX idx_premium_tipo_material ON lens_catalog.lentes_premium(tipo_lente, material, indice_refracao);
CREATE INDEX idx_premium_linha ON lens_catalog.lentes_premium(linha_completa);
```

#### Exemplo: ESSILOR no Sistema Atual

**3 Linhas Identificadas:**
1. **ESPACE** (Básica) - Nível 3
   - Incolor: R$ 82-197
   - Acclimates: R$ 250-390
   - Transitions: R$ 455-637

2. **VARILUX LIBERTY** (Intermediária) - Nível 4
   - Incolor: R$ 507-720
   - Transitions: R$ 1.209-1.365

3. **VARILUX CONFORT** (Premium) - Nível 5
   - Incolor: R$ 770-1.015
   - Transitions: R$ 1.430-1.560

**Total Essilor**: 21 produtos

---

### TABELA 4: suppliers.laboratorios
```sql
CREATE TABLE suppliers.laboratorios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id),
    
    -- Identificação
    nome_fantasia TEXT NOT NULL,
    razao_social TEXT,
    cnpj TEXT,
    
    -- Contato (JSONB agregado)
    contato_comercial JSONB DEFAULT '{}'::jsonb,
    
    -- Logística
    lead_time_padrao_dias INTEGER DEFAULT 7,
    atende_regioes TEXT[] DEFAULT ARRAY['SUDESTE'],
    
    -- Status
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT uk_lab_tenant UNIQUE (tenant_id, nome_fantasia)
);

CREATE INDEX idx_lab_tenant ON suppliers.laboratorios(tenant_id);
CREATE INDEX idx_lab_ativo ON suppliers.laboratorios(ativo) WHERE ativo = true;
```

#### contato_comercial (JSONB)
```json
{
  "email": "vendas@brascorlab.com.br",
  "telefone": "(11) 93047-3110",
  "contato_principal": "Shirley",
  "pessoa_contato": "Shirley",
  "representante": {
    "nome": "Shirley",
    "contato": "+55 11 91421-1122"
  },
  "whatsapp": {
    "atendimento": "(11) 93768-9139",
    "financeiro": "(11) 9657-9404",
    "comercial": "(11) 97657-4040"
  },
  "site": "https://www.brascorlab.com.br",
  "observacoes": "aceita pedidos por email"
}
```

---

### TABELA 5: suppliers.produtos_laboratorio
**Propósito**: Produtos específicos de cada laboratório (conecta labs com lentes)

```sql
CREATE TABLE suppliers.produtos_laboratorio (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id),
    laboratorio_id UUID NOT NULL REFERENCES suppliers.laboratorios(id),
    
    -- FK polimórfico (OU canônica OU premium)
    lente_canonica_id UUID REFERENCES lens_catalog.lentes_canonicas(id),
    lente_premium_id UUID REFERENCES lens_catalog.lentes_premium(id),
    
    -- CHECK: deve ter UMA e APENAS UMA
    CONSTRAINT chk_tipo_lente CHECK (
        (lente_canonica_id IS NOT NULL AND lente_premium_id IS NULL) OR
        (lente_canonica_id IS NULL AND lente_premium_id IS NOT NULL)
    ),
    
    -- Códigos do laboratório
    sku_laboratorio TEXT NOT NULL,             -- Código nativo do lab
    nome_comercial TEXT NOT NULL,
    sku_fantasia VARCHAR(50),                  -- Nosso código comercial
    
    -- Qualidade e disponibilidade
    qualidade_base INTEGER CHECK (qualidade_base BETWEEN 1 AND 5),
    disponivel BOOLEAN DEFAULT true,
    descontinuado_em TIMESTAMPTZ,
    
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT uk_produto_lab UNIQUE (laboratorio_id, sku_laboratorio, tenant_id)
);

CREATE INDEX idx_produto_canonica ON suppliers.produtos_laboratorio(lente_canonica_id);
CREATE INDEX idx_produto_premium ON suppliers.produtos_laboratorio(lente_premium_id);
```

**Mapeamento de Qualidade (baseado em preço):**
```
R$ 0-250:       qualidade_base = 2
R$ 251-600:     qualidade_base = 3
R$ 601-1.000:   qualidade_base = 4
R$ 1.000+:      qualidade_base = 5
```

---

### TABELA 6: commercial.precos_base
```sql
CREATE TABLE commercial.precos_base (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id),
    produto_lab_id UUID NOT NULL REFERENCES suppliers.produtos_laboratorio(id),
    
    -- Preços
    moeda VARCHAR(3) DEFAULT 'BRL',
    preco_custo NUMERIC(10,2) NOT NULL,
    preco_tabela NUMERIC(10,2) NOT NULL,
    
    -- Vigência
    vigencia_inicio DATE DEFAULT CURRENT_DATE,
    vigencia_fim DATE,
    
    -- Referência
    tabela_referencia TEXT DEFAULT 'MELLO_2025',
    
    CONSTRAINT uk_preco_vigencia UNIQUE (produto_lab_id, vigencia_inicio, tenant_id)
);

CREATE INDEX idx_preco_produto ON commercial.precos_base(produto_lab_id);
CREATE INDEX idx_preco_vigente ON commercial.precos_base(vigencia_inicio, vigencia_fim) 
  WHERE vigencia_fim IS NULL OR vigencia_fim > CURRENT_DATE;
```

**Cálculo de preco_tabela**:  
`preco_tabela = preco_custo * 2.5` (se não existir preco_venda_calculado)

---

### TABELA 7: logistics.tabela_prazos
```sql
CREATE TABLE logistics.tabela_prazos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES meta_system.tenants(id),
    laboratorio_id UUID NOT NULL REFERENCES suppliers.laboratorios(id),
    
    -- Detalhamento por tipo de lente (NOVO)
    tipo_lente TEXT,                           -- 'MONOFOCAL' | 'PROGRESSIVA' | NULL (genérico)
    categoria TEXT,                            -- 'ACABADA' | 'SURFACADA' | NULL (genérico)
    
    -- Geografia
    regiao_origem TEXT,
    regiao_destino TEXT NOT NULL DEFAULT 'SUDESTE',
    
    -- Prazos
    prazo_minimo INTEGER NOT NULL,             -- Dias úteis
    prazo_maximo INTEGER NOT NULL,
    prazo_medio INTEGER GENERATED ALWAYS AS ((prazo_minimo + prazo_maximo) / 2) STORED,
    
    -- Frete
    custo_frete NUMERIC(10,2) DEFAULT 0,
    frete_gratis_acima NUMERIC(10,2),
    
    -- Vigência
    vigencia_inicio DATE DEFAULT CURRENT_DATE,
    vigencia_fim DATE,
    ativo BOOLEAN DEFAULT true,
    
    CONSTRAINT uk_prazo UNIQUE (laboratorio_id, tipo_lente, categoria, regiao_destino, vigencia_inicio, tenant_id)
);

CREATE INDEX idx_prazo_lab_tipo ON logistics.tabela_prazos(laboratorio_id, tipo_lente, categoria) WHERE ativo = true;
```

---

### VIEW: public.vw_todas_lentes
**Propósito**: Unifica canônicas + premium para consumo do frontend

```sql
CREATE VIEW public.vw_todas_lentes AS
-- Lentes Canônicas
SELECT 
    'CANONICA' as tipo_lente_sistema,
    c.id,
    c.sku_canonico as sku_exibicao,
    c.nome_comercial,
    'Linha ' || COALESCE(c.linha_produto, 'Standard') as marca_exibicao,
    c.linha_produto,
    c.nivel_qualidade,
    c.tipo_lente,
    c.material,
    c.indice_refracao,
    c.categoria,
    c.tem_ar,
    c.tem_blue,
    c.tem_hc,
    c.tem_polarizado,
    c.tem_fotossensivel,
    c.tipo_fotossensivel,
    c.tem_tintavel,
    c.tratamentos_detalhes,
    c.specs_tecnicas,
    c.ativo,
    NULL::INTEGER as corredor_progressao,
    c.laboratorio_referencia_id
FROM lens_catalog.lentes_canonicas c
WHERE c.ativo = true

UNION ALL

-- Lentes Premium
SELECT 
    'PREMIUM' as tipo_lente_sistema,
    p.id,
    p.sku_premium as sku_exibicao,
    p.nome_comercial,
    m.nome as marca_exibicao,
    p.linha_completa as linha_produto,
    p.nivel_qualidade,
    p.tipo_lente,
    p.material,
    p.indice_refracao,
    p.categoria,
    p.tem_ar,
    p.tem_blue,
    p.tem_hc,
    p.tem_polarizado,
    p.tem_fotossensivel,
    p.tipo_fotossensivel,
    p.tem_tintavel,
    p.tratamentos_detalhes,
    p.specs_tecnicas,
    p.ativo,
    p.corredor_progressao,
    NULL::UUID as laboratorio_referencia_id
FROM lens_catalog.lentes_premium p
JOIN lens_catalog.marcas m ON p.marca_id = m.id
WHERE p.ativo = true;
```

---

## 🔄 MAPEAMENTO: MELLO → BESTLENS

### MAPEAMENTO 1: Fornecedores
| Campo Mello | Campo SIS Lens | Ação |
|-------------|----------------|------|
| `id` | `id` | ✓ Preservar UUID |
| `nome` | `nome_fantasia` | ✓ Renomear |
| `razao_social` | `razao_social` | ✓ 1:1 |
| `cnpj` | `cnpj` | ✓ 1:1 |
| `email`, `telefone`, etc. | `contato_comercial` (JSONB) | 🟡 Agregar |
| `prazo_entrega_dias` | `lead_time_padrao_dias` | ✓ Renomear |
| `ativo` | `ativo` | ✓ 1:1 |
| `created_at` | `criado_em` | ✓ Renomear |
| ❌ | `tenant_id` | 🔴 Criar (default) |
| ❌ | `atende_regioes` | 🔴 Criar (['SUDESTE']) |

---

### MAPEAMENTO 2: Marcas
| Origem | Destino | País |
|--------|---------|------|
| `ESSILOR` (distintar) | `marcas.nome = 'ESSILOR'` | França |
| `ZEISS` (adicionar) | `marcas.nome = 'ZEISS'` | Alemanha |
| `HOYA` (adicionar) | `marcas.nome = 'HOYA'` | Japão |
| `SOBLOCOS` (distintar) | ❌ Não criar (lab genérico) | Brasil |
| `POLYLUX` (distintar) | ❌ Não criar (lab genérico) | Brasil |
| `BRASCOR` (distintar) | ❌ Não criar (lab genérico) | Brasil |

---

### MAPEAMENTO 3: Lentes Canônicas
| Campo Mello | Campo SIS Lens | Transformação |
|-------------|----------------|---------------|
| `sku_normalizado` | `sku_canonico` | ✓ 1:1 |
| `nome_comercial` | `nome_comercial` | ✓ 1:1 |
| `tipo_lente` | `tipo_lente` | 🟡 Mapear FREE FORM |
| `material` | `material` | ✓ 1:1 |
| `indice_refracao` (text) | `indice_refracao` (numeric) | 🟡 Cast |
| `ar`, `blue`, etc. (5 booleans) | `tem_ar`, `tem_blue`, etc. | ✓ Renomear |
| `fotossensivel` + `tratamento_foto` | `tem_fotossensivel` + `tipo_fotossensivel` | 🟡 Parse TRANSITIONS/ACCLIMATES |
| `lente_representante_id` → specs | `specs_tecnicas` (JSONB) | 🟡 Buscar e agregar |
| ❌ | `linha_produto` | 🔴 NULL (povoar depois) |
| ❌ | `nivel_qualidade` | 🔴 NULL (povoar depois) |

**Lógica de Mapeamento FREE FORM:**
```sql
CASE 
  WHEN tipo_lente = 'FREE FORM' AND adicao_max > 0 THEN 'PROGRESSIVA'
  WHEN tipo_lente = 'FREE FORM' AND adicao_max = 0 THEN 'MONOFOCAL'
  WHEN tipo_lente = 'MULTIFOCAL' THEN 'PROGRESSIVA'
  WHEN tipo_lente = 'VISAO SIMPLES' THEN 'MONOFOCAL'
  WHEN tipo_lente = 'BIFOCAL' THEN 'BIFOCAL'
END
```

**Lógica de Fotocromático:**
```sql
CASE 
  WHEN tratamentos ILIKE '%transitions%' THEN 'TRANSITIONS'
  WHEN tratamentos ILIKE '%acclimates%' THEN 'ACCLIMATES'
  WHEN tratamentos ILIKE '%sensity%' THEN 'SENSITY'
  WHEN fotossensivel THEN 'GENERICO'
  ELSE NULL
END
```

---

### MAPEAMENTO 4: Lentes Premium (Essilor)
| Campo Mello | Campo SIS Lens | Transformação |
|-------------|----------------|---------------|
| `id` | `id` | ✓ Preservar UUID |
| `marca_lente = 'ESSILOR'` | `marca_id` (FK) | 🟡 Buscar Essilor |
| `nome_lente` | Parse para `linha_completa` + `nome_comercial` | 🟡 Regex |
| `nome_lente` | Parse para `design` | 🟡 Regex |
| Inferir por preço | `nivel_qualidade` | 🟡 Mapear |
| `tipo_lente` | Sempre 'PROGRESSIVA' (Varilux) ou 'MONOFOCAL' (Espace) | 🟡 Parse |
| `material`, `indice_refracao`, etc. | Mesmos campos | ✓ 1:1 |

**Exemplo de Parse:**
```
nome_lente: "VARILUX CONFORT CR TRANSITIONS"
  ↓
linha_completa: "Varilux Confort"
design: "Confort"
nome_comercial: "Varilux Confort CR Transitions"
nivel_qualidade: 5
tipo_fotossensivel: "TRANSITIONS"
```

---

### MAPEAMENTO 5: Produtos Laboratório
| Campo Mello | Campo SIS Lens | Complexidade |
|-------------|----------------|--------------|
| `id` | `id` | ✓ Preservar |
| `fornecedor_id` | `laboratorio_id` | ✓ Renomear |
| `codigo_fornecedor` | `sku_laboratorio` | ✓ Renomear |
| `nome_lente` | `nome_comercial` | ✓ 1:1 |
| `sku_geral` | `sku_fantasia` | ✓ Renomear |
| JOIN complexo | `lente_canonica_id` OU `lente_premium_id` | 🔴 ALTA |
| `preco_custo` → faixa | `qualidade_base` (1-5) | 🟡 Mapear |

**Mapeamento de Qualidade:**
```sql
qualidade_base = CASE 
  WHEN preco_custo <= 250 THEN 2
  WHEN preco_custo <= 600 THEN 3
  WHEN preco_custo <= 1000 THEN 4
  ELSE 5
END
```

---

### MAPEAMENTO 6: Preços
| Campo Mello | Campo SIS Lens | Ação |
|-------------|----------------|------|
| `id` (do produto) | `produto_lab_id` (FK) | ✓ 1:1 |
| `preco_custo` | `preco_custo` | ✓ 1:1 |
| `preco_venda_calculado` | `preco_tabela` | 🟡 Se NULL, calcular * 2.5 |
| `created_at` | `vigencia_inicio` | ✓ 1:1 |
| ❌ | `moeda` | 🔴 'BRL' |
| ❌ | `tabela_referencia` | 🔴 'MELLO_2025' |

---

### MAPEAMENTO 7: Prazos
**Opção A - Genéricos** (`pessoas.fornecedores.prazo_entrega_dias`):
```sql
INSERT INTO logistics.tabela_prazos (
  laboratorio_id, 
  tipo_lente,      -- NULL (genérico)
  categoria,       -- NULL (genérico)
  prazo_minimo,    -- prazo_entrega_dias
  prazo_maximo,    -- prazo_entrega_dias
  custo_frete      -- 2.00 (default)
)
```

**Opção B - Detalhados** (`pessoas.fornecedores_prazos_lentes`):
```sql
INSERT INTO logistics.tabela_prazos (
  laboratorio_id,
  tipo_lente,      -- 'MONOFOCAL' | 'PROGRESSIVA'
  categoria,       -- 'ACABADA' | 'SURFACADA'
  prazo_minimo,    -- prazo_entrega
  prazo_maximo     -- prazo_entrega
)
```

---

## 📊 QUERIES DE INVESTIGAÇÃO

### 1. Ver Essilor Completo
```sql
SELECT 
    id, nome_lente, marca_lente, material, indice_refracao,
    categoria, tratamentos, ar, blue, fotossensivel, polarizado,
    preco_custo, fornecedor_id, sku_geral
FROM lente.fornecedores_lentes
WHERE marca_lente = 'ESSILOR'
ORDER BY preco_custo;
```

### 2. Buscar Outras Marcas Premium
```sql
SELECT marca_lente, COUNT(*) as qtd, MIN(preco_custo) as menor, MAX(preco_custo) as maior
FROM lente.fornecedores_lentes
WHERE marca_lente IN ('ESSILOR', 'ZEISS', 'HOYA', 'VARILUX', 'TRANSITIONS')
GROUP BY marca_lente;
```

### 3. Padrões de Nome para Extrair Linha
```sql
SELECT nome_lente, marca_lente, preco_custo, categoria
FROM lente.fornecedores_lentes
WHERE marca_lente IN ('ESSILOR', 'SOBLOCOS', 'BRASCOR')
ORDER BY marca_lente, preco_custo
LIMIT 30;
```

### 4. Validar FREE FORM
```sql
SELECT 
  CASE WHEN adicao_max > 0 THEN 'Progressiva' ELSE 'Monofocal' END AS tipo_inferido,
  COUNT(*) as qtd,
  MIN(preco_custo) as preco_min,
  MAX(preco_custo) as preco_max
FROM lente.fornecedores_lentes
WHERE tipo_lente = 'FREE FORM'
GROUP BY 1;
```

### 5. Distribuição de Tratamentos Fotocromáticos
```sql
SELECT 
    tratamentos, tratamento_foto, nome_lente, marca_lente,
    COUNT(*) as qtd
FROM lente.fornecedores_lentes
WHERE fotossensivel = true
GROUP BY tratamentos, tratamento_foto, nome_lente, marca_lente
ORDER BY qtd DESC;
```

---

## ✅ CHECKLIST DE VALIDAÇÃO

### Fase 1 - Estrutura
- [ ] Schemas criados (8)
- [ ] Tabela `meta_system.tenants` criada
- [ ] Tenant "Óticas Taty Mello" inserido
- [ ] Tabela `lens_catalog.marcas` criada
- [ ] 6 marcas inseridas (ESSILOR premium, outras genéricas)
- [ ] Tabela `lens_catalog.lentes_canonicas` criada
- [ ] Tabela `lens_catalog.lentes_premium` criada
- [ ] Tabela `suppliers.laboratorios` criada
- [ ] Tabela `suppliers.produtos_laboratorio` criada (com FK polimórfico)
- [ ] Tabela `commercial.precos_base` criada
- [ ] Tabela `logistics.tabela_prazos` criada
- [ ] View `public.vw_todas_lentes` criada

### Fase 2 - Migração de Dados
- [ ] 11 fornecedores migrados
- [ ] Contatos agregados em JSONB
- [ ] 265 lentes canônicas criadas (de `catalogo_mello_lentes`)
- [ ] 21 lentes premium Essilor criadas
- [ ] 1.411 produtos_laboratorio criados
- [ ] FK `lente_canonica_id` OU `lente_premium_id` corretos
- [ ] 1.411 preços migrados
- [ ] Prazos genéricos criados (11 labs)
- [ ] Prazos detalhados criados (5 registros de Brascor/Polylux)

### Fase 3 - Validações de Integridade
- [ ] COUNT(laboratorios) = 11
- [ ] COUNT(lentes_canonicas) = 265
- [ ] COUNT(lentes_premium) = 21 (Essilor por enquanto)
- [ ] COUNT(produtos_laboratorio) = 1.411
- [ ] COUNT(precos_base) = 1.411
- [ ] Todos produtos têm FK válida (canônica OU premium)
- [ ] View `vw_todas_lentes` retorna 286 registros (265 + 21)
- [ ] Nenhum produto "órfão" (sem lente associada)

### Fase 4 - Povoamento Manual (Depois)
- [ ] `linha_produto` preenchida em canônicas
- [ ] `nivel_qualidade` preenchido em canônicas (1-5)
- [ ] Zeiss adicionado (se necessário)
- [ ] Hoya adicionado (se necessário)

---

## 🎯 DECISÕES PENDENTES

### 1. Quando Migrar?
- **Opção A**: Agora (só com 21 Essilor, depois adiciona Zeiss/Hoya no SIS Lens)
- **Opção B**: Depois (primeiro cataloga Zeiss/Hoya no Mello, migra tudo de uma vez)

### 2. Linha e Nível
- Povoar manualmente DEPOIS da migração
- Criar interface/script auxiliar para facilitar preenchimento

### 3. País de Origem
- Confirmar: Essilor (França), Zeiss (Alemanha), Hoya (Japão)

### 4. Prazos Detalhados
- Usar estrutura com `tipo_lente` + `categoria` ✓
- Prazos genéricos quando não houver específico ✓

---

## 📦 CONTADORES ESPERADOS

| Elemento | Atual (Mello) | Novo (SIS Lens) | Status |
|----------|---------------|-----------------|--------|
| Fornecedores | 11 | 11 | ✓ 1:1 |
| Marcas | 6 (extrair) | 6 | ✓ Criar |
| Lentes Canônicas | 265 (normalizados) | 265 | ✓ Migrar |
| Lentes Premium | 21 (só Essilor) | 21 | ✓ Migrar |
| Produtos Lab | 1.411 | 1.411 | ✓ 1:1 |
| Preços | 1.411 | 1.411 | ✓ 1:1 |
| Prazos | 5 (detalhados) + 11 (genéricos) | ~16 | ✓ Criar |
| **Total View** | N/A | **286** (265+21) | ✓ Criar |

---

## 🚀 PRÓXIMAS AÇÕES

1. **Revisar estrutura** proposta (tabelas, campos, constraints)
2. **Confirmar decisões** pendentes (país, quando migrar, etc.)
3. **Executar DDL** completo no SIS Lens (criar todas as tabelas)
4. **Criar script de migração** SQL (Mello → SIS Lens)
5. **Executar migração** e validar contadores
6. **Povoar linha/nível** manualmente depois
7. **Testar view** `vw_todas_lentes` no frontend

---

## 📝 OBSERVAÇÕES FINAIS

### Diferenciais da Nova Estrutura
- ✅ Separação clara: canônicas vs premium
- ✅ Tratamentos simplificados (boolean)
- ✅ Fotocromático diferenciado (Transitions vs genérico)
- ✅ Prazos detalhados (tipo + categoria)
- ✅ Multi-tenant preparado
- ✅ View unificada para frontend
- ✅ FK polimórfico para produtos (canônica OU premium)
- ✅ Campos de linha/nível (povoar depois)

### Gaps a Resolver
- 🟡 Povoamento de linha_produto (manual)
- 🟡 Povoamento de nivel_qualidade (manual)
- 🟡 Adicionar Zeiss/Hoya (quando necessário)
- 🟡 Validar todos os 1.411 produtos encontram seu canônico

---

**Documento vivo**: Atualizar conforme decisões e implementação.