import { createClient } from '@supabase/supabase-js';
import fs from 'fs';

const supabaseUrl = 'https://mhgbuplnxtfgipbemchb.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oZ2J1cGxueHRmZ2lwYmVtY2hiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwODAwMDQsImV4cCI6MjA1OTY1NjAwNH0.478ltLNyzDefQFZjnMHxuM2Qk8Aw8lsIpIrdb-h7rl0';
const supabase = createClient(supabaseUrl, supabaseKey);

async function run() {
    const { data: lenses, error: error1 } = await supabase
        .from('lenses')
        .select('spherical_min, spherical_max, cylindrical_min, cylindrical_max, addition_min, addition_max')
        .limit(100);

    const { data: counts, error: error2 } = await supabase
        .rpc('rpc_debug_ranges', {}); // Hypothetical, let's just do a count

    const results = {
        lensesSample: lenses,
        errors: { error1, error2 }
    };

    fs.writeFileSync('debug_output.json', JSON.stringify(results, null, 2));
}

run();
