import 'package:equatable/equatable.dart';
import 'package:xpertbiz/features/Lead/data/model/all_lead_model.dart';

import '../data/model/lead_status_model.dart';

abstract class LeadState extends Equatable {
  const LeadState();

  @override
  List<Object?> get props => [];
}

class LeadInitial extends LeadState {}

class LeadLoading extends LeadState {}

class LeadLoaded extends LeadState {
  final List<LeadStatusModel> leads;

  const LeadLoaded(this.leads);

  @override
  List<Object?> get props => [leads];
}

class LeadError extends LeadState {
  final String message;

  const LeadError(this.message);

  @override
  List<Object?> get props => [message];
}

class AllLeadInitial extends LeadState {}

class AllLeadLoading extends LeadState {}

class AllLeadState extends LeadState {
  final List<AllLeadModel> leads;
  final bool hasMore;
  final int currentPage;

  const AllLeadState({
    required this.leads,
    required this.hasMore,
    required this.currentPage,
  });
}

class AllLeadError extends LeadState {
  final String message;
  const AllLeadError(this.message);
}
