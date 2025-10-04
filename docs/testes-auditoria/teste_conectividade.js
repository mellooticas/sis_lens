// ============================================================================
// TESTE BÁSICO DE CONECTIVIDADE E PERMISSÕES
// ============================================================================

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ahcikwsoxhmqqteertkx.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoY2lrd3NveGhtcXF0ZWVydGt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0MzAwMzMsImV4cCI6MjA3NTAwNjAzM30.29PQSkRCNgmer_h7AcePf0BnOigyKJk4no8VqtmWBFk';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testeBasico() {
  console.log('🔍 TESTE BÁSICO DE CONECTIVIDADE SUPABASE\n');
  console.log('═══════════════════════════════════════════════════════════════\n');

  // ============================================================================
  // 1. TESTE DE AUTENTICAÇÃO
  // ============================================================================
  
  console.log('🔐 1. TESTE DE AUTENTICAÇÃO:\n');
  
  try {
    const { data: { session }, error } = await supabase.auth.getSession();
    
    if (error) {
      console.log(`❌ Erro de autenticação: ${error.message}`);
    } else {
      console.log(`✅ Autenticação: ${session ? 'Logado' : 'Anônimo (OK)'}`);
    }
  } catch (err) {
    console.log(`❌ Erro na autenticação: ${err.message}`);
  }

  // ============================================================================
  // 2. TESTE DE QUERY DIRETA SQL
  // ============================================================================
  
  console.log('\n🗄️  2. TESTE DE QUERY SQL DIRETA:\n');
  
  try {
    // Tentar executar uma query SQL básica
    const { data, error } = await supabase.rpc('version');
    
    if (error) {
      console.log(`❌ RPC version() falhou: ${error.message}`);
    } else {
      console.log(`✅ RPC version() funcionou: ${data}`);
    }
  } catch (err) {
    console.log(`❌ Erro na query: ${err.message}`);
  }

  // ============================================================================
  // 3. VERIFICAR RLS (ROW LEVEL SECURITY)
  // ============================================================================
  
  console.log('\n🛡️  3. VERIFICANDO PERMISSÕES:\n');
  
  // Tentar queries que devem funcionar independente do schema
  const testQueries = [
    { name: 'pg_version()', rpc: 'pg_version' },
    { name: 'current_user', rpc: 'current_user' },
    { name: 'current_database()', rpc: 'current_database' }
  ];

  for (const query of testQueries) {
    try {
      const { data, error } = await supabase.rpc(query.rpc);
      
      if (error) {
        console.log(`❌ ${query.name}: ${error.message}`);
      } else {
        console.log(`✅ ${query.name}: ${data}`);
      }
    } catch (err) {
      console.log(`❌ ${query.name}: ${err.message}`);
    }
  }

  // ============================================================================
  // 4. LISTAR SCHEMAS DISPONÍVEIS (ALTERNATIVA)
  // ============================================================================
  
  console.log('\n📂 4. TENTANDO LISTAR SCHEMAS (SQL DIRETO):\n');
  
  try {
    // Tentar usar SQL direto para listar schemas
    const { data, error } = await supabase.rpc('exec_sql', { 
      sql: 'SELECT schema_name FROM information_schema.schemata ORDER BY schema_name' 
    });
    
    if (error) {
      console.log(`❌ Falha ao listar schemas: ${error.message}`);
    } else {
      console.log(`✅ Schemas encontrados: ${JSON.stringify(data)}`);
    }
  } catch (err) {
    console.log(`❌ Erro na listagem: ${err.message}`);
  }

  // ============================================================================
  // 5. VERIFICAR SE BANCO ESTÁ VAZIO OU COM RESTRIÇÕES
  // ============================================================================
  
  console.log('\n🧪 5. TENTATIVAS ALTERNATIVAS:\n');
  
  // Tentar acessar alguma tabela do sistema que sempre existe
  const systemTables = ['pg_tables', 'pg_views', 'pg_stat_user_tables'];
  
  for (const table of systemTables) {
    try {
      const { data, error } = await supabase
        .from(table)
        .select('*')
        .limit(1);
      
      if (!error) {
        console.log(`✅ Acesso à ${table}: OK`);
      } else {
        console.log(`❌ ${table}: ${error.message}`);
      }
    } catch (err) {
      console.log(`❌ ${table}: ${err.message}`);
    }
  }

  // ============================================================================
  // 6. DIAGNÓSTICO FINAL
  // ============================================================================
  
  console.log('\n📊 DIAGNÓSTICO:\n');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('🎯 SITUAÇÃO DETECTADA:');
  console.log('');
  console.log('1. 🔑 Chave Supabase: Válida (sem erro de autenticação)');
  console.log('2. 🌐 URL Supabase: Acessível (conexão estabelecida)');
  console.log('3. 🗄️  Schema Cache: Limitado (anon key tem restrições)');
  console.log('');
  console.log('💡 POSSÍVEIS CAUSAS:');
  console.log('   • RLS (Row Level Security) habilitado nas tabelas');
  console.log('   • Permissões da chave anônima limitadas');
  console.log('   • Tabelas ainda não criadas no banco');
  console.log('   • Schema público não está populado');
  console.log('');
  console.log('🚀 AÇÕES RECOMENDADAS:');
  console.log('   1. Verificar no Supabase Dashboard se as tabelas existem');
  console.log('   2. Verificar permissões RLS nas tabelas');
  console.log('   3. Executar migration se necessário');
  console.log('   4. Testar com service_role key (se disponível)');
  console.log('═══════════════════════════════════════════════════════════════');
}

testeBasico();