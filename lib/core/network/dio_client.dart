import 'package:dio/dio.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';
import 'package:xpertbiz/core/network/api_interceptor.dart';

final apiInterceptor = ApiInterceptor();

class DioClient {
  static Dio getDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    dio.interceptors.add(apiInterceptor);
    return dio;
  }
}
