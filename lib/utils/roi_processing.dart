import 'dart:math';
import 'package:camera/camera.dart';

class ROIProcessor {
  final int blockSize; // Ex: 16 (16x16 blocos)
  final int historyLength; // Ex: 60 amostras por bloco
  final double topPercent; // Ex: 0.15 para top 15%

  late int width;
  late int height;
  bool _shapeSet = false;

  late List<List<List<double>>> _blockHistories;
  late List<List<double>> _currentBlockMeans;

  ROIProcessor({this.blockSize = 16, this.historyLength = 60, this.topPercent = 0.15});

  void setFrameShape(int w, int h) {
    width = w;
    height = h;
    int nBlocksX = (width / blockSize).floor();
    int nBlocksY = (height / blockSize).floor();
    _blockHistories = List.generate(nBlocksY, (_) =>
        List.generate(nBlocksX, (_) => List.filled(historyLength, 0.0, growable: true)));
    _currentBlockMeans = List.generate(nBlocksY, (_) => List.filled(nBlocksX, 0.0));
    _shapeSet = true;
  }

  // imagem do canal vermelho
  double processFrame(List<int> redMatrix, int frameWidth, int frameHeight) {
    if (!_shapeSet || width != frameWidth || height != frameHeight) {
      setFrameShape(frameWidth, frameHeight);
    }
    int nBlocksX = (frameWidth / blockSize).floor();
    int nBlocksY = (frameHeight / blockSize).floor();

    // 1. Calcula média do canal vermelho para cada bloco
    for (int by = 0; by < nBlocksY; by++) {
      for (int bx = 0; bx < nBlocksX; bx++) {
        int x0 = bx * blockSize, x1 = min(x0 + blockSize, frameWidth);
        int y0 = by * blockSize, y1 = min(y0 + blockSize, frameHeight);

        double sum = 0.0;
        int count = 0;
        for (int y = y0; y < y1; y++) {
          for (int x = x0; x < x1; x++) {
            sum += redMatrix[y * frameWidth + x];
            count++;
          }
        }
        double mean = count > 0 ? sum / count : 0.0;
        _currentBlockMeans[by][bx] = mean;
        // Atualiza histórico
        var hist = _blockHistories[by][bx];
        if (hist.length >= historyLength) hist.removeAt(0);
        hist.add(mean);
      }
    }

    // 2. Variação de cada bloco
    List<MapEntry<double, List<int>>> blockVarianceList = [];
    for (int by = 0; by < nBlocksY; by++) {
      for (int bx = 0; bx < nBlocksX; bx++) {
        var hist = _blockHistories[by][bx];
        double minv = hist.reduce(min);
        double maxv = hist.reduce(max);
        double amp = maxv - minv;
        blockVarianceList.add(MapEntry(amp, [by, bx]));
      }
    }

    // 3. Top % blocos
    blockVarianceList.sort((a, b) => b.key.compareTo(a.key));
    int nTop = max(1, (blockVarianceList.length * topPercent).round());
    var topBlocks = blockVarianceList.take(nTop).map((e) => e.value).toList();

    // 4. Média só dos top blocos
    double topSum = 0.0;
    int topCount = 0;
    for (var pos in topBlocks) {
      topSum += _currentBlockMeans[pos[0]][pos[1]];
      topCount++;
    }
    return topCount > 0 ? topSum / topCount : 0.0;
  }
}
