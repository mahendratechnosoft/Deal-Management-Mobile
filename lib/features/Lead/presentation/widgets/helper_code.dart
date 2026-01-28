import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
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
      const SnackBar(
        content: Text('Lead created successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show info snackbar
  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Build section header
  static Widget buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Build label with optional required indicator
  static Widget buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        children: isRequired
            ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ]
            : [],
      ),
    );
  }

  // Build error message widget
  static Widget buildErrorMessage(String error) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        error,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 14,
        ),
      ),
    );
  }

  // Build loading widget for dropdowns
  static Widget buildDropdownLoading() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  // Build loading view
  static Widget buildLoadingView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Build success view
  static Widget buildSuccessView({VoidCallback? onBackPressed}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          const Text(
            'Lead Created Successfully!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onBackPressed,
            child: const Text('Go Back'),
          ),
        ],
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
          const Icon(Icons.error, color: Colors.red, size: 80),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // NEW: Format phone number with country code
  static String formatPhoneNumber(String phoneNumber, String? countryCode) {
    if (phoneNumber.isEmpty) return phoneNumber;

    // Remove any non-digit characters
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // If already has country code, return as is
    if (phoneNumber.contains('+')) {
      return phoneNumber;
    }

    // Map country codes
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

    String code = countryCodes[countryCode] ?? '+1';
    return '($code) $digits';
  }

  // NEW: Format date for API
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
    'primaryNumber': '+91 9876543210',
    'secondaryNumber': '+91 9876543210',
    'email': 'example@domain.com',
    'website': 'https://example.com',
    'address': 'Enter complete address',
    'zipCode': 'Enter ZIP Code',
    'description': 'Enter description about the lead...',
    'additionalNotes': 'Enter any additional notes...',
  };

  // Field icons
  static const Map<String, IconData> fieldIcons = {
    'clientName': Icons.person,
    'companyName': Icons.business,
    'primaryNumber': Icons.phone_iphone_rounded,
    'secondaryNumber': Icons.phone_iphone_rounded,
    'email': Icons.mail,
    'website': Icons.link,
    'address': Icons.location_city,
    'zipCode': Icons.location_on,
    'description': Icons.description,
    'additionalNotes': Icons.note_add,
  };

  // Required fields
  static const List<String> requiredFields = [
    'clientName',
    'companyName',
    'primaryNumber',
  ];
}
