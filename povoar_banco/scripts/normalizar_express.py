import pandas as pd
import uuid
import os

def normalizar_express():
    path_vs = r'D:\projetos\sis_lens\povoar_banco\csv\express_vs_raw.csv'
    path_solares = r'D:\projetos\sis_lens\povoar_banco\csv\express_solares_raw.csv'
    output_path = r'D:\projetos\sis_lens\povoar_banco\csv\banco\express_final.csv'
    
    # ID do fornecedor Express (baseado no diagnóstico inicial)
    # 8eb9498c-3d99-4d26-bb8c-e503f97ccf2c
    fornecedor_id = '8eb9498c-3d99-4d26-bb8c-e503f97ccf2c'
    # Marca EXPRESS
    marca_id = '7bf35e08-7a88-4547-a06a-a6ce62fcc827'
    
    def calcular_preco_venda(custo):
        if custo <= 0: return 0.0
        venda = max(custo * 3.0, 250.0 + (custo * 0.1))
        if venda > custo * 4.0:
            if custo > 100: venda = custo * 4.0
        return round(venda, 2)

    def transform_row(row):
        nome = str(row['produto'])
        material_raw = str(row['material']).upper()
        
        # Mapeamento de Material
        if 'POLI' in material_raw:
            material = 'POLICARBONATO'
        elif 'ALTO_INDICE' in material_raw:
            material = 'HIGH_INDEX'
        else:
            material = 'CR39'
            
        # Fotossensível
        foto_raw = str(row['foto']).upper()
        foto = 'fotocromático' if foto_raw == 'SIM' else 'nenhum'
        
        # Tratamentos
        has_ar = str(row['ar']).upper() == 'SIM'
        has_blue = str(row['blue']).upper() == 'SIM'
        
        # Lentes solares (pelo nome ou pelo campo observações)
        is_polarizada = 'POLARIZADO' in str(row['observacoes']).upper() or 'POLARIZADO' in nome.upper()
        
        # UV400 automático para Poli, High Index ou com AR/Blue
        has_uv = material == 'POLICARBONATO' or material == 'HIGH_INDEX' or float(row['indice']) >= 1.6 or has_blue
        
        # Mapeamento de Índices
        idx = float(row['indice'])
        if idx == 1.5: indice = "1.50"
        elif idx == 1.56: indice = "1.56"
        elif idx == 1.59: indice = "1.59"
        elif idx == 1.61: indice = "1.61"
        elif idx == 1.67: indice = "1.67"
        elif idx == 1.7 or idx == 1.70: indice = "1.74" # Mapeando 1.70 para 1.74 conforme padrão adotado
        elif idx == 1.74: indice = "1.74"
        else: indice = "{:.2f}".format(idx)

        return {
            'id': str(uuid.uuid4()),
            'fornecedor_id': fornecedor_id,
            'marca_id': marca_id,
            'nome_lente': f"Express {nome}",
            'nome_comercial': f"Express {nome}",
            'tipo_lente': 'visao_simples',
            'material': material,
            'indice_refracao': indice,
            'categoria': 'economica',
            'tratamento_antirreflexo': has_ar,
            'tratamento_antirrisco': True if has_ar or material == 'POLICARBONATO' else False,
            'tratamento_uv': has_uv,
            'tratamento_blue_light': has_blue,
            'tratamento_fotossensiveis': foto,
            'fotossensivel': foto,
            'ar': has_ar,
            'blue': has_blue,
            'uv400': has_uv,
            'antirrisco': True if has_ar or material == 'POLICARBONATO' else False,
            'polarizado': is_polarizada,
            'esferico_min': row['esf_min'],
            'esferico_max': row['esf_max'],
            'cilindrico_min': row['cil_min'],
            'cilindrico_max': row['cil_max'],
            'grau_esferico_min': row['esf_min'],
            'grau_esferico_max': row['esf_max'],
            'grau_cilindrico_min': row['cil_min'],
            'grau_cilindrico_max': row['cil_max'],
            'preco_custo': row['valor'],
            'custo_base': row['valor'],
            'preco_tabela': calcular_preco_venda(float(row['valor'])),
            'status': 'ativo',
            'ativo': True,
            'disponivel': True,
            'prazo_entrega': 3,
            'adicao_min': None,
            'adicao_max': None
        }

    # Processar VS e Solares
    df_vs = pd.read_csv(path_vs)
    df_sol = pd.read_csv(path_solares)
    
    vs_data = [transform_row(row) for _, row in df_vs.iterrows()]
    sol_data = [transform_row(row) for _, row in df_sol.iterrows()]
    
    df_final = pd.DataFrame(vs_data + sol_data)
    df_final.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"Normalização Express concluída: {output_path} ({len(df_final)} lentes)")

if __name__ == "__main__":
    normalizar_express()
