📐 Blueprint Completo — Sistema Decisor de Lentes
Versão 1.0 - Documento de Arquitetura Raiz

🎯 Visão Executiva
Propósito
Sistema de apoio à decisão para compra de lentes oftálmicas, comparando múltiplos laboratórios em tempo real considerando preço, prazo e qualidade.
Problema que Resolve

Catálogos fragmentados entre laboratórios
Nomenclaturas diferentes para o mesmo produto
Decisões baseadas em planilhas desatualizadas
Falta de visibilidade de custo total (preço + frete)
Ausência de métricas de qualidade dos fornecedores

Solução
Plataforma unificada com:

Normalização canônica de lentes (SKU único)
Motor de ranking multi-critério (urgência/normal/especial)
Histórico de decisões para auditoria e analytics
Multi-tenant com isolamento por RLS


🏛️ Arquitetura de Alto Nível
┌─────────────────────────────────────────────────────────────┐
│                      FRONTEND (SvelteKit)                    │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────────────┐  │
│  │ Buscar  │  │ Ranking │  │ Decidir │  │  Histórico   │  │
│  │  Lente  │  │ Opções  │  │ Compra  │  │  Decisões    │  │
│  └─────────┘  └─────────┘  └─────────┘  └──────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS + JWT
                         │ (Supabase Client)
┌────────────────────────▼────────────────────────────────────┐
│                    PUBLIC SCHEMA (API)                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  VIEWS              │  RPC FUNCTIONS                  │  │
│  │  ───────────────────┼─────────────────────────────── │  │
│  │  vw_lentes_catalogo │  rpc_rank_opcoes()             │  │
│  │  vw_ranking_opcoes  │  rpc_confirmar_decisao()       │  │
│  │  vw_fornecedores    │  rpc_buscar_lente()            │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │ RLS + Security Invoker
┌────────────────────────▼────────────────────────────────────┐
│              SCHEMAS PRIVADOS (Domain Logic)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │lens_catalog  │  │  suppliers   │  │ commercial   │     │
│  │  (canônico)  │  │    (labs)    │  │(preços/desc) │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  logistics   │  │   scoring    │  │    orders    │     │
│  │(prazo/frete) │  │  (qualidade) │  │  (decisões)  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │ meta_system  │  │  analytics   │                        │
│  │(tenant/auth) │  │ (relatórios) │                        │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘

📦 Estrutura de Schemas — Bounded Contexts
1. lens_catalog — Fonte da Verdade Técnica
Responsabilidade: Lentes normalizadas, atributos técnicos imutáveis.
Conceitos-chave:

SKU Canônico: Código interno único, imutável (ex: LENS-0001-ESS-VLX-X-167-HC-AR-BLUE)
Hierarquia: Marca → Família → Design
Atributos Técnicos: Material, índice refração, tratamentos, tipo (mono/bi/progressiva)

Entidades principais:
lentes
├─ id (PK)
├─ tenant_id (FK → meta_system.tenants)
├─ sku_canonico (UNIQUE)
├─ marca_id (FK → marcas)
├─ familia (TEXT)
├─ design (TEXT)
├─ material (TEXT)
├─ indice_refracao (NUMERIC)
├─ tratamentos (TEXT[])
├─ tipo_lente (TEXT)
├─ corredor_progressao (INTEGER, nullable)
├─ specs_tecnicas (JSONB)
└─ ativo (BOOLEAN)

marcas
├─ id (PK)
├─ nome (TEXT) — Essilor, Hoya, Zeiss, etc.
└─ pais_origem (TEXT)
Regras de negócio:

SKU canônico NUNCA muda (mesmo se lab descontinuar)
Tratamentos são arrays (permite combos: ['HC', 'AR', 'BLUE'])
JSONB permite extensibilidade (novos atributos sem migration)

Queries típicas:

Buscar lente por características técnicas
Listar todas as variações de uma família
Filtrar por índice + tratamentos


2. suppliers — Mundo Real dos Laboratórios
Responsabilidade: Labs, catálogos nativos, mapeamento para o canônico.
Conceitos-chave:

SKU Laboratório: Código nativo do lab (ex: ESS-VLX-167-BLU)
SKU Fantasia: Código comercial humanizado (ex: VARILUX-X-167-BLUE)
Mapeamento N:1: Vários SKUs de labs → 1 SKU canônico

Entidades principais:
laboratorios
├─ id (PK)
├─ tenant_id (FK)
├─ nome (TEXT)
├─ nome_fantasia (TEXT)
├─ cnpj (TEXT, nullable)
├─ contato_comercial (JSONB)
├─ lead_time_padrao_dias (INTEGER)
├─ atende_regioes (TEXT[])
└─ ativo (BOOLEAN)

produtos_laboratorio
├─ id (PK)
├─ tenant_id (FK)
├─ laboratorio_id (FK → laboratorios)
├─ sku_laboratorio (TEXT) — código do lab
├─ nome_comercial (TEXT) — nome marketing do lab
├─ sku_fantasia (TEXT) — nosso código comercial
├─ lente_id (FK → lens_catalog.lentes) — mapeamento!
├─ qualidade_base (INTEGER 1-5)
├─ disponivel (BOOLEAN)
└─ descontinuado_em (DATE, nullable)
Regras de negócio:

Um lab pode ter múltiplos SKUs para a mesma lente canônica
sku_fantasia facilita comunicação (ex: em vez de LENS-0001-...)
qualidade_base é percepção inicial (pode ser sobreposta por scoring real)

Exemplo de mapeamento:
LabSKU LabNome ComercialSKU FantasiaLente CanônicaEssilorESS-VLX-X-167-BLUVarilux X Series 1.67 Blue UVVARILUX-X-167-BLUELENS-0001HoyaHOYA-ID-MYV-167Hoya iD MyView 1.67HOYA-ID-167LENS-0042ZeissZEI-SMF-160-DRVZeiss SmartLife 1.60 DriveSafeZEISS-SL-160-DRIVELENS-0089

3. commercial — Precificação e Descontos
Responsabilidade: Preços base, tabelas vigentes, regras de desconto.
Conceitos-chave:

Vigência temporal: Preços têm validade (início/fim)
Descontos por escopo: Lab, Marca ou Produto específico
Prioridade: Produto > Marca > Lab

Entidades principais:
precos_base
├─ id (PK)
├─ tenant_id (FK)
├─ produto_lab_id (FK → suppliers.produtos_laboratorio)
├─ moeda (TEXT)
├─ preco_custo (NUMERIC)
├─ preco_tabela (NUMERIC)
├─ vigencia_inicio (DATE)
├─ vigencia_fim (DATE, nullable)
└─ tabela_referencia (TEXT)

descontos
├─ id (PK)
├─ tenant_id (FK)
├─ escopo (ENUM: LABORATORIO | MARCA | PRODUTO)
├─ alvo_id (UUID) — FK polimórfico
├─ tipo_desconto (ENUM: PERCENTUAL | VALOR_FIXO | PRECO_TETO)
├─ valor (NUMERIC)
├─ prioridade (INTEGER)
├─ vigencia_inicio (DATE)
├─ vigencia_fim (DATE, nullable)
└─ ativo (BOOLEAN)
Regras de negócio:

Apenas 1 preço ativo por produto em um período (EXCLUDE constraint)
Descontos empilham por prioridade (maior prioridade = aplica primeiro)
Tipo PRECO_TETO: define preço máximo (ignora tabela se maior)

Cálculo de preço final:
1. Pega preco_tabela
2. Aplica descontos (ordem: prioridade DESC)
3. Se PRECO_TETO < resultado, usa PRECO_TETO
4. Retorna preco_final

4. logistics — Prazos e Fretes
Responsabilidade: Lead times, custos de entrega, regiões atendidas.
Entidades principais:
tabela_prazos
├─ id (PK)
├─ tenant_id (FK)
├─ laboratorio_id (FK → suppliers.laboratorios)
├─ regiao_origem (TEXT, nullable)
├─ regiao_destino (TEXT) — SUL, SUDESTE, etc.
├─ prazo_minimo (INTEGER) — dias úteis
├─ prazo_maximo (INTEGER)
├─ prazo_medio (INTEGER GENERATED) — (min+max)/2
├─ custo_frete (NUMERIC)
├─ frete_gratis_acima (NUMERIC, nullable)
├─ vigencia_inicio (DATE)
├─ vigencia_fim (DATE, nullable)
└─ ativo (BOOLEAN)
Regras de negócio:

Prazo médio é gerado automaticamente
Frete pode ser zero se pedido > frete_gratis_acima
Labs podem ter múltiplas tabelas (ex: expresso vs econômico)


5. scoring — Qualidade e Performance
Responsabilidade: Métricas históricas de qualidade dos labs.
Entidades principais:
metricas_laboratorio
├─ id (PK)
├─ tenant_id (FK)
├─ laboratorio_id (FK → suppliers.laboratorios)
├─ periodo_inicio (DATE)
├─ periodo_fim (DATE)
├─ sla_cumprimento_pct (NUMERIC) — % pedidos no prazo
├─ taxa_reentrega_pct (NUMERIC) — % refação
├─ taxa_atraso_medio_dias (NUMERIC)
├─ score_qualidade (INTEGER GENERATED) — 0-100
└─ fonte (TEXT) — MANUAL | AUTO | INTEGRACAO
Fórmula do score (exemplo):
score_qualidade = 
  (sla_cumprimento_pct * 0.5) +
  ((100 - taxa_reentrega_pct) * 0.3) +
  (max(0, 100 - taxa_atraso_medio_dias * 10) * 0.2)
MVP: Dados inseridos manualmente.
Futuro: Automatizar via integração com sistema de pedidos.

6. orders — Decisões e Auditoria
Responsabilidade: Log imutável de todas as decisões de compra.
Entidades principais:
decisoes_compra
├─ id (PK)
├─ tenant_id (FK)
├─ lente_id (FK → lens_catalog.lentes)
├─ laboratorio_id (FK → suppliers.laboratorios)
├─ produto_lab_id (FK → suppliers.produtos_laboratorio)
├─ criterio (ENUM: URGENCIA | NORMAL | ESPECIAL)
├─ preco_final (NUMERIC)
├─ prazo_estimado_dias (INTEGER)
├─ custo_frete (NUMERIC)
├─ score_atribuido (NUMERIC)
├─ motivo (TEXT)
├─ alternativas_consideradas (JSONB)
├─ decidido_por (UUID) — user_id
├─ decidido_em (TIMESTAMPTZ)
├─ status (TEXT) — DECIDIDO | ENVIADO | CONFIRMADO | ENTREGUE
└─ payload_decisao (JSONB) — snapshot completo
Regras de negócio:

Registro é append-only (nunca UPDATE)
alternativas_consideradas guarda Top N (ex: top 3 que perderam)
payload_decisao é snapshot para auditoria (preços podem mudar depois)


7. meta_system — Multi-tenant e Controle
Responsabilidade: Tenants, feature flags, configurações globais.
Entidades principais:
tenants
├─ id (PK)
├─ nome (TEXT)
├─ slug (TEXT UNIQUE)
├─ configuracoes (JSONB)
└─ ativo (BOOLEAN)

feature_flags
├─ id (PK)
├─ tenant_id (FK → tenants)
├─ flag_nome (TEXT)
└─ habilitado (BOOLEAN)

parametros_tenant (futuro: pesos customizáveis)
├─ tenant_id (FK)
├─ chave (TEXT) — ex: "peso_ranking_urgencia"
├─ valor (JSONB)
└─ tipo (TEXT) — PESOS | CONFIG | INTEGRACAO
Configurações típicas em JSONB:
json{
  "moeda_padrao": "BRL",
  "pesos_ranking": {
    "urgencia": {"prazo": 0.6, "preco": 0.25, "qualidade": 0.15},
    "normal": {"preco": 0.6, "prazo": 0.3, "qualidade": 0.1},
    "especial": {"qualidade": 0.6, "prazo": 0.25, "preco": 0.15}
  },
  "notificacoes": {
    "email_decisao": true,
    "webhook_dcl": "https://api.desenroladcl.com/webhook"
  }
}

8. analytics — Relatórios e Insights
Responsabilidade: Views materializadas, agregações para dashboards.
Entidades principais:
mv_economia_por_fornecedor (materialized view)
├─ laboratorio_id
├─ periodo (DATE range)
├─ total_pedidos (INTEGER)
├─ economia_total (NUMERIC) — vs preço_tabela original
└─ preco_medio (NUMERIC)

mv_performance_criterios (materialized view)
├─ criterio (URGENCIA|NORMAL|ESPECIAL)
├─ laboratorio_id
├─ vezes_escolhido (INTEGER)
└─ score_medio (NUMERIC)
Refresh strategy:

MVP: Manual (REFRESH MATERIALIZED VIEW)
Futuro: Cron job (pg_cron) ou trigger em decisoes_compra


🔐 Segurança — RLS e Políticas
Princípios

Todas as tabelas têm RLS habilitado
Tenant isolation via tenant_id = auth.jwt()->>'tenant_id'
Views públicas usam security_invoker (respeitam RLS do caller)
RPCs usam security_invoker quando possível (evitar privilege escalation)

Template de RLS (aplicar em todas as tabelas)
sql-- Habilitar RLS
ALTER TABLE schema.tabela ENABLE ROW LEVEL SECURITY;

-- Política universal
CREATE POLICY tenant_isolation ON schema.tabela
  FOR ALL
  USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
Exceções (tabelas sem RLS)

meta_system.tenants → usa políticas custom (admin only)
meta_system.feature_flags → idem
Logs técnicos (se houver) → sem RLS, mas sem PII


🌐 Camada Pública — Views e RPCs
Views Expostas em public
1. vw_lentes_catalogo
Propósito: Busca/autosuggest de lentes.
Campos retornados:

lente_id
sku_canonico
sku_fantasia (melhor opção, se houver)
marca_nome
familia
design
tipo_lente
indice_refracao
tratamentos
descricao_completa (gerada)

Ordenação: Por popularidade (futuro) ou alfabética.

2. vw_ranking_opcoes
Propósito: Base para RPC de ranking.
Campos retornados:

lente_id
laboratorio_id
laboratorio_nome
sku_fantasia
preco_tabela
preco_com_desconto (aplicado)
prazo_medio
custo_frete
score_qualidade (mais recente)
tenant_id

Joins:
lens_catalog.lentes
→ suppliers.produtos_laboratorio
→ suppliers.laboratorios
→ commercial.precos_base (vigente)
→ logistics.tabela_prazos (por região)
→ scoring.metricas_laboratorio (mais recente)
Filtros automáticos:

ativo = true
disponivel = true
Vigências válidas


3. vw_fornecedores_disponiveis
Propósito: Dropdown de labs para filtros.
Campos:

laboratorio_id
nome
regioes_atendidas
lead_time_medio


RPCs Expostos em public
1. rpc_rank_opcoes()
Assinatura:
sqlrpc_rank_opcoes(
  p_lente_id UUID,
  p_criterio TEXT, -- 'URGENCIA' | 'NORMAL' | 'ESPECIAL'
  p_filtros JSONB DEFAULT '{}'
)
RETURNS TABLE(
  laboratorio_id UUID,
  laboratorio_nome TEXT,
  sku_fantasia TEXT,
  preco_final NUMERIC,
  prazo_dias INTEGER,
  custo_frete NUMERIC,
  score_qualidade INTEGER,
  score_ponderado NUMERIC,
  rank_posicao INTEGER,
  justificativa TEXT
)
Lógica:

Pega tenant do JWT
Define pesos por critério:

URGENCIA: prazo 60%, preço 25%, qualidade 15%
NORMAL: preço 60%, prazo 30%, qualidade 10%
ESPECIAL: qualidade 60%, prazo 25%, preço 15%


Query em vw_ranking_opcoes
Normaliza scores (0-100 cada dimensão)
Aplica fórmula ponderada
Ordena DESC
Gera justificativa textual (ex: "Melhor prazo, preço 5% acima do menor")

Retorno: Top 10 opções ranqueadas.

2. rpc_confirmar_decisao()
Assinatura:
sqlrpc_confirmar_decisao(
  p_payload JSONB
)
RETURNS UUID -- decisao_id
Payload esperado:
json{
  "lente_id": "uuid",
  "laboratorio_id": "uuid",
  "produto_lab_id": "uuid",
  "criterio": "URGENCIA",
  "preco_final": 350.00,
  "prazo_estimado_dias": 5,
  "custo_frete": 15.00,
  "score_atribuido": 87.5,
  "motivo": "Melhor prazo, preço aceitável",
  "alternativas": [
    {"lab": "Lab B", "preco": 320.00, "prazo": 10},
    {"lab": "Lab C", "preco": 380.00, "prazo": 3}
  ]
}
Lógica:

Valida JWT (tenant_id + user_id)
Insere em orders.decisoes_compra
Retorna decisao_id
(Futuro) Dispara webhook Edge Function


3. rpc_buscar_lente()
Assinatura:
sqlrpc_buscar_lente(
  p_query TEXT,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE(
  lente_id UUID,
  label TEXT, -- Ex: "Varilux X Series 1.67 HC+AR+Blue"
  sku_fantasia TEXT
)
Lógica:

Full-text search em familia || design || tratamentos
Retorna matches ordenados por relevância


🎨 Frontend — Arquitetura SvelteKit
Estrutura de Diretórios
apps/decisor-lentes/
├─ src/
│  ├─ lib/
│  │  ├─ supabase.ts               # Cliente Supabase (singleton)
│  │  ├─ stores/
│  │  │  ├─ session.ts             # Auth store (user, tenant)
│  │  │  ├─ ranking.ts             # Estado do ranking atual
│  │  │  └─ filtros.ts             # Filtros ativos 
│  │  ├─ api/
│  │  │  ├─ lentes.ts              # Wrapper vw_lentes_catalogo
│  │  │  ├─ ranking.ts             # Wrapper rpc_rank_opcoes
│  │  │  └─ decisao.ts             # Wrapper rpc_confirmar_decisao
│  │  └─ utils/
│  │     ├─ formatters.ts          # Moeda, data, etc.
│  │     └─ validators.ts          # Zod schemas
│  ├─ routes/
│  │  ├─ +layout.svelte            # Layout global + nav
│  │  ├─ +layout.server.ts         # Preload session
│  │  ├─ +page.svelte              # Dashboard (home)
│  │  ├─ buscar/
│  │  │  └─ +page.svelte           # Busca lente (autosuggest)
│  │  ├─ ranking/
│  │  │  └─ [lenteId]/+page.svelte # Tabela comparativa
│  │  ├─ decisao/
│  │  │  └─ [decisaoId]/+page.svelte # Confirmação final
│  │  └─ historico/
│  │     └─ +page.svelte           # Decisões passadas
│  ├─ components/
│  │  ├─ SearchLente.svelte        # Input com autosuggest
│  │  ├─ FiltrosAvancados.svelte   # Região, prazo máx, etc.
│  │  ├─ TabelaRanking.svelte      # Grid comparativo
│  │  ├─ CardFornecedor.svelte     # Card individual
│  │  └─ ModalConfirmacao.svelte   # Confirmar decisão
│  └─ app.css                      # Tailwind base
├─ static/
│  └─ favicon.png
├─ .env.example
├─ package.json
├─ svelte.config.js
└─ vite.config.ts

Fluxo de UX (Happy Path)
1. [/buscar]
   ↓ Usuário digita "Varilux 1.67"
   ↓ Autosuggest chama rpc_buscar_lente()
   ↓ Seleciona lente
   
2. [/ranking/{lenteId}]
   ↓ Escolhe critério: [Urgência] [Normal] [Especial]
   ↓ (Opcional) Aplica filtros: região, prazo máx
   ↓ Sistema chama rpc_rank_opcoes() 
   ↓ Exibe Top 3 em cards destacados
   ↓ Usuário clica "Escolher Lab X"
   
3. [/decisao/{decisaoId}]
   ↓ Modal: "Confirmar compra?"
   ↓ Mostra resumo: lente, lab, preço, prazo
   ↓ Usuário confirma
   ↓ Chama rpc_confirmar_decisao()
   ↓ Redireciona para /historico
   
4. [/historico]
   ↓ Lista todas as decisões do tenant
   ↓ Filtros: data, lab, critério
   ↓ Export CSV (futuro)

Stores Svelte (Estado Global)
stores/session.ts
typescriptimport { writable } from 'svelte/store';
import type { User } from '@supabase/supabase-js';

interface Session {
  user: User | null;
  tenantId: string | null;
  tenantNome: string | null;
}

export const session = writable<Session>({
  user: null,
  tenantId: null,
  tenantNome: null
});
stores/ranking.ts
typescriptimport { writable } from 'svelte/store';

interface RankingState {
  lenteId: string | null;
  criterio: 'URGENCIA' | 'NORMAL' | 'ESPECIAL';
  opcoes: Array<{
    laboratorioId: string;
    laboratorioNome: string;
    precoFinal: number;
    prazoDias: number;
    scorePonderado: number;
    // ...
  }>;
  loading: boolean;
}

export const ranking = writable<RankingState>({
  lenteId: null,
  criterio: 'NORMAL',
  opcoes: [],
  loading: false
});

API Wrappers (Exemplo)
api/ranking.ts
typescriptimport { supabase } from '$lib/supabase';

export async function getRanking(
  lenteId: string,
  criterio: 'URGENCIA' | 'NORMAL' | 'ESPECIAL',
  filtros = {}
) {
  const { data, error } = await supabase.rpc('rpc_rank_opcoes', {
    p_lente_id: lenteId,
    p_criterio: criterio,
    p_filtros: filtros
  });

  if (error) {
    console.error('Erro ao buscar ranking:', error);
    throw error;
  }

  return data;
}

⚙️ Motor de Ranking — Lógica Detalhada
Normalização de Scores (0-100)
Cada dimensão é normalizada para 0-100:
Preço:
score_preco = 100 - (preco_item / preco_max * 100)
(Menor preço = score maior)
Prazo:
score_prazo = 100 - (prazo_item / prazo_max * 100)
(Menor prazo = score maior)
Qualidade:
score_qualidade = qualidade_index (já 0-100)
Aplicação de Pesos
score_final = 
  (score_preco * peso_preco) +
  (score_prazo * peso_prazo) +
  (score_qualidade * peso_qualidade)
Presets de Pesos
CritérioPreçoPrazoQualidadeURGENCIA0.250.600.15NORMAL0.600.300.10ESPECIAL0.150.250.60
Exemplo de Cálculo
Lente: Varilux X 1.67
3 Labs disponíveis:
LabPreçoPrazoQualidadeAR$ 4003 dias90BR$ 3507 dias85CR$ 3805 dias95
Critério: URGENCIA (prazo=0.6, preço=0.25, qualidade=0.15)
Normalização:

Max preço = 400, max prazo =
Tentar novamenteJContinuarEditar📐 Blueprint Completo — Sistema Decisor de Lentes (Continuação)

⚙️ Motor de Ranking — Lógica Detalhada (continuação)
Exemplo de Cálculo (continuação)
Lente: Varilux X 1.67
3 Labs disponíveis:
LabPreçoPrazoQualidadeAR$ 4003 dias90BR$ 3507 dias85CR$ 3805 dias95
Critério: URGENCIA (prazo=0.6, preço=0.25, qualidade=0.15)
Passo 1: Normalização (0-100)
Preço (menor é melhor):
Lab A: 100 - (400/400 * 100) = 0
Lab B: 100 - (350/400 * 100) = 12.5
Lab C: 100 - (380/400 * 100) = 5.0
Prazo (menor é melhor):
Lab A: 100 - (3/7 * 100) = 57.14
Lab B: 100 - (7/7 * 100) = 0
Lab C: 100 - (5/7 * 100) = 28.57
Qualidade (já normalizado):
Lab A: 90
Lab B: 85
Lab C: 95
Passo 2: Aplicação de pesos (URGENCIA)
Lab A: (0 × 0.25) + (57.14 × 0.6) + (90 × 0.15) = 47.78
Lab B: (12.5 × 0.25) + (0 × 0.6) + (85 × 0.15) = 15.88
Lab C: (5.0 × 0.25) + (28.57 × 0.6) + (95 × 0.15) = 32.39
Ranking final (URGENCIA):

Lab A → 47.78 (melhor prazo compensa preço alto)
Lab C → 32.39
Lab B → 15.88


Agora com critério NORMAL (preço=0.6, prazo=0.3, qualidade=0.1):
Lab A: (0 × 0.6) + (57.14 × 0.3) + (90 × 0.1) = 26.14
Lab B: (12.5 × 0.6) + (0 × 0.3) + (85 × 0.1) = 16.00
Lab C: (5.0 × 0.6) + (28.57 × 0.3) + (95 × 0.1) = 21.07
Ranking final (NORMAL):

Lab A → 26.14 (prazo ainda pesa)
Lab C → 21.07
Lab B → 16.00


Agora com critério ESPECIAL (qualidade=0.6, prazo=0.25, preço=0.15):
Lab A: (0 × 0.15) + (57.14 × 0.25) + (90 × 0.6) = 68.29
Lab B: (12.5 × 0.15) + (0 × 0.25) + (85 × 0.6) = 52.88
Lab C: (5.0 × 0.15) + (28.57 × 0.25) + (95 × 0.6) = 64.39
Ranking final (ESPECIAL):

Lab A → 68.29 (qualidade alta vence)
Lab C → 64.39
Lab B → 52.88


Geração de Justificativa
A função RPC gera texto explicativo:
sql-- Lógica simplificada
justificativa := CASE 
  WHEN rank_posicao = 1 THEN
    CASE criterio
      WHEN 'URGENCIA' THEN 
        'Melhor prazo (' || prazo_dias || ' dias), preço ' || 
        round((preco_final - preco_min) / preco_min * 100) || '% acima do menor.'
      WHEN 'NORMAL' THEN
        'Melhor custo-benefício, ' || 
        round((preco_final - preco_min) / preco_min * 100) || '% mais barato que a média.'
      WHEN 'ESPECIAL' THEN
        'Melhor qualidade (score ' || score_qualidade || '/100), prazo aceitável.'
    END
  ELSE
    'Opção ' || rank_posicao || ': ' || 
    CASE WHEN prazo_dias < prazo_medio THEN 'prazo reduzido' ELSE 'preço competitivo' END
END;
Saída exemplo:

Lab A (rank 1): "Melhor prazo (3 dias), preço 14% acima do menor."
Lab C (rank 2): "Opção 2: qualidade superior, prazo intermediário."
Lab B (rank 3): "Opção 3: menor preço, prazo mais longo."


🔄 Fluxo de Dados — Ponta a Ponta
Fluxo 1: Buscar Lente
┌──────────────┐
│   Frontend   │
│ (SearchBar)  │
└──────┬───────┘
       │ onChange("Varilux")
       ▼
┌──────────────────────────────────┐
│ supabase.rpc('rpc_buscar_lente') │
│ p_query: "Varilux"               │
│ p_limit: 20                      │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ RPC Function (Postgres)          │
│ • Full-text search em            │
│   vw_lentes_catalogo             │
│ • WHERE to_tsvector() @@         │
│   plainto_tsquery('Varilux')     │
│ • ORDER BY ts_rank DESC          │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Retorna JSON:                    │
│ [                                │
│   {lente_id, label, sku_fantasia}│
│   ...                            │
│ ]                                │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────┐
│   Frontend   │
│ (Dropdown)   │
│ • Renderiza  │
│   options    │
└──────────────┘

Fluxo 2: Gerar Ranking
┌──────────────┐
│   Frontend   │
│ (Ranking Page)│
└──────┬───────┘
       │ onMount / onClick("Urgência")
       ▼
┌──────────────────────────────────┐
│ supabase.rpc('rpc_rank_opcoes')  │
│ p_lente_id: uuid                 │
│ p_criterio: 'URGENCIA'           │
│ p_filtros: {regiao: 'SUL'}       │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────┐
│ RPC Function (Postgres)                      │
│ 1. Valida JWT → tenant_id                    │
│ 2. Define pesos (URGENCIA = prazo 60%)       │
│ 3. Query vw_ranking_opcoes                   │
│    • WHERE lente_id = p_lente_id             │
│    • AND tenant_id = JWT.tenant_id           │
│    • AND região IN filtros.regiao            │
│ 4. Normaliza scores (0-100)                  │
│ 5. Aplica fórmula ponderada                  │
│ 6. ORDER BY score_ponderado DESC             │
│ 7. LIMIT 10                                  │
│ 8. Gera justificativa por linha              │
└──────┬───────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Retorna JSON:                    │
│ [                                │
│   {                              │
│     laboratorio_id,              │
│     laboratorio_nome,            │
│     preco_final: 380,            │
│     prazo_dias: 3,               │
│     score_ponderado: 47.78,      │
│     rank_posicao: 1,             │
│     justificativa: "Melhor..."   │
│   },                             │
│   ...                            │
│ ]                                │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────┐
│   Frontend   │
│ (Tabela)     │
│ • Top 3 cards│
│ • Resto lista│
└──────────────┘

Fluxo 3: Confirmar Decisão
┌──────────────┐
│   Frontend   │
│ (Modal)      │
└──────┬───────┘
       │ onClick("Confirmar Lab A")
       ▼
┌────────────────────────────────────────┐
│ supabase.rpc('rpc_confirmar_decisao')  │
│ p_payload: {                           │
│   lente_id,                            │
│   laboratorio_id,                      │
│   criterio: 'URGENCIA',                │
│   preco_final: 400,                    │
│   alternativas: [...]                  │
│ }                                      │
└──────┬─────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────┐
│ RPC Function (Postgres)                      │
│ 1. Valida JWT → tenant_id, user_id           │
│ 2. INSERT INTO orders.decisoes_compra        │
│    • tenant_id = JWT.tenant_id               │
│    • decidido_por = JWT.sub (user_id)        │
│    • decidido_em = NOW()                     │
│    • payload_decisao = p_payload (snapshot)  │
│ 3. RETURNING id AS decisao_id                │
└──────┬─────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Retorna JSON:                    │
│ {decisao_id: "uuid-xyz"}         │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────┐
│   Frontend   │
│ • Toast OK   │
│ • Redirect   │
│   /historico │
└──────────────┘

🧩 Integrações Futuras
1. Desenrola DCL (Geração de Cartão)
Trigger: Após confirmar decisão.
Arquitetura:
┌──────────────────────────────┐
│ orders.decisoes_compra       │
│ (INSERT trigger)             │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ meta_system.outbox           │
│ • evento: 'decisao_criada'   │
│ • payload: {decisao_id}      │
│ • status: 'PENDING'          │
└──────┬───────────────────────┘
       │
       ▼
┌────────────────────────────────────┐
│ Supabase Edge Function             │
│ (webhook_processor)                │
│ • Polling outbox (ou pg_notify)    │
│ • GET decisao completa             │
│ • POST desenroladcl.com/api/orders │
│ • UPDATE outbox status = 'SENT'    │
└────────────────────────────────────┘
Payload enviado ao DCL:
json{
  "external_id": "decisao-uuid",
  "tenant_id": "uuid",
  "lente": {
    "sku": "VARILUX-X-167-BLUE",
    "descricao": "Varilux X Series 1.67 HC+AR+Blue"
  },
  "laboratorio": {
    "id": "lab-uuid",
    "nome": "Essilor Brasil"
  },
  "valores": {
    "preco_final": 400.00,
    "frete": 15.00,
    "total": 415.00
  },
  "prazo_estimado_dias": 3,
  "observacoes": "Decisão por critério URGENCIA"
}

2. Importação de Catálogos (ETL)
Cenário: Labs enviam planilhas Excel mensalmente.
Fluxo:
┌──────────────────────┐
│ Upload Excel         │
│ (Frontend)           │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Supabase Storage                 │
│ • Bucket: 'catalogos'            │
│ • Path: tenant/{lab_id}/YYYYMM/  │
└──────┬───────────────────────────┘
       │ (trigger storage.objects)
       ▼
┌──────────────────────────────────┐
│ Edge Function (etl_catalogo)     │
│ • Parse Excel (SheetJS)          │
│ • Validar colunas                │
│ • Mapear SKUs (fuzzy match)      │
│ • INSERT/UPDATE precos_base      │
│ • Log em meta_system.import_logs │
└──────────────────────────────────┘
Validações críticas:

SKU existe em produtos_laboratorio?
Preço > 0 e < threshold (ex: 10k)?
Vigência não sobrepõe preço ativo?


3. Coleta Automática de Métricas (SLA)
Cenário: Sistema de pedidos externo envia webhooks.
Fluxo:
┌────────────────────────────────┐
│ Sistema Externo (ERP/WMS)      │
│ • Pedido entregue              │
└──────┬─────────────────────────┘
       │ POST /api/webhook/entrega
       ▼
┌────────────────────────────────┐
│ Edge Function (webhook_receiver)│
│ • Valida signature (HMAC)       │
│ • Parse payload                 │
│ • Calcula atraso (data real vs  │
│   prazo_estimado)               │
│ • UPDATE scoring.metricas_lab   │
└────────────────────────────────┘
Cálculo de métricas:
sql-- Agregação diária (cron job)
INSERT INTO scoring.metricas_laboratorio (
  laboratorio_id,
  periodo_inicio,
  periodo_fim,
  sla_cumprimento_pct,
  taxa_atraso_medio_dias
)
SELECT 
  laboratorio_id,
  DATE_TRUNC('month', decidido_em) AS periodo_inicio,
  DATE_TRUNC('month', decidido_em) + INTERVAL '1 month' - INTERVAL '1 day' AS periodo_fim,
  COUNT(*) FILTER (WHERE data_entrega <= prazo_estimado) * 100.0 / COUNT(*) AS sla,
  AVG(EXTRACT(DAY FROM data_entrega - prazo_estimado)) FILTER (WHERE data_entrega > prazo_estimado) AS atraso
FROM orders.decisoes_compra
WHERE status = 'ENTREGUE'
  AND decidido_em >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY laboratorio_id;

📊 Analytics — Dashboards e Relatórios
Views Materializadas
1. mv_economia_mensal
Propósito: Quanto economizamos vs preço de tabela.
sqlCREATE MATERIALIZED VIEW analytics.mv_economia_mensal AS
SELECT 
  DATE_TRUNC('month', decidido_em) AS mes,
  laboratorio_id,
  lab.nome AS laboratorio_nome,
  COUNT(*) AS total_decisoes,
  SUM(preco_final) AS valor_pago,
  SUM(pb.preco_tabela) AS valor_tabela,
  SUM(pb.preco_tabela - preco_final) AS economia_total,
  ROUND(
    (SUM(pb.preco_tabela - preco_final) / NULLIF(SUM(pb.preco_tabela), 0)) * 100, 
    2
  ) AS economia_pct
FROM orders.decisoes_compra dc
JOIN suppliers.laboratorios lab ON lab.id = dc.laboratorio_id
JOIN commercial.precos_base pb ON pb.produto_lab_id = dc.produto_lab_id
WHERE decidido_em >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY mes, laboratorio_id, lab.nome
ORDER BY mes DESC, economia_total DESC;
Refresh: Diário (cron às 02:00).

2. mv_ranking_criterios
Propósito: Quais labs ganham mais em cada critério.
sqlCREATE MATERIALIZED VIEW analytics.mv_ranking_criterios AS
SELECT 
  criterio,
  laboratorio_id,
  lab.nome AS laboratorio_nome,
  COUNT(*) AS vezes_escolhido,
  ROUND(AVG(score_atribuido), 2) AS score_medio,
  ROUND(AVG(preco_final), 2) AS preco_medio,
  ROUND(AVG(prazo_estimado_dias), 1) AS prazo_medio
FROM orders.decisoes_compra dc
JOIN suppliers.laboratorios lab ON lab.id = dc.laboratorio_id
WHERE decidido_em >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY criterio, laboratorio_id, lab.nome
ORDER BY criterio, vezes_escolhido DESC;

Queries de Dashboard (tempo real)
Top 5 Labs (último mês)
sqlSELECT 
  lab.nome,
  COUNT(*) AS pedidos,
  SUM(preco_final) AS faturamento,
  ROUND(AVG(prazo_estimado_dias), 1) AS prazo_medio
FROM orders.decisoes_compra dc
JOIN suppliers.laboratorios lab ON lab.id = dc.laboratorio_id
WHERE decidido_em >= DATE_TRUNC('month', CURRENT_DATE)
  AND tenant_id = :tenant_id
GROUP BY lab.nome
ORDER BY pedidos DESC
LIMIT 5;
Evolução de Decisões (12 meses)
sqlSELECT 
  DATE_TRUNC('month', decidido_em) AS mes,
  criterio,
  COUNT(*) AS total
FROM orders.decisoes_compra
WHERE decidido_em >= CURRENT_DATE - INTERVAL '12 months'
  AND tenant_id = :tenant_id
GROUP BY mes, criterio
ORDER BY mes, criterio;

🔧 Operacional — Deploy e Manutenção
Ambientes
AmbienteSupabase ProjectVercelURLdevdecisor-devpreview branchesdev.decisor.appstagingdecisor-stagingstaging branchstaging.decisor.appproddecisor-prodmain branchapp.decisor.com

CI/CD Pipeline (GitHub Actions)
Workflow: Backend (DB Migrations)
yamlname: DB Migrations

on:
  push:
    branches: [main, staging, dev]
    paths:
      - 'database/**'

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Supabase CLI
        run: npm install -g supabase
      
      - name: Run Migrations
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_TOKEN }}
          SUPABASE_PROJECT_ID: ${{ secrets.PROJECT_ID }}
        run: |
          supabase db push --project-ref $SUPABASE_PROJECT_ID
      
      - name: Run Tests
        run: |
          npm run test:db
Workflow: Frontend
yamlname: Deploy Frontend

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Lint
        run: npm run lint
      
      - name: Type Check
        run: npm run check
      
      - name: Build
        env:
          VITE_SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          VITE_SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
        run: npm run build
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'

Estratégia de Migrations
Estrutura de diretórios:
database/
├─ migrations/
│  ├─ 001_initial_schemas.sql
│  ├─ 002_lens_catalog_tables.sql
│  ├─ 003_suppliers_tables.sql
│  ├─ 004_commercial_tables.sql
│  ├─ 005_rls_policies.sql
│  ├─ 006_public_views.sql
│  └─ 007_rpc_functions.sql
├─ seeds/
│  ├─ dev/
│  │  ├─ 01_tenants.sql
│  │  ├─ 02_marcas.sql
│  │  └─ 03_lentes_sample.sql
│  └─ prod/
│     └─ 01_tenants_only.sql
└─ tests/
   ├─ rls_tests.sql
   └─ ranking_tests.sql
Regras:

Migrations são imutáveis (nunca editar após merge)
Sempre UP e DOWN (rollback)
Testar em dev → staging → prod
Zero downtime (usar transações)


Monitoramento
Métricas-chave (Supabase Dashboard)

DB Connections: < 80% do pool
Query Performance: p95 < 500ms
RLS Overhead: < 20ms por query
Storage: < 80% do limite

Alertas (PagerDuty / Slack)
yamlalerts:
  - name: "RPC Timeout"
    condition: "p95 > 5000ms"
    severity: "critical"
  
  - name: "High DB CPU"
    condition: "cpu > 80% for 5min"
    severity: "warning"
  
  - name: "Failed Decisões"
    condition: "error_rate > 1%"
    severity: "critical"

🛡️ Segurança — Checklist Completo
Banco de Dados

 RLS habilitado em TODAS as tabelas
 Policies por tenant_id
 Views com security_invoker
 RPCs com security_invoker (quando possível)
 search_path fixo em funções
 GRANT mínimo (somente service_role em privadas)
 Audit log em decisoes_compra

Aplicação

 JWT validado em todas as requisições
 CORS restrito (apenas domínios permitidos)
 Rate limiting (Supabase: 100 req/s por IP)
 Input validation (Zod schemas)
 XSS prevention (Svelte escapa por padrão)
 CSRF tokens (SvelteKit CSRF protection)

Infraestrutura

 HTTPS obrigatório (Vercel/Supabase padrão)
 Secrets em variáveis de ambiente (nunca git)
 Backup automático (Supabase daily)
 Logs centralizados (Supabase Logs)
 2FA obrigatório para admins

LGPD/Compliance

 Minimização de dados (quase zero PII)
 Auditoria de acesso (quem viu o quê)
 Consentimento (termos de uso)
 Direito ao esquecimento (soft delete)
 Portabilidade (export CSV)


📋 Roadmap de Implementação
Sprint 0: Setup (1 semana)
Infraestrutura

 Criar 3 projetos Supabase (dev/staging/prod)
 Configurar Vercel (deploy automático)
 Setup GitHub Actions (CI/CD)
 Criar .env.example e documentar secrets

Repositório

 Estrutura de pastas (database/, apps/)
 Configurar ESLint + Prettier + Husky
 README com instruções de setup local


Sprint 1: Fundação DB (1 semana)
Schemas e Tabelas Básicas

 Migration 001: Criar schemas (lens_catalog, suppliers, commercial, logistics, meta_system, orders)
 Migration 002: Tabela meta_system.tenants
 Migration 003: Tabela lens_catalog.lentes
 Migration 004: Tabela lens_catalog.marcas
 Migration 005: Tabela suppliers.laboratorios
 Migration 006: Tabela suppliers.produtos_laboratorio
 Migration 007: Tabela commercial.precos_base
 Migration 008: Tabela orders.decisoes_compra

Seeds

 Inserir 1 tenant de teste
 Inserir 3 marcas (Essilor, Hoya, Zeiss)
 Inserir 3 labs
 Inserir 10 lentes canônicas
 Inserir 30 produtos_laboratorio (3 labs × 10 lentes)
 Inserir preços base


Sprint 2: RLS e Views (1 semana)
Segurança

 Migration 009: RLS ON em todas as tabelas
 Migration 010: Policies tenant_isolation
 Testes manuais de RLS (tentar acessar tenant errado)

Views Públicas

 Migration 011: public.vw_lentes_catalogo
 Migration 012: public.vw_ranking_opcoes
 Testes: SELECT nas views com diferentes tenants


Sprint 3: RPCs (1 semana)
Funções

 Migration 013: public.rpc_buscar_lente()
 Migration 014: public.rpc_rank_opcoes()
 Migration 015: public.rpc_confirmar_decisao()

Testes SQL

 Testar rpc_buscar_lente com diferentes queries
 Testar rpc_rank_opcoes com 3 critérios
 Testar rpc_confirmar_decisao (INSERT real)


Sprint 4: Frontend Base (2 semanas)
Setup SvelteKit

 npm create svelte@latest
 Instalar Tailwind CSS
 Instalar shadcn-svelte (ou Skeleton UI)
 Configurar Supabase Client

Auth

 Layout com header + nav
 Login page (Supabase Auth)
 Logout
 Protected routes (+layout.server.ts)

Telas Básicas

 / — Dashboard (placeholder)
 /buscar — Busca lente (input simples)
 /ranking/[lenteId] — Tabela ranking (mock)
 /historico — Lista decisões (mock)


Sprint 5: Integração Frontend ↔ Backend (2 semanas)
API Wrappers

 lib/api/lentes.ts → rpc_buscar_lente
 lib/api/ranking.ts → rpc_rank_opcoes
 lib/api/decisao.ts → rpc_confirmar_decisao

Componentes

 SearchLente.svelte (autosuggest real)
 TabelaRanking.svelte (bind dados reais)
 CardFornecedor.svelte (destaque top 3)
 ModalConfirmacao.svelte (confirmar decisão)

UX

 Loading states
 Error handling (toast notifications)
 Validação de formulários (Zod)


Sprint 6: MVP Completo (1 semana)
Fluxo End-to-End

 Buscar lente → Selecionar → Ver ranking → Confirmar → Ver histórico
 Testar com 3 usuários reais (UAT)
 Coletar feedback

Refinamentos

 Ajustar UX conforme feedback
 Corrigir bugs críticos
 Performance (indexação adicional se necessário)


Sprint 7: Descontos (1 semana) [Opcional MVP]

 Tabela commercial.descontos
 Lógica de aplicação (prioridade, escopo)
 Atualizar vw_ranking_opcoes (incluir descontos)
 Atualizar RPC rpc_rank_opcoes
 UI: Mostrar "de X por Y" (preço tacha
Tentar novamenteJContinuarEditar📐 Blueprint Completo — Sistema Decisor de Lentes (Continuação Final)

📋 Roadmap de Implementação (continuação)
Sprint 7: Descontos (1 semana) [Opcional MVP] (continuação)

 UI: Mostrar "de X por Y" (preço tachado)
 Badge de "Promoção ativa"
 Admin: CRUD de descontos (futuro backoffice)


Sprint 8: Logistics e Prazos (1 semana)
Backend

 Tabela logistics.tabela_prazos
 Integrar com vw_ranking_opcoes
 Adicionar filtro por região no RPC

Frontend

 Dropdown "Região de entrega"
 Filtro "Prazo máximo"
 Badge de "Entrega expressa" (< 5 dias)


Sprint 9: Scoring e Qualidade (1 semana)
Backend

 Tabela scoring.metricas_laboratorio
 Inserir dados históricos simulados (seed)
 Integrar score_qualidade no ranking

Frontend

 Ícones de qualidade (⭐⭐⭐⭐⭐)
 Tooltip com detalhes (SLA, taxa refação)
 Filtro "Apenas labs confiáveis" (score > 80)


Sprint 10: Analytics Básico (1 semana)
Views Materializadas

 analytics.mv_economia_mensal
 analytics.mv_ranking_criterios
 Cron job (pg_cron) para refresh diário

Dashboard

 Gráfico: Economia vs Tabela (últimos 6 meses)
 Top 5 labs mais escolhidos
 Distribuição por critério (pizza chart)
 Tempo médio de decisão (futuro: analytics.js)


Sprint 11: Histórico e Auditoria (1 semana)
Backend

 Query paginada em orders.decisoes_compra
 Filtros: data, lab, critério, usuário

Frontend

 Tabela com ordenação e busca
 Export CSV (client-side)
 Modal de detalhes (payload completo)
 Timeline visual (futuro)


Sprint 12: Edge Function — Integração DCL (2 semanas)
Backend

 Tabela meta_system.outbox (event sourcing)
 Trigger em decisoes_compra → INSERT outbox
 Edge Function webhook_processor

 Pooling outbox (a cada 30s)
 GET dados completos da decisão
 POST Desenrola DCL
 Retry com backoff exponencial
 UPDATE outbox (status, tentativas, erro)



Logging

 Tabela meta_system.webhook_logs
 UI: Painel de webhooks (status, latência)

Testes

 Mock do endpoint DCL
 Testar retry em falha
 Testar timeout


Sprint 13: Refinamento e Estabilização (1 semana)

 Code review completo
 Testes E2E (Playwright)
 Performance testing (k6 ou Artillery)
 Documentação técnica (ADRs)
 Runbook operacional


Sprint 14: Beta Fechado (2 semanas)

 Onboarding de 3-5 clientes piloto
 Treinamento (vídeos + docs)
 Suporte direto (Slack/WhatsApp)
 Coleta de métricas de uso (Mixpanel/PostHog)
 Iteração rápida (hotfixes)


Sprint 15: Lançamento (1 semana)

 Checklist de produção (security audit)
 Backup e disaster recovery testados
 Monitoramento ativo (alertas configurados)
 Comunicação de lançamento
 Suporte 24/7 (primeira semana)


🎯 Critérios de Sucesso (Métricas)
KPIs de Produto
MétricaTarget MVPTarget 3 mesesTempo médio de decisão< 5 min< 2 minTaxa de conversão (busca → decisão)> 60%> 80%Economia média por decisão> 10%> 15%NPS do produto> 50> 70Decisões por usuário/mês> 20> 50
KPIs Técnicos
MétricaSLOUptime99.5%P95 response time (RPC)< 500msP95 page load< 2sError rate< 0.1%Zero data breach100%

🧪 Estratégia de Testes
Testes Unitários (SQL)
Arquivo: database/tests/rls_tests.sql
sql-- Teste: RLS bloqueia acesso cross-tenant
BEGIN;
  SET LOCAL role TO authenticated;
  SET LOCAL request.jwt.claims TO '{"tenant_id": "tenant-A"}';
  
  -- Deve retornar apenas dados do tenant A
  SELECT COUNT(*) FROM lens_catalog.lentes; -- Esperado: 10
  
  -- Tentar acessar tenant B (deve falhar)
  SET LOCAL request.jwt.claims TO '{"tenant_id": "tenant-B"}';
  SELECT COUNT(*) FROM lens_catalog.lentes; -- Esperado: 0
ROLLBACK;
Arquivo: database/tests/ranking_tests.sql
sql-- Teste: Ranking retorna top 3
BEGIN;
  SET LOCAL role TO authenticated;
  SET LOCAL request.jwt.claims TO '{"tenant_id": "tenant-test"}';
  
  -- Chama RPC
  SELECT * FROM public.rpc_rank_opcoes(
    'lente-uuid-test',
    'URGENCIA',
    '{}'::jsonb
  );
  
  -- Valida resultado
  -- Esperado: 3 linhas, rank_posicao = 1, 2, 3
  -- Esperado: rank 1 tem menor prazo_dias
ROLLBACK;

Testes de Integração (Frontend)
Ferramenta: Playwright
typescript// tests/e2e/ranking.spec.ts
import { test, expect } from '@playwright/test';

test('Fluxo completo: Busca → Ranking → Decisão', async ({ page }) => {
  // Login
  await page.goto('/login');
  await page.fill('[name="email"]', 'teste@decisor.app');
  await page.fill('[name="password"]', 'senha123');
  await page.click('button[type="submit"]');
  
  // Buscar lente
  await page.goto('/buscar');
  await page.fill('[name="busca"]', 'Varilux');
  await page.waitForSelector('[role="option"]');
  await page.click('[role="option"]:first-child');
  
  // Ver ranking
  await expect(page).toHaveURL(/\/ranking\/.+/);
  await page.selectOption('[name="criterio"]', 'URGENCIA');
  await page.waitForSelector('[data-testid="card-fornecedor"]');
  
  // Confirmar decisão
  await page.click('[data-testid="btn-confirmar"]:first-child');
  await page.click('[data-testid="modal-confirmar-ok"]');
  
  // Validar redirecionamento
  await expect(page).toHaveURL('/historico');
  await expect(page.locator('text=Decisão confirmada')).toBeVisible();
});

Testes de Performance
Ferramenta: k6
javascript// tests/load/ranking.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 10 },  // Ramp up
    { duration: '1m', target: 50 },   // Stay at 50 users
    { duration: '30s', target: 0 },   // Ramp down
  ],
  thresholds: {
    'http_req_duration': ['p(95)<500'], // 95% < 500ms
    'http_req_failed': ['rate<0.01'],   // < 1% falhas
  },
};

export default function () {
  const url = 'https://api.decisor.app/rest/v1/rpc/rpc_rank_opcoes';
  const payload = JSON.stringify({
    p_lente_id: 'uuid-lente-test',
    p_criterio: 'NORMAL',
    p_filtros: {}
  });
  
  const params = {
    headers: {
      'Content-Type': 'application/json',
      'apikey': __ENV.SUPABASE_ANON_KEY,
    },
  };
  
  const res = http.post(url, payload, params);
  
  check(res, {
    'status 200': (r) => r.status === 200,
    'tem resultados': (r) => JSON.parse(r.body).length > 0,
    'response < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}

📚 Documentação Técnica
ADRs (Architecture Decision Records)
ADR-001: Por que Supabase?
Status: Aceito
Contexto: Precisamos de backend rápido, RLS nativo, auth integrado.
Decisão: Usar Supabase (Postgres + RLS + Edge Functions).
Consequências:

✅ Desenvolvimento mais rápido (infra pronta)
✅ RLS nativo (segurança por default)
❌ Vendor lock-in (mitigado: Postgres padrão, fácil migrar)


ADR-002: Por que SvelteKit?
Status: Aceito
Contexto: Precisamos de framework moderno, rápido, com SSR opcional.
Decisão: SvelteKit + Vite.
Consequências:

✅ Bundle menor (menos JS no cliente)
✅ DX excelente (reatividade simples)
❌ Ecossistema menor vs React (mitigado: libs principais existem)


ADR-003: Por que 3 camadas de SKU?
Status: Aceito
Contexto: Labs usam códigos próprios, precisamos normalizar.
Decisão: sku_laboratorio (deles) → sku_fantasia (comercial) → sku_canonico (técnico).
Consequências:

✅ Flexibilidade (labs podem mudar SKUs)
✅ Migração facilitada (mapeamento desacoplado)
❌ Complexidade adicional (mais tabelas)


ADR-004: Por que Views em vez de Queries diretas?
Status: Aceito
Contexto: Frontend não deve conhecer estrutura interna do DB.
Decisão: Expor apenas views e RPCs em public.
Consequências:

✅ Desacoplamento (schemas internos podem mudar)
✅ Segurança (RLS aplicado nas views)
❌ Overhead mínimo (views não materializadas são leves)


ADR-005: Por que JSONB para specs_tecnicas?
Status: Aceito
Contexto: Lentes têm atributos muito variados.
Decisão: Campo JSONB flexível + índice GIN.
Consequências:

✅ Extensibilidade (novos atributos sem migration)
✅ Queries eficientes (GIN index)
❌ Schema menos rígido (validar no app)


Glossário de Domínio
TermoDefiniçãoLente CanônicaProduto técnico normalizado, imutável, base de comparaçãoSKU LaboratórioCódigo nativo usado pelo laboratório em seu catálogoSKU FantasiaCódigo comercial humanizado, criado por nós para facilitar comunicaçãoSKU CanônicoIdentificador técnico único interno (ex: LENS-0001-ESS-VLX-X-167-HC-AR-BLUE)Produto LabInstância de uma lente canônica no catálogo de um laboratório específicoDecisão de CompraRegistro imutável da escolha de fornecedor para uma lenteCritérioPerfil de decisão (URGENCIA, NORMAL, ESPECIAL) com pesos específicosScore PonderadoNota final (0-100) calculada por fórmula de pesos aplicados às dimensõesRLSRow Level Security — firewall de dados no PostgresTenantCliente/organização isolada logicamente no sistema multi-tenant

🚨 Troubleshooting — Problemas Comuns
Problema: RPC retorna vazio
Sintoma: rpc_rank_opcoes() retorna array vazio.
Causas possíveis:

RLS bloqueando (tenant_id errado no JWT)
Nenhum preço vigente para a lente
Labs inativos ou produtos indisponíveis

Debug:
sql-- Checar JWT
SELECT auth.jwt() ->> 'tenant_id';

-- Checar se existem dados
SELECT COUNT(*) FROM public.vw_ranking_opcoes 
WHERE lente_id = 'uuid-problematico';

-- Desabilitar RLS temporariamente (só em dev!)
SET ROLE postgres;
ALTER TABLE lens_catalog.lentes DISABLE ROW LEVEL SECURITY;

Problema: Ranking sempre retorna mesmo lab
Sintoma: Lab X sempre em 1º lugar, independente do critério.
Causas possíveis:

Fórmula de normalização incorreta (divisão por zero)
Apenas 1 lab tem preço para aquela lente
Pesos não sendo aplicados corretamente

Debug:
sql-- Ver scores não normalizados
SELECT 
  laboratorio_nome,
  preco_tabela,
  prazo_medio,
  score_qualidade,
  -- Normalização manual
  100 - (preco_tabela / MAX(preco_tabela) OVER() * 100) AS score_preco_norm
FROM public.vw_ranking_opcoes
WHERE lente_id = 'uuid-teste';

Problema: Decisão não grava
Sintoma: rpc_confirmar_decisao() retorna erro ou null.
Causas possíveis:

JWT sem claim sub (user_id)
FK constraint violation (lente_id não existe)
Trigger falhando (se houver)

Debug:
sql-- Ver payload completo
SELECT * FROM orders.decisoes_compra 
ORDER BY created_at DESC 
LIMIT 1;

-- Testar INSERT manual
INSERT INTO orders.decisoes_compra (
  tenant_id, lente_id, laboratorio_id, produto_lab_id,
  criterio, preco_final, prazo_estimado_dias, decidido_por
) VALUES (
  'tenant-uuid', 'lente-uuid', 'lab-uuid', 'prod-uuid',
  'NORMAL', 350.00, 5, 'user-uuid'
);

Problema: Views lentas (> 1s)
Sintoma: vw_ranking_opcoes demora muito.
Causas possíveis:

Falta de índices
JOIN cartesiano acidental
RLS com query plan ruim

Solução:
sql-- Analisar query plan
EXPLAIN ANALYZE 
SELECT * FROM public.vw_ranking_opcoes 
WHERE lente_id = 'uuid-teste' 
  AND tenant_id = 'tenant-uuid';

-- Adicionar índices compostos
CREATE INDEX idx_produtos_lab_lente_tenant 
ON suppliers.produtos_laboratorio(lente_id, tenant_id) 
WHERE disponivel = true;

-- Materializar se necessário
CREATE MATERIALIZED VIEW analytics.mv_ranking_cache AS
SELECT * FROM public.vw_ranking_opcoes;

🎓 Guia de Onboarding — Novos Desenvolvedores
Setup Local (30 min)
1. Pré-requisitos
bash# Instalar Node.js 18+
node --version  # >= 18

# Instalar Supabase CLI
npm install -g supabase

# Instalar Git
git --version
2. Clone e Install
bashgit clone https://github.com/empresa/decisor-lentes.git
cd decisor-lentes
npm install
3. Configurar Ambiente
bash# Copiar .env
cp .env.example .env

# Editar com suas credenciais Supabase
nano .env
.env:
VITE_SUPABASE_URL=https://xyz.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc...
4. Rodar DB Local (opcional)
bashsupabase start
supabase db reset  # Aplica migrations + seeds
5. Rodar Frontend
bashnpm run dev
# Acesse http://localhost:5173
6. Login de Teste
Email: dev@decisor.app
Senha: dev123
Tenant: tenant-dev

Estrutura de Código — Mapa Mental
decisor-lentes/
│
├─ database/          # ← BACKEND (SQL)
│  ├─ migrations/     # Schemas, tabelas, RLS, views, RPCs
│  ├─ seeds/          # Dados iniciais (tenants, lentes)
│  └─ tests/          # Testes SQL (RLS, ranking)
│
├─ apps/
│  └─ decisor-lentes/ # ← FRONTEND (SvelteKit)
│     ├─ src/
│     │  ├─ lib/
│     │  │  ├─ supabase.ts      # Cliente Supabase
│     │  │  ├─ stores/          # Estado global (session, ranking)
│     │  │  └─ api/             # Wrappers RPCs
│     │  ├─ routes/             # Páginas (file-based routing)
│     │  └─ components/         # Componentes reutilizáveis
│     └─ static/                # Assets estáticos
│
├─ .github/
│  └─ workflows/      # CI/CD (migrations, deploy)
│
└─ docs/              # Documentação adicional
   ├─ ADRs/           # Architecture Decision Records
   ├─ API.md          # Docs das views/RPCs
   └─ DEPLOYMENT.md   # Guia de deploy

Fluxo de Contribuição

Pegar issue no GitHub Projects
Criar branch: git checkout -b feat/ranking-filtros
Desenvolver (migrations OU frontend, nunca misturar)
Testar localmente: npm run test + testes manuais
Commit: git commit -m "feat: adicionar filtro por região"
Push: git push origin feat/ranking-filtros
PR: Preencher template, marcar reviewer
Review: Aguardar aprovação (1+ approvals)
Merge: Squash and merge → delete branch
Deploy automático: GitHub Actions → Vercel/Supabase


🎬 Conclusão — Próximos Passos
Você tem agora:
✅ Arquitetura completa (schemas, views, RPCs, frontend)
✅ Estratégia de 3 SKUs (lab → fantasia → canônico)
✅ Motor de ranking (multi-critério com pesos)
✅ Segurança (RLS, tenant isolation, auditoria)
✅ Roadmap detalhado (15 sprints)
✅ Testes e monitoramento (E2E, performance, alertas)
✅ Troubleshooting (problemas comuns + soluções)
✅ Onboarding (setup dev em 30min)

Decisão Imediata Necessária:
Você quer começar com qual sprint?
Opção A — Sprint 0 + 1 (Fundação Completa):

Eu gero os arquivos:

database/migrations/001-008_*.sql (schemas + tabelas)
database/seeds/dev/*.sql (dados de teste)
.env.example
README.md (setup instructions)
apps/decisor-lentes/package.json (deps SvelteKit)



Opção B — Sprint 2 + 3 (RLS + Views + RPCs):

Assumo que Sprint 1 está pronto
Gero:

database/migrations/009-015_*.sql (RLS, views, RPCs)
database/tests/*.sql (testes RLS e ranking)



Opção C — Sprint 4 + 5 (Frontend Completo):

Assumo que backend (Sprints 1-3) está pronto
Gero:

Estrutura completa SvelteKit
Componentes (SearchLente, TabelaRanking, etc.)
API wrappers
Rotas



Opção D — Quero discutir alguma parte específica antes:

Motor de regras (descontos complexos)?
Estratégia de importação de catálogos?
Integração DCL em detalhes?
Analytics e relatórios?

