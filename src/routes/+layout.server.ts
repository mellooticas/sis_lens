/**
 * SIS Lens — Layout Root Server
 * Expõe session, user e cookies para todo o app via $page.data
 *
 * cookies.getAll() é necessário para o +layout.ts criar o server client
 * durante SSR com os mesmos cookies do request original.
 */

import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals, cookies }) => {
  const { session, user } = await locals.safeGetSession();

  return {
    session,
    user,
    cookies: cookies.getAll(),
  };
};
