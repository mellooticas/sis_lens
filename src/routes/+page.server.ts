/**
 * SIS Lens — Dashboard Principal
 * Utiliza v_catalog_lens_stats para KPIs de alta performance
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const supabase = locals.supabase;

  // Busca estatísticas consolidadas
  const { data: stats } = await supabase
    .from('v_catalog_lens_stats')
    .select('*')
    .single();

  const { data: grupos } = await supabase
    .from('v_catalog_lens_groups')
    .select('id, is_active');

  const grupos_ativos = grupos?.filter(g => g.is_active).length || 0;

  // Distribuição por tipo de lente (mapeado do stats)
  const por_tipo: Record<string, number> = {
    'single_vision': stats?.total_visao_simples || 0,
    'multifocal': stats?.total_multifocal || 0,
    'bifocal': stats?.total_bifocal || 0,
    'reading': stats?.total_leitura || 0,
    'occupational': stats?.total_ocupacional || 0
  };

  return {
    stats: {
      total_lentes: stats?.total_lentes || 0,
      lentes_ativas: stats?.total_lentes || 0, // No banco novo, a view v_catalog_lenses já filtra ativas por padrão se necessário, ou usamos status
      lentes_premium: stats?.total_premium || 0,
      total_standard: (stats?.total_lentes || 0) - (stats?.total_premium || 0),
      total_fornecedores: stats?.total_fornecedores || 0,
      total_marcas: stats?.total_marcas || 0,
      grupos_ativos,
      por_tipo
    }
  };
};
