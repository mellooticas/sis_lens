<!--
  🏠 Dashboard Principal - SIS Lens
  Visão geral completa do sistema decisor de lentes
-->
<script lang="ts">
  import { goto } from "$app/navigation";
  import { onMount } from "svelte";

  // Componentes padronizados
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

  // Hooks com dados reais
  import { useStatsCatalogo } from "$lib/hooks/useStatsCatalogo";
  import { useMarcas } from "$lib/hooks/useMarcas";
  import { useFornecedores } from "$lib/hooks/useFornecedores";
  
  // State dos hooks
  const { state: statsState } = useStatsCatalogo();
  const { state: marcasState } = useMarcas();
  const { state: fornecedoresState } = useFornecedores();

  // Dados reativos
  $: stats = $statsState.stats;
  $: marcas = $marcasState.marcas || [];
  $: fornecedores = $fornecedoresState.fornecedores || [];
  $: loading = $statsState.loading || $marcasState.loading || $fornecedoresState.loading;

  // Estado local
  let currentTime = new Date();

  // Atualizar relógio
  onMount(() => {
    const interval = setInterval(() => {
      currentTime = new Date();
    }, 1000);

    return () => clearInterval(interval);
  });

  // Funções utilitárias
  function formatNumber(value: number): string {
    if (!value) return "0";
    return value.toLocaleString("pt-BR");
  }
</script>

<svelte:head>
  <title>Dashboard - SIS Lens</title>
  <meta name="description" content="Dashboard principal do sistema decisor de lentes" />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
    <!-- Hero Section -->
    <PageHero
      badge="🏠 Dashboard"
      title="Sistema Decisor de Lentes"
      subtitle={`Última atualização: ${currentTime.toLocaleTimeString('pt-BR')}`}
      alignment="center"
      maxWidth="lg"
    />

    <!-- Estatísticas Principais -->
    {#if loading}
      <div class="flex justify-center py-12">
        <LoadingSpinner size="lg" />
      </div>
    {:else if stats}
      <section class="mt-8">
        <SectionHeader
          title="📊 Visão Geral do Catálogo"
          subtitle="Estatísticas atualizadas em tempo real"
        />

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mt-6">
          <StatsCard
            title="Total de Lentes"
            value={formatNumber(stats.total_lentes || 0)}
            icon="👓"
            color="blue"
          />

          <StatsCard
            title="Lentes Premium"
            value={formatNumber(stats.lentes_premium || 0)}
            icon="⭐"
            color="orange"
          />

          <StatsCard
            title="Lentes Genéricas"
            value={formatNumber(stats.lentes_genericas || 0)}
            icon="📦"
            color="green"
          />

          <StatsCard
            title="Marcas"
            value={formatNumber(stats.total_marcas || 0)}
            icon="🏷️"
            color="gold"
          />
        </div>
      </section>

      <!-- Marcas Disponíveis -->
      {#if marcas.length > 0}
        <section class="mt-12">
          <SectionHeader
            title="🏷️ Marcas Cadastradas"
            subtitle="Fabricantes de lentes no catálogo"
          />

          <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
            {#each marcas as marca}
              <ActionCard
                title={marca.nome}
                description={marca.is_premium ? 'Marca Premium' : 'Marca Standard'}
                actionLabel="Ver Produtos"
              />
            {/each}
          </div>
        </section>
      {/if}

      <!-- Fornecedores Ativos -->
      {#if fornecedores.length > 0}
        <section class="mt-12">
          <SectionHeader
            title="🏭 Fornecedores Cadastrados"
            subtitle="Distribuidores ativos no sistema"
          />

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-6">
            {#each fornecedores as fornecedor}
              <ActionCard
                title={fornecedor.nome}
                description={`${fornecedor.total_lentes || 0} lentes cadastradas`}
                actionLabel="Ver Catálogo"
              />
            {/each}
          </div>
        </section>
      {/if}
    {/if}

    <!-- Ações Rápidas -->
    <section class="mt-12">
      <SectionHeader
        title="⚡ Ações Rápidas"
        subtitle="Acesse rapidamente as funcionalidades principais"
      />

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
        <ActionCard
          title="Buscar Lentes"
          description="Pesquise no catálogo completo"
          icon="🔍"
          actionLabel="Ir para Busca"
        />

        <ActionCard
          title="Ver Catálogo"
          description="Grupos canônicos organizados"
          icon="📚"
          actionLabel="Ver Catálogo"
        />

        <ActionCard
          title="Comparar Fornecedores"
          description="Compare preços entre fornecedores"
          icon="⚖️"
          actionLabel="Comparar"
        />
      </div>
    </section>
  </Container>
</main>
