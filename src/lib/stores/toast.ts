/**
 * Toast Store
 * Store global para gerenciar notificações toast
 */

import { writable } from 'svelte/store';

export type ToastType = 'success' | 'error' | 'warning' | 'info';

export interface ToastMessage {
  id: string;
  message: string;
  type: ToastType;
  duration?: number;
}

function createToastStore() {
  const { subscribe, update } = writable<ToastMessage[]>([]);

  return {
    subscribe,
    
    // Adicionar toast
    show: (message: string, type: ToastType = 'success', duration = 3000) => {
      const id = Math.random().toString(36).substring(7);
      const toast: ToastMessage = { id, message, type, duration };
      
      update(toasts => [...toasts, toast]);
      
      // Auto-remover após duration
      if (duration > 0) {
        setTimeout(() => {
          update(toasts => toasts.filter(t => t.id !== id));
        }, duration);
      }
      
      return id;
    },
    
    // Remover toast específico
    remove: (id: string) => {
      update(toasts => toasts.filter(t => t.id !== id));
    },
    
    // Limpar todos
    clear: () => {
      update(() => []);
    },
    
    // Helpers para cada tipo
    success: (message: string, duration?: number) => {
      return createToastStore().show(message, 'success', duration);
    },
    
    error: (message: string, duration?: number) => {
      return createToastStore().show(message, 'error', duration);
    },
    
    warning: (message: string, duration?: number) => {
      return createToastStore().show(message, 'warning', duration);
    },
    
    info: (message: string, duration?: number) => {
      return createToastStore().show(message, 'info', duration);
    }
  };
}

export const toast = createToastStore(); 