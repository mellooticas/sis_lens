/**
 * Decision Engine API
 * Lógica para recomendações de compra e seleção de laboratórios.
 */
import { LensOracleAPI } from './lens-oracle';
import type { RankingOption } from '$lib/types/sistema';
import type { ApiResponse } from '$lib/types/sistema';

export class DecisionAPI {
  /**
   * Recomenda o melhor laboratório para um conceito canônico.
   */
  static async recommendBestLab(canonicalId: string): Promise<ApiResponse<RankingOption>> {
    const res = await LensOracleAPI.getBestPurchaseOptions(canonicalId, 1);
    if (res.data && res.data.length > 0) {
      return { data: res.data[0] };
    }
    return { error: { code: 'NOT_FOUND', message: 'Nenhuma opção de compra encontrada' } };
  }

  /**
   * Obtém matriz completa de decisão para comparação.
   */
  static async getDecisionMatrix(canonicalId: string, limit: number = 10): Promise<ApiResponse<RankingOption[]>> {
    return LensOracleAPI.getBestPurchaseOptions(canonicalId, limit);
  }
}
