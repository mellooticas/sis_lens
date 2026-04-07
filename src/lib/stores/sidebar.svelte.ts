const STORAGE_KEY = 'clearix-lens-sidebar'

class SidebarStore {
  collapsed = $state(false)
  mobileOpen = $state(false)

  constructor() {
    if (typeof window !== 'undefined') {
      this.collapsed = localStorage.getItem(STORAGE_KEY) === 'true'
    }
  }

  toggleCollapse() {
    this.collapsed = !this.collapsed
    localStorage.setItem(STORAGE_KEY, String(this.collapsed))
  }

  openMobile() { this.mobileOpen = true }
  closeMobile() { this.mobileOpen = false }
}

export const sidebarStore = new SidebarStore()
