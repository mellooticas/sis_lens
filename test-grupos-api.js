// ============================================================================
// TESTE: API Grupos Canônicos Standard
// Data: 2026-01-11
// Objetivo: Testar se a API buscarGruposCanonicosStandard retorna dados
// ============================================================================

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ozyrvdjnxqbjvjihqxva.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96eXJ2ZGpueHFianZqaWhxeHZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ0NDM2NzAsImV4cCI6MjA1MDAxOTY3MH0.sMBXKZoGIiAiR7fxHG20TGKXj6uXq83H0-qUJ4iyslg';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testarGruposStandard() {
  console.log('\n🔍 Testando busca de grupos standard...\n');

  try {
    // Teste 1: Buscar primeiros 12 grupos
    console.log('📊 Teste 1: Buscar primeiros 12 grupos standard');
    const { data, error, count } = await supabase
      .from('v_grupos_canonicos')
      .select('*', { count: 'exact' })
      .eq('is_premium', false)
      .order('preco_medio', { ascending: true })
      .range(0, 11);

    if (error) {
      console.error('❌ Erro:', error);
      return;
    }

    console.log('✅ Sucesso!');
    console.log(`📈 Total de grupos standard: ${count}`);
    console.log(`📦 Grupos retornados: ${data?.length || 0}`);
    
    if (data && data.length > 0) {
      console.log('\n📝 Primeiros 3 grupos:');
      data.slice(0, 3).forEach((grupo, idx) => {
        console.log(`\n${idx + 1}. ${grupo.nome_grupo}`);
        console.log(`   Material: ${grupo.material} ${grupo.indice_refracao}`);
        console.log(`   Tipo: ${grupo.tipo_lente}`);
        console.log(`   Preço: R$ ${grupo.preco_medio?.toFixed(2)}`);
        console.log(`   Lentes: ${grupo.total_lentes}`);
      });
    }

    // Teste 2: Verificar permissões da view
    console.log('\n\n📊 Teste 2: Verificar se view existe e está acessível');
    const { data: testView, error: viewError } = await supabase
      .from('v_grupos_canonicos')
      .select('id')
      .limit(1);

    if (viewError) {
      console.error('❌ Erro ao acessar view:', viewError);
    } else {
      console.log('✅ View v_grupos_canonicos está acessível');
    }

  } catch (err) {
    console.error('❌ Erro geral:', err);
  }
}

testarGruposStandard();
