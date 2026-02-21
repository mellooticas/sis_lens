/**
 * Hook para gerenciar marcas
 * NOVO BANCO: marcas são TEXT (brand_name) em v_catalog_lenses — sem tabela separada.
 */

import { writable, get } from 'svelte/store';
import { viewsApi } from '$lib/api/views-client';

// Tipo que corresponde ao retorno de ViewsApiClient.listarMarcas()
export interface Marca {
  brand_name: string;
  total: number;
  // Compat legado
  id?: string;
  nome?: string;
  slug?: string;
  is_premium?: boolean;
  ativo?: boolean;
}

interface MarcasState {
  marcas: Marca[];
  marcasPremium: Marca[];
  loading: boolean;
  error: string | null;
}

export function useMarcas() {
  const state = writable<MarcasState>({
    marcas: [],
    marcasPremium: [],
    loading: false,
    error: null
  });

  /**
   * Carregar todas as marcas (DISTINCT brand_name de v_catalog_lenses)
   */
  async function carregarMarcas() {
    state.update(s => ({ ...s, loading: true, error: null }));

    const [resTodas, resPremium] = await Promise.all([
      viewsApi.listarMarcas(),
      viewsApi.listarMarcasPremium()
    ]);

    if (resTodas.success) {
      // Mapear para Marca com campos compat
      const marcas: Marca[] = resTodas.data.map(m => ({
        ...m,
        id: m.brand_name,        // sem UUID no novo banco
        nome: m.brand_name,
        slug: m.brand_name.toLowerCase().replace(/\s+/g, '-'),
        is_premium: resPremium.data?.some(p => p.brand_name === m.brand_name) ?? false,
        ativo: true
      }));

      const premiumSet = new Set(resPremium.data?.map(p => p.brand_name) ?? []);
      const marcasPremium = marcas.filter(m => premiumSet.has(m.brand_name));

      state.update(s => ({
        ...s,
        marcas,
        marcasPremium,
        loading: false
      }));
    } else {
      state.update(s => ({
        ...s,
        loading: false,
        error: resTodas.error || 'Erro ao carregar marcas'
      }));
    }
  }

  /**
   * Obter marca por brand_name (substitui obterMarcaPorId)
   */
  function obterMarcaPorId(marcaIdOuNome: string): Marca | undefined {
    const currentState = get(state);
    return currentState.marcas.find(
      m => m.id === marcaIdOuNome || m.brand_name === marcaIdOuNome
    );
  }

  /**
   * Obter marca por slug
   */
  function obterMarcaPorSlug(slug: string): Marca | undefined {
    const currentState = get(state);
    return currentState.marcas.find(m => m.slug === slug);
  }

  return {
    state,
    carregarMarcas,
    obterMarcaPorId,
    obterMarcaPorSlug
  };
}
