import pandas as pd
import os

files = [
    r"D:\OneDrive - Óticas Taty Mello\Grupo Mello\Tecnologia_da_Informação\CRM_ERP\banco_de_dados\lentes\tabelaslentes\Processado\brascor.xlsx",
    r"D:\OneDrive - Óticas Taty Mello\Grupo Mello\Tecnologia_da_Informação\CRM_ERP\banco_de_dados\lentes\tabelaslentes\Processado\style.xlsx",
    r"D:\OneDrive - Óticas Taty Mello\Grupo Mello\Tecnologia_da_Informação\CRM_ERP\banco_de_dados\lentes\tabelaslentes\Processado\so_blocos.xlsx"
]

for file_path in files:
    if os.path.exists(file_path):
        print(f"\n--- Analisando: {os.path.basename(file_path)} ---")
        try:
            df = pd.read_excel(file_path, nrows=5)
            print("Colunas encontradas:")
            print(df.columns.tolist())
            print("\nPrimeiras 5 linhas:")
            print(df.to_string(index=False))
        except Exception as e:
            print(f"Erro ao ler {file_path}: {e}")
    else:
        print(f"Arquivo não encontrado: {file_path}")
