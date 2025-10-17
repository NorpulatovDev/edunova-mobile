class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, [this.statusCode]);
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);
}