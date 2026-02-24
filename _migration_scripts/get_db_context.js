import { createClient } from '@supabase/supabase-js';
import fs from 'fs';

const supabaseUrl = 'https://mhgbuplnxtfgipbemchb.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oZ2J1cGxueHRmZ2lwYmVtY2hiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwODAwMDQsImV4cCI6MjA1OTY1NjAwNH0.478ltLNyzDefQFZjnMHxuM2Qk8Aw8lsIpIrdb-h7rl0';
const supabase = createClient(supabaseUrl, supabaseKey);

async function run() {
    const { data: brands } = await supabase.from('v_inventory_brands').select('id, name');
    const { data: suppliers } = await supabase.from('suppliers').select('id, name');

    const context = {
        brands: brands || [],
        suppliers: suppliers || []
    };

    fs.writeFileSync('db_context.json', JSON.stringify(context, null, 2));
    console.log('db_context.json generated');
}

run();
