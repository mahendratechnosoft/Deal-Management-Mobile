import 'package:xpertbiz/features/customers/bloc/customer_event.dart';
import 'package:xpertbiz/features/customers/create_customer/bloc/model/update_customer_model.dart';
import 'model/customer_payload_model.dart';

class CreateCustomerEvent extends CustomerEvent {
  final CustomerFormModel customerForm;
  const CreateCustomerEvent({required this.customerForm});

  @override
  List<Object> get props => [customerForm];
}

class UpdateCustomerFormEvent extends CustomerEvent {
  final CustomerFormModel customerForm;
  const UpdateCustomerFormEvent({required this.customerForm});

  @override
  List<Object> get props => [customerForm];
}

class ValidateCustomerFormEvent extends CustomerEvent {
  final CustomerFormModel customerForm;
  const ValidateCustomerFormEvent({required this.customerForm});

  @override
  List<Object> get props => [customerForm];
}

class ResetCustomerFormEvent extends CustomerEvent {}

class IndustrySelectedEvent extends CustomerEvent {
  final String value;
  const IndustrySelectedEvent(this.value);

  @override
  List<Object> get props => [value];
}

class UpdateCustomerEvent extends CustomerEvent {
  final UpdateCustomerRequest request;
  const UpdateCustomerEvent({required this.request});
}

class GetCustomerEvent extends CustomerEvent {
  final String id;
  const GetCustomerEvent({required this.id});
}
