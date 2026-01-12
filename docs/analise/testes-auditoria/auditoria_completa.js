import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
    process.env.VITE_SUPABASE_URL,
    process.env.VITE_SUPABASE_ANON_KEY
);

console.log('🔍 AUDITORIA COMPLETA - TODAS AS VIEWS E TABELAS EM PUBLIC\n');
console.log('═══════════════════════════════════════════════════════════════\n');

async function auditoriaCompleta() {
    
    // Lista de TODAS as tabelas/views que deveriam existir em public
    const estruturasPublic = [
        // SISTEMA DE VOUCHERS (tabelas originais)
        { nome: 'usuarios', tipo: 'tabela', categoria: 'vouchers' },
        { nome: 'lojas', tipo: 'tabela', categoria: 'vouchers' },
        { nome: 'clientes', tipo: 'tabela', categoria: 'vouchers' },
        { nome: 'vouchers', tipo: 'tabela', categoria: 'vouchers' },
        { nome: 'v_dashboard_vouchers', tipo: 'view', categoria: 'vouchers' },
        
        // SISTEMA DE LENTES (views criadas)
        { nome: 'vw_lentes_catalogo', tipo: 'view', categoria: 'lentes' },
        { nome: 'vw_fornecedores', tipo: 'view', categoria: 'lentes' },
        { nome: 'decisoes_compra', tipo: 'view', categoria: 'lentes' },
        { nome: 'produtos_laboratorio', tipo: 'view', categoria: 'lentes' },
        { nome: 'mv_economia_por_fornecedor', tipo: 'view', categoria: 'lentes' },
        
        // POSSÍVEIS TABELAS ADICIONAIS
        { nome: 'configuracoes', tipo: 'tabela', categoria: 'config' },
        { nome: 'logs', tipo: 'tabela', categoria: 'sistema' },
        { nome: 'relatorios', tipo: 'tabela', categoria: 'analytics' }
    ];
    
    const rpcs = [
        { nome: 'rpc_buscar_lente', params: { p_query: 'varilux', p_limit: 5 } },
        { nome: 'rpc_rank_opcoes', params: null }, // Testar se existe
        { nome: 'rpc_confirmar_decisao', params: null } // Testar se existe
    ];
    
    console.log('📊 TESTANDO ESTRUTURAS EM PUBLIC:\n');
    
    const resultados = {
        funcionando: [],
        com_dados: [],
        vazias: [],
        com_problemas: [],
        nao_existe: []
    };
    
    for (const estrutura of estruturasPublic) {
        try {
            console.log(`🔍 ${estrutura.categoria.toUpperCase()} | ${estrutura.nome}...`);
            
            const { data, error, count } = await supabase
                .from(estrutura.nome)
                .select('*', { count: 'exact' })
                .limit(3);
            
            if (error) {
                // Analizar tipo de erro
                if (error.message.includes('does not exist') || 
                    error.message.includes('Could not find the table')) {
                    console.log(`❌ NÃO EXISTE: ${estrutura.nome}`);
                    resultados.nao_existe.push(estrutura);
                } else if (error.message.includes('infinite recursion') ||
                          error.message.includes('policy')) {
                    console.log(`⚠️  PROBLEMA DE POLÍTICAS: ${estrutura.nome}`);
                    console.log(`   Erro: ${error.message.substring(0, 80)}...`);
                    resultados.com_problemas.push({ ...estrutura, erro: error.message });
                } else {
                    console.log(`❌ ERRO: ${estrutura.nome} - ${error.message.substring(0, 50)}...`);
                    resultados.com_problemas.push({ ...estrutura, erro: error.message });
                }
            } else {
                resultados.funcionando.push(estrutura);
                if (count > 0) {
                    console.log(`✅ OK: ${estrutura.nome} (${count} registros)`);
                    resultados.com_dados.push({ ...estrutura, count });
                    
                    // Mostrar exemplo dos dados
                    if (data && data.length > 0) {
                        const colunas = Object.keys(data[0]).slice(0, 4).join(', ');
                        console.log(`   Colunas: ${colunas}`);
                    }
                } else {
                    console.log(`✅ OK: ${estrutura.nome} (vazia)`);
                    resultados.vazias.push(estrutura);
                }
            }
        } catch (err) {
            console.log(`❌ ERRO GERAL: ${estrutura.nome} - ${err.message}`);
            resultados.com_problemas.push({ ...estrutura, erro: err.message });
        }
        console.log('');
    }
    
    console.log('═══════════════════════════════════════════════════════════════\n');
    console.log('📋 TESTANDO FUNÇÕES RPC:\n');
    
    const rpcsResultados = { funcionando: [], com_problemas: [], nao_existe: [] };
    
    for (const rpc of rpcs) {
        try {
            console.log(`🔍 RPC: ${rpc.nome}...`);
            
            if (rpc.params) {
                const { data, error } = await supabase.rpc(rpc.nome, rpc.params);
                
                if (error) {
                    if (error.message.includes('does not exist') ||
                        error.message.includes('Could not find the function')) {
                        console.log(`❌ NÃO EXISTE: ${rpc.nome}`);
                        rpcsResultados.nao_existe.push(rpc);
                    } else {
                        console.log(`⚠️  PROBLEMA: ${rpc.nome} - ${error.message.substring(0, 60)}...`);
                        rpcsResultados.com_problemas.push({ ...rpc, erro: error.message });
                    }
                } else {
                    console.log(`✅ OK: ${rpc.nome} (${data?.length || 0} resultados)`);
                    rpcsResultados.funcionando.push(rpc);
                }
            } else {
                // Só testar se a função existe
                try {
                    await supabase.rpc(rpc.nome, {});
                    console.log(`✅ EXISTE: ${rpc.nome}`);
                    rpcsResultados.funcionando.push(rpc);
                } catch (err) {
                    if (err.message.includes('does not exist')) {
                        console.log(`❌ NÃO EXISTE: ${rpc.nome}`);
                        rpcsResultados.nao_existe.push(rpc);
                    } else {
                        console.log(`✅ EXISTE: ${rpc.nome} (erro nos parâmetros é normal)`);
                        rpcsResultados.funcionando.push(rpc);
                    }
                }
            }
        } catch (err) {
            console.log(`❌ ERRO: ${rpc.nome} - ${err.message}`);
            rpcsResultados.com_problemas.push({ ...rpc, erro: err.message });
        }
        console.log('');
    }
    
    console.log('═══════════════════════════════════════════════════════════════\n');
    console.log('📊 RELATÓRIO FINAL:\n');
    
    console.log(`✅ FUNCIONANDO (${resultados.funcionando.length}):`);
    resultados.funcionando.forEach(item => {
        const status = resultados.com_dados.find(d => d.nome === item.nome) ? 
            `COM DADOS (${resultados.com_dados.find(d => d.nome === item.nome).count})` : 'VAZIA';
        console.log(`   ${item.categoria} | ${item.nome} - ${status}`);
    });
    
    console.log(`\n❌ NÃO EXISTEM (${resultados.nao_existe.length}):`);
    resultados.nao_existe.forEach(item => {
        console.log(`   ${item.categoria} | ${item.nome} - PRECISA CRIAR`);
    });
    
    console.log(`\n⚠️  COM PROBLEMAS (${resultados.com_problemas.length}):`);
    resultados.com_problemas.forEach(item => {
        console.log(`   ${item.categoria} | ${item.nome} - ${item.erro.substring(0, 60)}...`);
    });
    
    console.log(`\n🔧 RPCS:`);
    console.log(`   Funcionando: ${rpcsResultados.funcionando.length}`);
    console.log(`   Não existem: ${rpcsResultados.nao_existe.length}`);
    console.log(`   Com problemas: ${rpcsResultados.com_problemas.length}`);
    
    console.log('\n═══════════════════════════════════════════════════════════════\n');
    console.log('🎯 PRÓXIMAS AÇÕES NECESSÁRIAS:\n');
    
    if (resultados.nao_existe.length > 0) {
        console.log('1. CRIAR ESTRUTURAS FALTANTES:');
        resultados.nao_existe.forEach(item => {
            console.log(`   - ${item.tipo}: ${item.nome} (${item.categoria})`);
        });
        console.log('');
    }
    
    if (resultados.com_problemas.length > 0) {
        console.log('2. RESOLVER PROBLEMAS:');
        resultados.com_problemas.forEach(item => {
            if (item.erro.includes('policy') || item.erro.includes('recursion')) {
                console.log(`   - ${item.nome}: Corrigir políticas RLS`);
            } else {
                console.log(`   - ${item.nome}: ${item.erro.substring(0, 40)}...`);
            }
        });
        console.log('');
    }
    
    if (rpcsResultados.nao_existe.length > 0) {
        console.log('3. CRIAR RPCS FALTANTES:');
        rpcsResultados.nao_existe.forEach(rpc => {
            console.log(`   - ${rpc.nome}`);
        });
        console.log('');
    }
    
    const percentualFuncionando = Math.round((resultados.funcionando.length / estruturasPublic.length) * 100);
    console.log(`📈 STATUS GERAL: ${percentualFuncionando}% das estruturas funcionando`);
    
    if (percentualFuncionando >= 80) {
        console.log('🎉 SISTEMA QUASE COMPLETO! Poucos ajustes necessários.');
    } else if (percentualFuncionando >= 60) {
        console.log('👍 SISTEMA PARCIALMENTE FUNCIONAL. Algumas estruturas precisam ser criadas.');
    } else {
        console.log('⚠️  SISTEMA PRECISA DE MAIS TRABALHO. Muitas estruturas faltando.');
    }
}

auditoriaCompleta();