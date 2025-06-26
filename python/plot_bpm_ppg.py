import matplotlib.pyplot as plt
from matplotlib.dates import DateFormatter
from datetime import datetime
from scipy.signal import find_peaks

# --------- Lê dados ---------
file_path = "bpm_history.csv"
with open(file_path, "r") as f:
    lines = f.readlines()

data = []
for line in lines[1:]:
    if not line.startswith("20"):
        continue
    parts = line.strip().split(";")
    if len(parts) < 3:
        continue
    timestamp = parts[0]
    try:
        bpm = float(parts[1].replace(",", "."))
        ppg_values = [float(x.replace(",", ".")) for x in parts[2].split(",")]
        data.append({"timestamp": timestamp, "bpm": bpm, "ppg": ppg_values})
    except Exception:
        continue

timestamps = [datetime.fromisoformat(entry["timestamp"]) for entry in data]
bpms = [entry["bpm"] for entry in data]
ex_ppg = data[0]["ppg"]

# --------- Detecção de picos no PPG ---------
peaks, _ = find_peaks(ex_ppg, distance=10, prominence=0.1)

# --------- Estilo e Gráfico ---------
plt.rcParams.update({
    "font.family": "DejaVu Sans",
    "axes.labelsize": 15,
    "axes.titlesize": 16,
    "legend.fontsize": 13
})
fig, (ax1, ax2) = plt.subplots(
    2, 1, figsize=(16, 8),
    gridspec_kw={"height_ratios": [2, 1]},
    sharex=False
)
fig.patch.set_facecolor('#f7fafc')

# --------- Título Global separado ---------
fig.suptitle(
    "Painel Biométrico Healthtech: BPM & Sinal PPG com Detecção Automática de Batimentos",
    fontsize=21, fontweight="bold", color="#1a273a", y=1.05
)

# --------- BPM x Tempo ---------
ax1.plot(
    timestamps, bpms,
    marker='o', markersize=8, linewidth=2.7,
    color="#157ab6", markerfacecolor='#50e3c2',
    label="BPM", alpha=0.94, zorder=3
)
ax1.set_title("Frequência Cardíaca ao Longo do Tempo", loc='left', pad=13, fontweight='bold')
ax1.set_ylabel("Batimentos por Minuto (BPM)")
ax1.grid(True, linestyle="--", linewidth=1, alpha=0.10, axis='y')
ax1.set_facecolor("#fbfcfe")
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)
ax1.xaxis.set_major_formatter(DateFormatter('%d/%m %H:%M:%S'))
ax1.margins(y=0.16)
ax1.legend(loc="upper left", frameon=False, fontsize=13, handlelength=1.6)

# --------- Sinal PPG + picos ---------
samples = range(len(ex_ppg))
ax2.plot(
    samples, ex_ppg, color="#11b6a6", linewidth=2.1, label="PPG", alpha=0.93, zorder=2
)
ax2.fill_between(samples, ex_ppg, color="#b6fff2", alpha=0.21, zorder=1)
ax2.scatter(
    peaks, [ex_ppg[i] for i in peaks], color="#e31743", marker="X", s=75, label="Picos Cardíacos", zorder=4
)
ax2.set_title("Sinal PPG com Detecção Automática de Batimentos", loc='left', pad=11, fontweight='bold')
ax2.set_ylabel("PPG (a.u.)")
ax2.set_xlabel("Amostra")
ax2.grid(True, linestyle="--", linewidth=1, alpha=0.10)
ax2.set_facecolor("#fbfcfe")
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)
ax2.margins(y=0.13)
ax2.legend(loc="upper right", frameon=False, fontsize=13, handlelength=1.6)

# --------- Footer ---------
fig.text(
    0.012, 0.015, "Fonte: bpm_history.csv  ·  Visualização Nayderson · Pronto para publicação",
    ha='left', va='bottom', fontsize=12, color="#7a869a", alpha=0.78
)

plt.subplots_adjust(left=0.07, right=0.97, top=0.89, bottom=0.09, hspace=0.36)
plt.savefig("biotech_painel_final.png", dpi=300, bbox_inches="tight")
plt.savefig("biotech_painel_final.pdf", dpi=300, bbox_inches="tight")
plt.savefig("biotech_painel_final.svg", dpi=300, bbox_inches="tight")
plt.show()
