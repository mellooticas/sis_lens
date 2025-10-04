<!-- 
	Página de Sistema de Vouchers
	Rota: /vouchers
	
	Gestão de vouchers, cupons, programa de pontuação e recompensas
-->
<script lang="ts">
	import type { PageData } from './$types';
	
	export let data: PageData;
	
	// Filtros
	let statusLocal = data.filtros?.status || 'ativo';
	let tipoLocal = data.filtros?.tipo || 'todos';
	let buscaLocal = data.filtros?.busca || '';
	
	// Estado local
	let carregando = false;
	let modoEdicao = false;
	let voucherEditando: any = null;
	let mostrarGerador = false;
	
	function aplicarFiltros() {
		const params = new URLSearchParams();
		if (statusLocal) params.set('status', statusLocal);
		if (tipoLocal) params.set('tipo', tipoLocal);
		if (buscaLocal) params.set('busca', buscaLocal);
		
		window.location.href = `/vouchers?${params.toString()}`;
	}
	
	function limparFiltros() {
		statusLocal = 'ativo';
		tipoLocal = 'todos';
		buscaLocal = '';
		window.location.href = '/vouchers';
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
	
	function formatarDataHora(data: string) {
		return new Date(data).toLocaleString('pt-BR');
	}
	
	function novoVoucher() {
		voucherEditando = {
			codigo: '',
			tipo: 'DESCONTO',
			valor: 0,
			tipo_valor: 'PERCENTUAL',
			descricao: '',
			quantidade_total: 1,
			uso_maximo_cliente: 1,
			valido_ate: '',
			ativo: true,
			publico: false
		};
		modoEdicao = true;
	}
	
	function editarVoucher(voucher: any) {
		voucherEditando = { ...voucher };
		modoEdicao = true;
	}
	
	function cancelarEdicao() {
		voucherEditando = null;
		modoEdicao = false;
	}
	
	async function salvarVoucher() {
		if (!voucherEditando) return;
		
		try {
			carregando = true;
			// TODO: Implementar API de salvamento
			console.log('Salvando voucher:', voucherEditando);
			
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
	
	function gerarCodigo() {
		const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
		let codigo = '';
		for (let i = 0; i < 8; i++) {
			codigo += chars.charAt(Math.floor(Math.random() * chars.length));
		}
		if (voucherEditando) {
			voucherEditando.codigo = codigo;
		}
	}
	
	async function alternarStatus(voucher: any) {
		try {
			carregando = true;
			// TODO: Implementar API de toggle status
			console.log('Alterando status:', voucher.id);
			
			// Simular delay
			await new Promise(resolve => setTimeout(resolve, 500));
			
			// Recarregar página
			window.location.reload();
		} catch (error) {
			console.error('Erro ao alterar status:', error);
		} finally {
			carregando = false;
		}
	}
	
	function copiarCodigo(codigo: string) {
		navigator.clipboard.writeText(codigo);
		// TODO: Mostrar toast de sucesso
	}
</script>

<svelte:head>
	<title>Sistema de Vouchers - BestLens</title>
	<meta name="description" content="Gestão de vouchers, cupons e programa de fidelidade" />
</svelte:head>

<div class="container mx-auto px-4 py-8">
	<!-- Header -->
	<div class="mb-8">
		<nav class="text-sm breadcrumbs mb-4">
			<a href="/" class="text-blue-600 hover:text-blue-800">Dashboard</a>
			<span class="mx-2 text-gray-500">></span>
			<span class="text-gray-700">Vouchers</span>
		</nav>
		
		<div class="flex items-center justify-between">
			<div>
				<h1 class="text-3xl font-bold text-gray-900 mb-2">
					🎟️ Sistema de Vouchers
				</h1>
				<p class="text-gray-600">
					Gestão de cupons, descontos e programa de fidelidade
				</p>
			</div>
			<div class="flex gap-2">
				<button
					type="button"
					class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg transition-colors"
					on:click={() => mostrarGerador = true}
				>
					⚡ Gerador Rápido
				</button>
				<button
					type="button"
					class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors"
					on:click={novoVoucher}
				>
					🎟️ Novo Voucher
				</button>
			</div>
		</div>
	</div>
	
	<!-- Estatísticas do Programa -->
	{#if data.estatisticas}
		<div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
			<div class="bg-white rounded-lg shadow-lg p-6">
				<div class="flex items-center">
					<div class="text-3xl mr-4">🎟️</div>
					<div>
						<div class="text-2xl font-bold text-gray-900">
							{data.estatisticas.vouchers_ativos || 0}
						</div>
						<div class="text-sm text-gray-600">Vouchers Ativos</div>
					</div>
				</div>
			</div>
			
			<div class="bg-white rounded-lg shadow-lg p-6">
				<div class="flex items-center">
					<div class="text-3xl mr-4">✅</div>
					<div>
						<div class="text-2xl font-bold text-gray-900">
							{data.estatisticas.resgates_mes || 0}
						</div>
						<div class="text-sm text-gray-600">Resgates no Mês</div>
					</div>
				</div>
			</div>
			
			<div class="bg-white rounded-lg shadow-lg p-6">
				<div class="flex items-center">
					<div class="text-3xl mr-4">💰</div>
					<div>
						<div class="text-2xl font-bold text-gray-900">
							{formatarMoeda(data.estatisticas.economia_gerada || 0)}
						</div>
						<div class="text-sm text-gray-600">Economia Gerada</div>
					</div>
				</div>
			</div>
			
			<div class="bg-white rounded-lg shadow-lg p-6">
				<div class="flex items-center">
					<div class="text-3xl mr-4">👥</div>
					<div>
						<div class="text-2xl font-bold text-gray-900">
							{data.estatisticas.usuarios_participantes || 0}
						</div>
						<div class="text-sm text-gray-600">Usuários Participantes</div>
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
		
		<div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
			<div>
				<label for="busca" class="block text-sm font-medium text-gray-700 mb-1">
					Buscar Voucher
				</label>
				<input
					id="busca"
					type="text"
					bind:value={buscaLocal}
					placeholder="Código ou descrição"
					class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
					on:keydown={(e) => e.key === 'Enter' && aplicarFiltros()}
				/>
			</div>
			
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
					<option value="DESCONTO">Desconto</option>
					<option value="FRETE_GRATIS">Frete Grátis</option>
					<option value="CREDITO">Crédito</option>
					<option value="BRINDE">Brinde</option>
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
					<option value="expirado">Expirados</option>
					<option value="esgotado">Esgotados</option>
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
	
	<!-- Grid de Vouchers -->
	<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
		{#each data.vouchers || [] as voucher}
			<div class="bg-white rounded-lg shadow-lg overflow-hidden">
				<!-- Header do Voucher -->
				<div class="px-6 py-4 bg-gradient-to-r from-blue-500 to-purple-600 text-white">
					<div class="flex items-center justify-between">
						<div>
							<h3 class="text-lg font-bold">
								{#if voucher.tipo === 'DESCONTO'}
									🏷️ Desconto
								{:else if voucher.tipo === 'FRETE_GRATIS'}
									🚚 Frete Grátis
								{:else if voucher.tipo === 'CREDITO'}
									💰 Crédito
								{:else}
									🎁 Brinde
								{/if}
							</h3>
							<div class="text-sm opacity-90">
								{voucher.descricao || 'Voucher especial'}
							</div>
						</div>
						<div class="text-right">
							<div class="text-2xl font-bold">
								{#if voucher.tipo_valor === 'PERCENTUAL'}
									{voucher.valor}%
								{:else}
									{formatarMoeda(voucher.valor)}
								{/if}
							</div>
						</div>
					</div>
				</div>
				
				<!-- Código do Voucher -->
				<div class="px-6 py-4 bg-gray-50 border-b border-gray-200">
					<div class="flex items-center justify-between">
						<div class="font-mono text-lg font-bold text-gray-900 bg-white px-3 py-2 rounded border-2 border-dashed border-gray-300">
							{voucher.codigo}
						</div>
						<button
							type="button"
							class="text-blue-600 hover:text-blue-800 text-sm"
							on:click={() => copiarCodigo(voucher.codigo)}
						>
							📋 Copiar
						</button>
					</div>
				</div>
				
				<!-- Detalhes -->
				<div class="p-6">
					<div class="grid grid-cols-2 gap-4 text-sm mb-4">
						<div>
							<span class="text-gray-600">Usos:</span>
							<div class="font-medium">
								{voucher.quantidade_usada || 0} / {voucher.quantidade_total || '∞'}
							</div>
						</div>
						<div>
							<span class="text-gray-600">Válido até:</span>
							<div class="font-medium">
								{voucher.valido_ate ? formatarData(voucher.valido_ate) : 'Sem limite'}
							</div>
						</div>
					</div>
					
					<!-- Status -->
					<div class="flex items-center justify-between mb-4">
						<div>
							{#if voucher.ativo && (!voucher.valido_ate || new Date(voucher.valido_ate) > new Date())}
								<span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs">
									✅ Ativo
								</span>
							{:else if voucher.valido_ate && new Date(voucher.valido_ate) <= new Date()}
								<span class="bg-red-100 text-red-800 px-2 py-1 rounded-full text-xs">
									⏰ Expirado
								</span>
							{:else if (voucher.quantidade_usada || 0) >= (voucher.quantidade_total || 0)}
								<span class="bg-yellow-100 text-yellow-800 px-2 py-1 rounded-full text-xs">
									🔄 Esgotado
								</span>
							{:else}
								<span class="bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs">
									❌ Inativo
								</span>
							{/if}
						</div>
						
						{#if voucher.publico}
							<span class="bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-xs">
								🌐 Público
							</span>
						{:else}
							<span class="bg-purple-100 text-purple-800 px-2 py-1 rounded-full text-xs">
								🔒 Privado
							</span>
						{/if}
					</div>
					
					<!-- Ações -->
					<div class="flex gap-2">
						<button
							type="button"
							class="flex-1 bg-blue-600 hover:bg-blue-700 text-white px-3 py-2 rounded text-sm transition-colors"
							on:click={() => editarVoucher(voucher)}
						>
							✏️ Editar
						</button>
						<button
							type="button"
							class="bg-gray-500 hover:bg-gray-600 text-white px-3 py-2 rounded text-sm transition-colors"
							on:click={() => alternarStatus(voucher)}
							disabled={carregando}
						>
							{voucher.ativo ? '❌' : '✅'}
						</button>
					</div>
				</div>
			</div>
		{:else}
			<div class="col-span-full text-center py-12">
				<div class="text-gray-500">
					<span class="text-4xl block mb-4">🎟️</span>
					<p class="text-lg font-medium mb-2">Nenhum voucher encontrado</p>
					<p class="text-sm">
						{#if buscaLocal || statusLocal !== 'ativo' || tipoLocal !== 'todos'}
							Tente ajustar os filtros ou 
							<button class="text-blue-600 hover:text-blue-800 underline" on:click={limparFiltros}>
								limpe todos os filtros
							</button>
						{:else}
							Crie o primeiro voucher para começar
						{/if}
					</p>
				</div>
			</div>
		{/each}
	</div>
	
	<!-- Transações Recentes -->
	{#if data.transacoes && data.transacoes.length > 0}
		<div class="bg-white rounded-lg shadow-lg p-6">
			<h3 class="text-lg font-semibold text-gray-900 mb-4">
				🔄 Transações Recentes
			</h3>
			
			<div class="overflow-x-auto">
				<table class="min-w-full divide-y divide-gray-200">
					<thead class="bg-gray-50">
						<tr>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
								Data/Hora
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
								Voucher
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
								Usuário
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
								Valor Economizado
							</th>
							<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
								Status
							</th>
						</tr>
					</thead>
					<tbody class="bg-white divide-y divide-gray-200">
						{#each data.transacoes as transacao}
							<tr class="hover:bg-gray-50">
								<td class="px-6 py-4 text-sm text-gray-900">
									{formatarDataHora(transacao.data_uso)}
								</td>
								<td class="px-6 py-4 text-sm">
									<div class="font-medium text-gray-900">
										{transacao.voucher_codigo}
									</div>
									<div class="text-gray-500">
										{transacao.voucher_descricao}
									</div>
								</td>
								<td class="px-6 py-4 text-sm text-gray-900">
									{transacao.usuario_nome || transacao.usuario_email}
								</td>
								<td class="px-6 py-4 text-sm font-medium text-green-600">
									{formatarMoeda(transacao.valor_economizado || 0)}
								</td>
								<td class="px-6 py-4 text-sm">
									<span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs">
										✅ Usado
									</span>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>
	{/if}
</div>

<!-- Modal de Edição -->
{#if modoEdicao && voucherEditando}
	<div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
		<div class="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-screen overflow-y-auto">
			<div class="px-6 py-4 border-b border-gray-200">
				<h3 class="text-lg font-semibold text-gray-900">
					🎟️ {voucherEditando.id ? 'Editar' : 'Novo'} Voucher
				</h3>
			</div>
			
			<div class="p-6">
				<div class="grid grid-cols-2 gap-4 mb-4">
					<div>
						<label for="voucher-codigo" class="block text-sm font-medium text-gray-700 mb-1">
							Código *
						</label>
						<div class="flex gap-2">
							<input
								id="voucher-codigo"
								type="text"
								bind:value={voucherEditando.codigo}
								placeholder="Ex: DESCONTO10"
								class="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
							/>
							<button
								type="button"
								class="bg-gray-500 hover:bg-gray-600 text-white px-3 py-2 rounded-lg text-sm transition-colors"
								on:click={gerarCodigo}
							>
								🎲
							</button>
						</div>
					</div>
					
					<div>
						<label for="voucher-tipo" class="block text-sm font-medium text-gray-700 mb-1">
							Tipo *
						</label>
						<select
							id="voucher-tipo"
							bind:value={voucherEditando.tipo}
							class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
						>
							<option value="DESCONTO">🏷️ Desconto</option>
							<option value="FRETE_GRATIS">🚚 Frete Grátis</option>
							<option value="CREDITO">💰 Crédito</option>
							<option value="BRINDE">🎁 Brinde</option>
						</select>
					</div>
				</div>
				
				<div class="grid grid-cols-2 gap-4 mb-4">
					<div>
						<label for="voucher-valor" class="block text-sm font-medium text-gray-700 mb-1">
							Valor *
						</label>
						<input
							id="voucher-valor"
							type="number"
							bind:value={voucherEditando.valor}
							step="0.01"
							min="0"
							class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
						/>
					</div>
					
					<div>
						<label for="voucher-tipo-valor" class="block text-sm font-medium text-gray-700 mb-1">
							Tipo do Valor
						</label>
						<select
							id="voucher-tipo-valor"
							bind:value={voucherEditando.tipo_valor}
							class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
						>
							<option value="PERCENTUAL">📊 Percentual</option>
							<option value="FIXO">💰 Valor Fixo</option>
						</select>
					</div>
				</div>
				
				<div class="mb-4">
					<label for="voucher-descricao" class="block text-sm font-medium text-gray-700 mb-1">
						Descrição
					</label>
					<textarea
						id="voucher-descricao"
						bind:value={voucherEditando.descricao}
						rows="2"
						class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
						placeholder="Descrição do voucher"
					></textarea>
				</div>
				
				<div class="grid grid-cols-2 gap-4 mb-4">
					<div>
						<label for="voucher-quantidade" class="block text-sm font-medium text-gray-700 mb-1">
							Quantidade Total
						</label>
						<input
							id="voucher-quantidade"
							type="number"
							bind:value={voucherEditando.quantidade_total}
							min="1"
							class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
						/>
					</div>
					
					<div>
						<label for="voucher-valido-ate" class="block text-sm font-medium text-gray-700 mb-1">
							Válido até
						</label>
						<input
							id="voucher-valido-ate"
							type="date"
							bind:value={voucherEditando.valido_ate}
							class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
						/>
					</div>
				</div>
				
				<div class="flex gap-4 mb-4">
					<label class="flex items-center">
						<input
							type="checkbox"
							bind:checked={voucherEditando.ativo}
							class="mr-2"
						/>
						<span class="text-sm text-gray-700">Ativo</span>
					</label>
					
					<label class="flex items-center">
						<input
							type="checkbox"
							bind:checked={voucherEditando.publico}
							class="mr-2"
						/>
						<span class="text-sm text-gray-700">Público</span>
					</label>
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
					on:click={salvarVoucher}
					disabled={carregando || !voucherEditando.codigo}
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