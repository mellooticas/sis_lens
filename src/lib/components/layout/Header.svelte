<!--
  SIS Lens — Header Dinâmico
  Padrão do Ecossistema SIS_DIGIAI (seção 3.2)
  Avatar com iniciais | firstName | roleLabel | Logout
-->
<script lang="ts">
  import { createEventDispatcher } from "svelte";
  import { fade } from "svelte/transition";
  import { onMount } from "svelte";
  import { currentUser, logout } from "$lib/stores/auth";

  export let collapsed = false;

  const dispatch = createEventDispatcher();

  // Relógio
  let currentTime = new Date();
  onMount(() => {
    const interval = setInterval(() => {
      currentTime = new Date();
    }, 1000);
    return () => clearInterval(interval);
  });

  $: hour = currentTime.getHours();
  $: greeting =
    hour < 12 ? "🌅 Bom dia" : hour < 18 ? "☀️ Boa tarde" : "🌙 Boa noite";

  // Menu do avatar
  let showUserMenu = false;
  function toggleUserMenu() {
    showUserMenu = !showUserMenu;
  }
  function closeMenu() {
    showUserMenu = false;
  }

  // Fechar menu ao clicar fora
  function handleOutsideClick(e: MouseEvent) {
    const target = e.target as HTMLElement;
    if (!target.closest("#user-menu-container")) {
      showUserMenu = false;
    }
  }
</script>

<svelte:window on:click={handleOutsideClick} />

<header
  class="
  sticky top-0 h-16 z-30
  bg-background border-b border-border
  transition-all duration-300
  flex items-center justify-between px-6
"
>
  <!-- Esquerda: Menu Toggle + Saudação -->
  <div class="flex items-center gap-4">
    <button
      class="p-2.5 rounded-xl text-muted-foreground hover:text-primary-600 dark:hover:text-primary-400
             hover:bg-primary-50 dark:hover:bg-primary-900/30 transition-all duration-200"
      on:click={() => dispatch("menuClick")}
      title={collapsed ? "Expandir menu" : "Recolher menu"}
      aria-label="Toggle sidebar"
    >
      <svg
        class="w-6 h-6"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        {#if collapsed}
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M13 5l7 7-7 7M5 5l7 7-7 7"
          />
        {:else}
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M4 6h16M4 12h16M4 18h7"
          />
        {/if}
      </svg>
    </button>

    <div class="hidden sm:flex flex-col" in:fade>
      <div class="flex items-baseline gap-2">
        <span
          class="text-2xl font-bold font-mono text-primary-600 dark:text-primary-400"
        >
          {currentTime.toLocaleTimeString("pt-BR", {
            hour: "2-digit",
            minute: "2-digit",
          })}
        </span>
        <h1
          class="text-lg font-bold text-foreground leading-tight"
        >
          {greeting}{#if $currentUser}, {$currentUser.firstName}{/if} 👋
        </h1>
      </div>
      <span class="text-xs font-medium text-muted-foreground">
        Ecossistema SIS_DIGIAI
      </span>
    </div>
  </div>

  <!-- Direita: Avatar do Usuário -->
  <div class="flex items-center gap-3">
    <!-- Avatar / User Menu -->
    {#if $currentUser}
      <div id="user-menu-container" class="relative">
        <button
          class="flex items-center gap-2.5 p-1.5 pr-3 rounded-xl
                 hover:bg-accent
                 transition-colors duration-200 group"
          on:click={toggleUserMenu}
          aria-label="Menu do usuário"
          aria-expanded={showUserMenu}
        >
          <!-- Avatar com iniciais -->
          <div
            class="w-8 h-8 rounded-full bg-gradient-to-br from-primary-500 to-primary-700
                      flex items-center justify-center text-white font-bold text-sm
                      ring-2 ring-primary-200 dark:ring-primary-800 group-hover:ring-primary-400
                      transition-all duration-200 shrink-0"
          >
            {$currentUser.initials}
          </div>
          <!-- Nome + Role -->
          <div class="hidden md:flex flex-col items-start">
            <span
              class="text-sm font-semibold text-foreground leading-none"
            >
              {$currentUser.firstName}
            </span>
            <span
              class="text-xs text-muted-foreground leading-none mt-0.5"
            >
              {$currentUser.roleLabel}
            </span>
          </div>
          <!-- Chevron -->
          <svg
            class="w-4 h-4 text-muted-foreground transition-transform duration-200 {showUserMenu
              ? 'rotate-180'
              : ''}"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M19 9l-7 7-7-7"
            />
          </svg>
        </button>

        <!-- Dropdown Menu -->
        {#if showUserMenu}
          <div
            class="absolute right-0 top-full mt-2 w-56 bg-card
                   border border-border
                   rounded-xl shadow-xl overflow-hidden z-50"
            in:fade={{ duration: 150 }}
          >
            <!-- Info do usuário -->
            <div
              class="px-4 py-3 border-b border-border"
            >
              <p
                class="text-sm font-semibold text-foreground truncate"
              >
                {$currentUser.name || $currentUser.email}
              </p>
              <p
                class="text-xs text-muted-foreground truncate"
              >
                {$currentUser.email}
              </p>
              <span
                class="inline-flex mt-1.5 items-center px-2 py-0.5 rounded-full text-xs font-medium
                           bg-primary-100 text-primary-700 dark:bg-primary-900/40 dark:text-primary-300"
              >
                {$currentUser.roleLabel}
              </span>
            </div>

            <!-- Tenant -->
            {#if $currentUser.tenantName}
              <div
                class="px-4 py-2 border-b border-border"
              >
                <p class="text-xs text-muted-foreground">
                  Óptica
                </p>
                <p
                  class="text-sm font-medium text-foreground truncate"
                >
                  {$currentUser.tenantName}
                </p>
              </div>
            {/if}

            <!-- Ações -->
            <div class="p-1">
              <button
                class="w-full flex items-center gap-2 px-3 py-2 text-sm text-red-600 dark:text-red-400
                       hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors duration-150"
                on:click={() => {
                  closeMenu();
                  logout();
                }}
              >
                <svg
                  class="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
                  />
                </svg>
                Sair do Sistema
              </button>
            </div>
          </div>
        {/if}
      </div>
    {:else}
      <!-- Fallback: usuário não carregado ainda -->
      <div
        class="w-8 h-8 rounded-full bg-border animate-pulse"
      ></div>
    {/if}
  </div>
</header>
