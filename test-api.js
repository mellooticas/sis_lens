// Teste rápido da API no console do navegador
// Cole isso no console (F12) enquanto estiver em http://localhost:5173

import { CatalogoAPI } from '$lib/api/catalogo-api';

console.log('🧪 Testando CatalogoAPI...');

// Teste 1: Buscar lentes
const resultado = await CatalogoAPI.buscarLentes({}, { pagina: 1, limite: 12 });
console.log('📊 Resultado:', resultado);
console.log('✅ Total de lentes:', resultado.data?.paginacao.total);
console.log('📦 Lentes na página:', resultado.data?.dados.length);

// Teste 2: Listar marcas
const marcas = await CatalogoAPI.listarMarcas();
console.log('🏭 Marcas:', marcas);
