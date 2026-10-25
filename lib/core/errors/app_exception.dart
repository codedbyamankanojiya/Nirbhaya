class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

class ApiException extends AppException {
  final int? statusCode;

  ApiException(super.message, {this.statusCode, super.code, super.details});
      
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class AuthException extends AppException {
  AuthException(super.message);
}

class LocationException extends AppException {
  LocationException(super.message);
}
