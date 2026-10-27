import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../create_lead_bloc.dart/create_bloc.dart';
import '../../create_lead_bloc.dart/create_event.dart';

class CreateLeadHelper {
  // Load countries
  static void loadCountries(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreateLeadBloc>().add(const LoadCountriesEvent());
    });
  }

  // Retry loading countries
  static void retryLoadCountries(BuildContext context) {
    context.read<CreateLeadBloc>().add(const LoadCountriesEvent());
  }

  // Show success snackbar
  static void showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Lead saved successfully',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show info snackbar
  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Build section header
  static Widget buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // Build label with optional required indicator
  static Widget buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF334155),
            fontWeight: FontWeight.w600,
          ),
          children: isRequired
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  // Build error message widget
  static Widget buildErrorMessage(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build loading widget for dropdowns
  static Widget buildDropdownLoading() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }

  // Build loading view
  static Widget buildLoadingView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 36,
            width: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // Build success view
  static Widget buildSuccessView({VoidCallback? onBackPressed}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF059669), size: 64),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lead Saved Successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The lead information has been updated in your pipeline.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBackPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Back to Leads',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build error view
  static Widget buildErrorView({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: const Icon(Icons.error_outline_rounded,
                color: Color(0xFFDC2626), size: 54),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF991B1B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // Format phone number with country code
  static String formatPhoneNumber(String phoneNumber, String? countryCode) {
    if (phoneNumber.isEmpty) return phoneNumber;
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (phoneNumber.contains('+')) {
      return phoneNumber;
    }

    final Map<String, String> countryCodes = {
      'US': '+1',
      'IN': '+91',
      'GB': '+44',
      'CA': '+1',
      'AU': '+61',
      'DE': '+49',
      'FR': '+33',
      'IT': '+39',
      'ES': '+34',
      'JP': '+81',
      'CN': '+86',
      'BR': '+55',
      'RU': '+7',
    };

    String code = countryCodes[countryCode] ?? '+91';
    return '($code) $digits';
  }

  // Format date for API
  static String? formatDateForApi(DateTime? date) {
    if (date == null) return null;
    return date.toUtc().toIso8601String();
  }
}

class CreateLeadConstants {
  // Lead sources
  static const List<String> leadSources = [
    'Website',
    'Referral',
    'Social Media',
    'Email Campaign',
    'Trade Show',
    'Cold Call',
    'Existing Customer',
    'Partner',
    'Other'
  ];

  // Industries
  static const List<String> industries = [
    'Technology',
    'Healthcare',
    'Finance',
    'Manufacturing',
    'Retail',
    'Real Estate',
    'Education',
    'Construction',
    'Hospitality',
    'Transportation',
    'Agriculture',
    'Energy',
    'Other'
  ];

  // Field names for controllers
  static const Map<String, String> fieldLabels = {
    'clientName': 'Client Name',
    'companyName': 'Company Name',
    'primaryNumber': 'Primary Number',
    'secondaryNumber': 'Secondary Number',
    'email': 'Email Address',
    'website': 'Website',
    'address': 'Street Address',
    'zipCode': 'ZIP Code',
    'description': 'Description',
    'additionalNotes': 'Additional Notes',
  };

  // Field hints
  static const Map<String, String> fieldHints = {
    'clientName': 'Enter Client Name',
    'companyName': 'Enter Company Name',
    'primaryNumber': '9876543210',
    'secondaryNumber': '9876543210',
    'email': 'example@domain.com',
    'website': 'https://example.com',
    'address': 'Enter complete address',
    'zipCode': 'Enter ZIP Code',
    'description': 'Enter description about the lead...',
    'additionalNotes': 'Enter any additional notes...',
  };

  // Field icons
  static const Map<String, IconData> fieldIcons = {
    'clientName': Icons.person_outline_rounded,
    'companyName': Icons.business_outlined,
    'primaryNumber': Icons.phone_iphone_rounded,
    'secondaryNumber': Icons.phone_outlined,
    'email': Icons.alternate_email_rounded,
    'website': Icons.language_rounded,
    'address': Icons.location_city_outlined,
    'zipCode': Icons.pin_drop_outlined,
    'description': Icons.notes_rounded,
    'additionalNotes': Icons.note_add_outlined,
  };

  // Required fields
  static const List<String> requiredFields = [
    'clientName',
    'companyName',
    'primaryNumber',
  ];
}
