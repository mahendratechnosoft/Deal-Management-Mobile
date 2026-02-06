import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/features/customers/data/model/customer_contect_model.dart';
import '../data/model/customer_list_model.dart';
import '../data/repo.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository repository;

  CustomerBloc(this.repository) : super(CustomerInitial()) {
    on<FetchCustomersEvent>(_onFetch);
    on<LoadMoreCustomersEvent>(_onLoadMore);
    on<SearchCustomersEvent>(_onSearch);
    on<RefreshCustomersEvent>(_onRefresh);
    on<ClearCustomerSearchEvent>(_onClearSearch);
    //
    on<ContactLoadEvent>(_onFetchContacts);
  }

  final List<Customer> _customers = [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isFetching = false;
  String _searchQuery = '';

  //
  List<CustomerContactModel> _contacts = [];
  // bool _isFetching = false;

  /// Fetch contacts
  Future<void> _onFetchContacts(
    ContactLoadEvent event,
    Emitter<CustomerState> emit,
  ) async {
    if (_isFetching) return;

    emit(ContactLoadingState());
    await _loadContacts(event.id, emit);
  }

  /// Core fetch logic
  Future<void> _loadContacts(
    String customerId,
    Emitter<CustomerState> emit,
  ) async {
    emit(ContactLoadingState());
    try {
      _isFetching = true;

      final List<CustomerContactModel> response =
          await repository.getContacts(taskId: customerId);
      _contacts = response;

      emit(ContactLoaded(List.unmodifiable(_contacts)));
    } catch (e) {
      final m = ApiError.getMessage(e);
      emit(ContactError(m));
    } finally {
      _isFetching = false;
    }
  }
  //

  Future<void> _onFetch(
    FetchCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    _customers.clear();
    _searchQuery = '';
    _currentPage = 0;
    _hasMore = true;

    await _fetchData(emit);
  }

  Future<void> _onLoadMore(
    LoadMoreCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    if (_isFetching || !_hasMore) return;

    _currentPage++;
    await _fetchData(emit);
  }

  Future<void> _onSearch(
    SearchCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    _searchQuery = event.query;
    _customers.clear();
    _currentPage = 0;
    _hasMore = true;
    emit(CustomerLoading());
    await _fetchData(emit);
  }

  Future<void> _onRefresh(
    RefreshCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    _customers.clear();
    _currentPage = 0;
    _hasMore = true;

    await _fetchData(emit);
  }

  Future<void> _onClearSearch(
    ClearCustomerSearchEvent event,
    Emitter<CustomerState> emit,
  ) async {
    _searchQuery = '';
    _customers.clear();
    _currentPage = 0;
    _hasMore = true;

    emit(CustomerLoading());
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<CustomerState> emit) async {
    try {
      _isFetching = true;

      final response = await repository.getCustomers(
          page: _currentPage, size: 10, search: _searchQuery);

      if (response.customerList.isEmpty) {
        _hasMore = false;
      } else {
        _customers.addAll(response.customerList);
        _hasMore = response.customerList.length == 10;
      }

      _isFetching = false;

      emit(CustomerLoaded(
        customers: List.from(_customers),
        hasMore: _hasMore,
      ));
    } catch (e) {
      _isFetching = false;
      final s = ApiError.getMessage(e);
      emit(CustomerError(s));
    }
  }
}
