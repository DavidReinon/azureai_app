import 'package:flutter/foundation.dart';

class ResultTextModel extends ChangeNotifier {
  String? _resultText;
  String? _resultDetails;
  Map<String, dynamic>? _jsonResult;
  bool loading = false;
  Uint8List? _imageData;

  String? get resultText => _resultText;
  String? get resultDetails => _resultDetails;
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

  String _processJsonResultText() {
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

  String _processJsonResultDetails() {
    if (_jsonResult == null) {
      return '';
    }

    // Process the JSON result
    List<String> processedLines = [];
    final status = _jsonResult?['status'];
    processedLines.add('Status: $status');

    final analyzeResult =
        (_jsonResult?['analyzeResult'] as Map<String, dynamic>);
    final version = analyzeResult['version'];
    processedLines.add('Model Version: $version');

    final readResults = analyzeResult['readResults'] as List<dynamic>;
    final width = readResults[0]['width'];
    final height = readResults[0]['height'];

    processedLines.add('Image width: $width');
    processedLines.add('Image height: $height');

    // Return the processed string
    return processedLines.join('\n');
  }

  void setResult(Map<String, dynamic>? jsonResult) {
    _jsonResult = jsonResult;
    _resultText = _processJsonResultText();
    _resultDetails = _processJsonResultDetails();
    loading = false;
    notifyListeners();
  }

  void clearResult() {
    _resultText = null;
    _jsonResult = null;
    notifyListeners();
  }
}
