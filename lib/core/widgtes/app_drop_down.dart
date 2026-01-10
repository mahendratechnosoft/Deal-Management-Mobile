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
    this.dropdownKey, // optional → no impact elsewhere
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 40,
      child: DropdownButtonFormField<T>(
        key: dropdownKey,
        value: value,
        isExpanded: isExpanded,
        hint: Text(
          hintText,
          style: TextStyle(
            color: AppColors.textSecondary,
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
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        menuMaxHeight: overlayHeight,
      ),
    );
  }
}
