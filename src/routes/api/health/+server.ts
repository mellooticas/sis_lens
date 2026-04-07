import { json } from '@sveltejs/kit'

export const GET = () =>
  json({
    status: 'ok',
    service: 'clearix-lens',
    timestamp: new Date().toISOString(),
  })
