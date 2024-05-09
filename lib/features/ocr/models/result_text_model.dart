import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResultTextModel extends ChangeNotifier {
  String? _resultText;
  Map<String, dynamic>? _jsonResult;
  bool loading = false;

  String? get resultText => _resultText;
  Map<String, dynamic>? get jsonResult => _jsonResult;
  bool get isLoading => loading;

  void setLoading() {
    loading = true;
    notifyListeners();
  }

  String _processJsonResult() {
    if (_jsonResult == null) {
      return '';
    }

    const resultExample = {
      'status': 'succeeded',
      'createdDateTime': '2024-05-08T10:27:21Z',
      'lastUpdatedDateTime': '2024-05-08T10:27:22Z',
      'analyzeResult': {
        'version': '3.2.0',
        'modelVersion': '2022-04-30',
        'readResults': [
          {
            'page': 1,
            'angle': -1.3737,
            'width': 1000,
            'height': 945,
            'unit': 'pixel',
            'lines': [
              {
                'boundingBox': [746, 185, 748, 198, 743, 199, 742, 185],
                'text': '-',
                'appearance': {
                  'style': {'name': 'other', 'confidence': 0.972}
                },
                'words': [
                  {
                    'boundingBox': [747, 186, 747, 188, 743, 188, 742, 186],
                    'text': '-',
                    'confidence': 0.869
                  }
                ]
              },
              {
                'boundingBox': [254, 268, 671, 261, 672, 306, 255, 319],
                'text': 'You must be the change you',
                'appearance': {
                  'style': {'name': 'handwriting', 'confidence': 0.982}
                },
                'words': [
                  {
                    'boundingBox': [254, 270, 302, 268, 304, 319, 257, 319],
                    'text': 'You',
                    'confidence': 0.997
                  },
                  {
                    'boundingBox': [311, 267, 382, 265, 385, 316, 314, 318],
                    'text': 'must',
                    'confidence': 0.981
                  },
                  {
                    'boundingBox': [392, 265, 426, 264, 428, 314, 394, 316],
                    'text': 'be',
                    'confidence': 0.758
                  },
                  {
                    'boundingBox': [435, 263, 494, 262, 497, 311, 438, 314],
                    'text': 'the',
                    'confidence': 0.992
                  },
                  {
                    'boundingBox': [504, 262, 606, 262, 608, 305, 5]
                  }
                ]
              }
            ]
          }
        ]
      }
    };

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
