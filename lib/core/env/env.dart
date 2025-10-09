import 'package:flutter/foundation.dart';

class Env {
  static const String _api = String.fromEnvironment('API_BASE_URL');
  static const bool _local = bool.fromEnvironment(
    'LOCAL_DEV',
    defaultValue: false,
  );

  static String get apiBase {
    if (_api.isNotEmpty) {
      return _api; // compile-time override wins
    }

    if (_local) {
      final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
      final String host = isAndroid ? '10.0.2.2' : 'localhost';
      return 'http://$host:9099/api';
    }

    // Safe default for ALL platforms (web, emulator, real device)
    // return 'https://voltpay-api-1018663726434.europe-west2.run.app/api';
    return 'http://192.168.56.1:9099/api';
  }
}
