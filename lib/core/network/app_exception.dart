/// Thrown by repository methods on API/network failure. Never let a raw
/// `DioException` escape a repository — always map it to this first.
class AppException implements Exception {
  const AppException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
