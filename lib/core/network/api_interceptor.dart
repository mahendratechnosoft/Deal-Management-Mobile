import 'dart:developer';

import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  String? _token;
  void updateToken(String token) {
    _token = token;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (_token != null && _token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_token';
    }

    options.headers['Accept'] = 'application/json';

    _logRequest(options);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Logging (Response)
    _logResponse(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // Handle Unauthorized (Token Expired)
    if (err.response?.statusCode == 401) {
      _handleUnauthorized();
    }

    // Logging (Error)
    _logError(err);

    super.onError(err, handler);
  }

  // ================= HELPERS =================

  void _handleUnauthorized() {
    // 🔥 CRM LEVEL ACTION
    // 1. Clear token from storage
    // 2. Redirect to login
    // 3. Clear BLoC states if needed

    // Example:
    // SecureStorage.clear();
    // AppRouter.router.go('/login');
  }

  void _logRequest(RequestOptions options) {
    log('''
➡️ REQUEST
URL: ${options.uri}
METHOD: ${options.method}
HEADERS: ${options.headers}
BODY: ${options.data}
''');
  }

  void _logResponse(Response response) {
    log('''✅ RESPONSEURL: ${response.requestOptions.uri}STATUS: ${response.statusCode}DATA: ${response.data}''');
  }

  void _logError(DioException err) {
    log('''❌ ERRORURL: ${err.requestOptions.uri}URL: ${err.requestOptions.uri}URL: ${err.requestOptions.uri}STATUS: ${err.response?.statusCode}MESSAGE: ${err.message}DATA: ${err.response?.data}''');
  }
}
