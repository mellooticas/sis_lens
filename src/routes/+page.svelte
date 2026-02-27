<!--
  SIS Lens — Dashboard Principal
  KPIs reais de v_catalog_lenses + v_catalog_lens_groups
  Design System SIS_DIGIAI: Base Neutra + Sotaque Violet
  SEM glassmorphism · SEM gradientes · SEM scale effects
-->
<script lang="ts">
  import type { PageData } from './$types';

  export let data: PageData;

  const { stats } = data;

  // Distribuição por tipo: ordena por contagem desc
  const tiposOrdenados = Object.entries(stats.por_tipo)
    .sort(([, a], [, b]) => b - a);

  // Percentual de lentes ativas
  const pctAtivas = stats.total_lentes > 0
    ? Math.round((stats.lentes_ativas / stats.total_lentes) * 100)
    : 0;

  // Percentual premium
  const pctPremium = stats.total_lentes > 0
    ? Math.round((stats.lentes_premium / stats.total_lentes) * 100)
    : 0;

  type QuickLink = { label: string; desc: string; href: string; icon: string };

  const quickLinks: QuickLink[] = [
    {
      label: 'Simulador de Receita',
      desc: 'Encontre a lente ideal por prescrição',
      href: '/simulador/receita',
      icon: 'zap',
    },
    {
      label: 'Catálogo Completo',
      desc: 'Browse todas as lentes disponíveis',
      href: '/lentes',
      icon: 'search',
    },
    {
      label: 'Ranking de Lentes',
      desc: 'Melhores lentes por critério',
      href: '/ranking',
      icon: 'trophy',
    },
    {
      label: 'Comparar Labs',
      desc: 'Compare fornecedores lado a lado',
      href: '/comparar',
      icon: 'scale',
    },
    {
      label: 'Tabela de Preços',
      desc: 'Preços e tratamentos por fornecedor',
      href: '/tabela-precos',
      icon: 'price-table',
    },
  ];
</script>

<svelte:head>
  <title>Dashboard — SIS Lens</title>
  <meta name="description" content="Visão geral do catálogo de lentes oftálmicas" />
</svelte:head>

<div class="p-6 space-y-8 max-w-7xl mx-auto">

  <!-- Header da página -->
  <div>
    <h1 class="text-2xl font-semibold text-neutral-900 dark:text-neutral-100">
      Dashboard
    </h1>
    <p class="mt-1 text-sm text-neutral-500 dark:text-neutral-400">
      Visão geral do catálogo de lentes
    </p>
  </div>

  <!-- KPIs principais -->
  <section aria-label="KPIs principais">
    <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">

      <!-- Total de Lentes -->
      <div class="col-span-2 sm:col-span-1 bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl p-4 space-y-1">
        <p class="text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wide">Total de Lentes</p>
        <p class="text-3xl font-bold text-neutral-900 dark:text-neutral-100">{stats.total_lentes}</p>
      </div>

      <!-- Lentes Ativas -->
      <div class="bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl p-4 space-y-1">
        <p class="text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wide">Ativas</p>
        <p class="text-3xl font-bold text-primary-600 dark:text-primary-400">{stats.lentes_ativas}</p>
        <p class="text-xs text-neutral-400 dark:text-neutral-500">{pctAtivas}% do total</p>
      </div>

      <!-- Premium -->
      <div class="bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl p-4 space-y-1">
        <p class="text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wide">Premium</p>
        <p class="text-3xl font-bold text-neutral-900 dark:text-neutral-100">{stats.lentes_premium}</p>
        <p class="text-xs text-neutral-400 dark:text-neutral-500">{pctPremium}% do total</p>
      </div>

      <!-- Standard -->
      <div class="bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl p-4 space-y-1">
        <p class="text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wide">Standard</p>
        <p class="text-3xl font-bold text-neutral-900 dark:text-neutral-100">{stats.total_standard}</p>
      </div>

      <!-- Com Antirreflexo -->
      <div class="bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl p-4 space-y-1">
        <p class="text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wide">Com AR</p>
        <p class="text-3xl font-bold text-neutral-900 dark:text-neutral-100">{stats.com_ar}</p>
        <p class="text-xs text-neutral-400 dark:text-neutral-500">antirreflexo</p>
      </div>

      <!-- Grupos Ativos -->
      <div class="bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl p-4 space-y-1">
        <p class="text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wide">Grupos Ativos</p>
        <p class="text-3xl font-bold text-neutral-900 dark:text-neutral-100">{stats.grupos_ativos}</p>
      </div>

    </div>
  </section>

  <!-- Linha secundária: distribuição por tipo + acesso rápido -->
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    <!-- Distribuição por Tipo -->
    <section
      aria-label="Distribuição por tipo de lente"
      class="lg:col-span-1 bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl p-5"
    >
      <h2 class="text-sm font-semibold text-neutral-700 dark:text-neutral-300 mb-4">
        Por tipo de lente
      </h2>

      {#if tiposOrdenados.length === 0}
        <p class="text-sm text-neutral-400 dark:text-neutral-500">Sem dados.</p>
      {:else}
        <ul class="space-y-3">
          {#each tiposOrdenados as [tipo, qtd]}
            {@const pct = stats.total_lentes > 0 ? Math.round((qtd / stats.total_lentes) * 100) : 0}
            <li>
              <div class="flex items-center justify-between mb-1">
                <span class="text-xs font-medium text-neutral-600 dark:text-neutral-400 capitalize truncate max-w-[70%]">{tipo}</span>
                <span class="text-xs font-semibold text-neutral-700 dark:text-neutral-300">{qtd}</span>
              </div>
              <div class="h-1.5 w-full bg-neutral-100 dark:bg-neutral-700 rounded-full overflow-hidden">
                <div
                  class="h-full bg-primary-500 dark:bg-primary-400 rounded-full transition-all duration-500"
                  style="width: {pct}%"
                  role="progressbar"
                  aria-valuenow={pct}
                  aria-valuemin={0}
                  aria-valuemax={100}
                ></div>
              </div>
            </li>
          {/each}
        </ul>
      {/if}
    </section>

    <!-- Acesso Rápido -->
    <section
      aria-label="Acesso rápido às ferramentas"
      class="lg:col-span-2 bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl p-5"
    >
      <h2 class="text-sm font-semibold text-neutral-700 dark:text-neutral-300 mb-4">
        Acesso rápido
      </h2>

      <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {#each quickLinks as link}
          <a
            href={link.href}
            class="flex items-start gap-3 p-3 rounded-lg border border-neutral-200 dark:border-neutral-700 hover:border-primary-300 dark:hover:border-primary-700 hover:bg-primary-50 dark:hover:bg-primary-900/20 transition-colors duration-150 group"
          >
            <!-- Ícone -->
            <span class="mt-0.5 shrink-0 w-8 h-8 flex items-center justify-center rounded-lg bg-neutral-100 dark:bg-neutral-700 group-hover:bg-primary-100 dark:group-hover:bg-primary-900/40 transition-colors duration-150">
              {#if link.icon === 'zap'}
                <svg class="w-4 h-4 text-neutral-500 dark:text-neutral-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                </svg>
              {:else if link.icon === 'search'}
                <svg class="w-4 h-4 text-neutral-500 dark:text-neutral-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
              {:else if link.icon === 'trophy'}
                <svg class="w-4 h-4 text-neutral-500 dark:text-neutral-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"/>
                </svg>
              {:else if link.icon === 'scale'}
                <svg class="w-4 h-4 text-neutral-500 dark:text-neutral-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3"/>
                </svg>
              {:else if link.icon === 'price-table'}
                <svg class="w-4 h-4 text-neutral-500 dark:text-neutral-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                </svg>
              {/if}
            </span>

            <!-- Texto -->
            <div class="min-w-0">
              <p class="text-sm font-medium text-neutral-800 dark:text-neutral-200 group-hover:text-primary-700 dark:group-hover:text-primary-300 transition-colors leading-none mb-1">
                {link.label}
              </p>
              <p class="text-xs text-neutral-500 dark:text-neutral-400 leading-snug">
                {link.desc}
              </p>
            </div>
          </a>
        {/each}
      </div>
    </section>

  </div>

</div>
