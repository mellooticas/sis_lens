-- ============================================================================
-- SCRIPT: GERAR DESCRIÇÕES AUTOMÁTICAS PARA LENTES DE CONTATO
-- ============================================================================
-- Objetivo: Preencher a coluna 'descricao_curta' para produtos que estão sem descrição,
--           utilizando dados técnicos (Nome, Marca, Material, Tipo, Finalidade).
-- ============================================================================

BEGIN;

UPDATE contact_lens.lentes l
SET descricao_curta = CONCAT(
    'Lente de contato ', l.nome_produto, 
    ' da marca ', m.nome, '.',
    ' ',
    CASE 
        WHEN l.tipo_lente = 'diaria' THEN 'Descarte Diário'
        WHEN l.tipo_lente = 'quinzenal' THEN 'Descarte Quinzenal'
        WHEN l.tipo_lente = 'mensal' THEN 'Descarte Mensal'
        WHEN l.tipo_lente = 'anual' THEN 'Descarte Anual'
        ELSE l.tipo_lente::text
    END,
    ', produzida em ', 
    CASE 
        WHEN l.material = 'silicone_hidrogel' THEN 'Silicone Hidrogel' 
        WHEN l.material = 'hidrogel' THEN 'Hidrogel'
        ELSE replace(l.material::text, '_', ' ')
    END,
    '. ',
    'Ideal para ', 
    CASE 
        WHEN l.finalidade = 'visao_simples' THEN 'Miopia ou Hipermetropia'
        WHEN l.finalidade = 'torica' THEN 'Astigmatismo'
        WHEN l.finalidade = 'multifocal' THEN 'Presbiopia (Multifocal)'
        WHEN l.finalidade = 'cosmetica' THEN 'uso Estético'
        ELSE replace(l.finalidade::text, '_', ' ')
    END,
    '.'
)
FROM contact_lens.marcas m
WHERE l.marca_id = m.id
  AND (l.descricao_curta IS NULL OR l.descricao_curta = '');

COMMIT;
