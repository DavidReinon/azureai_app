import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> ocrResponse(File image) async {
  // Configurar las credenciales de acceso
  final String? apiKey = dotenv.env['API_KEY'];
  const endpoint = 'https://testazureaiservices.cognitiveservices.azure.com/';

  // Leer la imagen como bytes
  if (!image.existsSync()) {
  throw Exception('File does not exist: ${image.path}');
}
  final imageBytes = await image.readAsBytes();
  final base64Image = base64Encode(imageBytes);

  // Construir la solicitud HTTP
  final url = Uri.parse('$endpoint/v1.0/ocr');
  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    'Ocp-Apim-Subscription-Key': apiKey,
  };
  final body = jsonEncode({'url': 'data:image/jpeg;base64,$base64Image'});

  // Realizar la solicitud HTTP
  final response = await http.post(url, headers: headers as Map<String, String>, body: body);

  // Procesar la respuesta
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final extractedText = extractTextFromResponse(jsonResponse);
    return extractedText;
  } else {
    throw Exception('Error: ${response.statusCode} - ${response.reasonPhrase}');
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