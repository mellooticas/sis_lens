import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
    process.env.VITE_SUPABASE_URL,
    process.env.VITE_SUPABASE_ANON_KEY
);

console.log('🧪 TESTANDO CONEXÃO DAS VIEWS BÁSICAS\n');
console.log('═══════════════════════════════════════════════════════════════\n');

async function testarViews() {
    console.log('🔍 Testando views criadas...\n');
    
    try {
        // 1. Testar view de lentes
        console.log('1️⃣ Testando vw_lentes_catalogo...');
        const { data: lentes, error: lentesError } = await supabase
            .from('vw_lentes_catalogo')
            .select('lente_id, sku_canonico, familia, marca_nome')
            .limit(3);
            
        if (lentesError) {
            console.log('❌ Erro na view vw_lentes_catalogo:', lentesError.message);
        } else {
            console.log('✅ View vw_lentes_catalogo funcionando!');
            console.log(`   ${lentes?.length || 0} lentes encontradas`);
            if (lentes?.[0]) {
                console.log(`   Exemplo: ${lentes[0].marca_nome} ${lentes[0].familia}`);
            }
        }
        
        console.log('');
        
        // 2. Testar view de fornecedores
        console.log('2️⃣ Testando vw_fornecedores...');
        const { data: fornecedores, error: fornecedoresError } = await supabase
            .from('vw_fornecedores')
            .select('id, nome, cnpj, credibilidade_score')
            .limit(3);
            
        if (fornecedoresError) {
            console.log('❌ Erro na view vw_fornecedores:', fornecedoresError.message);
        } else {
            console.log('✅ View vw_fornecedores funcionando!');
            console.log(`   ${fornecedores?.length || 0} fornecedores encontrados`);
            if (fornecedores?.[0]) {
                console.log(`   Exemplo: ${fornecedores[0].nome}`);
            }
        }
        
        console.log('');
        
        // 3. Testar view de decisões
        console.log('3️⃣ Testando decisoes_compra...');
        const { data: decisoes, error: decisoesError } = await supabase
            .from('decisoes_compra')
            .select('id, lente_recomendada_id, laboratorio_escolhido_id, status')
            .limit(3);
            
        if (decisoesError) {
            console.log('❌ Erro na view decisoes_compra:', decisoesError.message);
        } else {
            console.log('✅ View decisoes_compra funcionando!');
            console.log(`   ${decisoes?.length || 0} decisões encontradas`);
            if (decisoes?.[0]) {
                console.log(`   Exemplo: Decisão ${decisoes[0].id} - Status: ${decisoes[0].status}`);
            }
        }
        
        console.log('');
        
        // 4. Testar RPC de busca
        console.log('4️⃣ Testando rpc_buscar_lente...');
        const { data: busca, error: buscaError } = await supabase
            .rpc('rpc_buscar_lente', { 
                p_query: 'progressive',
                p_limit: 3
            });
            
        if (buscaError) {
            console.log('❌ Erro na RPC rpc_buscar_lente:', buscaError.message);
        } else {
            console.log('✅ RPC rpc_buscar_lente funcionando!');
            console.log(`   ${busca?.length || 0} resultados encontrados`);
            if (busca?.[0]) {
                console.log(`   Exemplo: ${busca[0].label}`);
            }
        }
        
        console.log('\n═══════════════════════════════════════════════════════════════');
        console.log('🎯 RESULTADO DOS TESTES:');
        console.log('');
        
        const sucessos = [
            !lentesError ? '✅ Catálogo de lentes' : '❌ Catálogo de lentes',
            !fornecedoresError ? '✅ Fornecedores' : '❌ Fornecedores', 
            !decisoesError ? '✅ Histórico de decisões' : '❌ Histórico de decisões',
            !buscaError ? '✅ Busca de lentes' : '❌ Busca de lentes'
        ];
        
        sucessos.forEach(resultado => console.log(resultado));
        
        const totalErros = [lentesError, fornecedoresError, decisoesError, buscaError]
            .filter(error => error !== null).length;
            
        if (totalErros === 0) {
            console.log('\n🎉 TODOS OS TESTES PASSARAM!');
            console.log('💡 Backend pronto para conectar ao sistema!');
        } else {
            console.log(`\n⚠️  ${totalErros} erro(s) encontrado(s)`);
            console.log('💡 Verificar se as views foram criadas corretamente');
        }
        
    } catch (error) {
        console.log('❌ Erro geral:', error);
    }
}

// Executar testes
testarViews();