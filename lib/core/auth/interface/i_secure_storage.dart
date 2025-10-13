import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ISecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
}

//----------------------------
// FlutterSecureStorageAdapter
//----------------------------
class FlutterSecureStorageAdapter implements ISecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) async => _storage.read(key: key);
}
