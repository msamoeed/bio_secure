import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'models/biometric_type.dart';
import 'models/security_level.dart';
import 'exceptions/bio_secure_exception.dart';

class BioSecure {
  static const MethodChannel _channel = MethodChannel('secure_storage_channel');
  final Platform _platform;
  BiometricType? _biometricType;
  bool? _isAvailable;

  /// Creates a new instance of BioSecure
  /// Optionally accepts a [Platform] for testing purposes
  BioSecure({Platform? platform}) : _platform = platform ?? Platform();

  /// Initializes the secure storage and checks device capabilities
  Future<SecurityStatus> initialize() async {
    if (!Platform.isIOS) {
      throw BioSecureException(
        code: 'unsupported_platform',
        message: 'This plugin only supports iOS devices',
      );
    }

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('initialize');
      
      if (result == null) {
        throw BioSecureException(
          code: 'initialization_failed',
          message: 'Failed to initialize secure storage',
        );
      }

      _isAvailable = result['available'] as bool;
      _biometricType = _parseBiometricType(result['biometricType'] as String);

      return SecurityStatus(
        isAvailable: _isAvailable ?? false,
        biometricType: _biometricType ?? BiometricType.none,
        secureEnclaveAvailable: result['secureEnclaveAvailable'] as bool? ?? false,
      );
    } on PlatformException catch (e) {
      throw BioSecureException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }

  /// Stores encrypted data in the Secure Enclave
  /// 
  /// Requires biometric authentication
  /// Throws [BioSecureException] if storage fails
  Future<void> secureStore(String key, String value) async {
    _checkInitialization();

    try {
      await _channel.invokeMethod<void>('secureStore', {
        'key': key,
        'value': value,
      });
    } on PlatformException catch (e) {
      throw BioSecureException(
        code: e.code,
        message: e.message ?? 'Failed to store data',
        details: e.details,
      );
    }
  }

  /// Retrieves data from the Secure Enclave
  /// 
  /// Requires biometric authentication
  /// Returns null if the key doesn't exist
  /// Throws [BioSecureException] if retrieval fails
  Future<String?> secureRetrieve(String key) async {
    _checkInitialization();

    try {
      final result = await _channel.invokeMethod<String>('secureRetrieve', {
        'key': key,
      });
      return result;
    } on PlatformException catch (e) {
      throw BioSecureException(
        code: e.code,
        message: e.message ?? 'Failed to retrieve data',
        details: e.details,
      );
    }
  }

  /// Deletes data from the Secure Enclave
  /// 
  /// Returns true if the data was successfully deleted
  /// Throws [BioSecureException] if deletion fails
  Future<void> secureDelete(String key) async {
    _checkInitialization();

    try {
      await _channel.invokeMethod<void>('secureDelete', {
        'key': key,
      });
    } on PlatformException catch (e) {
      throw BioSecureException(
        code: e.code,
        message: e.message ?? 'Failed to delete data',
        details: e.details,
      );
    }
  }

  /// Clears all stored data
  /// 
  /// Use with caution as this will delete all stored data
  /// Throws [BioSecureException] if clearing fails
  Future<void> clearAll() async {
    _checkInitialization();

    try {
      await _channel.invokeMethod<void>('clearAll');
    } on PlatformException catch (e) {
      throw BioSecureException(
        code: e.code,
        message: e.message ?? 'Failed to clear data',
        details: e.details,
      );
    }
  }

  /// Gets the current biometric type available on the device
  BiometricType? get biometricType => _biometricType;

  /// Checks if biometric authentication is available
  bool get isAvailable => _isAvailable ?? false;

  void _checkInitialization() {
    if (_isAvailable == null) {
      throw BioSecureException(
        code: 'not_initialized',
        message: 'BioSecure has not been initialized. Call initialize() first.',
      );
    }
  }

  BiometricType _parseBiometricType(String type) {
    switch (type) {
      case 'touch_id':
        return BiometricType.touchId;
      case 'face_id':
        return BiometricType.faceId;
      default:
        return BiometricType.none;
    }
  }
}