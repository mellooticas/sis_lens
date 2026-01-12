// scripts/test/diagnose-db.js
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.resolve(__dirname, '../../.env');
dotenv.config({ path: envPath });

const supabase = createClient(
    process.env.VITE_SUPABASE_URL,
    process.env.VITE_SUPABASE_ANON_KEY
);

async function checkTable(tableName) {
    console.log(`\n🔍 Checking table '${tableName}'...`);
    const { count, error } = await supabase
        .from(tableName)
        .select('*', { count: 'exact', head: true });

    if (error) {
        if (error.code === '42P01') {
             console.log(`   ❌ Table '${tableName}' does not exist.`);
        } else {
             console.log(`   ⚠️ Access issue or other error: ${error.message} (Code: ${error.code})`);
             if (error.message.includes('permission denied')) {
                 console.log(`   🔒 RLS is likely preventing public access.`);
             }
        }
    } else {
        console.log(`   ✅ Table reachable. Rows: ${count}`);
    }
}

async function run() {
    console.log(`🏥 Starting Database Diagnosis...`);
    console.log(`Target: ${process.env.VITE_SUPABASE_URL}`);
    
    // Check main tables based on file structure
    await checkTable('lentes');
    await checkTable('marcas');
    await checkTable('fornecedores');
    await checkTable('profiles'); // common supabase table
    
    console.log(`\n🏁 Diagnosis complete.`);
}

run();
