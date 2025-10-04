/**
 * Página de Debug - Teste de Dados do Banco
 * Carrega todos os dados das views para verificar conexão
 */

import { DatabaseClient } from '$lib/database/client';
import { supabase } from '$lib/supabase';

export async function load() {
  console.log('🧪 CARREGANDO DADOS DE DEBUG...');

  try {
    // 1. Teste do catálogo
    console.log('1️⃣ Carregando catálogo...');
    const catalogoResult = await DatabaseClient.buscarLentesPorQuery('', {}, 10);

    // 2. Teste dos fornecedores
    console.log('2️⃣ Carregando fornecedores...');
    const { data: fornecedores, error: fornecedoresError } = await supabase
      .from('fornecedores')
      .select('*')
      .limit(10);

    // 3. Teste de busca simples
    console.log('3️⃣ Testando busca...');
    const buscaResult = await DatabaseClient.buscarLentesPorQuery('progressive', {}, 5);

    // 4. Teste de lentes populares
    console.log('4️⃣ Carregando lentes populares...');
    const { data: populares, error: popularesError } = await supabase
      .from('lentes_populares')
      .select('*')
      .limit(5);

    // 5. Teste de preços
    console.log('5️⃣ Carregando preços...');
    const { data: precos, error: precosError } = await supabase
      .from('precos_atuais')
      .select('*')
      .limit(10);

    // 6. Teste de estatísticas
    console.log('6️⃣ Carregando estatísticas...');
    const { data: estatisticas, error: estatisticasError } = await supabase
      .from('estatisticas_uso')
      .select('*')
      .limit(5);

    console.log('✅ Todos os dados carregados com sucesso!');

    return {
      catalogo: catalogoResult?.resultados || [],
      fornecedores: fornecedores || [],
      busca: buscaResult?.resultados || [],
      populares: populares || [],
      precos: precos || [],
      estatisticas: estatisticas || [],
      erros: {
        fornecedores: fornecedoresError?.message,
        populares: popularesError?.message,
        precos: precosError?.message,
        estatisticas: estatisticasError?.message
      }
    };

  } catch (error) {
    console.error('❌ Erro ao carregar dados de debug:', error);
    
    return {
      catalogo: [],
      fornecedores: [],
      busca: [],
      populares: [],
      precos: [],
      estatisticas: [],
      erro: error instanceof Error ? error.message : 'Erro desconhecido'
    };
  }
}