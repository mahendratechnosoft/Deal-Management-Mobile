import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/features/Lead/bloc/state.dart';
import 'package:xpertbiz/features/Lead/data/model/all_lead_model.dart';
import 'package:xpertbiz/features/Lead/data/repo/repo.dart';
import 'event.dart';

class LeadBloc extends Bloc<LeadEvent, LeadState> {
  final LeadRepository repository;

  static const int limit = 100;

  int _page = 0;
  bool _hasMore = true;
  bool _isFetching = false;
  final List<AllLeadModel> _leads = [];

  LeadBloc(this.repository) : super(LeadInitial()) {
    on<FetchLeadStatus>(_fetchLeadStatus);
    on<FetchAllLeadsEvent>(_onFetchLeads);
    on<RefreshLeads>(_onRefresh);
    //call api
    add(const FetchLeadStatus());
  }

  Future<void> _fetchLeadStatus(
    FetchLeadStatus event,
    Emitter<LeadState> emit,
  ) async {
    if (state is LeadLoaded) return;
    emit(LeadLoading());
    try {
      final leads = await repository.fetchLeadStatus();
      emit(LeadLoaded(leads));
    } on DioException catch (e) {
      emit(LeadError(ApiError.getMessage(e)));
    } catch (e) {
      emit(LeadError(e.toString()));
    }
  }

  Future<void> _onFetchLeads(
    FetchAllLeadsEvent event,
    Emitter<LeadState> emit,
  ) async {
    if (_isFetching) return;
    if (event.loadMore && !_hasMore) return;

    _isFetching = true;

    if (!event.loadMore) {
      _page = 0;
      _hasMore = true;
      _leads.clear();
      emit(LeadLoading());
    }

    try {
      final response = await repository.fecthAllLeads(
        page: _page,
        limit: limit,
      );

      _leads.addAll(response.leads);
      _hasMore = response.currentPage < response.totalPages - 1;
      _page++;

      emit(
        AllLeadState(
          leads: List.unmodifiable(_leads),
          hasMore: _hasMore,
          currentPage: response.currentPage,
        ),
      );
    } catch (e) {
      emit(LeadError('Failed to load leads'));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onRefresh(
    RefreshLeads event,
    Emitter<LeadState> emit,
  ) async {
    add(FetchAllLeadsEvent(loadMore: false));
  }
}
