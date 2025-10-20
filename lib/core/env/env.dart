import 'package:flutter/foundation.dart';

class Env {
  static const String _api = String.fromEnvironment('API_BASE_URL');
  static const bool _local = bool.fromEnvironment(
    'LOCAL_DEV',
    defaultValue: false,
  );
  static const String _func = String.fromEnvironment('FUNCTION_API');

  static String get funcBase {
    if (_func.isNotEmpty) {
      debugPrint('FUNCTION_API = $_func');
      return _func;
    }
    if (_local) {
      final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
      final String host = isAndroid ? '10.0.2.2' : 'localhost';
      return 'http://$host:8080';
    }

    return 'http://192.168.56.1:8080';
    // return 'https://voltpay-api-1018663726434.europe-west2.run.app';
  }

  static String get apiBase {
    if (_api.isNotEmpty) {
      debugPrint('API_BASE = $_api');
      return _api; // compile-time override wins
    }

    if (_local) {
      final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
      final String host = isAndroid ? '10.0.2.2' : 'localhost';
      return 'http://$host:8080';
    }

    // Safe default for ALL platforms (web, emulator, real device)
    // return 'http://192.168.56.1:8080/api';
    return 'http://192.168.56.1:8080';
    // return 'https://voltpay-api-1018663726434.europe-west2.run.app';
  }

  static String get authBase {
    if (_api.isNotEmpty) {
      debugPrint('API_BASE = $_api');
      return _api; // compile-time override wins
    }
    if (_local) {
      final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
      final String host = isAndroid ? '10.0.2.2' : 'localhost';
      return 'http://$host:8080';
    }

    return 'http://192.168.56.1:8080';
    // return 'https://voltpay-api-1018663726434.europe-west2.run.app';
  }
}
