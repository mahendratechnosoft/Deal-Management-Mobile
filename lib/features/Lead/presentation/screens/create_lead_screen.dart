import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/app_button.dart';
import 'package:xpertbiz/core/utils/validators.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();

  final cntrClintName = TextEditingController();
  final cntrCompName = TextEditingController();
  final cntrEmail = TextEditingController();
  final cntrAddress = TextEditingController();
  final cntrNumber = TextEditingController();
  final cntrSecondNumber = TextEditingController();
  final cntrUrl = TextEditingController();
  final cntrCoutryCode = TextEditingController();

  @override
  void dispose() {
    cntrClintName.dispose();
    cntrCompName.dispose();
    cntrEmail.dispose();
    cntrAddress.dispose();
    cntrNumber.dispose();
    cntrSecondNumber.dispose();
    cntrUrl.dispose();
    cntrCoutryCode.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Submit payload (later Bloc/API)
    final payload = {
      "clientName": cntrClintName.text.trim(),
      "companyName": cntrCompName.text.trim(),
      "primaryNumber": cntrNumber.text.trim(),
      "secondaryNumber": cntrSecondNumber.text.trim(),
      "email": cntrEmail.text.trim(),
      "website": cntrUrl.text.trim(),
      "address": cntrAddress.text.trim(),
      "zip": cntrCoutryCode.text.trim(),
    };

    debugPrint('Create Lead Payload => $payload');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Create Leads'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),

                  /// Client Name
                  AppTextField(
                    prefixIcon: const Icon(Icons.person),
                    showLabel: true,
                    keyboardType: TextInputType.name,
                    validator: Validators.name,
                    isRequired: true,
                    labelText: 'Client Name',
                    hint: 'Enter Clint Name',
                    controller: cntrClintName,
                  ),

                  SizedBox(height: Responsive.h(16)),

                  /// Company Name
                  AppTextField(
                    prefixIcon: const Icon(Icons.home_repair_service),
                    keyboardType: TextInputType.name,
                    showLabel: true,
                    isRequired: true,
                    validator: (v) => Validators.required(v, 'Company Name'),
                    labelText: 'Company Name',
                    hint: 'Enter Company Name',
                    controller: cntrCompName,
                  ),

                  SizedBox(height: Responsive.h(16)),

                  /// Primary Number
                  AppTextField(
                    prefixIcon: const Icon(Icons.phone_iphone_rounded),
                    showLabel: true,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                    validator: Validators.phone,
                    labelText: 'Primary Number',
                    hint: '+91',
                    controller: cntrNumber,
                  ),

                  SizedBox(height: Responsive.h(16)),

                  /// Secondary Number
                  AppTextField(
                    prefixIcon: const Icon(Icons.phone_iphone_rounded),
                    showLabel: true,
                    keyboardType: TextInputType.number,
                    labelText: 'Secondary Number',
                    hint: '+91',
                    controller: cntrSecondNumber,
                  ),

                  SizedBox(height: Responsive.h(16)),

                  /// Email
                  AppTextField(
                    prefixIcon: const Icon(Icons.mail),
                    showLabel: true,
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Email Address',
                    hint: 'Enter Email Address',
                    controller: cntrEmail,
                  ),

                  SizedBox(height: Responsive.h(16)),

                  /// Website
                  AppTextField(
                    prefixIcon: const Icon(Icons.link),
                    showLabel: true,
                    keyboardType: TextInputType.url,
                    validator: Validators.url,
                    labelText: 'Website',
                    hint: 'Enter Website URL',
                    controller: cntrUrl,
                  ),

                  SizedBox(height: Responsive.h(16)),

                  /// Street Address
                  AppTextField(
                    prefixIcon: const Icon(Icons.location_city),
                    showLabel: true,
                    keyboardType: TextInputType.streetAddress,
                    labelText: 'Street Address',
                    hint: 'Enter Street Address',
                    controller: cntrAddress,
                  ),

                  SizedBox(height: Responsive.h(16)),

                  /// ZIP Code
                  AppTextField(
                    prefixIcon: const Icon(Icons.location_on),
                    showLabel: true,
                    keyboardType: TextInputType.text,
                    validator: Validators.zip,
                    labelText: 'ZIP Code',
                    hint: 'Enter ZIP Code',
                    controller: cntrCoutryCode,
                  ),

                  SizedBox(height: Responsive.h(24)),

                  /// SUBMIT BUTTON
                  Button(
                    text: 'Create Lead',
                    onPressed: _onSubmit,
                  ),

                  SizedBox(height: Responsive.h(16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
