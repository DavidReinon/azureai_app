import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResultTextModel extends ChangeNotifier {
  String? _resultText;
  Map<String, dynamic>? _jsonResult;
  bool loading = false;

  String? get resultText => _resultText;
  Map<String, dynamic>? get jsonResult => _jsonResult;
  bool get isLoading => loading;

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
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
}
