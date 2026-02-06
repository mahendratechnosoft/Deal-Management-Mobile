// lib/features/customers/create_customer/bloc/create_customer_state.dart
import 'package:equatable/equatable.dart';
import 'package:xpertbiz/features/customers/create_customer/bloc/model/create_customer_model.dart';
import 'package:xpertbiz/features/customers/data/model/get_customer_details_model.dart';
import 'model/customer_payload_model.dart';

sealed class CreateCustomerState extends Equatable {
  const CreateCustomerState();

  @override
  List<Object> get props => [];
}

class CustomerInitial extends CreateCustomerState {}

class CustomerLoading extends CreateCustomerState {}

class CustomerFormValid extends CreateCustomerState {
  final CustomerFormModel customerForm;

  const CustomerFormValid({
    required this.customerForm,
  });

  CustomerFormValid copyWith({
    CustomerFormModel? customerForm,
    Map<String, String?>? validationErrors,
  }) {
    return CustomerFormValid(
      customerForm: customerForm ?? this.customerForm,
    );
  }

  @override
  List<Object> get props => [customerForm];
}

class CustomerFormError extends CreateCustomerState {
  final CustomerFormModel customerForm;
  final String message;

  const CustomerFormError({
    required this.customerForm,
    required this.message,
  });

  @override
  List<Object> get props => [customerForm, message];
}

class CustomerCreateSuccess extends CreateCustomerState {
  final CreateCustomerModel customer;
  const CustomerCreateSuccess({required this.customer});

  @override
  List<Object> get props => [customer];
}

class CustomerCreateFailure extends CreateCustomerState {
  final String error;

  const CustomerCreateFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class IndustryLoaded extends CreateCustomerState {
  final String? selectedIndustry;

  const IndustryLoaded({this.selectedIndustry});

  IndustryLoaded copyWith({String? selectedIndustry}) {
    return IndustryLoaded(
      selectedIndustry: selectedIndustry ?? this.selectedIndustry,
    );
  }

  @override
  List<Object> get props => [if (selectedIndustry != null) selectedIndustry!];
}

class UpdateCustomerLoadingState extends CreateCustomerState {}

class UpdateCustomerLoadState extends CreateCustomerState {
  final CreateCustomerModel request;
  const UpdateCustomerLoadState({required this.request});
}

class UpdateCustomerError extends CreateCustomerState {
  final String error;
  const UpdateCustomerError({required this.error});
}

class GetCustomerLoadingState extends CreateCustomerState {}

class GetCustomerLoadState extends CreateCustomerState {
  final GetCustomerDetailsModel response;
  const GetCustomerLoadState({required this.response});
}

class GetCustomerError extends CreateCustomerState {
  final String error;
  const GetCustomerError({required this.error});
}
