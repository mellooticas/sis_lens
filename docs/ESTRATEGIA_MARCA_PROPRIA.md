---
description: Estratégia técnica para Marca Própria com Sourcing Dinâmico (Multi-lab)
complexity: 9
---

# 🏷️ Estratégia: Marca Própria Dinâmica & Sourcing Inteligente

## 🎯 O Conceito
Diferenciar tecnicamente a venda de **Grife** vs **Marca Própria** para maximizar margem.

1.  **Venda de Grife (Ex: Varilux, Zeiss)**: Produto específico. O sistema busca quem fornece *aquele* SKU com melhor condição.
2.  **Venda de Marca Própria (Ex: "BestLens Gold")**: Produto "abstrato" para o cliente. O sistema faz um leilão interno entre laboratórios homologados para entregar uma lente com aquelas especificações.

---

## 🏗️ Estrutura de Banco de Dados

### 1. Classificação do Produto (`lens_catalog`)

Adicionamos flags para identificar como a lente se comporta.

```sql
ALTER TABLE lens_catalog.marcas ADD COLUMN tipo_marca TEXT DEFAULT 'GRIFE'; -- 'GRIFE' ou 'PROPRIA'

-- Tabela para amarrar a Marca Própria aos produtos reais dos laboratórios
CREATE TABLE lens_catalog.homologacao_marca_propria (
    id UUID PRIMARY KEY,
    lente_marca_propria_id UUID REFERENCES lens_catalog.lentes(id), -- A lente "Virtual" (ex: BestLens Gold)
    
    produto_lab_id UUID REFERENCES suppliers.produtos_laboratorio(id), -- O produto "Real" (ex: Lab A - Digital 1.67)
    
    prioridade_sourcing INTEGER DEFAULT 1, -- Ordem de preferência manual (opcional)
    ativo BOOLEAN DEFAULT true,
    
    UNIQUE(lente_marca_propria_id, produto_lab_id)
);
```

### 2. Lógica do Algoritmo (`orders.processar_decisao`)

O "cérebro" da decisão muda dependendo do tipo de lente selecionada na venda.

#### Cenário A: Cliente quer "Varilux Comfort" (Grife)
*   **Input**: SKU `LENS-VAR-COMFORT`
*   **Query**: Busca em `suppliers.produtos_laboratorio` quem tem esse SKU mapeado.
*   **Resultado**: Lab Essilor Oficial (R$ 500) vs Lab Parceiro Autorizado (R$ 480).
*   **Decisão**: Competição simples de preço/prazo.

#### Cenário B: Cliente quer "BestLens Premium" (Marca Própria)
*   **Input**: SKU `LENS-BEST-PREMIUM` (Marca Própria)
*   **Query**:
    1.  O sistema vê que é Marca Própria.
    2.  Consulta `lens_catalog.homologacao_marca_propria` para ver quem fabrica isso.
    3.  Encontra:
        *   Lab A (Lente "Digital X"): R$ 150,00
        *   Lab B (Lente "Freeform Y"): R$ 140,00
        *   Lab C (Lente "HD Z"): R$ 180,00
    4.  O sistema valida as grades (`grades_disponibilidade`) de cada um (Lab B atende esse grau?).
*   **Resultado**: O sistema escolhe o **Lab B** invisivelmente.
*   **Saída para Vendedor**: "Venda BestLens Premium confirmada. Margem estimada: R$ 400,00".
*   **Pedido para Lab**: "Envie uma Lente Freeform Y".

---

## 🚀 Como isso aparece no Front-end?

### Na Mesa de Venda (Tablet/PC)

O sistema deve mostrar **duas colunas** ou abas claras:

| 💎 CATÁLOGO GRIFE | 🏆 MARCA PRÓPRIA (Maior Lucro) |
| :--- | :--- |
| **Varilux Comfort 3.0** | **BestLens Gold Digital** |
| *Tecnologia W.A.V.E 2.0* | *Tecnologia Freeform HD* |
| Custo Atual: R$ 500,00 | Custo Dinâmico: **R$ 140,00** (Lab B) |
| Venda Sugerida: R$ 1.200,00 | Venda Sugerida: R$ 900,00 |
| **Margem: R$ 700,00** | **Margem: R$ 760,00** 📈 |
| [Selecionar] | [Selecionar - Recomendado] |

Isso empodera o vendedor a oferecer um desconto maior na Marca Própria e ainda ganhar mais dinheiro.

## 🛡️ Controle de Qualidade (White Label)

Para isso funcionar, precisamos garantir que o cliente não perceba diferença de qualidade se o pedido cair no Lab A ou Lab B.

*   **Tabela `lens_catalog.especificacoes_minimas`**:
    *   Para ser homologada como "BestLens Gold", a lente do laboratório TEM que ter:
        *   Corredor Progressivo: > 14mm
        *   Campo de Visão: > 80%
        *   Tratamento AR: Hidrofóbico
    *   Isso garante consistência.

---

## 📊 Benefícios Resumidos

1.  **Poder de Negociação**: Você não fica refém de um laboratório. Se o Lab A aumentar o preço, o sistema automaticamente começa a direcionar volume para o Lab B (que ficou mais barato).
2.  **Blindagem de Estoque**: Se o Lab A quebrar ou atrasar, o sistema redireciona para o Lab C sem o cliente saber.
3.  **Maximização de Lucro**: O sistema sempre busca o menor custo *do momento* para entregar a promessa de qualidade da sua marca.
