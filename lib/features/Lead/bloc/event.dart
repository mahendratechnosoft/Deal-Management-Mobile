import 'package:equatable/equatable.dart';

abstract class LeadEvent extends Equatable {
  const LeadEvent();

  @override
  List<Object?> get props => [];
}

class FetchLeadStatus extends LeadEvent {
  const FetchLeadStatus();
}
