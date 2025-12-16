-- ===============================================================
-- 🕵️ QUERIES DE INVESTIGAÇÃO DO BANCO DE DADOS (SIS LENS)
-- ===============================================================
-- Use estas queries para explorar os dados e validar se o frontend
-- tem acesso a tudo que precisa.

-- 1. VERIFICAR TENANTS (CLIENTES) ATIVOS
-- O sistema é multi-tenant. Tudo depende do tenant_id.
SELECT id, nome, slug, ativo, criado_em 
FROM meta_system.tenants;

| id                                   | nome              | slug              | ativo | criado_em                     |
| ------------------------------------ | ----------------- | ----------------- | ----- | ----------------------------- |
| 550e8400-e29b-41d4-a716-446655440000 | Óticas Taty Mello | oticas-taty-mello | true  | 2025-10-06 18:12:49.229712+00 | vamos usar somente este
| 229220bb-d480-4608-a07c-ae9ab5266caf | Ótica Demo        | demo              | true  | 2025-12-10 04:09:31.000236+00 |

-- 2. EXPLORAR O CATÁLOGO DE LENTES
-- Veja quais produtos estão disponíveis para recomendação.
SELECT 
    l.nome,
    m.nome as marca,
    l.familia,
    l.material,
    l.indice_refracao,
    l.tratamentos,
    l.preco_referencia -- (Se houver view/coluna computada)
FROM lens_catalog.lentes l
JOIN lens_catalog.marcas m ON l.marca_id = m.id
WHERE l.ativo = true
LIMIT 20;

-- 3. ENTENDER O MOTOR DE SCORING (CRITÉRIOS)
-- Estes são os pesos que o sistema usa para decidir qual lab é melhor.
SELECT 
    nome, 
    categoria, 
    peso, 
    descricao 
FROM scoring.criterios_scoring
WHERE ativo = true
ORDER BY peso DESC;

-- 4. VERIFICAR RANKING ATUAL DOS LABORATÓRIOS
-- Quem está ganhando? Top labs baseados no score calculado.
SELECT 
    l.nome_fantasia,
    s.score_geral,
    s.ranking_geral,
    s.nivel_qualificacao, -- GOLD, SILVER, ETC
    s.score_preco,
    s.score_qualidade,
    s.score_prazo
FROM scoring.scores_laboratorios s
JOIN suppliers.laboratorios l ON s.laboratorio_id = l.id
WHERE s.valido_ate >= CURRENT_DATE
ORDER BY s.ranking_geral ASC;

-- 5. INSPECIONAR DECISÕES RECENTES (HISTÓRICO)
-- O que os usuários estão buscando e o que o sistema recomendou?
SELECT 
    d.cliente_nome,
    d.criado_em,
    d.status,
    -- Detalhes da lente recomendada (via join se necessário, ou JSON da decisão)
    (SELECT nome FROM lens_catalog.lentes WHERE id = d.lente_recomendada_id) as lente_recomendada
FROM orders.decisoes_lentes d
ORDER BY d.criado_em DESC
LIMIT 10;

-- 6. DETALHE DE UMA DECISÃO (ALTERNATIVAS GERADAS)
-- Pega a decisão mais recente e mostra as opções que foram apresentadas (Rank 1, 2, 3...)
WITH ultima_decisao AS (
    SELECT id, cliente_nome FROM orders.decisoes_lentes ORDER BY criado_em DESC LIMIT 1
)
SELECT 
    ud.cliente_nome,
    a.posicao,
    a.tipo_alternativa, -- RECOMENDACAO, ALTERNATIVA
    a.percentual_adequacao,
    a.preco_final,
    l.nome as lente_nome,
    lab.nome_fantasia as lab_nome
FROM orders.alternativas_cotacao a
JOIN ultima_decisao ud ON a.decisao_id = ud.id
JOIN lens_catalog.lentes l ON a.lente_id = l.id
JOIN suppliers.laboratorios lab ON a.laboratorio_id = l.id -- Nota: Em orders.alternativas_cotacao tem lab_id
ORDER BY a.posicao;

-- 7. SIMULAR UMA BUSCA VIA API (COMO O FRONTEND FAZ)
-- Testa a função que o frontend usa para buscar lentes.
SELECT * FROM api.buscar_lentes(
    p_tipo_lente => 'PROGRESSIVA',
    p_limite => 5
);

-- 8. ANALYTICS - KPIS DO DASHBOARD
-- Veja os números crus que alimentam os cards do dashboard.
SELECT * FROM analytics.vw_dashboard_kpis;
