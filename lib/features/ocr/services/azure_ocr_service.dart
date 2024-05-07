import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';

Future<Map<String, String>> ocrRead(Uint8List imageBytes) async {
  // Configurar las credenciales de acceso
  final String? apiKey = dotenv.env['API_KEY'];
  final endpoint = dotenv.env['API_ENDPOINT'];

  // Leer la imagen como bytes
  // if (!image.existsSync()) {
  //   throw Exception('File does not exist: ${image.path}');
  // }

  // Comprobar si apiKey es nulo o vacío
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('API key is missing');
  }

  final base64Image = base64Encode(imageBytes);

  // Construir la solicitud HTTP
  final url = Uri.parse('$endpoint/vision/v3.2/read/analyze');
  final Map<String, String> headers = {
    'Content-Type': 'application/octet-stream',
    'Ocp-Apim-Subscription-Key': apiKey,
  };
  //final body = jsonEncode({'url': 'data:image/jpeg;base64,$base64Image'});

  // Realizar la solicitud HTTP
  final response = await http.post(url, headers: headers, body: imageBytes);

  // Procesar la respuesta
  if (response.statusCode == 202) {
    return response.headers;
  } else {
    return {'error': response.body};
  }
}

ocrGetResult(String operationId) async {
  if (operationId.isEmpty) {
    throw Exception('OperationId is empty');
  }

  final apiKey = dotenv.env['API_KEY'];
  final endpoint = dotenv.env['API_ENDPOINT'];
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('API key is missing');
  }

  final url =
      Uri.parse('$endpoint/vision/v3.2/read/analyzeResults/$operationId');
  final headers = {
    'Ocp-Apim-Subscription-Key': apiKey,
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {'error': response.body};
  }
}

String extractTextFromResponse(Map<String, dynamic> response) {
  // Procesar la respuesta JSON para extraer el texto
  final regions = response['regions'] as List<dynamic>;
  final List<String> textLines = [];
  for (final region in regions) {
    final lines = region['lines'] as List<dynamic>;
    for (final line in lines) {
      final words = line['words'] as List<dynamic>;
      final text = words.map((word) => word['text']).join(' ');
      textLines.add(text);
    }
  }
  return textLines.join('\n');
}
