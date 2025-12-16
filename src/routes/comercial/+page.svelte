<!-- 
	Página de Gestão Comercial
	Rota: /comercial
	
	Gestão de preços, descontos, margens e políticas comerciais
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

	// Filtros
	let laboratorioLocal = data.filtros?.laboratorio || "";
	let marcaLocal = data.filtros?.marca || "";
	let statusLocal = data.filtros?.status || "ativo";
	let tipoLocal = data.filtros?.tipo || "todos";

	// Estado local
	let carregando = false;
	let modoEdicao = false;
	let itemEditando: any = null;

	function aplicarFiltros() {
		const params = new URLSearchParams();
		if (laboratorioLocal) params.set("laboratorio", laboratorioLocal);
		if (marcaLocal) params.set("marca", marcaLocal);
		if (statusLocal) params.set("status", statusLocal);
		if (tipoLocal) params.set("tipo", tipoLocal);
		window.location.href = `/comercial?${params.toString()}`;
	}

	function limparFiltros() {
		laboratorioLocal = "";
		marcaLocal = "";
		statusLocal = "ativo";
		tipoLocal = "todos";
		window.location.href = "/comercial";
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

	function editarItem(item: any, tipo: "preco" | "desconto") {
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
			console.log("Salvando item:", itemEditando);
			await new Promise((resolve) => setTimeout(resolve, 1000));
			window.location.reload();
		} catch (error) {
			console.error("Erro ao salvar:", error);
		} finally {
			carregando = false;
		}
	}

	function novoPreco() {
		itemEditando = {
			tipo: "preco",
			laboratorio_id: "",
			produto_id: "",
			preco_base: 0,
			margem_pct: 0,
			vigencia_inicio: new Date().toISOString().split("T")[0],
			vigencia_fim: "",
			ativo: true,
		};
		modoEdicao = true;
	}

	function novoDesconto() {
		itemEditando = {
			tipo: "desconto",
			nome: "",
			tipo_desconto: "PERCENTUAL",
			valor: 0,
			escopo: "PRODUTO",
			laboratorio_id: "",
			marca_id: "",
			produto_id: "",
			vigencia_inicio: new Date().toISOString().split("T")[0],
			vigencia_fim: "",
			ativo: true,
		};
		modoEdicao = true;
	}
</script>

<svelte:head>
	<title>Gestão Comercial - SIS Lens</title>
</svelte:head>

<main>
	<Container maxWidth="xl" padding="md">
			<!-- Hero -->
			<div
				class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-8"
			>
				<PageHero
					badge="💰 Negócio"
					title="Gestão Comercial"
					subtitle="Preços, descontos, margens e políticas"
				/>
				<div class="flex gap-2 mt-4 md:mt-0">
					<Button variant="primary" on:click={novoPreco}
						>💲 Novo Preço</Button
					>
					<Button variant="success" on:click={novoDesconto}
						>🏷️ Novo Desconto</Button
					>
				</div>
			</div>

			<!-- Stats -->
			{#if data.estatisticas}
				<section class="mb-12">
					<div
						class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6"
					>
						<StatsCard
							title="Preços Ativos"
							value={data.estatisticas.total_precos_ativos?.toString() ||
								"0"}
							icon="💲"
							color="blue"
						/>
						<StatsCard
							title="Descontos Ativos"
							value={data.estatisticas.total_descontos_ativos?.toString() ||
								"0"}
							icon="🏷️"
							color="green"
						/>
						<StatsCard
							title="Margem Média"
							value={`${data.estatisticas.margem_media_pct?.toFixed(1) || "0.0"}%`}
							icon="📊"
							color="orange"
						/>
						<StatsCard
							title="Economia Mensal"
							value={formatarMoeda(
								data.estatisticas.economia_desconto_mes || 0,
							)}
							icon="💰"
							color="purple"
						/>
					</div>
				</section>
			{/if}

			<!-- Filters -->
			<section class="glass-panel p-6 rounded-xl shadow-lg mb-8">
				<SectionHeader
					title="🔍 Filtros de Busca"
					subtitle="Refine sua visualização"
				/>
				<div class="grid grid-cols-1 md:grid-cols-4 gap-6 mt-6">
					<Select
						label="Tipo"
						bind:value={tipoLocal}
						options={[
							{ value: "todos", label: "Todos" },
							{ value: "precos", label: "Preços" },
							{ value: "descontos", label: "Descontos" },
						]}
					/>
					<Select
						label="Laboratório"
						bind:value={laboratorioLocal}
						options={[
							{ value: "", label: "Todos" },
							...(data.laboratorios || []).map((l) => ({
								value: l.id,
								label: l.nome,
							})),
						]}
					/>
					<Select
						label="Marca"
						bind:value={marcaLocal}
						options={[
							{ value: "", label: "Todas" },
							...(data.marcas || []).map((m) => ({
								value: m.id,
								label: m.nome,
							})),
						]}
					/>
					<Select
						label="Status"
						bind:value={statusLocal}
						options={[
							{ value: "ativo", label: "Ativos" },
							{ value: "inativo", label: "Inativos" },
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

			<!-- Content Tabs -->
			<div class="space-y-8">
				<!-- Preços -->
				{#if tipoLocal === "todos" || tipoLocal === "precos"}
					<section class="glass-panel p-6 rounded-xl shadow-lg">
						<SectionHeader
							title="💲 Tabela de Preços"
							subtitle="Preços base cadastrados"
						/>
						<div class="overflow-x-auto mt-6">
							<table class="w-full text-sm text-left">
								<thead
									class="bg-neutral-100 dark:bg-neutral-800 uppercase text-xs text-neutral-500"
								>
									<tr>
										<th class="px-4 py-3">Produto</th>
										<th class="px-4 py-3">Laboratório</th>
										<th class="px-4 py-3">Preço Base</th>
										<th class="px-4 py-3">Margem</th>
										<th class="px-4 py-3">Vigência</th>
										<th class="px-4 py-3">Status</th>
										<th class="px-4 py-3 text-right"
											>Ações</th
										>
									</tr>
								</thead>
								<tbody
									class="divide-y divide-neutral-200 dark:divide-neutral-700"
								>
									{#each data.precos || [] as preco}
										<tr
											class="hover:bg-neutral-50 dark:hover:bg-neutral-800/50 transition-colors"
										>
											<td class="px-4 py-3">
												<div class="font-bold">
													{preco.produto_nome}
												</div>
												<div
													class="text-xs text-neutral-500"
												>
													{preco.sku_fantasia}
												</div>
											</td>
											<td class="px-4 py-3"
												>{preco.laboratorio_nome}</td
											>
											<td class="px-4 py-3 font-medium"
												>{formatarMoeda(
													preco.preco_base || 0,
												)}</td
											>
											<td class="px-4 py-3"
												>{preco.margem_pct || 0}%</td
											>
											<td class="px-4 py-3">
												{formatarData(
													preco.vigencia_inicio,
												)}
												{#if preco.vigencia_fim}
													<span
														class="text-xs text-neutral-400"
														>até {formatarData(
															preco.vigencia_fim,
														)}</span
													>{/if}
											</td>
											<td class="px-4 py-3">
												{#if preco.ativo}
													<Badge
														variant="success"
														size="sm">Ativo</Badge
													>
												{:else}
													<Badge
														variant="neutral"
														size="sm">Inativo</Badge
													>
												{/if}
											</td>
											<td class="px-4 py-3 text-right">
												<Button
													variant="ghost"
													size="sm"
													on:click={() =>
														editarItem(
															preco,
															"preco",
														)}>✏️</Button
												>
											</td>
										</tr>
									{/each}
								</tbody>
							</table>
						</div>
					</section>
				{/if}

				<!-- Descontos -->
				{#if tipoLocal === "todos" || tipoLocal === "descontos"}
					<section class="glass-panel p-6 rounded-xl shadow-lg">
						<SectionHeader
							title="🏷️ Descontos Ativos"
							subtitle="Políticas de desconto vigentes"
						/>
						<div class="overflow-x-auto mt-6">
							<table class="w-full text-sm text-left">
								<thead
									class="bg-neutral-100 dark:bg-neutral-800 uppercase text-xs text-neutral-500"
								>
									<tr>
										<th class="px-4 py-3">Nome</th>
										<th class="px-4 py-3">Tipo</th>
										<th class="px-4 py-3">Valor</th>
										<th class="px-4 py-3">Escopo</th>
										<th class="px-4 py-3">Vigência</th>
										<th class="px-4 py-3">Status</th>
										<th class="px-4 py-3 text-right"
											>Ações</th
										>
									</tr>
								</thead>
								<tbody
									class="divide-y divide-neutral-200 dark:divide-neutral-700"
								>
									{#each data.descontos || [] as desconto}
										<tr
											class="hover:bg-neutral-50 dark:hover:bg-neutral-800/50 transition-colors"
										>
											<td class="px-4 py-3 font-medium"
												>{desconto.nome}</td
											>
											<td class="px-4 py-3">
												{#if desconto.tipo_desconto === "PERCENTUAL"}
													📊 Percentual
												{:else}
													💰 Fixo
												{/if}
											</td>
											<td
												class="px-4 py-3 font-bold text-green-600"
											>
												{#if desconto.tipo_desconto === "PERCENTUAL"}
													{desconto.valor}%
												{:else}
													{formatarMoeda(
														desconto.valor,
													)}
												{/if}
											</td>
											<td class="px-4 py-3">
												{#if desconto.escopo === "LABORATORIO"}
													🏢 Laboratório
												{:else if desconto.escopo === "MARCA"}
													🏷️ Marca
												{:else}
													📦 Produto
												{/if}
											</td>
											<td class="px-4 py-3">
												{formatarData(
													desconto.vigencia_inicio,
												)}
												{#if desconto.vigencia_fim}
													<span
														class="text-xs text-neutral-400"
														>até {formatarData(
															desconto.vigencia_fim,
														)}</span
													>{/if}
											</td>
											<td class="px-4 py-3">
												{#if desconto.ativo}
													<Badge
														variant="success"
														size="sm">Ativo</Badge
													>
												{:else}
													<Badge
														variant="neutral"
														size="sm">Inativo</Badge
													>
												{/if}
											</td>
											<td class="px-4 py-3 text-right">
												<Button
													variant="ghost"
													size="sm"
													on:click={() =>
														editarItem(
															desconto,
															"desconto",
														)}>✏️</Button
												>
											</td>
										</tr>
									{/each}
								</tbody>
							</table>
						</div>
					</section>
				{/if}
			</div>
		</Container>
	</main>

<!-- Modal de Edição (Legacy styled with Tailwind classes) -->
{#if modoEdicao && itemEditando}
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
					{#if itemEditando.tipo === "preco"}
						💲 Editar Preço
					{:else}
						🏷️ Editar Desconto
					{/if}
				</h3>
			</div>

			<div class="p-6 space-y-6">
				<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
					<div class="space-y-1">
						<label
							class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
							>Nome/Produto</label
						>
						<input
							type="text"
							bind:value={itemEditando.nome}
							class="input w-full"
							placeholder="Nome"
						/>
					</div>

					<div class="space-y-1">
						<label
							class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
						>
							{itemEditando.tipo === "preco"
								? "Preço Base"
								: "Valor Desconto"}
						</label>
						<input
							type="number"
							bind:value={itemEditando.valor}
							step="0.01"
							class="input w-full"
						/>
					</div>
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
					on:click={salvarItem}
					disabled={carregando}
				>
					{carregando ? "Salvando..." : "Salvar"}
				</Button>
			</div>
		</div>
	</div>
{/if}
