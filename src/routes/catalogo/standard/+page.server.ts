/**
 * 📚 Catálogo de Lentes - Server Load (NOVA ESTRUTURA)
 * Usa vw_buscar_lentes com agrupamento por canônicas
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';

const TENANT_ID = 'cd311ba0-9e20-46c4-a65f-9b48fb4b36ec'; // TODO: pegar do contexto

export const load: PageServerLoad = async ({ url }) => {
  try {
    // Parâmetros de busca e filtros
    const busca = url.searchParams.get('busca') || '';
    const tipo = url.searchParams.get('tipo') || ''; // PREMIUM ou GENÉRICA
    const tipo_lente = url.searchParams.get('tipo_lente') || '';
    const material = url.searchParams.get('material') || '';
    const marca_id = url.searchParams.get('marca_id') || '';
    const laboratorio_id = url.searchParams.get('laboratorio_id') || '';
    const pagina = parseInt(url.searchParams.get('pagina') || '1');
    const limite = 20;
    const offset = (pagina - 1) * limite;

    console.log('📚 Catálogo NOVO: Carregando lentes com filtros:', {
      busca, tipo, tipo_lente, material, marca_id, laboratorio_id, pagina
    });

    // 1. Buscar lentes usando a nova view vw_buscar_lentes
    let query = supabase
      .from('vw_buscar_lentes')
      .select('*', { count: 'exact' })
      .eq('tenant_id', TENANT_ID)
      .eq('ativo', true);

    // Aplicar filtros
    if (busca) {
      query = query.or(`nome_produto.ilike.%${busca}%,sku.ilike.%${busca}%,marca.ilike.%${busca}%`);
    }

    if (tipo) {
      query = query.eq('tipo', tipo);
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

    if (laboratorio_id) {
      query = query.eq('laboratorio_id', laboratorio_id);
    }

    query = query
      .order('nome_produto', { ascending: true })
      .range(offset, offset + limite - 1);

    const { data: lentes, count, error } = await query;

    if (error) {
      console.error('❌ Erro ao buscar lentes:', error);
      throw error;
    }

    // 2. Buscar marcas para filtro (vw_marcas)
    const { data: marcas } = await supabase
      .from('vw_marcas')
      .select('id, nome, total_produtos')
      .eq('tenant_id', TENANT_ID)
      .order('nome');

    // 3. Buscar laboratórios para filtro (vw_laboratorios)
    const { data: laboratorios } = await supabase
      .from('vw_laboratorios')
      .select('id, nome, total_produtos')
      .eq('tenant_id', TENANT_ID)
      .order('nome');

    // 4. Buscar filtros disponíveis (vw_filtros_disponiveis)
    const { data: filtrosDisponiveis } = await supabase
      .from('vw_filtros_disponiveis')
      .select('*')
      .eq('tenant_id', TENANT_ID)
      .single();

    // 5. Processar dados
    const totalPaginas = Math.ceil((count || 0) / limite);

    // Estatísticas calculadas
    const totalPremium = lentes?.filter(l => l.tipo === 'PREMIUM').length || 0;
    const totalGenerica = lentes?.filter(l => l.tipo === 'GENÉRICA').length || 0;

    return {
      lentes: lentes || [],
      total_resultados: count || 0,
      pagina_atual: pagina,
      total_paginas: totalPaginas,
      has_more: pagina < totalPaginas,
      
      filtros: {
        busca,
        tipo,
        tipo_lente,
        material,
        marca_id,
        laboratorio_id,
        opcoes: {
          tipos: [
            { value: '', label: 'Todos os tipos' },
            { value: 'PREMIUM', label: 'Premium' },
            { value: 'GENÉRICA', label: 'Genérica' }
          ],
          tipos_lente: [
            { value: '', label: 'Todos os tipos de lente' },
            ...(filtrosDisponiveis?.tipos_lente?.map(t => ({ value: t, label: t })) || [])
          ],
          materiais: [
            { value: '', label: 'Todos os materiais' },
            ...(filtrosDisponiveis?.materiais?.map(m => ({ value: m, label: m })) || [])
          ],
          marcas: [
            { value: '', label: 'Todas as marcas' },
            ...(marcas?.map(m => ({ value: m.id, label: `${m.nome} (${m.total_produtos})` })) || [])
          ],
          laboratorios: [
            { value: '', label: 'Todos os laboratórios' },
            ...(laboratorios?.map(l => ({ value: l.id, label: `${l.nome} (${l.total_produtos})` })) || [])
          ]
        }
      },
      
      estatisticas: {
        total_lentes: count || 0,
        total_premium: totalPremium,
        total_generica: totalGenerica,
        total_marcas: marcas?.length || 0,
        total_labs: laboratorios?.length || 0
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
        tipo: '',
        tipo_lente: '',
        material: '',
        marca_id: '',
        laboratorio_id: '',
        opcoes: {
          tipos: [],
          tipos_lente: [],
          materiais: [],
          marcas: [],
          laboratorios: []
        }
      },
      estatisticas: {
        total_lentes: 0,
        total_premium: 0,
        total_generica: 0,
        total_marcas: 0,
        total_labs: 0
      },
      sucesso: false,
      erro: 'Erro ao carregar catálogo de lentes'
    };
  }
};