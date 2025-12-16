-- Query para verificar a estrutura real da tabela scoring.scores_laboratorios
SELECT 
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'scoring' 
  AND table_name = 'scores_laboratorios'
ORDER BY ordinal_position;
