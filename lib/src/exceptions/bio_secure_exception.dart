class BioSecureException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  BioSecureException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'BioSecureException('
      'code: $code, '
      'message: $message, '
      'details: $details)';
}
