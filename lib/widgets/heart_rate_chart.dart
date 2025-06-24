import 'package:flutter/material.dart';
import 'dart:math';

class HeartRateChart extends StatelessWidget {
  final List<double> data;

  const HeartRateChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 120),
      painter: _ChartPainter(data: data),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  _ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double minValue = data.reduce(min);
    double maxValue = data.reduce(max);

    double verticalScale = maxValue - minValue == 0 ? 1 : maxValue - minValue;
    double xStep = size.width / (data.length > 1 ? data.length - 1 : 1);

    Path path = Path();
    for (int i = 0; i < data.length; i++) {
      double x = xStep * i;
      double y = size.height - ((data[i] - minValue) / verticalScale * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) => true;
}
