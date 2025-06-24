import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';

class HomePage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomePage({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate PPG'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text(
            'Medir frequência cardíaca',
            style: TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CameraService(
                  camera: cameras.firstWhere(
                    (cam) => cam.lensDirection == CameraLensDirection.back,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
