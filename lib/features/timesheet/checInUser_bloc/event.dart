abstract class CheckInEvent {}

class CheckInUserEvent extends CheckInEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  CheckInUserEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}

class ToggleCheckIn extends CheckInEvent {}
