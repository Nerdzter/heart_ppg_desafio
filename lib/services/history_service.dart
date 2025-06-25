import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
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

 Future<String> exportHistoryToCSV() async {
    final buffer = StringBuffer();
    buffer.writeln('timestamp;bpm');
    for (final sample in _history) {
      buffer.writeln('${sample.timestamp.toIso8601String()};${sample.bpm.toStringAsFixed(0)}');
    }

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/bpm_history.csv';
    final file = File(path);

    // 🔥 Certifique-se de importar 'dart:convert'!
    await file.writeAsString(buffer.toString(), encoding: utf8);

    return path;
  }
}