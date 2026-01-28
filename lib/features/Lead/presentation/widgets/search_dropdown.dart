import 'package:country_state_city/country_state_city.dart';

mixin DropdownFlutterListFilter {
  bool filter(String query);
}

/* ================= COUNTRY ================= */

class CountryName with DropdownFlutterListFilter {
  final String name;
  final String code;

  const CountryName({
    required this.name,
    required this.code,
  });

  @override
  String toString() => name;

  @override
  bool filter(String query) =>
      name.toLowerCase().contains(query.toLowerCase());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryName &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/* ================= STATE ================= */

class StateName with DropdownFlutterListFilter {
  final String name;
  final String code;
  final String countryCode;

  const StateName({
    required this.name,
    required this.code,
    required this.countryCode,
  });

  @override
  String toString() => name;

  @override
  bool filter(String query) =>
      name.toLowerCase().contains(query.toLowerCase());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateName &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          countryCode == other.countryCode;

  @override
  int get hashCode => Object.hash(code, countryCode);
}

/* ================= CITY ================= */

class CityName with DropdownFlutterListFilter {
  final String name;
  final String code;
  final String stateCode;
  final String countryCode;

  const CityName({
    required this.name,
    required this.code,
    required this.stateCode,
    required this.countryCode,
  });

  @override
  String toString() => name;

  @override
  bool filter(String query) =>
      name.toLowerCase().contains(query.toLowerCase());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityName &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/* ================= HELPER FUNCTIONS ================= */

Future<List<CountryName>> loadCountries() async {
  try {
    final countryList = await getAllCountries();
    return countryList
        .map((c) => CountryName(
              name: c.name,
              code: c.isoCode,
            ))
        .toList();
  } catch (e) {
    print('Error loading countries: $e');
    // Fallback to a basic list if API fails
    return [
      CountryName(name: 'United States', code: 'US'),
      CountryName(name: 'Canada', code: 'CA'),
      CountryName(name: 'United Kingdom', code: 'GB'),
      CountryName(name: 'India', code: 'IN'),
      CountryName(name: 'Australia', code: 'AU'),
    ];
  }
}

Future<List<StateName>> loadStatesByCountry(String countryCode) async {
  try {
    final stateList = await getStatesOfCountry(countryCode);
    return stateList
        .map((s) => StateName(
              name: s.name,
              code: s.isoCode,
              countryCode: countryCode,
            ))
        .toList();
  } catch (e) {
    print('Error loading states for $countryCode: $e');
    // Return empty list or fallback based on country
    return _getFallbackStates(countryCode);
  }
}

Future<List<CityName>> loadCitiesByState(
  String countryCode,
  String stateCode,
) async {
  try {
    final cityList = await getStateCities(countryCode, stateCode);
    return cityList
        .map((c) => CityName(
              name: c.name,
              code: c.countryCode,
              stateCode: stateCode,
              countryCode: countryCode,
            ))
        .toList();
  } catch (e) {
    print('Error loading cities for $stateCode, $countryCode: $e');
    return _getFallbackCities(countryCode, stateCode);
  }
}

/* ================= FALLBACK DATA ================= */

List<StateName> _getFallbackStates(String countryCode) {
  switch (countryCode) {
    case 'US':
      return [
        StateName(name: 'California', code: 'CA', countryCode: 'US'),
        StateName(name: 'New York', code: 'NY', countryCode: 'US'),
        StateName(name: 'Texas', code: 'TX', countryCode: 'US'),
        StateName(name: 'Florida', code: 'FL', countryCode: 'US'),
        StateName(name: 'Illinois', code: 'IL', countryCode: 'US'),
      ];
    case 'IN':
      return [
        StateName(name: 'Maharashtra', code: 'MH', countryCode: 'IN'),
        StateName(name: 'Delhi', code: 'DL', countryCode: 'IN'),
        StateName(name: 'Karnataka', code: 'KA', countryCode: 'IN'),
        StateName(name: 'Tamil Nadu', code: 'TN', countryCode: 'IN'),
        StateName(name: 'Uttar Pradesh', code: 'UP', countryCode: 'IN'),
      ];
    default:
      return [];
  }
}

List<CityName> _getFallbackCities(String countryCode, String stateCode) {
  if (countryCode == 'US' && stateCode == 'CA') {
    return [
      CityName(name: 'Los Angeles', code: 'LA', stateCode: 'CA', countryCode: 'US'),
      CityName(name: 'San Francisco', code: 'SF', stateCode: 'CA', countryCode: 'US'),
      CityName(name: 'San Diego', code: 'SD', stateCode: 'CA', countryCode: 'US'),
    ];
  } else if (countryCode == 'IN' && stateCode == 'MH') {
    return [
      CityName(name: 'Mumbai', code: 'MUM', stateCode: 'MH', countryCode: 'IN'),
      CityName(name: 'Pune', code: 'PUN', stateCode: 'MH', countryCode: 'IN'),
      CityName(name: 'Nagpur', code: 'NAG', stateCode: 'MH', countryCode: 'IN'),
    ];
  }
  return [];
}