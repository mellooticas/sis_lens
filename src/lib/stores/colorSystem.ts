import { writable } from 'svelte/store';
import { browser } from '$app/environment';
import type { ContrastLevel, ColorTheme } from '$lib/utils/colorSystem';
import { 
  applyContrastLevel, 
  applyColorTheme,
  getSavedContrastLevel,
  getSavedColorTheme 
} from '$lib/utils/colorSystem';

// Store de nível de contraste
function createContrastStore() {
  const { subscribe, set } = writable<ContrastLevel>('normal');

  return {
    subscribe,
    
    init: () => {
      if (!browser) return;
      const saved = getSavedContrastLevel();
      set(saved);
      applyContrastLevel(saved);
    },
    
    setLevel: (level: ContrastLevel) => {
      if (!browser) return;
      set(level);
      applyContrastLevel(level);
    }
  };
}

// Store de tema de cores
function createColorThemeStore() {
  const defaultTheme: ColorTheme = {
    primary: '#1c3b5a',      // primary-500
    secondary: '#d4af37',    // brand-gold-500
    accent: '#3b82f6',       // blue-500
    success: '#10b981',      // green-500
    warning: '#f59e0b',      // amber-500
    error: '#ef4444',        // red-500
  };

  const { subscribe, set } = writable<ColorTheme>(defaultTheme);

  return {
    subscribe,
    
    init: () => {
      if (!browser) return;
      const saved = getSavedColorTheme();
      if (saved) {
        set(saved);
        applyColorTheme(saved);
      } else {
        applyColorTheme(defaultTheme);
      }
    },
    
    setTheme: (theme: ColorTheme) => {
      if (!browser) return;
      set(theme);
      applyColorTheme(theme);
    },
    
    reset: () => {
      if (!browser) return;
      set(defaultTheme);
      applyColorTheme(defaultTheme);
      localStorage.removeItem('color-theme');
    }
  };
}

export const contrastStore = createContrastStore();
export const colorThemeStore = createColorThemeStore();
