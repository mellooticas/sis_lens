<script lang="ts">
	import { onMount } from 'svelte';
	import { useFiltros, useMarcas, useFornecedores } from '$lib/hooks';
	import type { BuscarLentesParams, TipoLente, Material, IndiceRefracao, Categoria } from '$lib/types/views';
	
	export let filtrosAtuais: BuscarLentesParams = {};
	export let onAplicar: (filtros: BuscarLentesParams) => void;
	export let onLimpar: (() => void) | undefined = undefined;
	
	const { state: filtrosState, carregarFiltros } = useFiltros();
	const { state: marcasState, carregarMarcas } = useMarcas();
	const { state: fornecedoresState, carregarFornecedores } = useFornecedores();
	
	let filtrosLocais: BuscarLentesParams = { ...filtrosAtuais };
	let expanded = false;
	
	onMount(async () => {
		await Promise.all([
			carregarFiltros(),
			carregarMarcas(),
			carregarFornecedores()
		]);
	});
	
	function aplicarFiltros() {
		onAplicar(filtrosLocais);
		expanded = false;
	}
	
	function limparFiltros() {
		filtrosLocais = {};
		onLimpar?.();
	}
	
	function contarFiltrosAtivos(): number {
		let count = 0;
		if (filtrosLocais.tipo_lente) count++;
		if (filtrosLocais.material) count++;
		if (filtrosLocais.indice_refracao) count++;
		if (filtrosLocais.categoria) count++;
		if (filtrosLocais.marca_id) count++;
		if (filtrosLocais.fornecedor_id) count++;
		if (filtrosLocais.apenas_premium) count++;
		if (filtrosLocais.com_ar) count++;
		if (filtrosLocais.com_blue) count++;
		if (filtrosLocais.com_fotossensivel) count++;
		if (filtrosLocais.com_polarizado) count++;
		if (filtrosLocais.preco_min || filtrosLocais.preco_max) count++;
		return count;
	}
	
	$: filtrosAtivos = contarFiltrosAtivos();
</script>

<div class="filtros-lentes bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg">
	<!-- Header -->
	<div class="px-4 py-3 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
		<div class="flex items-center gap-3">
			<svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
			</svg>
			<h3 class="text-lg font-semibold text-gray-900 dark:text-white">
				Filtros
			</h3>
			{#if filtrosAtivos > 0}
				<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
					{filtrosAtivos} ativo{filtrosAtivos === 1 ? '' : 's'}
				</span>
			{/if}
		</div>
		
		<button
			class="text-sm text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-200 font-medium"
			on:click={() => expanded = !expanded}
		>
			{expanded ? 'Ocultar' : 'Mostrar'}
		</button>
	</div>
	
	<!-- Body -->
	{#if expanded}
		<div class="px-4 py-4 space-y-4">
			<!-- Tipo de Lente -->
			{#if $filtrosState.filtros?.tipos_lente}
				<div>
					<label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
						Tipo de Lente
					</label>
					<select
						bind:value={filtrosLocais.tipo_lente}
						class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 dark:text-white"
					>
						<option value={undefined}>Todos os tipos</option>
						{#each $filtrosState.filtros.tipos_lente as tipo}
							<option value={tipo}>{tipo.replace('_', ' ')}</option>
						{/each}
					</select>
				</div>
			{/if}
			
			<!-- Material -->
			{#if $filtrosState.filtros?.materiais}
				<div>
					<label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
						Material
					</label>
					<select
						bind:value={filtrosLocais.material}
						class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 dark:text-white"
					>
						<option value={undefined}>Todos os materiais</option>
						{#each $filtrosState.filtros.materiais as material}
							<option value={material}>{material}</option>
						{/each}
					</select>
				</div>
			{/if}
			
			<!-- Índice de Refração -->
			{#if $filtrosState.filtros?.indices_refracao}
				<div>
					<label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
						Índice de Refração
					</label>
					<select
						bind:value={filtrosLocais.indice_refracao}
						class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 dark:text-white"
					>
						<option value={undefined}>Todos os índices</option>
						{#each $filtrosState.filtros.indices_refracao as indice}
							<option value={indice}>{indice}</option>
						{/each}
					</select>
				</div>
			{/if}
			
			<!-- Categoria -->
			{#if $filtrosState.filtros?.categorias}
				<div>
					<label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
						Categoria
					</label>
					<select
						bind:value={filtrosLocais.categoria}
						class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 dark:text-white"
					>
						<option value={undefined}>Todas as categorias</option>
						{#each $filtrosState.filtros.categorias as cat}
							<option value={cat}>{cat.replace('_', ' ')}</option>
						{/each}
					</select>
				</div>
			{/if}
			
			<!-- Marca -->
			{#if $marcasState.marcas.length > 0}
				<div>
					<label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
						Marca
					</label>
					<select
						bind:value={filtrosLocais.marca_id}
						class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 dark:text-white"
					>
						<option value={undefined}>Todas as marcas</option>
						{#each $marcasState.marcas as marca}
							<option value={marca.id}>
								{marca.nome} {marca.is_premium ? '★' : ''}
							</option>
						{/each}
					</select>
				</div>
			{/if}
			
			<!-- Fornecedor -->
			{#if $fornecedoresState.fornecedores.length > 0}
				<div>
					<label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
						Fornecedor
					</label>
					<select
						bind:value={filtrosLocais.fornecedor_id}
						class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 dark:text-white"
					>
						<option value={undefined}>Todos os fornecedores</option>
						{#each $fornecedoresState.fornecedores as fornecedor}
							<option value={fornecedor.id}>{fornecedor.nome}</option>
						{/each}
					</select>
				</div>
			{/if}
			
			<!-- Tratamentos -->
			{#if $filtrosState.filtros?.tratamentos_disponiveis}
				<div>
					<label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
						Tratamentos
					</label>
					<div class="space-y-2">
						{#if $filtrosState.filtros.tratamentos_disponiveis.ar}
							<label class="flex items-center">
								<input
									type="checkbox"
									bind:checked={filtrosLocais.com_ar}
									class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
								/>
								<span class="ml-2 text-sm text-gray-700 dark:text-gray-300">Antirreflexo (AR)</span>
							</label>
						{/if}
						
						{#if $filtrosState.filtros.tratamentos_disponiveis.blue}
							<label class="flex items-center">
								<input
									type="checkbox"
									bind:checked={filtrosLocais.com_blue}
									class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
								/>
								<span class="ml-2 text-sm text-gray-700 dark:text-gray-300">Filtro Blue Light</span>
							</label>
						{/if}
						
						{#if $filtrosState.filtros.tratamentos_disponiveis.polarizado}
							<label class="flex items-center">
								<input
									type="checkbox"
									bind:checked={filtrosLocais.com_polarizado}
									class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
								/>
								<span class="ml-2 text-sm text-gray-700 dark:text-gray-300">Polarizado</span>
							</label>
						{/if}
						
						{#if $filtrosState.filtros.tratamentos_disponiveis.uv400}
							<label class="flex items-center">
								<input
									type="checkbox"
									bind:checked={filtrosLocais.com_uv400}
									class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
								/>
								<span class="ml-2 text-sm text-gray-700 dark:text-gray-300">UV400</span>
							</label>
						{/if}
					</div>
				</div>
			{/if}
			
			<!-- Fotossensível -->
			<div>
				<label class="flex items-center">
					<input
						type="checkbox"
						bind:checked={filtrosLocais.com_fotossensivel}
						class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
					/>
					<span class="ml-2 text-sm text-gray-700 dark:text-gray-300">Fotossensível (Transitions)</span>
				</label>
			</div>
			
			<!-- Apenas Premium -->
			<div>
				<label class="flex items-center">
					<input
						type="checkbox"
						bind:checked={filtrosLocais.apenas_premium}
						class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
					/>
					<span class="ml-2 text-sm text-gray-700 dark:text-gray-300">Apenas lentes premium</span>
				</label>
			</div>
			
			<!-- Faixa de Preço -->
			<div>
				<label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
					Faixa de Preço
				</label>
				<div class="grid grid-cols-2 gap-2">
					<input
						type="number"
						bind:value={filtrosLocais.preco_min}
						placeholder="Mínimo"
						class="px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 dark:text-white"
					/>
					<input
						type="number"
						bind:value={filtrosLocais.preco_max}
						placeholder="Máximo"
						class="px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 dark:text-white"
					/>
				</div>
			</div>
		</div>
		
		<!-- Footer com Ações -->
		<div class="px-4 py-3 bg-gray-50 dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700 flex items-center justify-between gap-3">
			<button
				on:click={limparFiltros}
				class="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 text-sm font-medium rounded-md hover:bg-gray-50 dark:hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors"
			>
				Limpar Filtros
			</button>
			<button
				on:click={aplicarFiltros}
				class="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
			>
				Aplicar Filtros
			</button>
		</div>
	{/if}
</div>

<style>
	.filtros-lentes {
		@apply w-full;
	}
</style>
