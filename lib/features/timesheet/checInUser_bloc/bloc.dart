import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/event.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/state.dart';
import 'package:xpertbiz/features/timesheet/data/repo/repo.dart';
//import '../block/timesheet_event.dart';

class CheckInBloc extends Bloc<CheckInEvent, CheckInUserState> {
  final TimeSheetRepository repository;

  CheckInBloc(this.repository) : super(CheckInInitial()) {
    on<CheckInUserEvent>(_onFetchStatus);
    on<ToggleCheckIn>(_onToggleCheckIn);
  }

  Future<void> _onFetchStatus(
    CheckInUserEvent event,
    Emitter<CheckInUserState> emit,
  ) async {
    try {
      emit(CheckInLoading());

      final result = await repository.checkInStatus(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      final records = result.dates.first.records;
      final last = records.isNotEmpty ? records.last : null;

      emit(
        CheckInLoaded(
            isCheckedIn: last?.status ?? false,
            startTimestamp: last?.timeStamp ?? 0,
            checkInStatus: result),
      );
    } catch (e) {
      // emit(CheckInError(e.toString()));
    }
  }

  Future<void> _onToggleCheckIn(
    ToggleCheckIn event,
    Emitter<CheckInUserState> emit,
  ) async {
    //  if (state is! CheckInLoaded) return;
    try {
      final current = state as CheckInLoaded;

      final res = await repository.checkIn(!current.isCheckedIn);

      emit(
        CheckInLoaded(
          isCheckedIn: res.status, // 🔥 UI updates here
          startTimestamp: res.timeStamp,
          checkInStatus: current.checkInStatus,
        ),
      );
    } catch (e) {
      emit(CheckInError(e.toString()));
    }
  }
}
