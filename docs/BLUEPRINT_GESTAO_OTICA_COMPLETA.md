---
description: Blueprint para expansão do sistema BestLens em um ERP Completo para Óticas
---

# 🏥 Blueprint: Sistema de Gestão Ótica Completo (ERP + Decisor)

## 🎯 Visão Geral
Expandir o atual **"Sistema Decisor de Lentes"** (focado em compras B2B e técnica) para um **"Sistema de Gestão de Ótica"** (focado na operação da loja B2C), criando uma solução ponta-a-ponta.

O sistema atual (`BestLens`) será o **motor de inteligência** dentro do novo ERP.

---

## 🏗️ Nova Estrutura de Schemas

### 1. 👥 CRM & Clientes (Novo Schema: `crm`)
Gerenciamento de relacionamento e histórico do paciente.

- **`crm.clientes`**
    - `id`, `tenant_id`
    - `nome`, `cpf`, `data_nascimento`
    - `contato_principal` (JSON)
    - `endereco` (JSON)
    - `origem_captacao` (Instagram, Passante, Indicação)
    - `metricas` (LTV, Tíquete Médio, Última Compra)

- **`crm.agendamentos`**
    - `id`, `cliente_id`, `doutor_nome`
    - `data_hora`, `tipo` (Exame, Ajuste, Retirada)
    - `status` (Agendado, Confirmado, Realizado, Cancelado)

---

### 2. 🩺 Clínico & Receitas (Novo Schema: `clinical`)
Histórico estruturado de saúde visual (vital para recorrência).

- **`clinical.receitas`**
    - `id`, `cliente_id`, `doutor_nome`, `crm_doutor`
    - `data_receita`, `validade`
    - **Olho Direito (OD)**: Esférico, Cilíndrico, Eixo, Adição, Prisma, Base
    - **Olho Esquerdo (OE)**: Esférico, Cilíndrico, Eixo, Adição, Prisma, Base
    - `dnp_od`, `dnp_oe`, `altura_montagem`
    - `observacoes_medicas`
    - `arquivo_digitalizado_url`

---

### 3. 👓 Estoque & Loja (Novo Schema: `store`)
Gestão física de produtos além das lentes de laboratório.

- **`store.produtos`**
    - `id`, `sku_loja` (Código de barras)
    - `tipo` (ARMACAO, OCULOS_SOL, LENTE_CONTATO, ACESSORIO)
    - `marca`, `modelo`, `cor`, `tamanho_aro`, `tamanho_ponte`
    - `preco_custo`, `preco_venda`, `estoque_atual`
    - `fornecedor_id`

- **`store.movimentacoes_estoque`**
    - Registro de entrada, saída, quebra, inventário.

---

### 4. 💰 Vendas & Financeiro (Novo Schema: `sales`)
O "frente de caixa" que amarra tudo.

- **`sales.pedidos_venda`** (A "OS" da ótica)
    - `id`, `numero_os` (Sequencial amigável)
    - `cliente_id`
    - `receita_id` (Link para o clínico)
    - `vendedor_id`
    - `status` (ORCAMENTO, APROVADO, EM_LABORATORIO, MONTAGEM, PRONTO, ENTREGUE)
    - `total_produtos`, `total_servicos`, `desconto`, `total_final`
    - `previsao_entrega`

- **`sales.itens_venda`**
    - `id`, `pedido_venda_id`
    - `tipo_item` (PRODUTO_LOJA, LENTE_LAB, SERVICO)
    - `produto_store_id` (FK para armações/estoque)
    - `decisao_lente_id` (FK para o **BestLens** existente! 🔗)
    - `valor_unitario`, `quantidade`

- **`sales.pagamentos`**
    - `id`, `pedido_venda_id`
    - `metodo` (Dinheiro, Crédito, Débito, Pix)
    - `parcelas`, `valor`, `data_prevista`, `data_pagamento`

---

## 🔗 Integração: O "Elo Perdido"
A grande inteligência está em conectar a **Venda (Sales)** com a **Decisão (Lens Engine)**.

Quando o vendedor adiciona um par de lentes na OS:
1. O sistema puxa a `clinical.receita` do cliente.
2. Aciona o **BestLens** (`orders.processar_decisao_lente`) usando os dados da receita.
3. O vendedor escolhe a lente (Preço/Prazo/Qualidade) no painel do BestLens.
4. O ID da decisão (`decisao_lente_id`) é salvo no item da venda.
5. Quando a venda é paga, o sistema dispara o pedido para o laboratório (`suppliers`).

## 🚀 Diferenciais Competitivos (Ideias de Funcionalidade)

1.  **Recorrência Inteligente**: O sistema avisa quando a lente de contato está acabando ou quando a receita vai vencer (1 ano).
2.  **Provador Virtual (Simples)**: Upload da foto do cliente para testar armações (usando `store.produtos` com fotos).
3.  **Rastreio WhatsApp**: Cliente recebe "Seus óculos foram para o laboratório", "Chegaram na loja", etc.
4.  **Ranking de Lucratividade**: O BestLens já escolhe a lente técnica, mas agora pode priorizar a lente que dá maior margem para a loja (Preço Venda - Custo Lab).

## 📊 Fluxo de Trabalho Proposto

1.  **Recepção**: Cadastra Cliente (`crm`) e Agendamento.
2.  **Consultório**: Optometrista lança Receita (`clinical`).
3.  **Vendedor**:
    *   Abre Venda (`sales`).
    *   Seleciona Armação (`store`).
    *   Clica em "Selecionar Lentes" -> Abre Popup **BestLens**.
    *   BestLens analisa receita e sugere lentes.
    *   Vendedor confirma.
4.  **Caixa**: Recebe Pagamento.
5.  **Backoffice**: Dispara pedido pro Lab e acompanha status.
