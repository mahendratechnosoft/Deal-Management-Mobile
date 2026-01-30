import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/app_button.dart';
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
import '../../data/model/lead_details_model.dart';
import '../widgets/helper_code.dart';

class CreateLeadScreen extends StatefulWidget {
  final bool edit;
  const CreateLeadScreen({super.key, required this.edit});

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

  // Form controllers
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    log('check it is edit ${widget.edit}');
    super.initState();
    _initializeControllers();
    CreateLeadHelper.loadCountries(context);
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

    final bloc = context.read<CreateLeadBloc>();
    final currentState = bloc.state;

    if (currentState is! CreateLeadDataState) return;

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
    if (_selectedLeadSource == null) {
      CreateLeadHelper.showInfoSnackbar(context, 'Please select a lead source');
      return;
    }
    //ac110005-9add-1891-819a-dda683b20017
    //ac110005-9be4-18aa-819c-0dccfd600088

    // Create and submit request
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar:
          CommonAppBar(title: !widget.edit ? 'Create Leads' : "Update Lead"),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CreateLeadBloc, CreateLeadState>(
            listener: _handleBlocListeners,
          ),
          BlocListener<LeadBloc, LeadState>(
            listener: _handleAllLeadListener,
          ),
        ],
        child: BlocBuilder<CreateLeadBloc, CreateLeadState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  void _handleAllLeadListener(BuildContext context, LeadState state) {
    if (state is AllLeadState && state.leadDetailsModel != null) {
      _prefillFromLeadDetails(state.leadDetailsModel!);
    }
  }

  void _prefillFromLeadDetails(LeadDetailsModel lead) {
    _editingLeadId = lead.lead.id; // 👈 set ONLY in edit
    _existingLeadStatus = lead.lead.status;
    _controllers['clientName']?.text = lead.lead.clientName;
    _controllers['companyName']?.text = lead.lead.companyName;
    _controllers['primaryNumber']?.text = lead.lead.mobileNumber;
    _controllers['secondaryNumber']?.text = lead.lead.phoneNumber;
    _controllers['email']?.text = lead.lead.email;
    _controllers['website']?.text = lead.lead.website;
    _controllers['address']?.text = lead.lead.street;
    _controllers['zipCode']?.text = lead.lead.zipCode;

    _descriptionController.text = lead.lead.description;

    // Check for null/empty before parsing date
    if (lead.lead.followUp != null && lead.lead.followUp!.isNotEmpty) {
      try {
        _selectedFollowUpDate = DateTime.parse(lead.lead.followUp!);
      } catch (e) {
        _selectedFollowUpDate = null;
      }
    }

    setState(() {
      _selectedLeadSource = lead.lead.source;
      _selectedIndustry = lead.lead.industry;
    });
  }

  void _handleBlocListeners(BuildContext context, CreateLeadState state) {
    if (state is CreateLeadSuccess) {
      CreateLeadHelper.showSuccessSnackbar(context);
      Navigator.pop(context, true);
    } else if (state is CreateLeadError) {
      CreateLeadHelper.showErrorSnackbar(context, state.message);
    } else if (state is CreateLeadDataState && state.error != null) {
      CreateLeadHelper.showErrorSnackbar(context, state.error!);
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
      return CreateLeadHelper.buildSuccessView(
        onBackPressed: () => Navigator.pop(context),
      );
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
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _buildFormContainer(context, state),
        ),
      ),
    );
  }

  Widget _buildFormContainer(BuildContext context, CreateLeadDataState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information Section
          CreateLeadHelper.buildSectionHeader('Basic Information'),
          const SizedBox(height: 20),
          _buildBasicInformationFields(),
          const SizedBox(height: 16),
          _buildLocationDropdowns(context, state),
          const SizedBox(height: 16),
          _buildZipCodeField(),
          const SizedBox(height: 24),

          // Lead Information Section
          CreateLeadHelper.buildSectionHeader('Lead Information'),
          const SizedBox(height: 20),
          _buildLeadInformationFields(state),
          const SizedBox(height: 16),
          _buildDescriptionAndNotes(),
          const SizedBox(height: 24),

          // Error message
          if (state.error != null && state.error!.isNotEmpty)
            CreateLeadHelper.buildErrorMessage(state.error!),

          // Submit button
          _buildSubmitButton(state),
        ],
      ),
    );
  }

  // ======================== Helper Methods ========================

  // Helper to find matching string in list
  String? _findMatchingString(String? value, List<String> list) {
    if (value == null || value.isEmpty || list.isEmpty) return null;

    // Direct match
    if (list.contains(value)) return value;

    // Case-insensitive match
    for (var item in list) {
      if (item.toLowerCase() == value.toLowerCase()) {
        return item;
      }
    }

    return null;
  }

  // Helper to find matching object in list by name
  T? _findMatchingObject<T>(
      T? selected, List<T> items, String Function(T) getName) {
    if (selected == null || items.isEmpty) return null;

    final selectedName = getName(selected);
    for (var item in items) {
      if (getName(item) == selectedName) {
        return item;
      }
    }

    return null;
  }

  // ======================== Form Sections ========================

  Widget _buildBasicInformationFields() {
    return Column(
      children: [
        _buildClientNameField(),
        const SizedBox(height: 16),
        _buildCompanyNameField(),
        const SizedBox(height: 16),
        _buildPrimaryNumberField(),
        const SizedBox(height: 16),
        _buildSecondaryNumberField(),
        const SizedBox(height: 16),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildWebsiteField(),
        const SizedBox(height: 16),
        _buildAddressField(),
      ],
    );
  }

  Widget _buildLeadInformationFields(CreateLeadDataState state) {
    return Column(
      children: [
        _buildLeadSourceDropdown(),
        const SizedBox(height: 16),
        _buildIndustryDropdown(),
        const SizedBox(height: 16),
        _buildFollowUpDatePicker(),
      ],
    );
  }

  Widget _buildDescriptionAndNotes() {
    return Column(
      children: [
        _buildDescriptionField(),
        const SizedBox(height: 16),
      ],
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
  }) {
    return AppTextField(
      prefixIcon: Icon(CreateLeadConstants.fieldIcons[fieldKey]),
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
      fieldKey: 'primaryNumber',
      isRequired: true,
      keyboardType: TextInputType.number,
      isTenDigitPhone: true,
    );
  }

  Widget _buildSecondaryNumberField() {
    return _buildTextField(
      fieldKey: 'secondaryNumber',
      keyboardType: TextInputType.number,
      isTenDigitPhone: true,
    );
  }

  Widget _buildClientNameField() {
    return _buildTextField(
      fieldKey: 'clientName',
      isRequired: true,
      keyboardType: TextInputType.name,
      validator: Validators.name,
    );
  }

  Widget _buildCompanyNameField() {
    return _buildTextField(
      fieldKey: 'companyName',
      isRequired: true,
      keyboardType: TextInputType.name,
      validator: (v) => Validators.required(v, 'Company Name'),
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      fieldKey: 'email',
      keyboardType: TextInputType.emailAddress,
      validator: Validators.email,
    );
  }

  Widget _buildWebsiteField() {
    return _buildTextField(
      fieldKey: 'website',
      keyboardType: TextInputType.url,
      validator: Validators.url,
    );
  }

  Widget _buildAddressField() {
    return _buildTextField(
      fieldKey: 'address',
      keyboardType: TextInputType.streetAddress,
      maxLines: 2,
    );
  }

  Widget _buildZipCodeField() {
    return _buildTextField(
      fieldKey: 'zipCode',
      keyboardType: TextInputType.text,
      validator: Validators.zip,
    );
  }

  Widget _buildDescriptionField() {
    return AppTextField(
      showLabel: true,
      keyboardType: TextInputType.multiline,
      labelText: 'Description',
      hint: 'Enter description about the lead...',
      controller: _descriptionController,
      maxLines: 4,
    );
  }

  // ======================== Dropdown Widgets ========================

  Widget _buildLeadSourceDropdown() {
    final matchingSource = _findMatchingString(
        _selectedLeadSource, CreateLeadConstants.leadSources);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('Lead Source', isRequired: true),
        const SizedBox(height: 8),
        DropdownFlutter<String>(
          initialItem: matchingSource,
          decoration: CustomDropdownDecoration(
            closedBorder: Border.all(color: AppColors.border),
          ),
          hintText: 'Select Lead Source',
          items: CreateLeadConstants.leadSources,
          onChanged: (value) => setState(() => _selectedLeadSource = value),
        ),
      ],
    );
  }

  Widget _buildIndustryDropdown() {
    final matchingIndustry =
        _findMatchingString(_selectedIndustry, CreateLeadConstants.industries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('Industry'),
        const SizedBox(height: 8),
        DropdownFlutter<String>(
          initialItem: matchingIndustry,
          decoration: CustomDropdownDecoration(
            closedBorder: Border.all(color: AppColors.border),
          ),
          hintText: 'Select Industry',
          items: CreateLeadConstants.industries,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('Country', isRequired: true),
        const SizedBox(height: 8),
        state.countriesLoading
            ? CreateLeadHelper.buildDropdownLoading()
            : DropdownFlutter<CountryName>.search(
                initialItem: matchingCountry,
                decoration: CustomDropdownDecoration(
                  closedBorder: Border.all(color: AppColors.border),
                ),
                hintText: 'Select Country',
                items: state.countries,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('State'),
        const SizedBox(height: 8),
        state.statesLoading
            ? CreateLeadHelper.buildDropdownLoading()
            : DropdownFlutter<StateName>.search(
                initialItem: matchingState,
                decoration: CustomDropdownDecoration(
                  closedBorder: Border.all(color: AppColors.border),
                ),
                hintText: 'Select State',
                items: state.states,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('City'),
        const SizedBox(height: 8),
        state.citiesLoading
            ? CreateLeadHelper.buildDropdownLoading()
            : DropdownFlutter<CityName>.search(
                initialItem: matchingCity,
                decoration: CustomDropdownDecoration(
                  closedBorder: Border.all(color: AppColors.border),
                ),
                hintText: 'Select City',
                items: state.cities,
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

  // ======================== Submit Button ========================

  Widget _buildSubmitButton(CreateLeadDataState state) {
    return state.submitting
        ? const Center(child: CircularProgressIndicator())
        : Button(
            text: widget.edit ? 'Update Lead' : 'Create Lead',
            onPressed: widget.edit ? _updateLead : _onSubmit,
          );
  }
}
