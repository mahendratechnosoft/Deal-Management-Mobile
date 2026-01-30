import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String Function(String)? onChanged;

  /// Enabled / Disabled
  final bool enabled;

  /// Label
  final bool showLabel;
  final String? labelText;
  final bool isRequired;

  /// Multi-line & length
  final int maxLines;
  final int? minLength;
  final int? maxLength;

  /// 🔥 Phone number (10 digit, numeric only)
  final bool isTenDigitPhone;

  const AppTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.showLabel = false,
    this.labelText,
    this.isRequired = false,
    this.maxLines = 1,
    this.minLength,
    this.maxLength,
    this.isTenDigitPhone = false,
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

  /// 🔥 VALIDATION
  String? _internalValidator(String? value) {
    if (!widget.enabled) return null;

    // Custom validator
    if (widget.validator != null) {
      final result = widget.validator!(value);
      if (result != null) return result;
    }

    // Required
    if (widget.isRequired) {
      if (value == null || value.trim().isEmpty) {
        return 'This field is required';
      }
    }

    // 10 digit phone validation
    if (widget.isTenDigitPhone && value != null && value.isNotEmpty) {
      if (value.length != 10) {
        return 'Enter valid 10 digit mobile number';
      }
    }

    // Min / Max length
    if (value != null && value.isNotEmpty) {
      if (widget.minLength != null && value.length < widget.minLength!) {
        return 'Must be at least ${widget.minLength} characters';
      }
      if (widget.maxLength != null && value.length > widget.maxLength!) {
        return 'Must be at most ${widget.maxLength} characters';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        if (widget.showLabel && widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: RichText(
              text: TextSpan(
                text: widget.labelText!,
                style: TextStyle(
                  fontSize: Responsive.sp(12),
                  color: widget.enabled
                      ? AppColors.textPrimary
                      : AppColors.textPrimary.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  if (widget.isRequired && widget.enabled)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: Responsive.h(4)),
        ],

        /// TEXT FIELD
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.isTenDigitPhone
              ? TextInputType.number
              : widget.keyboardType,
          validator: _internalValidator,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          onChanged: widget.onChanged,

          /// 🔥 HARD INPUT RESTRICTION
          inputFormatters: widget.isTenDigitPhone
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
              : null,

          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: Responsive.sp(14),
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.textPrimary.withOpacity(0.6),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: Responsive.sp(14),
              color: widget.enabled
                  ? AppColors.textSecondary
                  : AppColors.textSecondary.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: Responsive.h(14),
              horizontal: Responsive.w(12),
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText && widget.enabled
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: Responsive.sp(20),
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : widget.suffixIcon,
            enabledBorder: _border(AppColors.borderDark),
            focusedBorder: _border(AppColors.primaryDark),
            errorBorder: _border(Colors.red),
            focusedErrorBorder: _border(Colors.redAccent, width: 1.5),
            disabledBorder: _border(AppColors.borderDark.withOpacity(0.3)),
            filled: true,
            fillColor: widget.enabled ? Colors.white : Colors.grey.shade100,
          ),
        ),
      ],
    );
    
  }
}
