/**
 * Servidor da Página de Contato - Carrega dados de contato
 * Processa formulários de contato e suporte
 */

import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';

export const load: PageServerLoad = async ({ url }) => {
  try {
    // Buscar configurações de contato do sistema
    const { data: configData } = await supabase
      .from('v_configuracoes_sistema')
      .select('*')
      .limit(5);

    // Buscar informações do sistema para contato
    const { data: usuariosCount } = await supabase
      .from('usuarios')
      .select('id', { count: 'exact' });

    return {
      // Dados de contato
      contato_info: {
        empresa: 'BestLens - Sistema Decisor de Lentes',
        email: 'contato@bestlens.com.br',
        telefone: '(11) 3000-0000',
        endereco: 'São Paulo, SP - Brasil',
        horario_funcionamento: 'Segunda a Sexta: 8h às 18h'
      },
      
      // Estatísticas do sistema
      estatisticas: {
        usuarios_ativos: usuariosCount?.length || 0,
        configuracoes_ativas: configData?.length || 0,
        sistema_online: true,
        ultima_atualizacao: new Date().toISOString()
      },
      
      // Formulário de contato (campos padrão)
      form_fields: {
        nome: '',
        email: '',
        empresa: '',
        telefone: '',
        assunto: '',
        mensagem: '',
        tipo_contato: 'suporte' // suporte, comercial, tecnico
      },
      
      // Tipos de contato disponíveis
      tipos_contato: [
        { value: 'suporte', label: 'Suporte Técnico' },
        { value: 'comercial', label: 'Comercial/Vendas' },
        { value: 'tecnico', label: 'Questões Técnicas' },
        { value: 'feedback', label: 'Feedback/Sugestões' },
        { value: 'outro', label: 'Outros Assuntos' }
      ]
    };

  } catch (err) {
    console.error('Erro no servidor de contato:', err);
    
    // Retorna dados básicos mesmo em caso de erro
    return {
      contato_info: {
        empresa: 'BestLens - Sistema Decisor de Lentes',
        email: 'contato@bestlens.com.br',
        telefone: '(11) 3000-0000',
        endereco: 'São Paulo, SP - Brasil',
        horario_funcionamento: 'Segunda a Sexta: 8h às 18h'
      },
      estatisticas: {
        usuarios_ativos: 0,
        configuracoes_ativas: 0,
        sistema_online: true,
        ultima_atualizacao: new Date().toISOString()
      },
      form_fields: {
        nome: '',
        email: '',
        empresa: '',
        telefone: '',
        assunto: '',
        mensagem: '',
        tipo_contato: 'suporte'
      },
      tipos_contato: [
        { value: 'suporte', label: 'Suporte Técnico' },
        { value: 'comercial', label: 'Comercial/Vendas' },
        { value: 'tecnico', label: 'Questões Técnicas' },
        { value: 'feedback', label: 'Feedback/Sugestões' },
        { value: 'outro', label: 'Outros Assuntos' }
      ]
    };
  }
};