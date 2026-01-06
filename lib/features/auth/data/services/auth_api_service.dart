import 'package:dio/dio.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';

class AuthApiService {
  final Dio dio;

  AuthApiService(this.dio);

  Future<Response> login(String email, String password) {
    return dio.post(
      ApiConstants.login,
      data: {
        "username": email,
        "password": password,
      },
    );
  }
}
