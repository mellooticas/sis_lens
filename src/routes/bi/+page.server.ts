/**
 * 📊 BI Dashboard - Server Load
 * Carrega todas as estatísticas e dados para o dashboard BI
 */
import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async () => {
  try {
    console.log('📊 BI: Carregando dados do dashboard...');

    // 1. Estatísticas gerais do catálogo
    const { data: statsData, error: statsError } = await supabase
      .from('vw_stats_catalogo')
      .select('*')
      .single();

    if (statsError) {
      console.error('❌ Erro ao buscar estatísticas:', statsError);
    }

    // 2. Top 10 lentes mais caras
    const { data: topCaros, error: errorCaros } = await supabase
      .from('v_lentes')
      .select('id, nome_lente, marca_nome, preco_venda_sugerido, material, indice_refracao, nome_exibicao')
      .eq('ativo', true)
      .order('preco_venda_sugerido', { ascending: false })
      .limit(10);

    if (errorCaros) {
      console.error('❌ Erro ao buscar top caros:', errorCaros);
    }

    // 3. Distribuição por tipo (query direta)
    const { data: distribuicaoTipo, error: errorTipo } = await supabase
      .from('v_lentes')
      .select('tipo_lente')
      .eq('ativo', true);

    // Agrupar manualmente
    const tipoMap = new Map();
    distribuicaoTipo?.forEach(item => {
      const tipo = item.tipo_lente;
      tipoMap.set(tipo, (tipoMap.get(tipo) || 0) + 1);
    });
    const distribuicaoTipoAgrupada = Array.from(tipoMap, ([tipo, quantidade]) => ({ tipo, quantidade }));

    if (errorTipo) {
      console.error('❌ Erro ao buscar distribuição por tipo:', errorTipo);
    }

    // 4. Distribuição por material (query direta)
    const { data: distribuicaoMaterial, error: errorMaterial } = await supabase
      .from('v_lentes')
      .select('material')
      .eq('ativo', true);

    // Agrupar manualmente
    const materialMap = new Map();
    distribuicaoMaterial?.forEach(item => {
      const material = item.material;
      materialMap.set(material, (materialMap.get(material) || 0) + 1);
    });
    const distribuicaoMaterialAgrupada = Array.from(materialMap, ([material, quantidade]) => ({ material, quantidade }));

    if (errorMaterial) {
      console.error('❌ Erro ao buscar distribuição por material:', errorMaterial);
    }

    // 5. Fornecedores (usando view se existir)
    const { data: fornecedores, error: errorFornecedores } = await supabase
      .from('v_fornecedores')
      .select('*');

    if (errorFornecedores) {
      console.error('❌ Erro ao buscar fornecedores:', errorFornecedores);
    }

    // 6. Grupos canônicos premium
    const { data: topPremium, error: errorPremium } = await supabase
      .from('v_grupos_canonicos')
      .select('id, nome_grupo, preco_medio, total_lentes, marcas_nomes')
      .eq('is_premium', true)
      .eq('ativo', true)
      .order('preco_medio', { ascending: false })
      .limit(10);

    if (errorPremium) {
      console.error('❌ Erro ao buscar top premium:', errorPremium);
    }

    // 7. Cálculos extras de preços (Premium vs Standard)
    const { data: precoStats, error: errorPreco } = await supabase
      .from('v_grupos_canonicos')
      .select('is_premium, preco_medio')
      .eq('ativo', true);
    
    let precoMedioPremium = 0;
    let precoMedioStandard = 0;
    
    if (precoStats) {
      const premium = precoStats.filter(g => g.is_premium).map(g => g.preco_medio || 0);
      const standard = precoStats.filter(g => !g.is_premium).map(g => g.preco_medio || 0);
      
      const avg = (arr: number[]) => arr.length ? arr.reduce((a, b) => a + b, 0) / arr.length : 0;
      
      precoMedioPremium = avg(premium);
      precoMedioStandard = avg(standard);
    }

    // 8. Contagem real de lentes premium (usando Marca Premium como proxy, já que categoria está vazia)
    const { count: countPremium, error: errorCount } = await supabase
      .from('v_lentes')
      .select('*', { count: 'exact', head: true })
      .eq('marca_premium', true)
      .eq('ativo', true);

    const totalLentes = statsData?.total_lentes || 0;
    const totalPremium = countPremium || 0;
    const totalStandard = totalLentes - totalPremium;

    console.log('✅ BI: Dados carregados:', {
      stats: !!statsData,
      topCaros: topCaros?.length || 0,
      distribuicaoTipo: distribuicaoTipoAgrupada?.length || 0,
      distribuicaoMaterial: distribuicaoMaterialAgrupada?.length || 0,
      fornecedores: fornecedores?.length || 0,
      topPremium: topPremium?.length || 0
    });

    const finalStats = {
      ...(statsData || {}),
      total_lentes: totalLentes,
      total_premium: totalPremium,
      total_standard: totalStandard,
      preco_medio: statsData?.preco_medio_catalogo || 0,
      preco_medio_premium: precoMedioPremium,
      preco_medio_standard: precoMedioStandard
    };

    return {
      stats: finalStats,
      topCaros: topCaros || [],
      distribuicaoTipo: distribuicaoTipoAgrupada || [],
      distribuicaoMaterial: distribuicaoMaterialAgrupada || [],
      fornecedores: fornecedores || [],
      topPremium: topPremium || [],
      sucesso: true
    };
  } catch (err) {
    console.error('❌ Erro ao carregar dashboard BI:', err);
    throw error(500, 'Erro ao carregar dados do BI');
  }
};
