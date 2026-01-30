import 'package:equatable/equatable.dart';
import '../data/model/create_lead_payload.dart';
import '../presentation/widgets/search_dropdown.dart';

abstract class CreateLeadEvent extends Equatable {
  const CreateLeadEvent();

  @override
  List<Object?> get props => [];
}

class LoadCountriesEvent extends CreateLeadEvent {
  const LoadCountriesEvent();
}

class CountrySelectedEvent extends CreateLeadEvent {
  final CountryName country;
  const CountrySelectedEvent(this.country);

  @override
  List<Object?> get props => [country];
}

class LoadStatesEvent extends CreateLeadEvent {
  final String countryCode;
  const LoadStatesEvent(this.countryCode);

  @override
  List<Object?> get props => [countryCode];
}

class StateSelectedEvent extends CreateLeadEvent {
  final StateName state;
  const StateSelectedEvent(this.state);

  @override
  List<Object?> get props => [state];
}

class LoadCitiesEvent extends CreateLeadEvent {
  final String countryCode;
  final String stateCode;
  const LoadCitiesEvent(this.countryCode, this.stateCode);

  @override
  List<Object?> get props => [countryCode, stateCode];
}

class CitySelectedEvent extends CreateLeadEvent {
  final CityName city;
  const CitySelectedEvent(this.city);

  @override
  List<Object?> get props => [city];
}

class ClearLocationEvent extends CreateLeadEvent {
  const ClearLocationEvent();
}

class SubmitCreateLeadEvent extends CreateLeadEvent {
  final CreateLeadRequest request;
  final bool edit;
  const SubmitCreateLeadEvent(this.request, this.edit);

  @override
  List<Object?> get props => [request];
}

class UpdateLeadEvent extends CreateLeadEvent {
  final CreateLeadRequest request;
  const UpdateLeadEvent({required this.request});
}

class DeleteLeadEvent extends CreateLeadEvent {
  final String leadId;
  const DeleteLeadEvent({required this.leadId});
}
