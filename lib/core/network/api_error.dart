import 'package:dio/dio.dart';

class ApiError {
  static String getMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }

    return "Something went wrong. Please try again.";
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return "timeout. Please check your internet.";

      case DioExceptionType.sendTimeout:
        return "Request timeout. Please try again.";

      case DioExceptionType.receiveTimeout:
        return "Server is taking too long to respond.";

      case DioExceptionType.badCertificate:
        return "Security certificate error.";

      case DioExceptionType.connectionError:
        return "No internet connection.";

      case DioExceptionType.cancel:
        return "Request was cancelled.";

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response);

      case DioExceptionType.unknown:
        return "An unknown error occurred.";
    }
  }

  static String _handleStatusCode(Response? response) {
    if (response == null) {
      return "Server error occurred.";
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    /// ✅ CASE 1: Plain text error (YOUR CASE)
    if (data is String && data.isNotEmpty) {
      return data;
    }

    /// ✅ CASE 2: JSON error
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
    }

    /// ✅ Fallback messages
    switch (statusCode) {
      case 400:
        return "Bad request. Please check inputs.";
      case 401:
        return "Invalid username or password.";
      case 403:
        return "You don’t have permission to perform this action.";
      case 404:
        return "Requested resource not found.";
      case 500:
        return "Internal server error. Try again later.";
      default:
        return "Something went wrong (Code: $statusCode).";
    }
  }
}
