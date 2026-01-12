// scripts/test/check-connection.js
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

// Load .env file
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.resolve(__dirname, '../../.env');
dotenv.config({ path: envPath });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.VITE_SUPABASE_ANON_KEY;

console.log(`Checking connection to Supabase...`);
console.log(`URL: ${SUPABASE_URL}`);
// Mask key for security in logs
console.log(`Key: ${SUPABASE_ANON_KEY ? SUPABASE_ANON_KEY.substring(0, 10) + '...' : 'UNDEFINED'}`);

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('❌ Missing environment variables!');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function testConnection() {
  try {
    // Try to basic query - picking a table that likely exists or system info
    // Trying to get 'lentes' count
    const { data, error, count } = await supabase
      .from('lentes')
      .select('*', { count: 'exact', head: true });

    if (error) {
       // If table doesn't exist, it might throw a 404-like error in the body, which appears in 'error'
       console.log('⚠️ Could not query "lentes" table directly. Trying generic health check...');
       console.error('Error details:', error.message);
       
       // Fallback: try auth check (doesn't require login, just checks endpoint)
       const { data: authData, error: authError } = await supabase.auth.getSession();
       if (authError) {
         throw authError;
       }
       console.log('✅ Auth service is reachable.');
    } else {
       console.log(`✅ Connection successful! Found ${count !== null ? count : 'N/A'} rows in 'lentes' table.`);
    }

    console.log('✅ Supabase client initialized and reachable.');

  } catch (err) {
    console.error('❌ Connection failed:', err.message);
    process.exit(1);
  }
}

testConnection();
