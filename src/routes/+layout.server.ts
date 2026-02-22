/**
 * SIS Lens — Layout Root Server
 * Expõe session e user para todo o app via $page.data
 * Necessário para o authStore (currentUser) funcionar corretamente.
 */

import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals }) => {
  const { session, user } = await locals.safeGetSession();

  return {
    session,
    user,
  };
};
