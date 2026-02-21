<script lang="ts">
	import type { VCatalogLens } from '$lib/types/database-views';

	export let lente: VCatalogLens;
	export let mostrarFornecedor = true;
	export let mostrarAlternativas = false;
	export let onSelecionar: ((lente: VCatalogLens) => void) | undefined = undefined;
	export let onCompararFornecedores: ((lente: VCatalogLens) => void) | undefined = undefined;
	export let compact = false;

	function formatarPreco(preco: number): string {
		return new Intl.NumberFormat('pt-BR', {
			style: 'currency',
			currency: 'BRL'
		}).format(preco);
	}

	function obterCorCategoria(categoria: string | null): string {
		const cores: Record<string, string> = {
			economica: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
			standard:  'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200',
			premium:   'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200',
			super_premium: 'bg-pink-100 text-pink-800 dark:bg-pink-900 dark:text-pink-200'
		};
		return cores[categoria || 'standard'] || cores.standard;
	}

	// Computed
	$: margemLucro = lente.price_suggested > 0
		? ((lente.price_suggested - lente.price_cost) / lente.price_suggested * 100)
		: null;

	$: temTratamentos = lente.anti_reflective || lente.blue_light || lente.uv_filter
		|| (lente.photochromic && lente.photochromic !== 'nenhum');
</script>

<div class="lente-card bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden hover:shadow-lg transition-shadow duration-200"
     class:flex={compact}
     class:flex-row={compact}
     class:items-center={compact}>

	<!-- Header -->
	<div
	  class="px-4 py-3 bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 border-b border-gray-200 dark:border-gray-700"
	  class:border-b-0={compact}
	  class:border-r={compact}
	  class:flex-shrink-0={compact}
	  style={compact ? 'width: 40%;' : ''}
	>
		<div class="flex items-start justify-between">
			<div class="flex-1">
				<h3 class="text-sm font-semibold text-gray-900 dark:text-white line-clamp-2">
					{lente.lens_name}
				</h3>
				<div class="flex items-center gap-2 mt-1 flex-wrap">
					{#if lente.category}
					<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {obterCorCategoria(lente.category)}">
						{lente.category.replace('_', ' ')}
					</span>
					{/if}
					{#if lente.is_premium}
						<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200">
							★ Premium
						</span>
					{/if}
				</div>
			</div>
		</div>
	</div>

	<!-- Corpo -->
	<div class="px-4 py-3 space-y-3 flex-1"
	     class:flex={compact}
	     class:flex-row={compact}
	     class:items-center={compact}
	     class:justify-between={compact}
	     class:space-y-0={compact}
	     class:gap-4={compact}>

		{#if !compact}
		<!-- Marca e Fornecedor -->
		<div class="flex items-center justify-between text-sm">
			<div>
				<span class="text-gray-500 dark:text-gray-400">Marca:</span>
				<strong class="ml-1 text-gray-900 dark:text-white">{lente.brand_name || '—'}</strong>
			</div>
			{#if mostrarFornecedor && lente.supplier_name}
				<div class="text-right">
					<span class="text-gray-500 dark:text-gray-400">Fornecedor:</span>
					<strong class="ml-1 text-gray-900 dark:text-white">{lente.supplier_name}</strong>
				</div>
			{/if}
		</div>
		{/if}

		<!-- Especificações Técnicas -->
		<div class="grid gap-2 text-xs"
		     class:grid-cols-3={!compact}
		     class:grid-cols-5={compact}
		     class:flex-shrink-0={compact}>
			{#if compact}
			<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
				<div class="text-gray-500 dark:text-gray-400">Marca</div>
				<div class="font-medium text-gray-900 dark:text-white">{lente.brand_name || '—'}</div>
			</div>
			{/if}
			<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
				<div class="text-gray-500 dark:text-gray-400">Material</div>
				<div class="font-medium text-gray-900 dark:text-white">{lente.material || '—'}</div>
			</div>
			<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
				<div class="text-gray-500 dark:text-gray-400">Índice</div>
				<div class="font-medium text-gray-900 dark:text-white">{lente.refractive_index ?? '—'}</div>
			</div>
			<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
				<div class="text-gray-500 dark:text-gray-400">Tipo</div>
				<div class="font-medium text-gray-900 dark:text-white capitalize">
					{(lente.lens_type || '—').replace('_', ' ')}
				</div>
			</div>
			{#if compact && lente.supplier_name}
			<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
				<div class="text-gray-500 dark:text-gray-400">Fornecedor</div>
				<div class="font-medium text-gray-900 dark:text-white">{lente.supplier_name}</div>
			</div>
			{/if}
		</div>

		<!-- Tratamentos -->
		{#if temTratamentos}
			<div class="flex flex-wrap gap-1.5"
			     class:flex-shrink-0={compact}>
				{#if lente.anti_reflective}
					<span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-blue-50 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300">AR</span>
				{/if}
				{#if lente.blue_light}
					<span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-indigo-50 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300">Blue Light</span>
				{/if}
				{#if lente.photochromic && lente.photochromic !== 'nenhum'}
					<span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-purple-50 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300">
						{lente.photochromic}
					</span>
				{/if}
				{#if lente.uv_filter}
					<span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-yellow-50 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300">UV</span>
				{/if}
			</div>
		{/if}

		{#if !compact}
		<!-- Faixas Ópticas -->
		<div class="border-t border-gray-200 dark:border-gray-700 pt-2 text-xs text-gray-600 dark:text-gray-400">
			<div class="grid grid-cols-2 gap-2">
				<div>
					<span class="font-medium">Esférico:</span>
					{lente.spherical_min !== null ? ((lente.spherical_min ?? 0) > 0 ? '+' : '') + lente.spherical_min : '?'}
					a
					{lente.spherical_max !== null ? ((lente.spherical_max ?? 0) > 0 ? '+' : '') + lente.spherical_max : '?'}
				</div>
				<div>
					<span class="font-medium">Cilíndrico:</span>
					{lente.cylindrical_min ?? '?'} a {lente.cylindrical_max ?? '?'}
				</div>
			</div>
			{#if lente.addition_min !== null && lente.addition_max !== null}
				<div class="mt-1">
					<span class="font-medium">Adição:</span>
					+{lente.addition_min} a +{lente.addition_max}
				</div>
			{/if}
		</div>
		{/if}

	</div>

	<!-- Footer -->
	<div class="px-4 py-3 bg-gray-50 dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700"
	     class:border-t-0={compact}
	     class:border-l={compact}
	     class:flex-shrink-0={compact}>
		<div class="flex items-center justify-between"
		     class:flex-col={compact}
		     class:items-end={compact}
		     class:gap-3={compact}>
			<div class:text-center={compact}>
				<div class="text-xs text-gray-500 dark:text-gray-400">Preço Sugerido</div>
				<div class="font-bold text-gray-900 dark:text-white"
				     class:text-2xl={!compact}
				     class:text-xl={compact}>
					{formatarPreco(lente.price_suggested)}
				</div>
				{#if margemLucro !== null && margemLucro > 0}
					<div class="text-xs text-green-600 dark:text-green-400">
						Margem: {margemLucro.toFixed(0)}%
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
