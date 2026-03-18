<script lang="ts">
  import Sidebar from "./Sidebar.svelte";
  import Header from "./Header.svelte";

  let sidebarCollapsed = false;

  function toggleSidebar() {
    sidebarCollapsed = !sidebarCollapsed;
  }
</script>

<div class="min-h-screen bg-background transition-colors duration-300">
  <Sidebar collapsed={sidebarCollapsed} />

  <div
    class="transition-all duration-300 flex flex-col min-h-screen"
    style="padding-left: {sidebarCollapsed ? '72px' : '16rem'}"
  >
    <Header on:menuClick={toggleSidebar} collapsed={sidebarCollapsed} />

    <main class="flex-1 p-4 md:p-8">
      <div class="mx-auto max-w-7xl">
        <slot />
      </div>
    </main>
  </div>
</div>
