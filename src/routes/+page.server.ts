/**
 * SIS Lens — Dashboard Principal
 * Campos reais da v_catalog_lens_stats (migration 271 + 280):
 *   total, premium, economica, with_ar, with_blue, with_uv, with_photochromic,
 *   price_min, price_max, price_avg, suppliers_count, brands_count, materials_count
 *
 * Campos reais da v_catalog_lens_groups (migration 076):
 *   id, tenant_id, name, lens_type, material, refractive_index,
 *   is_premium, supplier_lab_id, created_at, updated_at
 *   (sem is_active — a view já filtra deleted_at IS NULL)
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const supabase = locals.supabase;

  const [statsResult, gruposResult, tiposResult] = await Promise.all([
    // Estatísticas consolidadas (migration 111)
    supabase.from('v_catalog_lens_stats').select('*').single(),
    // Contagem de grupos (view filtra deleted_at IS NULL, não tem is_active)
    supabase.from('v_catalog_lens_groups').select('id'),
    // Distribuição por tipo (lens_type da v_catalog_lenses)
    supabase.from('v_catalog_lenses').select('lens_type').eq('status', 'active'),
  ]);

  const stats = statsResult.data;
  const grupos_ativos = gruposResult.data?.length || 0;

  // Agregação por tipo no lado TypeScript
  const por_tipo: Record<string, number> = {};
  for (const row of tiposResult.data ?? []) {
    const tipo = row.lens_type ?? 'outros';
    por_tipo[tipo] = (por_tipo[tipo] || 0) + 1;
  }

  return {
    stats: {
      total_lentes:   stats?.total    || 0,
      lentes_ativas:  stats?.total    || 0,   // view já filtra status='active'
      lentes_premium: stats?.premium  || 0,
      total_standard: (stats?.total   || 0) - (stats?.premium || 0),
      com_ar:         stats?.with_ar  || 0,
      grupos_ativos,
      por_tipo,
    }
  };
};
