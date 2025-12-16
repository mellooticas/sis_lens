/**
 * 🏆 Produtos Premium - Server Load
 * Lista produtos premium agrupados por canonical
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';

const TENANT_ID = 'cd311ba0-9e20-46c4-a65f-9b48fb4b36ec';

export const load: PageServerLoad = async ({ url }) => {
  try {
    const marca_id = url.searchParams.get('marca_id') || '';
    const tipo_lente = url.searchParams.get('tipo_lente') || '';

    console.log('🏆 Premium: Carregando produtos premium');

    // 1. Buscar produtos premium usando vw_produtos_premium
    let query = supabase
      .from('vw_produtos_premium')
      .select('*')
      .eq('tenant_id', TENANT_ID)
      .eq('ativo', true);

    if (marca_id) {
      query = query.eq('marca_id', marca_id);
    }

    if (tipo_lente) {
      query = query.eq('tipo_lente', tipo_lente);
    }

    query = query.order('nome');

    const { data: produtos, error } = await query;

    if (error) {
      console.error('❌ Erro ao buscar produtos premium:', error);
      throw error;
    }

    // 2. Buscar marcas premium
    const { data: marcas } = await supabase
      .from('vw_marcas')
      .select('id, nome, produtos_premium')
      .eq('tenant_id', TENANT_ID)
      .gt('produtos_premium', 0)
      .order('nome');

    // 3. Buscar tipos de lente disponíveis
    const { data: filtrosDisponiveis } = await supabase
      .from('vw_filtros_disponiveis')
      .select('tipos_lente')
      .eq('tenant_id', TENANT_ID)
      .single();

    return {
      produtos: produtos || [],
      total: produtos?.length || 0,
      
      filtros: {
        marca_id,
        tipo_lente,
        opcoes: {
          marcas: [
            { value: '', label: 'Todas as marcas' },
            ...(marcas?.map(m => ({ 
              value: m.id, 
              label: `${m.nome} (${m.produtos_premium})` 
            })) || [])
          ],
          tipos_lente: [
            { value: '', label: 'Todos os tipos' },
            ...(filtrosDisponiveis?.tipos_lente?.map(t => ({ 
              value: t, 
              label: t 
            })) || [])
          ]
        }
      },
      
      estatisticas: {
        total_produtos: produtos?.length || 0,
        total_marcas: marcas?.length || 0,
        media_labs_por_produto: produtos?.length 
          ? produtos.reduce((acc, p) => acc + (p.qtd_laboratorios || 0), 0) / produtos.length 
          : 0
      },
      
      sucesso: true
    };
  } catch (error) {
    console.error('❌ Erro ao carregar produtos premium:', error);
    return {
      produtos: [],
      total: 0,
      filtros: {
        marca_id: '',
        tipo_lente: '',
        opcoes: { marcas: [], tipos_lente: [] }
      },
      estatisticas: {
        total_produtos: 0,
        total_marcas: 0,
        media_labs_por_produto: 0
      },
      sucesso: false,
      erro: 'Erro ao carregar produtos premium'
    };
  }
};
