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
let query = supabase
.from('v_lentes')
.select('*');

// Busca por texto usando search_text
if (params.query) {
query = query.ilike('search_text', `%${params.query}%`);
}

// Filtros adicionais
if (params.categoria) {
query = query.eq('categoria', params.categoria);
}

if (params.material) {
query = query.eq('material', params.material);
}

if (params.indice_refracao) {
query = query.eq('indice_refracao', params.indice_refracao.toString());
}

if (params.tipo_lente) {
query = query.eq('tipo_lente', params.tipo_lente);
}

// Limite de resultados
query = query.limit(params.limite || 10);

const { data, error } = await query;

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
.from('v_lentes')
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
