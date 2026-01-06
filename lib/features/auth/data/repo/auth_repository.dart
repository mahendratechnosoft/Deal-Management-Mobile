import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';
import '../services/auth_api_service.dart';

class AuthRepository {
  final AuthApiService apiService;

  AuthRepository(this.apiService);

  Future<LoginResponse> login(String email, String password) async {
    final response = await apiService.login(email, password);
    return LoginResponse.fromJson(response.data);
  }
}
