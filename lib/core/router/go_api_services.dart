// lib/core/router/go_api_services.dart
import 'dart:io';

import 'package:http/http.dart' as http;

class GoApiService {
  static const String _baseUrl = String.fromEnvironment(
    'GO_API_BASE',
    defaultValue: 'http://10.0.2.2:8080', // Android emulator → host
  );

  static Future<String> fetchMessage() async {
    final Uri uri = Uri.parse('$_baseUrl/api/message');
    final http.Response res = await http.get(
      uri,
      headers: <String, String>{HttpHeaders.acceptHeader: 'text/plain'},
    );
    if (res.statusCode != 200) {
      throw Exception('API error ${res.statusCode}: ${res.body}');
    }
    return res.body;
    // For JSON, decode with jsonDecode and return a field.
  }
}
