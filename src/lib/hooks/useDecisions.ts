/**
 * Decisions Hook
 * Hook para gerenciar decisões e histórico
 */

import { decisoes, toast } from '$lib/stores';
import { get } from 'svelte/store';
import type { ActionResult } from '@sveltejs/kit';
import type { DecisaoCompra, StatusDecisao } from '$lib/types/sistema';

export interface UseDecisionsOptions {
  autoToast?: boolean;
  onSuccess?: (data: any) => void;
  onError?: (error: string) => void;
}

export function useDecisions(options: UseDecisionsOptions = {}) {
  const { autoToast = true, onSuccess, onError } = options;

  /**
   * Confirmar decisão de compra
   */
  async function confirmarDecisao(
    lente_id: string,
    laboratorio_id: string,
    criterio: string,
    observacoes?: string
  ) {
    try {
      const formData = new FormData();
      formData.append('lente_id', lente_id);
      formData.append('laboratorio_id', laboratorio_id);
      formData.append('criterio', criterio);
      if (observacoes) {
        formData.append('observacoes', observacoes);
      }
      
      const response = await fetch('/actions/confirmar-decisao', {
        method: 'POST',
        body: formData
      });
      
      const result: ActionResult = await response.json();
      
      if (result.type === 'success' && result.data) {
        const novaDecisao = result.data.decisao as DecisaoCompra;
        decisoes.addDecisao(novaDecisao);
        
        if (autoToast) {
          toast.show('Decisão confirmada com sucesso!', 'success');
        }
        
        onSuccess?.(result.data);
        return novaDecisao;
      } else if (result.type === 'failure') {
        const errorMsg = (result.data?.message as string) || 'Erro ao confirmar decisão';
        
        if (autoToast) {
          toast.show(errorMsg, 'error');
        }
        
        onError?.(errorMsg);
        throw new Error(errorMsg);
      }
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Erro inesperado';
      
      if (autoToast) {
        toast.show(errorMsg, 'error');
      }
      
      onError?.(errorMsg);
      throw error;
    }
  }

  /**
   * Carregar histórico de decisões
   */
  async function loadDecisoes(
    status?: StatusDecisao | 'TODAS',
    page = 1,
    append = false
  ) {
    try {
      decisoes.setLoading(true);
      
      const params = new URLSearchParams();
      if (status && status !== 'TODAS') {
        params.append('status', status);
      }
      params.append('page', page.toString());
      
      const response = await fetch(`/actions/listar-decisoes?${params}`);
      const result: ActionResult = await response.json();
      
      if (result.type === 'success' && result.data) {
        const { decisoes: novasDecisoes, hasMore } = result.data;
        decisoes.setDecisoes(novasDecisoes, append);
        decisoes.setHasMore(hasMore);
        decisoes.setPage(page);
        
        onSuccess?.(result.data);
      } else if (result.type === 'failure') {
        const errorMsg = (result.data?.message as string) || 'Erro ao carregar decisões';
        decisoes.setError(errorMsg);
        
        if (autoToast) {
          toast.show(errorMsg, 'error');
        }
        
        onError?.(errorMsg);
      }
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Erro inesperado';
      decisoes.setError(errorMsg);
      
      if (autoToast) {
        toast.show(errorMsg, 'error');
      }
      
      onError?.(errorMsg);
    }
  }

  /**
   * Carregar mais decisões (paginação)
   */
  async function loadMoreDecisoes() {
    const state = get(decisoes);
    if (state.hasMore && !state.loading) {
      await loadDecisoes(
        state.filtroStatus === 'TODAS' ? undefined : state.filtroStatus,
        state.page + 1,
        true
      );
    }
  }

  /**
   * Filtrar decisões por status
   */
  async function filterByStatus(status: StatusDecisao | 'TODAS') {
    decisoes.setFiltroStatus(status);
    await loadDecisoes(
      status === 'TODAS' ? undefined : status,
      1,
      false
    );
  }

  /**
   * Recarregar decisões
   */
  async function refreshDecisoes() {
    const state = get(decisoes);
    await loadDecisoes(
      state.filtroStatus === 'TODAS' ? undefined : state.filtroStatus,
      1,
      false
    );
  }

  /**
   * Atualizar status de uma decisão
   */
  async function updateDecisaoStatus(
    decisaoId: string,
    novoStatus: StatusDecisao
  ) {
    try {
      // Atualizar localmente primeiro (otimistic update)
      decisoes.updateDecisao(decisaoId, { status: novoStatus });
      
      const formData = new FormData();
      formData.append('decisao_id', decisaoId);
      formData.append('status', novoStatus);
      
      const response = await fetch('/actions/update-decisao-status', {
        method: 'POST',
        body: formData
      });
      
      const result: ActionResult = await response.json();
      
      if (result.type === 'failure') {
        // Reverter se houve erro
        await refreshDecisoes();
        
        const errorMsg = (result.data?.message as string) || 'Erro ao atualizar status';
        
        if (autoToast) {
          toast.show(errorMsg, 'error');
        }
        
        onError?.(errorMsg);
      } else if (autoToast) {
        toast.show('Status atualizado com sucesso!', 'success');
      }
      
    } catch (error) {
      // Reverter em caso de erro
      await refreshDecisoes();
      
      const errorMsg = error instanceof Error ? error.message : 'Erro inesperado';
      
      if (autoToast) {
        toast.show(errorMsg, 'error');
      }
      
      onError?.(errorMsg);
    }
  }

  return {
    confirmarDecisao,
    loadDecisoes,
    loadMoreDecisoes,
    filterByStatus,
    refreshDecisoes,
    updateDecisaoStatus
  };
}