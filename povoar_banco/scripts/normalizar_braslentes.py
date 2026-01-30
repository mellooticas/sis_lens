import pandas as pd
import uuid
import os

def normalizar_braslentes():
    folder = r'D:\projetos\sis_lens\povoar_banco\csv'
    input_path = os.path.join(folder, 'bras_lentes_2026.xlsx')
    output_path = os.path.join(folder, 'banco', 'braslentes_final.csv')
    
    fornecedor_id = '43721f5b-4f4a-4a75-bb34-6e8b373c5948' # BRASLENTES
    marca_id = '87915598-a669-4f7f-8551-fa7259f6358c'      # BRASLENTES (Marca)

    def calcular_preco_venda(custo):
        if custo <= 0: return 0.0
        venda = max(custo * 3.0, 250.0 + (custo * 0.1))
        if venda > custo * 4.0:
            if custo > 100: venda = custo * 4.0
        return round(venda, 2)

    def parse_tratamentos(nome_produto):
        text = str(nome_produto).upper()
        res = {
            'ar': ' AR' in text or 'A.R.' in text or 'HMC' in text,
            'blue': 'BLUE' in text or 'ANTIBLUE' in text,
            'uv': 'UV' in text,
            'foto': 'FOTO' in text or 'TRANSITIONS' in text or 'FOTOSSENSÍVEL' in text
        }
        return res

    all_lentes = []
    xl = pd.ExcelFile(input_path)
    
    # Sheet VS
    if 'VS' in xl.sheet_names:
        df = pd.read_excel(xl, 'VS')
        for _, row in df.iterrows():
            preco = float(row['preco_custo'])
            if preco <= 0: continue
            
            traits = parse_tratamentos(row['produto'])
            indice = "{:.2f}".format(row['indice'])
            if indice == '1.49': indice = '1.50'
            
            material = 'POLICARBONATO' if 'POLICARBONATO' in str(row['produto']).upper() or indice == '1.59' else 'CR39'
            
            lente = {
                'id': str(uuid.uuid4()),
                'fornecedor_id': fornecedor_id,
                'marca_id': marca_id,
                'nome_lente': f"Braslentes {row['produto']}",
                'nome_comercial': row['produto'],
                'tipo_lente': 'visao_simples',
                'material': material,
                'indice_refracao': indice,
                'categoria': 'economica',
                'tratamento_antirreflexo': traits['ar'],
                'tratamento_antirrisco': traits['ar'] or material == 'POLICARBONATO',
                'tratamento_uv': traits['uv'] or material == 'POLICARBONATO' or float(indice) >= 1.6,
                'tratamento_blue_light': traits['blue'],
                'tratamento_fotossensiveis': 'fotocromático' if traits['foto'] else 'nenhum',
                'esferico_min': row['esf_min'],
                'esferico_max': row['esf_max'],
                'cilindrico_min': row['cil_min'],
                'cilindrico_max': row['cil_max'],
                'adicao_min': 0.0,
                'adicao_max': 0.0,
                'preco_custo': preco,
                'custo_base': preco,
                'preco_tabela': calcular_preco_venda(preco),
                'ativo': True, 'disponivel': True, 'prazo_entrega': 7
            }
            all_lentes.append(lente)

    # Sheet multi
    if 'multi' in xl.sheet_names:
        df = pd.read_excel(xl, 'multi')
        for _, row in df.iterrows():
            preco = float(row['preco_custo'])
            if preco <= 0: continue
            
            traits = parse_tratamentos(row['produto'])
            indice = "{:.2f}".format(row['indice'])
            
            lente = {
                'id': str(uuid.uuid4()),
                'fornecedor_id': fornecedor_id,
                'marca_id': marca_id,
                'nome_lente': f"Braslentes {row['produto']}",
                'nome_comercial': row['produto'],
                'tipo_lente': 'multifocal',
                'material': 'CR39',
                'indice_refracao': indice,
                'categoria': 'economica',
                'tratamento_antirreflexo': traits['ar'],
                'tratamento_antirrisco': traits['ar'],
                'tratamento_uv': traits['uv'] or float(indice) >= 1.6,
                'tratamento_blue_light': traits['blue'],
                'tratamento_fotossensiveis': 'transitions' if 'TRANSITIONS' in str(row['produto']).upper() else ('fotocromático' if traits['foto'] else 'nenhum'),
                'esferico_min': row['esf_min'],
                'esferico_max': row['esf_max'],
                'cilindrico_min': -4.0, # Padrao multi se nao tiver
                'cilindrico_max': 0.0,
                'adicao_min': row['adicao_min'] if pd.notnull(row['adicao_min']) and row['adicao_min'] != 0 else 1.0,
                'adicao_max': row['adicao_max'] if pd.notnull(row['adicao_max']) and row['adicao_max'] != 0 else 3.0,
                'preco_custo': preco,
                'custo_base': preco,
                'preco_tabela': calcular_preco_venda(preco),
                'ativo': True, 'disponivel': True, 'prazo_entrega': 7
            }
            all_lentes.append(lente)

    # Sheet coloridas
    if 'coloridas' in xl.sheet_names:
        df = pd.read_excel(xl, 'coloridas')
        for _, row in df.iterrows():
            preco = float(row['preco_custo'])
            if preco <= 0: continue
            
            material = 'POLICARBONATO' if 'POLICARBONATO' in str(row['produto']).upper() else 'CR39'
            
            lente = {
                'id': str(uuid.uuid4()),
                'fornecedor_id': fornecedor_id,
                'marca_id': marca_id,
                'nome_lente': f"Braslentes Solar {row['produto']}",
                'nome_comercial': row['produto'],
                'tipo_lente': 'visao_simples',
                'material': material,
                'indice_refracao': '1.50' if material == 'CR39' else '1.59',
                'categoria': 'economica',
                'tratamento_antirreflexo': False,
                'tratamento_antirrisco': material == 'POLICARBONATO',
                'tratamento_uv': True,
                'tratamento_blue_light': False,
                'tratamento_fotossensiveis': 'nenhum',
                'esferico_min': 0.0,
                'esferico_max': 0.0,
                'cilindrico_min': 0.0,
                'cilindrico_max': 0.0,
                'adicao_min': 0.0,
                'adicao_max': 0.0,
                'preco_custo': preco,
                'custo_base': preco,
                'preco_tabela': calcular_preco_venda(preco),
                'ativo': True, 'disponivel': True, 'prazo_entrega': 7
            }
            all_lentes.append(lente)

    df_final = pd.DataFrame(all_lentes)
    df_final.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"Normalização BRASLENTES concluída: {output_path} ({len(df_final)} lentes)")

if __name__ == "__main__":
    normalizar_braslentes()
