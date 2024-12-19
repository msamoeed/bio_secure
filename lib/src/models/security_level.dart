import '../../bio_secure.dart';

class SecurityStatus {
  /// Whether biometric authentication is available
  final bool isAvailable;

  /// The type of biometric authentication available
  final BiometricType biometricType;

  /// Whether Secure Enclave is available
  final bool secureEnclaveAvailable;

  SecurityStatus({
    required this.isAvailable,
    required this.biometricType,
    required this.secureEnclaveAvailable,
  });

  @override
  String toString() => 'SecurityStatus('
      'isAvailable: $isAvailable, '
      'biometricType: $biometricType, '
      'secureEnclaveAvailable: $secureEnclaveAvailable)';
}