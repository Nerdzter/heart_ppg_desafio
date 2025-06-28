import 'dart:math';
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';


// Filtro Passa Alta (IIR 1ª ordem, digital)
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

// Filtro passa-baixa (média móvel)
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

// Detecção de picos
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

// Auto-correlação (para periodicidade)
List<double> autocorrelation(List<double> signal, {int maxLag = 50}) {
  List<double> result = [];
  double mean = signal.reduce((a, b) => a + b) / signal.length;
  for (int lag = 0; lag < maxLag; lag++) {
    double sum = 0;
    for (int i = 0; i < signal.length - lag; i++) {
      sum += (signal[i] - mean) * (signal[i + lag] - mean);
    }
    result.add((signal.length - lag) > 0 ? sum / (signal.length - lag) : 0.0);
  }
  return result;
}

// FFT para análise de frequência
List<double> computeFFT(List<double> signal) {
  // Pad para potência de 2 se necessário
  int n = pow(2, (log(signal.length) / log(2)).ceil()).toInt();
  var sigArr = Array(signal + List.filled(n - signal.length, 0.0));

  // Converte Array (real) para ArrayComplex
  var sigArrComplex = arrayToComplexArray(sigArr);

  // Calcula o espectro
  var spectrum = fft(sigArrComplex);

  // Pega a magnitude de cada ponto (módulo)
  var magnitude = arrayComplexAbs(spectrum);

  return magnitude.toList();
}

// Cálculo de BPM via picos
double? calculateBPM(List<double> signal, String formatGroup,
    {double? sampleRate, bool useHighPass = false, HighPassFilter? highPass}) {
  if (signal.length < 64) return null;
  double fps = sampleRate ?? 30.0;

  List<double> toProcess = List.from(signal);
  if (useHighPass && highPass != null) {
    toProcess = highPass.filterList(toProcess);
  }

  final smoothed = smoothSignal(toProcess, windowSize: 5);
  final double baseline = smoothed.reduce((a, b) => a + b) / smoothed.length;
  final threshold = baseline * 1.02;
  final peaks = detectPeaks(smoothed, threshold: threshold);

  if (peaks.length < 2) return null;

  List<int> intervals = [];
  for (int i = 1; i < peaks.length; i++) {
    intervals.add(peaks[i] - peaks[i - 1]);
  }
  if (intervals.isEmpty) return null;

  double avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
  double bpm = 60.0 * fps / avgInterval;
  return bpm;
}

// BPM por autocorrelação
double? calculateBPMByAutocorr(List<double> signal, {double sampleRate = 30.0, int minLag = 12, int maxLag = 60}) {
  if (signal.length < maxLag + 1) return null;
  var autocorr = autocorrelation(signal, maxLag: maxLag);
  // Ignora lag 0, pega pico após minLag
  double maxValue = autocorr.sublist(minLag).reduce(max);
  int bestLag = minLag + autocorr.sublist(minLag).indexOf(maxValue);
  if (bestLag == 0) return null;
  double bpm = 60.0 * sampleRate / bestLag;
  return bpm;
}
