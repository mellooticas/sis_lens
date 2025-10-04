/**
 * Server-side loader para página comercial
 * Carrega preços, descontos e configurações comerciais
 */
import type { PageServerLoad } from './$types';
import { DatabaseClient } from '$lib/database/client';

export const load: PageServerLoad = async ({ url }) => {
	try {
		const db = new DatabaseClient();
		
		// Parâmetros de filtro
		const laboratorio = url.searchParams.get('laboratorio') || '';
		const marca = url.searchParams.get('marca') || '';
		const status = url.searchParams.get('status') || 'ativo';
		const tipo = url.searchParams.get('tipo') || 'todos'; // precos, descontos, todos
		
		// Carregar dados comerciais
		const [
			precosResult,
			descontosResult,
			laboratoriosResult,
			marcasResult,
			estatisticasResult
		] = await Promise.all([
			// Preços vigentes
			db.listarPrecos({
				laboratorio,
				marca,
				status,
				incluirHistorico: false
			}),
			
			// Descontos ativos
			db.listarDescontos({
				laboratorio,
				marca,
				status
			}),
			
			// Laboratórios para filtro
			db.listarLaboratorios({ ativo: true }),
			
			// Marcas para filtro
			db.listarMarcas(),
			
			// Estatísticas comerciais
			db.obterEstatisticasComerciais()
		]);
		
		return {
			precos: precosResult.dados || [],
			descontos: descontosResult.dados || [],
			laboratorios: laboratoriosResult.dados || [],
			marcas: marcasResult.dados || [],
			estatisticas: estatisticasResult.dados || null,
			filtros: {
				laboratorio,
				marca,
				status,
				tipo
			}
		};
	} catch (error) {
		console.error('Erro ao carregar dados comerciais:', error);
		return {
			precos: [],
			descontos: [],
			laboratorios: [],
			marcas: [],
			estatisticas: null,
			filtros: { laboratorio: '', marca: '', status: 'ativo', tipo: 'todos' },
			erro: 'Erro ao carregar dados comerciais'
		};
	}
};