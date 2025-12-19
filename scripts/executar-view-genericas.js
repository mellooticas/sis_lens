import { createClient } from '@supabase/supabase-js';
import * as fs from 'fs';
import * as path from 'path';
import { fileURLToPath } from 'url';
import 'dotenv/config';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Erro: Variáveis de ambiente VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY são necessárias');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function executarSQL() {
  try {
    console.log('📊 Criando view vw_detalhes_genericas...\n');
    
    const sqlPath = path.join(__dirname, '..', 'povoar_banco', '16_VIEW_DETALHES_GENERICAS.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    // Executar via RPC (precisamos de uma função helper ou dividir o SQL)
    // Como o Supabase não permite executar SQL diretamente via cliente,
    // vamos usar o SQL Editor do Dashboard
    
    console.log('📋 SQL a ser executado no Supabase Dashboard:\n');
    console.log('='.repeat(80));
    console.log(sql);
    console.log('='.repeat(80));
    console.log('\n✅ Copie o SQL acima e execute no Supabase Dashboard > SQL Editor');
    console.log(`🔗 https://supabase.com/dashboard/project/${supabaseUrl.split('.')[0].replace('https://', '')}/sql/new`);
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
    process.exit(1);
  }
}

executarSQL();
