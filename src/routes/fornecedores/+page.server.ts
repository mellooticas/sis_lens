/**
 * Server-side loader para página de fornecedores
 * Carrega lista de laboratórios com métricas de performance
 */
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url }) => {
	try {
		// Parâmetros de query
		const busca = url.searchParams.get('busca') || '';
		const regiao = url.searchParams.get('regiao') || '';
		const status = url.searchParams.get('status') || 'ativo';
		
		return {
			fornecedores: [],
			estatisticas: null,
			regioes: [],
			filtros: {
				busca,
				regiao,
				status
			}
		};
	} catch (error) {
		console.error('Erro ao carregar fornecedores:', error);
		return {
			fornecedores: [],
			estatisticas: null,
			regioes: [],
			filtros: { busca: '', regiao: '', status: 'ativo' },
			erro: 'Erro ao carregar dados dos fornecedores'
		};
	}
};