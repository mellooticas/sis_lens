/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
      colors: {
        // BestLens Brand Colors
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
            500: '#E8E0D5', // Base light
            600: '#78716c',
            700: '#57534e',
            800: '#44403c',
            900: '#292524'
          }
        },
        // Cores de Estado
        success: '#22c55e',
        warning: '#f59e0b',
        error: '#ef4444',
        info: '#3b82f6'
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        headline: ['Montserrat', 'system-ui', 'sans-serif']
      },
      fontSize: {
        xs: ['0.75rem', { lineHeight: '1rem' }],
        sm: ['0.875rem', { lineHeight: '1.25rem' }],
        base: ['1rem', { lineHeight: '1.5rem' }],
        lg: ['1.125rem', { lineHeight: '1.75rem' }],
        xl: ['1.25rem', { lineHeight: '1.75rem' }],
        '2xl': ['1.5rem', { lineHeight: '2rem' }],
        '3xl': ['1.875rem', { lineHeight: '2.25rem' }],
        '4xl': ['2.25rem', { lineHeight: '2.5rem' }],
        '5xl': ['3rem', { lineHeight: '1' }],
        '6xl': ['3.75rem', { lineHeight: '1' }]
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '100': '25rem',
        '112': '28rem',
        '128': '32rem'
      },
      borderRadius: {
        '4xl': '2rem'
      },
      boxShadow: {
        'card': '0 2px 8px rgba(28, 59, 90, 0.08)',
        'card-hover': '0 4px 16px rgba(28, 59, 90, 0.12)',
        'elevated': '0 8px 32px rgba(28, 59, 90, 0.16)'
      }
    }
  },
  plugins: []
};