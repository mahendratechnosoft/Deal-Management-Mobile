import 'package:equatable/equatable.dart';

abstract class LeadEvent extends Equatable {
  const LeadEvent();

  @override
  List<Object?> get props => [];
}

class FetchLeadStatus extends LeadEvent {
  const FetchLeadStatus();
}

class FetchAllLeadsEvent extends LeadEvent {
  final bool loadMore;
  const FetchAllLeadsEvent({this.loadMore = false});
}

class RefreshLeads extends LeadEvent {}
