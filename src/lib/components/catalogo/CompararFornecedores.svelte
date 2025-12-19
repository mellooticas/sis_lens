<script lang="ts">
	import { onMount } from 'svelte';
	import type { VwCompararFornecedores, OpcaoComparacao } from '$lib/types/views';
	
	export let grupoId: string | undefined = undefined;
	export let lenteId: string | undefined = undefined;
	export let tipo: 'PREMIUM' | 'GENÉRICA' | undefined = undefined;
	
	let comparacoes: VwCompararFornecedores[] = [];
	let loading = true;
	let error: string | null = null;
	
	onMount(async () => {
		await carregarComparacoes();
	});
	
	async function carregarComparacoes() {
		loading = true;
		error = null;
		
		try {
			const { viewsApi } = await import('$lib/api/views-client');
			
			let response;
			if (lenteId) {
				response = await viewsApi.compararFornecedoresPorLente(lenteId);
			} else if (grupoId) {
				response = await viewsApi.compararFornecedores(grupoId, tipo);
			} else {
				response = await viewsApi.compararFornecedores(undefined, tipo);
			}
			
			if (response.success && response.data) {
				comparacoes = response.data;
			} else {
				error = response.error || 'Erro ao carregar comparações';
			}
		} catch (err) {
			error = err instanceof Error ? err.message : 'Erro desconhecido';
		} finally {
			loading = false;
		}
	}
	
	function formatarPreco(preco: number): string {
		return new Intl.NumberFormat('pt-BR', {
			style: 'currency',
			currency: 'BRL'
		}).format(preco);
	}
	
	function calcularEconomia(opcaoMaisBarata: number, opcaoAtual: number): number {
		return ((opcaoAtual - opcaoMaisBarata) / opcaoMaisBarata) * 100;
	}
	
	function obterClasseEconomia(economia: number): string {
		if (economia === 0) return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200';
		if (economia < 10) return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200';
		if (economia < 30) return 'bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200';
		return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200';
	}
</script>

<div class="comparacao-fornecedores">
	{#if loading}
		<div class="flex items-center justify-center p-8">
			<div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
			<span class="ml-4 text-gray-600 dark:text-gray-400">Carregando comparações...</span>
		</div>
	{:else if error}
		<div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4">
			<div class="flex items-center">
				<svg class="h-5 w-5 text-red-400 mr-2" fill="currentColor" viewBox="0 0 20 20">
					<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
				</svg>
				<span class="text-red-800 dark:text-red-200">{error}</span>
			</div>
		</div>
	{:else if comparacoes.length === 0}
		<div class="bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-8 text-center">
			<svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
			</svg>
			<p class="mt-4 text-gray-600 dark:text-gray-400">
				Nenhuma comparação disponível para os filtros selecionados
			</p>
		</div>
	{:else}
		<div class="space-y-6">
			{#each comparacoes as comparacao}
				{@const precoMinimo = Math.min(...comparacao.opcoes.map(o => o.preco_tabela))}
				
				<div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
					<!-- Header do Grupo -->
					<div class="bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 px-6 py-4 border-b border-gray-200 dark:border-gray-700">
						<div class="flex items-center justify-between">
							<div>
								<h3 class="text-lg font-semibold text-gray-900 dark:text-white">
									{comparacao.produto}
								</h3>
								<div class="flex items-center gap-4 mt-1 text-sm text-gray-600 dark:text-gray-400">
									<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium {comparacao.tipo === 'PREMIUM' ? 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200' : 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200'}">
										{comparacao.tipo}
									</span>
									{#if comparacao.marca}
										<span class="font-medium">{comparacao.marca}</span>
									{/if}
									<span>{comparacao.material} {comparacao.indice_refracao}</span>
								</div>
							</div>
							<div class="text-right">
								<p class="text-sm text-gray-600 dark:text-gray-400">A partir de</p>
								<p class="text-2xl font-bold text-green-600 dark:text-green-400">
									{formatarPreco(precoMinimo)}
								</p>
							</div>
						</div>
					</div>
					
					<!-- Tabela de Comparação -->
					<div class="overflow-x-auto">
						<table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
							<thead class="bg-gray-50 dark:bg-gray-900">
								<tr>
									<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
										Fornecedor
									</th>
									<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
										Marca
									</th>
									<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
										SKU
									</th>
									<th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
										Preço Tabela
									</th>
									<th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
										Diferença
									</th>
									<th scope="col" class="px-6 py-3 text-center text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
										Ação
									</th>
								</tr>
							</thead>
							<tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
								{#each comparacao.opcoes as opcao, idx}
									{@const economia = calcularEconomia(precoMinimo, opcao.preco_tabela)}
									{@const isMelhorPreco = opcao.preco_tabela === precoMinimo}
									
									<tr class="{isMelhorPreco ? 'bg-green-50 dark:bg-green-900/10' : ''} hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
										<td class="px-6 py-4 whitespace-nowrap">
											<div class="flex items-center">
												{#if isMelhorPreco}
													<svg class="h-5 w-5 text-green-600 mr-2" fill="currentColor" viewBox="0 0 20 20">
														<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
													</svg>
												{/if}
												<span class="text-sm font-medium text-gray-900 dark:text-white">
													{opcao.fornecedor}
												</span>
											</div>
										</td>
										<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">
											{opcao.marca}
										</td>
										<td class="px-6 py-4 whitespace-nowrap">
											<code class="text-xs bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded text-gray-700 dark:text-gray-300">
												{opcao.sku}
											</code>
										</td>
										<td class="px-6 py-4 whitespace-nowrap text-right">
											<span class="text-sm font-semibold {isMelhorPreco ? 'text-green-600 dark:text-green-400' : 'text-gray-900 dark:text-white'}">
												{formatarPreco(opcao.preco_tabela)}
											</span>
										</td>
										<td class="px-6 py-4 whitespace-nowrap text-right">
											{#if isMelhorPreco}
												<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">
													Melhor preço
												</span>
											{:else}
												<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium {obterClasseEconomia(economia)}">
													+{economia.toFixed(1)}%
												</span>
											{/if}
										</td>
										<td class="px-6 py-4 whitespace-nowrap text-center">
											<button
												class="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
												on:click={() => {/* Adicionar ao carrinho ou decisão */}}
											>
												Selecionar
											</button>
										</td>
									</tr>
								{/each}
							</tbody>
						</table>
					</div>
					
					<!-- Informações Adicionais -->
					<div class="bg-gray-50 dark:bg-gray-900 px-6 py-3 border-t border-gray-200 dark:border-gray-700">
						<div class="flex items-center justify-between text-xs text-gray-600 dark:text-gray-400">
							<span>
								{comparacao.opcoes.length} {comparacao.opcoes.length === 1 ? 'fornecedor disponível' : 'fornecedores disponíveis'}
							</span>
							<span>
								Economia máxima: <strong class="text-green-600 dark:text-green-400">
									{formatarPreco(Math.max(...comparacao.opcoes.map(o => o.preco_tabela)) - precoMinimo)}
								</strong>
							</span>
						</div>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>

<style>
	.comparacao-fornecedores {
		@apply w-full;
	}
</style>
