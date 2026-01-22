/**
 * 📚 Catálogo Standard - Server Load
 * Usa view consolidada v_grupos_canonicos com filtro is_premium = false
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';

const TENANT_ID = 'cd311ba0-9e20-46c4-a65f-9b48fb4b36ec'; // TODO: pegar do contexto

export const load: PageServerLoad = async ({ url }) => {
  try {
    // Parâmetros de busca e filtros
    const busca = url.searchParams.get('busca') || '';
    const tipo_lente = url.searchParams.get('tipo_lente') || '';
    const material = url.searchParams.get('material') || '';
    const marca_id = url.searchParams.get('marca_id') || '';
    const pagina = parseInt(url.searchParams.get('pagina') || '1');
    const limite = 20;
    const offset = (pagina - 1) * limite;

    console.log('📚 Catálogo Standard: Carregando grupos não-premium com filtros:', {
      busca, tipo_lente, material, marca_id, pagina
    });

    // 1. Buscar grupos canônicos STANDARD (is_premium = false) usando v_grupos_canonicos
    let query = supabase
      .from('v_grupos_canonicos')
      .select('*', { count: 'exact' })
      .eq('ativo', true)
      .eq('is_premium', false);

    // Aplicar filtros
    if (busca) {
      query = query.or(`nome_grupo.ilike.%${busca}%,slug.ilike.%${busca}%`);
    }

    if (tipo_lente) {
      query = query.eq('tipo_lente', tipo_lente);
    }

    if (material) {
      query = query.eq('material', material);
    }

    if (marca_id) {
      query = query.eq('marca_id', marca_id);
    }

    query = query
      .order('nome_grupo', { ascending: true })
      .range(offset, offset + limite - 1);

    const { data: grupos, count, error } = await query;

    if (error) {
      console.error('❌ Erro ao buscar grupos standard:', error);
      throw error;
    }

    // 2. Buscar marcas para filtro (tabela lens_catalog.marcas) - apenas não-premium
    const { data: marcas } = await supabase
      .from('lens_catalog.marcas')
      .select('id, nome')
      .eq('ativo', true)
      .eq('is_premium', false)
      .order('nome');

    // 3. Processar dados
    const totalPaginas = Math.ceil((count || 0) / limite);

    // Dados consolidados
    console.log('✅ Grupos Standard carregados:', {
      total: count,
      pagina,
      grupos: grupos?.length
    });

    return {
      grupos: grupos || [],
      total_resultados: count || 0,
      pagina_atual: pagina,
      total_paginas: totalPaginas,
      has_more: pagina < totalPaginas,
      
      filtros: {
        busca,
        tipo_lente,
        material,
        marca_id,
        opcoes: {
          tipos_lente: [
            { value: '', label: 'Todos os tipos de lente' }
            // TODO: adicionar tipos_lente disponíveis para standard
          ],
          materiais: [
            { value: '', label: 'Todos os materiais' }
            // TODO: adicionar materiais disponíveis para standard
          ],
          marcas: [
            { value: '', label: 'Todas as marcas' },
            ...(marcas?.map(m => ({ value: m.id, label: m.nome })) || [])
          ]
        }
      },
      
      estatisticas: {
        total_grupos: count || 0,
        total_marcas: marcas?.length || 0
      },
      
      sucesso: true,
      erro: null
    };
  } catch (error) {
    console.error('❌ Erro ao carregar catálogo standard:', error);
    return {
      grupos: [],
      total_resultados: 0,
      pagina_atual: 1,
      total_paginas: 0,
      has_more: false,
      filtros: {
        busca: '',
        tipo_lente: '',
        material: '',
        marca_id: '',
        opcoes: {
          tipos_lente: [],
          materiais: [],
          marcas: []
        }
      },
      estatisticas: {
        total_grupos: 0,
        total_marcas: 0
      },
      sucesso: false,
      erro: 'Erro ao carregar catálogo standard'
    };
  }
};