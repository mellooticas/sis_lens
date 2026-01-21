/**
 * Formata um número como preço em reais (R$)
 */
export function formatarPreco(valor: number): string {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(valor);
}

/**
 * Formata um número como percentual
 */
export function formatarPercentual(valor: number, casasDecimais = 2): string {
  return `${valor.toFixed(casasDecimais)}%`;
}

/**
 * Formata uma data no formato brasileiro
 */
export function formatarData(data: string | Date): string {
  const date = typeof data === 'string' ? new Date(data) : data;
  return new Intl.DateTimeFormat('pt-BR').format(date);
}

/**
 * Formata um número como decimal com casas decimais
 */
export function formatarDecimal(valor: number, casasDecimais = 2): string {
  return valor.toFixed(casasDecimais);
}
