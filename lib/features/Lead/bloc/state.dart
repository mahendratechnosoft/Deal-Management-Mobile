import 'package:equatable/equatable.dart';

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
