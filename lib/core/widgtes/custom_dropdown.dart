import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged; // Make it nullable
  final String Function(T) itemLabel;

  final String hintText;
  final double? width;
  final double? height;
  final bool enabled;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final Widget? prefixIcon;

  /// 🔥 NEW
  final double? menuMaxHeight;

  /// LABEL + VALIDATION
  final bool showLabel;
  final String? labelText;
  final bool isRequired;
  final String? Function(T?)? validator;
  final String? errorText;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged, // Still required but nullable
    required this.itemLabel,
    this.value,
    this.hintText = 'Select',
    this.width,
    this.height,
    this.enabled = true,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 6,
    this.prefixIcon,
    this.menuMaxHeight, // 👈

    this.showLabel = false,
    this.labelText,
    this.isRequired = false,
    this.validator,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final validationError = validator?.call(value) ?? errorText;
    final hasError = validationError != null && validationError.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        if (showLabel && labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: RichText(
              text: TextSpan(
                text: labelText!,
                style: TextStyle(
                  fontSize: Responsive.sp(12),
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  if (isRequired)
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

        /// DROPDOWN
        Container(
          width: width ?? double.infinity,
          height: height ?? Responsive.h(48),
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(10)),
          decoration: BoxDecoration(
            color: enabled
                ? backgroundColor ?? Colors.white
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: hasError ? Colors.red : borderColor ?? AppColors.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              menuMaxHeight: menuMaxHeight ?? 250,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              hint: Text(
                hintText,
                style: TextStyle(
                  fontSize: Responsive.sp(12),
                  color: AppColors.textSecondary,
                ),
              ),
              onChanged: enabled ? onChanged : null, // This accepts null now
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        /// ERROR TEXT
        if (hasError) ...[
          SizedBox(height: Responsive.h(4)),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              validationError,
              style: TextStyle(
                color: Colors.red,
                fontSize: Responsive.sp(11),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class DropdownItem {
  final String id;
  final String name;
  final String? displayName; // Optional: for showing selected status
  final bool isSelected;

  const DropdownItem({
    required this.id,
    required this.name,
    this.displayName,
    this.isSelected = false,
  });
}
