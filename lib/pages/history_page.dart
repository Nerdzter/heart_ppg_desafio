import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../widgets/heart_rate_chart.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final history = HistoryService().history.reversed.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Medições')),
      body: history.isEmpty
          ? const Center(child: Text('Nenhuma medição salva ainda.'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text('BPM: ${item.bpm.toStringAsFixed(0)}'),
                    subtitle: Text(
                      'Data: ${item.timestamp.day}/${item.timestamp.month} '
                      'às ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: Icon(Icons.favorite, color: Colors.red.shade300),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Gráfico da Medição'),
                          content: SizedBox(
                            height: 120,
                            width: 320,
                            child: HeartRateChart(data: item.signal),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Fechar'),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
