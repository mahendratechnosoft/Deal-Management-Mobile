import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';

class CommonDropdown<T> extends StatelessWidget {
  final List<T> items;
  final String hintText;

  final T? value;
  final double? height;
  final double? overlayHeight;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemAsString;
  final bool isExpanded;
  final bool enabled;

  // Label properties
  final bool showLabel;
  final String? labelText;
  final bool isRequired;

  /// 🔹 OPTIONAL controller key (NEW)
  final GlobalKey? dropdownKey;

  const CommonDropdown({
    super.key,
    required this.items,
    required this.hintText,
    this.value,
    this.height,
    this.overlayHeight,
    this.onChanged,
    this.itemAsString,
    this.isExpanded = true,
    this.enabled = true,
    this.showLabel = false,
    this.labelText,
    this.isRequired = false,
    this.dropdownKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        if (showLabel && labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 8),
            child: RichText(
              text: TextSpan(
                text: labelText!,
                style: TextStyle(
                  fontSize: 12,
                  color: enabled
                      ? AppColors.textPrimary
                      : AppColors.textPrimary.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  if (isRequired && enabled)
                    const TextSpan(
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
        ],

        /// DROPDOWN
        SizedBox(
          height: height ?? 40,
          child: DropdownButtonFormField<T>(
            key: dropdownKey,
            value: value,
            isExpanded: isExpanded,
            hint: Text(
              hintText,
              style: TextStyle(
                color: enabled
                    ? AppColors.textSecondary
                    : AppColors.textSecondary.withOpacity(0.5),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      itemAsString?.call(item) ?? item.toString(),
                      style: TextStyle(
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textPrimary.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: enabled ? onChanged : null,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade300, // Light grey border
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade300, // Light grey when enabled
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primary
                      .withOpacity(0.5), // Subtle primary color on focus
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade200, // Very light grey when disabled
                  width: 1,
                ),
              ),
              enabled: enabled,
              fillColor: enabled ? Colors.white : Colors.grey.shade50,
              filled: true,
            ),
            menuMaxHeight: overlayHeight,
          ),
        ),
      ],
    );
  }
}
