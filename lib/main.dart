import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/country_cubit.dart';
import 'cubits/country_state.dart';
import 'models/country_model.dart';
import 'screens/favourites_screen.dart';

void main() {
  runApp(const MyApp());
}

// ==================== MY APP ====================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CountryCubit()..fetchCountries(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2589F5)),
          scaffoldBackgroundColor: const Color(0xFFF4F7FF),
        ),
        home: const CountryScreen(),
      ),
    );
  }
}

// ==================== COUNTRY SCREEN ====================

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  final TextEditingController controller = TextEditingController();
  Timer? debounce;

  void searchCountries(String value) {
    debounce?.cancel();

    debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<CountryCubit>().fetchCountries(value);
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1687F8), Color(0xFF55B4FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  const Text('🌍', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Country Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Explore countries around the world',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Favorite Countries',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoritesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: TextField(
                controller: controller,
                onChanged: searchCountries,
                decoration: InputDecoration(
                  hintText: 'Search country name...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF2589F5),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clear();
                      searchCountries('');
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFB7D9FF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFB7D9FF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFF2589F5),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Section title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.public, color: Color(0xFF21477F)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      controller.text.trim().isEmpty
                          ? 'All Countries'
                          : 'Search Results',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF21477F),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Country list
            Expanded(
              child: BlocBuilder<CountryCubit, CountryState>(
                builder: (context, state) {
                  if (state.isLoading && state.countries.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.error != null && state.countries.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off,
                              size: 48,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(height: 12),
                            Text(state.error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                context.read<CountryCubit>().fetchCountries(
                                      controller.text,
                                    );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state.countries.isEmpty) {
                    return const Center(
                      child: Text('No matching countries found'),
                    );
                  }

                  return Stack(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: state.countries.length,
                        itemBuilder: (context, index) {
                          final country = state.countries[index];

                          return _countryCard(context, country);
                        },
                      ),
                      if (state.isLoading)
                        const Align(
                          alignment: Alignment.topCenter,
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countryCard(BuildContext context, Country country) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 58,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            country.flagEmoji,
            style: const TextStyle(fontSize: 34),
          ),
        ),
        title: Text(
          country.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF17396C),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            'Capital: ${country.capital}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<CountryCubit, CountryState>(
              builder: (context, state) {
                final favorite = context.read<CountryCubit>().isFavorite(
                      country,
                    );

                return IconButton(
                  tooltip: favorite ? 'Remove favorite' : 'Add favorite',
                  onPressed: () {
                    context.read<CountryCubit>().toggleFavorite(country);
                  },
                  icon: Icon(
                    favorite ? Icons.favorite : Icons.favorite_border,
                    color: favorite ? Colors.red : Colors.grey,
                  ),
                );
              },
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF8CA7D4)),
          ],
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
  }
}

// ==================== COUNTRY DETAIL PAGE ====================

class CountryDetailPage extends StatelessWidget {
  final Country country;

  const CountryDetailPage({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Details'),
        backgroundColor: const Color(0xFF2589F5),
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<CountryCubit, CountryState>(
            builder: (context, state) {
              final favorite = context.read<CountryCubit>().isFavorite(country);

              return IconButton(
                tooltip: favorite ? 'Remove favorite' : 'Add favorite',
                onPressed: () {
                  context.read<CountryCubit>().toggleFavorite(country);
                },
                icon: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                  color: favorite ? Colors.red : Colors.white,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1687F8), Color(0xFF83CAFF)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Text(country.flagEmoji, style: const TextStyle(fontSize: 86)),
                const SizedBox(height: 12),
                Text(
                  country.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  country.officialName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _infoCard(Icons.location_city, 'Capital', country.capital),
          _infoCard(
            Icons.people_alt,
            'Population',
            country.displayPopulation,
          ),
          _infoCard(Icons.public, 'Region', country.displayRegion),
          _infoCard(Icons.map, 'Subregion', country.displaySubregion),
          _infoCard(
            Icons.square_foot,
            'Area (km²)',
            country.displayArea,
          ),
          _infoCard(
            Icons.language,
            'Languages',
            country.displayLanguages,
          ),
          _infoCard(
            Icons.attach_money,
            'Currencies',
            country.displayCurrencies,
          ),
          _infoCard(
            Icons.access_time,
            'Time Zones',
            country.displayTimezones,
          ),
          _infoCard(
            Icons.flag,
            'Border Countries',
            country.displayBorders,
          ),
          _infoCard(
            Icons.public,
            'Continents',
            country.displayContinents,
          ),
          _infoCard(
            Icons.check_circle_outline,
            'Independent',
            country.displayIndependent,
          ),
          _infoCard(
            Icons.verified,
            'UN Member',
            country.displayUnMember,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2589F5)),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
