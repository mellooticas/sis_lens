
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error('Missing Supabase credentials');
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

const id = '82cee871-8c04-4841-b3b9-7ca6d1d1286a'; // Lens ID from user log

async function diagnose() {
    console.log(`Checking lens ${id}...`);

    // 1. Check Ophthalmic View
    let { data: oph, error: ophErr } = await supabase.from('v_lentes').select('*').eq('id', id).single();

    if (oph) {
        console.log('✅ TYPE: Ophthalmic Lens (lens_catalog.lentes)');
        console.log('Current State:', {
            preco_custo: oph.preco_custo,
            preco_venda_sugerido: oph.preco_venda_sugerido,
            ativo: oph.ativo
        });

        // 2. Try RPC Call
        const newPrice = (oph.preco_venda_sugerido || 0) + 1.5;
        console.log(`👉 Attempting RPC update_lente_catalog... Setting Preco Venda to ${newPrice}`);

        const { error: rpcErr } = await supabase.rpc('update_lente_catalog', {
            p_id: id,
            p_preco_custo: oph.preco_custo || 0,
            p_preco_venda: newPrice,
            p_ativo: true
        });

        if (rpcErr) {
            console.error('❌ RPC Failed:', rpcErr);
        } else {
            console.log('✅ RPC executed (no error returned).');

            // 3. Verify Update
            const { data: updated } = await supabase.from('v_lentes').select('*').eq('id', id).single();
            console.log('New State:', {
                preco_custo: updated.preco_custo,
                preco_venda_sugerido: updated.preco_venda_sugerido
            });

            if (updated.preco_venda_sugerido == newPrice) {
                console.log('🎉 SUCCESS: Database updated!');
            } else {
                console.log('⚠️ FAILURE: Value did NOT change. (Check Triggers or Permissions)');
            }
        }

    } else {
        console.log('❌ Not found in v_lentes. Checking contact lenses...');

        // Check Contact View
        let { data: con, error: conErr } = await supabase.from('v_lentes_contato').select('*').eq('id', id).single();

        if (con) {
            console.log('✅ TYPE: Contact Lens (contact_lens.lentes)');
            console.log('Current State:', {
                preco_custo: con.preco_custo,
                preco_tabela: con.preco_tabela,
                ativo: con.ativo
            });

            // Test RPC
            const newPrice = (con.preco_tabela || 0) + 2.5;
            console.log(`👉 Attempting RPC update_lente_contact... Setting Preco Tabela to ${newPrice}`);

            const { error: rpcErr } = await supabase.rpc('update_lente_contact', {
                p_id: id,
                p_preco_custo: con.preco_custo || 0,
                p_preco_tabela: newPrice,
                p_ativo: true
            });

            if (rpcErr) {
                console.error('❌ RPC Failed:', rpcErr);
            } else {
                const { data: updated } = await supabase.from('v_lentes_contato').select('*').eq('id', id).single();
                console.log('New State:', { preco_tabela: updated.preco_tabela });
                if (updated.preco_tabela == newPrice) {
                    console.log('🎉 SUCCESS: Database updated!');
                } else {
                    console.log('⚠️ FAILURE: Value did NOT change.');
                }
            }

        } else {
            console.error('❌ ID not found in either view. Is it deleted or inactive?');
        }
    }
}

diagnose();
