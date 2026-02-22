import type { PageServerLoad } from './$types';
import { LensOracleAPI } from '$lib/api/lens-oracle';

export const load: PageServerLoad = async () => {
    try {
        // Carrega marcas de contato e estatísticas iniciais
        const [brandsRes, contactLensesRes] = await Promise.all([
            LensOracleAPI.getBrands({ scope: 'contact', premium_only: false, limit: 100 }),
            LensOracleAPI.searchContactLenses({ limit: 12 })
        ]);

        // Extrair fornecedores únicos das lentes carregadas ou marcas
        // Nota: v_brands_by_manufacturer (Migration 210) seria ideal, mas usaremos os dados das marcas
        const brands = brandsRes.data || [];
        const manufacturers = [...new Set(brands.map(b => b.manufacturer_name).filter(Boolean))];

        return {
            brands,
            manufacturers,
            initialLenses: contactLensesRes.data || [],
            sucesso: true
        };
    } catch (error) {
        console.error('Erro ao carregar catálogo de contato:', error);
        return {
            brands: [],
            manufacturers: [],
            initialLenses: [],
            sucesso: false,
            error: 'Erro ao carregar dados iniciais'
        };
    }
};
