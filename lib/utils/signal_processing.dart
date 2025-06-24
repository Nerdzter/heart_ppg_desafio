import 'dart:math';

// Filtro simples passa-baixa (moving average) para suavizar o sinal
List<double> smoothSignal(List<double> signal, {int windowSize = 5}) {
  if (signal.length < windowSize) return List.from(signal);
  List<double> smoothed = [];
  for (int i = 0; i < signal.length; i++) {
    int start = max(0, i - windowSize + 1);
    double avg = signal.sublist(start, i + 1).reduce((a, b) => a + b) / (i - start + 1);
    smoothed.add(avg);
  }
  return smoothed;
}

// Detecção de picos básicos (máximos locais)
List<int> detectPeaks(List<double> signal, {double threshold = 0.5, int minDistance = 15}) {
  List<int> peaks = [];
  for (int i = 1; i < signal.length - 1; i++) {
    if (signal[i] > signal[i - 1] && signal[i] > signal[i + 1] && signal[i] > threshold) {
      if (peaks.isEmpty || (i - peaks.last) > minDistance) {
        peaks.add(i);
      }
    }
  }
  return peaks;
}

// Calcula BPM a partir dos picos detectados
double? calculateBPM(List<double> signal, String formatGroup) {
  if (signal.length < 64) return null;
  final smoothed = smoothSignal(signal, windowSize: 5);
  final double baseline = smoothed.reduce((a, b) => a + b) / smoothed.length;
  final threshold = baseline * 1.02; // ajuste fino conforme teste
  final peaks = detectPeaks(smoothed, threshold: threshold);

  if (peaks.length < 2) return null;

  // Calcula intervalos entre picos (frames)
  List<int> intervals = [];
  for (int i = 1; i < peaks.length; i++) {
    intervals.add(peaks[i] - peaks[i - 1]);
  }
  if (intervals.isEmpty) return null;

  double avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;

  // Supondo ~30 FPS (frames por segundo)
  double fps = 30.0;
  // Alguns dispositivos Android podem variar (faça ajuste fino em device real se necessário)

  double bpm = 60.0 * fps / avgInterval;
  return bpm;
}
