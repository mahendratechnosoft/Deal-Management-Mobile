import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import '../utils/responsive.dart';

class AppTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Responsive.r(8)),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: Responsive.sp(14),
      ),
      decoration: InputDecoration(
        labelText: widget.hint,

        /// Padding
        contentPadding: EdgeInsets.symmetric(
          vertical: Responsive.h(14),
          horizontal: Responsive.w(12),
        ),

        /// Icons
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  size: Responsive.sp(20),
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffixIcon,

        /// 🎯 BORDER STATES
        enabledBorder: _border(AppColors.borderDark),
        focusedBorder: _border(AppColors.primaryDark),
        errorBorder: _border(Colors.red),
        focusedErrorBorder: _border(Colors.redAccent, width: 1.5),
        disabledBorder: _border(AppColors.border.withOpacity(0.5)),

        /// Fill
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
