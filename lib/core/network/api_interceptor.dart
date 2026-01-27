import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/app_routes.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';

class ApiInterceptor extends Interceptor {
  String? _token;

  void updateToken(String token) {
    _token = token;
    log('Token Update new');
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

  void _logRequest(RequestOptions options) {}

  void _logResponse(Response response) {}

  void _logError(DioException err) {
    log('❌ ERRORURL: ${err.requestOptions.uri} STATUS: ${err.response?.statusCode} MESSAGE: ${err.message}DATA: ${err.response?.data}');
  }
}
