import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';

class CustomDatePicker extends FormField<DateTime> {
  CustomDatePicker({
    super.key,
    DateTime? selectedDate,
    required ValueChanged<DateTime> onDateSelected,
    String hintText = 'Select Date',
    DateTime? firstDate,
    DateTime? lastDate,
    bool enabled = true,
    IconData icon = Icons.calendar_month_outlined,

    /// Label & validation
    bool showLabel = false,
    String? labelText,
    bool isRequired = false,
    String? errorText,
    FormFieldValidator<DateTime>? validator,
  }) : super(
          initialValue: selectedDate,
          validator: validator ??
              (isRequired
                  ? (value) =>
                      value == null ? (errorText ?? 'Date is required') : null
                  : null),
          builder: (FormFieldState<DateTime> field) {
            final dateText = field.value != null
                ? DateFormat('dd MMM yyyy').format(field.value!)
                : hintText;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LABEL
                if (showLabel && labelText != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: RichText(
                      text: TextSpan(
                        text: labelText,
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

                /// DATE FIELD
                InkWell(
                  onTap: enabled
                      ? () async {
                          final picked = await showDatePicker(
                            context: field.context,
                            initialDate: field.value ?? DateTime.now(),
                            firstDate: firstDate ?? DateTime(2000),
                            lastDate: lastDate ?? DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.primaryDark,
                                    onPrimary: Colors.white,
                                    onSurface: AppColors.textPrimary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            field.didChange(picked);
                            onDateSelected(picked);
                          }
                        }
                      : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(8),
                      vertical: Responsive.h(14),
                    ),
                    decoration: BoxDecoration(
                      color: enabled ? Colors.white : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: field.hasError ? Colors.red : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(icon,
                            color: AppColors.primaryDark,
                            size: Responsive.sp(20)),
                        SizedBox(width: Responsive.w(8)),
                        Expanded(
                          child: Text(
                            dateText,
                            style: TextStyle(
                              fontSize: Responsive.sp(14),
                              color: field.value != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// ERROR TEXT
                if (field.hasError) ...[
                  SizedBox(height: Responsive.h(4)),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: Responsive.sp(11),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );
}
