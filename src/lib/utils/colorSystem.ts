/**
 * Sistema de Controle de Cores e Contraste
 * Funções para calcular contraste, ajustar cores dinamicamente e garantir acessibilidade
 */

// Tipo para configuração de contraste
export type ContrastLevel = 'normal' | 'medium' | 'high' | 'maximum';

// Configuração de contrastes por nível
export const contrastConfig = {
  normal: {
    textOnLight: 0.87,     // Opacidade padrão texto escuro
    textOnDark: 0.87,      // Opacidade padrão texto claro
    borderStrength: 0.1,   // Força das bordas
    shadowStrength: 0.08,  // Força das sombras
  },
  medium: {
    textOnLight: 0.92,
    textOnDark: 0.92,
    borderStrength: 0.15,
    shadowStrength: 0.12,
  },
  high: {
    textOnLight: 0.95,
    textOnDark: 0.95,
    borderStrength: 0.2,
    shadowStrength: 0.16,
  },
  maximum: {
    textOnLight: 1.0,
    textOnDark: 1.0,
    borderStrength: 0.3,
    shadowStrength: 0.2,
  }
};

/**
 * Converte hex para RGB
 */
export function hexToRgb(hex: string): { r: number; g: number; b: number } | null {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
}

/**
 * Converte RGB para hex
 */
export function rgbToHex(r: number, g: number, b: number): string {
  return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
}

/**
 * Calcula luminância relativa (WCAG 2.0)
 */
export function getLuminance(r: number, g: number, b: number): number {
  const [rs, gs, bs] = [r, g, b].map(c => {
    c = c / 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
}

/**
 * Calcula contraste entre duas cores (WCAG 2.0)
 * Retorna valor de 1 (sem contraste) a 21 (máximo contraste)
 */
export function getContrast(color1: string, color2: string): number {
  const rgb1 = hexToRgb(color1);
  const rgb2 = hexToRgb(color2);
  
  if (!rgb1 || !rgb2) return 1;
  
  const lum1 = getLuminance(rgb1.r, rgb1.g, rgb1.b);
  const lum2 = getLuminance(rgb2.r, rgb2.g, rgb2.b);
  
  const lighter = Math.max(lum1, lum2);
  const darker = Math.min(lum1, lum2);
  
  return (lighter + 0.05) / (darker + 0.05);
}

/**
 * Verifica se o contraste atende WCAG AA ou AAA
 */
export function meetsWCAG(color1: string, color2: string, level: 'AA' | 'AAA' = 'AA'): {
  normalText: boolean;
  largeText: boolean;
  contrast: number;
} {
  const contrast = getContrast(color1, color2);
  const threshold = level === 'AAA' ? 7 : 4.5;
  const largeThreshold = level === 'AAA' ? 4.5 : 3;
  
  return {
    normalText: contrast >= threshold,
    largeText: contrast >= largeThreshold,
    contrast: Math.round(contrast * 100) / 100
  };
}

/**
 * Escurece uma cor
 */
export function darken(hex: string, percent: number): string {
  const rgb = hexToRgb(hex);
  if (!rgb) return hex;
  
  const factor = 1 - (percent / 100);
  return rgbToHex(
    Math.round(rgb.r * factor),
    Math.round(rgb.g * factor),
    Math.round(rgb.b * factor)
  );
}

/**
 * Clareia uma cor
 */
export function lighten(hex: string, percent: number): string {
  const rgb = hexToRgb(hex);
  if (!rgb) return hex;
  
  const factor = percent / 100;
  return rgbToHex(
    Math.round(rgb.r + (255 - rgb.r) * factor),
    Math.round(rgb.g + (255 - rgb.g) * factor),
    Math.round(rgb.b + (255 - rgb.b) * factor)
  );
}

/**
 * Ajusta saturação de uma cor
 */
export function adjustSaturation(hex: string, percent: number): string {
  const rgb = hexToRgb(hex);
  if (!rgb) return hex;
  
  // Converter para HSL
  const r = rgb.r / 255;
  const g = rgb.g / 255;
  const b = rgb.b / 255;
  
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  let h = 0, s = 0, l = (max + min) / 2;
  
  if (max !== min) {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    
    switch (max) {
      case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6; break;
      case g: h = ((b - r) / d + 2) / 6; break;
      case b: h = ((r - g) / d + 4) / 6; break;
    }
  }
  
  // Ajustar saturação
  s = Math.max(0, Math.min(1, s * (1 + percent / 100)));
  
  // Converter de volta para RGB
  function hue2rgb(p: number, q: number, t: number) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1/6) return p + (q - p) * 6 * t;
    if (t < 1/2) return q;
    if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
    return p;
  }
  
  const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
  const p = 2 * l - q;
  
  const rNew = hue2rgb(p, q, h + 1/3);
  const gNew = hue2rgb(p, q, h);
  const bNew = hue2rgb(p, q, h - 1/3);
  
  return rgbToHex(
    Math.round(rNew * 255),
    Math.round(gNew * 255),
    Math.round(bNew * 255)
  );
}

/**
 * Gera uma paleta de cores a partir de uma cor base
 */
export function generatePalette(baseColor: string): {
  50: string;
  100: string;
  200: string;
  300: string;
  400: string;
  500: string;
  600: string;
  700: string;
  800: string;
  900: string;
} {
  return {
    50: lighten(baseColor, 40),
    100: lighten(baseColor, 32),
    200: lighten(baseColor, 24),
    300: lighten(baseColor, 16),
    400: lighten(baseColor, 8),
    500: baseColor,
    600: darken(baseColor, 8),
    700: darken(baseColor, 16),
    800: darken(baseColor, 24),
    900: darken(baseColor, 32),
  };
}

/**
 * Aplica nível de contraste ao documento
 */
export function applyContrastLevel(level: ContrastLevel): void {
  if (typeof document === 'undefined') return;
  
  const config = contrastConfig[level];
  const root = document.documentElement;
  
  // Aplicar opacidades de texto
  root.style.setProperty('--text-opacity-light', config.textOnLight.toString());
  root.style.setProperty('--text-opacity-dark', config.textOnDark.toString());
  root.style.setProperty('--border-strength', config.borderStrength.toString());
  root.style.setProperty('--shadow-strength', config.shadowStrength.toString());
  
  // Aplicar contraste em cores baseado no tema atual
  const isDark = root.classList.contains('dark');
  
  if (isDark) {
    // Dark mode - aumentar contraste com cores mais claras
    const textBrightness = 200 + (config.textOnDark * 55); // 200-255
    const bgDarkness = 15 * (1 - config.textOnDark); // 15-0
    
    root.style.setProperty('--contrast-text', `rgb(${textBrightness}, ${textBrightness}, ${textBrightness})`);
    root.style.setProperty('--contrast-bg', `rgb(${bgDarkness}, ${bgDarkness}, ${bgDarkness})`);
  } else {
    // Light mode - aumentar contraste com cores mais escuras
    const textDarkness = 50 * (1 - config.textOnLight); // 50-0
    const bgBrightness = 240 + (config.textOnLight * 15); // 240-255
    
    root.style.setProperty('--contrast-text', `rgb(${textDarkness}, ${textDarkness}, ${textDarkness})`);
    root.style.setProperty('--contrast-bg', `rgb(${bgBrightness}, ${bgBrightness}, ${bgBrightness})`);
  }
  
  // Salvar preferência
  localStorage.setItem('contrast-level', level);
}

/**
 * Obtém nível de contraste salvo
 */
export function getSavedContrastLevel(): ContrastLevel {
  if (typeof localStorage === 'undefined') return 'normal';
  return (localStorage.getItem('contrast-level') as ContrastLevel) || 'normal';
}

/**
 * Aplica tema de cor customizado
 */
export interface ColorTheme {
  primary: string;
  secondary: string;
  accent: string;
  success: string;
  warning: string;
  error: string;
}

export function applyColorTheme(theme: ColorTheme): void {
  if (typeof document === 'undefined') return;
  
  const root = document.documentElement;
  
  // Gerar paletas para cada cor
  const primaryPalette = generatePalette(theme.primary);
  const secondaryPalette = generatePalette(theme.secondary);
  
  // Aplicar variáveis CSS
  Object.entries(primaryPalette).forEach(([shade, color]) => {
    root.style.setProperty(`--color-primary-${shade}`, color);
  });
  
  Object.entries(secondaryPalette).forEach(([shade, color]) => {
    root.style.setProperty(`--color-secondary-${shade}`, color);
  });
  
  root.style.setProperty('--color-accent', theme.accent);
  root.style.setProperty('--color-success', theme.success);
  root.style.setProperty('--color-warning', theme.warning);
  root.style.setProperty('--color-error', theme.error);
  
  // Salvar tema
  localStorage.setItem('color-theme', JSON.stringify(theme));
}

/**
 * Obtém tema de cor salvo
 */
export function getSavedColorTheme(): ColorTheme | null {
  if (typeof localStorage === 'undefined') return null;
  const saved = localStorage.getItem('color-theme');
  return saved ? JSON.parse(saved) : null;
}
