import 'package:flutter/foundation.dart';

class ResultTextModel extends ChangeNotifier {
  String? _resultText;
  Map<String, dynamic>? _jsonResult;
  bool loading = false;
  Uint8List? _imageData;

  String? get resultText => _resultText;
  Map<String, dynamic>? get jsonResult => _jsonResult;
  bool get isLoading => loading;
  Uint8List? get imageData => _imageData;

  void setLoading() {
    loading = loading ? false : true;
    notifyListeners();
  }

  void setImageData(Uint8List? data) {
    _imageData = data;
    notifyListeners();
  }

  String _processJsonResult() {
    if (_jsonResult == null) {
      return '';
    }

    // Process the JSON result
    final analyzeResult =
        (_jsonResult?['analyzeResult'] as Map<String, dynamic>);
    final readResults = analyzeResult['readResults'] as List<dynamic>;
    final lines = readResults[0]['lines'] as List<dynamic>;

    final List<String> processedLines = lines.map((oneLine) {
      final line = oneLine['text'] as String;
      return line;
    }).toList();

    // Return the processed string
    return processedLines.join('\n');
  }

  void setResult(Map<String, dynamic>? jsonResult) {
    _jsonResult = jsonResult;
    _resultText = _processJsonResult();
    loading = false;
    notifyListeners();
  }

  void clearResult() {
    _resultText = null;
    _jsonResult = null;
    notifyListeners();
  }
}
