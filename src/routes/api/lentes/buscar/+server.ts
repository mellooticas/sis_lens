/**
 * API Route - Busca de Lentes
 * Endpoint AJAX para busca em tempo real
 */

import { LentesService } from '$lib/api';
import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url }) => {
  const query = url.searchParams.get('q') || '';
  const limite = parseInt(url.searchParams.get('limite') || '10');
  const categoria = url.searchParams.get('categoria') || '';
  const material = url.searchParams.get('material') || '';

  if (!query.trim()) {
    return json({
      success: false,
      error: 'Query é obrigatória',
      data: []
    }, { status: 400 });
  }

  try {
    const resultado = await LentesService.buscarLentes(query, {
      categoria: categoria || undefined,
      material: material || undefined
    }, limite);

    return json({
      success: resultado.success,
      data: resultado.data,
      total: resultado.total,
      error: resultado.success ? null : resultado.error
    });
  } catch (error) {
    console.error('Erro na API de busca de lentes:', error);
    return json({
      success: false,
      error: 'Erro interno do servidor',
      data: []
    }, { status: 500 });
  }
};

export const POST: RequestHandler = async ({ request }) => {
  try {
    const { query, filtros, limite } = await request.json();

    if (!query?.trim()) {
      return json({
        success: false,
        error: 'Query é obrigatória',
        data: []
      }, { status: 400 });
    }

    const resultado = await LentesService.buscarLentes(
      query, 
      filtros || {}, 
      limite || 20
    );

    return json({
      success: resultado.success,
      data: resultado.data,
      total: resultado.total,
      error: resultado.success ? null : resultado.error
    });
  } catch (error) {
    console.error('Erro na API POST de busca de lentes:', error);
    return json({
      success: false,
      error: 'Erro interno do servidor',
      data: []
    }, { status: 500 });
  }
};