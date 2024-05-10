import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../enums/ocr_service_status_enums.dart';

class AzureOcrService {
  final String? _apiKey = dotenv.env['API_KEY'];
  final String? _endpoint = dotenv.env['API_ENDPOINT'];
  Map<String, String>? _operationHeaders;

  Map<String, dynamic>? jsonResult;
  Map<String, String>? errorMessage;

  Future<bool> processImage(Uint8List imageBytes) async {
    final bool correctRead = await _ocrRead(imageBytes);

    if (correctRead) {
      final bool correctGetResult = await _ocrGetResult();
      return correctGetResult;
    }
    return false;
  }

  Future<bool> _ocrRead(Uint8List imageBytes) async {
    // Comprobar si _apiKey es nulo o vacío
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception('API key is missing');
    }

    // Construir la solicitud HTTP
    final url = Uri.parse('$_endpoint/vision/v3.2/read/analyze');
    final Map<String, String> headers = {
      'Content-Type': 'application/octet-stream',
      'Ocp-Apim-Subscription-Key': _apiKey,
    };

    // Realizar la solicitud HTTP
    final response = await http.post(url, headers: headers, body: imageBytes);

    // Procesar la respuesta
    if (response.statusCode == 202) {
      _operationHeaders = response.headers;
      print('OperationId: ${_operationHeaders!['operation-location']}\n');
      return true;
    } else {
      errorMessage = jsonDecode(response.body)['error'];
      return false;
    }
  }

  Future<bool> _ocrGetResult() async {
    if (_operationHeaders == null ||
        _operationHeaders!['operation-location'] == null) {
      throw Exception('OperationId is missing');
    }

    final url = Uri.parse(_operationHeaders!['operation-location']!);
    final headers = {
      'Ocp-Apim-Subscription-Key': _apiKey!,
    };

    while (true) {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final status = OcrServiceStatusExtension.fromString(result['status']);

        // Si el procesamiento aún no ha terminado, espera un poco y luego intenta de nuevo
        if (status == OcrServiceStatus.running ||
            status == OcrServiceStatus.notStarted) {
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }
        jsonResult = result;
        print('Result: ${result}\n');
        print('Headers: ${response.headers}\n');
        return true;
      } else {
        errorMessage = jsonDecode(response.body)['error'];
        return false;
      }
    }
  }
}
