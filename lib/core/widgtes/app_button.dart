import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// ✅ Optional validator flag
  /// If false → button disabled
  final bool isValid;

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isValid = true, // default = valid
  });

  bool get _isDisabled => onPressed == null || isLoading || !isValid;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.h(48),
      child: Material(
        borderRadius: BorderRadius.circular(Responsive.r(12)),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.r(12)),
          onTap: _isDisabled ? null : onPressed,
          child: Ink(
            decoration: BoxDecoration(
              boxShadow: _isDisabled
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
              borderRadius: BorderRadius.circular(Responsive.r(12)),
              gradient: _isDisabled
                  ? null
                  : const LinearGradient(
                      colors: [
                        Color(0xFF0E7490), // cyan-700
                        Color(0xFF1D4ED8), // blue-700
                      ],
                    ),
              color: _isDisabled ? Colors.grey.shade400 : null,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: Responsive.h(22),
                      width: Responsive.h(22),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.sp(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
