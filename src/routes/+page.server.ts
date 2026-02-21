/**
 * SIS Lens — Dashboard Principal
 * Dados reais de v_catalog_lenses + v_catalog_lens_groups
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const supabase = locals.supabase;

  const [lentesResult, gruposResult] = await Promise.all([
    supabase
      .from('v_catalog_lenses')
      .select('lens_type, is_premium, status, supplier_name, brand_name'),
    supabase
      .from('v_catalog_lens_groups')
      .select('id, is_active, is_premium')
  ]);

  const lentes = lentesResult.data ?? [];
  const grupos = gruposResult.data ?? [];

  // KPIs principais
  const total_lentes   = lentes.length;
  const lentes_ativas  = lentes.filter(l => l.status === 'active').length;
  const lentes_premium = lentes.filter(l => l.is_premium).length;
  const grupos_ativos  = grupos.filter(g => g.is_active).length;

  // Fornecedores/Labs e Marcas únicos
  const fornecedores = [...new Set(lentes.map(l => l.supplier_name).filter(Boolean))];
  const marcas       = [...new Set(lentes.map(l => l.brand_name).filter(Boolean))];

  // Distribuição por tipo de lente
  const por_tipo: Record<string, number> = {};
  lentes.forEach(l => {
    if (l.lens_type) por_tipo[l.lens_type] = (por_tipo[l.lens_type] || 0) + 1;
  });

  return {
    stats: {
      total_lentes,
      lentes_ativas,
      lentes_premium,
      total_standard:    lentes.filter(l => !l.is_premium).length,
      total_fornecedores: fornecedores.length,
      total_marcas:       marcas.length,
      grupos_ativos,
      por_tipo
    }
  };
};
