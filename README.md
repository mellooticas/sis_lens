# Clearix Lens — Catálogo Inteligente de Lentes Oftálmicas

> Sistema de gestão e consulta de catálogo de lentes para óticas, com engine canônica de equivalência, pricing por contrato e filtros avançados.

---

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Frontend | SvelteKit 2.5 + Svelte 5 + TypeScript |
| Estilo | Tailwind CSS v3 |
| Backend | Supabase (PostgreSQL 15 + Auth + RLS) |
| Deploy | Netlify (adapter-netlify) |

---

## Módulos do Catálogo

### `/lentes` — Catálogo Real
Todas as lentes físicas do pricing_book do tenant.

**Filtros disponíveis:**
- Busca por nome
- Tipo (Visão Simples, Multifocal, Bifocal, Ocupacional)
- Fornecedor (dinâmico)
- Marca (dinâmico)
- Material / Índice de refração (dinâmico)
- Linha (Standard / Premium)
- Tratamentos: Anti-Reflexo, Anti-Risco, UV, Blue Cut, Fotossensível, Polarizado

Cards clicáveis → `/lentes/[id]` com edição de preço (custo + sugerido).

---

### `/standard` — Conceitos Canônicos Standard
View: `v_canonical_lenses_pricing` — agrupa lentes equivalentes por física ótica.

**Filtros disponíveis:**
- Busca por nome canônico
- Tipo de lente
- Classe de material
- Tratamentos: AR, UV, Blue Cut, Fotossensível

Cards → `/standard/[id]` com lentes mapeadas clicáveis para `/lentes/[id]`.
Preço exibido: **Média** (`price_avg`).

---

### `/premium` — Conceitos Canônicos Premium
View: `v_canonical_lenses_premium_pricing` — mesma lógica, foco em alta tecnologia.

**Filtros disponíveis:** idênticos ao `/standard`.

Cards → `/premium/[id]` com lentes mapeadas clicáveis para `/lentes/[id]`.
Preço exibido: **Média** (`price_avg`).

---

### `/contato` — Lentes de Contato
View: `v_contact_lenses` — 226 lentes de contato (inseridas via migration 284).

**Filtros disponíveis:**
- Busca (nome ou marca)
- Marca (dinâmico)
- Tipo de descarte
- Finalidade (Visão Simples, Tórica, Multifocal, Cosmético, Terapêutico)
- Material
- Colorida / Estética
- Proteção UV

Cards → `/contato/[id]` com edição de preço.

---

## Arquitetura de Dados

### Schemas principais

```
catalog_lenses/
├── lenses                    # Lentes reais (com pricing_book)
├── contact_lenses            # Lentes de contato (226 registros)
├── brands                    # Marcas (ópticas + contato)
├── canonical_lenses          # Conceitos canônicos
├── canonical_lens_mappings   # Mapeamento canônico → lente real
└── stg_contact_lens_import   # Staging ETL (233 linhas CSV)

inventory/
└── pricing_book              # Preços por tenant

iam/
└── tenants                   # Multi-tenant (tenant_id via JWT)
```

### Views públicas principais

| View | Uso |
|------|-----|
| `v_catalog_lenses` | Catálogo real com pricing + tratamentos |
| `v_catalog_contact_lenses` | Lentes de contato com dados técnicos |
| `v_contact_lenses` | View pública com COALESCE tenant |
| `v_canonical_lenses_pricing` | Canônicos standard com pricing agregado |
| `v_canonical_lenses_premium_pricing` | Canônicos premium com pricing agregado |

### RPCs de escrita

| RPC | Função |
|-----|--------|
| `rpc_update_lens_price` | Edita custo + preço sugerido de lente real |
| `rpc_update_contact_lens_price` | Edita custo + preço sugerido de lente de contato |
| `rpc_canonical_detail` | Retorna lentes mapeadas de um conceito canônico |
| `rpc_etl_contact_lenses_from_csv` | ETL do staging para contact_lenses |

Todas as RPCs usam `SECURITY DEFINER` + `COALESCE(current_tenant_id(), '00000000-...')` para compatibilidade com JWT admin (sem claim tenant_id).

---

## Regras de Negócio

- **Preço canônico**: exibido como `price_avg` (média de todas as lentes mapeadas), não `price_min`
- **Edição de preço**: permitida apenas em `/lentes/[id]` e `/contato/[id]` — páginas canônicas são somente leitura
- **Lentes de contato**: `status='draft'` no CSV original → mapeado para `'inactive'` (enum `inventory.record_status` não tem 'draft')
- **Multi-tenant**: todas as queries filtram por `tenant_id` via RLS + COALESCE

---

## Histórico de Migrations Relevantes

| Migration | O que fez |
|-----------|-----------|
| 214 | Cria `catalog_lenses.contact_lenses` |
| 217 | Cria ETL + staging + crosswalk de marcas |
| 263 | `TRUNCATE brands CASCADE` → apagou contact_lenses acidentalmente |
| 269 | Re-seed de lentes ópticas (sem re-seed de contato) |
| 277 | Views canônicas com pricing agregado |
| 278 | `rpc_canonical_detail` |
| 281 | View `v_contact_lenses` com COALESCE fix |
| 284 | Re-insert direto de 226 lentes de contato (bypass ETL) |
| 285 | RPCs de edição de preço |

---

## Quick Start

```bash
# 1. Instalar dependências
npm install

# 2. Configurar variáveis de ambiente
cp .env.example .env
# VITE_SUPABASE_URL=https://...supabase.co
# VITE_SUPABASE_ANON_KEY=...

# 3. Rodar em desenvolvimento
npm run dev
# http://localhost:5173

# 4. Build para produção
npm run build
```

---

## Estrutura de Rotas

```
src/routes/
├── /                        # Dashboard
├── /lentes                  # Catálogo real (filtros completos)
│   └── /[id]               # Detalhe + edição de preço
├── /standard                # Canônicos standard (filtros)
│   └── /[id]               # Detalhe canônico + lentes mapeadas
├── /premium                 # Canônicos premium (filtros)
│   └── /[id]               # Detalhe canônico + lentes mapeadas
└── /contato                 # Lentes de contato (filtros completos)
    └── /[id]               # Detalhe + edição de preço
```

---

## Padrão de Fetch (Client-Side)

Todas as páginas de catálogo usam fetch client-side para evitar problemas de SSR com JWT:

```
+page.server.ts  →  lê URL params apenas (sem queries ao DB)
+page.svelte     →  afterNavigate() → supabase client → fetch
```

---

Projeto privado — Clearix Lens © 2026
