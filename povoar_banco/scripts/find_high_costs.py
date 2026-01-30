import pandas as pd
import os

folder = r'd:\projetos\sis_lens\povoar_banco\csv\banco'
files = [f for f in os.listdir(folder) if f.endswith('.csv')]
found = []

for f in files:
    try:
        df = pd.read_csv(os.path.join(folder, f))
        # Procurando custos suspeitos (acima de 2000 já é muito raro para custo)
        high_cost = df[df['preco_custo'] > 1500]
        if not high_cost.empty:
            for _, row in high_cost.iterrows():
                found.append({
                    'arquivo': f,
                    'lente': row['nome_lente'],
                    'custo': row['preco_custo'],
                    'venda': row['preco_tabela']
                })
    except:
        continue

if found:
    print(f"{'ARQUIVO':<20} | {'LENTE':<40} | {'CUSTO':<10} | {'VENDA':<10}")
    print("-" * 90)
    for filter in found:
        print(f"{filter['arquivo']:<20} | {filter['lente'][:40]:<40} | {filter['custo']:<10.2f} | {filter['venda']:<10.2f}")
else:
    print("Nenhuma lente encontrada com custo acima de R$ 3.000,00.")
