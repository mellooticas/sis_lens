<script lang="ts">
  /**
   * 👓 Componente de Ícone de Óculos
   * Diferentes estilos de armações em SVG
   */
  
  export let style: 'aviator' | 'wayfarer' | 'round' | 'rectangular' | 'cat-eye' = 'wayfarer';
  export let size: 'sm' | 'md' | 'lg' | 'xl' = 'md';
  export let color: string = 'currentColor';
  export let className: string = '';

  const sizeMap = {
    sm: '24',
    md: '32',
    lg: '48',
    xl: '64'
  };

  const iconSize = sizeMap[size];
</script>

<div class="glasses-icon inline-flex {className}">
  {#if style === 'wayfarer'}
    <!-- Armação estilo Wayfarer (clássico retangular) -->
    <svg width={iconSize} height={iconSize} viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
      <!-- Lente esquerda -->
      <rect x="10" y="35" width="30" height="25" rx="3" stroke={color} stroke-width="2.5" fill="none"/>
      <!-- Ponte -->
      <line x1="40" y1="42" x2="60" y2="42" stroke={color} stroke-width="2"/>
      <!-- Lente direita -->
      <rect x="60" y="35" width="30" height="25" rx="3" stroke={color} stroke-width="2.5" fill="none"/>
      <!-- Haste esquerda -->
      <path d="M 10 42 L 2 42" stroke={color} stroke-width="2" stroke-linecap="round"/>
      <!-- Haste direita -->
      <path d="M 90 42 L 98 42" stroke={color} stroke-width="2" stroke-linecap="round"/>
      <!-- Detalhes decorativos -->
      <circle cx="25" cy="47" r="1.5" fill={color} opacity="0.3"/>
      <circle cx="75" cy="47" r="1.5" fill={color} opacity="0.3"/>
    </svg>

  {:else if style === 'aviator'}
    <!-- Armação estilo Aviator -->
    <svg width={iconSize} height={iconSize} viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
      <!-- Lente esquerda (gota) -->
      <path d="M 25 35 Q 15 35 10 47 Q 10 58 25 60 Q 38 58 38 47 Q 38 35 25 35 Z" 
            stroke={color} stroke-width="2" fill="none"/>
      <!-- Ponte dupla aviador -->
      <path d="M 38 42 L 45 38 L 55 38 L 62 42" stroke={color} stroke-width="1.5" fill="none"/>
      <!-- Lente direita (gota) -->
      <path d="M 75 35 Q 85 35 90 47 Q 90 58 75 60 Q 62 58 62 47 Q 62 35 75 35 Z" 
            stroke={color} stroke-width="2" fill="none"/>
      <!-- Hastes -->
      <path d="M 10 47 L 2 45" stroke={color} stroke-width="1.5" stroke-linecap="round"/>
      <path d="M 90 47 L 98 45" stroke={color} stroke-width="1.5" stroke-linecap="round"/>
      <!-- Reflexo -->
      <ellipse cx="20" cy="42" rx="4" ry="6" fill={color} opacity="0.15"/>
      <ellipse cx="70" cy="42" rx="4" ry="6" fill={color} opacity="0.15"/>
    </svg>

  {:else if style === 'round'}
    <!-- Armação redonda (John Lennon style) -->
    <svg width={iconSize} height={iconSize} viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
      <!-- Lente esquerda -->
      <circle cx="28" cy="47" r="15" stroke={color} stroke-width="2" fill="none"/>
      <!-- Ponte -->
      <line x1="43" y1="47" x2="57" y2="47" stroke={color} stroke-width="1.5"/>
      <!-- Lente direita -->
      <circle cx="72" cy="47" r="15" stroke={color} stroke-width="2" fill="none"/>
      <!-- Hastes -->
      <path d="M 13 47 L 5 47" stroke={color} stroke-width="1.5" stroke-linecap="round"/>
      <path d="M 87 47 L 95 47" stroke={color} stroke-width="1.5" stroke-linecap="round"/>
      <!-- Reflexo -->
      <circle cx="23" cy="42" r="3" fill={color} opacity="0.2"/>
      <circle cx="67" cy="42" r="3" fill={color} opacity="0.2"/>
    </svg>

  {:else if style === 'rectangular'}
    <!-- Armação retangular moderna -->
    <svg width={iconSize} height={iconSize} viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
      <!-- Lente esquerda -->
      <rect x="8" y="38" width="32" height="20" rx="2" stroke={color} stroke-width="2.5" fill="none"/>
      <!-- Ponte -->
      <line x1="40" y1="48" x2="60" y2="48" stroke={color} stroke-width="2"/>
      <!-- Lente direita -->
      <rect x="60" y="38" width="32" height="20" rx="2" stroke={color} stroke-width="2.5" fill="none"/>
      <!-- Hastes angulares -->
      <path d="M 8 48 L 1 46" stroke={color} stroke-width="2" stroke-linecap="round"/>
      <path d="M 92 48 L 99 46" stroke={color} stroke-width="2" stroke-linecap="round"/>
      <!-- Detalhes minimalistas -->
      <line x1="10" y1="40" x2="10" y2="56" stroke={color} stroke-width="0.5" opacity="0.3"/>
      <line x1="90" y1="40" x2="90" y2="56" stroke={color} stroke-width="0.5" opacity="0.3"/>
    </svg>

  {:else if style === 'cat-eye'}
    <!-- Armação Cat Eye (vintage/feminino) -->
    <svg width={iconSize} height={iconSize} viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
      <!-- Lente esquerda com cantos levantados -->
      <path d="M 12 48 Q 10 42 15 38 L 35 36 Q 40 38 40 48 Q 38 56 28 58 Q 15 57 12 48 Z" 
            stroke={color} stroke-width="2" fill="none"/>
      <!-- Ponte delicada -->
      <path d="M 40 45 Q 45 43 50 43 Q 55 43 60 45" stroke={color} stroke-width="1.5" fill="none"/>
      <!-- Lente direita com cantos levantados -->
      <path d="M 88 48 Q 90 42 85 38 L 65 36 Q 60 38 60 48 Q 62 56 72 58 Q 85 57 88 48 Z" 
            stroke={color} stroke-width="2" fill="none"/>
      <!-- Hastes -->
      <path d="M 12 48 L 4 48" stroke={color} stroke-width="1.5" stroke-linecap="round"/>
      <path d="M 88 48 L 96 48" stroke={color} stroke-width="1.5" stroke-linecap="round"/>
      <!-- Decoração vintage -->
      <circle cx="35" cy="37" r="1" fill={color}/>
      <circle cx="65" cy="37" r="1" fill={color}/>
    </svg>
  {/if}
</div>

<style>
  .glasses-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
  }

  .glasses-icon svg {
    filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.1));
  }
</style>
