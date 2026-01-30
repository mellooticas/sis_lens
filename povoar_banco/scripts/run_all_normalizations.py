import os
import subprocess

scripts_dir = r'd:\projetos\sis_lens\povoar_banco\scripts'
scripts = [
    'normalizar_brascor.py',
    'normalizar_hoya.py',
    'normalizar_polylux.py',
    'normalizar_style.py',
    'normalizar_sygma.py',
    'normalizar_express.py',
    'normalizar_high_vision.py',
    'normalizar_so_blocos.py',
    'normalizar_braslentes.py'
]

for s in scripts:
    path = os.path.join(scripts_dir, s)
    if os.path.exists(path):
        print(f"Running {s}...")
        subprocess.run(['python', path], check=True)
    else:
        print(f"Skipping {s} (not found)")

print("All normalization scripts executed successfully!")
