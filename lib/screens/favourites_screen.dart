import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/country_cubit.dart';
import '../cubits/country_state.dart';
import '../models/country_model.dart';
import '../main.dart' show CountryDetailPage;

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorite Countries'),
        backgroundColor: const Color(0xFF2589F5),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<CountryCubit, CountryState>(
        builder: (context, state) {
          final favorites = state.favoriteCountries;

          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 72,
                    color: Colors.blueGrey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No favorite countries yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text('Add countries using the heart button.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final Country country = favorites[index];

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Text(
                    country.flagEmoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                  title: Text(
                    country.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('Capital: ${country.capital}'),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    tooltip: 'Remove favorite',
                    onPressed: () {
                      context
                          .read<CountryCubit>()
                          .toggleFavorite(country);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CountryDetailPage(country: country),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
