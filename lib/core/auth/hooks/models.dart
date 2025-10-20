// lib/core/auth/hooks/models.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

enum HookDecision { allow, deny }

/// Identity providers we support.
/// Firebase treats email-link as 'password'.
enum ProviderId {
  google('google.com', 'google.com'),
  facebook('facebook.com', 'facebook.com'),
  apple('apple.com', 'apple.com'),
  password('password', 'password'),
  emailLink('password', 'password'),
  phone('phone', 'phone'),
  anonymous('anonymous', 'anonymous');

  const ProviderId(this.providerId, this.eventSuffix);
  final String providerId;
  final String eventSuffix;
}

/// BEFORE CREATE result (policy preflight)
@freezed
abstract class BeforeCreateResult with _$BeforeCreateResult {
  const factory BeforeCreateResult.allow({
    required int httpStatus,
    Map<String, dynamic>? userRecordUpdates,
  }) = _BCAllow;

  const factory BeforeCreateResult.deny({
    required int httpStatus,
    String? errorCode,
    String? errorMessage,
  }) = _BCDeny;

  factory BeforeCreateResult.fromJson(Map<String, dynamic> json) =>
      _$BeforeCreateResultFromJson(json);
}

/// BEFORE SIGN IN result (policy preflight)
@freezed
abstract class BeforeSignInResult with _$BeforeSignInResult {
  const factory BeforeSignInResult.allow({
    required int httpStatus,
    Map<String, dynamic>? sessionClaims,
  }) = _BSAllow;

  const factory BeforeSignInResult.deny({
    required int httpStatus,
    String? errorCode,
    String? errorMessage,
  }) = _BSDeny;

  factory BeforeSignInResult.fromJson(Map<String, dynamic> json) =>
      _$BeforeSignInResultFromJson(json);
}
