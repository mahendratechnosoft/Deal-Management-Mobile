import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/features/Lead/bloc/state.dart';
import 'package:xpertbiz/features/Lead/data/model/all_lead_model.dart';
import 'package:xpertbiz/features/Lead/data/repo/repo.dart';
import '../data/model/activity_log_model.dart';
import 'event.dart';

class LeadBloc extends Bloc<LeadEvent, LeadState> {
  final LeadRepository repository;

  static const int limit = 10;

  int _page = 0;
  bool _hasMore = true;
  bool _isFetching = false;
  String? _currentSearchQuery;
  DateTime? _currentSelectedDate;
  String? _currentStatus; // Track current status
  bool _isFetchingDetails = false;
  bool _isFetchingActivity = false;
  bool _reminder = false;
  final List<LeadModel> _leads = [];
  final List<ActivityLogModel> _activityLogs = [];

  LeadBloc(this.repository) : super(LeadInitial()) {
    on<ResetLeadEvent>((event, emit) {
      emit(LeadInitial());
    });
    on<FetchLeadStatus>(_fetchLeadStatus);
    on<FetchAllLeadsEvent>(_onFetchLeads);
    on<RefreshLeads>(_onRefresh);
    on<SearchLeadsEvent>(_onSearchLeads);
    on<FilterByDateEvent>(_onFilterByDate);
    on<ClearSearchEvent>(_onClearSearch);
    on<ClearAllFiltersEvent>(_onClearAllFilters);
    on<LeadDetailsEvent>(_leadDetails);
    on<FetchLeadActivityEvent>(_fetchLeadActivity);
    on<FetchReminderEvent>(_onReminder);
    on<CreateReminderSubmitEvent>(_createReminder);
  }

  Future<void> _fetchLeadActivity(
    FetchLeadActivityEvent event,
    Emitter<LeadState> emit,
  ) async {
    if (_isFetchingActivity) return;

    final currentState = state;
    if (currentState is! AllLeadState) return;

    _isFetchingActivity = true;

    emit(currentState.copyWith(activityLogsLoader: true));

    try {
      final activityLogs = await repository.fetchActivity(taskId: event.leadId);
      _activityLogs.clear();
      _activityLogs.addAll(activityLogs);

      emit(
        currentState.copyWith(
          activityLogsLoader: false,
          activityLogs: List.unmodifiable(_activityLogs),
        ),
      );
    } on DioException catch (e) {
      emit(currentState.copyWith(
        activityLogsLoader: false,
      ));
      if (kDebugMode) {
        print('Activity logs error: ${ApiError.getMessage(e)}');
      }
    } catch (e) {
      emit(currentState.copyWith(
        activityLogsLoader: false,
      ));
      if (kDebugMode) {
        print('Activity logs error: $e');
      }
    } finally {
      _isFetchingActivity = false;
    }
  }

  // Reset and fetch with new status
  void fetchLeadsByStatus(String? status) {
    _currentStatus = status;
    add(FetchAllLeadsEvent(status: status));
  }

  Future<void> _fetchLeadStatus(
    FetchLeadStatus event,
    Emitter<LeadState> emit,
  ) async {
    //   if (state is LeadLoaded) return;
    emit(LeadLoading());
    try {
      final leads = await repository.fetchLeadStatus();
      emit(LeadLoaded(leads));
    } on DioException catch (e) {
      emit(LeadError(ApiError.getMessage(e)));
    } catch (e) {
      emit(LeadError(ApiError.getMessage(e)));
    }
  }

  Future<void> _createReminder(
    CreateReminderSubmitEvent event,
    Emitter<LeadState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AllLeadState) {
      emit(AllLeadState(
        statusAndCount: const [],
        leads: const [],
        filteredLeads: const [],
        hasMore: false,
        currentPage: 1,
        createReminder: true,
      ));
      return;
    }

    log('Creating reminder...');
    emit(
        currentState.copyWith(createReminder: true, createReminderError: null));

    try {
      final result = await repository.createReminder(request: event.request);
      log('Reminder created successfully $result');
      // Update state to show success
      emit(
        currentState.copyWith(
          createReminder: false,
          createReminderError: null,
        ),
      );
    } on DioException catch (e) {
      final errorMessage = ApiError.getMessage(e);
      log('Create reminder error: $errorMessage');

      emit(currentState.copyWith(
        createReminder: false,
        createReminderError: errorMessage,
      ));
    } catch (e) {
      log('Create reminder error: $e');

      emit(currentState.copyWith(
        createReminder: false,
        createReminderError: e.toString(),
      ));
    }
  }

  // ================= FETCH ALL LEADS (PAGINATION) =================
  Future<void> _onFetchLeads(
    FetchAllLeadsEvent event,
    Emitter<LeadState> emit,
  ) async {
    if (_isFetching) return;
    if (event.loadMore && !_hasMore) return;

    _isFetching = true;

    // If status changed or not loading more, reset pagination
    if (!event.loadMore || event.status != _currentStatus) {
      _page = 0;
      _hasMore = true;
      _leads.clear();
      _currentStatus = event.status;
      emit(LeadLoading());
    }

    try {
      final response = await repository.fecthAllLeads(
        page: _page,
        limit: limit,
        status: _currentStatus,
      );
      _leads.addAll(response.leadList);
      _hasMore = response.currentPage < response.totalPages;
      _page++;

      log('check resposne : ${response.statusAndCount.first.status}');

      // Apply current filters to the newly loaded data
      final filteredLeads = _applyFilters(_leads);

      emit(
        AllLeadState(
          statusAndCount: response.statusAndCount,
          leads: List.unmodifiable(_leads),
          filteredLeads: filteredLeads,
          hasMore: _hasMore,
          currentPage: response.currentPage,
          searchQuery: _currentSearchQuery,
          selectedDate: _currentSelectedDate,
          status: _currentStatus,
          isSearching:
              _currentSearchQuery != null && _currentSearchQuery!.isNotEmpty,
          isDateFiltered: _currentSelectedDate != null,
        ),
      );
    } on DioException catch (e) {
      emit(LeadError(ApiError.getMessage(e)));
    } catch (e) {
      log('error ${e.toString()}');
      emit(LeadError(ApiError.getMessage(e)));
    } finally {
      _isFetching = false;
    }
  }

  // ================= SEARCH LEADS =================
  void _onSearchLeads(
    SearchLeadsEvent event,
    Emitter<LeadState> emit,
  ) {
    final currentState = state;

    if (currentState is AllLeadState) {
      final searchQuery = event.searchQuery.trim();
      _currentSearchQuery = searchQuery.isNotEmpty ? searchQuery : null;

      final filteredLeads = _applyFilters(_leads);

      emit(
        currentState.copyWith(
          filteredLeads: filteredLeads,
          searchQuery: _currentSearchQuery,
          isSearching: _currentSearchQuery != null,
        ),
      );
    }
  }

  // ================= FILTER BY DATE =================
  void _onFilterByDate(
    FilterByDateEvent event,
    Emitter<LeadState> emit,
  ) {
    final currentState = state;

    if (currentState is AllLeadState) {
      _currentSelectedDate = event.selectedDate;

      final filteredLeads = _applyFilters(_leads);

      emit(
        currentState.copyWith(
          filteredLeads: filteredLeads,
          selectedDate: event.selectedDate,
          isDateFiltered: event.selectedDate != null,
        ),
      );
    }
  }

  // ================= CLEAR SEARCH =================
  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<LeadState> emit,
  ) {
    final currentState = state;

    if (currentState is AllLeadState) {
      _currentSearchQuery = null;

      final filteredLeads = _applyFilters(_leads);

      emit(
        currentState.copyWith(
          filteredLeads: filteredLeads,
          searchQuery: null,
          isSearching: false,
        ),
      );
    }
  }

  // ================= CLEAR ALL FILTERS =================
  void _onClearAllFilters(
    ClearAllFiltersEvent event,
    Emitter<LeadState> emit,
  ) {
    final currentState = state;

    if (currentState is AllLeadState) {
      _currentSearchQuery = null;
      _currentSelectedDate = null;

      emit(
        currentState.copyWith(
          filteredLeads: _leads,
          searchQuery: null,
          selectedDate: null,
          isSearching: false,
          isDateFiltered: false,
        ),
      );
    }
  }

  // ================= REFRESH =================
  Future<void> _onRefresh(
    RefreshLeads event,
    Emitter<LeadState> emit,
  ) async {
    add(FetchAllLeadsEvent(
      loadMore: false,
      status: event.status ?? _currentStatus,
    ));
  }

  // ================= HELPER: APPLY ALL FILTERS =================
  List<LeadModel> _applyFilters(List<LeadModel> leads) {
    List<LeadModel> filtered = leads;

    // Apply search filter
    if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
      filtered = _filterBySearch(filtered, _currentSearchQuery!);
    }

    // Apply date filter
    if (_currentSelectedDate != null) {
      filtered = _filterByDate(filtered, _currentSelectedDate!);
    }

    return filtered;
  }

  // ================= HELPER: FILTER BY SEARCH =================
  List<LeadModel> _filterBySearch(List<LeadModel> leads, String query) {
    final lowerCaseQuery = query.toLowerCase();

    return leads.where((lead) {
      return (lead.clientName!.toLowerCase().contains(lowerCaseQuery)) ||
          (lead.companyName!.toLowerCase().contains(lowerCaseQuery)) ||
          (lead.email?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
          (lead.mobileNumber?.toLowerCase().contains(lowerCaseQuery) ??
              false) ||
          (lead.status.toLowerCase().contains(lowerCaseQuery));
    }).toList();
  }

  // ================= HELPER: FILTER BY DATE =================
  List<LeadModel> _filterByDate(List<LeadModel> leads, DateTime date) {
    return leads.where((lead) {
      try {
        final leadDate = lead.createdDate;
        return leadDate!.year == date.year &&
            leadDate.month == date.month &&
            leadDate.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  //
  Future<void> _leadDetails(
    LeadDetailsEvent event,
    Emitter<LeadState> emit,
  ) async {
    if (_isFetchingDetails) return;

    final currentState = state;
    if (currentState is! AllLeadState) return;

    _isFetchingDetails = true;

    emit(currentState.copyWith(leadDetailsLoader: true));

    try {
      final res = await repository.fecthLeadDetails(taskId: event.leadId);

      emit(
        currentState.copyWith(
          leadDetailsLoader: false,
          leadDetailsModel: res,
        ),
      );
    } on DioException catch (e) {
      emit(currentState.copyWith(
        leadDetailsLoader: false,
      ));
      log('Lead details error: ${ApiError.getMessage(e)}');
    } catch (e) {
      emit(currentState.copyWith(
        leadDetailsLoader: false,
      ));
      log('Lead details error: $e');
    } finally {
      _isFetchingDetails = false;
    }
  }

  //
  Future<void> _onReminder(
    FetchReminderEvent event,
    Emitter<LeadState> emit,
  ) async {
    if (_reminder) return;

    final currentState = state;
    if (currentState is! AllLeadState) return;

    _reminder = true;

    emit(currentState.copyWith(reminder: true));

    try {
      final res = await repository.fetchReminder(taskId: event.leadId);

      emit(
        currentState.copyWith(
          reminder: false,
          remindermodel: res,
        ),
      );
    } on DioException catch (e) {
      emit(currentState.copyWith(
        reminder: false,
      ));
      log('Lead details error: ${ApiError.getMessage(e)}');
    } catch (e) {
      emit(currentState.copyWith(
        reminder: false,
      ));
      log('Lead details error: $e');
    } finally {
      _reminder = false;
    }
  }
}
