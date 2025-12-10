---
description: Proposta de Refinamento da Estrutura de Dados para o Módulo de Lentes (BestLens)
complexity: 8
---

# 🧠 Refinamento: Estrutura de Lentes Avançada & Integração Modular

Como o **BestLens** operará como um módulo independente (Serviço de Inteligência) para outros apps (CRM, Vendas), precisamos aprofundar a estrutura técnica para garantir precisão nas decisões e facilidade de integração.

## 1. 📏 Grades de Disponibilidade (Availability Grids)

O maior desafio técnico em lentes é saber: *"Esta receita pode ser feita nesta lente?"*
Atualmente, usamos JSONB ou validações simples. Para um motor de decisão robusto, precisamos de grades estruturadas para consultas SQL eficientes.

### Nova Tabela: `lens_catalog.grades_disponibilidade`

Permite mapear faixas de fabricação complexas (ex: "Se Esférico > +2, o Cilíndrico máximo cai para -2").

```sql
CREATE TABLE lens_catalog.grades_disponibilidade (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lente_id UUID NOT NULL REFERENCES lens_catalog.lentes(id) ON DELETE CASCADE,
    
    -- Definição do Retângulo de Disponibilidade
    esferico_min NUMERIC(4,2) NOT NULL,
    esferico_max NUMERIC(4,2) NOT NULL,
    cilindrico_min NUMERIC(4,2) NOT NULL DEFAULT 0,
    cilindrico_max NUMERIC(4,2) NOT NULL, -- Geralmente negativo, ex: -6.00
    adicao_min NUMERIC(4,2) DEFAULT 0,
    adicao_max NUMERIC(4,2) DEFAULT 0,
    
    -- Parâmetros Físicos resultantes desta faixa
    diametro_mm INTEGER NOT NULL, -- ex: 65, 70, 75, 80
    
    -- Controle
    ativo BOOLEAN DEFAULT true,
    
    -- Índice para busca rápida (GIST ou BTREE composto)
    CONSTRAINT ck_grade_esferico CHECK (esferico_max >= esferico_min)
);

CREATE INDEX idx_grades_busca ON lens_catalog.grades_disponibilidade (lente_id, esferico_min, esferico_max, cilindrico_min, cilindrico_max);
```

**Benefício**: O algoritmo `processar_decisao_lente` agora faz um filtro **HARD** antes de pontuar. Elimina o risco de vender uma lente que o laboratório vai recusar.

---

## 2. 🔌 Integração Modular (Webhooks & API)

Apps externos (Sales, CRM) precisam ser notificados quando uma decisão é aprovada ou quando o status da lente muda (Ex: "Entrou em Surfaçagem").

### Novo Schema: `integration`

```sql
-- Apps externos autorizados
CREATE TABLE integration.clientes_api (
    id UUID PRIMARY KEY,
    nome TEXT NOT NULL, -- ex: "App de Venda Loja 1"
    api_key_hash TEXT NOT NULL,
    webhook_url_padrao TEXT,
    tenant_id UUID REFERENCES meta_system.tenants(id)
);

-- Fila de eventos para notificar outros apps
CREATE TABLE integration.eventos_webhook (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    decisao_id UUID REFERENCES orders.decisoes_lentes(id),
    evento TEXT NOT NULL, -- 'DECISAO_CRIADA', 'STATUS_MUDOU', 'LAB_RECUSOU'
    payload JSONB NOT NULL,
    url_destino TEXT NOT NULL,
    tentativas INTEGER DEFAULT 0,
    status TEXT DEFAULT 'PENDENTE', -- PENDENTE, ENVIADO, FALHA
    criado_em TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 3. 🛡️ Tratamentos e Adicionais (Estrutura Combinatória)

Para evitar criar um SKU canônico para cada combinação (Lente X + AR Y + Trans Z), podemos separar os tratamentos compatíveis.

**Problema Atual**: `LENS-001-ESS-VAR-X-167-AR-BLUE` (Tudo num SKU só).
**Vantagem**: Preço fechado, fácil de rankear.
**Desvantagem**: Explosão de SKUs.

**Proposta Híbrida**: Manter SKUs fehados para os "Combos Mais Vendidos" (Top 80%), e usar uma tabela de *Add-ons* para customizações raras.

### Tabela: `lens_catalog.compatibilidade_tratamentos`

```sql
CREATE TABLE lens_catalog.adicionais (
    id UUID PRIMARY KEY,
    nome TEXT, -- "Filtro Azul Extra", "Espelhamento Prata"
    tipo TEXT -- TRATAMENTO, COLORACAO
);

CREATE TABLE lens_catalog.regras_compatibilidade (
    lente_base_id UUID REFERENCES lens_catalog.lentes(id),
    adicional_id UUID REFERENCES lens_catalog.adicionais(id),
    preco_acrescimoNUMERIC(10,2),
    prazo_adicional_dias INTEGER
);
```

*Nota: Para o MVP/Fase 1, recomendo manter a estrutura atual de SKUs Fechados (Combinados) para simplificar o motor de decisão, já que a maioria das óticas trabalha com pacotes fechados dos laboratórios (Lente + AR).*

---

## 4. 🧠 Ideias para o Motor de Decisão (Algoritmo v2)

Para "conversar sobre o ramo ótico", aqui estão diferenciais de inteligência para o banco:

1.  **Histórico de "Quebras" (Garantia)**:
    *   Adicionar tabela `quality.garantias_acionadas`.
    *   Se um lab/lente tem alta taxa de garantia (descasque de antirreflexo), o Score dele cai automaticamente.
    *   *Query*: `orders.processar_decisao` consulta essa taxa para penalizar o score.

2.  **Frete Dinâmico / Consolidação**:
    *   Tabela `logistics.rotas_entrega`.
    *   Se a ótica já tem um pedido aberto naquele laboratório saindo hoje, o custo de frete do novo pedido é ZERO (carona). O algoritmo deve saber disso para priorizar esse lab.

3.  **Sugestão de Upsell (Melhoria de Margem)**:
    *   O algoritmo retorna a "Melhor Técnica" (Ranking 1).
    *   Mas também retorna "Melhor Margem" (onde Preço Venda - Custo Lab é maior).
    *   Isso ajuda o vendedor a decidir qual oferecer.

---

## 🔜 Próximos Passos Sugeridos

1.  **Criar a Tabela de Grades (`lens_catalog.grades_disponibilidade`)**: É a base técnica fundamental.
2.  **Implementar Webhooks Básico**: Para garantir que o sistema não seja uma "ilha".
3.  **Popular Grades de Exemplo**: Criar scripts para popular grades comuns (ex: Lentes prontas -6 a +4).
