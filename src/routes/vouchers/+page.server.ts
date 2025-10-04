/**
 * Server-side loader para página de vouchers
 * Carrega vouchers, cupons e sistema de pontuação
 */
import type { PageServerLoad } from './$types';
import { DatabaseClient } from '$lib/database/client';

export const load: PageServerLoad = async ({ url }) => {
	try {
		const db = new DatabaseClient();
		
		// Parâmetros de filtro
		const status = url.searchParams.get('status') || 'ativo';
		const tipo = url.searchParams.get('tipo') || 'todos';
		const busca = url.searchParams.get('busca') || '';
		
		// Carregar dados de vouchers
		const [
			vouchersResult,
			estatisticasResult,
			transacoesResult,
			configuracoesResult
		] = await Promise.all([
			// Vouchers disponíveis
			db.listarVouchers({
				status,
				tipo,
				busca
			}),
			
			// Estatísticas do programa
			db.obterEstatisticasVouchers(),
			
			// Transações recentes
			db.listarTransacoesVouchers({ limite: 10 }),
			
			// Configurações do programa
			db.obterConfiguracoesVouchers()
		]);
		
		return {
			vouchers: vouchersResult.dados || [],
			estatisticas: estatisticasResult.dados || null,
			transacoes: transacoesResult.dados || [],
			configuracoes: configuracoesResult.dados || null,
			filtros: {
				status,
				tipo,
				busca
			}
		};
	} catch (error) {
		console.error('Erro ao carregar vouchers:', error);
		return {
			vouchers: [],
			estatisticas: null,
			transacoes: [],
			configuracoes: null,
			filtros: { status: 'ativo', tipo: 'todos', busca: '' },
			erro: 'Erro ao carregar dados de vouchers'
		};
	}
};