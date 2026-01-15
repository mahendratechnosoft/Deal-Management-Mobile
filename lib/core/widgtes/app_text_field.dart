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
  
  /// NEW: Enabled state
  final bool enabled;

  /// 🔥 LABEL
  final bool showLabel;
  final String? labelText;
  final bool isRequired;

  /// 🔥 NEW: multi-line & max-length support
  final int maxLines;
  final int? minLength;
  final int? maxLength;

  const AppTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true, // Default to enabled
    this.showLabel = false,
    this.labelText,
    this.isRequired = false,
    this.maxLines = 1,
    this.minLength,
    this.maxLength,
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

  String? _internalValidator(String? value) {
    // Skip validation if field is disabled
    if (!widget.enabled) {
      return null;
    }
    
    // use custom validator if provided
    if (widget.validator != null) {
      final result = widget.validator!(value);
      if (result != null) return result;
    }

    // if required
    if (widget.isRequired) {
      if (value == null || value.trim().isEmpty) {
        return 'This field is required';
      }
    }

    // optional minLength / maxLength (only if user typed something)
    if (value != null && value.trim().isNotEmpty) {
      final length = value.trim().length;
      if (widget.minLength != null && length < widget.minLength!) {
        return 'Must be at least ${widget.minLength} characters';
      }
      if (widget.maxLength != null && length > widget.maxLength!) {
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
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
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
          keyboardType: widget.keyboardType,
          validator: _internalValidator,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
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
                      color: widget.enabled
                          ? AppColors.textPrimary
                          : AppColors.textPrimary.withOpacity(0.5),
                    ),
                    onPressed: widget.enabled
                        ? () => setState(() => _obscure = !_obscure)
                        : null,
                  )
                : widget.suffixIcon,
            enabledBorder: _border(widget.enabled 
                ? AppColors.borderDark 
                : AppColors.borderDark.withOpacity(0.5)),
            focusedBorder: _border(widget.enabled 
                ? AppColors.primaryDark 
                : AppColors.primaryDark.withOpacity(0.5)),
            errorBorder: _border(Colors.red),
            focusedErrorBorder: _border(Colors.redAccent, width: 1.5),
            disabledBorder: _border(AppColors.borderDark.withOpacity(0.3)),
            filled: true,
            fillColor: widget.enabled 
                ? Colors.white 
                : Colors.grey.shade100,
          ),
        ),
      ],
    );
  }
}