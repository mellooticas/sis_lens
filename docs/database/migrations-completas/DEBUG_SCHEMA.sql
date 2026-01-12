-- SCRIPT DE INVESTIGAÇÃO DE ESQUEMA
-- Execute este script para listar todas as colunas da tabela orders.decisoes_lentes
-- e descobrir quais nomes de colunas estão realmente disponíveis.

SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'orders' 
  AND table_name = 'decisoes_lentes'
ORDER BY ordinal_position;


| column_name               | data_type                | is_nullable |
| ------------------------- | ------------------------ | ----------- |
| id                        | uuid                     | NO          |
| tenant_id                 | uuid                     | NO          |
| lente_recomendada_id      | uuid                     | NO          |
| laboratorio_escolhido_id  | uuid                     | NO          |
| criterio_usado            | USER-DEFINED             | NO          |
| preco_final               | numeric                  | NO          |
| prazo_estimado_dias       | integer                  | NO          |
| custo_frete               | numeric                  | YES         |
| score_atribuido           | numeric                  | YES         |
| motivo_decisao            | text                     | YES         |
| alternativas_consideradas | jsonb                    | YES         |
| status                    | USER-DEFINED             | YES         |
| decidido_por              | uuid                     | YES         |
| decidido_em               | timestamp with time zone | NO          |
| confirmado_em             | timestamp with time zone | YES         |
| entregue_em               | timestamp with time zone | YES         |
| observacoes               | text                     | YES         |


-- Também vamos checar a tabela de laboratórios
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'suppliers' 
  AND table_name = 'laboratorios'
ORDER BY ordinal_position;


| column_name           | data_type                | is_nullable |
| --------------------- | ------------------------ | ----------- |
| id                    | uuid                     | NO          |
| tenant_id             | uuid                     | NO          |
| nome_fantasia         | text                     | NO          |
| razao_social          | text                     | YES         |
| cnpj                  | text                     | YES         |
| contato_comercial     | jsonb                    | YES         |
| lead_time_padrao_dias | integer                  | YES         |
| atende_regioes        | ARRAY                    | YES         |
| ativo                 | boolean                  | NO          |
| criado_em             | timestamp with time zone | NO          |
| atualizado_em         | timestamp with time zone | NO          |

