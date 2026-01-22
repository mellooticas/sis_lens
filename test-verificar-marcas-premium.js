// ============================================================================
// VERIFICAÇÃO: Marcas e is_premium nas Lentes
// ============================================================================

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ozyrvdjnxqbjvjihqxva.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96eXJ2ZGpueHFianZqaWhxeHZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ0NDM2NzAsImV4cCI6MjA1MDAxOTY3MH0.sMBXKZoGIiAiR7fxHG20TGKXj6uXq83H0-qUJ4iyslg';

const supabase = createClient(supabaseUrl, supabaseKey);

async function verificarMarcasEPremium() {
  console.log('\n' + '='.repeat(70));
  console.log('VERIFICAÇÃO DE MARCAS E IS_PREMIUM NAS LENTES');
  console.log('='.repeat(70) + '\n');

  try {
    // Verificação 1: Lentes sem marca_id
    console.log('📋 VERIFICAÇÃO 1: Lentes SEM marca_id\n');
    const { data: semMarca, count: countSemMarca } = await supabase
      .from('lentes')
      .select('id, nome, categoria', { count: 'exact' })
      .eq('ativo', true)
      .is('marca_id', null);

    console.log(`Total sem marca: ${countSemMarca}`);
    if (countSemMarca === 0) {
      console.log('✅ TODAS as lentes têm marca definida\n');
    } else {
      console.log('⚠️  ATENÇÃO: Existem lentes sem marca\n');
      console.log('Exemplos:', semMarca?.slice(0, 5));
    }

    // Verificação 2: Lentes sem is_premium
    console.log('\n📋 VERIFICAÇÃO 2: Lentes SEM is_premium definido\n');
    const { data: semPremium, count: countSemPremium } = await supabase
      .from('lentes')
      .select('id, nome, categoria', { count: 'exact' })
      .eq('ativo', true)
      .is('is_premium', null);

    console.log(`Total sem is_premium: ${countSemPremium}`);
    if (countSemPremium === 0) {
      console.log('✅ TODAS as lentes têm is_premium definido\n');
    } else {
      console.log('⚠️  ATENÇÃO: Existem lentes sem is_premium\n');
      console.log('Exemplos:', semPremium?.slice(0, 5));
    }

    // Verificação 3: Distribuição de is_premium
    console.log('\n📊 DISTRIBUIÇÃO: is_premium (TRUE/FALSE)\n');
    
    const { count: totalPremium } = await supabase
      .from('lentes')
      .select('*', { count: 'exact', head: true })
      .eq('ativo', true)
      .eq('is_premium', true);

    const { count: totalStandard } = await supabase
      .from('lentes')
      .select('*', { count: 'exact', head: true })
      .eq('ativo', true)
      .eq('is_premium', false);

    const { count: totalLentes } = await supabase
      .from('lentes')
      .select('*', { count: 'exact', head: true })
      .eq('ativo', true);

    console.log(`Premium (true):   ${totalPremium || 0} lentes (${((totalPremium || 0) / totalLentes * 100).toFixed(2)}%)`);
    console.log(`Standard (false): ${totalStandard || 0} lentes (${((totalStandard || 0) / totalLentes * 100).toFixed(2)}%)`);
    console.log(`NULL:             ${totalLentes - (totalPremium || 0) - (totalStandard || 0)} lentes`);
    console.log(`TOTAL:            ${totalLentes} lentes\n`);

    // Verificação 4: Lentes por marca
    console.log('\n📊 DISTRIBUIÇÃO: Lentes por Marca (Top 10)\n');
    
    const { data: marcas } = await supabase.rpc('get_lentes_por_marca');
    
    if (marcas && marcas.length > 0) {
      console.log('Marca'.padEnd(25), 'Total'.padStart(8), 'Premium'.padStart(10), 'Standard'.padStart(10));
      console.log('-'.repeat(65));
      marcas.slice(0, 10).forEach(m => {
        console.log(
          (m.marca || 'Sem marca').padEnd(25),
          String(m.total || 0).padStart(8),
          String(m.premium || 0).padStart(10),
          String(m.standard || 0).padStart(10)
        );
      });
    } else {
      // Fallback: buscar direto
      const { data: todasLentes } = await supabase
        .from('lentes')
        .select('marca_id, is_premium')
        .eq('ativo', true);

      const marcasCount = {};
      todasLentes?.forEach(l => {
        const key = l.marca_id || 'SEM_MARCA';
        if (!marcasCount[key]) {
          marcasCount[key] = { total: 0, premium: 0, standard: 0 };
        }
        marcasCount[key].total++;
        if (l.is_premium === true) marcasCount[key].premium++;
        if (l.is_premium === false) marcasCount[key].standard++;
      });

      console.log('\nMarcas únicas:', Object.keys(marcasCount).length);
      console.log('Lentes sem marca:', marcasCount['SEM_MARCA']?.total || 0);
    }

    // Validação Final
    console.log('\n' + '='.repeat(70));
    console.log('VALIDAÇÃO FINAL');
    console.log('='.repeat(70) + '\n');
    
    console.log(`Total de lentes:        ${totalLentes}`);
    console.log(`Lentes sem marca:       ${countSemMarca}`);
    console.log(`Lentes sem is_premium:  ${countSemPremium}`);
    console.log(`Lentes OK:              ${totalLentes - countSemMarca - countSemPremium}\n`);

    if (countSemMarca === 0 && countSemPremium === 0) {
      console.log('✅ TUDO OK - Pode executar 99V e 99W\n');
    } else {
      console.log('⚠️  CORRIGIR antes de executar 99V e 99W\n');
      
      if (countSemMarca > 0) {
        console.log(`   → Existem ${countSemMarca} lentes sem marca_id`);
      }
      if (countSemPremium > 0) {
        console.log(`   → Existem ${countSemPremium} lentes sem is_premium`);
      }
      console.log('');
    }

  } catch (error) {
    console.error('❌ Erro ao verificar:', error.message);
  }
}

verificarMarcasEPremium();
