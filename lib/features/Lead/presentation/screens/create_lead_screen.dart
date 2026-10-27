import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/utils/validators.dart';
import 'package:xpertbiz/core/widgtes/custom_date_picker.dart';
import 'package:xpertbiz/features/Lead/bloc/bloc.dart';
import 'package:xpertbiz/features/Lead/bloc/state.dart'
    hide
        CreateLeadSuccess,
        CreateLeadError,
        CreateLeadLoading,
        CreateLeadInitial;
import 'package:xpertbiz/features/Lead/create_lead_bloc.dart/create_bloc.dart';
import 'package:xpertbiz/features/Lead/create_lead_bloc.dart/create_event.dart';
import 'package:xpertbiz/features/Lead/create_lead_bloc.dart/create_state.dart';
import 'package:xpertbiz/features/Lead/data/model/create_lead_payload.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/search_dropdown.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';
import '../widgets/helper_code.dart';

class CreateLeadScreen extends StatefulWidget {
  final bool edit;
  final dynamic initialLead;
  const CreateLeadScreen({super.key, required this.edit, this.initialLead});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _additionalNoteController = TextEditingController();

  String? _selectedLeadSource;
  String? _selectedIndustry;
  DateTime? _selectedFollowUpDate;
  String? _editingLeadId;
  String? _existingLeadStatus;
  LoginResponse? user;
  bool access = true;

  // Pending location to match once countries/states/cities load
  String? _pendingCountry;
  String? _pendingState;
  String? _pendingCity;

  void accessStatus() {
    if (widget.edit == true) {
      access = user?.moduleAccess.leadEdit ?? true;
    } else {
      access = user?.moduleAccess.leadCreate ?? true;
    }
  }

  // Form controllers
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    user = AuthLocalStorage.getUser();
    log('check it is edit ${widget.edit}');
    super.initState();
    _initializeControllers();
    accessStatus();

    if (widget.edit) {
      dynamic lead = widget.initialLead;
      if (lead == null) {
        final leadState = context.read<LeadBloc>().state;
        if (leadState is AllLeadState && leadState.leadDetailsModel != null) {
          lead = leadState.leadDetailsModel!.lead;
        }
      }
      if (lead != null) {
        _prefillFromLead(lead);
      }
    } else {
      context.read<CreateLeadBloc>().add(const ClearLocationEvent());
    }

    CreateLeadHelper.loadCountries(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final createBlocState = context.read<CreateLeadBloc>().state;
        if (createBlocState is CreateLeadDataState) {
          _syncPendingLocation(createBlocState);
        }
      }
    });
  }

  void _initializeControllers() {
    for (var key in CreateLeadConstants.fieldLabels.keys) {
      _controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _additionalNoteController.dispose();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _updateLead() {
    log('updated lead');
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<CreateLeadBloc>();
    final currentState = bloc.state;
    if (currentState is! CreateLeadDataState) return;

    if (currentState.selectedCountry == null) {
      CreateLeadHelper.showInfoSnackbar(context, 'Please select a country');
      return;
    }

    if (_selectedLeadSource == null || _selectedLeadSource!.trim().isEmpty) {
      CreateLeadHelper.showInfoSnackbar(context, 'Please select a lead source');
      return;
    }

    final request = _buildCreateLeadRequest(currentState);
    bloc.add(SubmitCreateLeadEvent(request, true));
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<CreateLeadBloc>();
    final currentState = bloc.state;
    if (currentState is! CreateLeadDataState) return;

    // Validate required country selection
    if (currentState.selectedCountry == null) {
      CreateLeadHelper.showInfoSnackbar(context, 'Please select a country');
      return;
    }

    // Validate required lead source
    if (_selectedLeadSource == null || _selectedLeadSource!.trim().isEmpty) {
      CreateLeadHelper.showInfoSnackbar(context, 'Please select a lead source');
      return;
    }

    final request = _buildCreateLeadRequest(currentState);
    bloc.add(SubmitCreateLeadEvent(request, false));
  }

  CreateLeadRequest _buildCreateLeadRequest(CreateLeadDataState state) {
    return CreateLeadRequest(
      id: widget.edit ? _editingLeadId : null,
      companyName: _controllers['companyName']!.text.trim(),
      clientName: _controllers['clientName']!.text.trim(),
      status: widget.edit ? (_existingLeadStatus ?? 'New Lead') : 'New Lead',
      source: _selectedLeadSource ?? '',
      revenue: 0,
      mobileNumber: CreateLeadHelper.formatPhoneNumber(
        _controllers['primaryNumber']!.text.trim(),
        state.selectedCountry?.code,
      ),
      phoneNumber: _controllers['secondaryNumber']!.text.trim().isNotEmpty
          ? CreateLeadHelper.formatPhoneNumber(
              _controllers['secondaryNumber']!.text.trim(),
              state.selectedCountry?.code,
            )
          : null,
      email: _controllers['email']!.text.trim(),
      website: _controllers['website']!.text.trim(),
      industry: _selectedIndustry,
      street: _controllers['address']!.text.trim(),
      country: state.selectedCountry?.name,
      state: state.selectedState?.name,
      city: state.selectedCity?.name,
      zipCode: _controllers['zipCode']!.text.trim(),
      description: _descriptionController.text.trim(),
      followUp: CreateLeadHelper.formatDateForApi(_selectedFollowUpDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateLeadBloc, CreateLeadState>(
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: CommonAppBar(
            title: !widget.edit ? 'Create New Lead' : 'Update Lead',
          ),
          bottomNavigationBar: state is CreateLeadDataState
              ? _buildBottomActionBar(state)
              : null,
          body: MultiBlocListener(
            listeners: [
              BlocListener<CreateLeadBloc, CreateLeadState>(
                listener: _handleBlocListeners,
              ),
              BlocListener<LeadBloc, LeadState>(
                listener: _handleAllLeadListener,
              ),
            ],
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  void _handleAllLeadListener(BuildContext context, LeadState state) {
    if (widget.edit && state is AllLeadState && state.leadDetailsModel != null) {
      if (_editingLeadId == null ||
          _editingLeadId != state.leadDetailsModel!.lead.id) {
        _prefillFromLead(state.leadDetailsModel!.lead);
      }
    }
  }

  void _prefillFromLead(dynamic lead) {
    if (lead == null) return;

    try {
      final String id = (lead.id ?? '').toString();
      final String status = (lead.status ?? 'New Lead').toString();
      final String clientName = (lead.clientName ?? '').toString();
      final String companyName = (lead.companyName ?? '').toString();
      final String mobileNumber = (lead.mobileNumber ?? '').toString();
      final String phoneNumber = (lead.phoneNumber ?? '').toString();
      final String email = (lead.email ?? '').toString();
      final String website = (lead.website ?? '').toString();
      final String street = (lead.street ?? '').toString();
      final String zipCode = (lead.zipCode ?? '').toString();
      final String description = (lead.description ?? '').toString();
      final dynamic followUp = lead.followUp;
      final String source = (lead.source ?? '').toString();
      final String industry = (lead.industry ?? '').toString();
      final String country = (lead.country ?? '').toString();
      final String state = (lead.state ?? '').toString();
      final String city = (lead.city ?? '').toString();

      _editingLeadId = id;
      _existingLeadStatus = status;

      _controllers['clientName']?.text = clientName;
      _controllers['companyName']?.text = companyName;
      _controllers['primaryNumber']?.text = _extractTenDigits(mobileNumber);
      _controllers['secondaryNumber']?.text = _extractTenDigits(phoneNumber);
      _controllers['email']?.text = email;
      _controllers['website']?.text = website;
      _controllers['address']?.text = street;
      _controllers['zipCode']?.text = zipCode;

      _descriptionController.text = description;

      if (followUp != null) {
        if (followUp is DateTime) {
          _selectedFollowUpDate = followUp;
        } else {
          final str = followUp.toString().trim();
          if (str.isNotEmpty) {
            try {
              _selectedFollowUpDate = DateTime.parse(str).toLocal();
            } catch (e) {
              log('Error parsing follow-up date: $e');
            }
          }
        }
      }

      _selectedLeadSource = source.isNotEmpty ? source : null;
      _selectedIndustry = industry.isNotEmpty ? industry : null;

      _pendingCountry = country.trim().isNotEmpty ? country.trim() : null;
      _pendingState = state.trim().isNotEmpty ? state.trim() : null;
      _pendingCity = city.trim().isNotEmpty ? city.trim() : null;

      setState(() {});
    } catch (e) {
      log('Error prefilling lead details: $e');
    }
  }

  String _extractTenDigits(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length > 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  void _syncPendingLocation(CreateLeadDataState state) {
    // 1. Sync Country
    if (_pendingCountry != null && _pendingCountry!.isNotEmpty) {
      if (!state.countriesLoading && state.countries.isNotEmpty) {
        CountryName? match;
        for (var c in state.countries) {
          if (c.name.trim().toLowerCase() == _pendingCountry!.toLowerCase() ||
              c.code.trim().toLowerCase() == _pendingCountry!.toLowerCase()) {
            match = c;
            break;
          }
        }
        match ??= CountryName(name: _pendingCountry!, code: _pendingCountry!);
        _pendingCountry = null;
        if (state.selectedCountry == null ||
            state.selectedCountry!.code != match.code) {
          context.read<CreateLeadBloc>().add(CountrySelectedEvent(match));
          return;
        }
      }
    }

    // 2. Sync State
    if (_pendingState != null && _pendingState!.isNotEmpty) {
      if (state.selectedCountry != null && !state.statesLoading) {
        StateName? match;
        for (var s in state.states) {
          if (s.name.trim().toLowerCase() == _pendingState!.toLowerCase() ||
              s.code.trim().toLowerCase() == _pendingState!.toLowerCase()) {
            match = s;
            break;
          }
        }
        match ??= StateName(
          name: _pendingState!,
          code: _pendingState!,
          countryCode: state.selectedCountry!.code,
        );
        _pendingState = null;
        if (state.selectedState == null ||
            state.selectedState!.code != match.code) {
          context.read<CreateLeadBloc>().add(StateSelectedEvent(match));
          return;
        }
      }
    }

    // 3. Sync City
    if (_pendingCity != null && _pendingCity!.isNotEmpty) {
      if (state.selectedState != null && !state.citiesLoading) {
        CityName? match;
        for (var c in state.cities) {
          if (c.name.trim().toLowerCase() == _pendingCity!.toLowerCase() ||
              c.code.trim().toLowerCase() == _pendingCity!.toLowerCase()) {
            match = c;
            break;
          }
        }
        match ??= CityName(
          name: _pendingCity!,
          code: _pendingCity!,
          stateCode: state.selectedState!.code,
          countryCode: state.selectedCountry?.code ?? '',
        );
        _pendingCity = null;
        if (state.selectedCity == null ||
            state.selectedCity!.code != match.code) {
          context.read<CreateLeadBloc>().add(CitySelectedEvent(match));
        }
      }
    }
  }

  void _handleBlocListeners(BuildContext context, CreateLeadState state) {
    if (state is CreateLeadSuccess) {
      CreateLeadHelper.showSuccessSnackbar(context);
      Navigator.pop(context, true);
    } else if (state is CreateLeadError) {
      CreateLeadHelper.showErrorSnackbar(context, state.message);
    } else if (state is CreateLeadDataState) {
      if (state.error != null) {
        CreateLeadHelper.showErrorSnackbar(context, state.error!);
      }
      _syncPendingLocation(state);
    }
  }

  Widget _buildBody(BuildContext context, CreateLeadState state) {
    if (state is CreateLeadInitial) {
      return CreateLeadHelper.buildLoadingView('Initializing...');
    }

    if (state is CreateLeadLoading) {
      return CreateLeadHelper.buildLoadingView(state.message ?? 'Loading...');
    }

    if (state is CreateLeadError) {
      return CreateLeadHelper.buildErrorView(
        message: state.message,
        onRetry: () => CreateLeadHelper.retryLoadCountries(context),
      );
    }

    if (state is CreateLeadSuccess) {
      return CreateLeadHelper.buildSuccessView(onBackPressed: () {
        Navigator.pop(context, true);
      });
    }

    if (state is CreateLeadDataState) {
      if (state.countries.isEmpty && state.countriesLoading) {
        return CreateLeadHelper.buildLoadingView('Loading countries...');
      }
      return _buildForm(context, state);
    }

    return CreateLeadHelper.buildLoadingView('Loading...');
  }

  Widget _buildForm(BuildContext context, CreateLeadDataState state) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // View-only banner if permission missing
            if (!access) _buildReadOnlyBanner(),

            // Card 1: Basic Company & Client Info
            _buildSectionCard(
              icon: Icons.business_center_rounded,
              title: 'Company & Client',
              subtitle: 'Primary account details and lead origin',
              children: [
                _buildClientNameField(),
                const SizedBox(height: 16),
                _buildCompanyNameField(),
                const SizedBox(height: 16),
                _buildLeadSourceDropdown(),
                const SizedBox(height: 16),
                _buildIndustryDropdown(),
              ],
            ),

            // Card 2: Contact Information
            _buildSectionCard(
              icon: Icons.contact_phone_rounded,
              title: 'Contact Details',
              subtitle: 'Direct communication channels',
              children: [
                _buildPrimaryNumberField(),
                const SizedBox(height: 16),
                _buildSecondaryNumberField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildWebsiteField(),
              ],
            ),

            // Card 3: Location Details
            _buildSectionCard(
              icon: Icons.location_on_rounded,
              title: 'Location & Address',
              subtitle: 'Territory and physical address',
              children: [
                _buildLocationDropdowns(context, state),
                const SizedBox(height: 16),
                _buildAddressField(),
                const SizedBox(height: 16),
                _buildZipCodeField(),
              ],
            ),

            // Card 4: Pipeline & Notes
            _buildSectionCard(
              icon: Icons.event_note_rounded,
              title: 'Pipeline & Notes',
              subtitle: 'Next follow-up interaction and context',
              children: [
                _buildFollowUpDatePicker(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
              ],
            ),

            if (state.error != null && state.error!.isNotEmpty)
              CreateLeadHelper.buildErrorMessage(state.error!),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFFD97706)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You have read-only access. Form fields are disabled.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Section Card Container
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ======================== Helper Methods ========================

  String? _findMatchingString(String? value, List<String> list) {
    if (value == null || value.isEmpty || list.isEmpty) return null;
    if (list.contains(value)) return value;
    for (var item in list) {
      if (item.toLowerCase() == value.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  T? _findMatchingObject<T>(
      T? selected, List<T> items, String Function(T) getName) {
    if (selected == null || items.isEmpty) return selected;
    final selectedName = getName(selected).trim().toLowerCase();
    for (var item in items) {
      if (getName(item).trim().toLowerCase() == selectedName) {
        return item;
      }
    }
    return selected;
  }

  CustomDropdownDecoration _dropdownDecoration({bool hasError = false}) {
    return CustomDropdownDecoration(
      closedFillColor: Colors.white,
      closedBorder: Border.all(
        color: hasError ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
        width: 1.1,
      ),
      closedBorderRadius: BorderRadius.circular(10),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      headerStyle: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ======================== Field Widgets ========================

  Widget _buildTextField({
    required String fieldKey,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool isTenDigitPhone = false,
    bool enable = true,
  }) {
    return AppTextField(
      enabled: enable,
      prefixIcon: Icon(
        CreateLeadConstants.fieldIcons[fieldKey],
        size: 20,
        color: const Color(0xFF64748B),
      ),
      showLabel: true,
      keyboardType: keyboardType,
      validator: validator,
      isRequired: isRequired,
      isTenDigitPhone: isTenDigitPhone,
      labelText: CreateLeadConstants.fieldLabels[fieldKey]!,
      hint: CreateLeadConstants.fieldHints[fieldKey]!,
      controller: _controllers[fieldKey]!,
      maxLines: maxLines,
    );
  }

  Widget _buildPrimaryNumberField() {
    return _buildTextField(
      enable: access,
      fieldKey: 'primaryNumber',
      isRequired: true,
      keyboardType: TextInputType.number,
      isTenDigitPhone: true,
    );
  }

  Widget _buildSecondaryNumberField() {
    return _buildTextField(
      enable: access,
      fieldKey: 'secondaryNumber',
      keyboardType: TextInputType.number,
      isTenDigitPhone: true,
    );
  }

  Widget _buildClientNameField() {
    return _buildTextField(
      enable: access,
      fieldKey: 'clientName',
      isRequired: true,
      keyboardType: TextInputType.name,
      validator: Validators.name,
    );
  }

  Widget _buildCompanyNameField() {
    return _buildTextField(
      enable: access,
      fieldKey: 'companyName',
      isRequired: true,
      keyboardType: TextInputType.name,
      validator: (v) => Validators.required(v, 'Company Name'),
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      isRequired: true,
      enable: access,
      fieldKey: 'email',
      keyboardType: TextInputType.emailAddress,
      validator: Validators.email,
    );
  }

  Widget _buildWebsiteField() {
    return _buildTextField(
      enable: access,
      fieldKey: 'website',
      keyboardType: TextInputType.url,
      validator: Validators.url,
    );
  }

  Widget _buildAddressField() {
    return _buildTextField(
      enable: access,
      fieldKey: 'address',
      keyboardType: TextInputType.streetAddress,
      maxLines: 2,
    );
  }

  Widget _buildZipCodeField() {
    return _buildTextField(
      enable: access,
      fieldKey: 'zipCode',
      keyboardType: TextInputType.text,
      validator: Validators.zip,
    );
  }

  Widget _buildDescriptionField() {
    return AppTextField(
      enabled: access,
      showLabel: true,
      keyboardType: TextInputType.multiline,
      labelText: 'Description / Notes',
      hint: 'Enter relevant background notes, deal requirements or context...',
      controller: _descriptionController,
      maxLines: 4,
    );
  }

  // ======================== Dropdown Widgets ========================

  Widget _buildLeadSourceDropdown() {
    final sources = List<String>.from(CreateLeadConstants.leadSources);
    if (_selectedLeadSource != null &&
        _selectedLeadSource!.trim().isNotEmpty &&
        !sources.any((s) =>
            s.trim().toLowerCase() == _selectedLeadSource!.trim().toLowerCase())) {
      sources.add(_selectedLeadSource!.trim());
    }

    final matchingSource =
        _findMatchingString(_selectedLeadSource, sources);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('Lead Source', isRequired: true),
        const SizedBox(height: 8),
        DropdownFlutter<String>(
          key: ValueKey('lead_source_${matchingSource ?? _selectedLeadSource}'),
          enabled: access,
          initialItem: matchingSource ?? _selectedLeadSource,
          decoration: _dropdownDecoration(),
          hintText: 'Select Lead Source',
          items: sources,
          onChanged: (value) => setState(() => _selectedLeadSource = value),
        ),
      ],
    );
  }

  Widget _buildIndustryDropdown() {
    final industries = List<String>.from(CreateLeadConstants.industries);
    if (_selectedIndustry != null &&
        _selectedIndustry!.trim().isNotEmpty &&
        !industries.any((i) =>
            i.trim().toLowerCase() == _selectedIndustry!.trim().toLowerCase())) {
      industries.add(_selectedIndustry!.trim());
    }

    final matchingIndustry =
        _findMatchingString(_selectedIndustry, industries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('Industry'),
        const SizedBox(height: 8),
        DropdownFlutter<String>(
          key: ValueKey('industry_${matchingIndustry ?? _selectedIndustry}'),
          enabled: access,
          initialItem: matchingIndustry ?? _selectedIndustry,
          decoration: _dropdownDecoration(),
          hintText: 'Select Industry',
          items: industries,
          onChanged: (value) => setState(() => _selectedIndustry = value),
        ),
      ],
    );
  }

  Widget _buildFollowUpDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('Follow-Up Date & Time'),
        const SizedBox(height: 8),
        CustomDatePicker(
          key: ValueKey(_selectedFollowUpDate),
          enabled: access,
          selectedDate: _selectedFollowUpDate,
          showLabel: false,
          labelText: '',
          hintText: 'Select Follow-Up Date & Time',
          onDateSelected: (date) =>
              setState(() => _selectedFollowUpDate = date),
        ),
      ],
    );
  }

  // ======================== Location Dropdowns ========================

  Widget _buildLocationDropdowns(
      BuildContext context, CreateLeadDataState state) {
    return Column(
      children: [
        _buildCountryDropdown(context, state),
        if (state.selectedCountry != null) const SizedBox(height: 16),
        if (state.selectedCountry != null) _buildStateDropdown(context, state),
        if (state.selectedState != null) const SizedBox(height: 16),
        if (state.selectedState != null) _buildCityDropdown(context, state),
      ],
    );
  }

  Widget _buildCountryDropdown(
      BuildContext context, CreateLeadDataState state) {
    final matchingCountry = _findMatchingObject(
      state.selectedCountry,
      state.countries,
      (country) => country.name,
    );

    final List<CountryName> countryItems =
        List<CountryName>.from(state.countries);
    if (state.selectedCountry != null &&
        !countryItems.any((c) =>
            c.code == state.selectedCountry!.code ||
            c.name.toLowerCase() ==
                state.selectedCountry!.name.toLowerCase())) {
      countryItems.insert(0, state.selectedCountry!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('Country', isRequired: true),
        const SizedBox(height: 8),
        state.countriesLoading
            ? CreateLeadHelper.buildDropdownLoading()
            : DropdownFlutter<CountryName>.search(
                key: ValueKey('country_${state.selectedCountry?.code}'),
                enabled: access,
                initialItem: matchingCountry ?? state.selectedCountry,
                decoration: _dropdownDecoration(),
                hintText: 'Select Country',
                items: countryItems,
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<CreateLeadBloc>()
                        .add(CountrySelectedEvent(value));
                  }
                },
              ),
      ],
    );
  }

  Widget _buildStateDropdown(BuildContext context, CreateLeadDataState state) {
    final matchingState = _findMatchingObject(
      state.selectedState,
      state.states,
      (stateObj) => stateObj.name,
    );

    final List<StateName> stateItems = List<StateName>.from(state.states);
    if (state.selectedState != null &&
        !stateItems.any((s) =>
            s.name.toLowerCase() ==
            state.selectedState!.name.toLowerCase())) {
      stateItems.insert(0, state.selectedState!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('State'),
        const SizedBox(height: 8),
        state.statesLoading
            ? CreateLeadHelper.buildDropdownLoading()
            : DropdownFlutter<StateName>.search(
                key: ValueKey(
                    'state_${state.selectedState?.code}_${state.selectedState?.name}'),
                enabled: access,
                initialItem: matchingState ?? state.selectedState,
                decoration: _dropdownDecoration(),
                hintText: 'Select State',
                items: stateItems,
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<CreateLeadBloc>()
                        .add(StateSelectedEvent(value));
                  }
                },
              ),
      ],
    );
  }

  Widget _buildCityDropdown(BuildContext context, CreateLeadDataState state) {
    final matchingCity = _findMatchingObject(
      state.selectedCity,
      state.cities,
      (city) => city.name,
    );

    final List<CityName> cityItems = List<CityName>.from(state.cities);
    if (state.selectedCity != null &&
        !cityItems.any((c) =>
            c.name.toLowerCase() ==
            state.selectedCity!.name.toLowerCase())) {
      cityItems.insert(0, state.selectedCity!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('City'),
        const SizedBox(height: 8),
        state.citiesLoading
            ? CreateLeadHelper.buildDropdownLoading()
            : DropdownFlutter<CityName>.search(
                key: ValueKey('city_${state.selectedCity?.name}'),
                enabled: access,
                initialItem: matchingCity ?? state.selectedCity,
                decoration: _dropdownDecoration(),
                hintText: 'Select City',
                items: cityItems,
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<CreateLeadBloc>()
                        .add(CitySelectedEvent(value));
                  }
                },
              ),
      ],
    );
  }

  // ======================== Sticky Bottom Bar ========================

  Widget _buildBottomActionBar(CreateLeadDataState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: access
                    ? (state.submitting
                        ? null
                        : (widget.edit ? _updateLead : _onSubmit))
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  disabledBackgroundColor: const Color(0xFF93C5FD),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.edit
                                ? Icons.save_outlined
                                : Icons.add_circle_outline_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.edit ? 'Update Lead' : 'Create Lead',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
