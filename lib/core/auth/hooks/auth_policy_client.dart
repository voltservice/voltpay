// lib/core/auth/hooks/auth_policy_client.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:voltpay/core/auth/domain/AuthApiConfig.dart';
import 'package:voltpay/core/auth/hooks/models.dart';

typedef AppCheckTokenProvider = Future<String?> Function();

@immutable
class AuthPolicyClient {
  const AuthPolicyClient._(
    this._cfg, {
    this.client,
    this.timeout = const Duration(seconds: 5),
    this.appCheckTokenProvider,
  });

  /// Preferred: build with `fromConfig`.
  factory AuthPolicyClient.fromConfig(
    AuthApiConfig cfg, {
    http.Client? client,
    Duration timeout = const Duration(seconds: 5),
    AppCheckTokenProvider? appCheckTokenProvider,
  }) {
    return AuthPolicyClient._(
      cfg,
      client: client,
      timeout: timeout,
      appCheckTokenProvider: appCheckTokenProvider,
    );
  }

  /// Legacy constructor (kept for compatibility).
  factory AuthPolicyClient({
    required String baseUrl,
    http.Client? client,
    Duration timeout = const Duration(seconds: 5),
    String beforeCreatePath = '/auth/beforeCreate',
    String beforeSignInPath = '/auth/beforeSignIn',
    AppCheckTokenProvider? appCheckTokenProvider,
  }) {
    final AuthApiConfig cfg = AuthApiConfig(
      baseUrl: baseUrl,
      beforeCreatePath: beforeCreatePath,
      beforeSignInPath: beforeSignInPath,
      attachApiPrefix: false,
    );
    return AuthPolicyClient._(
      cfg,
      client: client,
      timeout: timeout,
      appCheckTokenProvider: appCheckTokenProvider,
    );
  }

  final AuthApiConfig _cfg;
  final http.Client? client;
  final Duration timeout;
  final AppCheckTokenProvider? appCheckTokenProvider;

  // ---------- Before Create ----------
  Future<BeforeCreateResult> beforeCreate({
    required String email,
    ProviderId providerId = ProviderId.emailLink,
    String? displayName,
    String? tenantResourceName,
  }) async {
    final http.Client c = client ?? http.Client();
    final Uri uri = _cfg.beforeCreateUri;

    final Map<String, String> headers = await _headers();
    final Map<String, dynamic> payload = <String, dynamic>{
      'eventType':
          'providers/firebase.auth/eventTypes/beforeCreate:${providerId.eventSuffix}',
      if (tenantResourceName != null && tenantResourceName.isNotEmpty)
        'resource': tenantResourceName,
      'data': <String, dynamic>{
        'userInfo': <String, dynamic>{
          'email': email.trim().toLowerCase(),
          if (displayName != null && displayName.isNotEmpty)
            'displayName': displayName,
          'emailVerified': false,
          'disabled': false,
        },
      },
    };

    try {
      final http.Response resp = await c
          .post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(timeout);

      final Map<String, dynamic> body = _safeJson(resp.body);
      if (resp.statusCode == 200) {
        final Map<String, dynamic>? updates = _asMap(body['userRecord']);
        return BeforeCreateResult.allow(
          httpStatus: resp.statusCode,
          userRecordUpdates: updates,
        );
      }
      final Map<String, dynamic>? err = _asMap(body['error']);
      return BeforeCreateResult.deny(
        httpStatus: resp.statusCode,
        errorCode: err?['code'] as String?,
        errorMessage: err?['message'] as String? ?? 'Signup not allowed.',
      );
    } catch (_) {
      return const BeforeCreateResult.deny(
        httpStatus: 0,
        errorCode: 'network-error',
        errorMessage: 'Could not reach signup policy service.',
      );
    } finally {
      if (client == null) {
        c.close();
      }
    }
  }

  // ---------- Before Sign-In ----------
  Future<BeforeSignInResult> beforeSignIn({
    required ProviderId providerId,
    String? email,
    bool? emailVerified,
    String? phoneNumber,
    String? displayName,
    String? tenantResourceName,
  }) async {
    final http.Client c = client ?? http.Client();
    final Uri uri = _cfg.beforeSignInUri;

    final Map<String, String> headers = await _headers();
    final Map<String, dynamic> userInfo = <String, dynamic>{
      if (email != null) 'email': email.trim().toLowerCase(),
      if (emailVerified != null) 'emailVerified': emailVerified,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (displayName != null && displayName.isNotEmpty)
        'displayName': displayName,
      'disabled': false,
    };

    final Map<String, dynamic> payload = <String, dynamic>{
      'eventType':
          'providers/firebase.auth/eventTypes/beforeSignIn:${providerId.eventSuffix}',
      if (tenantResourceName != null && tenantResourceName.isNotEmpty)
        'resource': tenantResourceName,
      'data': <String, dynamic>{'userInfo': userInfo},
    };

    try {
      final http.Response resp = await c
          .post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(timeout);

      final Map<String, dynamic> body = _safeJson(resp.body);
      if (resp.statusCode == 200) {
        final Map<String, dynamic>? claims = _asMap(body['sessionClaims']);
        return BeforeSignInResult.allow(
          httpStatus: resp.statusCode,
          sessionClaims: claims,
        );
      }
      final Map<String, dynamic>? err = _asMap(body['error']);
      return BeforeSignInResult.deny(
        httpStatus: resp.statusCode,
        errorCode: err?['code'] as String?,
        errorMessage: err?['message'] as String? ?? 'Sign-in not allowed.',
      );
    } catch (_) {
      return const BeforeSignInResult.deny(
        httpStatus: 0,
        errorCode: 'network-error',
        errorMessage: 'Could not reach sign-in policy service.',
      );
    } finally {
      if (client == null) {
        c.close();
      }
    }
  }

  // ---------- helpers ----------
  Future<Map<String, String>> _headers() async {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (appCheckTokenProvider != null) {
      final String? tok = await appCheckTokenProvider!.call();
      if (tok != null && tok.isNotEmpty) {
        headers['X-Firebase-AppCheck'] = tok;
      }
    }
    return headers;
  }

  Map<String, dynamic> _safeJson(String s) {
    try {
      return s.isNotEmpty
          ? (json.decode(s) as Map<String, dynamic>)
          : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic>? _asMap(Object? v) {
    if (v is Map) {
      return v.cast<String, dynamic>();
    }
    return null;
  }
}
