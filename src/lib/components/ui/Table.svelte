<script lang="ts">
  /**
   * Table Component
   * Tabela de dados responsiva
   */

  export let headers: Array<{
    key: string;
    label: string;
    sortable?: boolean;
  }> = [];
  export let data: Array<Record<string, any>> = [];
  export let hoverable = true;
  export let striped = false;
  export let compact = false;

  let sortKey = "";
  let sortDirection: "asc" | "desc" = "asc";

  function handleSort(key: string) {
    if (sortKey === key) {
      sortDirection = sortDirection === "asc" ? "desc" : "asc";
    } else {
      sortKey = key;
      sortDirection = "asc";
    }
  }

  $: sortedData = sortKey
    ? [...data].sort((a, b) => {
        const aVal = a[sortKey];
        const bVal = b[sortKey];
        const modifier = sortDirection === "asc" ? 1 : -1;

        if (typeof aVal === "number" && typeof bVal === "number") {
          return (aVal - bVal) * modifier;
        }

        return String(aVal).localeCompare(String(bVal)) * modifier;
      })
    : data;
</script>

<div class="table-wrapper">
  <table class="table" class:hoverable class:striped class:compact>
    <thead>
      <tr>
        {#each headers as header}
          <th
            class:sortable={header.sortable}
            class:active={sortKey === header.key}
            on:click={() => header.sortable && handleSort(header.key)}
          >
            <div class="th-content">
              <span>{header.label}</span>

              {#if header.sortable}
                <span class="sort-icon">
                  {#if sortKey === header.key}
                    {sortDirection === "asc" ? "↑" : "↓"}
                  {:else}
                    ↕
                  {/if}
                </span>
              {/if}
            </div>
          </th>
        {/each}
      </tr>
    </thead>

    <tbody>
      {#if sortedData.length === 0}
        <tr>
          <td colspan={headers.length} class="empty-row">
            <slot name="empty">
              <div
                class="text-center text-neutral-500 dark:text-neutral-400 py-8"
              >
                Nenhum dado disponível
              </div>
            </slot>
          </td>
        </tr>
      {:else}
        {#each sortedData as row, i}
          <tr>
            {#each headers as header}
              <td>
                <slot name="cell" {row} column={header.key}>
                  {row[header.key] ?? "-"}
                </slot>
              </td>
            {/each}
          </tr>
        {/each}
      {/if}
    </tbody>
  </table>
</div>

<style>
  .table-wrapper {
    @apply w-full overflow-x-auto;
    @apply rounded-lg border border-neutral-200 dark:border-neutral-700;
  }

  .table {
    @apply w-full;
    @apply bg-transparent; /* Transparency for glass effect */
  }

  thead {
    @apply bg-neutral-50/50 dark:bg-neutral-900/50; /* Semi-transparent header */
    @apply border-b border-neutral-200/50 dark:border-neutral-700/50;
  }

  th {
    @apply px-4 py-3;
    @apply text-left text-xs font-semibold;
    @apply text-neutral-700 dark:text-neutral-300;
    @apply uppercase tracking-wider;
  }

  th.sortable {
    @apply cursor-pointer;
    @apply hover:bg-neutral-100 dark:hover:bg-neutral-800;
    @apply transition-colors;
  }

  th.active {
    @apply text-brand-blue-600 dark:text-brand-blue-400;
  }

  .th-content {
    @apply flex items-center justify-between gap-2;
  }

  .sort-icon {
    @apply text-neutral-400;
  }

  td {
    @apply px-4 py-3;
    @apply text-sm text-neutral-900 dark:text-neutral-100;
  }

  tbody tr {
    @apply border-b border-neutral-200 dark:border-neutral-700;
  }

  tbody tr:last-child {
    @apply border-b-0;
  }

  .table.hoverable tbody tr {
    @apply hover:bg-neutral-50 dark:hover:bg-neutral-900/50;
    @apply transition-colors;
  }

  .table.striped tbody tr:nth-child(even) {
    @apply bg-neutral-50 dark:bg-neutral-900/30;
  }

  .table.compact th,
  .table.compact td {
    @apply px-3 py-2;
  }

  .empty-row {
    @apply border-0;
  }
</style>
