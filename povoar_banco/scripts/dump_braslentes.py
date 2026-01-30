import pandas as pd
import os

path = r'd:\projetos\sis_lens\povoar_banco\csv\bras_lentes_2026.xlsx'
xl = pd.ExcelFile(path)
output = []
for sheet in xl.sheet_names:
    df = pd.read_excel(path, sheet_name=sheet)
    output.append(f"Sheet: {sheet}")
    output.append(f"Columns: {df.columns.tolist()}")
    output.append(df.head(5).to_string())
    output.append("-" * 50)

with open(r'd:\projetos\sis_lens\povoar_banco\csv\bras_lentes_structure.txt', 'w', encoding='utf-8') as f:
    f.write("\n".join(output))
