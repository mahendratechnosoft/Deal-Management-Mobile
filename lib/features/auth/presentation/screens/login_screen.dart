import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/constants/app_string.dart';
import 'package:xpertbiz/core/images/app_images.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/utils/validators.dart';
import 'package:xpertbiz/core/widgtes/app_button.dart';
import 'package:xpertbiz/core/widgtes/app_snackbar.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin(BuildContext context, AuthState state) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginEvent(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              AppSnackBar.show(
                context,
                message: AppStrings.success,
                type: SnackBarType.success,
              );
              context.go(AppRouteName.dashboard);
            } else if (state is AuthFailure) {
              AppSnackBar.show(
                context,
                message: state.message,
                type: SnackBarType.error,
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      color: AppColors.card,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.r(16)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(Responsive.w(20)),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AppImages.crm,
                                height: Responsive.h(50),
                              ),
                              SizedBox(height: Responsive.h(16)),

                              /// Email
                              AppTextField(
                                hint: AppStrings.email,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              SizedBox(height: Responsive.h(16)),

                              /// Password
                              AppTextField(
                                hint: AppStrings.password,
                                controller: _passwordController,
                                validator: Validators.password,
                                obscureText: true,
                                prefixIcon: const Icon(Icons.lock_outline),
                              ),
                              SizedBox(height: Responsive.h(8)),

                              /// Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    AppStrings.forgotPass,
                                    style: TextStyle(
                                      fontSize: Responsive.sp(12),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: Responsive.h(16)),

                              /// Login Button
                              Button(
                                text: AppStrings.login,
                                isLoading: state is AuthLoading,
                                onPressed: state is AuthLoading
                                    ? null
                                    : () => _onLogin(context, state),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: Responsive.h(24)),

                    /// Footer
                    Text(
                      AppStrings.copyright,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Responsive.sp(12),
                        color: AppColors.textLight,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
