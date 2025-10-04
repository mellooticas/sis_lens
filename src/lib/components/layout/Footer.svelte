<script lang="ts">
  /**
   * Footer Component
   * Rodapé do app
   */
  
  import Logo from './Logo.svelte';
  
  const currentYear = new Date().getFullYear();
  
  const links = {
    product: [
      { label: 'Buscar Lentes', href: '/buscar' },
      { label: 'Histórico', href: '/historico' },
      { label: 'Configurações', href: '/config' }
    ],
    company: [
      { label: 'Sobre', href: '/sobre' },
      { label: 'Contato', href: '/contato' },
      { label: 'Suporte', href: '/suporte' }
    ],
    legal: [
      { label: 'Termos de Uso', href: '/termos' },
      { label: 'Privacidade', href: '/privacidade' }
    ]
  };
</script>

<footer class="footer">
  <div class="container mx-auto px-4">
    <div class="footer-content">
      <!-- Logo e Descrição -->
      <div class="footer-brand">
        <Logo size="md" theme="auto" />
        <p class="brand-description">
          Sistema de apoio à decisão para compra de lentes oftálmicas. 
          Compare fornecedores e tome decisões inteligentes.
        </p>
      </div>
      
      <!-- Links -->
      <div class="footer-links">
        <div class="link-column">
          <h4 class="column-title">Produto</h4>
          <ul class="link-list">
            {#each links.product as link}
              <li>
                <a href={link.href} class="footer-link">
                  {link.label}
                </a>
              </li>
            {/each}
          </ul>
        </div>
        
        <div class="link-column">
          <h4 class="column-title">Empresa</h4>
          <ul class="link-list">
            {#each links.company as link}
              <li>
                <a href={link.href} class="footer-link">
                  {link.label}
                </a>
              </li>
            {/each}
          </ul>
        </div>
        
        <div class="link-column">
          <h4 class="column-title">Legal</h4>
          <ul class="link-list">
            {#each links.legal as link}
              <li>
                <a href={link.href} class="footer-link">
                  {link.label}
                </a>
              </li>
            {/each}
          </ul>
        </div>
      </div>
    </div>
    
    <!-- Bottom -->
    <div class="footer-bottom">
      <p class="copyright">
        © {currentYear} BestLens. Todos os direitos reservados.
      </p>
      
      <div class="social-links">
        <button type="button" class="social-link" aria-label="LinkedIn">
          <svg width="20" height="20" fill="currentColor" viewBox="0 0 24 24">
            <path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/>
          </svg>
        </button>
      </div>
    </div>
  </div>
</footer>

<style>
  .footer {
    @apply bg-white dark:bg-neutral-900;
    @apply border-t border-neutral-200 dark:border-neutral-800;
    @apply py-12;
    @apply transition-colors;
  }
  
  .footer-content {
    @apply grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8;
    @apply pb-8 mb-8;
    @apply border-b border-neutral-200 dark:border-neutral-800;
  }
  
  .footer-brand {
    @apply lg:col-span-1;
  }
  
  .brand-description {
    @apply mt-4 text-sm;
    @apply text-neutral-600 dark:text-neutral-400;
    @apply max-w-xs;
  }
  
  .footer-links {
    @apply lg:col-span-3;
    @apply grid grid-cols-1 sm:grid-cols-3 gap-8;
  }
  
  .link-column {
    @apply space-y-4;
  }
  
  .column-title {
    @apply font-semibold;
    @apply text-neutral-900 dark:text-neutral-100;
  }
  
  .link-list {
    @apply space-y-2;
  }
  
  .footer-link {
    @apply text-sm;
    @apply text-neutral-600 dark:text-neutral-400;
    @apply hover:text-brand-blue-600 dark:hover:text-brand-blue-400;
    @apply transition-colors;
  }
  
  .footer-bottom {
    @apply flex flex-col sm:flex-row;
    @apply items-center justify-between;
    @apply gap-4;
  }
  
  .copyright {
    @apply text-sm;
    @apply text-neutral-600 dark:text-neutral-400;
  }
  
  .social-links {
    @apply flex items-center gap-4;
  }
  
  .social-link {
    @apply text-neutral-600 dark:text-neutral-400;
    @apply hover:text-brand-blue-600 dark:hover:text-brand-blue-400;
    @apply transition-colors;
  }
</style>