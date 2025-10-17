import 'package:encrypt/encrypt.dart';
import 'package:logger/logger.dart';

class AESCipher {

  AESCipher._internal() {
    _logger = Logger();
    // _aesKey 是明文16字节密钥，并非Base64编码；使用 UTF-8 初始化
    final key = Key.fromUtf8(_aesKey);
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  }
  static AESCipher? _instance;
  late Encrypter _encrypter;
  late Logger _logger;
  
  // AES Key from chaoxing_py
  static const String _aesKey = 'u2oh6Vu^HWe4_AES';

  static AESCipher get instance {
    _instance ??= AESCipher._internal();
    return _instance!;
  }

  /// Encrypt a string using AES encryption
  /// This replicates the chaoxing_py encryption logic
  /// IMPORTANT: IV must be the same as the key (u2oh6Vu^HWe4_AES) to match Python implementation
  String encrypt(String plainText) {
    try {
      // Use the same key as IV to match chaoxing_py behavior
      final iv = IV.fromUtf8(_aesKey);
      final encrypted = _encrypter.encrypt(plainText, iv: iv);
      _logger.d('Encrypted text: ${encrypted.base64}');
      return encrypted.base64;
    } catch (e) {
      _logger.e('Encryption error: $e');
      rethrow;
    }
  }

  /// Decrypt a string using AES decryption
  String decrypt(String encryptedText) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      // Use the same key as IV to match chaoxing_py behavior
      final iv = IV.fromUtf8(_aesKey);
      final decrypted = _encrypter.decrypt(encrypted, iv: iv);
      _logger.d('Decrypted text: $decrypted');
      return decrypted;
    } catch (e) {
      _logger.e('Decryption error: $e');
      rethrow;
    }
  }

  /// Encrypt username for login (replicates chaoxing_py behavior)
  String encryptUsername(String username) {
    return encrypt(username);
  }

  /// Encrypt password for login (replicates chaoxing_py behavior)
  String encryptPassword(String password) {
    return encrypt(password);
  }

  /// Validate if the encryption is working correctly
  bool validateEncryption() {
    try {
      const testString = 'test_string';
      final encrypted = encrypt(testString);
      final decrypted = decrypt(encrypted);
      return decrypted == testString;
    } catch (e) {
      _logger.e('Encryption validation failed: $e');
      return false;
    }
  }
}
