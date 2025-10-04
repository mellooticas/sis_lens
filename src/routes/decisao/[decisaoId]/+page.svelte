<!-- 
	Página de Confirmação de Decisão
	Rota: /decisao/[decisaoId]
	
	Confirma a decisão de compra e registra no histórico
-->
<script lang="ts">
	import type { PageData } from './$types';
	import { goto } from '$app/navigation';
	
	export let data: PageData;
	
	let confirmando = false;
	let observacoes = '';
	
	async function confirmarDecisao() {
		confirmando = true;
		try {
			// TODO: Implementar chamada para rpc_confirmar_decisao
			console.log('Confirmando decisão:', data.decisao?.id);
			console.log('Observações:', observacoes);
			
			// Simular delay
			await new Promise(resolve => setTimeout(resolve, 1000));
			
			// Redirecionar para histórico
			await goto('/historico');
		} catch (error) {
			console.error('Erro ao confirmar decisão:', error);
		} finally {
			confirmando = false;
		}
	}
	
	function cancelar() {
		history.back();
	}
</script>

<svelte:head>
	<title>Confirmar Decisão - BestLens</title>
	<meta name="description" content="Confirme sua decisão de compra" />
</svelte:head>

<div class="container mx-auto px-4 py-8 max-w-4xl">
	<!-- Header -->
	<div class="mb-8">
		<nav class="text-sm breadcrumbs mb-4">
			<a href="/buscar" class="text-blue-600 hover:text-blue-800">Buscar</a>
			<span class="mx-2 text-gray-500">></span>
			<a href="/ranking?lente_id={data.decisao?.lente_id}" class="text-blue-600 hover:text-blue-800">Ranking</a>
			<span class="mx-2 text-gray-500">></span>
			<span class="text-gray-700">Confirmar Decisão</span>
		</nav>
		
		<h1 class="text-3xl font-bold text-gray-900 mb-2">
			Confirmar Decisão de Compra
		</h1>
		<p class="text-gray-600">
			Revise os detalhes antes de confirmar sua escolha
		</p>
	</div>
	
	{#if data.decisao}
		<div class="bg-white rounded-lg shadow-lg overflow-hidden">
			<!-- Resumo da Decisão -->
			<div class="px-6 py-4 bg-green-50 border-b border-green-200">
				<h2 class="text-xl font-semibold text-green-900 flex items-center">
					<span class="text-2xl mr-2">✅</span>
					Decisão Pronta para Confirmação
				</h2>
			</div>
			
			<div class="p-6">
				<!-- Informações da Lente -->
				<div class="mb-6">
					<h3 class="text-lg font-semibold text-gray-900 mb-3">
						📋 Lente Selecionada
					</h3>
					<div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
						<h4 class="font-semibold text-blue-900 mb-2">
							{data.decisao.lente_nome}
						</h4>
						<div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
							<div>
								<span class="text-gray-600">Marca:</span>
								<span class="font-medium ml-1">{data.decisao.lente_marca}</span>
							</div>
							<div>
								<span class="text-gray-600">Material:</span>
								<span class="font-medium ml-1">{data.decisao.lente_material}</span>
							</div>
							<div>
								<span class="text-gray-600">Índice:</span>
								<span class="font-medium ml-1">{data.decisao.lente_indice}</span>
							</div>
							<div>
								<span class="text-gray-600">Tipo:</span>
								<span class="font-medium ml-1">{data.decisao.lente_tipo}</span>
							</div>
						</div>
					</div>
				</div>
				
				<!-- Fornecedor Escolhido -->
				<div class="mb-6">
					<h3 class="text-lg font-semibold text-gray-900 mb-3">
						🏭 Laboratório Escolhido
					</h3>
					<div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
						<div class="flex items-start justify-between">
							<div>
								<h4 class="font-semibold text-yellow-900 mb-2">
									{data.decisao.laboratorio_nome}
								</h4>
								<div class="text-sm text-gray-600">
									{data.decisao.laboratorio_regiao || 'Nacional'}
								</div>
							</div>
							<div class="text-right">
								<div class="text-sm text-gray-600">Ranking</div>
								<div class="text-xl font-bold text-yellow-600">
									#{data.decisao.posicao_ranking || '?'}
								</div>
							</div>
						</div>
					</div>
				</div>
				
				<!-- Detalhes Financeiros -->
				<div class="mb-6">
					<h3 class="text-lg font-semibold text-gray-900 mb-3">
						💰 Detalhes Financeiros
					</h3>
					<div class="bg-gray-50 border border-gray-200 rounded-lg p-4">
						<div class="grid grid-cols-2 md:grid-cols-4 gap-4">
							<div>
								<div class="text-sm text-gray-600">Preço Base</div>
								<div class="font-semibold text-gray-900">
									R$ {data.decisao.preco_base?.toFixed(2) || '0,00'}
								</div>
							</div>
							{#if data.decisao.desconto_valor && data.decisao.desconto_valor > 0}
								<div>
									<div class="text-sm text-gray-600">Desconto</div>
									<div class="font-semibold text-green-600">
										- R$ {data.decisao.desconto_valor.toFixed(2)}
									</div>
								</div>
							{/if}
							<div>
								<div class="text-sm text-gray-600">Frete</div>
								<div class="font-semibold text-gray-900">
									R$ {data.decisao.frete_valor?.toFixed(2) || '0,00'}
								</div>
							</div>
							<div>
								<div class="text-sm text-gray-600">Total Final</div>
								<div class="font-bold text-lg text-blue-600">
									R$ {data.decisao.preco_final?.toFixed(2) || '0,00'}
								</div>
							</div>
						</div>
					</div>
				</div>
				
				<!-- Prazo de Entrega -->
				<div class="mb-6">
					<h3 class="text-lg font-semibold text-gray-900 mb-3">
						⏰ Prazo de Entrega
					</h3>
					<div class="bg-purple-50 border border-purple-200 rounded-lg p-4">
						<div class="flex items-center">
							<span class="text-2xl mr-3">📅</span>
							<div>
								<div class="font-semibold text-purple-900">
									{data.decisao.prazo_dias || '?'} dias úteis
								</div>
								<div class="text-sm text-gray-600">
									Previsão de entrega conforme histórico do laboratório
								</div>
							</div>
						</div>
					</div>
				</div>
				
				<!-- Critério Utilizado -->
				<div class="mb-6">
					<h3 class="text-lg font-semibold text-gray-900 mb-3">
						🎯 Critério de Decisão
					</h3>
					<div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
						<div class="flex items-center">
							{#if data.decisao.criterio === 'URGENCIA'}
								<span class="text-2xl mr-3">🚨</span>
								<div>
									<div class="font-semibold text-blue-900">Urgência</div>
									<div class="text-sm text-gray-600">Prioridade para prazo de entrega</div>
								</div>
							{:else if data.decisao.criterio === 'ESPECIAL'}
								<span class="text-2xl mr-3">⭐</span>
								<div>
									<div class="font-semibold text-blue-900">Especial</div>
									<div class="text-sm text-gray-600">Prioridade para qualidade</div>
								</div>
							{:else}
								<span class="text-2xl mr-3">⚖️</span>
								<div>
									<div class="font-semibold text-blue-900">Normal</div>
									<div class="text-sm text-gray-600">Equilíbrio entre preço, prazo e qualidade</div>
								</div>
							{/if}
						</div>
					</div>
				</div>
				
				<!-- Observações -->
				<div class="mb-6">
					<label for="observacoes" class="block text-lg font-semibold text-gray-900 mb-3">
						📝 Observações (Opcional)
					</label>
					<textarea
						id="observacoes"
						bind:value={observacoes}
						class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
						rows="3"
						placeholder="Adicione observações sobre esta decisão..."
					></textarea>
				</div>
				
				<!-- Ações -->
				<div class="flex gap-4 pt-6 border-t border-gray-200">
					<button
						type="button"
						class="flex-1 bg-gray-500 hover:bg-gray-600 text-white px-6 py-3 rounded-lg font-medium transition-colors"
						on:click={cancelar}
						disabled={confirmando}
					>
						❌ Cancelar
					</button>
					<button
						type="button"
						class="flex-1 bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
						on:click={confirmarDecisao}
						disabled={confirmando}
					>
						{#if confirmando}
							<span class="inline-block animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></span>
							Confirmando...
						{:else}
							✅ Confirmar Decisão
						{/if}
					</button>
				</div>
			</div>
		</div>
	{:else}
		<!-- Estado de erro -->
		<div class="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
			<span class="text-4xl mb-4 block">❌</span>
			<h2 class="text-xl font-semibold text-red-900 mb-2">
				Decisão não encontrada
			</h2>
			<p class="text-red-700 mb-4">
				Não foi possível carregar os detalhes desta decisão.
			</p>
			<a
				href="/buscar"
				class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg inline-block transition-colors"
			>
				Voltar à Busca
			</a>
		</div>
	{/if}
</div>

<style>
	.breadcrumbs {
		@apply flex items-center;
	}
</style>