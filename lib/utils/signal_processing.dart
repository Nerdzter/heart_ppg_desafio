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
double? calculateBPM(
  List<double> signal,
  String formatGroup, {
  double sampleRate = 30.0, // Agora pode ser passado!
}) {
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

  // Agora usa o sampleRate fornecido!
  double bpm = 60.0 * sampleRate / avgInterval;
  return bpm;
}

// Filtro Passa-Alta (IIR simples)
class HighPassFilter {
  final double cutoffHz;
  final double sampleRate;
  double? _lastX, _lastY;
  late double _alpha;

  HighPassFilter({required this.cutoffHz, required this.sampleRate}) {
    final rc = 1.0 / (2 * pi * cutoffHz);
    _alpha = rc / (rc + (1.0 / sampleRate));
  }

  double filter(double x) {
    double y = (_lastY ?? 0) + _alpha * ((x - (_lastX ?? x)));
    _lastX = x;
    _lastY = y;
    return y;
  }

  List<double> filterList(List<double> signal) {
    _lastX = null;
    _lastY = null;
    return signal.map((x) => filter(x)).toList();
  }
}
