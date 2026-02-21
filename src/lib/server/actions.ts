// ============================================================================
// SERVER ACTIONS - SISTEMA DECISOR DE LENTES
// Actions do SvelteKit para operações server-side
// ============================================================================

import { fail, redirect } from '@sveltejs/kit';
import { DatabaseClient } from '$lib/database/client';
import type {
  CriterioDecisao,
  FiltrosRanking,
  PayloadDecisao,
  UUID
} from '$lib/types/sistema';

// ============================================================================
// BUSCA E CATÁLOGO
// ============================================================================

export const buscarLentesAction = async ({ request }: { request: Request }) => {
  const data = await request.formData();
  const query = data.get('query') as string;
  const limit = parseInt(data.get('limit') as string) || 20;

  if (!query || query.trim().length < 2) {
    return fail(400, {
      error: 'Query deve ter pelo menos 2 caracteres',
      query
    });
  }

  try {
    const result = await DatabaseClient.buscarLentesPorQuery(query.trim(), {}, limit);

    if (!result.success) {
      return fail(500, {
        error: result.error ?? 'Erro ao buscar lentes',
        query
      });
    }

    return {
      success: true,
      data: result.data,
      total: result.total,
      query
    };
  } catch (error) {
    console.error('Erro na busca de lentes:', error);
    return fail(500, {
      error: 'Erro interno do servidor',
      query
    });
  }
};

export const listarLentesAction = async ({ request }: { request: Request }) => {
  const url = new URL(request.url);
  const page = parseInt(url.searchParams.get('page') || '1');
  const per_page = parseInt(url.searchParams.get('per_page') || '20');

  // Extrair filtros da query string
  const filtros = {
    material: url.searchParams.get('material') || undefined,
    indice_refracao: url.searchParams.get('indice_refracao') ?
      parseFloat(url.searchParams.get('indice_refracao')!) : undefined,
    tipo_lente: url.searchParams.get('tipo_lente') || undefined
  };

  try {
    const result = await DatabaseClient.listarLentesCatalogo(filtros, page, per_page);

    return {
      success: true,
      data: result.data,
      total: result.total,
      filtros
    };
  } catch (error) {
    console.error('Erro ao listar lentes:', error);
    return fail(500, { error: 'Erro interno do servidor' });
  }
};

// ============================================================================
// RANKING E DECISÕES
// ============================================================================

export const gerarRankingAction = async ({ request }: { request: Request }) => {
  const data = await request.formData();
  const lente_id = data.get('lente_id') as UUID;
  const criterio = data.get('criterio') as CriterioDecisao;

  // Filtros opcionais
  const filtros: FiltrosRanking = {};

  const preco_maximo = data.get('preco_maximo');
  if (preco_maximo) filtros.preco_maximo = parseFloat(preco_maximo as string);

  const prazo_maximo_dias = data.get('prazo_maximo_dias');
  if (prazo_maximo_dias) filtros.prazo_maximo_dias = parseInt(prazo_maximo_dias as string);

  const score_minimo = data.get('score_minimo');
  if (score_minimo) filtros.score_minimo = parseFloat(score_minimo as string);

  // Validações
  if (!lente_id) {
    return fail(400, { error: 'ID da lente é obrigatório' });
  }

  if (!criterio || !['URGENCIA', 'NORMAL', 'ESPECIAL'].includes(criterio)) {
    return fail(400, {
      error: 'Critério deve ser: URGENCIA, NORMAL ou ESPECIAL',
      lente_id
    });
  }

  try {
    const result = await DatabaseClient.gerarRankingOpcoes(lente_id, criterio, filtros as Record<string, unknown>);

    if (!result.success) {
      return fail(500, {
        error: result.error ?? 'Erro ao gerar ranking',
        lente_id,
        criterio
      });
    }

    return {
      success: true,
      data: result.data,
      metadata: result.metadata,
      lente_id,
      criterio,
      filtros
    };
  } catch (error) {
    console.error('Erro ao gerar ranking:', error);
    return fail(500, {
      error: 'Erro interno do servidor',
      lente_id,
      criterio
    });
  }
};

export const confirmarDecisaoAction = async ({ request }: { request: Request }) => {
  const data = await request.formData();

  // Extrair dados do formulário
  const payload: PayloadDecisao = {
    lente_id: data.get('lente_id') as UUID,
    laboratorio_id: data.get('laboratorio_id') as UUID,
    produto_lab_id: data.get('produto_lab_id') as UUID,
    criterio: data.get('criterio') as CriterioDecisao,
    preco_final: parseFloat(data.get('preco_final') as string),
    prazo_estimado_dias: parseInt(data.get('prazo_estimado_dias') as string),
    custo_frete: parseFloat(data.get('custo_frete') as string),
    score_atribuido: parseFloat(data.get('score_atribuido') as string),
    motivo: data.get('motivo') as string,
    alternativas: JSON.parse(data.get('alternativas') as string || '[]')
  };

  // Validações básicas
  if (!payload.lente_id || !payload.laboratorio_id || !payload.produto_lab_id) {
    return fail(400, {
      error: 'IDs de lente, laboratório e produto são obrigatórios'
    });
  }

  if (!payload.criterio || !['URGENCIA', 'NORMAL', 'ESPECIAL'].includes(payload.criterio)) {
    return fail(400, { error: 'Critério inválido' });
  }

  if (payload.preco_final <= 0) {
    return fail(400, { error: 'Preço deve ser maior que zero' });
  }

  if (payload.prazo_estimado_dias <= 0) {
    return fail(400, { error: 'Prazo deve ser maior que zero' });
  }

  if (!payload.motivo || payload.motivo.trim().length < 5) {
    return fail(400, { error: 'Motivo deve ter pelo menos 5 caracteres' });
  }

  try {
    // NOVO BANCO: usar rpc_production_create_service_order() (migration 076)
    // Por enquanto delega para confirmarDecisaoCompra do DatabaseClient (legado)
    const result = await DatabaseClient.confirmarDecisaoCompra(
      '', // tenant_id extraído do JWT pelo RLS no novo banco
      payload.lente_id,
      {
        laboratorio_id: payload.laboratorio_id,
        produto_lab_id: payload.produto_lab_id,
        preco_final: payload.preco_final,
        prazo_estimado_dias: payload.prazo_estimado_dias,
        custo_frete: payload.custo_frete,
        score_atribuido: payload.score_atribuido,
        motivo: payload.motivo,
        alternativas: payload.alternativas
      },
      payload.criterio,
      {}
    );

    if (!result.success) {
      return fail(500, { error: result.error ?? 'Erro ao confirmar decisão' });
    }

    // Redirecionar para a página da decisão criada
    const decisaoId = (result.data as { decisao_id?: string } | undefined)?.decisao_id;
    throw redirect(302, `/decisoes/${decisaoId ?? ''}`);

  } catch (error) {
    if (error instanceof Response) {
      throw error; // Re-throw redirect
    }

    console.error('Erro ao confirmar decisão:', error);
    return fail(500, { error: 'Erro interno do servidor' });
  }
};

// ============================================================================
// HISTÓRICO E RELATÓRIOS
// ============================================================================

export const listarDecisoesAction = async ({ request }: { request: Request }) => {
  const url = new URL(request.url);
  const page = parseInt(url.searchParams.get('page') || '1');
  const per_page = parseInt(url.searchParams.get('per_page') || '20');

  // Filtros
  const filtros = {
    criterio: url.searchParams.get('criterio') || undefined,
    status: url.searchParams.get('status') || undefined,
    laboratorio_id: url.searchParams.get('laboratorio_id') || undefined
  };

  try {
    const result = await DatabaseClient.listarDecisoesCompra(filtros, page, per_page);

    return {
      success: true,
      data: result.data,
      total: result.total,
      filtros
    };
  } catch (error) {
    console.error('Erro ao listar decisões:', error);
    return fail(500, { error: 'Erro interno do servidor' });
  }
};

export const obterDashboardAction = async () => {
  try {
    const result = await DatabaseClient.buscarDashboardExecutivo();

    return {
      success: true,
      data: result.data
    };
  } catch (error) {
    console.error('Erro ao obter dashboard:', error);
    return fail(500, { error: 'Erro interno do servidor' });
  }
};

// ============================================================================
// FORNECEDORES
// ============================================================================

export const listarLaboratoriosAction = async () => {
  try {
    const result = await DatabaseClient.listarFornecedores();

    return {
      success: true,
      data: result.data,
      total: result.total
    };
  } catch (error) {
    console.error('Erro ao listar laboratórios:', error);
    return fail(500, { error: 'Erro interno do servidor' });
  }
};

export const obterProdutosLaboratorioAction = async ({ request }: { request: Request }) => {
  const url = new URL(request.url);
  const laboratorio_id = url.searchParams.get('laboratorio_id') as UUID;

  if (!laboratorio_id) {
    return fail(400, { error: 'ID do laboratório é obrigatório' });
  }

  try {
    // NOVO BANCO: usar v_catalog_suppliers_labs com filtro por id (migration 076)
    const result = await DatabaseClient.buscarFornecedorPorId(laboratorio_id);

    return {
      success: true,
      data: result.data,
      laboratorio_id
    };
  } catch (error) {
    console.error('Erro ao obter produtos do laboratório:', error);
    return fail(500, { error: 'Erro interno do servidor', laboratorio_id });
  }
};
