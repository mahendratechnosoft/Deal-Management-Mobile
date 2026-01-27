import 'package:equatable/equatable.dart';

import '../data/model/create_reminder_payload.dart';

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
  final String? status;

  const FetchAllLeadsEvent({
    this.loadMore = false,
    this.status,
  });

  @override
  List<Object?> get props => [loadMore, status];
}

class ResetLeadEvent extends LeadEvent {
  const ResetLeadEvent();
}

class RefreshLeads extends LeadEvent {
  final String? status;

  const RefreshLeads({this.status});

  @override
  List<Object?> get props => [status];
}

class SearchLeadsEvent extends LeadEvent {
  final String searchQuery;

  const SearchLeadsEvent(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}

class FilterByDateEvent extends LeadEvent {
  final DateTime? selectedDate;

  const FilterByDateEvent(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

class ClearSearchEvent extends LeadEvent {
  const ClearSearchEvent();
}

class ClearAllFiltersEvent extends LeadEvent {
  const ClearAllFiltersEvent();
}

class LeadDetailsEvent extends LeadEvent {
  final String leadId; // Changed from taskId to leadId

  const LeadDetailsEvent({required this.leadId});

  @override
  List<Object?> get props => [leadId];
}

class ClearLeadDetailsEvent extends LeadEvent {
  const ClearLeadDetailsEvent();
}

class FetchLeadActivityEvent extends LeadEvent {
  final String leadId;

  const FetchLeadActivityEvent(this.leadId);

  @override
  List<Object?> get props => [leadId];
}

class FetchReminderEvent extends LeadEvent {
  final String leadId;
  const FetchReminderEvent(this.leadId);

  @override
  List<Object?> get props => [leadId];
}

class CreateReminderSubmitEvent extends LeadEvent {
  final CreateReminderRequest request;
  const CreateReminderSubmitEvent({required this.request});
}

// create lead
class SubmitCreateLead extends LeadEvent {
  final Map<String, dynamic> payload;
  const SubmitCreateLead(this.payload);
}