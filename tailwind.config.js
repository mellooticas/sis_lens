/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './src/**/*.{html,js,svelte,ts}',
    './src/routes/**/*.{svelte,ts}',
    './src/lib/**/*.{svelte,ts}'
  ],
  
  darkMode: 'class',
  
  theme: {
    extend: {
      colors: {
        // Brand Colors (Blueprint SIS Lens)
        'brand-blue': {
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
        'brand-orange': {
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
        'brand-gold': {
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
        },
        
        // Semantic Colors
        success: {
          DEFAULT: '#22c55e',
          light: '#dcfce7',
          dark: '#15803d'
        },
        warning: {
          DEFAULT: '#f59e0b',
          light: '#fef3c7',
          dark: '#b45309'
        },
        error: {
          DEFAULT: '#ef4444',
          light: '#fee2e2',
          dark: '#b91c1c'
        },
        info: {
          DEFAULT: '#3b82f6',
          light: '#dbeafe',
          dark: '#1d4ed8'
        },
        
        // Ranking Colors (Semáforo)
        'prazo-rapido': '#22c55e',
        'prazo-medio': '#f59e0b',
        'prazo-longo': '#ef4444',
        'preco-otimo': '#22c55e',
        'preco-bom': '#f59e0b',
        'preco-alto': '#ef4444'
      },
      
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        headline: ['Montserrat', 'system-ui', 'sans-serif']
      },
      
      boxShadow: {
        'card': '0 2px 8px rgba(28, 59, 90, 0.08)',
        'card-hover': '0 4px 16px rgba(28, 59, 90, 0.12)',
        'elevated': '0 8px 32px rgba(28, 59, 90, 0.16)'
      },
      
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in',
        'slide-up': 'slideUp 0.4s ease-out'
      },
      
      keyframes: {
        fadeIn: {
          from: { opacity: '0' },
          to: { opacity: '1' }
        },
        slideUp: {
          from: { transform: 'translateY(10px)', opacity: '0' },
          to: { transform: 'translateY(0)', opacity: '1' }
        }
      }
    }
  },
  
  plugins: []
};