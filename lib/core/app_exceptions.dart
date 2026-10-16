class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class UnsupportedImageException implements Exception {
  const UnsupportedImageException(this.message);
  final String message;
  @override
  String toString() => message;
}
