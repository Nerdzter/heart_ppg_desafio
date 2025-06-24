import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:wakelock/wakelock.dart';
import 'ppg_service.dart';

class CameraService extends StatefulWidget {
  final CameraDescription camera;

  const CameraService({Key? key, required this.camera}) : super(key: key);

  @override
  State<CameraService> createState() => _CameraServiceState();
}

class _CameraServiceState extends State<CameraService> {
  late CameraController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    Wakelock.enable();
  }

  @override
  void dispose() {
    _controller.dispose();
    Wakelock.disable();
    super.dispose();
  }

  Future<void> _initCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    await _controller.initialize();
    await _controller.setFlashMode(FlashMode.torch);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medição de BPM'),
      ),
      body: Stack(
        children: [
          CameraPreview(_controller),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          Center(
            child: ElevatedButton(
              child: const Text(
                'Iniciar Medição',
                style: TextStyle(fontSize: 22),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PPGService(controller: _controller),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
