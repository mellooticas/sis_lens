
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

const idToCheck = 'df5ea5c4-37e5-4fba-933d-f24b2c3fae48'; // Ophthalmic lens from user message
const idContact = '7eddbadd-36f1-4a64-8ef4-45ef6fe29f13'; // Contact lens from user message

async function check() {
    console.log('--- Checking Ophthalmic Lens ---');
    // Check directly in table if RLS allows, or via RPC/View
    const { data: lens, error: lensError } = await supabase
        .from('v_lentes')
        .select('*')
        .eq('id', idToCheck)
        .single();

    if (lensError) console.error('Error finding ophthalmic lens:', lensError.message);
    else console.log('Found v_lentes:', { id: lens.id, preco_venda_sugerido: lens.preco_venda_sugerido, ativo: lens.ativo });

    console.log('\n--- Checking Contact Lens ---');
    const { data: contact, error: contactError } = await supabase
        .from('v_lentes_contato')
        .select('*')
        .eq('id', idContact)
        .single();

    if (contactError) console.error('Error finding contact lens:', contactError.message);
    else console.log('Found v_lentes_contato:', { id: contact.id, preco_tabela: contact.preco_tabela, ativo: contact.ativo });

    // Test RPC Call for Contact Lens
    if (contact) {
        console.log('\n--- Testing update_lente_contact RPC ---');
        const newPrice = (contact.preco_tabela || 0) + 1;
        console.log(`Attribute new price: ${newPrice}`);

        const { error: rpcError } = await supabase.rpc('update_lente_contact', {
            p_id: contact.id,
            p_preco_custo: contact.preco_custo || 0,
            p_preco_tabela: newPrice,
            p_ativo: true // Force active to avoid disappearance
        });

        if (rpcError) {
            console.error('RPC Error:', rpcError);
        } else {
            console.log('RPC Success. Verifying change...');
            const { data: updated } = await supabase.from('v_lentes_contato').select('*').eq('id', idContact).single();
            console.log('Updated contact lens:', { id: updated.id, preco_tabela: updated.preco_tabela });

            if (updated.preco_tabela === newPrice) {
                console.log('✅ RPC works!');
            } else {
                console.log('❌ Value did not change.');
            }
        }
    }
}

check();
