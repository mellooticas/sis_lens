import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
    process.env.VITE_SUPABASE_URL,
    process.env.VITE_SUPABASE_ANON_KEY
);

console.log('🔍 TESTANDO VIEWS ESPECÍFICAS - CATÁLOGO E DECISÕES\n');

async function testarViewsEspecificas() {
    console.log('═══════════════════════════════════════════════════════');
    
    try {
        // 1. Testar vw_lentes_catalogo diretamente
        console.log('1️⃣ Testando vw_lentes_catalogo (select simples)...');
        const { data: catalogoData, error: catalogoError } = await supabase
            .from('vw_lentes_catalogo')
            .select('*')
            .limit(3);
            
        if (catalogoError) {
            console.log('❌ ERRO vw_lentes_catalogo:', catalogoError.message);
            console.log('   Código:', catalogoError.code);
            console.log('   Details:', catalogoError.details);
        } else {
            console.log('✅ vw_lentes_catalogo OK');
            console.log(`   ${catalogoData?.length || 0} registros encontrados`);
            if (catalogoData?.[0]) {
                console.log('   Exemplo:', {
                    id: catalogoData[0].lente_id?.substring(0, 8) + '...',
                    sku: catalogoData[0].sku_canonico,
                    marca: catalogoData[0].marca_nome,
                    familia: catalogoData[0].familia
                });
            }
        }
        
        console.log('');
        
        // 2. Testar decisoes_compra diretamente
        console.log('2️⃣ Testando decisoes_compra (select simples)...');
        const { data: decisoesData, error: decisoesError } = await supabase
            .from('decisoes_compra')
            .select('*')
            .limit(3);
            
        if (decisoesError) {
            console.log('❌ ERRO decisoes_compra:', decisoesError.message);
            console.log('   Código:', decisoesError.code);
            console.log('   Details:', decisoesError.details);
        } else {
            console.log('✅ decisoes_compra OK');
            console.log(`   ${decisoesData?.length || 0} registros encontrados`);
            if (decisoesData?.[0]) {
                console.log('   Exemplo:', {
                    id: decisoesData[0].id?.substring(0, 8) + '...',
                    status: decisoesData[0].status,
                    criterio: decisoesData[0].criterio_usado,
                    preco: decisoesData[0].preco_final
                });
            }
        }
        
        console.log('');
        console.log('═══════════════════════════════════════════════════════');
        
        // 3. Testar com range (como no listarLentes)
        console.log('3️⃣ Testando vw_lentes_catalogo com range...');
        const { data: catalogoRange, error: catalogoRangeError, count } = await supabase
            .from('vw_lentes_catalogo')
            .select('*', { count: 'exact' })
            .range(0, 9); // page 1, 10 items
            
        if (catalogoRangeError) {
            console.log('❌ ERRO vw_lentes_catalogo com range:', catalogoRangeError.message);
        } else {
            console.log('✅ vw_lentes_catalogo com range OK');
            console.log(`   ${catalogoRange?.length || 0} registros retornados`);
            console.log(`   ${count || 0} total de registros`);
        }
        
        console.log('');
        console.log('💡 DIAGNÓSTICO:');
        const catalogoOK = !catalogoError && !catalogoRangeError;
        const decisoesOK = !decisoesError;
        
        if (catalogoOK) {
            console.log('✅ View vw_lentes_catalogo: FUNCIONANDO');
        } else {
            console.log('❌ View vw_lentes_catalogo: PROBLEMA');
        }
        
        if (decisoesOK) {
            console.log('✅ View decisoes_compra: FUNCIONANDO');  
        } else {
            console.log('❌ View decisoes_compra: PROBLEMA');
        }
        
        if (!catalogoOK || !decisoesOK) {
            console.log('');
            console.log('🔧 AÇÃO NECESSÁRIA:');
            console.log('   Execute as views no Supabase Dashboard:');
            console.log('   - views_basicas.sql');
        }
        
    } catch (error) {
        console.log('❌ Erro geral:', error);
    }
}

testarViewsEspecificas();