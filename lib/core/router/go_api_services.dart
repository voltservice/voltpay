// // lib/core/router/go_api_services.dart
// import 'dart:io';
//
// import 'package:http/http.dart' as http;
//
// class GoApiService {
//   static const String _baseUrl = String.fromEnvironment(
//     'GO_API_BASE',
//     defaultValue: 'http://10.0.2.2:8080', // Android emulator → host
//   );
//
//   static Future<String> fetchMessage() async {
//     final Uri uri = Uri.parse('$_baseUrl/api/message');
//     final http.Response res = await http.get(
//       uri,
//       headers: <String, String>{HttpHeaders.acceptHeader: 'text/plain'},
//     );
//     if (res.statusCode != 200) {
//       throw Exception('API error ${res.statusCode}: ${res.body}');
//     }
//     return res.body;
//   }
// }
// lib/core/router/go_api_services.dart
import 'dart:io';

import 'package:http/http.dart' as http;

class GoApiService {
  static const String _baseUrl = String.fromEnvironment(
    'GO_API_BASE',
    defaultValue: 'http://10.0.2.2:8080', // Android emulator → host
  );

  /// Optional [client] lets tests inject a mock. In app code you can ignore it.
  static Future<String> fetchMessage({http.Client? client}) async {
    final http.Client c = client ?? http.Client();
    try {
      final Uri uri = Uri.parse('$_baseUrl/api/message');
      final http.Response res = await c.get(
        uri,
        headers: <String, String>{HttpHeaders.acceptHeader: 'text/plain'},
      );
      if (res.statusCode != 200) {
        throw Exception('API error ${res.statusCode}: ${res.body}');
      }
      return res.body;
    } finally {
      if (client == null) {
        c.close();
      }
    }
  }
}
