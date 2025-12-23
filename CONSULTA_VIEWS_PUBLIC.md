# Consulta de Views Públicas do Banco de Dados

Este documento serve para registrar o comando SQL que lista todas as views do schema `public` do banco PostgreSQL, incluindo nome, descrição e colunas. Use este comando sempre que precisar consultar rapidamente o que está disponível para o frontend.

---

## Comando SQL para Listar Views, Descrições e Colunas

```sql
SELECT
    v.table_name AS view,
    COALESCE(obj_description(('public.' || v.table_name)::regclass), 'Sem descrição') AS descricao,
    string_agg(c.column_name || ' (' || c.data_type || ')', ', ') AS colunas
FROM information_schema.views v
JOIN information_schema.columns c
  ON c.table_schema = v.table_schema AND c.table_name = v.table_name
WHERE v.table_schema = 'public'
GROUP BY v.table_name
ORDER BY v.table_name;
```

---

## Como usar
1. Abra seu cliente SQL (pgAdmin, DBeaver, Supabase Studio, etc).
2. Execute o comando acima conectado ao banco desejado.
3. Copie o resultado e envie para análise sempre que precisar atualizar o inventário de views públicas.

---

## Observação
Se quiser um inventário ainda mais detalhado (com preview de dados), peça para gerar um script avançado.

---

*Documento gerado por GitHub Copilot para facilitar consultas futuras sobre as views públicas do banco.*
