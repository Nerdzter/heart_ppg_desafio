/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SignalSpectrumChart extends StatelessWidget {
  final List<double> data;
  final String title;
  final double? xFactor; // Para FFT: transforma índice em Hz

  const SignalSpectrumChart({
    super.key,
    required this.data,
    required this.title,
    this.xFactor,
  });

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(data.length, (i) => FlSpot(
      xFactor != null ? i * xFactor! : i.toDouble(),
      data[i],
    ));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(
              height: 110,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: Colors.red,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  minY: data.reduce((a, b) => a < b ? a : b),
                  maxY: data.reduce((a, b) => a > b ? a : b),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/