import pandas as pd
import os

files = ['brascor.xlsx', 'hoya.xlsx', 'polilux.xlsx', 'sygma.xlsx']
folder = r'D:\projetos\sis_lens\povoar_banco\csv'

output_info = []

for f in files:
    path = os.path.join(folder, f)
    if os.path.exists(path):
        output_info.append(f"\n--- Analisando: {f} ---")
        try:
            xl = pd.ExcelFile(path)
            output_info.append(f"Abas: {xl.sheet_names}")
            for sheet in xl.sheet_names:
                df = pd.read_excel(path, sheet_name=sheet, nrows=5)
                output_info.append(f"\nSheet [{sheet}] - Colunas:")
                output_info.append(str(df.columns.tolist()))
                output_info.append("Primeiras linhas:")
                output_info.append(df.head(2).to_string())
        except Exception as e:
            output_info.append(f"Erro ao ler {f}: {e}")
    else:
        output_info.append(f"Arquivo não encontrado: {path}")

with open(os.path.join(folder, 'excel_structure.txt'), 'w', encoding='utf-8') as f_out:
    f_out.write("\n".join(output_info))
print("Estrutura salva em excel_structure.txt")
