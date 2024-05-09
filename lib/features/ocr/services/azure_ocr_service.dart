import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../enums/ocr_service_status_enums.dart';

class AzureOcrService {
  final String? apiKey = dotenv.env['API_KEY'];
  final String? endpoint = dotenv.env['API_ENDPOINT'];
  Map<String, String>? operationHeaders;

  Future<Map<String, dynamic>> processImage(Uint8List imageBytes) async {
    await _ocrRead(imageBytes);
    return await _ocrGetResult();
  }

  Future<void> _ocrRead(Uint8List imageBytes) async {
    // Comprobar si apiKey es nulo o vacío
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('API key is missing');
    }

    // Construir la solicitud HTTP
    final url = Uri.parse('$endpoint/vision/v3.2/read/analyze');
    final Map<String, String> headers = {
      'Content-Type': 'application/octet-stream',
      'Ocp-Apim-Subscription-Key': apiKey!,
    };

    // Realizar la solicitud HTTP
    final response = await http.post(url, headers: headers, body: imageBytes);

    // Procesar la respuesta
    if (response.statusCode == 202) {
      operationHeaders = response.headers;
      print('OperationId: ${operationHeaders!['operation-location']}\n');
    } else {
      throw Exception('Error: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> _ocrGetResult() async {
    if (operationHeaders == null ||
        operationHeaders!['operation-location'] == null) {
      throw Exception('OperationId is missing');
    }

    final url = Uri.parse(operationHeaders!['operation-location']!);
    final headers = {
      'Ocp-Apim-Subscription-Key': apiKey!,
    };

    while (true) {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        final status =
            OcrServiceStatusExtension.fromString(jsonResult['status']);

        // Si el procesamiento aún no ha terminado, espera un poco y luego intenta de nuevo
        if (status == OcrServiceStatus.running ||
            status == OcrServiceStatus.notStarted) {
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        print('Result: ${jsonResult}\n');
        print('Headers: ${response.headers}\n');
        return jsonResult;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
  }
}
