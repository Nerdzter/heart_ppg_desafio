import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../utils/signal_processing.dart';
import '../widgets/heart_rate_chart.dart';
import 'history_service.dart';
import '../models/heart_rate_sample.dart';


class PPGService extends StatefulWidget {
  final CameraController controller;

  const PPGService({Key? key, required this.controller}) : super(key: key);

  @override
  State<PPGService> createState() => _PPGServiceState();
}

class _PPGServiceState extends State<PPGService> {
  List<double> redValues = [];
  double bpm = 0;
  bool _isStreaming = false;
  bool measuring = false;

  @override
  void dispose() {
    _stopMeasurement();
    super.dispose();
  }

  void _startMeasurement() {
    setState(() {
      measuring = true;
      redValues.clear();
      bpm = 0;
    });

    if (!_isStreaming) {
      _isStreaming = true;
      widget.controller.startImageStream((CameraImage image) {
        double avgRed = _calculateAvgRed(image);
        setState(() {
          redValues.add(avgRed);
          if (redValues.length > 256) {
            redValues.removeAt(0);
          }
        });

        if (redValues.length >= 128) {
          double? calcBpm = calculateBPM(redValues, image.format.group.toString());
          if (calcBpm != null && calcBpm > 30 && calcBpm < 220) {
            setState(() {
              bpm = calcBpm;
            });
          }
        }
      });
    }
  }

  Future<void> _stopMeasurement() async {
    if (_isStreaming) {
      try {
        await widget.controller.stopImageStream();
      } catch (_) {}
      _isStreaming = false;
    }
    // Salva histórico se houver leitura válida
    if (bpm > 0 && redValues.isNotEmpty) {
      final sample = HeartRateSample(
        bpm: bpm,
        timestamp: DateTime.now(),
        signal: List.from(redValues),
      );
      HistoryService().addSample(sample);
    }
    setState(() {
      measuring = false;
      bpm = 0;
    });
  }
  
  double _calculateAvgRed(CameraImage image) {
    if (image.format.group == ImageFormatGroup.yuv420) {
      final plane = image.planes[0];
      final data = plane.bytes;
      int sum = 0;
      for (var i = 0; i < data.length; i += 2) {
        sum += data[i];
      }
      return sum / (data.length ~/ 2);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      final data = image.planes[0].bytes;
      int sum = 0, count = 0;
      for (int i = 0; i < data.length; i += 4) {
        sum += data[i + 2];
        count++;
      }
      return count > 0 ? sum / count : 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medição PPG'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            measuring
                ? 'Coloque o dedo sobre a câmera e aguarde...'
                : 'Pronto para medir!',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              measuring
                  ? bpm > 0
                      ? '${bpm.toStringAsFixed(0)} BPM'
                      : 'Calculando...'
                  : '-- BPM',
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 140,
            child: HeartRateChart(data: redValues),
          ),
          const SizedBox(height: 32),
          measuring
              ? ElevatedButton(
                  onPressed: _stopMeasurement,
                  child: const Text('Parar Medição'),
                )
              : ElevatedButton(
                  onPressed: _startMeasurement,
                  child: const Text('Iniciar Medição'),
                ),
        ],
      ),
    );
  }
}
