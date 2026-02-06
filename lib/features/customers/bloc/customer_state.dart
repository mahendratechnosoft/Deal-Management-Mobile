import 'package:equatable/equatable.dart';
import 'package:xpertbiz/features/customers/data/model/customer_contect_model.dart';
import '../data/model/customer_list_model.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();
  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final bool hasMore;

  const CustomerLoaded({
    required this.customers,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [customers, hasMore];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

// contact
class ContactLoadingState extends CustomerState {}
class ContactLoaded extends CustomerState {
  final List<CustomerContactModel> contacts;

  const ContactLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class ContactError extends CustomerState {
  final String message;
  const ContactError(this.message);

  @override
  List<Object?> get props => [message];
}


