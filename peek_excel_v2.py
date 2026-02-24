import pandas as pd
import os
import sys

# Ensure UTF-8 output
if sys.platform == "win32":
    import codecs
    sys.stdout = codecs.getwriter("utf-8")(sys.stdout.detach())

folder = r"D:\OneDrive - Óticas Taty Mello\Grupo Mello\Tecnologia_da_Informação\CRM_ERP\banco_de_dados\lentes\tabelaslentes\Processado"
files = [f for f in os.listdir(folder) if f.endswith('.xlsx')]

for file_name in files:
    file_path = os.path.join(folder, file_name)
    print(f"\nFILE: {file_name}")
    try:
        df = pd.read_excel(file_path, nrows=3)
        print(f"COLUMNS: {df.columns.tolist()}")
        # Check specific range columns if they exist
        range_cols = [c for c in df.columns if any(x in c.lower() for x in ['esf', 'sph', 'cil', 'cyl', 'min', 'max'])]
        if range_cols:
            print(f"RANGE_COLS_DATA:\n{df[range_cols].to_string(index=False)}")
        else:
            print("No range columns identified.")
    except Exception as e:
        print(f"ERROR: {e}")
