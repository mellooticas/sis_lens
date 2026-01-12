// ============================================================================
// DESCOBRIR O QUE REALMENTE EXISTE NO BANCO
// ============================================================================

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ahcikwsoxhmqqteertkx.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoY2lrd3NveGhtcXF0ZWVydGt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0MzAwMzMsImV4cCI6MjA3NTAwNjAzM30.29PQSkRCNgmer_h7AcePf0BnOigyKJk4no8VqtmWBFk';

const supabase = createClient(supabaseUrl, supabaseKey);

async function descobrirEstruturaBanco() {
  console.log('🔍 DESCOBRINDO ESTRUTURA REAL DO BANCO BESTLENS\n');
  console.log('═══════════════════════════════════════════════════════════════\n');

  try {
    // ============================================================================
    // 1. LISTAR TABELAS NO SCHEMA PUBLIC
    // ============================================================================
    
    console.log('📋 1. LISTANDO TABELAS NO SCHEMA PUBLIC:\n');
    
    const { data: tables, error: tablesError } = await supabase
      .from('information_schema.tables')
      .select('table_name, table_type')
      .eq('table_schema', 'public')
      .order('table_name');
    
    if (tablesError) {
      console.log('❌ Erro ao listar tabelas:', tablesError.message);
    } else {
      console.log(`✅ Encontradas ${tables?.length || 0} tabelas/views:\n`);
      
      const tabelas = tables?.filter(t => t.table_type === 'BASE TABLE') || [];
      const views = tables?.filter(t => t.table_type === 'VIEW') || [];
      
      console.log('🗂️  TABELAS:');
      tabelas.forEach(t => console.log(`   • ${t.table_name}`));
      
      console.log('\n👁️  VIEWS:');
      views.forEach(v => console.log(`   • ${v.table_name}`));
      
      console.log(''); // linha em branco
    }

    // ============================================================================
    // 2. LISTAR FUNÇÕES/RPCs
    // ============================================================================
    
    console.log('⚙️  2. LISTANDO FUNÇÕES/RPCs:\n');
    
    const { data: functions, error: functionsError } = await supabase
      .from('information_schema.routines')
      .select('routine_name, routine_type')
      .eq('routine_schema', 'public')
      .eq('routine_type', 'FUNCTION')
      .order('routine_name');
    
    if (functionsError) {
      console.log('❌ Erro ao listar funções:', functionsError.message);
    } else {
      console.log(`✅ Encontradas ${functions?.length || 0} funções:\n`);
      functions?.forEach(f => console.log(`   • ${f.routine_name}()`));
      console.log(''); // linha em branco
    }

    // ============================================================================
    // 3. TESTAR ACESSO A ALGUMAS TABELAS COMUNS
    // ============================================================================
    
    console.log('🧪 3. TESTANDO ACESSO A TABELAS COMUNS:\n');
    
    // Tentar algumas tabelas que podem existir
    const commonTables = [
      'users', 'profiles', 'auth.users',
      'storage.buckets', 'storage.objects',
      // Possíveis tabelas do sistema
      'lentes', 'laboratorios', 'decisoes',
      'produtos', 'fornecedores', 'opcoes'
    ];

    for (const tableName of commonTables) {
      try {
        const { data, error, count } = await supabase
          .from(tableName)
          .select('*', { count: 'exact' })
          .limit(1);
        
        if (!error) {
          console.log(`✅ ${tableName}: ${count || 0} registros`);
        }
      } catch (err) {
        // Ignorar erros de tabelas que não existem
      }
    }

    // ============================================================================
    // 4. VERIFICAR SCHEMA ESPECÍFICO
    // ============================================================================
    
    console.log('\n🔍 4. VERIFICANDO ESQUEMAS DISPONÍVEIS:\n');
    
    const { data: schemas, error: schemasError } = await supabase
      .from('information_schema.schemata')
      .select('schema_name')
      .order('schema_name');
    
    if (schemasError) {
      console.log('❌ Erro ao listar esquemas:', schemasError.message);
    } else {
      console.log(`✅ Esquemas encontrados:\n`);
      schemas?.forEach(s => console.log(`   • ${s.schema_name}`));
    }

    // ============================================================================
    // 5. RESUMO E RECOMENDAÇÕES
    // ============================================================================
    
    console.log('\n📊 RESUMO E SITUAÇÃO ATUAL:\n');
    console.log('═══════════════════════════════════════════════════════════════');
    
    if (tables && tables.length > 0) {
      console.log('✅ CONEXÃO COM BANCO: Funcionando');
      console.log(`📋 ESTRUTURA ATUAL: ${tables.length} tabelas/views encontradas`);
      
      // Verificar se há tabelas relacionadas ao SIS Lens
      const bestLensTables = tables.filter(t => 
        t.table_name.includes('lente') || 
        t.table_name.includes('laboratorio') || 
        t.table_name.includes('decisao') ||
        t.table_name.includes('produto')
      );
      
      if (bestLensTables.length > 0) {
        console.log('🎯 TABELAS BESTLENS ENCONTRADAS:');
        bestLensTables.forEach(t => console.log(`   ✅ ${t.table_name} (${t.table_type})`));
      } else {
        console.log('⚠️  NENHUMA TABELA BESTLENS ENCONTRADA');
        console.log('💡 AÇÃO NECESSÁRIA: Executar migration SQL');
      }
    } else {
      console.log('❌ PROBLEMA NA CONEXÃO OU BANCO VAZIO');
    }
    
    console.log('═══════════════════════════════════════════════════════════════');

  } catch (error) {
    console.error('❌ ERRO GERAL:', error);
  }
}

descobrirEstruturaBanco();