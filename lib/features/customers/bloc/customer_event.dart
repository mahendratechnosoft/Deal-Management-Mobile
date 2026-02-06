import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustomersEvent extends CustomerEvent {
  final int page;
  final int size;

  const FetchCustomersEvent({
    required this.page,
    required this.size,
  });

  @override
  List<Object?> get props => [page, size];
}

class LoadMoreCustomersEvent extends CustomerEvent {
  final int size;

  const LoadMoreCustomersEvent({required this.size});

  @override
  List<Object?> get props => [size];
}

/// 🔍 Search
class SearchCustomersEvent extends CustomerEvent {
  final String query;

  const SearchCustomersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// 🔄 Pull to refresh
class RefreshCustomersEvent extends CustomerEvent {}
class ClearCustomerSearchEvent extends CustomerEvent {}
class ContactLoadEvent extends CustomerEvent {
  final String id;
 const  ContactLoadEvent({required this.id});
}

class ComplianceEvent extends CustomerEvent{}


