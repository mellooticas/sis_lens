-- ===============================================================
-- 🔬 INVESTIGAÇÃO PROFUNDA (CÓDIGO FONTE E DEFINIÇÕES) - PUBLIC
-- ===============================================================

-- 1. VERIFICAR SE 'rpc_rank_opcoes' APENAS LE OU TAMBÉM GRAVA (INSERT)
-- Frontend precisa criar decisões. Se esta função não fizer INSERT, falta algo no Public.
SELECT prosrc as codigo_fonte 
FROM pg_proc 
WHERE proname = 'rpc_rank_opcoes';

| codigo_fonte                                                                                                                                                                                                                                                                                                                     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 
BEGIN
  RETURN QUERY
  SELECT 
    vo.laboratorio_id,
    vo.laboratorio_nome,
    vo.preco_com_desconto as preco_final,
    ROW_NUMBER() OVER (ORDER BY vo.laboratorio_id)::INTEGER as rank_posicao
  FROM public.vw_ranking_opcoes vo
  WHERE vo.lente_id = p_lente_id
  ORDER BY rank_posicao
  LIMIT 10;
END;
 |



-- 2. VERIFICAR SE 'vw_fornecedores_disponiveis' MOSTRA SCORES/BADGES
-- Frontend precisa mostrar "Ouro/Prata". Vamos ver o SQL da view.
SELECT definition 
FROM pg_views 
WHERE schemaname = 'public' 
  AND viewname = 'vw_fornecedores_disponiveis';

  | definition                                                                                                                                       |
| ------------------------------------------------------------------------------------------------------------------------------------------------ |
|  SELECT id AS laboratorio_id,
    ('Lab-'::text || (id)::text) AS nome,
    tenant_id
   FROM suppliers.laboratorios lab
  WHERE (ativo = true); |


-- 3. VERIFICAR SE EXISTE ALGUMA TRIGGER OU REGRA QUE SALVA AUTOMATICAMENTE
-- Talvez ao inserir em alguma view? (Pouco provável, mas possível)
SELECT * FROM information_schema.triggers WHERE event_object_schema = 'public';


| trigger_catalog | trigger_schema | trigger_name                | event_manipulation | event_object_catalog | event_object_schema | event_object_table | action_order | action_condition | action_statement                            | action_orientation | action_timing | action_reference_old_table | action_reference_new_table | action_reference_old_row | action_reference_new_row | created |
| --------------- | -------------- | --------------------------- | ------------------ | -------------------- | ------------------- | ------------------ | ------------ | ---------------- | ------------------------------------------- | ------------------ | ------------- | -------------------------- | -------------------------- | ------------------------ | ------------------------ | ------- |
| postgres        | public         | trigger_usuarios_updated_at | UPDATE             | postgres             | public              | usuarios           | 1            | null             | EXECUTE FUNCTION update_updated_at_column() | ROW                | BEFORE        | null                       | null                       | null                     | null                     | null    |
