-- ============================================================================
-- PASSO 4: Processar TODAS as lentes
-- ============================================================================

UPDATE lens_catalog.lentes
SET updated_at = NOW()
WHERE ativo = true
  AND grupo_canonico_id IS NULL;

-- VALIDAÇÃO COMPLETA
SELECT
  'Lentes Ativas' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.lentes
WHERE ativo = true

UNION ALL

SELECT
  'Lentes com Grupo' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.lentes
WHERE ativo = true AND grupo_canonico_id IS NOT NULL

UNION ALL

SELECT
  'Lentes Órfãs' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.lentes
WHERE ativo = true AND grupo_canonico_id IS NULL

UNION ALL

SELECT
  'Grupos Criados' as metrica,
  COUNT(*)::TEXT as total
FROM lens_catalog.grupos_canonicos
WHERE ativo = true;



Error: Failed to run sql query: ERROR: 23505: duplicate key value violates unique constraint "grupos_canonicos_nome_grupo_key" DETAIL: Key (nome_grupo)=(Lente CR39 1.67 Visao simples +UV [-13.00/9.00 | -6.00/0.00]) already exists. CONTEXT: SQL statement "INSERT INTO lens_catalog.grupos_canonicos ( slug, nome_grupo, tipo_lente, material, indice_refracao, categoria_predominante, grau_esferico_min, grau_esferico_max, grau_cilindrico_min, grau_cilindrico_max, adicao_min, adicao_max, tratamento_antirreflexo, tratamento_antirrisco, tratamento_uv, tratamento_blue_light, tratamento_fotossensiveis, preco_minimo, preco_maximo, preco_medio, total_lentes, total_marcas, peso, is_premium, ativo ) VALUES ( v_slug, v_nome_grupo, p_tipo_lente, p_material, p_indice, p_categoria, p_esferico_min, p_esferico_max, p_cilindrico_min, p_cilindrico_max, p_adicao_min, p_adicao_max, p_tem_ar, p_tem_antirrisco, p_tem_uv, p_tem_blue, p_tratamento_foto::TEXT, 0, 0, 0, 0, 0, -- estatísticas iniciais 50, false, true -- peso padrão, não premium, ativo ) RETURNING id" PL/pgSQL function lens_catalog.encontrar_ou_criar_grupo_canonico(lens_catalog.tipo_lente,lens_catalog.material_lente,lens_catalog.indice_refracao,lens_catalog.categoria_lente,numeric,numeric,numeric,numeric,numeric,numeric,boolean,boolean,boolean,boolean,lens_catalog.tratamento_foto) line 50 at SQL statement PL/pgSQL function lens_catalog.trigger_atualizar_grupo_canonico() line 21 at assignment



