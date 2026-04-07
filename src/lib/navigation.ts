import type { NavSection, UserRole } from '$lib/components/sidebar/sidebar-types'

const ALL_ROLES: UserRole[] = ['super_admin', 'admin', 'rh_manager', 'manager', 'staff']

export const navigation: NavSection[] = [
  {
    id: 'principal',
    label: 'PRINCIPAL',
    items: [
      { id: 'dashboard', label: 'Dashboard', href: '/', icon: 'home', roles: ALL_ROLES },
    ],
  },
  {
    id: 'catalogos',
    label: 'CATALOGOS',
    items: [
      { id: 'lentes', label: 'Lentes', href: '/lentes', icon: 'grid', roles: ALL_ROLES },
      { id: 'standard', label: 'Standard', href: '/standard', icon: 'box', roles: ALL_ROLES },
      { id: 'premium', label: 'Premium', href: '/premium', icon: 'sparkles', roles: ALL_ROLES },
      { id: 'contato', label: 'Contato', href: '/contato', icon: 'eye', roles: ALL_ROLES },
    ],
  },
  {
    id: 'operacao',
    label: 'OPERACAO',
    items: [
      { id: 'simulador', label: 'Simulador de Receita', href: '/simulador/receita', icon: 'zap', roles: ALL_ROLES },
    ],
  },
  {
    id: 'estrategia-bi',
    label: 'ESTRATEGIA & BI',
    items: [
      { id: 'ranking', label: 'Ranking de Lentes', href: '/ranking', icon: 'trophy', roles: ALL_ROLES },
    ],
  },
  {
    id: 'gestao',
    label: 'GESTAO',
    items: [
      { id: 'saude', label: 'Saude do Sistema', href: '/saude', icon: 'shield', roles: ['super_admin', 'admin'] },
    ],
  },
]

export function getFilteredNavigation(role?: UserRole): NavSection[] {
  if (!role) return navigation
  return navigation
    .map((section) => ({
      ...section,
      items: section.items.filter((item) => item.roles.includes(role)),
    }))
    .filter((section) => section.items.length > 0)
}
