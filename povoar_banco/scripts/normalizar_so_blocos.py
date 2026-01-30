import pandas as pd
import uuid
import os

def normalizar_so_blocos():
    path_vs = r'D:\projetos\sis_lens\povoar_banco\csv\so_blocos_vs.csv'
    path_multi = r'D:\projetos\sis_lens\povoar_banco\csv\so_blocos_multi.csv'
    output_path = r'D:\projetos\sis_lens\povoar_banco\csv\banco\so_blocos_final.csv'
    
    fornecedor_id = 'e1e1eace-11b4-4f26-9f15-620808a4a410' # So Blocos
    marca_id = '4af04ba6-e600-4874-b8dc-45a2e1773725'      # SO BLOCOS
    
    def calcular_preco_venda(custo):
        if custo <= 0: return 0.0
        venda = max(custo * 3.0, 250.0 + (custo * 0.1))
        if venda > custo * 4.0:
            if custo > 100: venda = custo * 4.0
        return round(venda, 2)

    def transform_row(row, tipo):
        tratamento = str(row['tratamento']).lower()
        nome = str(row['nome_completo_lente'])
        
        # Mapeamento de Material
        material_orig = str(row['material']).lower()
        if 'policarbonato' in material_orig or 'poli' in material_orig:
            material = 'POLICARBONATO'
        else:
            material = 'CR39' # Acetato/Resina
            
        # Mapeamento de Fotossensível
        if 'transitions' in tratamento:
            foto = 'transitions'
        elif 'fotossensível' in tratamento or 'foto' in tratamento:
            foto = 'fotocromático'
        else:
            foto = 'nenhum'
            
        # Tratamentos Booleanos
        has_ar = any(x in tratamento for x in ['ar', 'blue', 'hidro', 'hmc'])
        has_blue = any(x in tratamento for x in ['blue', 'bluecut'])
        has_uv = any(x in tratamento for x in ['uv', 'uv400']) or material == 'POLICARBONATO' or row['indice_refracao'] >= 1.6
        has_antirrisco = any(x in tratamento for x in ['verniz', 'hc', 'hidro', 'hmc', 'ar'])
        
        # Formatação Índice (O banco tem enums fixos)
        orig_indice = float(row['indice_refracao'])
        if orig_indice == 1.49:
            indice = "1.50"
        elif orig_indice == 1.70:
            indice = "1.74" # Mapeia 1.70 para 1.74 que é o mais próximo no Enum
        else:
            indice = "{:.2f}".format(orig_indice)
        
        # Correção adicional para formatar 1.5 como 1.50 (garantindo string exata do enum)
        if indice == "1.5": indice = "1.50"
        if indice == "1.6": indice = "1.61" # Se houver 1.6 puro, mapeia para 1.61
        
        # Dicionário de saída (conforme tabela_lentes.sql)
        data = {
            'id': str(uuid.uuid4()),
            'fornecedor_id': fornecedor_id,
            'marca_id': marca_id,
            'nome_lente': nome,
            'nome_comercial': nome,
            'tipo_lente': tipo,
            'material': material,
            'indice_refracao': indice,
            'categoria': 'economica',
            'tratamento_antirreflexo': has_ar,
            'tratamento_antirrisco': has_antirrisco,
            'tratamento_uv': has_uv,
            'tratamento_blue_light': has_blue,
            'tratamento_fotossensiveis': foto,
            'fotossensivel': foto,
            'ar': has_ar,
            'blue': has_blue,
            'uv400': has_uv,
            'antirrisco': has_antirrisco,
            'esferico_min': row['esf_min'],
            'esferico_max': row['esf_max'],
            'cilindrico_min': row['cil_min'],
            'cilindrico_max': row['cil_max'],
            'grau_esferico_min': row['esf_min'],
            'grau_esferico_max': row['esf_max'],
            'grau_cilindrico_min': row['cil_min'],
            'grau_cilindrico_max': row['cil_max'],
            'preco_custo': row['preco_custo'],
            'custo_base': row['preco_custo'],
            'preco_tabela': calcular_preco_venda(float(row['preco_custo'])), # Markup base de 3x se não houver regra
            'status': 'ativo',
            'ativo': True,
            'disponivel': True,
            'prazo_entrega': 7
        }
        
        if tipo == 'multifocal':
            data['adicao_min'] = row['add_min'] if pd.notnull(row['add_min']) and row['add_min'] != 0 else 1.0
            data['adicao_max'] = row['add_max'] if pd.notnull(row['add_max']) and row['add_max'] != 0 else 3.0
        else:
            data['adicao_min'] = None
            data['adicao_max'] = None
            
        return data

    # Processar VS
    df_vs = pd.read_csv(path_vs)
    vs_data = [transform_row(row, 'visao_simples') for _, row in df_vs.iterrows()]
    
    # Processar Multi
    df_multi = pd.read_csv(path_multi)
    multi_data = [transform_row(row, 'multifocal') for _, row in df_multi.iterrows()]
    
    # Unificar e Salvar
    df_final = pd.DataFrame(vs_data + multi_data)
    
    # Garantir que todas as colunas da tabela existam (mesmo que nulas)
    # Pegando as colunas do df_final para manter ordem lógica
    df_final.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"Arquivo final gerado: {output_path} ({len(df_final)} lentes)")

if __name__ == "__main__":
    normalizar_so_blocos()
