class Country {
  final String name;
  final String officialName;
  final String capital;
  final int? population;
  final String? region;
  final String? subregion;
  final String flagEmoji;
  final double? area;
  final dynamic languages;
  final dynamic currencies;
  final List<dynamic>? timezones;
  final List<dynamic>? borders;
  final List<dynamic>? continents;
  final bool? independent;
  final bool? unMember;
  final Map<String, dynamic> rawJson;

  const Country({
    required this.name,
    required this.officialName,
    required this.capital,
    this.population,
    this.region,
    this.subregion,
    required this.flagEmoji,
    this.area,
    this.languages,
    this.currencies,
    this.timezones,
    this.borders,
    this.continents,
    this.independent,
    this.unMember,
    required this.rawJson,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // names
    final names = json['names'] ?? json['name'];
    String name = 'Unknown';
    String officialName = 'N/A';
    if (names is Map) {
      name = (names['common'] ?? names['official'] ?? 'Unknown').toString();
      officialName = (names['official'] ?? 'N/A').toString();
    } else if (names is String) {
      name = names;
    }

    // flag
    final flag = json['flag'] ?? json['emoji'];
    String flagEmoji = '🌍';
    if (flag is Map) {
      flagEmoji = (flag['emoji'] ?? '🌍').toString();
    } else if (flag is String && flag.isNotEmpty) {
      flagEmoji = flag;
    }

    // capital
    final capitalField = json['capitals'] ?? json['capital'];
    String capital = 'N/A';
    if (capitalField is List && capitalField.isNotEmpty) {
      capital = _capitalItemName(capitalField.first);
    } else if (capitalField is Map) {
      capital = _capitalItemName(capitalField);
    } else if (capitalField is String) {
      capital = capitalField;
    }

    return Country(
      name: name,
      officialName: officialName,
      capital: capital,
      population: json['population'] is num
          ? (json['population'] as num).toInt()
          : null,
      region: json['region']?.toString(),
      subregion: json['subregion']?.toString(),
      flagEmoji: flagEmoji,
      area: json['area'] is num ? (json['area'] as num).toDouble() : null,
      languages: json['languages'],
      currencies: json['currencies'],
      timezones: json['timezones'] is List ? json['timezones'] : null,
      borders: json['borders'] is List ? json['borders'] : null,
      continents: json['continents'] is List ? json['continents'] : null,
      independent: json['independent'] is bool ? json['independent'] : null,
      unMember: json['unMember'] is bool ? json['unMember'] : null,
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => rawJson;

  static String _capitalItemName(dynamic value) {
    if (value is Map) {
      return (value['name'] ?? value['common'] ?? value['capital'] ?? 'N/A')
          .toString();
    }
    if (value == null) {
      return 'N/A';
    }
    return value.toString();
  }

  String get displayPopulation =>
      population != null ? population.toString() : 'N/A';
  String get displayRegion => region ?? 'N/A';
  String get displaySubregion => subregion ?? 'N/A';
  String get displayArea => area != null ? area.toString() : 'N/A';
  String get displayIndependent =>
      independent == true ? 'Yes' : (independent == false ? 'No' : 'N/A');
  String get displayUnMember =>
      unMember == true ? 'Yes' : (unMember == false ? 'No' : 'N/A');

  String get displayLanguages => displayValue(languages);
  String get displayCurrencies => displayValue(currencies);
  String get displayTimezones => displayValue(timezones);
  String get displayBorders => displayValue(borders);
  String get displayContinents => displayValue(continents);

  static String displayValue(dynamic value) {
    if (value == null) {
      return 'N/A';
    }

    if (value is bool) {
      return value ? 'Yes' : 'No';
    }

    if (value is List) {
      if (value.isEmpty) return 'N/A';

      return value
          .map((item) {
            if (item is Map) {
              return (item['name'] ??
                      item['common'] ??
                      item['official'] ??
                      item['symbol'] ??
                      'N/A')
                  .toString();
            }

            return item.toString();
          })
          .join(', ');
    }

    if (value is Map) {
      if (value.isEmpty) return 'N/A';

      return value.entries
          .map((entry) {
            final item = entry.value;

            if (item is Map) {
              final name = item['name']?.toString() ?? '';
              final symbol = item['symbol']?.toString() ?? '';

              if (name.isNotEmpty && symbol.isNotEmpty) {
                return '$name ($symbol)';
              }

              if (name.isNotEmpty) {
                return name;
              }

              return entry.key.toString();
            }

            return item.toString();
          })
          .join(', ');
    }

    return value.toString();
  }
}
