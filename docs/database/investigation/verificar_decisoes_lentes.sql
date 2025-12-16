-- Query para verificar a estrutura real da tabela orders.decisoes_lentes
SELECT 
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'orders' 
  AND table_name = 'decisoes_lentes'
ORDER BY ordinal_position;
