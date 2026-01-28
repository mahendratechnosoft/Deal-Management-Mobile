import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/app_button.dart';
import 'package:xpertbiz/core/utils/validators.dart';
import 'package:xpertbiz/core/widgtes/custom_date_picker.dart';
import 'package:xpertbiz/features/Lead/create_lead_bloc.dart/create_bloc.dart';
import 'package:xpertbiz/features/Lead/create_lead_bloc.dart/create_event.dart';
import 'package:xpertbiz/features/Lead/create_lead_bloc.dart/create_state.dart';
import 'package:xpertbiz/features/Lead/data/model/create_lead_payload.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/search_dropdown.dart';
import '../widgets/helper_code.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

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

  // Form controllers
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
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

    // Create and submit request
    final request = _buildCreateLeadRequest(currentState);
    bloc.add(SubmitCreateLeadEvent(request));
  }

  CreateLeadRequest _buildCreateLeadRequest(CreateLeadDataState state) {
    return CreateLeadRequest(
      companyName: _controllers['companyName']!.text.trim(),
      clientName: _controllers['clientName']!.text.trim(),
      status: 'New Lead',
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
      appBar: const CommonAppBar(title: 'Create Leads'),
      body: BlocConsumer<CreateLeadBloc, CreateLeadState>(
        listener: _handleBlocListeners,
        builder: (context, state) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _buildBody(context, state),
        ),
      ),
    );
  }

  void _handleBlocListeners(BuildContext context, CreateLeadState state) {
    if (state is CreateLeadSuccess) {
      CreateLeadHelper.showSuccessSnackbar(context);
      Navigator.pop(context);
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
          _buildLeadInformationFields(),
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

  Widget _buildLeadInformationFields() {
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
      isTenDigitPhone: isTenDigitPhone, // <-- Now matches
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
      isTenDigitPhone: true, // <-- Change to match new parameter name
    );
  }

  Widget _buildSecondaryNumberField() {
    return _buildTextField(
      fieldKey: 'secondaryNumber',
      keyboardType: TextInputType.number,
      isTenDigitPhone: true, // <-- Change to match new parameter name
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('Lead Source', isRequired: true),
        const SizedBox(height: 8),
        DropdownFlutter<String>(
          initialItem: _selectedLeadSource,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('Industry'),
        const SizedBox(height: 8),
        DropdownFlutter<String>(
          initialItem: _selectedIndustry,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('Country', isRequired: true),
        const SizedBox(height: 8),
        state.countriesLoading
            ? CreateLeadHelper.buildDropdownLoading()
            : DropdownFlutter<CountryName>.search(
                initialItem: state.selectedCountry,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('State'),
        const SizedBox(height: 8),
        state.statesLoading
            ? CreateLeadHelper.buildDropdownLoading()
            : DropdownFlutter<StateName>.search(
                initialItem: state.selectedState,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('City'),
        const SizedBox(height: 8),
        state.citiesLoading
            ? CreateLeadHelper.buildDropdownLoading()
            : DropdownFlutter<CityName>.search(
                initialItem: state.selectedCity,
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
            text: 'Create Lead',
            onPressed: _onSubmit,
          );
  }
}
