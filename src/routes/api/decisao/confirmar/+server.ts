/**
 * API: Confirmar Decisão de Compra
 * Endpoint: POST /api/decisao/confirmar
 * 
 * Confirma uma decisão de compra e registra no histórico
 * Chama rpc_confirmar_decisao do Supabase
 */
import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { supabase } from '$lib/supabase';
import { DatabaseClient } from '$lib/database/client';

export const POST: RequestHandler = async ({ request }) => {
	try {
		// Parse do body
		const body = await request.json();
		const { 
			lente_id, 
			laboratorio_id, 
			criterio, 
			observacoes 
		} = body;

		// Validação básica
		if (!lente_id || !laboratorio_id || !criterio) {
			return json({ 
				error: 'Parâmetros obrigatórios: lente_id, laboratorio_id, criterio' 
			}, { status: 400 });
		}

		// Validar critério
		if (!['URGENCIA', 'NORMAL', 'ESPECIAL'].includes(criterio)) {
			return json({ 
				error: 'Critério deve ser: URGENCIA, NORMAL ou ESPECIAL' 
			}, { status: 400 });
		}

		// Verificar autenticação
		const { data: { session }, error: sessionError } = await supabase.auth.getSession();
		if (sessionError || !session?.user) {
			return json({ error: 'Não autorizado' }, { status: 401 });
		}

		// Inicializar cliente do banco
		const db = new DatabaseClient();

		// Chamar RPC para confirmar decisão
		const { data, error } = await supabase.rpc('criar_decisao_lente', {
			p_lente_id: lente_id,
			p_laboratorio_id: laboratorio_id,
			p_criterio: criterio,
			p_observacoes: observacoes || null
		});

		if (error) {
			console.error('Erro ao confirmar decisão:', error);
			return json({ 
				error: 'Erro ao confirmar decisão',
				detalhes: error.message 
			}, { status: 500 });
		}

		// Retornar sucesso com ID da decisão
		return json({
			sucesso: true,
			decisao_id: data?.decisao_id,
			mensagem: 'Decisão confirmada com sucesso',
			dados: data
		});

	} catch (error) {
		console.error('Erro na API de confirmação de decisão:', error);
		
		return json({
			error: 'Erro interno do servidor',
			detalhes: error instanceof Error ? error.message : 'Erro desconhecido'
		}, { status: 500 });
	}
};