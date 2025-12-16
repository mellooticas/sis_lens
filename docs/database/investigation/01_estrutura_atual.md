# 🏗️ Estrutura Atual do Banco de Dados - Sis Lens

Este documento detalha a estrutura do banco de dados PostgreSQL do Sis Lens, organizada por esquemas (schemas) funcionais.

## 🧭 Visão Geral

O banco de dados utiliza uma arquitetura modular, onde cada domínio do negócio possui seu próprio schema.

| Schema | Domínio | Descrição |
| :--- | :--- | :--- |
| **api** | Interface Pública | Camada de abstração para o frontend. Contém funções e views prontas para consumo (ex: `buscar_lentes`, `criar_decisao_lente`). **O Frontend deve priorizar o uso deste schema.** |
| **meta_system** | Sistema | Controle de multi-tenancy (clientes), usuários e logs do sistema. |
| **lens_catalog** | Catálogo | Fonte da verdade técnica das lentes. Contém marcas, famílias, SKUs canônicos e especificações. |
| **suppliers** | Fornecedores | Cadastro de laboratórios e representantes. |
| **scoring** | Inteligência | Motor de decisão. Calcula notas (scores) para laboratórios e produtos com base em critérios configuráveis (preço, prazo, qualidade). |
| **commercial** | Comercial | Tabelas de preços, descontos e regras comerciais. |
| **logistics** | Logística | Rastreamento de pedidos e métricas de entrega. |
| **orders** | Pedidos/Decisões | Histórico de decisões tomadas pelo sistema e pedidos enviados. |
| **analytics** | Dashboards | Views materializadas e tabelas para relatórios e KPIs. |

---

## 🔍 Detalhamento dos Principais Schemas

### 1. Schema `api` (Contrato com Frontend)
Este é o ponto de entrada principal. O frontend deve evitar consultas diretas às tabelas base e usar estas funções:

*   **`api.buscar_lentes(...)`**: Busca avançada com filtros (marca, grau, tratamentos).
*   **`api.criar_decisao_lente(...)`**: A "cérebro" do sistema. Recebe a receita e o paciente, e retorna as melhores opções de lentes já rankeadas e comparadas.
*   **`api.obter_laboratorio(...)`**: Retorna perfil completo do laboratório, incluindo badges (Gold, Silver) e métricas de desempenho.
*   **`api.obter_dashboard_kpis()`**: Retorna JSON pronto para os cards do dashboard principal.

### 2. Schema `scoring` (Motor de Decisão)
Onde a mágica acontece. O sistema avalia laboratórios continuamente.
*   **`criterios_scoring`**: Define o que importa (Ex: "Pontualidade" tem peso 1.8, "Preço" tem peso 1.7).
*   **`scores_laboratorios`**: Tabela calculada que contém a nota atual (0-10) de cada laboratório.
*   **`avaliacoes_laboratorios`**: Histórico detalhado de cada avaliação recebida (manual ou automática).

### 3. Schema `lens_catalog` (Produtos)
Dados técnicos puros.
*   **`lentes`**: Tabela central dos produtos. Usa `specs_tecnicas` (JSONB) para flexibilidade de atributos.
*   **`sku_canonico`**: Identificador único global (ex: `LENS-0001-ESS-VLX-X...`).

### 4. Schema `orders` (Fluxo de Decisão)
Armazena o resultado das interações.
*   **`decisoes_lentes`**: O "pedido" de recomendação feito pelo usuário.
*   **`alternativas_cotacao`**: As opções que o sistema gerou para aquela decisão (ex: Recomendada, Alternativa 1, Alternativa 2).

---

## ⚠️ Pontos de Atenção para o Frontend

1.  **Uso da API**: Certifique-se de que o SvelteKit está chamando `rpc('nome_funcao')` do Supabase para as funções do schema `api`, em vez de tentar montar queries complexas no client-side.
2.  **Scoring em Tempo Real**: As notas dos laboratórios são reavaliadas periodicamente. O frontend deve mostrar sempre o dado mais fresco (via `api.listar_laboratorios` ou `api.vw_ranking_laboratorios`).
3.  **JSONB**: Muitas colunas (como `specs_tecnicas` e `filtros`) são JSONB. O frontend precisa estar preparado para renderizar chaves dinâmicas se necessário.
