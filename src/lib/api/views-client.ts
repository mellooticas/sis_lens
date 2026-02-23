
/**
 * SIS Lens — Views Client (Shim / Bridge)
 * Redireciona chamadas legadas para a nova LensOracleAPI.
 * 
 * TODO: Remover este arquivo após migrar todos os hooks/componentes
 * para chamar LensOracleAPI diretamente.
 */

import { LensOracleAPI } from './lens-oracle';
import type {
    VCatalogLens,
    VCatalogLensGroup,
    VCatalogLensStats,
    RpcLensSearchResult,
    VCanonicalLens
} from '$lib/types/database-views';
import type { ApiResponse } from '$lib/types/sistema';

export interface BuscarGruposParams {
    limit?: number;
    offset?: number;
    is_premium?: boolean;
}

export class ViewsAPI {
    /** @deprecated Use LensOracleAPI.searchLenses */
    async buscarLentes(params: any) {
        return LensOracleAPI.searchLenses(params);
    }

    /** @deprecated Use LensOracleAPI.getLensById */
    async obterLentePorId(id: string) {
        return LensOracleAPI.getLensById(id);
    }

    /** @deprecated Use LensOracleAPI.getCanonicalLenses */
    async buscarGruposCanonicos(params: BuscarGruposParams): Promise<ApiResponse<VCanonicalLens[]>> {
        return LensOracleAPI.getCanonicalLenses({
            limit: params.limit,
            is_premium: params.is_premium
        });
    }

    /** @deprecated Use LensOracleAPI.getBestPurchaseOptions */
    async compararFornecedores(grupoId: string | undefined): Promise<ApiResponse<any[]>> {
        if (!grupoId) return { data: [] };
        // Mapeia para a nova lógica de ranking por conceito canônico
        return LensOracleAPI.getBestPurchaseOptions(grupoId);
    }

    /** @deprecated Use LensOracleAPI.getCatalogStats */
    async obterStatsCatalogo() {
        return LensOracleAPI.getCatalogStats();
    }
}

export const viewsApi = new ViewsAPI();
