
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const supabase = createClient(process.env.VITE_SUPABASE_URL, process.env.VITE_SUPABASE_ANON_KEY);

async function inspect() {
    console.log('--- Inspecting lens_catalog.lentes structure ---');

    // 1. Check Columns
    const { data: cols, error: colErr } = await supabase
        .rpc('get_column_info', { p_table: 'lentes', p_schema: 'lens_catalog' });

    // Since we can't easily call SQL queries to information_schema without a helper RPC or service key hacking,
    // we will try to infer from behavior or assume standard setup.
    // Actually, we can use the `rpc` tool if we had a generic sql exec rpc, but we dont.

    // Let's try to infer if 'update_lente_catalog' source code contains 'DISABLE TRIGGER'.
    // We can't easily see source code from client.

    // We will assume the script 'debug_verify_update.js' failed because the SQL V2 was NOT applied.
    // But let's verify if `preco_tabela` is a generated column by trying to update it via a different mock RPC that catches the error.

    console.log('Attempting to create a temp RPC to test direct update (simulated via existing one)');

    // We will re-run the debug logic but check if 'updated_at' changed.
    const id = '82cee871-8c04-4841-b3b9-7ca6d1d1286a';
    const { data: pre } = await supabase.from('v_lentes').select('updated_at, preco_venda_sugerido').eq('id', id).single();
    console.log('Pre-Update:', pre);

    const { error } = await supabase.rpc('update_lente_catalog', {
        p_id: id,
        p_preco_custo: 50, // Force a COST change too
        p_preco_venda: 500,
        p_ativo: true
    });

    const { data: post } = await supabase.from('v_lentes').select('updated_at, preco_venda_sugerido, preco_custo').eq('id', id).single();
    console.log('Post-Update:', post);

    if (pre.updated_at !== post.updated_at) {
        console.log('✅ Updated_at CHANGED. The record WAS updated.');
    } else {
        console.log('❌ Updated_at SAME. The record was NOT touched (or rolled back).');
    }
}

inspect();
