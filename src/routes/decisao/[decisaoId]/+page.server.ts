/**
 * Página de Decisão - Server Load e Actions
 * Confirmação e acompanhamento de decisões
 */

import { DecisaoService, LentesService, RankingService } from '$lib/api';
import { fail, error } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ params, url }) => {
  const { decisaoId } = params;
  const novaDecisao = url.searchParams.get('nova') === 'true';
  const lenteId = url.searchParams.get('lente_id');
  const opcaoId = url.searchParams.get('opcao_id');
  const criterio = url.searchParams.get('criterio') || 'NORMAL';
  
  try {
    if (novaDecisao && lenteId && opcaoId) {
      // Nova decisão - carregar dados para confirmação
      const lenteResult = await LentesService.buscarLentePorId(lenteId);
      
      if (!lenteResult.success) {
        throw error(404, 'Lente não encontrada');
      }

      const rankingResult = await RankingService.listarOpcoes(lenteId, criterio);
      const opcaoEscolhida = rankingResult.data?.find((op: any) => 
        op.produto_laboratorio_id === opcaoId || op.id === opcaoId
      );

      if (!opcaoEscolhida) {
        throw error(404, 'Opção de ranking não encontrada');
      }

      return {
        modo: 'nova_decisao' as const,
        lente: lenteResult.data,
        opcao_escolhida: opcaoEscolhida,
        criterio_usado: criterio,
        decisao: null,
        sucesso: true,
        erro: null
      };
    } else {
      // Decisão existente - buscar por ID
      // Nota: Aqui assumimos que teremos uma função para buscar decisão por ID
      // Por ora, retornamos estrutura básica
      return {
        modo: 'acompanhar_decisao' as const,
        lente: null,
        opcao_escolhida: null,
        criterio_usado: criterio,
        decisao: { id: decisaoId, status: 'PENDENTE' },
        sucesso: true,
        erro: null
      };
    }
  } catch (err) {
    console.error('Erro no load da página de decisão:', err);
    
    if (err && typeof err === 'object' && 'status' in err) {
      throw err;
    }
    
    throw error(500, 'Erro interno do servidor');
  }
};

export const actions: Actions = {
  confirmar: async ({ request, params }) => {
    const data = await request.formData();
    const lenteId = data.get('lente_id')?.toString();
    const opcaoEscolhidaId = data.get('opcao_escolhida_id')?.toString();
    const criterio = data.get('criterio')?.toString() || 'NORMAL';
    const observacoes = data.get('observacoes')?.toString() || '';

    if (!lenteId || !opcaoEscolhidaId) {
      return fail(400, {
        erro: 'Dados insuficientes para confirmar decisão',
        lenteId,
        opcaoEscolhidaId
      });
    }

    try {
      const resultado = await DecisaoService.confirmarDecisao(
        lenteId,
        opcaoEscolhidaId,
        criterio,
        {}, // filtros
        observacoes
      );

      if (!resultado.success) {
        return fail(500, {
          erro: resultado.error,
          lenteId,
          opcaoEscolhidaId
        });
      }

      return {
        sucesso: true,
        decisao: resultado.data,
        economia_estimada: resultado.economia_estimada,
        mensagem: 'Decisão confirmada com sucesso!'
      };
    } catch (error) {
      console.error('Erro ao confirmar decisão:', error);
      return fail(500, {
        erro: 'Erro interno do servidor',
        lenteId,
        opcaoEscolhidaId
      });
    }
  },

  cancelar: async ({ params }) => {
    // Implementar cancelamento de decisão
    const { decisaoId } = params;
    
    try {
      // Aqui implementaríamos a lógica de cancelamento
      // Por ora, retornamos sucesso simulado
      return {
        sucesso: true,
        mensagem: 'Decisão cancelada com sucesso!'
      };
    } catch (error) {
      console.error('Erro ao cancelar decisão:', error);
      return fail(500, {
        erro: 'Erro ao cancelar decisão'
      });
    }
  }
};