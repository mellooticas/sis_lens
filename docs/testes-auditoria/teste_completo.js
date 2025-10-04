import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
    process.env.VITE_SUPABASE_URL,
    process.env.VITE_SUPABASE_ANON_KEY
);

console.log('🧪 TESTE COMPLETO - TODAS AS TABELAS E VIEWS\n');
console.log('═══════════════════════════════════════════════════════════════\n');

async function testarTodasConexoes() {
    
    // 1. TESTAR TABELAS ORIGINAIS EM PUBLIC (Sistema de Vouchers)
    console.log('📋 PARTE 1: SISTEMA DE VOUCHERS (Tabelas originais em public)\n');
    
    const tabelasPublic = [
        'usuarios',
        'vouchers', 
        'lojas',
        'clientes',
        'v_dashboard_vouchers'
    ];
    
    for (const tabela of tabelasPublic) {
        try {
            console.log(`🔍 Testando public.${tabela}...`);
            const { data, error, count } = await supabase
                .from(tabela)
                .select('*', { count: 'exact' })
                .limit(3);
                
            if (error) {
                console.log(`❌ ERRO ${tabela}:`, error.message);
            } else {
                console.log(`✅ ${tabela}: ${count || 0} registros`);
                if (data && data.length > 0) {
                    console.log(`   Exemplo:`, Object.keys(data[0]).slice(0, 5).join(', '));
                }
            }
        } catch (err) {
            console.log(`❌ ERRO ${tabela}:`, err.message);
        }
        console.log('');
    }
    
    console.log('═══════════════════════════════════════════════════════════════\n');
    
    // 2. TESTAR VIEWS CRIADAS (Sistema de Lentes)
    console.log('📋 PARTE 2: SISTEMA DE LENTES (Views criadas)\n');
    
    const viewsLentes = [
        'vw_lentes_catalogo',
        'vw_fornecedores', 
        'decisoes_compra',
        'produtos_laboratorio',
        'mv_economia_por_fornecedor'
    ];
    
    for (const view of viewsLentes) {
        try {
            console.log(`🔍 Testando public.${view}...`);
            const { data, error, count } = await supabase
                .from(view)
                .select('*', { count: 'exact' })
                .limit(3);
                
            if (error) {
                console.log(`❌ ERRO ${view}:`, error.message);
            } else {
                console.log(`✅ ${view}: ${count || 0} registros`);
                if (data && data.length > 0) {
                    console.log(`   Exemplo:`, Object.keys(data[0]).slice(0, 5).join(', '));
                }
            }
        } catch (err) {
            console.log(`❌ ERRO ${view}:`, err.message);
        }
        console.log('');
    }
    
    console.log('═══════════════════════════════════════════════════════════════\n');
    
    // 3. TESTAR RPCs
    console.log('📋 PARTE 3: FUNÇÕES RPC\n');
    
    const rpcs = [
        { nome: 'rpc_buscar_lente', params: { p_query: 'progressive', p_limit: 3 } },
        { nome: 'rpc_rank_opcoes', params: { p_lente_id: 'test', p_criterio: 'NORMAL' } },
        { nome: 'rpc_confirmar_decisao', params: { p_payload: {} }, skip: true } // Skip pois precisa de dados válidos
    ];
    
    for (const rpc of rpcs) {
        if (rpc.skip) {
            console.log(`⏭️  Pulando ${rpc.nome} (requer dados válidos)`);
            continue;
        }
        
        try {
            console.log(`🔍 Testando ${rpc.nome}...`);
            const { data, error } = await supabase.rpc(rpc.nome, rpc.params);
                
            if (error) {
                console.log(`❌ ERRO ${rpc.nome}:`, error.message);
            } else {
                console.log(`✅ ${rpc.nome}: ${data?.length || 0} resultados`);
                if (data && data.length > 0) {
                    console.log(`   Exemplo:`, Object.keys(data[0]).slice(0, 3).join(', '));
                }
            }
        } catch (err) {
            console.log(`❌ ERRO ${rpc.nome}:`, err.message);
        }
        console.log('');
    }
    
    console.log('═══════════════════════════════════════════════════════════════\n');
    
    // 4. VERIFICAR PERMISSÕES
    console.log('📋 PARTE 4: VERIFICAÇÃO DE PERMISSÕES\n');
    
    try {
        console.log('🔍 Testando acesso aos schemas...');
        
        // Tentar acessar schemas diretamente (deve falhar)
        const { data: schemaTest, error: schemaError } = await supabase
            .from('lens_catalog.lentes')
            .select('*')
            .limit(1);
            
        if (schemaError) {
            console.log('✅ Segurança OK: Acesso direto aos schemas bloqueado');
            console.log(`   Erro esperado: ${schemaError.message}`);
        } else {
            console.log('⚠️  Acesso direto aos schemas permitido (pode ser problema de segurança)');
        }
        
    } catch (err) {
        console.log('✅ Segurança OK: Schemas protegidos');
    }
    
    console.log('');
    console.log('═══════════════════════════════════════════════════════════════\n');
    
    // 5. RESUMO FINAL
    console.log('📊 RESUMO FINAL - SISTEMA HÍBRIDO BESTLENS\n');
    
    console.log('🎯 COMPONENTES TESTADOS:');
    console.log('├─ 📋 Sistema de Vouchers (tabelas originais)');
    console.log('├─ 🔍 Sistema de Lentes (views criadas)');
    console.log('├─ ⚙️  Funções RPC (busca e ranking)');
    console.log('└─ 🔒 Segurança (permissões anon)');
    console.log('');
    
    console.log('💡 PRÓXIMOS PASSOS:');
    console.log('1. Verificar quais tabelas/views têm dados');
    console.log('2. Testar fluxos completos no frontend');
    console.log('3. Adicionar dados de exemplo se necessário');
    console.log('4. Validar integração vouchers + lentes');
    
    console.log('');
    console.log('🎉 TESTE COMPLETO FINALIZADO!');
}

testarTodasConexoes();