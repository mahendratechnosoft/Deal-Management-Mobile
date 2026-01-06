import 'package:equatable/equatable.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final LoginResponse loginResponse;
  AuthSuccess(this.loginResponse);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
