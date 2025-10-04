/**
 * Servidor da Página de Configurações de Fornecedores
 * Gerencia configurações específicas dos fornecedores/laboratórios
 */

import type { PageServerLoad } from './$types';
import { supabase } from '$lib/supabase';

export const load: PageServerLoad = async ({ url }) => {
  try {
    // Buscar configurações gerais do sistema
    const { data: configData } = await supabase
      .from('v_configuracoes_sistema')
      .select('*')
      .limit(10);

    // Buscar dados dos vouchers para simular configurações de fornecedores
    const { data: vouchersData } = await supabase
      .from('vouchers_desconto')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(20);

    // Simular dados de configurações de fornecedores baseado nos vouchers
    const configuracoesFornecedores = vouchersData?.map((voucher, index) => ({
      id: voucher.id,
      fornecedor_nome: `Laboratório ${['Premium', 'Express', 'Quality', 'Standard', 'Economy'][index % 5]}`,
      status: voucher.status === 'ATIVO' ? 'ativo' : 'inativo',
      prioridade: Math.floor(Math.random() * 5) + 1,
      desconto_maximo: voucher.valor_desconto || 10,
      prazo_padrao: Math.floor(Math.random() * 7) + 2,
      regiao_atendimento: ['Sul', 'Sudeste', 'Centro-Oeste', 'Nordeste', 'Norte'][index % 5],
      tipo_pagamento: ['À vista', 'Cartão', 'Boleto', 'PIX'][index % 4],
      margem_minima: 15 + (index % 10),
      comissao_percentual: 5 + (index % 8),
      aceita_urgencia: Math.random() > 0.5,
      aceita_especiais: Math.random() > 0.3,
      data_ultima_atualizacao: voucher.updated_at || voucher.created_at
    })) || [];

    return {
      // Configurações dos fornecedores
      configuracoes: configuracoesFornecedores,
      
      // Estatísticas
      estatisticas: {
        total_fornecedores: configuracoesFornecedores.length,
        fornecedores_ativos: configuracoesFornecedores.filter(f => f.status === 'ativo').length,
        fornecedores_inativos: configuracoesFornecedores.filter(f => f.status === 'inativo').length,
        desconto_medio: configuracoesFornecedores.reduce((acc, f) => acc + f.desconto_maximo, 0) / configuracoesFornecedores.length || 0,
        prazo_medio: configuracoesFornecedores.reduce((acc, f) => acc + f.prazo_padrao, 0) / configuracoesFornecedores.length || 0
      },
      
      // Opções para formulários
      opcoes: {
        regioes: ['Sul', 'Sudeste', 'Centro-Oeste', 'Nordeste', 'Norte'],
        tipos_pagamento: ['À vista', 'Cartão', 'Boleto', 'PIX'],
        status_opcoes: [
          { value: 'ativo', label: 'Ativo' },
          { value: 'inativo', label: 'Inativo' },
          { value: 'manutencao', label: 'Em Manutenção' }
        ],
        prioridades: [
          { value: 1, label: 'Muito Baixa' },
          { value: 2, label: 'Baixa' },
          { value: 3, label: 'Média' },
          { value: 4, label: 'Alta' },
          { value: 5, label: 'Muito Alta' }
        ]
      },
      
      // Configurações gerais do sistema
      config_sistema: configData || [],
      
      // Metadados
      total_resultados: configuracoesFornecedores.length,
      data_atualizacao: new Date().toISOString()
    };

  } catch (err) {
    console.error('Erro no servidor de configurações de fornecedores:', err);
    
    // Retorna dados mockados em caso de erro
    return {
      configuracoes: [],
      estatisticas: {
        total_fornecedores: 0,
        fornecedores_ativos: 0,
        fornecedores_inativos: 0,
        desconto_medio: 0,
        prazo_medio: 0
      },
      opcoes: {
        regioes: ['Sul', 'Sudeste', 'Centro-Oeste', 'Nordeste', 'Norte'],
        tipos_pagamento: ['À vista', 'Cartão', 'Boleto', 'PIX'],
        status_opcoes: [
          { value: 'ativo', label: 'Ativo' },
          { value: 'inativo', label: 'Inativo' },
          { value: 'manutencao', label: 'Em Manutenção' }
        ],
        prioridades: [
          { value: 1, label: 'Muito Baixa' },
          { value: 2, label: 'Baixa' },
          { value: 3, label: 'Média' },
          { value: 4, label: 'Alta' },
          { value: 5, label: 'Muito Alta' }
        ]
      },
      config_sistema: [],
      total_resultados: 0,
      data_atualizacao: new Date().toISOString()
    };
  }
};