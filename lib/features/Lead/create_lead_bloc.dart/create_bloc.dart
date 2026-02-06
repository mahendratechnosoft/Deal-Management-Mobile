import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/network/api_error.dart';
import 'package:xpertbiz/features/Lead/create_lead_bloc.dart/create_event.dart';
import '../data/repo/repo.dart';
import '../presentation/widgets/search_dropdown.dart';
import 'create_state.dart';

class CreateLeadBloc extends Bloc<CreateLeadEvent, CreateLeadState> {
  final LeadRepository repository;
  CreateLeadBloc(this.repository) : super(CreateLeadInitial()) {
    on<LoadCountriesEvent>(_loadCountries);
    on<CountrySelectedEvent>(_onCountrySelected);
    on<LoadStatesEvent>(_onLoadStates);
    on<StateSelectedEvent>(_onStateSelected);
    on<LoadCitiesEvent>(_onLoadCities);
    on<CitySelectedEvent>(_onCitySelected);
    on<ClearLocationEvent>(_onClearLocation);
    on<SubmitCreateLeadEvent>(_onSubmitCreateLead);
    on<DeleteLeadEvent>(_deleteLead);
  }

  Future<void> _loadCountries(
    LoadCountriesEvent event,
    Emitter<CreateLeadState> emit,
  ) async {
    // If this is the first time, initialize with CreateLeadDataState
    if (state is! CreateLeadDataState) {
      emit(CreateLeadDataState(
        countries: const [],
        states: const [],
        cities: const [],
        countriesLoading: true,
      ));
    }

    final currentState = state as CreateLeadDataState;
    emit(currentState.copyWith(countriesLoading: true));

    try {
      final countries = await loadCountries();
      emit(
        currentState.copyWith(
          countries: countries,
          countriesLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          countriesLoading: false,
          error: 'Failed to load countries: $e',
        ),
      );
      log('Error loading countries: $e');
    }
  }

  Future<void> _onCountrySelected(
    CountrySelectedEvent event,
    Emitter<CreateLeadState> emit,
  ) async {
    final currentState = state as CreateLeadDataState;

    emit(
      currentState.copyWith(
        selectedCountry: event.country,
        selectedState: null,
        selectedCity: null,
        states: const [],
        cities: const [],
        statesLoading: true,
        error: null,
      ),
    );

    // Load states for the selected country
    add(LoadStatesEvent(event.country.code));
  }

  Future<void> _onLoadStates(
    LoadStatesEvent event,
    Emitter<CreateLeadState> emit,
  ) async {
    final currentState = state as CreateLeadDataState;

    try {
      final states = await loadStatesByCountry(event.countryCode);
      emit(
        currentState.copyWith(
          states: states,
          statesLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          statesLoading: false,
          error: 'Failed to load states: $e',
        ),
      );
      log('Error loading states: $e');
    }
  }

  Future<void> _onStateSelected(
    StateSelectedEvent event,
    Emitter<CreateLeadState> emit,
  ) async {
    final currentState = state as CreateLeadDataState;

    emit(
      currentState.copyWith(
        selectedState: event.state,
        selectedCity: null,
        cities: const [],
        citiesLoading: true,
        error: null,
      ),
    );

    // Load cities for the selected state
    add(LoadCitiesEvent(event.state.countryCode, event.state.code));
  }

  Future<void> _onLoadCities(
    LoadCitiesEvent event,
    Emitter<CreateLeadState> emit,
  ) async {
    final currentState = state as CreateLeadDataState;

    try {
      final cities =
          await loadCitiesByState(event.countryCode, event.stateCode);
      emit(
        currentState.copyWith(
          cities: cities,
          citiesLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          citiesLoading: false,
          error: 'Failed to load cities: $e',
        ),
      );
      log('Error loading cities: $e');
    }
  }

  Future<void> _onCitySelected(
    CitySelectedEvent event,
    Emitter<CreateLeadState> emit,
  ) async {
    final currentState = state as CreateLeadDataState;

    emit(
      currentState.copyWith(
        selectedCity: event.city,
        error: null,
      ),
    );
  }

  Future<void> _onClearLocation(
    ClearLocationEvent event,
    Emitter<CreateLeadState> emit,
  ) async {
    final currentState = state as CreateLeadDataState;

    emit(
      currentState.copyWith(
        selectedCountry: null,
        selectedState: null,
        selectedCity: null,
        states: const [],
        cities: const [],
        error: null,
      ),
    );
  }

  Future<void> _onSubmitCreateLead(
    SubmitCreateLeadEvent event,
    Emitter<CreateLeadState> emit,
  ) async {
    final currentState = state as CreateLeadDataState;
    emit(currentState.copyWith(
      submitting: true,
      error: null,
      submitSuccess: false,
    ));

    try {
      await repository.createLead(request: event.request, edit: event.edit);
      emit(CreateLeadSuccess());
      emit(currentState.copyWith(
        submitting: false,
        submitSuccess: true,
        error: null,
      ));
    } catch (e) {
      ApiError.getMessage(e);
      emit(currentState.copyWith(
        submitting: false,
        error: 'Failed to create lead: $e',
      ));
    }
  }

  Future<void> _deleteLead(
      DeleteLeadEvent event, Emitter<CreateLeadState> emit) async {
    try {
      final res = await repository.deleteLead(event.leadId);
      log('Delete $res');
    } catch (e) {
      ApiError.getMessage(e);
      print('Error : $e');
    }
  }
}
