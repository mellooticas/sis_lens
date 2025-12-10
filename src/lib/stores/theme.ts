import { writable } from 'svelte/store';
import { browser } from '$app/environment';

// Tipo de tema
type Theme = 'light' | 'dark';

// Criar store
function createThemeStore() {
  const { subscribe, set, update } = writable<Theme>('light');

  return {
    subscribe,
    
    // Inicializar (chamar no onMount ou layout)
    init: () => {
      if (!browser) return;

      // Verificar localStorage ou preferência do sistema
      const storedTheme = localStorage.getItem('theme') as Theme;
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      
      const initialTheme = storedTheme || (prefersDark ? 'dark' : 'light');
      
      set(initialTheme);
      updateDocument(initialTheme);
    },

    // Alternar tema
    toggle: () => {
      update(current => {
        const newTheme = current === 'light' ? 'dark' : 'light';
        updateDocument(newTheme);
        localStorage.setItem('theme', newTheme);
        return newTheme;
      });
    }
  };
}

// Atualizar classe no html
function updateDocument(theme: Theme) {
  if (!browser) return;
  
  const html = document.documentElement;
  if (theme === 'dark') {
    html.classList.add('dark');
  } else {
    html.classList.remove('dark');
  }
}

export const theme = createThemeStore();
