/**
 * SIS Lens Design Tokens
 * Sistema completo de design tokens para uso em TypeScript/JavaScript
 */

export const colors = {
  brand: {
    blue: {
      50: '#f0f4f8',
      100: '#d9e6f2',
      200: '#b3cce5',
      300: '#8db3d8',
      400: '#6799cb',
      500: '#1C3B5A', // Primary
      600: '#162f48',
      700: '#112336',
      800: '#0b1724',
      900: '#060c12'
    },
    orange: {
      50: '#fef5f0',
      100: '#fde6d9',
      200: '#fbcdb3',
      300: '#f9b48d',
      400: '#f79b67',
      500: '#CC6B2F', // Accent
      600: '#a35626',
      700: '#7a401c',
      800: '#522b13',
      900: '#291509'
    },
    gold: {
      50: '#fdfaf2',
      100: '#fbf4e0',
      200: '#f7e9c1',
      300: '#f3dea2',
      400: '#efd383',
      500: '#DEA742', // Value
      600: '#b28635',
      700: '#856428',
      800: '#59431a',
      900: '#2c210d'
    },
    neutral: {
      50: '#fafaf9',
      100: '#f5f5f4',
      200: '#e7e5e4',
      300: '#d6d3d1',
      400: '#a8a29e',
      500: '#E8E0D5', // Base
      600: '#78716c',
      700: '#57534e',
      800: '#44403c',
      900: '#292524'
    }
  },
  semantic: {
    success: {
      light: '#dcfce7',
      DEFAULT: '#22c55e',
      dark: '#15803d'
    },
    warning: {
      light: '#fef3c7',
      DEFAULT: '#f59e0b',
      dark: '#b45309'
    },
    error: {
      light: '#fee2e2',
      DEFAULT: '#ef4444',
      dark: '#b91c1c'
    },
    info: {
      light: '#dbeafe',
      DEFAULT: '#3b82f6',
      dark: '#1d4ed8'
    }
  },
  ranking: {
    prazo: {
      rapido: '#22c55e',
      medio: '#f59e0b',
      longo: '#ef4444'
    },
    preco: {
      otimo: '#22c55e',
      bom: '#f59e0b',
      alto: '#ef4444'
    }
  }
} as const;

export const typography = {
  fontFamily: {
    sans: 'Inter, system-ui, sans-serif',
    headline: 'Montserrat, system-ui, sans-serif',
    mono: 'JetBrains Mono, monospace'
  },
  fontSize: {
    xs: '0.75rem',    // 12px
    sm: '0.875rem',   // 14px
    base: '1rem',     // 16px
    lg: '1.125rem',   // 18px
    xl: '1.25rem',    // 20px
    '2xl': '1.5rem',  // 24px
    '3xl': '1.875rem', // 30px
    '4xl': '2.25rem',  // 36px
    '5xl': '3rem',     // 48px
    '6xl': '3.75rem'   // 60px
  },
  fontWeight: {
    light: 300,
    regular: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
    extrabold: 800
  },
  lineHeight: {
    tight: 1.25,
    normal: 1.5,
    relaxed: 1.75,
    loose: 2
  }
} as const;

export const spacing = {
  0: '0',
  1: '0.25rem',   // 4px
  2: '0.5rem',    // 8px
  3: '0.75rem',   // 12px
  4: '1rem',      // 16px
  5: '1.25rem',   // 20px
  6: '1.5rem',    // 24px
  8: '2rem',      // 32px
  10: '2.5rem',   // 40px
  12: '3rem',     // 48px
  16: '4rem',     // 64px
  20: '5rem',     // 80px
  24: '6rem'      // 96px
} as const;

export const borderRadius = {
  none: '0',
  sm: '0.125rem',   // 2px
  base: '0.25rem',  // 4px
  md: '0.375rem',   // 6px
  lg: '0.5rem',     // 8px
  xl: '0.75rem',    // 12px
  '2xl': '1rem',    // 16px
  '3xl': '1.5rem',  // 24px
  full: '9999px'
} as const;

export const shadows = {
  sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
  base: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
  md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
  lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
  card: '0 2px 8px rgba(28, 59, 90, 0.08)',
  cardHover: '0 4px 16px rgba(28, 59, 90, 0.12)',
  elevated: '0 8px 32px rgba(28, 59, 90, 0.16)'
} as const;

export const zIndex = {
  base: 0,
  dropdown: 10,
  sticky: 20,
  fixed: 30,
  modal: 40,
  popover: 50,
  tooltip: 60
} as const;

// Helper functions para uso dinâmico
export const getRankingColor = (tipo: 'prazo' | 'preco', valor: number) => {
  if (tipo === 'prazo') {
    if (valor < 5) return colors.ranking.prazo.rapido;
    if (valor <= 10) return colors.ranking.prazo.medio;
    return colors.ranking.prazo.longo;
  } else {
    // Lógica de preço (comparativo)
    // Aqui você pode implementar lógica baseada em percentil
    return colors.ranking.preco.bom; // Default
  }
};

export const getScoreColor = (score: number) => {
  if (score >= 8) return colors.semantic.success.DEFAULT;
  if (score >= 6) return colors.semantic.warning.DEFAULT;
  return colors.semantic.error.DEFAULT;
};

// Export default com tudo
export default {
  colors,
  typography,
  spacing,
  borderRadius,
  shadows,
  zIndex,
  getRankingColor,
  getScoreColor
};