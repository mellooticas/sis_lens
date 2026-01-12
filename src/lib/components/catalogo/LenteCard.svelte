<script lang="ts">
	import type { VLenteCatalogo } from '$lib/types/database-views';
	
	export let lente: VLenteCatalogo;
	export let mostrarFornecedor = true;
	export let mostrarAlternativas = false; // Desabilitado por padrão (campos não existem)
	export let onSelecionar: ((lente: VLenteCatalogo) => void) | undefined = undefined;
	export let onCompararFornecedores: ((lente: VLenteCatalogo) => void) | undefined = undefined;
	
	function formatarPreco(preco: number): string {
		return new Intl.NumberFormat('pt-BR', {
			style: 'currency',
			currency: 'BRL'
		}).format(preco);
	}
	
	function obterCorCategoria(categoria: string): string {
		const cores: Record<string, string> = {
			economica: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
			intermediaria: 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200',
			premium: 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200',
			super_premium: 'bg-pink-100 text-pink-800 dark:bg-pink-900 dark:text-pink-200'
		};
		return cores[categoria] || cores.intermediaria;
	}
</script>

<div class="lente-card bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden hover:shadow-lg transition-shadow duration-200">
	<!-- Header -->
	<div class="px-4 py-3 bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 border-b border-gray-200 dark:border-gray-700">
		<div class="flex items-start justify-between">
			<div class="flex-1">
				<h3 class="text-sm font-semibold text-gray-900 dark:text-white line-clamp-2">
					{lente.nome_lente}
				</h3>
				<div class="flex items-center gap-2 mt-1">
					<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {obterCorCategoria(lente.categoria)}">
						{lente.categoria.replace('_', ' ')}
					</span>
					{#if lente.marca_premium}
						<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200">
							★ Premium
						</span>
					{/if}
				</div>
			</div>
		</div>
	</div>
	
	<!-- Corpo -->
	<div class="px-4 py-3 space-y-3">
		<!-- Marca e Fornecedor -->
		<div class="flex items-center justify-between text-sm">
			<div>
				<span class="text-gray-500 dark:text-gray-400">Marca:</span>
				<strong class="ml-1 text-gray-900 dark:text-white">{lente.marca_nome}</strong>
			</div>
			{#if mostrarFornecedor && lente.fornecedor_nome}
				<div class="text-right">
					<span class="text-gray-500 dark:text-gray-400">Fornecedor:</span>
					<strong class="ml-1 text-gray-900 dark:text-white">{lente.fornecedor_nome}</strong>
				</div>
			{/if}
		</div>
		
		<!-- Especificações Técnicas -->
		<div class="grid grid-cols-3 gap-2 text-xs">
			<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
				<div class="text-gray-500 dark:text-gray-400">Material</div>
				<div class="font-medium text-gray-900 dark:text-white">{lente.material}</div>
			</div>
			<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
				<div class="text-gray-500 dark:text-gray-400">Índice</div>
				<div class="font-medium text-gray-900 dark:text-white">{lente.indice_refracao}</div>
			</div>
			<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
				<div class="text-gray-500 dark:text-gray-400">Tipo</div>
				<div class="font-medium text-gray-900 dark:text-white capitalize">
					{lente.tipo_lente.replace('_', ' ')}
				</div>
			</div>
		</div>
		
		<!-- Tratamentos -->
		{#if lente.tratamento_antirreflexo || lente.tratamento_blue_light || lente.tratamento_fotossensiveis !== 'nenhum' || lente.tratamento_uv}
			<div class="flex flex-wrap gap-1.5">
				{#if lente.tratamento_antirreflexo}
					<span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-blue-50 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300">
						AR
					</span>
				{/if}
				{#if lente.tratamento_blue_light}
					<span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-indigo-50 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300">
						Blue Light
					</span>
				{/if}
				{#if lente.tratamento_fotossensiveis !== 'nenhum'}
					<span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-purple-50 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300">
						{lente.tratamento_fotossensiveis}
					</span>
				{/if}
				{#if lente.tratamento_uv}
					<span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-yellow-50 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300">
						UV
					</span>
				{/if}
			</div>
		{/if}
		
		<!-- Faixas Ópticas -->
		<div class="border-t border-gray-200 dark:border-gray-700 pt-2 text-xs text-gray-600 dark:text-gray-400">
			<div class="grid grid-cols-2 gap-2">
				<div>
					<span class="font-medium">Esférico:</span>
					{lente.grau_esferico_min > 0 ? '+' : ''}{lente.grau_esferico_min} a {lente.grau_esferico_max > 0 ? '+' : ''}{lente.grau_esferico_max}
				</div>
				<div>
					<span class="font-medium">Cilíndrico:</span>
					{lente.grau_cilindrico_min} a {lente.grau_cilindrico_max}
				</div>
			</div>
			{#if lente.adicao_min !== null && lente.adicao_max !== null}
				<div class="mt-1">
					<span class="font-medium">Adição:</span>
					+{lente.adicao_min} a +{lente.adicao_max}
				</div>
			{/if}
		</div>
		
	</div>
	
	<!-- Footer -->
	<div class="px-4 py-3 bg-gray-50 dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700">
		<div class="flex items-center justify-between">
			<div>
				<div class="text-xs text-gray-500 dark:text-gray-400">Preço Sugerido</div>
				<div class="text-2xl font-bold text-gray-900 dark:text-white">
					{formatarPreco(lente.preco_venda_sugerido)}
				</div>
				{#if lente.preco_custo && lente.margem_lucro}
					<div class="text-xs text-green-600 dark:text-green-400">
						Margem: {lente.margem_lucro.toFixed(0)}%
					</div>
				{/if}
			</div>
			
			<div class="flex gap-2">
				<a
					href="/catalogo/{lente.id}"
					class="px-4 py-2 bg-gray-100 hover:bg-gray-200 dark:bg-gray-800 dark:hover:bg-gray-700 text-gray-900 dark:text-white text-sm font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
				>
					Ver Detalhes
				</a>
				{#if onSelecionar}
					<button
						class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
						on:click={() => onSelecionar?.(lente)}
					>
						Selecionar
					</button>
				{/if}
			</div>
		</div>
	</div>
</div>

<style>
	.lente-card {
		@apply w-full max-w-md;
	}
	
	.line-clamp-2 {
		display: -webkit-box;
		-webkit-line-clamp: 2;
		-webkit-box-orient: vertical;
		overflow: hidden;
	}
</style>
