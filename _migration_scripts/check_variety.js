import { createClient } from '@supabase/supabase-js';
import fs from 'fs';

const supabaseUrl = 'https://mhgbuplnxtfgipbemchb.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oZ2J1cGxueHRmZ2lwYmVtY2hiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwODAwMDQsImV4cCI6MjA1OTY1NjAwNH0.478ltLNyzDefQFZjnMHxuM2Qk8Aw8lsIpIrdb-h7rl0';
const supabase = createClient(supabaseUrl, supabaseKey); // Default schema is public

async function run() {
    const { data: lenses, error } = await supabase
        .from('v_catalog_lenses')
        .select('spherical_min, spherical_max, cylindrical_min, cylindrical_max')
        .limit(200);

    if (error) {
        console.error(error);
        fs.writeFileSync('variety_check.json', JSON.stringify({ error }));
        return;
    }

    const uniqueRanges = new Set();
    lenses.forEach(l => {
        const key = `${l.spherical_min}|${l.spherical_max}|${l.cylindrical_min}|${l.cylindrical_max}`;
        uniqueRanges.add(key);
    });

    fs.writeFileSync('variety_check.json', JSON.stringify({
        totalLenses: lenses.length,
        uniqueRangesCount: uniqueRanges.size,
        uniqueRanges: Array.from(uniqueRanges),
        sample: lenses.slice(0, 10)
    }, null, 2));
}

run();
