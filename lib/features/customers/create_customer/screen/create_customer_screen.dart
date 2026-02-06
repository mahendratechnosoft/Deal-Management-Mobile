import 'dart:developer';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/validators.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_button.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/features/Lead/create_lead_bloc.dart/create_bloc.dart';
import 'package:xpertbiz/features/Lead/create_lead_bloc.dart/create_event.dart';
import 'package:xpertbiz/features/Lead/create_lead_bloc.dart/create_state.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/helper_code.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/search_dropdown.dart';
import 'package:xpertbiz/features/customers/create_customer/bloc/create_customer_bloc.dart';
import 'package:xpertbiz/features/customers/create_customer/bloc/create_customer_event.dart';
import 'package:xpertbiz/features/customers/create_customer/bloc/create_customer_state.dart';
import 'package:xpertbiz/features/customers/create_customer/bloc/model/update_customer_model.dart';
import 'package:xpertbiz/features/customers/create_customer/screen/widgte/box_widget.dart';
import '../../../../core/widgtes/custom_dropdown.dart';
import '../../../auth/data/locale_data/hive_service.dart';
import '../../../auth/data/locale_data/login_response.dart';
import '../bloc/model/customer_payload_model.dart';

class CreateCustomerScreen extends StatefulWidget {
  final bool edit;
  final String? id;
  const CreateCustomerScreen({super.key, required this.edit, this.id});

  @override
  State<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen> {
  LoginResponse? user;
  bool? isEdit;
  bool? isCredit;

  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  late CreateCustomerBloc _customerBloc;
  late CreateLeadBloc _leadBloc;

  // Store location values separately
  String _selectedCountry = '';
  String _selectedState = '';
  String _selectedCity = '';

  // Use ValueNotifier for industry to force UI updates
  final ValueNotifier<String?> _industryNotifier = ValueNotifier<String?>(null);

  // Store IDs from API response
  String _adminId = '';
  String _userId = '';
  String _customerId = '';
  bool status = false;

  TextEditingController _getController(String key) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(),
    );
  }

  void _initializeControllersFromState(CreateCustomerState state) {
    if (state is GetCustomerLoadState) {
      final details = state.response;

      // Store IDs from response
      _adminId = details.adminId;
      _userId = details.userId;
      _customerId = details.customerId;
      status = details.status;

      // Store industry from response (make sure it's not empty)
      if (details.industry.isNotEmpty) {
        _industryNotifier.value = details.industry;
        // Update the bloc state with loaded industry
        _customerBloc.add(IndustrySelectedEvent(details.industry));
      }

      // Fill form fields
      _getController('companyName').text = details.companyName;
      _getController('email').text = details.email ?? '';
      _getController('primaryNumber').text = details.mobile;
      _getController('secondaryNumber').text = details.phone;
      _getController('website').text = details.website;
      _getController('revenue').text = details.revenue;
      _getController('streetAddress').text = details.billingStreet;
      _getController('zipCode').text = details.billingZipCode;
      _getController('gstin').text = details.gstin ?? '';
      _getController('pan').text = details.panNumber ?? '';
      _getController('description').text = details.description;

      // Initialize location values
      _selectedCountry = details.billingCountry;
      _selectedState = details.billingState;
      _selectedCity = details.billingCity;
    }
  }

  void _getDetails() {
    if (widget.edit && widget.id != null) {
      _customerBloc.add(GetCustomerEvent(id: widget.id!));
    }
  }

  void checkAccess() {
    if (widget.edit == true) {
      isEdit = user?.moduleAccess.customerEdit;
    } else {
      isEdit = user?.moduleAccess.customerCreate;
    }
  }

  @override
  void initState() {
    super.initState();
    user = AuthLocalStorage.getUser();
    _customerBloc = context.read<CreateCustomerBloc>();
    _leadBloc = context.read<CreateLeadBloc>();
    checkAccess();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getDetails();
      CreateLeadHelper.loadCountries(context);
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _industryNotifier.dispose();
    super.dispose();
  }

  void _onIndustryChanged(String? value) {
    if (value != null) {
      _industryNotifier.value = value;
      _customerBloc.add(IndustrySelectedEvent(value));
      log('UI selected industry: $value');
    }
  }

  void _onCountryChanged(CountryName? value) {
    if (value != null) {
      _leadBloc.add(CountrySelectedEvent(value));
      _selectedCountry = value.name;
    }
  }

  void _onStateChanged(StateName? value) {
    if (value != null) {
      _leadBloc.add(StateSelectedEvent(value));
      _selectedState = value.name;
    }
  }

  void _onCityChanged(CityName? value) {
    if (value != null) {
      _leadBloc.add(CitySelectedEvent(value));
      _selectedCity = value.name;
    }
  }

  void _updateCustomer() {
    if (_formKey.currentState?.validate() != true) return;

    // Get the current lead state to access selected values
    final leadState = _leadBloc.state;
    String selectedCountry = '';
    String selectedState = '';
    String selectedCity = '';

    if (leadState is CreateLeadDataState) {
      selectedCountry = leadState.selectedCountry?.name ?? _selectedCountry;
      selectedState = leadState.selectedState?.name ?? _selectedState;
      selectedCity = leadState.selectedCity?.name ?? _selectedCity;
    } else {
      // Fallback to stored values
      selectedCountry = _selectedCountry;
      selectedState = _selectedState;
      selectedCity = _selectedCity;
    }

    // Get the current industry value
    String industryValue = _industryNotifier.value ?? '';
    if (industryValue.isEmpty && _customerBloc.state is CustomerFormValid) {
      industryValue =
          (_customerBloc.state as CustomerFormValid).customerForm.industry ??
              '';
    }

    // Get form values from controllers
    final payload = UpdateCustomerRequest(
      employeeId: null,
      customerId: _customerId.isNotEmpty ? _customerId : widget.id ?? '',
      adminId: _adminId,
      companyName: _getController('companyName').text.trim(),
      phone: _getController('primaryNumber').text.trim(),
      mobile: _getController('secondaryNumber').text.trim(),
      website: _getController('website').text.trim(),
      industry: industryValue,
      revenue: _getController('revenue').text.trim(),
      billingStreet: _getController('streetAddress').text.trim(),
      billingCity: selectedCity,
      billingState: selectedState,
      billingCountry: selectedCountry,
      billingZipCode: _getController('zipCode').text.trim(),
      shippingStreet: _getController('streetAddress').text.trim(),
      shippingCity: selectedCity,
      shippingState: selectedState,
      shippingCountry: selectedCountry,
      shippingZipCode: _getController('zipCode').text.trim(),
      description: _getController('description').text.trim(),
      status: status,
      userId: _userId,
      password: 0,
      loginEmail: '',
      active: true,
    );

    _customerBloc.add(UpdateCustomerEvent(request: payload));
  }

  void _onCreateCustomer() {
    if (_formKey.currentState?.validate() != true) return;

    // Get the current lead state to access selected values
    final leadState = _leadBloc.state;
    String selectedCountry = '';
    String selectedState = '';
    String selectedCity = '';

    if (leadState is CreateLeadDataState) {
      selectedCountry = leadState.selectedCountry?.name ?? '';
      selectedState = leadState.selectedState?.name ?? '';
      selectedCity = leadState.selectedCity?.name ?? '';
    }

    // Get the current industry value
    String industryValue = _industryNotifier.value ?? '';
    if (industryValue.isEmpty && _customerBloc.state is CustomerFormValid) {
      industryValue =
          (_customerBloc.state as CustomerFormValid).customerForm.industry ??
              '';
    }

    // Create form model from controllers and bloc state
    final customerForm = CustomerFormModel(
      companyName: _getController('companyName').text.trim(),
      email: _getController('email').text.trim(),
      primaryNumber: _getController('primaryNumber').text.trim(),
      secondaryNumber: _getController('secondaryNumber').text.trim(),
      website: _getController('website').text.trim(),
      annualRevenue: _getController('revenue').text.trim(),
      streetAddress: _getController('streetAddress').text.trim(),
      zipCode: _getController('zipCode').text.trim(),
      country: selectedCountry,
      state: selectedState,
      city: selectedCity,
      industry: industryValue,
      gstin: _getController('gstin').text.trim(),
      panNumber: _getController('pan').text.trim(),
      description: _getController('description').text.trim(),
    );

    if (!customerForm.isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _customerBloc.add(CreateCustomerEvent(customerForm: customerForm));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateCustomerBloc, CreateCustomerState>(
          listener: (context, state) {
            if (state is CustomerCreateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Customer created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            }

            if (state is UpdateCustomerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is CustomerCreateFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is GetCustomerLoadState) {
              _initializeControllersFromState(state);
            }

            if (state is UpdateCustomerLoadState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Customer updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CommonAppBar(
          title: widget.edit ? 'Update Customer' : 'Create New Customer',
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                commonBox(context, 'Basic Information'),
                const SizedBox(height: 16),
                AppTextField(
                  showLabel: true,
                  isRequired: true,
                  enabled: isEdit ?? true,
                  labelText: 'Company Name',
                  hint: 'Company Name',
                  keyboardType: TextInputType.name,
                  controller: _getController('companyName'),
                  validator: Validators.validateCompanyName,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        enabled: isEdit ?? true,
                        showLabel: true,
                        labelText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        hint: 'abc@gmail.com',
                        controller: _getController('email'),
                        validator: (value) => value?.isEmpty == true
                            ? null
                            : Validators.validateEmail(value),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ValueListenableBuilder<String?>(
                        valueListenable: _industryNotifier,
                        builder: (context, industryValue, child) {
                          log('ValueListenableBuilder rebuilt with: $industryValue');

                          return BlocBuilder<CreateCustomerBloc,
                              CreateCustomerState>(
                            buildWhen: (previous, current) {
                              // Only rebuild when state type changes
                              return previous.runtimeType !=
                                  current.runtimeType;
                            },
                            builder: (context, state) {
                              // Get industry value from different possible states
                              String? finalIndustryValue = industryValue;

                              if (finalIndustryValue == null ||
                                  finalIndustryValue.isEmpty) {
                                if (state is CustomerFormValid) {
                                  finalIndustryValue =
                                      state.customerForm.industry;
                                } else if (state is GetCustomerLoadState) {
                                  // Already handled by ValueListenable
                                }
                              }

                              log('Current industry in UI: $finalIndustryValue, State type: ${state.runtimeType}');

                              // Check if the value exists in the items list
                              // If not, set to null to avoid the Flutter error
                              final validValue = finalIndustryValue != null &&
                                      finalIndustryValue.isNotEmpty &&
                                      CreateLeadConstants.industries
                                          .contains(finalIndustryValue)
                                  ? finalIndustryValue
                                  : null;

                              return CustomDropdown<String>(
                                enabled: isEdit ?? true,
                                key: ValueKey<String?>(
                                    'industry_${validValue ?? 'null'}'),
                                showLabel: true,
                                isRequired: true,
                                labelText: 'Industry',
                                hintText: 'Select Industry',
                                value: validValue,
                                items: CreateLeadConstants.industries,
                                onChanged: _onIndustryChanged,
                                itemLabel: (v) => v,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        showLabel: true,
                        enabled: isEdit ?? true,
                        keyboardType: TextInputType.number,
                        labelText: 'Annual Revenue',
                        hint: 'Enter Annual Revenue',
                        controller: _getController('revenue'),
                        validator: (value) => value?.isEmpty == true
                            ? null
                            : Validators.validateRevenue(value),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: AppTextField(
                        showLabel: true,
                        enabled: isEdit ?? true,
                        labelText: 'Website',
                        hint: 'Enter website url',
                        keyboardType: TextInputType.url,
                        controller: _getController('website'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        enabled: isEdit ?? true,
                        showLabel: true,
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                        labelText: 'Primary Number',
                        hint: 'Enter Number',
                        isTenDigitPhone: true,
                        controller: _getController('primaryNumber'),
                        validator: Validators.validatePhone,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: AppTextField(
                        // isTenDigitPhone: true,
                        showLabel: true,
                        enabled: isEdit ?? true,
                        keyboardType: TextInputType.phone,
                        labelText: 'Secondary Number',
                        hint: 'Enter Number',
                        controller: _getController('secondaryNumber'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                commonBox(context, 'Address Information'),
                const SizedBox(height: 16),
                AppTextField(
                  showLabel: true,
                  enabled: isEdit ?? true,
                  isRequired: true,
                  labelText: 'Street Address',
                  hint: 'Enter Street Address',
                  keyboardType: TextInputType.streetAddress,
                  controller: _getController('streetAddress'),
                  validator: (value) =>
                      Validators.validateRequired(value, 'Street address'),
                ),
                const SizedBox(height: 16),
                BlocBuilder<CreateLeadBloc, CreateLeadState>(
                  builder: (context, leadState) {
                    return _buildLocationDropdowns(leadState);
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  enabled: isEdit ?? true,
                  showLabel: true,
                  isRequired: true,
                  labelText: 'ZIP Code',
                  hint: 'Enter ZIP code',
                  keyboardType: TextInputType.number,
                  controller: _getController('zipCode'),
                  validator: (value) =>
                      Validators.validateRequired(value, 'ZIP Code'),
                ),
                const SizedBox(height: 16),
                commonBox(context, 'Additional Information'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        enabled: isEdit ?? true,
                        showLabel: true,
                        labelText: 'GSTIN',
                        hint: 'Enter GSTIN',
                        keyboardType: TextInputType.multiline,
                        controller: _getController('gstin'),
                        validator: (value) => value?.isEmpty == true
                            ? null
                            : Validators.validateGSTIN(value),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: AppTextField(
                        showLabel: true,
                        enabled: isEdit ?? true,
                        labelText: 'PAN Number',
                        hint: 'PAN Number',
                        keyboardType: TextInputType.multiline,
                        controller: _getController('pan'),
                        validator: (value) => value?.isEmpty == true
                            ? null
                            : Validators.validatePAN(value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  showLabel: true,
                  enabled: isEdit ?? true,
                  labelText: 'Description',
                  hint: 'Enter Description',
                  maxLines: 4,
                  controller: _getController('description'),
                ),
                const SizedBox(height: 32),
                widget.edit
                    ? BlocBuilder<CreateCustomerBloc, CreateCustomerState>(
                        builder: (context, state) {
                          final isLoading = state is UpdateCustomerLoadingState;
                          return Button(
                            isValid: isEdit == false ? false : true,
                            isLoading: isLoading,
                            text: 'Update Customer',
                            onPressed: _updateCustomer,
                          );
                        },
                      )
                    : BlocBuilder<CreateCustomerBloc, CreateCustomerState>(
                        builder: (context, state) {
                          final isLoading = state is CustomerLoading;
                          return Button(
                            isValid: widget.edit == true ? false : true,
                            isLoading: isLoading,
                            text: 'Create Customer',
                            onPressed: isLoading ? null : _onCreateCustomer,
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationDropdowns(CreateLeadState leadState) {
    if (leadState is! CreateLeadDataState) return const SizedBox.shrink();

    return Column(
      children: [
        _buildCountryDropdown(leadState),
        if (leadState.selectedCountry != null) const SizedBox(height: 16),
        if (leadState.selectedCountry != null) _buildStateDropdown(leadState),
        if (leadState.selectedState != null) const SizedBox(height: 16),
        if (leadState.selectedState != null) _buildCityDropdown(leadState),
      ],
    );
  }

  Widget _buildCountryDropdown(CreateLeadDataState state) {
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
                enabled: isEdit ?? true,
                initialItem: matchingCountry,
                decoration: const CustomDropdownDecoration(),
                hintText: 'Select Country',
                items: state.countries,
                onChanged: _onCountryChanged,
              ),
      ],
    );
  }

  Widget _buildStateDropdown(CreateLeadDataState state) {
    final matchingState = _findMatchingObject(
      state.selectedState,
      state.states,
      (stateObj) => stateObj.name,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('State', isRequired: true),
        const SizedBox(height: 8),
        state.statesLoading
            ? CreateLeadHelper.buildDropdownLoading()
            : DropdownFlutter<StateName>.search(
                initialItem: matchingState,
                decoration: const CustomDropdownDecoration(),
                hintText: 'Select State',
                items: state.states,
                onChanged: _onStateChanged,
              ),
      ],
    );
  }

  Widget _buildCityDropdown(CreateLeadDataState state) {
    final matchingCity = _findMatchingObject(
      state.selectedCity,
      state.cities,
      (city) => city.name,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateLeadHelper.buildLabel('City', isRequired: true),
        const SizedBox(height: 8),
        state.citiesLoading
            ? CreateLeadHelper.buildDropdownLoading()
            : DropdownFlutter<CityName>.search(
                initialItem: matchingCity,
                decoration: const CustomDropdownDecoration(),
                hintText: 'Select City',
                items: state.cities,
                onChanged: _onCityChanged,
              ),
      ],
    );
  }

  T? _findMatchingObject<T>(
    T? selected,
    List<T> items,
    String Function(T) getName,
  ) {
    if (selected == null || items.isEmpty) return null;
    final selectedName = getName(selected);
    return items.firstWhere(
      (item) => getName(item) == selectedName,
      orElse: () => items.first,
    );
  }
}
