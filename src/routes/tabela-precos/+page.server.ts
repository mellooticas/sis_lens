/**
 * 💰 Tabela de Preços - Server Load
 * Novo banco: v_catalog_lenses
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';
import type { VCatalogLens } from '$lib/types/database-views';

export const load: PageServerLoad = async ({ url }) => {
  try {
    // Parâmetros de filtros
    const marca = url.searchParams.get('marca') || '';
    const tipo_lente = url.searchParams.get('tipo_lente') || '';
    const material = url.searchParams.get('material') || '';
    const indice = url.searchParams.get('indice') || '';
    const tratamento = url.searchParams.get('tratamento') || '';
    const preco_min = parseFloat(url.searchParams.get('preco_min') || '0');
    const preco_max = parseFloat(url.searchParams.get('preco_max') || '99999');
    const busca = url.searchParams.get('busca') || '';
    const pagina = parseInt(url.searchParams.get('pagina') || '1');
    const visualizacao = url.searchParams.get('view') || 'tabela';
    const limite = visualizacao === 'cards' ? 12 : 20;
    const offset = (pagina - 1) * limite;

    console.log('💰 Tabela de Preços: Carregando com filtros:', {
      marca, tipo_lente, material, indice, tratamento, preco_min, preco_max, busca, visualizacao
    });

    // 1. Query principal de lentes (v_catalog_lenses)
    let query = supabase
      .from('v_catalog_lenses')
      .select(`
        id, slug, sku, lens_name, brand_name, supplier_name, supplier_lab_id,
        lens_type, material, refractive_index, category,
        anti_reflective, anti_scratch, uv_filter, blue_light, photochromic, polarized,
        digital, free_form,
        spherical_min, spherical_max, cylindrical_min, cylindrical_max,
        addition_min, addition_max,
        price_cost, price_suggested,
        stock_available, lead_time_days,
        is_premium, status,
        created_at, updated_at
      `, { count: 'exact' });

    // 2. Aplicar filtros
    if (busca) {
      query = query.or(`lens_name.ilike.%${busca}%,brand_name.ilike.%${busca}%,sku.ilike.%${busca}%`);
    }

    if (marca) {
      query = query.eq('brand_name', marca);
    }

    if (tipo_lente) {
      query = query.eq('lens_type', tipo_lente);
    }

    if (material) {
      query = query.eq('material', material);
    }

    if (indice) {
      query = query.eq('refractive_index', parseFloat(indice));
    }

    // Filtro de tratamento (mapeamento para novo banco)
    if (tratamento) {
      const tratamentoMap: Record<string, string> = {
        ar: 'anti_reflective',
        antirrisco: 'anti_scratch',
        blue: 'blue_light',
        uv: 'uv_filter',
        polarizado: 'polarized',
        digital: 'digital',
        free_form: 'free_form'
      };
      const campo = tratamentoMap[tratamento];
      if (campo) {
        query = query.eq(campo, true);
      } else if (tratamento === 'fotossensivel' || tratamento === 'foto') {
        query = query.neq('photochromic', 'nenhum');
      }
    }

    query = query
      .gte('price_suggested', preco_min)
      .lte('price_suggested', preco_max)
      .order('brand_name', { ascending: true })
      .order('lens_name', { ascending: true })
      .range(offset, offset + limite - 1);

    const { data: lentes, count, error: queryError } = await query;

    if (queryError) {
      console.error('❌ Erro ao buscar lentes:', queryError);
      throw queryError;
    }

    // 3. Buscar opções para filtros (DISTINCT de v_catalog_lenses)
    const [marcasResult, tiposResult, materiaisResult, indicesResult] = await Promise.all([
      supabase.from('v_catalog_lenses').select('brand_name').not('brand_name', 'is', null).order('brand_name'),
      supabase.from('v_catalog_lenses').select('lens_type').not('lens_type', 'is', null).order('lens_type'),
      supabase.from('v_catalog_lenses').select('material').not('material', 'is', null).order('material'),
      supabase.from('v_catalog_lenses').select('refractive_index').not('refractive_index', 'is', null).order('refractive_index')
    ]);

    // 4. Processar opções para filtros
    const marcasUnicas = [...new Set(marcasResult.data?.map(m => m.brand_name).filter(Boolean))];
    const tiposUnicos = [...new Set(tiposResult.data?.map(t => t.lens_type).filter(Boolean))];
    const materiaisUnicos = [...new Set(materiaisResult.data?.map(m => m.material).filter(Boolean))];
    const indicesUnicos = [...new Set(indicesResult.data?.map(i => i.refractive_index).filter(Boolean))];

    // Tratamentos disponíveis no novo banco (fixo)
    const tratamentosUnicos = [
      { value: 'ar', label: 'Anti-Reflexo' },
      { value: 'blue', label: 'Blue Light' },
      { value: 'uv', label: 'Proteção UV' },
      { value: 'fotossensivel', label: 'Fotossensível' },
      { value: 'polarizado', label: 'Polarizado' },
      { value: 'digital', label: 'Digital' },
      { value: 'free_form', label: 'Free Form' },
      { value: 'antirrisco', label: 'Anti-Risco' }
    ];

    // 5. Estatísticas básicas
    const { data: statsData } = await supabase
      .from('v_catalog_lens_stats')
      .select('total_lenses, price_min, price_max, price_avg')
      .single();

    const totalPaginas = Math.ceil((count || 0) / limite);

    return {
      lentes: (lentes || []) as VCatalogLens[],
      total_resultados: count || 0,
      pagina_atual: pagina,
      total_paginas: totalPaginas,
      has_more: pagina < totalPaginas,
      visualizacao,
      filtros: {
        marca,
        tipo_lente,
        material,
        indice,
        tratamento,
        preco_min,
        preco_max,
        busca,
        opcoes: {
          marcas: marcasUnicas.map(m => ({ value: m, label: m })),
          tipos: tiposUnicos.map(t => ({ value: t, label: (t as string).replace('_', ' ') })),
          materiais: materiaisUnicos.map(m => ({ value: m, label: m })),
          indices: indicesUnicos.map(i => ({ value: String(i), label: String(i) })),
          tratamentos: tratamentosUnicos
        }
      },
      estatisticas: {
        total_lentes: count || 0,
        total_marcas: marcasUnicas.length,
        preco_medio: statsData?.price_avg || 0,
        preco_min: statsData?.price_min || 0,
        preco_max: statsData?.price_max || 0
      },
      sucesso: true,
      erro: null
    };
  } catch (err) {
    console.error('❌ Erro ao carregar tabela de preços:', err);
    return {
      lentes: [],
      total_resultados: 0,
      pagina_atual: 1,
      total_paginas: 0,
      has_more: false,
      visualizacao: 'tabela',
      filtros: {
        marca: '',
        tipo_lente: '',
        material: '',
        indice: '',
        tratamento: '',
        preco_min: 0,
        preco_max: 0,
        busca: '',
        opcoes: { marcas: [], tipos: [], materiais: [], indices: [], tratamentos: [] }
      },
      estatisticas: {
        total_lentes: 0,
        total_marcas: 0,
        preco_medio: 0,
        preco_min: 0,
        preco_max: 0
      },
      sucesso: false,
      erro: 'Erro ao carregar tabela de preços'
    };
  }
};
