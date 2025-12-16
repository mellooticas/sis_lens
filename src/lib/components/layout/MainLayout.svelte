<script lang="ts">
  /**
   * Main Layout
   * Estrutura principal: Sidebar + Header + Content
   */
  import Sidebar from "./Sidebar.svelte";
  import Header from "./Header.svelte";

  export let currentPage = "";

  let sidebarCollapsed = false;

  function toggleSidebar() {
    sidebarCollapsed = !sidebarCollapsed;
  }
</script>

<div
  class="min-h-screen bg-neutral-50 dark:bg-neutral-950 text-neutral-900 dark:text-neutral-100 transition-colors"
>
  <!-- Sidebar (Left) -->
  <Sidebar collapsed={sidebarCollapsed} />

  <!-- Main Content (Right) -->
  <div
    class="transition-all duration-500 ease-out flex flex-col min-h-screen"
    style="padding-left: {sidebarCollapsed ? '7.25rem' : '18rem'}"
  >
    <!-- Header (Top) -->
    <Header on:menuClick={toggleSidebar} collapsed={sidebarCollapsed} />

    <!-- Page Content -->
    <main class="flex-1 p-6">
      <div class="container mx-auto max-w-7xl animate-fade-in">
        <slot />
      </div>
    </main>
  </div>
</div>
