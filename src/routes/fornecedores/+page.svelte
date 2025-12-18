<script lang="ts">
  /**
   * Página de Gestão de Fornecedores - Interface Principal
   * Lista e gerencia laboratórios/fornecedores com métricas
   */

  import { goto } from "$app/navigation";
  import { page } from "$app/stores";
  import type { PageData } from "./$types";

  // === Layout ===
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";

  // === UI ===
  import Button from "$lib/components/ui/Button.svelte";
  import Input from "$lib/components/ui/Input.svelte";
  import Select from "$lib/components/ui/Select.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import Table from "$lib/components/ui/Table.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

  // === Cards ===
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";

  // Filtros
  let busca = $page.url.searchParams.get("busca") || "";
  let regiao = $page.url.searchParams.get("regiao") || "";
  let status = $page.url.searchParams.get("status") || "ativo";
  let categoria = $page.url.searchParams.get("categoria") || "";

  import { createClient } from '@supabase/supabase-js';
  import { onMount } from 'svelte';
  
  // Estado local
  let isLoading = false;
  let showNewModal = false;
  let fornecedores: any[] = [];
  let estatisticas = {
    total_fornecedores: 0,
    fornecedores_ativos: 0,
    nota_media: 0,
    prazo_medio: 0,
  };

  // Carregar dados reais do banco
  onMount(async () => {
    try {
      isLoading = true;
      const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
      const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

      if (!supabaseUrl || !supabaseKey) {
        throw new Error('Missing Supabase environment variables');
      }

      const supabase = createClient(supabaseUrl, supabaseKey);
      
      // Buscar laboratórios usando a view pública
      const { data, error } = await supabase
        .from('vw_laboratorios_completo')
        .select('*');

      if (error) {
        console.error('Erro ao carregar laboratórios:', error);
      } else {
        fornecedores = (data || []).map((lab: any) => ({
          id: lab.id,
          nome: lab.nome_fantasia,
          codigo: lab.cnpj,
          regiao: 'N/A',
          categoria: lab.badge === 'QUALIFICADO' ? 'premium' : 'standard',
          status: lab.ativo ? 'ativo' : 'inativo',
          metricas: {
            prazo_medio: lab.lead_time || 0,
            preco_competitivo_pct: lab.score_preco || 0,
            total_decisoes: 0,
            prazo_cumprido_pct: lab.score_prazo || 0,
            qualidade_media: lab.score_qualidade || 0,
          },
        }));

        const ativos = fornecedores.filter(f => f.status === 'ativo');
        const scores = ativos.map(f => f.metricas.qualidade_media).filter(s => s > 0);
        const prazos = ativos.map(f => f.metricas.prazo_medio).filter(p => p > 0);
        
        estatisticas = {
          total_fornecedores: fornecedores.length,
          fornecedores_ativos: ativos.length,
          nota_media: scores.length > 0 ? scores.reduce((a, b) => a + b, 0) / scores.length : 0,
          prazo_medio: prazos.length > 0 ? prazos.reduce((a, b) => a + b, 0) / prazos.length : 0,
        };
      }
    } catch (error) {
      console.error('Erro ao carregar fornecedores:', error);
    } finally {
      isLoading = false;
    }
  });

  const regioes = [
    { codigo: "SP", nome: "São Paulo" },
    { codigo: "RJ", nome: "Rio de Janeiro" },
    { codigo: "MG", nome: "Minas Gerais" },
  ];

  // Formatadores
  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(value);
  };

  const formatPercentage = (value: number) => {
    return `${value.toFixed(1)}%`;
  };

  const formatRating = (value: number) => {
    return `${value.toFixed(1)}/5.0`;
  };

  // Opções para selects
  const statusOptions = [
    { value: "", label: "Todos os status" },
    { value: "ativo", label: "Ativo" },
    { value: "inativo", label: "Inativo" },
    { value: "suspenso", label: "Suspenso" },
  ];

  const categoriaOptions = [
    { value: "", label: "Todas as categorias" },
    { value: "premium", label: "Premium" },
    { value: "standard", label: "Standard" },
    { value: "economico", label: "Econômico" },
  ];

  $: regiaoOptions = [
    { value: "", label: "Todas as regiões" },
    ...(regioes || []).map((reg: any) => ({
      value: reg.codigo,
      label: reg.nome,
    })),
  ];

  // Headers da tabela
  const tableHeaders = [
    { key: "nome", label: "Laboratório" },
    { key: "regiao", label: "Região" },
    { key: "categoria", label: "Categoria" },
    { key: "nota_qualidade", label: "Qualidade", align: "center" as const },
    { key: "prazo_medio", label: "Prazo Médio", align: "center" as const },
    {
      key: "preco_competitivo",
      label: "Competitividade",
      align: "center" as const,
    },
    { key: "total_decisoes", label: "Decisões", align: "center" as const },
    { key: "status", label: "Status" },
    { key: "actions", label: "Ações", align: "center" as const },
  ];

  // Dados filtrados
  $: fornecedoresFiltrados = filtrarFornecedores(fornecedores || []);

  function filtrarFornecedores(fornecedores: any[]) {
    return fornecedores.filter((fornecedor) => {
      const matchBusca =
        !busca ||
        fornecedor.nome.toLowerCase().includes(busca.toLowerCase()) ||
        fornecedor.codigo?.toLowerCase().includes(busca.toLowerCase());

      const matchRegiao = !regiao || fornecedor.regiao === regiao;
      const matchStatus = !status || fornecedor.status === status;
      const matchCategoria = !categoria || fornecedor.categoria === categoria;

      return matchBusca && matchRegiao && matchStatus && matchCategoria;
    });
  }

  // Aplicar filtros
  function aplicarFiltros() {
    const params = new URLSearchParams();

    if (busca) params.set("busca", busca);
    if (regiao) params.set("regiao", regiao);
    if (status) params.set("status", status);
    if (categoria) params.set("categoria", categoria);

    goto(`/fornecedores?${params.toString()}`);
  }

  // Limpar filtros
  function limparFiltros() {
    busca = "";
    regiao = "";
    status = "";
    categoria = "";
    goto("/fornecedores");
  }

  // Funções de cor
  function getStatusColor(status: string) {
    switch (status) {
      case "ativo":
        return "success";
      case "inativo":
        return "neutral";
      case "suspenso":
        return "danger";
      default:
        return "neutral";
    }
  }

  function getCategoriaColor(categoria: string) {
    switch (categoria) {
      case "premium":
        return "gold";
      case "standard":
        return "blue";
      case "economico":
        return "green";
      default:
        return "neutral";
    }
  }

  function getQualidadeColor(nota: number) {
    if (nota >= 4.5) return "success";
    if (nota >= 3.5) return "warning";
    return "danger";
  }

  // Calcular nota de qualidade
  function calcularNotaQualidade(metricas: any) {
    if (!metricas) return 0;
    const cumprimentoPrazo = metricas.prazo_cumprido_pct || 0;
    const qualidadeProdutos = metricas.qualidade_media || 0;
    return ((cumprimentoPrazo * 0.6 + qualidadeProdutos * 20 * 0.4) / 100) * 5;
  }
</script>

<svelte:head>
  <title>Fornecedores - SIS Lens</title>
  <meta
    name="description"
    content="Gestão e acompanhamento de fornecedores/laboratórios"
  />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
      <!-- Hero Section -->
      <PageHero
        badge="🏢 Sistema de Fornecedores"
        title="Gestão de Fornecedores"
        subtitle="Gerencie laboratórios e acompanhe métricas de performance"
        alignment="center"
        maxWidth="lg"
      />

      <!-- Estatísticas -->
      {#if estatisticas}
        <section class="mt-8">
          <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
            <StatsCard
              title="Total Fornecedores"
              value={estatisticas.total_fornecedores}
              icon="🏢"
              color="blue"
            />

            <StatsCard
              title="Fornecedores Ativos"
              value={estatisticas.fornecedores_ativos}
              icon="✅"
              color="green"
            />

            <StatsCard
              title="Nota Média"
              value={formatRating(estatisticas.nota_media)}
              icon="⭐"
              color="orange"
            />

            <StatsCard
              title="Prazo Médio"
              value={`${estatisticas.prazo_medio} dias`}
              icon="⚡"
              color="gold"
            />
          </div>
        </section>
      {/if}

      <!-- Filtros -->
      <section class="mt-12">
        <div class="glass-panel rounded-xl p-6 shadow-xl">
          <SectionHeader title="Filtros de Busca" />

          <div class="space-y-6">
            <!-- Busca Principal -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
              <div class="lg:col-span-2">
                <Input
                  label="Buscar fornecedores"
                  placeholder="Nome do laboratório ou código..."
                  bind:value={busca}
                />
              </div>
              <div>
                <Button
                  variant="primary"
                  size="md"
                  fullWidth
                  on:click={aplicarFiltros}
                  disabled={isLoading}
                >
                  🔍 Filtrar
                </Button>
              </div>
            </div>

            <!-- Filtros Específicos -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <Select
                label="Região"
                bind:value={regiao}
                options={regiaoOptions}
              />

              <Select
                label="Status"
                bind:value={status}
                options={statusOptions}
              />

              <Select
                label="Categoria"
                bind:value={categoria}
                options={categoriaOptions}
              />

              <div class="flex items-end">
                <Button
                  variant="ghost"
                  size="md"
                  fullWidth
                  on:click={limparFiltros}
                >
                  🗑️ Limpar
                </Button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Tabela de Fornecedores -->
      <section class="mt-12">
        <div class="glass-panel rounded-xl p-6 shadow-xl">
          <SectionHeader
            title="Fornecedores Cadastrados"
            subtitle={fornecedoresFiltrados.length
              ? `${fornecedoresFiltrados.length} fornecedores encontrados`
              : ""}
          actionLabel="+ Novo Fornecedor"
          on:action={() => (showNewModal = true)}
        />

        {#if isLoading}
          <div class="flex justify-center py-12">
            <LoadingSpinner size="lg" />
          </div>
        {:else if fornecedoresFiltrados && fornecedoresFiltrados.length > 0}
          <Table headers={tableHeaders} rows={fornecedoresFiltrados} hoverable>
            <svelte:fragment slot="cell" let:row let:header>
              {#if header.key === "categoria"}
                <Badge variant={getCategoriaColor(row.categoria)} size="sm">
                  {row.categoria || "N/A"}
                </Badge>
              {:else if header.key === "nota_qualidade"}
                {@const nota = calcularNotaQualidade(row.metricas)}
                <div class="text-center">
                  <Badge variant={getQualidadeColor(nota)} size="sm">
                    {formatRating(nota)}
                  </Badge>
                </div>
              {:else if header.key === "prazo_medio"}
                <Badge variant="info" size="sm">
                  {row.metricas?.prazo_medio || 0} dias
                </Badge>
              {:else if header.key === "preco_competitivo"}
                <div class="text-center">
                  <span class="font-medium text-success">
                    {formatPercentage(row.metricas?.preco_competitivo_pct || 0)}
                  </span>
                </div>
              {:else if header.key === "total_decisoes"}
                <div class="text-center">
                  <span
                    class="font-medium text-neutral-900 dark:text-neutral-100"
                  >
                    {row.metricas?.total_decisoes || 0}
                  </span>
                </div>
              {:else if header.key === "status"}
                <Badge variant={getStatusColor(row.status)} size="sm">
                  {row.status}
                </Badge>
              {:else if header.key === "actions"}
                <div class="flex gap-2 justify-center">
                  <Button
                    variant="primary"
                    size="sm"
                    on:click={() => goto(`/fornecedores/${row.id}`)}
                  >
                    📄 Ver
                  </Button>
                  <Button
                    variant="secondary"
                    size="sm"
                    on:click={() => goto(`/fornecedores/${row.id}/editar`)}
                  >
                    ✏️ Editar
                  </Button>
                </div>
              {:else}
                {row[header.key] || "N/A"}
              {/if}
            </svelte:fragment>
          </Table>
        {:else}
          <EmptyState
            icon="🏢"
            title="Nenhum fornecedor encontrado"
            description="Não há fornecedores que correspondam aos filtros aplicados"
            actionLabel="Limpar Filtros"
            on:action={limparFiltros}
          />
        {/if}

        </div>
      </section>

      <!-- Ações Rápidas -->
      <section class="mt-12">
        <SectionHeader title="Ações Rápidas" />

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <ActionCard
            icon="➕"
            title="Novo Fornecedor"
            description="Cadastrar novo laboratório/fornecedor"
            actionLabel="Cadastrar"
            color="blue"
            on:click={() => (showNewModal = true)}
          />

          <ActionCard
            icon="📊"
            title="Relatórios"
            description="Ver relatórios de performance dos fornecedores"
            actionLabel="Ver Relatórios"
            color="green"
            on:click={() => goto("/analytics?tab=fornecedores")}
          />

          <ActionCard
            icon="⚙️"
            title="Configurações"
            description="Gerenciar configurações e critérios de avaliação"
            actionLabel="Configurar"
            color="orange"
            on:click={() => goto("/configuracoes/fornecedores")}
          />
        </div>
      </section>
    </Container>
  </main>

<!-- Modal Novo Fornecedor -->
{#if showNewModal}
  <div class="fixed inset-0 z-50 flex items-center justify-center">
    <!-- Backdrop -->
    <button
      type="button"
      class="absolute inset-0 bg-black/50"
      on:click={() => (showNewModal = false)}
      aria-label="Fechar modal"
    ></button>

    <!-- Modal -->
    <div
      class="relative bg-white dark:bg-neutral-800 rounded-xl max-w-md w-full mx-4 p-6"
    >
      <div class="text-center">
        <div
          class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-blue-100 dark:bg-blue-900/20 mb-4"
        >
          <svg
            class="h-6 w-6 text-blue-600 dark:text-blue-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 6v6m0 0v6m0-6h6m-6 0H6"
            />
          </svg>
        </div>

        <h3
          class="text-lg font-medium text-neutral-900 dark:text-neutral-100 mb-2"
        >
          Novo Fornecedor
        </h3>

        <p class="text-sm text-neutral-600 dark:text-neutral-400 mb-6">
          Para cadastrar um novo fornecedor, acesse a página de administração ou
          entre em contato com nosso suporte.
        </p>

        <div class="flex gap-3">
          <Button
            variant="secondary"
            size="md"
            fullWidth
            on:click={() => (showNewModal = false)}
          >
            Cancelar
          </Button>

          <Button
            variant="primary"
            size="md"
            fullWidth
            on:click={() => {
              showNewModal = false;
              goto("/contato");
            }}
          >
            Contato
          </Button>
        </div>
      </div>
    </div>
  </div>
{/if}
