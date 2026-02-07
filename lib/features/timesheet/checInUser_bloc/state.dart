import '../data/model/checkIn_status_model.dart';

abstract class CheckInUserState {}

class CheckInInitial extends CheckInUserState {}

class CheckInLoading extends CheckInUserState {}

class CheckInLoaded extends CheckInUserState {
  final bool isCheckedIn;
  final int startTimestamp;
  final EmployeeAttendanceResponse checkInStatus;

  CheckInLoaded(
      {required this.isCheckedIn,
      required this.startTimestamp,
      required this.checkInStatus});
}

class CheckInError extends CheckInUserState {
  final String message;
  CheckInError(this.message);
}
