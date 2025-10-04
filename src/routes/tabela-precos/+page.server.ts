/**
 * 💰 Tabela de Preços - Server Load
 * Tabela normalizada de lentes com filtros avançados para vouchers
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';

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
    const visualizacao = url.searchParams.get('view') || 'tabela'; // tabela ou cards
    const limite = visualizacao === 'cards' ? 12 : 20;
    const offset = (pagina - 1) * limite;

    console.log('💰 Tabela de Preços: Carregando com filtros:', {
      marca, tipo_lente, material, indice, tratamento, preco_min, preco_max, busca, visualizacao
    });

    // 1. Query principal de lentes
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
        preco_promocional,
        disponibilidade,
        estoque_disponivel,
        prazo_entrega,
        categoria,
        peso,
        espessura_centro,
        espessura_borda,
        protecao_uv,
        antirreflexo,
        created_at,
        updated_at
      `, { count: 'exact' });

    // 2. Aplicar filtros
    if (busca) {
      query = query.or(`familia.ilike.%${busca}%,marca_nome.ilike.%${busca}%,sku_canonico.ilike.%${busca}%,descricao_completa.ilike.%${busca}%`);
    }

    if (marca) {
      query = query.eq('marca_nome', marca);
    }

    if (tipo_lente) {
      query = query.eq('tipo_lente', tipo_lente);
    }

    if (material) {
      query = query.eq('material', material);
    }

    if (indice) {
      query = query.eq('indice_refracao', indice);
    }

    if (tratamento) {
      query = query.contains('tratamentos', [tratamento]);
    }

    query = query
      .gte('preco_base', preco_min)
      .lte('preco_base', preco_max)
      .order('marca_nome', { ascending: true })
      .order('familia', { ascending: true })
      .range(offset, offset + limite - 1);

    const { data: lentes, count, error } = await query;

    if (error) {
      console.error('❌ Erro ao buscar lentes:', error);
      throw error;
    }

    // 3. Buscar opções para filtros
    const [marcasResult, tiposResult, materiaisResult, indicesResult, tratamentosResult] = await Promise.all([
      // Marcas
      supabase.from('lentes_catalogo')
        .select('marca_nome')
        .not('marca_nome', 'is', null)
        .order('marca_nome'),
      
      // Tipos de lente
      supabase.from('lentes_catalogo')
        .select('tipo_lente')
        .not('tipo_lente', 'is', null)
        .order('tipo_lente'),
      
      // Materiais
      supabase.from('lentes_catalogo')
        .select('material')
        .not('material', 'is', null)
        .order('material'),
      
      // Índices de refração
      supabase.from('lentes_catalogo')
        .select('indice_refracao')
        .not('indice_refracao', 'is', null)
        .order('indice_refracao'),
      
      // Tratamentos (usar RPC para extrair array)
      supabase.rpc('obter_tratamentos_unicos')
    ]);

    // 4. Processar opções para filtros
    const marcasUnicas = [...new Set(marcasResult.data?.map(m => m.marca_nome).filter(Boolean))];
    const tiposUnicos = [...new Set(tiposResult.data?.map(t => t.tipo_lente).filter(Boolean))];
    const materiaisUnicos = [...new Set(materiaisResult.data?.map(m => m.material).filter(Boolean))];
    const indicesUnicos = [...new Set(indicesResult.data?.map(i => i.indice_refracao).filter(Boolean))];
    const tratamentosUnicos = tratamentosResult.data || [];

    // 5. Estatísticas da tabela
    const { data: estatisticas } = await supabase
      .rpc('obter_estatisticas_tabela_precos');

    const totalPaginas = Math.ceil((count || 0) / limite);

    return {
      lentes: lentes || [],
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
          tipos: tiposUnicos.map(t => ({ value: t, label: t })),
          materiais: materiaisUnicos.map(m => ({ value: m, label: m })),
          indices: indicesUnicos.map(i => ({ value: i, label: i })),
          tratamentos: tratamentosUnicos.map(t => ({ value: t, label: t }))
        }
      },
      estatisticas: estatisticas?.[0] || {
        total_lentes: count || 0,
        total_marcas: marcasUnicas.length,
        preco_medio: 0,
        preco_min: 0,
        preco_max: 0
      },
      sucesso: true,
      erro: null
    };
  } catch (error) {
    console.error('❌ Erro ao carregar tabela de preços:', error);
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