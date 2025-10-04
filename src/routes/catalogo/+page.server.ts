/**
 * 📚 Catálogo de Lentes - Server Load
 * Busca lentes do Supabase com filtros e paginação
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';

export const load: PageServerLoad = async ({ url }) => {
  try {
    // Parâmetros de busca e filtros
    const busca = url.searchParams.get('busca') || '';
    const categoria = url.searchParams.get('categoria') || '';
    const material = url.searchParams.get('material') || '';
    const preco_min = parseFloat(url.searchParams.get('preco_min') || '0');
    const preco_max = parseFloat(url.searchParams.get('preco_max') || '99999');
    const pagina = parseInt(url.searchParams.get('pagina') || '1');
    const limite = 20;
    const offset = (pagina - 1) * limite;

    console.log('📚 Catálogo: Carregando lentes com filtros:', {
      busca, categoria, material, preco_min, preco_max, pagina
    });

    // 1. Construir query base
    let query = supabase
      .from('lentes_catalogo')
      .select(`
        id,
        sku_canonico,
        familia,
        design,
        material,
        indice_refracao,
        tipo_lente,
        marca_nome,
        descricao_completa,
        tratamentos,
        preco_base,
        disponibilidade,
        created_at
      `, { count: 'exact' });

    // 2. Aplicar filtros
    if (busca) {
      query = query.or(`familia.ilike.%${busca}%,marca_nome.ilike.%${busca}%,sku_canonico.ilike.%${busca}%`);
    }

    if (categoria) {
      query = query.eq('tipo_lente', categoria);
    }

    if (material) {
      query = query.eq('material', material);
    }

    query = query
      .gte('preco_base', preco_min)
      .lte('preco_base', preco_max)
      .order('familia', { ascending: true })
      .range(offset, offset + limite - 1);

    const { data: lentes, count, error } = await query;

    if (error) {
      console.error('❌ Erro ao buscar lentes:', error);
      throw error;
    }

    // 3. Buscar opções para filtros
    const { data: categorias } = await supabase
      .from('lentes_catalogo')
      .select('tipo_lente')
      .not('tipo_lente', 'is', null)
      .order('tipo_lente');

    const { data: materiais } = await supabase
      .from('lentes_catalogo')
      .select('material')
      .not('material', 'is', null)
      .order('material');

    // 4. Estatísticas do catálogo
    const { data: estatisticas } = await supabase
      .rpc('obter_estatisticas_catalogo');

    // 5. Processar dados
    const categoriasUnicas = [...new Set(categorias?.map(c => c.tipo_lente).filter(Boolean))];
    const materiaisUnicos = [...new Set(materiais?.map(m => m.material).filter(Boolean))];

    const totalPaginas = Math.ceil((count || 0) / limite);

    return {
      lentes: lentes || [],
      total_resultados: count || 0,
      pagina_atual: pagina,
      total_paginas: totalPaginas,
      has_more: pagina < totalPaginas,
      filtros: {
        busca,
        categoria,
        material,
        preco_min,
        preco_max,
        opcoes: {
          categorias: categoriasUnicas.map(cat => ({ value: cat, label: cat })),
          materiais: materiaisUnicos.map(mat => ({ value: mat, label: mat }))
        }
      },
      estatisticas: estatisticas?.[0] || {
        total_lentes: count || 0,
        total_marcas: 0,
        preco_medio: 0
      },
      sucesso: true,
      erro: null
    };
  } catch (error) {
    console.error('❌ Erro ao carregar catálogo:', error);
    return {
      lentes: [],
      total_resultados: 0,
      pagina_atual: 1,
      total_paginas: 0,
      has_more: false,
      filtros: {
        busca: '',
        categoria: '',
        material: '',
        preco_min: 0,
        preco_max: 0,
        opcoes: { categorias: [], materiais: [] }
      },
      estatisticas: {
        total_lentes: 0,
        total_marcas: 0,
        preco_medio: 0
      },
      sucesso: false,
      erro: 'Erro ao carregar catálogo de lentes'
    };
  }
};