export type TipoLenteContato = 'diaria' | 'quinzenal' | 'mensal' | 'trimestral' | 'anual' | 'rgp' | 'escleral';
export type MaterialContato = 'hidrogel' | 'silicone_hidrogel' | 'rgp_gas_perm' | 'pmma';
export type FinalidadeContato = 'visao_simples' | 'torica' | 'multifocal' | 'cosmetica' | 'terapeutica' | 'orto_k';

export interface LenteContato {
  id: string;
  slug: string;
  nome_produto: string;
  sku: string;
  
  // Relacionamentos
  marca_nome: string;
  fabricante_nome: string; // Do join com fornecedores ou marcas
  fornecedor_nome: string;

  // Classificação
  tipo_lente: TipoLenteContato;
  material: MaterialContato;
  finalidade: FinalidadeContato;

  // Especificações
  diametro: number;
  curva_base: number;
  dk_t: number;
  conteudo_agua: number;
  
  // Faixas de Grau
  esferico_min: number;
  esferico_max: number;
  cilindrico_min: number;
  cilindrico_max: number;
  adicao_min: number;
  adicao_max: number;

  // Comercial
  preco_tabela: number; // Preço de Venda
  preco_custo: number;  // Preço de Custo
  margem_lucro?: number; // Margem calculada (opcional pois vem da view)
  unidades_por_caixa: number;
  dias_uso: number;
  
  // Metadata
  disponivel: boolean;
  descricao_curta: string;
  imagem_url?: string;
  
  created_at: string;
}

export interface FiltrosLentesContato {
  busca?: string;
  tipos?: TipoLenteContato[];
  materiais?: MaterialContato[];
  finalidades?: FinalidadeContato[];
  marcas?: string[];
  fabricantes?: string[];
  precoMin?: number;
  precoMax?: number;
}
