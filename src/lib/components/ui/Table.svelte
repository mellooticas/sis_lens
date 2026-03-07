<script lang="ts">
  /**
   * Table — SIS Lens Component Contract
   * Header: bg-muted/50 text-muted-foreground px-4 py-3
   * Row: border-b border-border hover:bg-muted/50
   * Cell: px-4 py-4
   */

  interface Header {
    key: string;
    label: string;
    sortable?: boolean;
  }

  interface Props {
    headers?: Header[];
    data?: Record<string, any>[];
    hoverable?: boolean;
    striped?: boolean;
    compact?: boolean;
    class?: string;
  }

  let {
    headers = [],
    data = [],
    hoverable = true,
    striped = false,
    compact = false,
    class: className = ''
  }: Props = $props();

  let sortKey = $state('');
  let sortDirection = $state<'asc' | 'desc'>('asc');

  function handleSort(key: string) {
    if (sortKey === key) {
      sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      sortKey = key;
      sortDirection = 'asc';
    }
  }

  let sortedData = $derived(
    sortKey
      ? [...data].sort((a, b) => {
          const aVal = a[sortKey];
          const bVal = b[sortKey];
          const modifier = sortDirection === 'asc' ? 1 : -1;

          if (typeof aVal === 'number' && typeof bVal === 'number') {
            return (aVal - bVal) * modifier;
          }

          return String(aVal).localeCompare(String(bVal)) * modifier;
        })
      : data
  );
</script>

<div class="w-full overflow-x-auto rounded-lg border border-border {className}">
  <table class="w-full">
    <thead>
      <tr class="bg-muted/50 border-b border-border">
        {#each headers as header}
          <th
            class="text-left text-xs font-semibold text-muted-foreground uppercase tracking-wider {compact ? 'px-3 py-2' : 'px-4 py-3'} {header.sortable ? 'cursor-pointer hover:bg-muted transition-colors select-none' : ''}"
            class:text-primary={sortKey === header.key}
            onclick={() => header.sortable && handleSort(header.key)}
          >
            <div class="flex items-center justify-between gap-2">
              <span>{header.label}</span>

              {#if header.sortable}
                <span class="text-muted-foreground/50">
                  {#if sortKey === header.key}
                    {sortDirection === 'asc' ? '\u2191' : '\u2193'}
                  {:else}
                    \u2195
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
          <td colspan={headers.length}>
            <div class="text-center text-muted-foreground py-8">
              Nenhum dado disponivel
            </div>
          </td>
        </tr>
      {:else}
        {#each sortedData as row, i}
          <tr
            class="border-b border-border last:border-b-0 {hoverable ? 'hover:bg-muted/50 transition-colors' : ''} {striped && i % 2 === 1 ? 'bg-muted/30' : ''}"
          >
            {#each headers as header}
              <td class="text-sm text-foreground {compact ? 'px-3 py-2' : 'px-4 py-4'}">
                {row[header.key] ?? '-'}
              </td>
            {/each}
          </tr>
        {/each}
      {/if}
    </tbody>
  </table>
</div>
