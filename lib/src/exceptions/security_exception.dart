class SecurityException implements Exception {
  final String code;
  final String message;

  SecurityException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'SecurityException($code: $message)';

  factory SecurityException.jailbroken() {
    return SecurityException(
      code: 'device_jailbroken',
      message: 'Device appears to be jailbroken',
    );
  }

  factory SecurityException.tampered() {
    return SecurityException(
      code: 'app_tampered',
      message: 'Application appears to be tampered',
    );
  }

  factory SecurityException.debugged() {
    return SecurityException(
      code: 'debugger_attached',
      message: 'Debugger appears to be attached',
    );
  }
}