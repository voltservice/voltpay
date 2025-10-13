// lib/auth/services/password_hasher.dart
abstract class IPasswordHasher {
  Future<String> hash(String password);
  Future<bool> verify(String password, String stored);
  bool needsRehash(String stored);
}
