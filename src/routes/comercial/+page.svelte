<!-- 
	Página de Gestão Comercial
	Rota: /comercial
	
	Gestão de preços, descontos, margens e políticas comerciais
-->
<script lang="ts">
	import type { PageData } from './$types';
	
	export let data: PageData;
	
	// Filtros
	let laboratorioLocal = data.filtros?.laboratorio || '';
	let marcaLocal = data.filtros?.marca || '';
	let statusLocal = data.filtros?.status || 'ativo';
	let tipoLocal = data.filtros?.tipo || 'todos';
	
	// Estado local
	let carregando = false;
	let modoEdicao = false;
	let itemEditando: any = null;
	
	function aplicarFiltros() {
		const params = new URLSearchParams();
		if (laboratorioLocal) params.set('laboratorio', laboratorioLocal);
		if (marcaLocal) params.set('marca', marcaLocal);
		if (statusLocal) params.set('status', statusLocal);
		if (tipoLocal) params.set('tipo', tipoLocal);
		
		window.location.href = `/comercial?${params.toString()}`;
	}
	
	function limparFiltros() {
		laboratorioLocal = '';
		marcaLocal = '';
		statusLocal = 'ativo';
		tipoLocal = 'todos';
		window.location.href = '/comercial';
	}
	
	function formatarMoeda(valor: number) {
		return valor.toLocaleString('pt-BR', {
			style: 'currency',
			currency: 'BRL'
		});
	}
	
	function formatarData(data: string) {
		return new Date(data).toLocaleDateString('pt-BR');
	}
	
	function editarItem(item: any, tipo: 'preco' | 'desconto') {
		itemEditando = { ...item, tipo };
		modoEdicao = true;
	}
	
	function cancelarEdicao() {
		itemEditando = null;
		modoEdicao = false;
	}
	
	async function salvarItem() {
		if (!itemEditando) return;
		
		try {
			carregando = true;
			// TODO: Implementar API de salvamento
			console.log('Salvando item:', itemEditando);
			
			// Simular delay
			await new Promise(resolve => setTimeout(resolve, 1000));
			
			// Recarregar página
			window.location.reload();
		} catch (error) {
			console.error('Erro ao salvar:', error);
		} finally {
			carregando = false;
		}
	}
	
	function novoPreco() {
		itemEditando = {
			tipo: 'preco',
			laboratorio_id: '',
			produto_id: '',
			preco_base: 0,
			margem_pct: 0,
			vigencia_inicio: new Date().toISOString().split('T')[0],
			vigencia_fim: '',
			ativo: true
		};
		modoEdicao = true;
	}
	
	function novoDesconto() {
		itemEditando = {
			tipo: 'desconto',
			nome: '',
			tipo_desconto: 'PERCENTUAL',
			valor: 0,
			escopo: 'PRODUTO',
			laboratorio_id: '',
			marca_id: '',
			produto_id: '',
			vigencia_inicio: new Date().toISOString().split('T')[0],
			vigencia_fim: '',
			ativo: true
		};
		modoEdicao = true;
	}
</script>

<svelte:head>
	<title>Gestão Comercial - BestLens</title>
	<meta name="description" content="Gestão de preços, descontos e políticas comerciais" />
</svelte:head>

<div class="container mx-auto px-4 py-8">
	<!-- Header -->
	<div class="mb-8">
		<nav class="text-sm breadcrumbs mb-4">
			<a href="/" class="text-blue-600 hover:text-blue-800">Dashboard</a>
			<span class="mx-2 text-gray-500">></span>
			<span class="text-gray-700">Comercial</span>
		</nav>
		
		<div class="flex items-center justify-between">
			<div>
				<h1 class="text-3xl font-bold text-gray-900 mb-2">
					💰 Gestão Comercial
				</h1>
				<p class="text-gray-600">
					Preços, descontos, margens e políticas comerciais
				</p>
			</div>
			<div class="flex gap-2">
				<button
					type="button"
					class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors"
					on:click={novoPreco}
				>
					💲 Novo Preço
				</button>
				<button
					type="button"
					class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg transition-colors"
					on:click={novoDesconto}
				>
					🏷️ Novo Desconto
				</button>
			</div>
		</div>
	</div>
	
	<!-- Estatísticas Comerciais -->
	{#if data.estatisticas}
		<div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
			<div class="bg-white rounded-lg shadow-lg p-6">
				<div class="flex items-center">
					<div class="text-3xl mr-4">💲</div>
					<div>
						<div class="text-2xl font-bold text-gray-900">
							{data.estatisticas.total_precos_ativos || 0}
						</div>
						<div class="text-sm text-gray-600">Preços Ativos</div>
					</div>
				</div>
			</div>
			
			<div class="bg-white rounded-lg shadow-lg p-6">
				<div class="flex items-center">
					<div class="text-3xl mr-4">🏷️</div>
					<div>
						<div class="text-2xl font-bold text-gray-900">
							{data.estatisticas.total_descontos_ativos || 0}
						</div>
						<div class="text-sm text-gray-600">Descontos Ativos</div>
					</div>
				</div>
			</div>
			
			<div class="bg-white rounded-lg shadow-lg p-6">
				<div class="flex items-center">
					<div class="text-3xl mr-4">📊</div>
					<div>
						<div class="text-2xl font-bold text-gray-900">
							{data.estatisticas.margem_media_pct?.toFixed(1) || '0.0'}%
						</div>
						<div class="text-sm text-gray-600">Margem Média</div>
					</div>
				</div>
			</div>
			
			<div class="bg-white rounded-lg shadow-lg p-6">
				<div class="flex items-center">
					<div class="text-3xl mr-4">💰</div>
					<div>
						<div class="text-2xl font-bold text-gray-900">
							{formatarMoeda(data.estatisticas.economia_desconto_mes || 0)}
						</div>
						<div class="text-sm text-gray-600">Economia Mensal</div>
					</div>
				</div>
			</div>
		</div>
	{/if}
	
	<!-- Filtros -->
	<div class="bg-white rounded-lg shadow-lg p-6 mb-6">
		<h2 class="text-lg font-semibold text-gray-900 mb-4">
			🔍 Filtros
		</h2>
		
		<div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
			<div>
				<label for="tipo" class="block text-sm font-medium text-gray-700 mb-1">
					Tipo
				</label>
				<select
					id="tipo"
					bind:value={tipoLocal}
					class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
				>
					<option value="todos">Todos</option>
					<option value="precos">Preços</option>
					<option value="descontos">Descontos</option>
				</select>
			</div>
			
			<div>
				<label for="laboratorio" class="block text-sm font-medium text-gray-700 mb-1">
					Laboratório
				</label>
				<select
					id="laboratorio"
					bind:value={laboratorioLocal}
					class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
				>
					<option value="">Todos</option>
					{#each data.laboratorios || [] as lab}
						<option value={lab.id}>{lab.nome}</option>
					{/each}
				</select>
			</div>
			
			<div>
				<label for="marca" class="block text-sm font-medium text-gray-700 mb-1">
					Marca
				</label>
				<select
					id="marca"
					bind:value={marcaLocal}
					class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
				>
					<option value="">Todas</option>
					{#each data.marcas || [] as marca}
						<option value={marca.id}>{marca.nome}</option>
					{/each}
				</select>
			</div>
			
			<div>
				<label for="status" class="block text-sm font-medium text-gray-700 mb-1">
					Status
				</label>
				<select
					id="status"
					bind:value={statusLocal}
					class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
				>
					<option value="ativo">Ativos</option>
					<option value="inativo">Inativos</option>
					<option value="todos">Todos</option>
				</select>
			</div>
		</div>
		
		<div class="flex gap-2">
			<button
				type="button"
				class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors"
				on:click={aplicarFiltros}
			>
				🔍 Filtrar
			</button>
			<button
				type="button"
				class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg transition-colors"
				on:click={limparFiltros}
			>
				🗑️ Limpar
			</button>
		</div>
	</div>
	
	<!-- Tabs de Conteúdo -->
	<div class="bg-white rounded-lg shadow-lg overflow-hidden">
		<div class="border-b border-gray-200">
			<nav class="flex space-x-8 px-6 py-3">
				<button
					type="button"
					class="py-2 px-1 border-b-2 font-medium text-sm
						{tipoLocal === 'todos' || tipoLocal === 'precos' 
							? 'border-blue-500 text-blue-600' 
							: 'border-transparent text-gray-500 hover:text-gray-700'}"
					on:click={() => { tipoLocal = 'precos'; aplicarFiltros(); }}
				>
					💲 Preços ({data.precos?.length || 0})
				</button>
				<button
					type="button"
					class="py-2 px-1 border-b-2 font-medium text-sm
						{tipoLocal === 'todos' || tipoLocal === 'descontos' 
							? 'border-blue-500 text-blue-600' 
							: 'border-transparent text-gray-500 hover:text-gray-700'}"
					on:click={() => { tipoLocal = 'descontos'; aplicarFiltros(); }}
				>
					🏷️ Descontos ({data.descontos?.length || 0})
				</button>
			</nav>
		</div>
		
		<!-- Tabela de Preços -->
		{#if tipoLocal === 'todos' || tipoLocal === 'precos'}
			<div class="p-6">
				<h3 class="text-lg font-semibold text-gray-900 mb-4">
					💲 Tabela de Preços
				</h3>
				
				<div class="overflow-x-auto">
					<table class="min-w-full divide-y divide-gray-200">
						<thead class="bg-gray-50">
							<tr>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Produto
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Laboratório
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Preço Base
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Margem
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Vigência
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Status
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Ações
								</th>
							</tr>
						</thead>
						<tbody class="bg-white divide-y divide-gray-200">
							{#each data.precos || [] as preco}
								<tr class="hover:bg-gray-50">
									<td class="px-6 py-4 text-sm">
										<div class="font-medium text-gray-900">
											{preco.produto_nome}
										</div>
										<div class="text-gray-500">
											{preco.sku_fantasia}
										</div>
									</td>
									<td class="px-6 py-4 text-sm text-gray-900">
										{preco.laboratorio_nome}
									</td>
									<td class="px-6 py-4 text-sm font-medium text-gray-900">
										{formatarMoeda(preco.preco_base || 0)}
									</td>
									<td class="px-6 py-4 text-sm text-gray-900">
										{preco.margem_pct || 0}%
									</td>
									<td class="px-6 py-4 text-sm text-gray-900">
										{formatarData(preco.vigencia_inicio)}
										{#if preco.vigencia_fim}
											<br/>até {formatarData(preco.vigencia_fim)}
										{/if}
									</td>
									<td class="px-6 py-4 text-sm">
										{#if preco.ativo}
											<span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs">
												✅ Ativo
											</span>
										{:else}
											<span class="bg-red-100 text-red-800 px-2 py-1 rounded-full text-xs">
												❌ Inativo
											</span>
										{/if}
									</td>
									<td class="px-6 py-4 text-sm">
										<button
											type="button"
											class="text-blue-600 hover:text-blue-800 mr-2"
											on:click={() => editarItem(preco, 'preco')}
										>
											✏️ Editar
										</button>
									</td>
								</tr>
							{:else}
								<tr>
									<td colspan="7" class="px-6 py-12 text-center text-gray-500">
										<span class="text-4xl block mb-4">💲</span>
										<p>Nenhum preço encontrado</p>
									</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			</div>
		{/if}
		
		<!-- Tabela de Descontos -->
		{#if tipoLocal === 'todos' || tipoLocal === 'descontos'}
			<div class="p-6 {tipoLocal === 'todos' ? 'border-t border-gray-200' : ''}">
				<h3 class="text-lg font-semibold text-gray-900 mb-4">
					🏷️ Descontos Ativos
				</h3>
				
				<div class="overflow-x-auto">
					<table class="min-w-full divide-y divide-gray-200">
						<thead class="bg-gray-50">
							<tr>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Nome
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Tipo
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Valor
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Escopo
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Vigência
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Status
								</th>
								<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
									Ações
								</th>
							</tr>
						</thead>
						<tbody class="bg-white divide-y divide-gray-200">
							{#each data.descontos || [] as desconto}
								<tr class="hover:bg-gray-50">
									<td class="px-6 py-4 text-sm font-medium text-gray-900">
										{desconto.nome}
									</td>
									<td class="px-6 py-4 text-sm text-gray-900">
										{desconto.tipo_desconto === 'PERCENTUAL' ? '📊 Percentual' : '💰 Valor Fixo'}
									</td>
									<td class="px-6 py-4 text-sm font-medium text-green-600">
										{#if desconto.tipo_desconto === 'PERCENTUAL'}
											{desconto.valor}%
										{:else}
											{formatarMoeda(desconto.valor)}
										{/if}
									</td>
									<td class="px-6 py-4 text-sm text-gray-900">
										{#if desconto.escopo === 'LABORATORIO'}
											🏢 Laboratório
										{:else if desconto.escopo === 'MARCA'}
											🏷️ Marca
										{:else}
											📦 Produto
										{/if}
									</td>
									<td class="px-6 py-4 text-sm text-gray-900">
										{formatarData(desconto.vigencia_inicio)}
										{#if desconto.vigencia_fim}
											<br/>até {formatarData(desconto.vigencia_fim)}
										{/if}
									</td>
									<td class="px-6 py-4 text-sm">
										{#if desconto.ativo}
											<span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs">
												✅ Ativo
											</span>
										{:else}
											<span class="bg-red-100 text-red-800 px-2 py-1 rounded-full text-xs">
												❌ Inativo
											</span>
										{/if}
									</td>
									<td class="px-6 py-4 text-sm">
										<button
											type="button"
											class="text-blue-600 hover:text-blue-800 mr-2"
											on:click={() => editarItem(desconto, 'desconto')}
										>
											✏️ Editar
										</button>
									</td>
								</tr>
							{:else}
								<tr>
									<td colspan="7" class="px-6 py-12 text-center text-gray-500">
										<span class="text-4xl block mb-4">🏷️</span>
										<p>Nenhum desconto encontrado</p>
									</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			</div>
		{/if}
	</div>
</div>

<!-- Modal de Edição -->
{#if modoEdicao && itemEditando}
	<div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
		<div class="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-screen overflow-y-auto">
			<div class="px-6 py-4 border-b border-gray-200">
				<h3 class="text-lg font-semibold text-gray-900">
					{itemEditando.tipo === 'preco' ? '💲 Editar Preço' : '🏷️ Editar Desconto'}
				</h3>
			</div>
			
			<div class="p-6">
				<!-- Formulário será implementado aqui -->
				<div class="grid grid-cols-2 gap-4">
					<div>
						<label for="item-nome" class="block text-sm font-medium text-gray-700 mb-1">
							Nome/Produto
						</label>
						<input
							id="item-nome"
							type="text"
							bind:value={itemEditando.nome}
							class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
						/>
					</div>
					
					<div>
						<label for="item-valor" class="block text-sm font-medium text-gray-700 mb-1">
							{itemEditando.tipo === 'preco' ? 'Preço Base' : 'Valor Desconto'}
						</label>
						<input
							id="item-valor"
							type="number"
							bind:value={itemEditando.valor}
							step="0.01"
							class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
						/>
					</div>
				</div>
			</div>
			
			<div class="px-6 py-4 border-t border-gray-200 flex justify-end gap-2">
				<button
					type="button"
					class="px-4 py-2 text-gray-700 bg-gray-200 rounded-lg hover:bg-gray-300 transition-colors"
					on:click={cancelarEdicao}
				>
					Cancelar
				</button>
				<button
					type="button"
					class="px-4 py-2 text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors"
					on:click={salvarItem}
					disabled={carregando}
				>
					{carregando ? 'Salvando...' : 'Salvar'}
				</button>
			</div>
		</div>
	</div>
{/if}

<style>
	.breadcrumbs {
		display: flex;
		align-items: center;
	}
</style>