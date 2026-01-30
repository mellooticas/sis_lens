import pandas as pd
import os

folder = r'd:\projetos\sis_lens\povoar_banco\csv'
files = []
for root, dirs, f_names in os.walk(folder):
    for f in f_names:
        if f.endswith('.csv') or f.endswith('.xlsx'):
            files.append(os.path.join(root, f))

found = []
target = 7115.0

for f in files:
    try:
        if f.endswith('.csv'):
            df = pd.read_csv(f)
        else:
            df = pd.read_excel(f)
        
        # Search in all numeric columns
        for col in df.select_dtypes(include=['number']).columns:
            matches = df[df[col] == target]
            if not matches.empty:
                for _, row in matches.iterrows():
                    found.append(f"File: {f} | Col: {col} | Row: {row.to_dict()}")
        
        # Search as string just in case
        for col in df.select_dtypes(include=['object']).columns:
            matches = df[df[col].astype(str).str.contains('7115', na=False)]
            if not matches.empty:
                for _, row in matches.iterrows():
                    found.append(f"File: {f} | Col: {col} | Content: {row[col]}")
                    
    except Exception as e:
        continue

if found:
    for item in found:
        print(item)
else:
    print("Valor 7115 não encontrado.")
