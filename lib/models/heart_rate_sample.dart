class HeartRateSample {
  final double bpm;
  final DateTime timestamp;
  final List<double> signal;

  HeartRateSample({
    required this.bpm,
    required this.timestamp,
    required this.signal,
  });
}
