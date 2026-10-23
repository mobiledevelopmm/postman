import '../models/country_model.dart';

class CountryState {
  final bool isLoading;
  final List<Country> countries;
  final List<Country> favoriteCountries;
  final String? error;

  const CountryState({
    this.isLoading = false,
    this.countries = const [],
    this.favoriteCountries = const [],
    this.error,
  });

  CountryState copyWith({
    bool? isLoading,
    List<Country>? countries,
    List<Country>? favoriteCountries,
    String? error,
    bool clearError = false,
  }) {
    return CountryState(
      isLoading: isLoading ?? this.isLoading,
      countries: countries ?? this.countries,
      favoriteCountries: favoriteCountries ?? this.favoriteCountries,
      error: clearError ? null : error ?? this.error,
    );
  }
}
