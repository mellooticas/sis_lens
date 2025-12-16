<!-- 
	Página de Sistema de Vouchers
	Rota: /vouchers
	
	Gestão de vouchers, cupons, programa de pontuação e recompensas
-->
<script lang="ts">
	import type { PageData } from "./$types";

	export let data: PageData;

	import Container from "$lib/components/layout/Container.svelte";
	import PageHero from "$lib/components/layout/PageHero.svelte";
	import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
	import StatsCard from "$lib/components/cards/StatsCard.svelte";
	import Button from "$lib/components/ui/Button.svelte";
	import Input from "$lib/components/forms/Input.svelte";
	import Select from "$lib/components/forms/Select.svelte";
	import Badge from "$lib/components/ui/Badge.svelte";
	import EmptyState from "$lib/components/ui/EmptyState.svelte";

	// Filtros
	let statusLocal = data.filtros?.status || "ativo";
	let tipoLocal = data.filtros?.tipo || "todos";
	let buscaLocal = data.filtros?.busca || "";

	// Estado local
	let carregando = false;
	let modoEdicao = false;
	let voucherEditando: any = null;
	let mostrarGerador = false;

	// ... (keep existing functions: aplicarFiltros, limparFiltros, etc)
	function aplicarFiltros() {
		const params = new URLSearchParams();
		if (statusLocal) params.set("status", statusLocal);
		if (tipoLocal) params.set("tipo", tipoLocal);
		if (buscaLocal) params.set("busca", buscaLocal);
		window.location.href = `/vouchers?${params.toString()}`;
	}

	function limparFiltros() {
		statusLocal = "ativo";
		tipoLocal = "todos";
		buscaLocal = "";
		window.location.href = "/vouchers";
	}

	function formatarMoeda(valor: number) {
		return valor.toLocaleString("pt-BR", {
			style: "currency",
			currency: "BRL",
		});
	}

	function formatarData(data: string) {
		return new Date(data).toLocaleDateString("pt-BR");
	}

	function formatarDataHora(data: string) {
		return new Date(data).toLocaleString("pt-BR");
	}

	function novoVoucher() {
		voucherEditando = {
			codigo: "",
			tipo: "DESCONTO",
			valor: 0,
			tipo_valor: "PERCENTUAL",
			descricao: "",
			quantidade_total: 1,
			uso_maximo_cliente: 1,
			valido_ate: "",
			ativo: true,
			publico: false,
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
			console.log("Salvando voucher:", voucherEditando);
			await new Promise((resolve) => setTimeout(resolve, 1000));
			window.location.reload();
		} catch (error) {
			console.error("Erro ao salvar:", error);
		} finally {
			carregando = false;
		}
	}

	function gerarCodigo() {
		const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		let codigo = "";
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
			console.log("Alterando status:", voucher.id);
			await new Promise((resolve) => setTimeout(resolve, 500));
			window.location.reload();
		} catch (error) {
			console.error("Erro ao alterar status:", error);
		} finally {
			carregando = false;
		}
	}

	function copiarCodigo(codigo: string) {
		navigator.clipboard.writeText(codigo);
		// Suggestion: use toast here
	}
</script>

<svelte:head>
	<title>Sistema de Vouchers - SIS Lens</title>
</svelte:head>

<main>
	<Container maxWidth="xl" padding="md">
			<!-- Hero -->
			<div
				class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-8"
			>
				<PageHero
					badge="🎟️ Fidelidade"
					title="Sistema de Vouchers"
					subtitle="Gestão de cupons, descontos e programa de fidelidade"
				/>
				<div class="flex gap-2 mt-4 md:mt-0">
					<Button
						variant="ghost"
						size="md"
						on:click={() => (mostrarGerador = true)}
					>
						⚡ Gerador Rápido
					</Button>
					<Button variant="primary" size="md" on:click={novoVoucher}>
						🎟️ Novo Voucher
					</Button>
				</div>
			</div>

			<!-- Stats -->
			{#if data.estatisticas}
				<section class="mb-12">
					<div
						class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6"
					>
						<StatsCard
							title="Vouchers Ativos"
							value={data.estatisticas.vouchers_ativos?.toString() ||
								"0"}
							icon="🎟️"
							color="blue"
						/>
						<StatsCard
							title="Resgates no Mês"
							value={data.estatisticas.resgates_mes?.toString() ||
								"0"}
							icon="✅"
							color="green"
						/>
						<StatsCard
							title="Economia Gerada"
							value={formatarMoeda(
								data.estatisticas.economia_gerada || 0,
							)}
							icon="💰"
							color="orange"
						/>
						<StatsCard
							title="Participantes"
							value={data.estatisticas.usuarios_participantes?.toString() ||
								"0"}
							icon="👥"
							color="purple"
						/>
					</div>
				</section>
			{/if}

			<!-- Filters -->
			<section class="glass-panel p-6 rounded-xl shadow-lg mb-8">
				<SectionHeader
					title="🔍 Filtros de Busca"
					subtitle="Encontre vouchers rapidamente"
				/>
				<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
					<Input
						label="Buscar Voucher"
						placeholder="Código ou descrição"
						bind:value={buscaLocal}
						on:keydown={(e) =>
							e.key === "Enter" && aplicarFiltros()}
					/>
					<Select
						label="Tipo"
						bind:value={tipoLocal}
						options={[
							{ value: "todos", label: "Todos" },
							{ value: "DESCONTO", label: "Desconto" },
							{ value: "FRETE_GRATIS", label: "Frete Grátis" },
							{ value: "CREDITO", label: "Crédito" },
							{ value: "BRINDE", label: "Brinde" },
						]}
					/>
					<Select
						label="Status"
						bind:value={statusLocal}
						options={[
							{ value: "ativo", label: "Ativos" },
							{ value: "inativo", label: "Inativos" },
							{ value: "expirado", label: "Expirados" },
							{ value: "esgotado", label: "Esgotados" },
							{ value: "todos", label: "Todos" },
						]}
					/>
				</div>
				<div class="flex justify-end gap-3 mt-4">
					<Button variant="ghost" on:click={limparFiltros}
						>Limpar</Button
					>
					<Button variant="primary" on:click={aplicarFiltros}
						>Filtrar</Button
					>
				</div>
			</section>

			<!-- Vouchers Grid -->
			<section class="mb-12">
				{#if data.vouchers && data.vouchers.length > 0}
					<div
						class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
					>
						{#each data.vouchers as voucher}
							<div
								class="card overflow-hidden group hover:-translate-y-1 transition-transform duration-300"
							>
								<!-- Header -->
								<div
									class="p-4 bg-gradient-to-r from-brand-blue-500 to-brand-blue-700 text-white"
								>
									<div
										class="flex justify-between items-start"
									>
										<div>
											<h3 class="font-bold text-lg">
												{#if voucher.tipo === "DESCONTO"}
													🏷️ Desconto
												{:else if voucher.tipo === "FRETE_GRATIS"}
													🚚 Frete Grátis
												{:else if voucher.tipo === "CREDITO"}
													💰 Crédito
												{:else}
													🎁 Brinde
												{/if}
											</h3>
											<p
												class="text-white/80 text-sm mt-1"
											>
												{voucher.descricao ||
													"Sem descrição"}
											</p>
										</div>
										<div class="text-right">
											<span class="text-2xl font-bold">
												{#if voucher.tipo_valor === "PERCENTUAL"}
													{voucher.valor}%
												{:else}
													{formatarMoeda(
														voucher.valor,
													)}
												{/if}
											</span>
										</div>
									</div>
								</div>

								<!-- Body -->
								<div class="p-6 space-y-4">
									<!-- Code -->
									<div
										class="flex items-center justify-between bg-neutral-100 dark:bg-neutral-800 p-3 rounded-lg border border-dashed border-neutral-300 dark:border-neutral-600"
									>
										<code
											class="font-mono font-bold text-lg text-brand-blue-600 dark:text-brand-blue-400"
										>
											{voucher.codigo}
										</code>
										<button
											class="text-sm text-neutral-500 hover:text-brand-blue-500"
											on:click={() =>
												copiarCodigo(voucher.codigo)}
										>
											📋 Copiar
										</button>
									</div>

									<!-- Info -->
									<div class="grid grid-cols-2 text-sm gap-2">
										<div>
											<span
												class="block text-neutral-500 text-xs"
												>Usos</span
											>
											<span class="font-medium"
												>{voucher.quantidade_usada || 0}
												/ {voucher.quantidade_total ||
													"∞"}</span
											>
										</div>
										<div>
											<span
												class="block text-neutral-500 text-xs"
												>Validade</span
											>
											<span class="font-medium"
												>{voucher.valido_ate
													? formatarData(
															voucher.valido_ate,
														)
													: "Indeterminado"}</span
											>
										</div>
									</div>

									<!-- Status & Visibility -->
									<div class="flex gap-2 flex-wrap">
										{#if voucher.ativo && (!voucher.valido_ate || new Date(voucher.valido_ate) > new Date())}
											<Badge variant="success" size="sm"
												>Ativo</Badge
											>
										{:else if voucher.valido_ate && new Date(voucher.valido_ate) <= new Date()}
											<Badge variant="error" size="sm"
												>Expirado</Badge
											>
										{:else}
											<Badge variant="neutral" size="sm"
												>Inativo</Badge
											>
										{/if}

										{#if voucher.publico}
											<Badge variant="info" size="sm"
												>Público</Badge
											>
										{:else}
											<Badge variant="warning" size="sm"
												>Privado</Badge
											>
										{/if}
									</div>
								</div>

								<!-- Footer Actions -->
								<div
									class="p-4 border-t border-neutral-200 dark:border-neutral-700 bg-neutral-50 dark:bg-neutral-800/50 flex gap-2"
								>
									<Button
										variant="ghost"
										size="sm"
										fullWidth
										on:click={() => editarVoucher(voucher)}
									>
										✏️ Editar
									</Button>
									<Button
										variant="ghost"
										size="sm"
										fullWidth
										on:click={() => alternarStatus(voucher)}
									>
										{voucher.ativo ? "Desativar" : "Ativar"}
									</Button>
								</div>
							</div>
						{/each}
					</div>
				{:else}
					<EmptyState
						icon="🎟️"
						title="Nenhum voucher encontrado"
						description="Tente ajustar os filtros ou crie um novo voucher."
						actionLabel="Limpar Filtros"
						on:action={limparFiltros}
					/>
				{/if}
			</section>

			<!-- Recent Transactions -->
			{#if data.transacoes && data.transacoes.length > 0}
				<section class="glass-panel p-6 rounded-xl shadow-lg">
					<SectionHeader
						title="🔄 Transações Recentes"
						subtitle="Histórico de uso de vouchers"
					/>
					<div class="overflow-x-auto mt-6">
						<table class="w-full text-sm text-left">
							<thead
								class="bg-neutral-100 dark:bg-neutral-800 uppercase text-xs text-neutral-500"
							>
								<tr>
									<th class="px-4 py-3">Data</th>
									<th class="px-4 py-3">Voucher</th>
									<th class="px-4 py-3">Usuário</th>
									<th class="px-4 py-3">Economia</th>
									<th class="px-4 py-3">Status</th>
								</tr>
							</thead>
							<tbody
								class="divide-y divide-neutral-200 dark:divide-neutral-700"
							>
								{#each data.transacoes as transacao}
									<tr
										class="hover:bg-neutral-50 dark:hover:bg-neutral-800/50 transition-colors"
									>
										<td class="px-4 py-3"
											>{formatarDataHora(
												transacao.data_uso,
											)}</td
										>
										<td class="px-4 py-3">
											<div class="font-bold">
												{transacao.voucher_codigo}
											</div>
											<div
												class="text-xs text-neutral-500"
											>
												{transacao.voucher_descricao}
											</div>
										</td>
										<td class="px-4 py-3"
											>{transacao.usuario_nome ||
												transacao.usuario_email}</td
										>
										<td
											class="px-4 py-3 font-bold text-green-600"
											>{formatarMoeda(
												transacao.valor_economizado ||
													0,
											)}</td
										>
										<td class="px-4 py-3"
											><Badge variant="success" size="sm"
												>Usado</Badge
											></td
										>
									</tr>
								{/each}
							</tbody>
						</table>
					</div>
				</section>
			{/if}
		</Container>
	</main>

<!-- Modal de Edição (Legacy styled with Tailwind classes, can be modernized later or kept simple) -->
{#if modoEdicao && voucherEditando}
	<div
		class="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4"
	>
		<div
			class="bg-white dark:bg-neutral-900 rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto border border-neutral-200 dark:border-neutral-700"
		>
			<div
				class="px-6 py-4 border-b border-neutral-200 dark:border-neutral-700"
			>
				<h3 class="text-xl font-bold text-neutral-900 dark:text-white">
					{voucherEditando.id ? "Editar" : "Novo"} Voucher
				</h3>
			</div>

			<div class="p-6 space-y-6">
				<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
					<div class="space-y-1">
						<label
							class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
							>Código *</label
						>
						<div class="flex gap-2">
							<input
								type="text"
								bind:value={voucherEditando.codigo}
								placeholder="Ex: PROMO10"
								class="flex-1 input"
							/>
							<Button
								variant="secondary"
								size="md"
								on:click={gerarCodigo}>🎲</Button
							>
						</div>
					</div>

					<div class="space-y-1">
						<label
							class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
							>Tipo *</label
						>
						<select
							bind:value={voucherEditando.tipo}
							class="input w-full"
						>
							<option value="DESCONTO">🏷️ Desconto</option>
							<option value="FRETE_GRATIS">🚚 Frete Grátis</option
							>
							<option value="CREDITO">💰 Crédito</option>
							<option value="BRINDE">🎁 Brinde</option>
						</select>
					</div>
				</div>

				<!-- More fields... simplified for brevity layout but kept functional logic -->
				<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
					<div class="space-y-1">
						<label
							class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
							>Valor *</label
						>
						<input
							type="number"
							bind:value={voucherEditando.valor}
							min="0"
							step="0.01"
							class="input"
						/>
					</div>
					<div class="space-y-1">
						<label
							class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
							>Tipo Valor</label
						>
						<select
							bind:value={voucherEditando.tipo_valor}
							class="input w-full"
						>
							<option value="PERCENTUAL">📊 Percentual</option>
							<option value="FIXO">💰 Valor Fixo</option>
						</select>
					</div>
				</div>

				<div class="space-y-1">
					<label
						class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
						>Descrição</label
					>
					<textarea
						bind:value={voucherEditando.descricao}
						rows="2"
						class="input w-full"
						placeholder="Descrição"
					></textarea>
				</div>

				<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
					<div class="space-y-1">
						<label
							class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
							>Qtd Total</label
						>
						<input
							type="number"
							bind:value={voucherEditando.quantidade_total}
							min="1"
							class="input"
						/>
					</div>
					<div class="space-y-1">
						<label
							class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
							>Validade</label
						>
						<input
							type="date"
							bind:value={voucherEditando.valido_ate}
							class="input"
						/>
					</div>
				</div>

				<div class="flex gap-6">
					<label class="flex items-center gap-2 cursor-pointer">
						<input
							type="checkbox"
							bind:checked={voucherEditando.ativo}
							class="w-4 h-4 rounded text-brand-blue-600 focus:ring-brand-blue-500"
						/>
						<span
							class="text-sm text-neutral-700 dark:text-neutral-300"
							>Ativo</span
						>
					</label>
					<label class="flex items-center gap-2 cursor-pointer">
						<input
							type="checkbox"
							bind:checked={voucherEditando.publico}
							class="w-4 h-4 rounded text-brand-blue-600 focus:ring-brand-blue-500"
						/>
						<span
							class="text-sm text-neutral-700 dark:text-neutral-300"
							>Público</span
						>
					</label>
				</div>
			</div>

			<div
				class="px-6 py-4 border-t border-neutral-200 dark:border-neutral-700 flex justify-end gap-3 bg-neutral-50 dark:bg-neutral-800/50 rounded-b-2xl"
			>
				<Button variant="ghost" on:click={cancelarEdicao}
					>Cancelar</Button
				>
				<Button
					variant="primary"
					on:click={salvarVoucher}
					disabled={carregando || !voucherEditando.codigo}
				>
					{carregando ? "Salvando..." : "Salvar Voucher"}
				</Button>
			</div>
		</div>
	</div>
{/if}
