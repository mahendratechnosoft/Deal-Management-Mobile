import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/core/network/dio_client.dart';
import 'package:xpertbiz/features/auth/data/repo/auth_repository.dart';
import '../data/locale_data/hive_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'user_role.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    
    on<LogoutEvent>((event, emit) async {
      await AuthLocalStorage.clear();
      emit(AuthInitial());
    });
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await repository.login(event.email, event.password);
      await AuthLocalStorage.saveUser(response);
      RoleResolver.setRole(response.role);
      emit(AuthSuccess(response));
      apiInterceptor.updateToken(response.jwtToken);
    } on DioException catch (dioError) {
      final message = ApiError.getMessage(dioError);
      log(message);
      emit(AuthFailure(message));
    } catch (error) {
      emit(AuthFailure(
        "Something went wrong. Please try again.",
      ));
    }
  }
}
