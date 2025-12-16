# Investigation - Dados do Banco Real

Esta pasta contém os dados extraídos do banco de dados real para análise e migração.

## Estrutura

```
investigation/
├── README.md                    # Este arquivo
├── schemas/                     # Estrutura dos schemas
├── tables/                      # Definições das tabelas
├── data/                        # Dados exportados
├── queries/                     # Queries de investigação
└── analysis/                    # Análises e relatórios
```

## Como Adicionar Dados

1. **Exportar Schema**
   ```sql
   -- Listar todos os schemas
   SELECT schema_name 
   FROM information_schema.schemata 
   WHERE schema_name NOT IN ('pg_catalog', 'information_schema');
   ```

2. **Exportar Estrutura de Tabelas**
   ```sql
   -- Para cada schema
   SELECT 
       table_schema,
       table_name,
       column_name,
       data_type,
       is_nullable
   FROM information_schema.columns
   WHERE table_schema = 'public'
   ORDER BY table_schema, table_name, ordinal_position;
   ```

3. **Exportar Dados**
   ```sql
   -- Copiar para CSV
   COPY (SELECT * FROM public.sua_tabela) 
   TO '/caminho/arquivo.csv' 
   WITH (FORMAT CSV, HEADER);
   ```

## Status da Migração

- [ ] Schemas identificados
- [ ] Tabelas mapeadas
- [ ] Dados extraídos
- [ ] Análise de relacionamentos
- [ ] Plano de migração criado

## Notas

Adicione aqui observações sobre o banco real que descobrir durante a investigação.
