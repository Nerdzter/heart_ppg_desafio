import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../utils/signal_processing.dart';
import '../widgets/heart_rate_chart.dart';
import '../models/heart_rate_sample.dart';
import 'history_service.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PPGRecord {
  final DateTime timestamp;
  final double ppg;
  PPGRecord({required this.timestamp, required this.ppg});
}

class PPGService extends StatefulWidget {
  final CameraController controller;

  const PPGService({Key? key, required this.controller}) : super(key: key);

  @override
  State<PPGService> createState() => _PPGServiceState();
}

class _PPGServiceState extends State<PPGService> with SingleTickerProviderStateMixin {
  List<double> redValues = [];
  double bpm = 0;
  bool _isStreaming = false;
  bool measuring = false;
  late AnimationController _pulseController;

  List<PPGRecord> ppgRecords = [];
  Timer? _bpmTimer;

  Future<void> pedirPermissaoStorage() async {
    if (await Permission.manageExternalStorage.isGranted) return;
    await Permission.manageExternalStorage.request();
    await Permission.storage.request(); // redundante, mas pode ajudar para devices antigos
  }

  Future<void> exportarPPGCSV() async {
    await pedirPermissaoStorage();
    try {
      final directory = Directory('/storage/emulated/0/Download');
      final file = File('${directory.path}/ppg_history.csv');
      final buffer = StringBuffer();

      buffer.writeln('timestamp;ppg');
      for (final record in ppgRecords) {
        buffer.writeln('${record.timestamp.toIso8601String()};${record.ppg.toStringAsFixed(4)}');
      }

      await file.writeAsString(buffer.toString(), encoding: utf8);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exportado para Download! Compartilhando...')),
        );
        await Share.shareFiles([file.path], text: 'PPG bruto exportado!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar/compartilhar CSV: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 1,
      upperBound: 1.13,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _stopMeasurement();
    _pulseController.dispose();
    super.dispose();
  }

  void _startMeasurement() {
    setState(() {
      measuring = true;
      redValues.clear();
      ppgRecords.clear();
      bpm = 0;
    });

    // NÃO precisa mais do Timer.periodic!
    // Toda gravação será feita no frame do stream abaixo.

    if (!_isStreaming) {
      _isStreaming = true;
      widget.controller.startImageStream((CameraImage image) {
        double avgRed = _calculateAvgRed(image);

        // Salva PPG bruto e timestamp a cada frame!
        ppgRecords.add(PPGRecord(
          timestamp: DateTime.now(),
          ppg: avgRed,
        ));

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
    //_bpmTimer?.cancel(); // Não precisa mais!

    if (_isStreaming) {
      try {
        await widget.controller.stopImageStream();
      } catch (_) {}
      _isStreaming = false;
    }
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
    final colorGradient = [Color(0xFFFFE5EC), Color(0xFFFFB6C1)];
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colorGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: measuring ? _pulseController.value : 1,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB6C1), Color(0xFFFF5E62)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.22),
                              blurRadius: 32,
                              spreadRadius: 2,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: measuring
                              ? (bpm > 0
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.favorite, color: Colors.white, size: 38),
                                        const SizedBox(height: 12),
                                        Text(
                                          '${bpm.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 46,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'BPM',
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 5,
                                        ),
                                        const SizedBox(height: 18),
                                        const Text(
                                          'Calculando...',
                                          style: TextStyle(color: Colors.white70, fontSize: 18),
                                        )
                                      ],
                                    ))
                              : Icon(Icons.favorite, color: Colors.white.withOpacity(0.7), size: 56),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 100,
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    color: Colors.white.withOpacity(0.85),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: HeartRateChart(data: redValues),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                measuring
                    ? ElevatedButton.icon(
                        onPressed: _stopMeasurement,
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: const Text('Parar Medição', style: TextStyle(fontSize: 20)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _startMeasurement,
                            icon: const Icon(Icons.favorite, color: Colors.white),
                            label: const Text('Iniciar Medição', style: TextStyle(fontSize: 22)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: ppgRecords.isNotEmpty ? exportarPPGCSV : null,
                            icon: Icon(Icons.share),
                            label: Text('Exportar & Compartilhar CSV'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 32),
                measuring
                    ? Text(
                        'Coloque o dedo sobre a câmera e aguarde...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.pink.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        'Pronto para medir!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
