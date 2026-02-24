const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const supabaseUrl = 'https://mhgbuplnxtfgipbemchb.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oZ2J1cGxueHRmZ2lwYmVtY2hiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwODAwMDQsImV4cCI6MjA1OTY1NjAwNH0.478ltLNyzDefQFZjnMHxuM2Qk8Aw8lsIpIrdb-h7rl0';
const supabase = createClient(supabaseUrl, supabaseKey);

async function run() {
    const { data, error } = await supabase
        .from('lenses')
        .select('spherical_min, spherical_max, cylindrical_min, cylindrical_max')
        .not('spherical_min', 'is', null)
        .limit(10);

    if (error) {
        console.error(error);
        fs.writeFileSync('output.json', JSON.stringify(error));
    } else {
        console.log(data);
        fs.writeFileSync('output.json', JSON.stringify(data));
    }
}

run();
