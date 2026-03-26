export const SSO_APP_KEY = 'clearix_lens'
export const SSO_TICKET_PARAM = 'ticket'
export const SSO_DEFAULT_NEXT = '/'

export function normalizeSsoNext(next?: string | null, fallback = SSO_DEFAULT_NEXT): string {
  if (!next) {
    return fallback
  }

  if (
    next.startsWith('/') &&
    !next.startsWith('/auth') &&
    !next.includes("'") &&
    !next.includes('"')
  ) {
    return next
  }

  return fallback
}
