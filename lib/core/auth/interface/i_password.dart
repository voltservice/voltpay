// lib/features/send_money/security/repo/password_repo.dart
abstract class IPasswordRepo {
  /// Persist the payment password securely (locally or via backend).
  Future<void> setPaymentPassword(String plain);
  Future<bool> verify(String plain); // 👈 add this
  Future<void> clear();
}
