// ============================================================================
// SERVER ACTIONS — SIS LENS (refatorado para LensOracleAPI)
// ============================================================================
// Nota: Este módulo era legado e usava DatabaseClient (removido).
// As actions estão migradas para as rotas SvelteKit.
// Arquivo mantido para evitar quebra de imports enquanto o refactoring
// nas rotas individuais é concluído.
// ============================================================================

import { fail } from '@sveltejs/kit';
import { LensOracleAPI } from '$lib/api/lens-oracle';
import type { UUID } from '$lib/types/sistema';

// ============================================================================
// BUSCA E CATÁLOGO
// ============================================================================

export const buscarLentesAction = async ({ request }: { request: Request }) => {
  const data = await request.formData();
  const query = data.get('query') as string;
  const limit = parseInt(data.get('limit') as string) || 20;

  if (!query || query.trim().length < 2) {
    return fail(400, { error: 'Query deve ter pelo menos 2 caracteres', query });
  }

  const result = await LensOracleAPI.searchLenses({ query: query.trim(), limit });
  if (result.error) {
    return fail(500, { error: result.error.message, query });
  }

  return { success: true, data: result.data, total: result.data?.length ?? 0, query };
};

export const listarLentesAction = async ({ request }: { request: Request }) => {
  const url = new URL(request.url);
  const limit = parseInt(url.searchParams.get('per_page') || '20');
  const offset = (parseInt(url.searchParams.get('page') || '1') - 1) * limit;

  const filtros = {
    material:  url.searchParams.get('material')  || undefined,
    lens_type: url.searchParams.get('lens_type') || undefined,
    refractive_index: url.searchParams.get('refractive_index')
      ? parseFloat(url.searchParams.get('refractive_index')!)
      : undefined,
  };

  const result = await LensOracleAPI.searchLenses({ ...filtros, limit, offset });
  if (result.error) {
    return fail(500, { error: result.error.message });
  }

  return { success: true, data: result.data, total: result.data?.length ?? 0, filtros };
};

// ============================================================================
// RANKING E DECISÕES
// ============================================================================

export const gerarRankingAction = async ({ request }: { request: Request }) => {
  const data = await request.formData();
  const lente_id = data.get('lente_id') as UUID;

  if (!lente_id) {
    return fail(400, { error: 'ID da lente é obrigatório' });
  }

  const result = await LensOracleAPI.getAlternatives(lente_id, 10);
  if (result.error) {
    return fail(500, { error: result.error.message, lente_id });
  }

  return { success: true, data: result.data, lente_id };
};

export const confirmarDecisaoAction = async ({ request: _request }: { request: Request }) => {
  // Decisão de compra agora é tratada pelo SIS Vendas / SIS OS
  return fail(501, { error: 'Decisões de compra são gerenciadas pelo SIS OS' });
};

// ============================================================================
// HISTÓRICO E RELATÓRIOS
// ============================================================================

export const listarDecisoesAction = async ({ request: _request }: { request: Request }) => {
  return fail(501, { error: 'Histórico de decisões é gerenciado pelo SIS Financeiro' });
};

export const obterDashboardAction = async () => {
  const result = await LensOracleAPI.getCatalogStats();
  if (result.error) {
    return fail(500, { error: result.error.message });
  }
  return { success: true, data: result.data };
};

// ============================================================================
// FORNECEDORES / LABORATÓRIOS
// ============================================================================

export const listarLaboratoriosAction = async () => {
  const result = await LensOracleAPI.getBrands({ scope: 'ophthalmic' });
  if (result.error) {
    return fail(500, { error: result.error.message });
  }
  return { success: true, data: result.data, total: result.data?.length ?? 0 };
};

export const obterProdutosLaboratorioAction = async ({ request }: { request: Request }) => {
  const url = new URL(request.url);
  const laboratorio_id = url.searchParams.get('laboratorio_id') as UUID;

  if (!laboratorio_id) {
    return fail(400, { error: 'ID do laboratório é obrigatório' });
  }

  const result = await LensOracleAPI.searchLenses({ supplier_id: laboratorio_id, limit: 100 });
  if (result.error) {
    return fail(500, { error: result.error.message, laboratorio_id });
  }

  return { success: true, data: result.data, laboratorio_id };
};
