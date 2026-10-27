import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/features/Lead/bloc/state.dart';
import 'package:xpertbiz/features/Lead/data/model/all_lead_model.dart';
import 'package:xpertbiz/features/Lead/data/repo/repo.dart';
import 'package:xpertbiz/features/Lead/data/model/activity_log_model.dart';
import 'event.dart';

class LeadBloc extends Bloc<LeadEvent, LeadState> {
  final LeadRepository repository;

  static const int limit = 10;

  int _page = 0;
  bool _hasMore = true;
  bool _isFetching = false;
  String? _currentSearchQuery;
  DateTime? _currentSelectedDate;
  String? _currentStatus;
  bool _isFetchingDetails = false;
  bool _isFetchingActivity = false;
  bool _reminder = false;
  final List<LeadModel> _leads = [];
  final List<ActivityLogModel> _activityLogs = [];
  List<StatusCountModel> _cachedStatusAndCount = [];

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
    } catch (e) {
      emit(currentState.copyWith(activityLogsLoader: false));
      if (kDebugMode) {
        print('Activity logs error: $e');
      }
    } finally {
      _isFetchingActivity = false;
    }
  }

  void fetchLeadsByStatus(String? status) {
    _currentStatus = status;
    add(FetchAllLeadsEvent(page: 0, status: status));
  }

  Future<void> _fetchLeadStatus(
    FetchLeadStatus event,
    Emitter<LeadState> emit,
  ) async {
    emit(LeadLoading());
    try {
      final leads = await repository.fetchLeadStatus();
      emit(LeadLoaded(leads));
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
      emit(const AllLeadState(
        statusAndCount: [],
        leads: [],
        filteredLeads: [],
        hasMore: false,
        currentPage: 0,
        createReminder: true,
      ));
      return;
    }

    emit(currentState.copyWith(createReminder: true, createReminderError: null));

    try {
      final result = await repository.createReminder(request: event.request);
      log('Reminder created: $result');
      emit(
        currentState.copyWith(
          createReminder: false,
          createReminderError: null,
        ),
      );
    } catch (e) {
      final errorMessage = ApiError.getMessage(e);
      emit(currentState.copyWith(
        createReminder: false,
        createReminderError: errorMessage,
      ));
    }
  }

  // ================= FETCH ALL LEADS (PAGE-BASED PAGINATION & SEARCH) =================
  Future<void> _onFetchLeads(
    FetchAllLeadsEvent event,
    Emitter<LeadState> emit,
  ) async {
    if (_isFetching) return;
    _isFetching = true;

    final currentState = state;

    // Check if status or search has changed
    final statusChanged = event.status != _currentStatus;
    final searchChanged = event.search != null && event.search != _currentSearchQuery;

    if (event.page != null) {
      _page = event.page!;
    } else if (statusChanged || searchChanged || !event.loadMore) {
      _page = 0;
      _hasMore = true;
    }

    if (event.status != null || statusChanged) {
      _currentStatus = (event.status == 'All' || event.status == '') ? null : event.status;
    }
    if (event.search != null || searchChanged) {
      _currentSearchQuery = (event.search?.trim().isEmpty ?? true) ? null : event.search?.trim();
    }

    if (currentState is AllLeadState && currentState.leads.isNotEmpty) {
      emit(currentState.copyWith(
        isLoadingPage: true,
        status: _currentStatus,
        searchQuery: _currentSearchQuery,
      ));
    } else {
      emit(LeadLoading());
    }

    try {
      final response = await repository.fecthAllLeads(
        page: _page,
        limit: limit,
        status: _currentStatus,
        search: _currentSearchQuery,
      );

      _leads.clear();
      _leads.addAll(response.leadList);

      final int calculatedPages = response.totalPages > 0
          ? response.totalPages
          : (response.totalLeads > 0 ? (response.totalLeads / limit).ceil() : 1);
      final int totalPages = calculatedPages > 0 ? calculatedPages : 1;
      _hasMore = (_page + 1) < totalPages;

      List<StatusCountModel> statusAndCount = response.statusAndCount;
      if (statusAndCount.isNotEmpty) {
        _cachedStatusAndCount = statusAndCount;
      } else if (_cachedStatusAndCount.isNotEmpty) {
        statusAndCount = _cachedStatusAndCount;
      } else {
        try {
          final statuses = await repository.fetchLeadStatus();
          statusAndCount = statuses
              .map((s) => StatusCountModel(status: s.status, count: s.count))
              .toList();
          _cachedStatusAndCount = statusAndCount;
        } catch (e) {
          log('fetchLeadStatus fallback error: $e');
        }
      }

      emit(
        AllLeadState(
          statusAndCount: statusAndCount,
          leads: List.unmodifiable(_leads),
          filteredLeads: List.unmodifiable(_leads),
          hasMore: _hasMore,
          currentPage: _page,
          totalPages: totalPages,
          totalLeads: response.totalLeads,
          searchQuery: _currentSearchQuery,
          selectedDate: _currentSelectedDate,
          status: _currentStatus,
          isSearching: _currentSearchQuery != null && _currentSearchQuery!.isNotEmpty,
          isDateFiltered: _currentSelectedDate != null,
          isLoadingPage: false,
        ),
      );
    } catch (e) {
      log('Lead fetch error: $e');
      emit(LeadError(ApiError.getMessage(e)));
    } finally {
      _isFetching = false;
    }
  }

  // ================= SERVER-SIDE SEARCH =================
  Future<void> _onSearchLeads(
    SearchLeadsEvent event,
    Emitter<LeadState> emit,
  ) async {
    final query = event.searchQuery.trim();
    _currentSearchQuery = query.isNotEmpty ? query : null;
    _page = 0;
    if (event.status != null) {
      _currentStatus = (event.status == 'All' || event.status == '') ? null : event.status;
    }

    add(FetchAllLeadsEvent(
      page: 0,
      status: _currentStatus,
      search: _currentSearchQuery,
    ));
  }

  void _onFilterByDate(
    FilterByDateEvent event,
    Emitter<LeadState> emit,
  ) {
    final currentState = state;
    if (currentState is AllLeadState) {
      _currentSelectedDate = event.selectedDate;
      emit(
        currentState.copyWith(
          selectedDate: event.selectedDate,
          isDateFiltered: event.selectedDate != null,
        ),
      );
    }
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<LeadState> emit,
  ) {
    _currentSearchQuery = null;
    _page = 0;
    add(FetchAllLeadsEvent(
      page: 0,
      status: _currentStatus,
      search: null,
    ));
  }

  void _onClearAllFilters(
    ClearAllFiltersEvent event,
    Emitter<LeadState> emit,
  ) {
    _currentSearchQuery = null;
    _currentStatus = null;
    _currentSelectedDate = null;
    _page = 0;
    add(const FetchAllLeadsEvent(page: 0, status: null, search: null));
  }

  Future<void> _onRefresh(
    RefreshLeads event,
    Emitter<LeadState> emit,
  ) async {
    _page = 0;
    add(FetchAllLeadsEvent(
      page: 0,
      status: event.status ?? _currentStatus,
      search: event.search ?? _currentSearchQuery,
    ));
  }

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
    } catch (e) {
      emit(currentState.copyWith(leadDetailsLoader: false));
      log('Lead details error: $e');
    } finally {
      _isFetchingDetails = false;
    }
  }

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
    } catch (e) {
      emit(currentState.copyWith(reminder: false));
      log('Reminder error: $e');
    } finally {
      _reminder = false;
    }
  }
}
