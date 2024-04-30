import 'package:flutter/material.dart';

class ResultTextModel extends ChangeNotifier {
  String _resultText = '';

  String get resultText => _resultText;

  void setResult(String result) {
    _resultText = result;
    notifyListeners();
  }

  void clearResult() {
    _resultText = '';
    notifyListeners();
  }
}
