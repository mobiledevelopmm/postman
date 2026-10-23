import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/country_model.dart';
import 'country_state.dart';

class CountryCubit extends Cubit<CountryState> {
  CountryCubit() : super(const CountryState()) {
    loadFavorites();
  }

  // Replace with a NEW valid API key.
  // The key previously shared in chat should be revoked.
  static const String apiKey = 'rc_live_36d322b1f3ae4072b46165ffa0e7724d';

  static const String favoriteKey = 'favorite_countries';

  // Fetch all countries or search by country name.
  Future<void> fetchCountries([String query = '']) async {
    final search = query.trim();

    emit(state.copyWith(isLoading: true, clearError: true));

    final params = <String, String>{
      'response_fields':
          'names.common,names.official,capitals,population,'
          'region,subregion,flag.emoji,area,languages,'
          'currencies,timezones,borders,continents,'
          'independent,unMember',
      'pretty': '1',
      'limit': '100',
    };

    if (search.isNotEmpty) {
      params['q'] = search;
    }

    final url = Uri.https('api.restcountries.com', '/countries/v5', params);

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      debugPrint('Search: $search');
      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'API Error: ${response.statusCode}',
          ),
        );
        return;
      }

      final result = jsonDecode(response.body);

      if (result is! Map<String, dynamic>) {
        emit(state.copyWith(isLoading: false, error: 'Invalid API response'));
        return;
      }

      final data = result['data'];
      final objects = data is Map ? data['objects'] : null;

      if (objects is! List) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Country list not found in API response',
          ),
        );
        return;
      }

      final countries = objects
          .whereType<Map>()
            .map((item) => Country.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          countries: countries,
          clearError: true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Country API error: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(
        state.copyWith(isLoading: false, error: 'Failed to load countries: $e'),
      );
    }
  }

  // Get country name safely.
  String _countryName(Country country) {
    return country.name.toLowerCase();
  }

  // Load saved favorites when the app starts.
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(favoriteKey) ?? [];

      final favorites = saved.map((item) {
        final map = Map<String, dynamic>.from(jsonDecode(item) as Map);
        return Country.fromJson(map);
      }).toList();

      emit(state.copyWith(favoriteCountries: favorites));
    } catch (e) {
      debugPrint('Load favorites error: $e');
    }
  }

  // Check whether a country is already a favorite.
  bool isFavorite(Country country) {
    final name = _countryName(country);

    return state.favoriteCountries.any((item) => _countryName(item) == name);
  }

  // Add or remove a favorite country.
  Future<void> toggleFavorite(Country country) async {
    final favorites = List<Country>.from(state.favoriteCountries);

    final name = _countryName(country);

    if (name.isEmpty) return;

    final index = favorites.indexWhere((item) => _countryName(item) == name);
    if (index >= 0) {
      // Already a favorite: remove it.
      favorites.removeAt(index);
    } else {
      // Not a favorite: add it.
      favorites.add(country);
    }

    // Update the UI immediately.
    emit(state.copyWith(favoriteCountries: favorites));

    // Save favorites for the next app launch.
    await _saveFavorites(favorites);
  }

  Future<void> _saveFavorites(List<Country> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(
        favoriteKey,
        favorites.map((item) => jsonEncode(item.toJson())).toList(),
      );
    } catch (e) {
      debugPrint('Save favorites error: $e');
    }
  }
}
