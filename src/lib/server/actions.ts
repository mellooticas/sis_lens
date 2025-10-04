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
    const result = await DatabaseClient.lenses.buscarLentes(query.trim(), limit);
    
    if (result.error) {
      return fail(500, { 
        error: result.error,
        query 
      });
    }

    return {
      success: true,
      data: result.data,
      meta: result.meta,
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
    const result = await DatabaseClient.lenses.listarLentes(page, per_page, filtros);
    
    if (result.error) {
      return fail(500, { error: result.error });
    }

    return {
      success: true,
      data: result.data,
      meta: result.meta,
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
    const result = await DatabaseClient.ranking.gerarRanking(lente_id, criterio, filtros);
    
    if (result.error) {
      return fail(500, { 
        error: result.error,
        lente_id,
        criterio 
      });
    }

    return {
      success: true,
      data: result.data,
      meta: result.meta,
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
      error: 'IDs de lente, laboratório e produto são obrigatórios',
      payload 
    });
  }

  if (!payload.criterio || !['URGENCIA', 'NORMAL', 'ESPECIAL'].includes(payload.criterio)) {
    return fail(400, { 
      error: 'Critério inválido',
      payload 
    });
  }

  if (payload.preco_final <= 0) {
    return fail(400, { 
      error: 'Preço deve ser maior que zero',
      payload 
    });
  }

  if (payload.prazo_estimado_dias <= 0) {
    return fail(400, { 
      error: 'Prazo deve ser maior que zero',
      payload 
    });
  }

  if (!payload.motivo || payload.motivo.trim().length < 5) {
    return fail(400, { 
      error: 'Motivo deve ter pelo menos 5 caracteres',
      payload 
    });
  }

  try {
    const result = await DatabaseClient.ranking.confirmarDecisao(payload);
    
    if (result.error) {
      return fail(500, { 
        error: result.error,
        payload 
      });
    }

    // Redirecionar para a página da decisão criada
    throw redirect(302, `/decisoes/${result.data?.decisao_id}`);
    
  } catch (error) {
    if (error instanceof Response) {
      throw error; // Re-throw redirect
    }
    
    console.error('Erro ao confirmar decisão:', error);
    return fail(500, { 
      error: 'Erro interno do servidor',
      payload 
    });
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
    const result = await DatabaseClient.orders.listarDecisoes(page, per_page, filtros);
    
    if (result.error) {
      return fail(500, { error: result.error });
    }

    return {
      success: true,
      data: result.data,
      meta: result.meta,
      filtros
    };
  } catch (error) {
    console.error('Erro ao listar decisões:', error);
    return fail(500, { error: 'Erro interno do servidor' });
  }
};

export const obterDashboardAction = async () => {
  try {
    const result = await DatabaseClient.analytics.obterDashboard();
    
    if (result.error) {
      return fail(500, { error: result.error });
    }

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
    const result = await DatabaseClient.suppliers.listarLaboratorios();
    
    if (result.error) {
      return fail(500, { error: result.error });
    }

    return {
      success: true,
      data: result.data,
      meta: result.meta
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
    const result = await DatabaseClient.suppliers.obterProdutosLaboratorio(laboratorio_id);
    
    if (result.error) {
      return fail(500, { error: result.error });
    }

    return {
      success: true,
      data: result.data,
      meta: result.meta,
      laboratorio_id
    };
  } catch (error) {
    console.error('Erro ao obter produtos do laboratório:', error);
    return fail(500, { error: 'Erro interno do servidor' });
  }
};