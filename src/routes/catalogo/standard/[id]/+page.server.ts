/**
 * 📚 Detalhes Grupo Canônico Standard - Server Load
 * Novo banco: v_catalog_lens_groups (is_premium = false) + v_catalog_lenses
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';
import { error } from '@sveltejs/kit';
import type { VCatalogLensGroup, VCatalogLens } from '$lib/types/database-views';

export const load: PageServerLoad = async ({ params }) => {
  const grupoId = params.id;

  if (!grupoId) {
    throw error(400, 'ID do grupo não encontrado');
  }

  try {
    console.log('🔍 Buscando grupo standard:', grupoId);

    // Buscar grupo específico com validação is_premium = false
    let grupo: VCatalogLensGroup | null = null;
    const { data: grupoData, error: erroGrupo } = await supabase
      .from('v_catalog_lens_groups')
      .select('*')
      .eq('id', grupoId)
      .eq('is_premium', false)
      .single();

    if (erroGrupo || !grupoData) {
      // Fallback: derivar grupo de v_catalog_lenses
      console.warn('⚠ v_catalog_lens_groups indisponível, usando fallback');
      const { data: ref } = await supabase
        .from('v_catalog_lenses')
        .select('group_id, group_name, lens_type, material, refractive_index, is_premium, tenant_id, created_at, updated_at')
        .eq('group_id', grupoId)
        .eq('is_premium', false)
        .limit(1)
        .maybeSingle();

      if (!ref) {
        throw error(404, 'Grupo standard não encontrado');
      }

      grupo = {
        id: grupoId,
        tenant_id: ref.tenant_id,
        name: ref.group_name ?? grupoId,
        lens_type: ref.lens_type,
        material: ref.material,
        refractive_index: ref.refractive_index,
        is_premium: false,
        is_active: true,
        created_at: ref.created_at,
        updated_at: ref.updated_at
      };
    } else {
      grupo = grupoData as VCatalogLensGroup;
    }

    console.log('✅ Grupo encontrado:', grupo.name);

    // Buscar lentes do grupo
    console.log('🔍 Buscando lentes do grupo:', grupoId);
    const { data: lentes, error: erroLentes } = await supabase
      .from('v_catalog_lenses')
      .select('*')
      .eq('group_id', grupoId)
      .eq('status', 'active')
      .order('price_suggested', { ascending: true });

    if (erroLentes) {
      console.error('❌ Erro ao buscar lentes:', erroLentes);
      throw error(500, `Erro ao buscar lentes: ${erroLentes.message}`);
    }

    console.log('✅ Grupo Standard carregado:', {
      grupoId,
      nome: grupo.name,
      total_lentes: lentes?.length || 0
    });

    return {
      grupo,
      lentes: (lentes || []) as VCatalogLens[],
      sucesso: true
    };
  } catch (err) {
    console.error('❌ Erro ao carregar grupo standard:', err);
    throw error(500, 'Erro ao carregar detalhes do grupo');
  }
};
