// ============================================================================
// TESTE REAL DAS CONEXÕES COM O BANCO EXISTENTE
// ============================================================================

import { DatabaseClient } from './src/lib/database/client.js';

async function testarConexaoReal() {
  console.log('🔍 TESTANDO CONEXÕES REAIS COM O BANCO BESTLENS\n');
  console.log('═══════════════════════════════════════════════════════════════\n');

  // ============================================================================
  // 1. TESTAR VIEWS PRINCIPAIS
  // ============================================================================
  
  console.log('📋 1. TESTANDO VIEWS DO SCHEMA PUBLIC:\n');
  
  try {
    // Teste 1: View de lentes
    console.log('🔸 Testando vw_lentes_catalogo...');
    const lentesResult = await DatabaseClient.lenses.listarLentes(1, 5);
    
    if (lentesResult.error) {
      console.log(`❌ vw_lentes_catalogo: ${lentesResult.error}`);
    } else {
      console.log(`✅ vw_lentes_catalogo: ${lentesResult.data?.length || 0} registros encontrados`);
      if (lentesResult.data?.[0]) {
        console.log(`   📄 Exemplo: ${JSON.stringify(lentesResult.data[0], null, 2).substring(0, 200)}...`);
      }
    }
    
    // Teste 2: View de fornecedores
    console.log('\n🔸 Testando vw_fornecedores...');
    const fornecedoresResult = await DatabaseClient.suppliers.listarLaboratorios();
    
    if (fornecedoresResult.error) {
      console.log(`❌ vw_fornecedores: ${fornecedoresResult.error}`);
    } else {
      console.log(`✅ vw_fornecedores: ${fornecedoresResult.data?.length || 0} laboratórios encontrados`);
      if (fornecedoresResult.data?.[0]) {
        console.log(`   📄 Exemplo: ${JSON.stringify(fornecedoresResult.data[0], null, 2).substring(0, 200)}...`);
      }
    }
    
    // ============================================================================
    // 2. TESTAR RPCs/FUNÇÕES
    // ============================================================================
    
    console.log('\n⚙️  2. TESTANDO RPCS/FUNÇÕES:\n');
    
    // Teste 3: RPC de busca
    console.log('🔸 Testando rpc_buscar_lente...');
    const buscaResult = await DatabaseClient.lenses.buscarLentes('varilux', 5);
    
    if (buscaResult.error) {
      console.log(`❌ rpc_buscar_lente: ${buscaResult.error}`);
    } else {
      console.log(`✅ rpc_buscar_lente: ${buscaResult.data?.length || 0} resultados para "varilux"`);
      if (buscaResult.data?.[0]) {
        console.log(`   📄 Exemplo: ${JSON.stringify(buscaResult.data[0], null, 2)}`);
      }
    }
    
    // ============================================================================
    // 3. TESTAR TABELAS DIRETAMENTE
    // ============================================================================
    
    console.log('\n🗂️  3. TESTANDO TABELAS DIRETAMENTE:\n');
    
    // Teste 4: Histórico de decisões
    console.log('🔸 Testando tabela decisoes_compra...');
    const decisoesResult = await DatabaseClient.orders.listarDecisoes(1, 5);
    
    if (decisoesResult.error) {
      console.log(`❌ decisoes_compra: ${decisoesResult.error}`);
    } else {
      console.log(`✅ decisoes_compra: ${decisoesResult.data?.length || 0} decisões no histórico`);
    }
    
    // ============================================================================
    // 4. RESUMO DO TESTE
    // ============================================================================
    
    console.log('\n📊 4. RESUMO DA CONECTIVIDADE:\n');
    console.log('═══════════════════════════════════════════════════════════════');
    
    // Verificar se todas as conexões estão funcionando
    const viewsOk = !lentesResult.error && !fornecedoresResult.error;
    const rpcsOk = !buscaResult.error;
    const tabelasOk = !decisoesResult.error;
    
    console.log(`Views do Schema: ${viewsOk ? '✅ CONECTADAS' : '❌ COM PROBLEMAS'}`);
    console.log(`RPCs/Funções: ${rpcsOk ? '✅ FUNCIONANDO' : '❌ COM PROBLEMAS'}`);
    console.log(`Tabelas Diretas: ${tabelasOk ? '✅ ACESSÍVEIS' : '❌ COM PROBLEMAS'}`);
    
    if (viewsOk && rpcsOk && tabelasOk) {
      console.log('\n🎯 SISTEMA BACKEND TOTALMENTE CONECTADO!');
      console.log('✅ Todas as views, RPCs e tabelas estão acessíveis');
      console.log('✅ DatabaseClient funcionando perfeitamente');
      console.log('✅ Pronto para uso no frontend');
    } else {
      console.log('\n⚠️  ALGUNS COMPONENTES PRECISAM DE ATENÇÃO');
      console.log('🔧 Verifique as conexões marcadas com ❌');
    }
    
    console.log('═══════════════════════════════════════════════════════════════');
    
  } catch (error) {
    console.error('❌ ERRO GERAL NO TESTE:', error);
  }
}

testarConexaoReal();