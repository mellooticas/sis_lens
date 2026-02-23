import type { PageServerLoad } from './$types';
import { LensOracleAPI } from '$lib/api/lens-oracle';

export const load: PageServerLoad = async () => {
    const [healthRes, pricingRes, summaryRes] = await Promise.all([
        LensOracleAPI.getSystemHealthAudit(),
        LensOracleAPI.getPricingOrganismHealth(),
        LensOracleAPI.getGlobalCatalogSummary()
    ]);

    return {
        systemHealth: healthRes.data || [],
        pricingHealth: pricingRes.data || [],
        catalogSummary: summaryRes.data || []
    };
};
