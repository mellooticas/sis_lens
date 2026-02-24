import pandas as pd
import os

folder = r"D:\OneDrive - Óticas Taty Mello\Grupo Mello\Tecnologia_da_Informação\CRM_ERP\banco_de_dados\lentes\tabelaslentes\Processado"
files = [f for f in os.listdir(folder) if f.endswith('.xlsx')]

output_summary = []

for file_name in files:
    file_path = os.path.join(folder, file_name)
    try:
        df = pd.read_excel(file_path, nrows=2)
        cols = df.columns.tolist()
        output_summary.append(f"--- {file_name} ---")
        output_summary.append(f"Cols: {cols}")
        output_summary.append(df.to_csv(index=False))
    except Exception as e:
        output_summary.append(f"Error {file_name}: {e}")

with open("excel_final_report.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output_summary))
