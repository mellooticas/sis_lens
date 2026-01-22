// ============================================================================
// VERIFICAÇÃO RÁPIDA: Marcas e is_premium nas Lentes
// ============================================================================

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ozyrvdjnxqbjvjihqxva.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96eXJ2ZGpueHFianZqaWhxeHZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ0NDM2NzAsImV4cCI6MjA1MDAxOTY3MH0.sMBXKZoGIiAiR7fxHG20TGKXj6uXq83H0-qUJ4iyslg';

const supabase = createClient(supabaseUrl, supabaseKey);

async function verificar() {
  console.log('\n' + '='.repeat(70));
  console.log('VERIFICAÇÃO: MARCAS E IS_PREMIUM NAS LENTES');
  console.log('='.repeat(70) + '\n');

  // Use a RPC que deve existir ou faça consultas diretas
  const { data: lentes, error } = await supabase
    .rpc('verificar_lentes_marcas_premium');

  if (error && error.code === 'PGRST202') {
    console.log('⚠️  RPC não existe, tentando consulta direta...\n');
    
    // Tentar buscar direto
    const { data: allLentes, count, error: error2 } = await supabase
      .from('lentes')
      .select('id, nome, marca_id, is_premium', { count: 'exact' })
      .eq('ativo', true)
      .limit(10);

    if (error2) {
      console.error('❌ Erro na consulta:', error2.message);
      console.log('\n💡 Provavelmente tabela lentes não é acessível via API');
      console.log('   Verifique RLS policies ou use connection string direta\n');
      return;
    }

    console.log(`✅ Consultei ${count} lentes ativas\n`);
    
    if (!allLentes || allLentes.length === 0) {
      console.log('⚠️  Nenhuma lente retornada\n');
      return;
    }

    // Análise dos dados retornados
    const semMarca = allLentes.filter(l => !l.marca_id);
    const semPremium = allLentes.filter(l => l.is_premium === null || l.is_premium === undefined);
    
    console.log('📊 AMOSTRA (10 lentes):');
    console.log(`   Sem marca_id:    ${semMarca.length}`);
    console.log(`   Sem is_premium:  ${semPremium.length}\n`);

    if (semMarca.length > 0) {
      console.log('⚠️  Exemplos sem marca:', semMarca.map(l => l.id));
    }
    if (semPremium.length > 0) {
      console.log('⚠️  Exemplos sem premium:', semPremium.map(l => l.id));
    }

    console.log('\n📝 Primeiras lentes:');
    allLentes.slice(0, 3).forEach(l => {
      console.log(`   ID ${l.id}: marca_id=${l.marca_id || 'NULL'}, is_premium=${l.is_premium === null ? 'NULL' : l.is_premium}`);
    });

    console.log('\n' + '='.repeat(70));
    if (count > 0 && semMarca.length === 0 && semPremium.length === 0) {
      console.log('✅ AMOSTRA OK - Todas as 10 lentes têm marca_id e is_premium');
    } else {
      console.log('⚠️  Possíveis problemas detectados na amostra');
    }
    console.log('💡 Para verificação completa, execute: 99Y_VERIFICAR_MARCAS_PREMIUM_RAPIDO.sql');
    console.log('='.repeat(70) + '\n');

  } else if (error) {
    console.error('❌ Erro RPC:', error.message);
  } else {
    console.log('✅ Resultado RPC:', lentes);
  }
}

verificar();
