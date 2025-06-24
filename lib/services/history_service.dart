import '../models/heart_rate_sample.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final List<HeartRateSample> _history = [];

  List<HeartRateSample> get history => List.unmodifiable(_history);

  void addSample(HeartRateSample sample) {
    _history.add(sample);
  }

  void clear() {
    _history.clear();
  }
}
