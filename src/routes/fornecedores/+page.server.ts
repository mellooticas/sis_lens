/**
 * Server-side loader para página de fornecedores
 * Carrega lista de laboratórios com métricas de performance
 */
import type { PageServerLoad } from './$types';
import { DatabaseClient } from '$lib/database/client';

export const load: PageServerLoad = async ({ url }) => {
	try {
		const db = new DatabaseClient();
		
		// Parâmetros de query
		const busca = url.searchParams.get('busca') || '';
		const regiao = url.searchParams.get('regiao') || '';
		const status = url.searchParams.get('status') || 'ativo';
		
		// Carregar fornecedores com métricas
		const fornecedores = await db.listarFornecedores({
			busca,
			regiao,
			status,
			incluirMetricas: true
		});
		
		// Carregar estatísticas gerais
		const estatisticas = await db.obterEstatisticasFornecedores();
		
		// Carregar regiões disponíveis para filtro
		const regioes = await db.listarRegioes();
		
		return {
			fornecedores: fornecedores.dados || [],
			estatisticas: estatisticas.dados || null,
			regioes: regioes.dados || [],
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