import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import find_peaks, butter, filtfilt, welch
import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import os

# --- ANÁLISE E GERAÇÃO DOS GRÁFICOS ---

# 1. Ler e limpar dados
df = pd.read_csv('ppg_history.csv')
df[['timestamp', 'ppg']] = df['timestamp;ppg'].str.split(';', expand=True)
df['timestamp'] = pd.to_datetime(df['timestamp'])
df['ppg'] = pd.to_numeric(df['ppg'])
df = df.dropna()

# 2. Estatísticas básicas
ppg_mean = df['ppg'].mean()
ppg_std = df['ppg'].std()
ppg_min = df['ppg'].min()
ppg_max = df['ppg'].max()

# 3. Gráfico do PPG bruto
plt.figure()
plt.plot(df['timestamp'], df['ppg'])
plt.title('PPG Bruto ao longo do tempo')
plt.xlabel('Tempo')
plt.ylabel('PPG')
plt.tight_layout()
plt.savefig('ppg_bruto.png')
plt.close()

# 4. Filtragem do Sinal (Moving Average)
window_size = 15
df['ppg_filtered'] = df['ppg'].rolling(window=window_size, center=True).mean()

plt.figure()
plt.plot(df['timestamp'], df['ppg'], alpha=0.5, label='Bruto')
plt.plot(df['timestamp'], df['ppg_filtered'], label='Filtrado (Moving Average)')
plt.title('PPG Bruto x Filtrado')
plt.xlabel('Tempo')
plt.ylabel('PPG')
plt.legend()
plt.tight_layout()
plt.savefig('ppg_filtrado.png')
plt.close()

# 5. Detecção de picos (batimentos)
distance = int(0.5 / ((df['timestamp'][1] - df['timestamp'][0]).total_seconds()))  # ~0.5s distância mínima entre batidas
peaks, _ = find_peaks(df['ppg_filtered'].fillna(df['ppg_filtered'].mean()), distance=distance)
df['peaks'] = 0
df.loc[peaks, 'peaks'] = 1

plt.figure()
plt.plot(df['timestamp'], df['ppg_filtered'], label='Filtrado')
plt.scatter(df['timestamp'][peaks], df['ppg_filtered'][peaks], color='red', label='Batimentos')
plt.title('Detecção de Batimentos (Picos)')
plt.xlabel('Tempo')
plt.ylabel('PPG')
plt.legend()
plt.tight_layout()
plt.savefig('ppg_picos.png')
plt.close()

# 6. Calcular BPM ao longo do tempo
peak_times = df['timestamp'][peaks]
rr_intervals = peak_times.diff().dt.total_seconds().dropna()
bpm = 60 / rr_intervals
bpm_times = peak_times.iloc[1:]

plt.figure()
plt.plot(bpm_times, bpm)
plt.title('BPM ao longo do tempo')
plt.xlabel('Tempo')
plt.ylabel('BPM')
plt.tight_layout()
plt.savefig('bpm_tempo.png')
plt.close()

# 7. Análise de coerência cardíaca (HRV Frequência)
window_seconds = 60
sample_rate = 1 / (df['timestamp'].diff().dt.total_seconds().median())
window_samples = int(window_seconds * sample_rate)
coherence_marks = []
for i in range(0, len(df)-window_samples, window_samples):
    segment = df['ppg_filtered'].iloc[i:i+window_samples].dropna()
    if len(segment) > 10:
        f, pxx = welch(segment, fs=sample_rate)
        coherence_band = pxx[(f >= 0.04) & (f <= 0.26)].sum()
        total_power = pxx.sum()
        ratio = coherence_band / total_power if total_power > 0 else 0
        if ratio > 0.7:
            coherence_marks.append((df['timestamp'].iloc[i], df['timestamp'].iloc[i+window_samples-1]))

plt.figure()
plt.plot(df['timestamp'], df['ppg_filtered'], label='PPG Filtrado')
for start, end in coherence_marks:
    plt.axvspan(start, end, color='green', alpha=0.3, label='Coerência' if start==coherence_marks[0][0] else None)
plt.title('Coerência Cardíaca (faixas marcadas)')
plt.xlabel('Tempo')
plt.ylabel('PPG')
plt.legend()
plt.tight_layout()
plt.savefig('coerencia_cardica.png')
plt.close()

# 8. Artefatos: Outliers (z-score > 3)
zscore = (df['ppg'] - ppg_mean) / ppg_std
artefatos = df[np.abs(zscore) > 3]

plt.figure()
plt.plot(df['timestamp'], df['ppg'], alpha=0.5, label='PPG Bruto')
plt.scatter(artefatos['timestamp'], artefatos['ppg'], color='red', label='Artefatos')
plt.title('Detecção de Artefatos')
plt.xlabel('Tempo')
plt.ylabel('PPG')
plt.legend()
plt.tight_layout()
plt.savefig('artefatos.png')
plt.close()

# 9. Histograma do PPG
plt.figure()
plt.hist(df['ppg'], bins=50)
plt.title('Histograma dos valores de PPG')
plt.xlabel('PPG')
plt.ylabel('Frequência')
plt.tight_layout()
plt.savefig('histograma_ppg.png')
plt.close()

# --- RELATÓRIO AUTOMÁTICO ---
relatorio = f"""
RELATÓRIO DE ANÁLISE PPG

1. Estatísticas Básicas
- Média: {ppg_mean:.2f}
- Desvio padrão: {ppg_std:.2f}
- Mínimo: {ppg_min:.2f}
- Máximo: {ppg_max:.2f}

2. Interpretação dos Gráficos:
- O gráfico bruto revela oscilações naturais do sinal PPG, além de artefatos visíveis como saltos abruptos.
- O gráfico filtrado suaviza ruídos, permitindo melhor percepção da dinâmica real do pulso.
- Os picos (batimentos) são identificados automaticamente; a série BPM mostra a frequência cardíaca ao longo do tempo.
- As faixas verdes nos gráficos marcam períodos de coerência cardíaca, normalmente associados a respiração ritmada e estados de relaxamento.
- Artefatos (outliers) são destacados em vermelho para alertar sobre leituras incomuns.
- O histograma mostra a distribuição dos valores de PPG, útil para detectar viés, ruído e anomalias.

3. Recomendações
- Considere descartar trechos de sinal com saltos abruptos antes de análises clínicas.
- Refine thresholds de coerência conforme padrão do usuário/sensor.
- Integre variabilidade de intervalo RR para análises mais avançadas de HRV.
- Use períodos de coerência cardíaca como referência para biofeedback ou treinos de relaxamento.

4. Períodos de Coerência Cardíaca detectados:
"""
if len(coherence_marks) == 0:
    relatorio += "\nNenhum período de coerência cardíaca detectado."
else:
    for idx, (start, end) in enumerate(coherence_marks, 1):
        relatorio += f"\n - Período {idx}: {start} até {end}"

# --- DASHBOARD TKINTER ---

def show_image(img_path, label):
    img = Image.open(img_path)
    img = img.resize((720, 360), Image.Resampling.LANCZOS)
    img_tk = ImageTk.PhotoImage(img)
    label.img = img_tk
    label.config(image=img_tk)

graph_files = [
    ("PPG Bruto", "ppg_bruto.png"),
    ("PPG Filtrado", "ppg_filtrado.png"),
    ("Batimentos", "ppg_picos.png"),
    ("BPM", "bpm_tempo.png"),
    ("Coerência Cardíaca", "coerencia_cardica.png"),
    ("Artefatos", "artefatos.png"),
    ("Histograma", "histograma_ppg.png"),
]

root = tk.Tk()
root.title("Dashboard PPG - Análise Completa")
root.geometry("820x500")

tabs = ttk.Notebook(root)
tabs.pack(expand=1, fill='both')

for nome, arquivo in graph_files:
    frame = ttk.Frame(tabs)
    tabs.add(frame, text=nome)
    label = tk.Label(frame)
    label.pack(pady=10)
    if os.path.exists(arquivo):
        show_image(arquivo, label)
    else:
        label.config(text=f"Arquivo {arquivo} não encontrado.")

frame_relatorio = ttk.Frame(tabs)
tabs.add(frame_relatorio, text="Relatório")

text_relatorio = tk.Text(frame_relatorio, wrap='word', font=("Consolas", 11))
text_relatorio.insert('1.0', relatorio)
text_relatorio.config(state='disabled')
text_relatorio.pack(expand=1, fill='both', padx=10, pady=10)

root.mainloop()
