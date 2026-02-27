<script lang="ts">
	import type {
		VCatalogLens,
		RpcLensSearchResult,
	} from "$lib/types/database-views";
	import { TrendingDown, ShieldCheck, Zap, Sparkles } from "lucide-svelte";

	export let lente: VCatalogLens | RpcLensSearchResult | any;
	export let mostrarFornecedor = true;
	export let mostrarAlternativas = false;
	export let onSelecionar:
		| ((lente: VCatalogLens | RpcLensSearchResult) => void)
		| undefined = undefined;
	export let compact = false;

	function formatarPreco(preco: number): string {
		return new Intl.NumberFormat("pt-BR", {
			style: "currency",
			currency: "BRL",
		}).format(preco);
	}

	function obterCorCategoria(categoria: string | null): string {
		const cores: Record<string, string> = {
			economica:
				"bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
			standard:
				"bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200",
			premium:
				"bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200",
			super_premium:
				"bg-pink-100 text-pink-800 dark:bg-pink-900 dark:text-pink-200",
		};
		return cores[categoria || "standard"] || cores.standard;
	}

	// Computed - usando cast any para evitar lints chatos de union types incompletos
	$: _lente = lente as any;

	$: margemLucro =
		_lente.price_suggested > 0
			? ((_lente.price_suggested - (_lente.price_cost || 0)) /
					_lente.price_suggested) *
				100
			: null;

	$: temTratamentos =
		_lente.anti_reflective ||
		_lente.blue_light ||
		_lente.uv_filter ||
		!!_lente.photochromic;
</script>

<div
	class="lente-card bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden hover:shadow-lg transition-shadow duration-200"
	class:flex={compact}
	class:flex-row={compact}
	class:items-center={compact}
>
	<!-- Header -->
	<div
		class="px-4 py-3 bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 border-b border-gray-200 dark:border-gray-700"
		class:border-b-0={compact}
		class:border-r={compact}
		class:flex-shrink-0={compact}
		style={compact ? "width: 40%;" : ""}
	>
		<div class="flex items-start justify-between">
			<div class="flex-1">
				<a
					href="/lentes/{_lente.id}"
					class="text-sm font-semibold text-gray-900 dark:text-white line-clamp-2 hover:text-primary-600 transition-colors"
				>
					{_lente.lens_name || _lente.nome}
				</a>
				<div class="flex items-center gap-2 mt-1 flex-wrap">
					{#if _lente.category || _lente.categoria}
						<span
							class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {obterCorCategoria(
								_lente.category || _lente.categoria,
							)}"
						>
							{(_lente.category || _lente.categoria).replace(
								"_",
								" ",
							)}
						</span>
					{/if}
					{#if _lente.is_premium}
						<span
							class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
						>
							★ Premium
						</span>
					{/if}
				</div>
			</div>
		</div>
	</div>

	<!-- Corpo -->
	<div
		class="px-4 py-3 space-y-3 flex-1"
		class:flex={compact}
		class:flex-row={compact}
		class:items-center={compact}
		class:justify-between={compact}
		class:space-y-0={compact}
		class:gap-4={compact}
	>
		{#if !compact}
			<!-- Marca e Fornecedor -->
			<div class="flex items-center justify-between text-sm">
				<div>
					<span class="text-gray-500 dark:text-gray-400">Marca:</span>
					<strong class="ml-1 text-gray-900 dark:text-white"
						>{_lente.brand_name || _lente.marca || "—"}</strong
					>
				</div>
				{#if mostrarFornecedor && (_lente.supplier_name || _lente.fornecedor)}
					<div class="text-right">
						<span class="text-gray-500 dark:text-gray-400"
							>Fornecedor:</span
						>
						<strong class="ml-1 text-gray-900 dark:text-white"
							>{_lente.supplier_name || _lente.fornecedor}</strong
						>
					</div>
				{/if}
			</div>
		{/if}

		<!-- Especificações Técnicas -->
		<div
			class="grid gap-2 text-xs"
			class:grid-cols-3={!compact}
			class:grid-cols-5={compact}
			class:flex-shrink-0={compact}
		>
			{#if compact}
				<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
					<div class="text-gray-500 dark:text-gray-400">Marca</div>
					<div class="font-medium text-gray-900 dark:text-white">
						{_lente.brand_name || _lente.marca || "—"}
					</div>
				</div>
			{/if}
			<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
				<div class="text-gray-500 dark:text-gray-400">Material</div>
				<div class="font-medium text-gray-900 dark:text-white">
					{_lente.material_name || "—"}
				</div>
			</div>
			<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
				<div class="text-gray-500 dark:text-gray-400">Índice</div>
				<div class="font-medium text-gray-900 dark:text-white">
					{_lente.refractive_index || _lente.indice_refracao || "—"}
				</div>
			</div>
			<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
				<div class="text-gray-500 dark:text-gray-400">Tipo</div>
				<div
					class="font-medium text-gray-900 dark:text-white capitalize"
				>
					{(_lente.lens_type || _lente.tipo_lente || "—").replace(
						"_",
						" ",
					)}
				</div>
			</div>
			{#if compact}
				<div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
					<div class="text-gray-500 dark:text-gray-400">Preço</div>
					<div
						class="font-bold text-primary-600 dark:text-primary-400"
					>
						{formatarPreco(_lente.price_suggested || _lente.preco)}
					</div>
				</div>
			{/if}
		</div>

		<!-- Tratamentos -->
		{#if temTratamentos && !compact}
			<div class="flex flex-wrap gap-1.5">
				{#if _lente.anti_reflective || _lente.tem_ar}
					<span
						class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-medium bg-blue-50 text-blue-700 dark:bg-blue-900 dark:text-blue-200"
					>
						Antirreflexo
					</span>
				{/if}
				{#if _lente.blue_light || _lente.tem_blue}
					<span
						class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-medium bg-indigo-50 text-indigo-700 dark:bg-indigo-900 dark:text-indigo-200"
					>
						Blue Light
					</span>
				{/if}
				{#if _lente.photochromic}
					<span
						class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-medium bg-purple-50 text-purple-700 dark:bg-purple-900 dark:text-purple-200"
					>
						Fotossensível
					</span>
				{/if}
				{#if _lente.uv_filter}
					<span
						class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-medium bg-teal-50 text-teal-700 dark:bg-teal-900 dark:text-teal-200"
					>
						Filtro UV
					</span>
				{/if}
			</div>
		{/if}

		<!-- Footer do Card (Preço e Ações) -->
		{#if !compact}
			<div
				class="pt-3 border-t border-gray-100 dark:border-gray-700 flex items-center justify-between"
			>
				<div>
					<div
						class="text-[10px] text-gray-500 dark:text-gray-400 font-medium uppercase tracking-wider"
					>
						{_lente.price_suggested || _lente.preco
							? "Preço Sugerido"
							: "Faixa de Preço"}
					</div>
					<div
						class="text-xl font-black text-gray-900 dark:text-white"
					>
						{#if _lente.price_suggested || _lente.preco}
							{formatarPreco(
								_lente.price_suggested || _lente.preco,
							)}
						{:else if _lente.price_min && _lente.price_max}
							<span class="text-sm font-medium">a partir de</span>
							{formatarPreco(_lente.price_min)}
						{:else}
							Sob Consulta
						{/if}
					</div>
					{#if _lente.options_count}
						<div
							class="text-[10px] text-primary-600 dark:text-primary-400 font-bold mt-1 uppercase"
						>
							{_lente.options_count} opções disponíveis
						</div>
					{/if}
				</div>

				<div class="flex items-center gap-2">
					{#if onSelecionar}
						<button
							on:click={() => onSelecionar(_lente)}
							class="px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white text-xs font-bold rounded-lg shadow-sm shadow-primary-500/20 transition-all"
						>
							Selecionar
						</button>
					{:else}
						<a
							href="/lentes/{_lente.id}"
							class="px-4 py-2 bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-900 dark:text-white text-xs font-bold rounded-lg transition-all"
						>
							Ver Detalhes
						</a>
					{/if}
				</div>
			</div>
		{/if}

		{#if mostrarAlternativas}
			<div
				class="mt-4 pt-4 border-t border-dashed border-gray-200 dark:border-gray-700"
			>
				<h4
					class="text-xs font-bold text-gray-400 uppercase mb-3 flex items-center gap-2"
				>
					<Sparkles class="w-3 h-3 text-amber-500" /> Alternativas Sugeridas
				</h4>
				<!-- Placeholder para alternativas no card -->
				<div class="text-[10px] text-gray-500 italic">
					Comparação de marcas disponível em detalhes.
				</div>
			</div>
		{/if}
	</div>
</div>

<style>
	:global(.lente-card) {
		@apply transition-all duration-300;
	}
	:global(.lente-card:hover) {
		@apply -translate-y-1 shadow-xl border-primary-200 dark:border-primary-900/30;
	}
</style>
