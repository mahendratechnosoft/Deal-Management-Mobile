import 'package:equatable/equatable.dart';
import '../presentation/widgets/search_dropdown.dart';

abstract class CreateLeadState extends Equatable {
  const CreateLeadState();

  @override
  List<Object?> get props => [];
}

class CreateLeadInitial extends CreateLeadState {}

class CreateLeadLoading extends CreateLeadState {
  final String? message;
  const CreateLeadLoading({this.message});
  
  @override
  List<Object?> get props => [message];
}

class CreateLeadDataState extends CreateLeadState {
  final List<CountryName> countries;
  final List<StateName> states;
  final List<CityName> cities;
  final CountryName? selectedCountry;
  final StateName? selectedState;
  final CityName? selectedCity;
  final bool countriesLoading;
  final bool statesLoading;
  final bool citiesLoading;
  final bool submitting;
  final bool submitSuccess;
  final String? error;

  const CreateLeadDataState({
    this.countries = const [],
    this.states = const [],
    this.cities = const [],
    this.selectedCountry,
    this.selectedState,
    this.selectedCity,
    this.countriesLoading = false,
    this.statesLoading = false,
    this.citiesLoading = false,
    this.submitting = false,
    this.submitSuccess = false,
    this.error,
  });

  CreateLeadDataState copyWith({
    List<CountryName>? countries,
    List<StateName>? states,
    List<CityName>? cities,
    CountryName? selectedCountry,
    StateName? selectedState,
    CityName? selectedCity,
    bool? countriesLoading,
    bool? statesLoading,
    bool? citiesLoading,
    bool? submitting,
    bool? submitSuccess,
    String? error,
  }) {
    return CreateLeadDataState(
      countries: countries ?? this.countries,
      states: states ?? this.states,
      cities: cities ?? this.cities,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedState: selectedState ?? this.selectedState,
      selectedCity: selectedCity ?? this.selectedCity,
      countriesLoading: countriesLoading ?? this.countriesLoading,
      statesLoading: statesLoading ?? this.statesLoading,
      citiesLoading: citiesLoading ?? this.citiesLoading,
      submitting: submitting ?? this.submitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        countries,
        states,
        cities,
        selectedCountry,
        selectedState,
        selectedCity,
        countriesLoading,
        statesLoading,
        citiesLoading,
        submitting,
        submitSuccess,
        error,
      ];
}

class CreateLeadSuccess extends CreateLeadState {
  const CreateLeadSuccess();
}

class CreateLeadError extends CreateLeadState {
  final String message;
  const CreateLeadError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UpdateLeadLoading extends CreateLeadState {
  final String message;
  
  const UpdateLeadLoading(this.message);
}

class UpdateLeadSuccess extends CreateLeadState {
  const UpdateLeadSuccess();
}

class UpdateLeadError extends CreateLeadState {
  final String message;
  
  const UpdateLeadError(this.message);
}