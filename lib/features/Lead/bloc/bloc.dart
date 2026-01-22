import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/features/Lead/bloc/state.dart';
import 'package:xpertbiz/features/Lead/data/repo/repo.dart';
import 'event.dart';

class LeadBloc extends Bloc<LeadEvent, LeadState> {
  final LeadRepository repository;

  LeadBloc(this.repository) : super(LeadInitial()) {
    on<FetchLeadStatus>(_fetchLeadStatus);
  }

  Future<void> _fetchLeadStatus(
    FetchLeadStatus event,
    Emitter<LeadState> emit,
  ) async {
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
}
