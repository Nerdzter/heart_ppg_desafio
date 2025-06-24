import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import 'history_page.dart';

class HomePage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomePage({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE5EC), Color(0xFFFFB6C1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Ícone/logo/ilustração
              const Icon(Icons.favorite, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Heart Rate PPG',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    color: Colors.white.withOpacity(0.95),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Desafio - Nayderson',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.favorite, size: 28),
                            label: const Text(
                              'Iniciar medição',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
                              elevation: 4,
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
                          const SizedBox(height: 20),
                          TextButton.icon(
                            icon: const Icon(Icons.history, color: Colors.red),
                            label: const Text(
                              'Ver histórico',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HistoryPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
