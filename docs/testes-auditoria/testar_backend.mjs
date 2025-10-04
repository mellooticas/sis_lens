import { LensCatalogService } from './src/lib/database/client.ts';

console.log('🧪 TESTANDO SERVIÇOS DO BACKEND BESTLENS\n');
console.log('═══════════════════════════════════════════════════════════════\n');

async function testarBackend() {
    try {
        console.log('🔍 Testando LensCatalogService...\n');
        
        // 1. Testar busca de lentes
        console.log('1️⃣ Testando busca de lentes...');
        const resultadoBusca = await LensCatalogService.searchLenses('progressive', 5);
        console.log(`✅ Busca funcionando! ${resultadoBusca.length} resultados`);
        if (resultadoBusca[0]) {
            console.log(`   Exemplo: ${resultadoBusca[0].label}`);
        }
        console.log('');
        
        // 2. Testar catálogo
        console.log('2️⃣ Testando catálogo completo...');
        const catalogo = await LensCatalogService.getCatalog(3);
        console.log(`✅ Catálogo funcionando! ${catalogo.length} lentes`);
        if (catalogo[0]) {
            console.log(`   Exemplo: ${catalogo[0].marca_nome} ${catalogo[0].familia}`);
        }
        console.log('');
        
        // 3. Testar fornecedores
        console.log('3️⃣ Testando fornecedores...');
        const fornecedores = await LensCatalogService.getSuppliers(3);
        console.log(`✅ Fornecedores funcionando! ${fornecedores.length} laboratórios`);
        if (fornecedores[0]) {
            console.log(`   Exemplo: ${fornecedores[0].nome} (Score: ${fornecedores[0].credibilidade_score})`);
        }
        console.log('');
        
        console.log('═══════════════════════════════════════════════════════════════');
        console.log('🎉 BACKEND TOTALMENTE CONECTADO!');
        console.log('');
        console.log('✅ LensCatalogService → Funcionando');
        console.log('✅ Views públicas → Acessíveis');
        console.log('✅ Supabase → Conectado');
        console.log('');
        console.log('🚀 Sistema pronto para uso completo!');
        
    } catch (error) {
        console.log('❌ Erro no backend:', error.message);
        console.log('💡 Verifique se as views foram criadas no Supabase');
    }
}

// Executar teste
testarBackend();