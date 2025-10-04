/**
 * Theme Context - Dark/Light Mode
 * Gerencia tema global da aplicação
 */

import { writable } from 'svelte/store';
import { browser } from '$app/environment';

export type Theme = 'light' | 'dark';

// Helper para detectar preferência do sistema
function getSystemTheme(): Theme {
  if (!browser) return 'light';
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

// Helper para carregar tema salvo
function getSavedTheme(): Theme {
  if (!browser) return 'light';
  const saved = localStorage.getItem('bestlens-theme');
  return (saved as Theme) || getSystemTheme();
}

// Store do tema
function createThemeStore() {
  const { subscribe, set, update } = writable<Theme>(getSavedTheme());

  return {
    subscribe,
    
    // Setar tema específico
    set: (theme: Theme) => {
      set(theme);
      if (browser) {
        localStorage.setItem('bestlens-theme', theme);
        applyTheme(theme);
      }
    },
    
    // Toggle entre light/dark
    toggle: () => {
      update(current => {
        const newTheme = current === 'light' ? 'dark' : 'light';
        if (browser) {
          localStorage.setItem('bestlens-theme', newTheme);
          applyTheme(newTheme);
        }
        return newTheme;
      });
    },
    
    // Inicializar tema (chamar no mount)
    init: () => {
      const theme = getSavedTheme();
      set(theme);
      if (browser) {
        applyTheme(theme);
        
        // Observer para mudanças no sistema
        const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
        mediaQuery.addEventListener('change', (e) => {
          const systemTheme = e.matches ? 'dark' : 'light';
          const savedTheme = localStorage.getItem('bestlens-theme');
          if (!savedTheme) {
            set(systemTheme);
            applyTheme(systemTheme);
          }
        });
      }
    }
  };
}

// Aplicar tema no HTML
function applyTheme(theme: Theme) {
  if (!browser) return;
  
  const root = document.documentElement;
  
  if (theme === 'dark') {
    root.classList.add('dark');
  } else {
    root.classList.remove('dark');
  }
}

export const theme = createThemeStore();