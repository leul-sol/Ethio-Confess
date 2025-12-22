import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/error/app_error.dart';
import '../core/error/error_handler_service.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e, stackTrace) {
      throw ErrorHandlerService.handleError(
        e,
        stackTrace,
      );
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e, stackTrace) {
      throw ErrorHandlerService.handleError(
        e,
        stackTrace,
      );
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e, stackTrace) {
      throw ErrorHandlerService.handleError(
        e,
        stackTrace,
      );
    }
  }
}
