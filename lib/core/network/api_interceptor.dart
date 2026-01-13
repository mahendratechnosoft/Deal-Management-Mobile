import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/app_routes.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';

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
    if (_token != null && _token!.trim().isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_token';
      log('🔐 Bearer token added');
    } else {
      log('⚠️ Bearer token NOT added');
    }

    options.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    _logRequest(options);
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    _logResponse(response);
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (err.response?.statusCode == 401) {
      _handleUnauthorized();
    }

    _logError(err);
    handler.next(err);
  }

  void _handleUnauthorized() async {
    log('🚫 Unauthorized - Token expired or invalid');
    await AuthLocalStorage.clear();
    _token = null;
    AppRouter.router.go(AppRouteName.login);
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
    log('''
✅ RESPONSE
URL: ${response.requestOptions.uri}
STATUS: ${response.statusCode}
DATA: ${response.data}
''');
  }

  void _logError(DioException err) {
    log('''
❌ ERROR
URL: ${err.requestOptions.uri}
STATUS: ${err.response?.statusCode}
MESSAGE: ${err.message}
DATA: ${err.response?.data}
''');
  }
}
