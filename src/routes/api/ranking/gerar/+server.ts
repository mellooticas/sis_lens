/**
 * API Route - Gerar Ranking
 * Endpoint AJAX para ranking em tempo real
 */

import { RankingService, LentesService } from '$lib/api';
import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const POST: RequestHandler = async ({ request }) => {
  try {
    const { lente_id, criterio, filtros } = await request.json();

    if (!lente_id?.trim()) {
      return json({
        success: false,
        error: 'ID da lente é obrigatório',
        data: []
      }, { status: 400 });
    }

    if (!criterio || !['NORMAL', 'URGENCIA', 'ESPECIAL'].includes(criterio)) {
      return json({
        success: false,
        error: 'Critério inválido. Use: NORMAL, URGENCIA ou ESPECIAL',
        data: []
      }, { status: 400 });
    }

    // Verificar se a lente existe
    const lenteResult = await LentesService.buscarLentePorId(lente_id);
    if (!lenteResult.success) {
      return json({
        success: false,
        error: 'Lente não encontrada',
        data: []
      }, { status: 404 });
    }

    // Gerar ranking
    const resultado = await RankingService.gerarRanking(
      lente_id, 
      criterio, 
      filtros || {}
    );

    if (!resultado.success) {
      return json({
        success: false,
        error: resultado.error,
        data: []
      }, { status: 500 });
    }

    return json({
      success: true,
      data: resultado.data,
      lente: lenteResult.data,
      metadata: resultado.metadata,
      error: null
    });
  } catch (error) {
    console.error('Erro na API de ranking:', error);
    return json({
      success: false,
      error: 'Erro interno do servidor',
      data: []
    }, { status: 500 });
  }
};