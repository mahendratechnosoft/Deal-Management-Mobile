// lib/features/customers/create_customer/bloc/create_customer_bloc.dart
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/features/customers/bloc/customer_event.dart';
import 'package:xpertbiz/features/customers/create_customer/bloc/create_customer_state.dart';
import 'package:xpertbiz/features/customers/data/repo.dart';
import 'create_customer_event.dart';
import 'model/customer_payload_model.dart';

class CreateCustomerBloc extends Bloc<CustomerEvent, CreateCustomerState> {
  final CustomerRepository repo;

  CreateCustomerBloc(this.repo) : super(IndustryLoaded()) {
    on<CreateCustomerEvent>(_onCreateCustomer);
    on<ResetCustomerFormEvent>(_onResetForm);
    on<IndustrySelectedEvent>(_onIndustrySelected);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<GetCustomerEvent>(_onGetCustomer);
  }

  Future<void> _onCreateCustomer(
    CreateCustomerEvent event,
    Emitter<CreateCustomerState> emit,
  ) async {
    emit(CustomerLoading());
    try {
      final customer = event.customerForm.toCustomerModel();
      final result = await repo.cretaeCustomer(customer);
      emit(CustomerCreateSuccess(customer: result));
    } catch (e) {
      emit(CustomerCreateFailure(error: ApiError.getMessage(e)));
    }
  }

  void _onResetForm(
    ResetCustomerFormEvent event,
    Emitter<CreateCustomerState> emit,
  ) {
    emit(IndustryLoaded());
  }

  void _onIndustrySelected(
    IndustrySelectedEvent event,
    Emitter<CreateCustomerState> emit,
  ) {
    final currentForm = state is CustomerFormValid
        ? (state as CustomerFormValid).customerForm
        : CustomerFormModel();

    currentForm.industry = event.value;

    emit(CustomerFormValid(customerForm: currentForm));
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomerEvent event, Emitter<CreateCustomerState> emit) async {
    emit(UpdateCustomerLoadingState());
    try {
      final res = await repo.updateCustomer(event.request);
      emit(UpdateCustomerLoadState(request: res));
    } catch (e) {
      log('message : $e ${ApiError.getMessage(e)}');
      emit(UpdateCustomerError(error: ApiError.getMessage(e)));
    }
  }

  Future<void> _onGetCustomer(
      GetCustomerEvent event, Emitter<CreateCustomerState> emit) async {
    emit(UpdateCustomerLoadingState());
    try {
      final res = await repo.getCustomerDetails(event.id);
      emit(GetCustomerLoadState(response: res));
    } catch (e) {
      emit(GetCustomerError(error: ApiError.getMessage(e)));
    }
  }
}
