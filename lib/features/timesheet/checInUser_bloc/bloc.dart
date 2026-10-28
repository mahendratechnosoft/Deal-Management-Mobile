import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/event.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/state.dart';
import 'package:xpertbiz/features/timesheet/data/model/checkIn_status_model.dart';
import 'package:xpertbiz/features/timesheet/data/repo/repo.dart';

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
      if (state is! CheckInLoaded) {
        emit(CheckInLoading());
      }

      final result = await repository.checkInStatus(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      bool isCheckedIn = false;
      int startTimestamp = 0;

      if (result.dates.isNotEmpty) {
        final records = result.dates.first.records;
        if (records.isNotEmpty) {
          final last = records.last;
          isCheckedIn = last.status;
          if (isCheckedIn) {
            startTimestamp = last.timeStamp;
          }
        }
      }

      emit(
        CheckInLoaded(
          isCheckedIn: isCheckedIn,
          startTimestamp: startTimestamp,
          checkInStatus: result,
        ),
      );
    } catch (e) {
      emit(CheckInError(e.toString()));
    }
  }

  Future<void> _onToggleCheckIn(
    ToggleCheckIn event,
    Emitter<CheckInUserState> emit,
  ) async {
    try {
      final current = state is CheckInLoaded ? (state as CheckInLoaded) : null;
      final currentlyCheckedIn = current?.isCheckedIn ?? false;
      final nextStatus = !currentlyCheckedIn;

      emit(CheckInLoading());

      final res = await repository.checkIn(nextStatus);

      emit(
        CheckInLoaded(
          isCheckedIn: res.status,
          startTimestamp: res.status ? res.timeStamp : 0,
          checkInStatus: current?.checkInStatus ??
              EmployeeAttendanceResponse(employeeName: '', dates: []),
        ),
      );
    } catch (e) {
      emit(CheckInError(e.toString()));
    }
  }
}
