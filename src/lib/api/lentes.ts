/**
 * API Wrapper: Lentes
 * Wrapper para operações relacionadas às lentes
 * Blueprint: lib/api/lentes.ts → rpc_buscar_lente
 */

import { supabase } from '$lib/supabase';

export interface BuscarLenteParams {
query: string;
categoria?: string;
material?: string;
indice_refracao?: number;
tipo_lente?: string;
limite?: number;
}

export interface LenteResult {
id: string;
sku_canonico: string;
nome: string;
marca: string;
familia: string;
design: string;
material: string;
indice_refracao: number;
tratamentos: string[];
tipo_lente: string;
corredor_progressao?: number;
ativo: boolean;
}

/**
 * Buscar lentes usando RPC function
 */
export async function buscarLente(params: BuscarLenteParams): Promise<{
sucesso: boolean;
dados: LenteResult[];
erro?: string;
}> {
try {
const { data, error } = await supabase.rpc('buscar_lentes', {
p_query: params.query,
p_categoria: params.categoria || null,
p_material: params.material || null,
p_indice_refracao: params.indice_refracao || null,
p_tipo_lente: params.tipo_lente || null,
p_limite: params.limite || 10
});

if (error) {
console.error('Erro ao buscar lentes:', error);
return {
sucesso: false,
dados: [],
erro: error.message
};
}

return {
sucesso: true,
dados: data || []
};
} catch (error) {
console.error('Erro na busca de lentes:', error);
return {
sucesso: false,
dados: [],
erro: error instanceof Error ? error.message : 'Erro desconhecido'
};
}
}

/**
 * Obter detalhes de uma lente específica
 */
export async function obterLente(lenteId: string): Promise<{
sucesso: boolean;
dados: LenteResult | null;
erro?: string;
}> {
try {
const { data, error } = await supabase
.from('vw_lentes_catalogo')
.select('*')
.eq('id', lenteId)
.single();

if (error) {
console.error('Erro ao obter lente:', error);
return {
sucesso: false,
dados: null,
erro: error.message
};
}

return {
sucesso: true,
dados: data
};
} catch (error) {
console.error('Erro ao obter lente:', error);
return {
sucesso: false,
dados: null,
erro: error instanceof Error ? error.message : 'Erro desconhecido'
};
}
}
